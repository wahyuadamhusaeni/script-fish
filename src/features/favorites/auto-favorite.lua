--[[
    Auto Favorite Module

    Automatically favorites fish based on filters:
    - Name
    - Rarity
    - Variant

    Usage:
        local AutoFavorite = require("src/features/favorites/auto-favorite")
        AutoFavorite.setFilters({ names = {"Megalodon"}, rarities = {"Mythic"} })
        AutoFavorite.start()
]]

local State = require("src/core/state")
local Services = require("src/core/services")
local Constants = require("src/core/constants")
local Events = require("src/network/events")

local AutoFavorite = {}

-- Private variables
local favoriteCache = {}
local dataConnection = nil

--[[
    Convert table to set (for faster lookups)
    @param tbl table - Array to convert
    @return table - Set table
]]
local function toSet(tbl)
    local set = {}

    if type(tbl) == "table" then
        -- Handle array part
        for _, value in ipairs(tbl) do
            set[value] = true
        end

        -- Handle dictionary part
        for key, value in pairs(tbl) do
            if value then
                set[key] = true
            end
        end
    end

    return set
end

--[[
    Check if item should be favorited based on filters
    @param item table - Item data
    @return boolean - Should favorite
]]
local function shouldFavorite(item)
    if not State.autoFavEnabled then
        return false
    end

    -- Get item data
    local itemData = Services.ItemUtility.GetItemDataFromItemType("Items", item.Id)

    if not itemData or itemData.Data.Type ~= "Fish" then
        return false
    end

    local rarity = Constants.TIER_FISH[itemData.Data.Tier]
    local name = itemData.Data.Name
    local variant = (item.Metadata and item.Metadata.VariantId) or "None"

    -- Check filters
    local matchName = State.selectedName[name]
    local matchRarity = State.selectedRarity[rarity]
    local matchVariant = State.selectedVariant[variant]

    -- Check current favorite status
    local currentlyFavorited = rawget(favoriteCache, item.UUID)
    if currentlyFavorited == nil then
        currentlyFavorited = item.Favorited
    end

    -- Logic: If both name AND variant are selected, match both
    -- Otherwise, match name OR rarity
    local shouldBeFavorited = false

    if next(State.selectedVariant) ~= nil and next(State.selectedName) ~= nil then
        shouldBeFavorited = matchName and matchVariant
    else
        shouldBeFavorited = matchName or matchRarity
    end

    return shouldBeFavorited and not currentlyFavorited, item.UUID
end

--[[
    Favorite an item
    @param uuid string - Item UUID
]]
local function favoriteItem(uuid)
    Events.REFav:FireServer(uuid)
    rawset(favoriteCache, uuid, true)
end

--[[
    Scan inventory and favorite matching items
]]
local function scanInventory()
    if not State.autoFavEnabled then
        return
    end

    local Data = Services.Replion.Client:WaitReplion("Data")
    local items = Data:GetExpect({"Inventory", "Items"})

    for _, item in ipairs(items) do
        local should, uuid = shouldFavorite(item)
        if should then
            favoriteItem(uuid)
        end
    end
end

--[[
    Start auto favorite
]]
function AutoFavorite.start()
    if State.autoFavEnabled then
        return
    end

    State.autoFavEnabled = true

    -- Initial scan
    scanInventory()

    -- Watch for new items
    local Data = Services.Replion.Client:WaitReplion("Data")
    if dataConnection then
        dataConnection:Disconnect()
    end

    dataConnection = Data:OnChange({"Inventory", "Items"}, scanInventory)
end

--[[
    Stop auto favorite
]]
function AutoFavorite.stop()
    State.autoFavEnabled = false

    if dataConnection then
        dataConnection:Disconnect()
        dataConnection = nil
    end
end

--[[
    Set name filter
    @param names table - Array of fish names
]]
function AutoFavorite.setNames(names)
    State.selectedName = toSet(names)
end

--[[
    Set rarity filter
    @param rarities table - Array of rarities
]]
function AutoFavorite.setRarities(rarities)
    State.selectedRarity = toSet(rarities)
end

--[[
    Set variant filter (only works with name filter)
    @param variants table - Array of variants
]]
function AutoFavorite.setVariants(variants)
    if next(State.selectedName) ~= nil then
        State.selectedVariant = toSet(variants)
    else
        State.selectedVariant = {}
        warn("[AutoFavorite] Select names first before selecting variants")
    end
end

--[[
    Unfavorite all fish
]]
function AutoFavorite.unfavoriteAll()
    local Data = Services.Replion.Client:WaitReplion("Data")
    local items = Data:GetExpect({"Inventory", "Items"})

    for _, item in ipairs(items) do
        local isFavorited = rawget(favoriteCache, item.UUID)
        if isFavorited == nil then
            isFavorited = item.Favorited
        end

        if isFavorited then
            Events.REFav:FireServer(item.UUID)
            rawset(favoriteCache, item.UUID, false)
        end
    end
end

--[[
    Setup favorite state change listener
]]
function AutoFavorite.setupListener()
    -- Listen for favorite state changes from server
    Events.REFavChg.OnClientEvent:Connect(function(uuid, favorited)
        rawset(favoriteCache, uuid, favorited)
    end)
end

-- Initialize listener on module load
AutoFavorite.setupListener()

return AutoFavorite
