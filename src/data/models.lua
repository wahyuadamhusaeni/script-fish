-- src/data/models.lua
-- Data models and utilities for accessing game data

local Services = require("src/core/services")

local Data = {}

-- Initialize data sources
local function initializeData()
    -- Get Net module
    local netModule = Services.RS.Packages._Index:FindFirstChild("sleitnick_net@0.2.0")
    if not netModule then
        error("[Data] Net module not found")
    end

    local Net = require(netModule.net)

    -- Get Replion module
    local replionModule = Services.RS.Packages._Index:FindFirstChild("ytrev_replion@2.0.0-rc.3")
    if not replionModule then
        error("[Data] Replion module not found")
    end

    local Replion = require(replionModule.replion)

    -- Wait for Data replion
    Data.Data = Replion.Client:WaitReplion("Data")

    -- Get Items folder
    Data.Items = Services.RS:WaitForChild("Items")

    -- Get utility modules from RS
    local itemUtilModule = Services.RS:FindFirstChild("ItemUtility")
    local playerStatsUtilModule = Services.RS:FindFirstChild("PlayerStatsUtility")

    if itemUtilModule then
        Data.ItemUtility = require(itemUtilModule)
    else
        warn("[Data] ItemUtility not found")
        Data.ItemUtility = {
            GetItemDataFromItemType = function(itemType, itemId)
                -- Fallback implementation
                local itemsFolder = Data.Items:FindFirstChild(itemType)
                if itemsFolder then
                    local item = itemsFolder:FindFirstChild(tostring(itemId))
                    if item then
                        return {
                            Data = require(item)
                        }
                    end
                end
                return nil
            end,
            GetItemData = function(itemId)
                -- Try to find in Items folder
                for _, category in ipairs(Data.Items:GetChildren()) do
                    local item = category:FindFirstChild(tostring(itemId))
                    if item then
                        return require(item)
                    end
                end
                return nil
            end,
            GetEnchantData = function(enchantId)
                local enchants = Data.Items:FindFirstChild("Enchant Stones")
                if enchants then
                    local enchant = enchants:FindFirstChild(tostring(enchantId))
                    if enchant then
                        return require(enchant)
                    end
                end
                return nil
            end
        }
    end

    if playerStatsUtilModule then
        Data.PlayerStatsUtility = require(playerStatsUtilModule)
    else
        warn("[Data] PlayerStatsUtility not found")
        Data.PlayerStatsUtility = {
            GetPlayerModifiers = function(player)
                return {}
            end,
            GetSellPrice = function(basePrice, modifiers)
                -- Simple sell price calculation
                return basePrice or 0
            end,
            GetItemFromInventory = function(data, filterFunc)
                local items = data:GetExpect({ "Inventory", "Items" }) or {}
                for _, item in ipairs(items) do
                    if filterFunc(item) then
                        return item
                    end
                end
                return nil
            end
        }
    end

    print("[Data] All data models initialized")
end

-- Initialize when module is loaded
local success, err = pcall(initializeData)
if not success then
    warn("[Data] Failed to initialize:", err)
end

return Data
