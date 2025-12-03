local Constants = require("src/core/constants")
local Services = require("src/core/services")

local BlatantFish = require("src/features/fishing/blatant-fish")
local AutoSell = require("src/features/selling/auto-sell")
local AutoFavorite = require("src/features/favorites/auto-favorite")
local LegitFish = require("src/features/fishing/legit-fish")



local fishNames = {}
local FishingTab = {}

local function getFishNames()
    if #fishNames > 0 then
        return fishNames
    end

    local items = Services.RS:WaitForChild("Items")

    for _, item in ipairs(items:GetChildren()) do
        if item:IsA("ModuleScript") then
            local success, result = pcall(require, item)
            if success and result.Data and result.Data.Type == "Fish" then
                table.insert(fishNames, result.Data.Name)
            end
        end
    end

    table.sort(fishNames)
    return fishNames
end

function FishingTab.setup(tab)
    local legitSection = tab:Section({
        Title = "Legit Feature"
    })

    legitSection:Dropdown({
        Title = "Mode",
        Value = "Always Perfect",
        Values = { "Always Perfect", "Normal" },
        Callback = function(value)
            LegitFish.setMode(value)
        end
    })

    legitSection:Input({
        Title = "Fishing Delay",
        Value = "0.7",
        Type = "Input",
        Callback = function(value)
            LegitFish.setFishingDelay(value)
        end
    })

    legitSection:Toggle({
        Title = "Enable Legit Fishing",
        Value = false,
        Callback = function(enabled)
            if enabled then
                LegitFish.start()
            else
                LegitFish.stop()
            end
        end
    })

    legitSection.Divider()

    legitSection:Input({
        Title = "Shake Delay",
        Value = "0",
        Type = "Input",
        Callback = function(value)
            LegitFish.setShakeDelay(value)
        end
    })

    legitSection:Toggle({
        Title = "Auto Shake",
        Value = false,
        Callback = function(enabled)
            _G.ShakeEnabled = enabled
            if enabled then
                LegitFish.startAutoShake()
                print("[Fish Tab] Auto shake enabled")
            else
                LegitFish.stopAutoShake()
                print("[Fish Tab] Auto shake disabled")
            end
        end
    })

    local blatanSection = tab:Section({
        Title = "Blatan Feature"
    })

    blatanSection:Input({
        Title = "Delay Reel",
        Value = "1.8",
        Type = "Input",
        Callback = function(value)
            BlatantFish.setReelDelay(value)
        end
    })

    blatanSection:Input({
        Title = "Delay Fishing",
        Value = "0.7",
        Type = "Input",
        Callback = function(value)
            BlatantFish.setFishingDelay(value)
        end
    })

    blatanSection:Toggle({
        Title = "Blatan Fishing",
        Value = false,
        Callback = function(enabled)
            if enabled then
                BlatantFish.start()
            else
                BlatantFish.stop()
            end
        end
    })

    blatanSection:Button({
        Title = "Recovery Fishing",
        Callback = function()
            BlatantFish.recovery()
        end
    })

    local sellingSection = tab:Section({
        Title = "Selling Feature"
    })

    sellingSection:Dropdown({
        Title = "Fish Type",
        Value = "Delay",
        Values = {
            "Delay",
            "Count"
        },
        Callback = function(value)
            AutoSell.setMode(value)
        end
    })

    sellingSection:Input({
        Title = "Set Value",
        Desc = "Delay = Minute, Count = Backpack Count",
        Value = "1",
        Type = "Input",
        Callback = function(value)
            AutoSell.setDelay(value)
        end
    })

    sellingSection:Toggle({
        Title = "Start Auto Selling",
        Value = false,
        Callback = function(enabled)
            if enabled then
                AutoSell.start()
            else
                AutoSell.stop()
            end
        end
    })

    sellingSection:Button({
        Title = "Sell Now",
        Callback = function()
            AutoSell.sellNow()
        end
    })

    local favoriteSection = tab:Section({
        Title = "Favorite Feature"
    })

    favoriteSection:Dropdown({
        Title = "Favorite by Name",
        Value = {},
        Values = getFishNames(),
        Multi = true,
        AllowNone = true,
        Callback = function(value)
            AutoFavorite.setNames(value)
        end
    })

    favoriteSection:Dropdown({
        Title = "Favorite by Rarity",
        Value = {},
        Values = Constants.TIER_FISH_2,
        Multi = true,
        AllowNone = true,
        Callback = function(value)
            AutoFavorite.setRarities(value)
        end
    })

    favoriteSection:Dropdown({
        Title = "Favorite by Variant",
        Value = {},
        Values = Constants.VARIANTS,
        Multi = true,
        AllowNone = true,
        Callback = function(value)
            AutoFavorite.setVariants(value)
        end
    })

    favoriteSection:Toggle({
        Title = "Auto Favorite",
        Value = false,
        Callback = function(enabled)
            if enabled then
                AutoFavorite.start()
            else
                AutoFavorite.stop()
            end
        end
    })
end

return FishingTab
