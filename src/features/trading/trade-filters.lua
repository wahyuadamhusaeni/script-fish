-- src/features/trading/trade-filters.lua
-- Trade filter utilities for grouping and selecting items

local Services = require("src/core/services")
local Data = require("src/data/models")

local TradeFilters = {}

-- Group items by name with their UUIDs
function TradeFilters.getGroupedByType(itemType)
    local grouped = {}
    local options = {}

    local items = Data.Data:GetExpect({ "Inventory", "Items" }) or {}

    for _, item in ipairs(items) do
        if not item.Favorited then
            local itemData = Data.ItemUtility.GetItemDataFromItemType("Items", item.Id)

            if itemData and itemData.Data.Type == itemType then
                local name = itemData.Data.Name

                if not grouped[name] then
                    grouped[name] = {
                        name = name,
                        uuids = {},
                        count = 0,
                        id = item.Id
                    }
                end

                table.insert(grouped[name].uuids, item.UUID)
                grouped[name].count = grouped[name].count + 1
            end
        end
    end

    -- Create dropdown options with count
    for name, data in pairs(grouped) do
        table.insert(options, string.format("%s x%d", name, data.count))
    end

    table.sort(options)

    return grouped, options
end

-- Get fish by rarity (for trade by rarity)
function TradeFilters.getFishByRarity(rarity)
    local fishes = {}
    local items = Data.Data:GetExpect({ "Inventory", "Items" }) or {}

    for _, item in ipairs(items) do
        if not item.Favorited then
            local itemData = Data.ItemUtility.GetItemDataFromItemType("Items", item.Id)

            if itemData and itemData.Data.Type == "Fish" then
                local fishRarity = _G.TierFish[itemData.Data.Tier]

                if fishRarity == rarity then
                    table.insert(fishes, {
                        UUID = item.UUID,
                        Name = itemData.Data.Name
                    })
                end
            end
        end
    end

    return fishes
end

-- Get fish suitable for coin trading (sorted by price)
function TradeFilters.getFishForCoins()
    local localPlayer = Services.Players.LocalPlayer
    local modifiers = Data.PlayerStatsUtility:GetPlayerModifiers(localPlayer)
    local fishes = {}

    local items = Data.Data:GetExpect({ "Inventory", "Items" }) or {}

    for _, item in ipairs(items) do
        if not item.Favorited then
            local itemData = Data.ItemUtility.GetItemDataFromItemType("Items", item.Id)

            if itemData and itemData.Data.Type == "Fish" then
                local price = Data.PlayerStatsUtility:GetSellPrice(
                    itemData.Data.Price,
                    modifiers
                )

                table.insert(fishes, {
                    UUID = item.UUID,
                    Name = itemData.Data.Name,
                    Price = price
                })
            end
        end
    end

    return fishes
end

-- Choose fishes by target coin range
function TradeFilters.chooseFishesByRange(fishes, targetCoins)
    -- Sort by price descending (most expensive first)
    table.sort(fishes, function(a, b)
        return a.Price > b.Price
    end)

    local selected = {}
    local totalValue = 0

    -- Pick fishes until we reach target
    for _, fish in ipairs(fishes) do
        if totalValue + fish.Price <= targetCoins then
            table.insert(selected, fish)
            totalValue = totalValue + fish.Price
        end

        if totalValue >= targetCoins then
            break
        end
    end

    -- If still below target and we have fish, add cheapest one
    if totalValue < targetCoins and #fishes > 0 then
        table.insert(selected, fishes[#fishes])
        totalValue = totalValue + fishes[#fishes].Price
    end

    return selected, totalValue
end

-- Check if item still exists in inventory (for trade confirmation)
function TradeFilters.itemExists(uuid)
    local items = Data.Data:GetExpect({ "Inventory", "Items" }) or {}

    for _, item in ipairs(items) do
        if item.UUID == uuid then
            return true
        end
    end

    return false
end

return TradeFilters
