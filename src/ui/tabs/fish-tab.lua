--[[
    Fish Tab Module

    UI for fishing features.

    Usage:
        local FishTab = require("src/ui/tabs/fish-tab")
        FishTab.setup(tab)
]]

local InstantFish = require("src/features/fishing/instant-fish")
local LegitFish = require("src/features/fishing/legit-fish")
local BlatantFish = require("src/features/fishing/blatant-fish")
local AutoSell = require("src/features/selling/auto-sell")
local AutoFavorite = require("src/features/favorites/auto-favorite")
local State = require("src/core/state")
local Constants = require("src/core/constants")
local Services = require("src/core/services")

local FishTab = {}

-- Fish names list (will be populated)
local fishNames = {}

-- Get all fish names from game
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

--[[
    Setup fish tab UI
    @param tab table - Tab object from UI library
]]
function FishTab.setup(tab)
    -- Fishing Features Section
    local fishingSection = tab:AddSection("Instant Fishing")

    -- Instant Fishing Toggle
    fishingSection:AddToggle({
        Title = "Instant Fishing",
        Content = "Auto catch fish instantly (bypasses minigame)",
        Default = false,
        Callback = function(enabled)
            if enabled then
                InstantFish.start()
                print("[Fish Tab] Instant fishing started")
            else
                InstantFish.stop()
                print("[Fish Tab] Instant fishing stopped")
            end
        end
    })

    -- Delay Complete Input
    fishingSection:AddInput({
        Title = "Complete Delay",
        Content = "Delay after catching (seconds)",
        Value = tostring(_G.DelayComplete or 0),
        Callback = function(value)
            local delay = tonumber(value)
            if delay and delay >= 0 then
                _G.DelayComplete = delay
                print("[Fish Tab] Complete delay set to:", delay)
            end
        end
    })

    -- Fishing Stats Section
    local statsSection = tab:AddSection("Fishing Stats")

    local statsLabel = statsSection:AddParagraph({
        Title = "Statistics",
        Content = "Fish Count: 0\nStatus: Idle"
    })

    -- Update stats periodically
    task.spawn(function()
        while true do
            task.wait(2)

            if InstantFish.isRunning() then
                local count = InstantFish.getFishCount()
                local startCount = _G.Celestial.InstantCount or 0
                local caught = count - startCount

                statsLabel:SetContent(string.format(
                    "Fish Count: %d\nCaught: %d\nStatus: Fishing",
                    count, caught
                ))
            else
                local count = InstantFish.getFishCount()
                statsLabel:SetContent(string.format(
                    "Fish Count: %d\nStatus: Idle",
                    count
                ))
            end
        end
    end)

    -- Legit Fishing Section
    local legitSection = tab:AddSection("Legit Fishing")

    -- Legit Mode Dropdown
    legitSection:AddDropdown({
        Title = "Legit Mode",
        Options = {"Always Perfect", "Normal"},
        Default = "Always Perfect",
        Multi = false,
        Callback = function(mode)
            LegitFish.setMode(mode)
            print("[Fish Tab] Legit mode:", mode)
        end
    })

    -- Fishing Delay Input
    legitSection:AddInput({
        Title = "Fishing Delay",
        Content = "Delay before completing minigame (seconds)",
        Value = tostring(_G.Delay or 0),
        Callback = function(value)
            local delay = tonumber(value)
            if delay and delay >= 0 then
                _G.Delay = delay
                print("[Fish Tab] Fishing delay set to:", delay)
            end
        end
    })

    -- Legit Fishing Toggle
    legitSection:AddToggle({
        Title = "Enable Legit Fishing",
        Content = "Auto fishing with game mechanics",
        Default = false,
        Callback = function(enabled)
            if enabled then
                LegitFish.start()
                print("[Fish Tab] Legit fishing started")
            else
                LegitFish.stop()
                print("[Fish Tab] Legit fishing stopped")
            end
        end
    })

    legitSection:AddDivider()

    -- Auto Shake Toggle
    legitSection:AddToggle({
        Title = "Auto Shake",
        Content = "Spam click during fishing (independent feature)",
        Default = false,
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

    -- Shake Delay Input
    legitSection:AddInput({
        Title = "Shake Delay",
        Content = "Delay between clicks (seconds)",
        Value = "0",
        Callback = function(value)
            LegitFish.setShakeDelay(value)
        end
    })

    -- Blatant Fishing Section
    local blatantSection = tab:AddSection("Blatant Fishing")

    -- Blatant Mode Dropdown
    blatantSection:AddDropdown({
        Title = "Blatant Mode",
        Options = {"Fast", "Random Result"},
        Multi = false,
        Callback = function(mode)
            BlatantFish.setMode(mode)
            print("[Fish Tab] Blatant mode:", mode)
        end
    })

    -- Reel Delay Input
    blatantSection:AddInput({
        Title = "Reel Delay",
        Content = "Delay between catches (seconds)",
        Value = "0.5",
        Callback = function(value)
            BlatantFish.setReelDelay(value)
        end
    })

    -- Blatant Fishing Toggle
    blatantSection:AddToggle({
        Title = "Enable Blatant Fishing",
        Content = "Aggressive fishing method (HIGH DETECTION RISK)",
        Default = false,
        Callback = function(enabled)
            if enabled then
                BlatantFish.start()
                print("[Fish Tab] Blatant fishing started")
            else
                BlatantFish.stop()
                print("[Fish Tab] Blatant fishing stopped")
            end
        end
    })

    -- Recovery Button
    blatantSection:AddButton({
        Title = "Recovery Fishing",
        Content = "Cancel stuck fishing state",
        Callback = function()
            BlatantFish.recovery()
            print("[Fish Tab] Recovery executed")
        end
    })

    -- AUTO SELL SECTION
    local sellSection = tab:AddSection("Auto Sell")

    -- Sell Mode Dropdown
    sellSection:AddDropdown({
        Title = "Sell Mode",
        Options = {"Delay", "Count"},
        Multi = false,
        Default = "Delay",
        Callback = function(mode)
            AutoSell.setMode(mode)
            print("[Fish Tab] Sell mode:", mode)
        end
    })

    -- Delay Input
    sellSection:AddInput({
        Title = "Sell Delay (seconds)",
        Content = "Sell every X seconds",
        Value = "60",
        Callback = function(value)
            local delay = tonumber(value)
            if delay and delay >= 1 then
                AutoSell.setDelay(delay)
                print("[Fish Tab] Sell delay:", delay)
            end
        end
    })

    -- Count Input
    sellSection:AddInput({
        Title = "Sell Count",
        Content = "Sell when fish count reaches X",
        Value = "50",
        Callback = function(value)
            local count = tonumber(value)
            if count and count >= 1 then
                AutoSell.setCount(count)
                print("[Fish Tab] Sell count:", count)
            end
        end
    })

    -- Auto Sell Toggle
    sellSection:AddToggle({
        Title = "Enable Auto Sell",
        Content = "Automatically sell fish",
        Default = false,
        Callback = function(enabled)
            if enabled then
                AutoSell.start()
                print("[Fish Tab] Auto sell started")
            else
                AutoSell.stop()
                print("[Fish Tab] Auto sell stopped")
            end
        end
    })

    -- AUTO FAVORITE SECTION
    local favSection = tab:AddSection("Auto Favorite")

    -- Fish Name Dropdown
    favSection:AddDropdown({
        Title = "Favorite by Name",
        Options = getFishNames(),
        Multi = true,
        Callback = function(selected)
            AutoFavorite.setNames(selected)
            print("[Fish Tab] Favorite names:", #selected, "selected")
        end
    })

    -- Rarity Dropdown
    favSection:AddDropdown({
        Title = "Favorite by Rarity",
        Options = {
            "Uncommon",
            "Rare",
            "Epic",
            "Legendary",
            "Mythic",
            "Secret"
        },
        Multi = true,
        Callback = function(selected)
            AutoFavorite.setRarities(selected)
            print("[Fish Tab] Favorite rarities:", #selected, "selected")
        end
    })

    -- Variant Dropdown
    favSection:AddDropdown({
        Title = "Favorite by Variant",
        Content = "Only works with Name filter",
        Options = Constants.VARIANTS,
        Multi = true,
        Callback = function(selected)
            AutoFavorite.setVariants(selected)
            print("[Fish Tab] Favorite variants:", #selected, "selected")
        end
    })

    -- Auto Favorite Toggle
    favSection:AddToggle({
        Title = "Enable Auto Favorite",
        Content = "Auto favorite matching fish",
        Default = false,
        Callback = function(enabled)
            if enabled then
                AutoFavorite.start()
                print("[Fish Tab] Auto favorite started")
            else
                AutoFavorite.stop()
                print("[Fish Tab] Auto favorite stopped")
            end
        end
    })

    -- Unfavorite All Button
    favSection:AddButton({
        Title = "Unfavorite All Fish",
        Content = "Remove favorite from all fish",
        Callback = function()
            AutoFavorite.unfavoriteAll()
            print("[Fish Tab] All fish unfavorited")
        end
    })

    -- Info Section
    local infoSection = tab:AddSection("Information")

    infoSection:AddParagraph({
        Title = "Fishing Modes",
Content = [[
INSTANT FISHING:
- Bypasses minigame completely
- Fast and efficient
- Medium detection risk

LEGIT FISHING:
- Always Perfect: Auto cast + perfect catch
- Normal: Power override + auto cast
- Auto Shake: Independent spam click
- Lower detection risk

BLATANT FISHING:
- Aggressive method
- Fast mode: Fastest possible
- Random Result: Slight delay
- HIGH DETECTION RISK

WARNING: All methods risk ban!
Use at your own risk.
        ]]
    })

    print("[Fish Tab] Initialized")
end

return FishTab
