--[[
    ╔═══════════════════════════════════════════════════╗
    ║          Roblox FishIt Script - Bundled          ║
    ║                                                   ║
    ║  Build Date: 2025-12-03 02:54:11                        ║
    ║  Version: 2.0.0                              ║
    ║                                                   ║
    ║  ⚠️  FOR EDUCATIONAL PURPOSES ONLY               ║
    ║                                                   ║
    ╚═══════════════════════════════════════════════════╝
]]


-- ============================================
-- MODULE SYSTEM
-- ============================================

local Modules = {}
local LoadedModules = {}

-- Custom require function
local function require(moduleName)
    -- Normalize module name
    moduleName = moduleName:gsub("^src/", "")
    moduleName = moduleName:gsub("%.lua$", "")

    -- Return cached module if already loaded
    if LoadedModules[moduleName] then
        return LoadedModules[moduleName]
    end

    -- Get module function
    local moduleFunc = Modules[moduleName]
    if not moduleFunc then
        error("Module not found: " .. moduleName)
    end

    -- Execute module and cache result
    local result = moduleFunc()
    LoadedModules[moduleName] = result
    return result
end

-- ============================================
-- MODULES
-- ============================================

-- Module: core/services
Modules["core/services"] = function()
    --[[
        Services Module
    
        Provides access to Roblox game services.
        This is a core module that should be loaded first.
    
        Usage:
            local Services = require("src/core/services")
            print(Services.Players.LocalPlayer.Name)
    ]]
    
    local Services = {}
    
    -- Game services
    Services.Players = game:GetService("Players")
    Services.RunService = game:GetService("RunService")
    Services.HttpService = game:GetService("HttpService")
    Services.ReplicatedStorage = game:GetService("ReplicatedStorage")
    Services.VirtualInputManager = game:GetService("VirtualInputManager")
    Services.GuiService = game:GetService("GuiService")
    Services.CoreGui = game:GetService("CoreGui")
    Services.TeleportService = game:GetService("TeleportService")
    
    -- Shortcuts
    Services.RS = Services.ReplicatedStorage
    Services.VIM = Services.VirtualInputManager
    Services.Camera = workspace.CurrentCamera
    Services.LocalPlayer = Services.Players.LocalPlayer
    Services.PlayerGui = Services.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Game-specific requires (with error handling)
    local function safeRequire(path, name)
        local success, result = pcall(function()
            return require(path)
        end)
        if success then
            return result
        else
            warn(string.format("[Services] Failed to load %s: %s", name, tostring(result)))
            return nil
        end
    end
    
    local function safeGet(parent, path, name)
        local success, result = pcall(function()
            local current = parent
            for part in string.gmatch(path, "[^%.]+") do
                current = current[part]
            end
            return current
        end)
        if success then
            return result
        else
            warn(string.format("[Services] Failed to get %s: %s", name, tostring(result)))
            return nil
        end
    end
    
    -- Try to load game-specific modules
    local netSuccess, netResult = pcall(function()
        return Services.RS.Packages._Index["sleitnick_net@0.2.0"].net
    end)
    Services.Net = netSuccess and netResult or nil
    if not netSuccess then
        warn("[Services] Failed to load Net:", netResult)
    end
    Services.Replion = safeRequire(Services.RS.Packages.Replion, "Replion")
    Services.FishingController = safeRequire(Services.RS.Controllers.FishingController, "FishingController")
    Services.TradingController = safeRequire(Services.RS.Controllers.ItemTradingController, "TradingController")
    Services.ItemUtility = safeRequire(Services.RS.Shared.ItemUtility, "ItemUtility")
    Services.VendorUtility = safeRequire(Services.RS.Shared.VendorUtility, "VendorUtility")
    Services.PlayerStatsUtility = safeRequire(Services.RS.Shared.PlayerStatsUtility, "PlayerStatsUtility")
    Services.Effects = safeRequire(Services.RS.Shared.Effects, "Effects")
    Services.NotifierFish = safeRequire(Services.RS.Controllers.TextNotificationController, "TextNotificationController")
    
    return Services

end

-- Module: core/constants
Modules["core/constants"] = function()
    --[[
        Constants Module
    
        Contains all constant values used throughout the script:
        - Fish tiers/rarities
        - Fish variants
        - Ignored events
        - Rod priority list
    ]]
    
    local Constants = {}
    
    -- Fish rarity tiers
    Constants.TIER_FISH = {
        [1] = " ",
        [2] = "Uncommon",
        [3] = "Rare",
        [4] = "Epic",
        [5] = "Legendary",
        [6] = "Mythic",
        [7] = "Secret"
    }
    
    -- Fish variants
    Constants.VARIANTS = {
        "Galaxy",
        "Corrupt",
        "Gemstone",
        "Ghost",
        "Lightning",
        "Fairy Dust",
        "Gold",
        "Midnight",
        "Radioactive",
        "Stone",
        "Holographic",
        "Albino",
        "Bloodmoon",
        "Sandy",
        "Acidic",
        "Color Burn",
        "Festive",
        "Frozen"
    }
    
    -- Events to ignore in auto-event system
    Constants.IGNORED_EVENTS = {
        Cloudy = true,
        Day = true,
        ["Increased Luck"] = true,
        Mutated = true,
        Night = true,
        Snow = true,
        ["Sparkling Cove"] = true,
        Storm = true,
        Wind = true,
        UIListLayout = true,
        ["Admin - Shocked"] = true,
        ["Admin - Super Mutated"] = true,
        Radiant = true
    }
    
    -- Rod priority for auto-equip (highest priority first)
    Constants.ROD_PRIORITY = {
        "Element Rod",
        "Ghostfin Rod",
        "Bambo Rod",
        "Angler Rod",
        "Ares Rod",
        "Hazmat Rod",
        "Astral Rod",
        "Midnight Rod"
    }
    
    -- Event position offsets (Y-axis)
    Constants.EVENT_OFFSETS = {
        ["Worm Hunt"] = 25
    }
    
    return Constants

end

-- Module: core/state
Modules["core/state"] = function()
    --[[
        State Module
    
        Global state management for the script.
        Contains all runtime state and configuration.
    
        Usage:
            local State = require("src/core/state")
            State.autoInstant = true
    ]]
    
    local Services = require("src/core/services")
    local Constants = require("src/core/constants")
    
    local State = {
        -- Fishing
        autoInstant = false,
        canFish = true,
        Instant = false,
        CancelWaitTime = 3,
        ResetTimer = 0.5,
        hasTriggeredBug = false,
        lastFishTime = 0,
        fishConnected = false,
        lastCancelTime = 0,
        hasFishingEffect = false,
    
        -- Selling
        autoSellEnabled = false,
        sellMode = "Delay",  -- "Delay" or "Count"
        sellDelay = 60,
        inputSellCount = 50,
    
        -- Favorites
        autoFavEnabled = false,
        selectedName = {},
        selectedRarity = {},
        selectedVariant = {},
    
        -- Events
        autoEventActive = false,
        selectedEvents = {},
        autoWeather = false,
        curCF = nil,
        origCF = nil,
        offs = Constants.EVENT_OFFSETS,
        ignore = Constants.IGNORED_EVENTS,
    
        -- Position
        savedCFrame = nil,
        flt = false,
        con = nil,
    
        -- Rods & Baits
        rodDataList = {},
        rodDisplayNames = {},
        baitDataList = {},
        baitDisplayNames = {},
        selectedRodId = nil,
        selectedBaitId = nil,
        rods = {},
        baits = {},
        weathers = {},
    
        -- Player references
        player = Services.LocalPlayer,
        stats = Services.LocalPlayer:WaitForChild("leaderstats"),
        caught = Services.LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Caught"),
        char = Services.LocalPlayer.Character or Services.LocalPlayer.CharacterAdded:Wait(),
        vim = Services.VIM,
        cam = Services.Camera,
    
        -- Trading
        trade = {
            selectedPlayer = nil,
            selectedItem = nil,
            tradeAmount = 1,
            targetCoins = 0,
            trading = false,
            awaiting = false,
            lastResult = nil,
            successCount = 0,
            failCount = 0,
            totalToTrade = 0,
            sentCoins = 0,
            successCoins = 0,
            failCoins = 0,
            totalReceived = 0,
            currentGrouped = {},
            TotemActive = false
        },
    
        -- Notifications
        notifConnections = {},
        defaultHandlers = {},
        disabledCons = {},
        CEvent = true,
    
        -- Webhook
        webhook = {
            url = "",
            enabled = false,
            hideIdentifier = false,
            discordMention = "",
            selectedRarities = {
                Uncommon = false,
                Rare = false,
                Epic = false,
                Legendary = false,
                Mythic = true,
                Secret = true
            }
        },
    
        -- Misc
        lcc = 0,
        lastState = nil
    }
    
    return State

end

-- Module: network/events
Modules["network/events"] = function()
    --[[
        Network Events Module
    
        Remote Events for client-server communication.
        All FireServer() calls use these events.
    
        Usage:
            local Events = require("src/network/events")
            Events.REFishDone:FireServer()
    ]]
    
    local Services = require("src/core/services")
    local Net = Services.Net
    
    local Events = {
        -- Cutscene events
        RECutscene = Net["RE/ReplicateCutscene"],
        REStop = Net["RE/StopCutscene"],
    
        -- Favorite events
        REFav = Net["RE/FavoriteItem"],
        REFavChg = Net["RE/FavoriteStateChanged"],
    
        -- Fishing events
        REFishDone = Net["RE/FishingCompleted"],
        REFishGot = Net["RE/FishCaught"],
        REPlayFishEffect = Net["RE/PlayFishingEffect"],
        FishingMinigameChanged = Net["RE/FishingMinigameChanged"],
        FishingStopped = Net["RE/FishingStopped"],
    
        -- Equipment events
        REEquip = Net["RE/EquipToolFromHotbar"],
        REEquipItem = Net["RE/EquipItem"],
    
        -- Enchanting events
        REAltar = Net["RE/ActivateEnchantingAltar"],
        REAltar2 = Net["RE/ActivateSecondEnchantingAltar"],
    
        -- Notification events
        RENotify = Net["RE/TextNotification"],
        REObtainedNewFishNotification = Net["RE/ObtainedNewFishNotification"],
        RETextEffect = Net["RE/ReplicateTextEffect"],
    
        -- Event rewards
        REEvReward = Net["RE/ClaimEventReward"],
    
        -- Totem
        Totem = Net["RE/SpawnTotem"],
    
        -- Oxygen (unreliable event)
        UpdateOxygen = Net["URE/UpdateOxygen"]
    }
    
    return Events

end

-- Module: network/functions
Modules["network/functions"] = function()
    --[[
        Network Functions Module
    
        Remote Functions for client-server request-response communication.
        All InvokeServer() calls use these functions.
    
        Usage:
            local Functions = require("src/network/functions")
            local success = Functions.ChargeRod:InvokeServer(timestamp)
    ]]
    
    local Services = require("src/core/services")
    local Net = Services.Net
    
    local Functions = {
        -- Trading
        Trade = Net["RF/InitiateTrade"],
    
        -- Shop/Purchase
        BuyRod = Net["RF/PurchaseFishingRod"],
        BuyBait = Net["RF/PurchaseBait"],
        BuyWeather = Net["RF/PurchaseWeatherEvent"],
    
        -- Fishing
        ChargeRod = Net["RF/ChargeFishingRod"],
        StartMini = Net["RF/RequestFishingMinigameStarted"],
        UpdateRadar = Net["RF/UpdateFishingRadar"],
        Cancel = Net["RF/CancelFishingInputs"],
        Done = Net["RF/RequestFishingMinigameStarted"],
    
        -- Dialogue
        Dialogue = Net["RF/SpecialDialogueEvent"]
    }
    
    return Functions

end

-- Module: network/webhook
Modules["network/webhook"] = function()
    --[[
        Webhook Module
    
        Discord webhook integration for notifications.
    
        Usage:
            local Webhook = require("src/network/webhook")
            Webhook.sendFishCaught(url, "Megalodon", "Mythic", "Galaxy")
    ]]
    
    local Services = require("src/core/services")
    
    local Webhook = {}
    
    -- Initialize httpRequest based on executor
    Webhook.httpRequest = syn and syn.request
        or http and http.request
        or http_request
        or fluxus and fluxus.request
        or request
    
    --[[
        Send generic webhook
        @param url string - Discord webhook URL
        @param data table - Webhook payload
        @return boolean - Success status
    ]]
    function Webhook.send(url, data)
        if not Webhook.httpRequest then
            warn("[Webhook] HTTP request not supported by executor")
            return false
        end
    
        local success = pcall(function()
            Webhook.httpRequest({
                Url = url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = Services.HttpService:JSONEncode(data)
            })
        end)
    
        return success
    end
    
    --[[
        Send fish caught notification
        @param webhookUrl string - Discord webhook URL
        @param fishName string - Name of fish
        @param rarity string - Fish rarity
        @param variant string - Fish variant (optional)
    ]]
    function Webhook.sendFishCaught(webhookUrl, fishName, rarity, variant)
        local embed = {
            embeds = {{
                title = "[FISH] Fish Caught!",
                description = string.format("**%s**\nRarity: %s\nVariant: %s",
                    fishName, rarity, variant or "None"),
                color = 0x00ff00,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
            }}
        }
    
        return Webhook.send(webhookUrl, embed)
    end
    
    --[[
        Send disconnect notification
        @param webhookUrl string - Discord webhook URL
        @param reason string - Disconnect reason
        @param customName string - Custom player name (optional)
    ]]
    function Webhook.sendDisconnect(webhookUrl, reason, customName)
        local embed = {
            content = _G.DiscordMention or "",
            embeds = {{
                title = "[WARNING] Disconnected",
                description = string.format("**%s** disconnected\nReason: %s",
                    customName or "Player", reason),
                color = 0xff0000,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
            }}
        }
    
        return Webhook.send(webhookUrl, embed)
    end
    
    --[[
        Send trade notification
        @param webhookUrl string - Discord webhook URL
        @param itemName string - Item traded
        @param targetPlayer string - Player traded with
        @param success boolean - Trade success status
    ]]
    function Webhook.sendTrade(webhookUrl, itemName, targetPlayer, success)
        local color = success and 0x00ff00 or 0xff0000
        local title = success and "[SUCCESS] Trade Success" or "[FAILED] Trade Failed"
    
        local embed = {
            embeds = {{
                title = title,
                description = string.format("Item: **%s**\nPlayer: **%s**",
                    itemName, targetPlayer),
                color = color,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
            }}
        }
    
        return Webhook.send(webhookUrl, embed)
    end
    
    return Webhook

end

-- Module: utils/player-utils
Modules["utils/player-utils"] = function()
    --[[
        Player Utilities Module
    
        Helper functions for player operations.
    
        Usage:
            local PlayerUtils = require("src/utils/player-utils")
            PlayerUtils.teleport(character, Vector3.new(0, 10, 0))
    ]]
    
    local Services = require("src/core/services")
    
    local PlayerUtils = {}
    
    --[[
        Get HumanoidRootPart from character
        @param character Model - Character model
        @return BasePart - HumanoidRootPart or first BasePart
    ]]
    function PlayerUtils.getHumanoidRootPart(character)
        return character and (
            character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChildWhichIsA("BasePart")
        )
    end
    
    --[[
        Teleport character to position
        @param character Model - Character to teleport
        @param position Vector3 - Target position
    ]]
    function PlayerUtils.teleport(character, position)
        local hrp = PlayerUtils.getHumanoidRootPart(character)
        if hrp then
            hrp.CFrame = CFrame.new(position)
        end
    end
    
    --[[
        Set all parts in character to anchored
        @param character Model - Character model
        @param anchored boolean - Anchored state
    ]]
    function PlayerUtils.setAnchored(character, anchored)
        if not character then return end
    
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = anchored
            end
        end
    end
    
    --[[
        Get list of player names (excluding self)
        @param excludeSelf boolean - Whether to exclude local player
        @return table - Array of player names
    ]]
    function PlayerUtils.getPlayers(excludeSelf)
        local players = {}
    
        for _, player in ipairs(Services.Players:GetPlayers()) do
            if not excludeSelf or player ~= Services.LocalPlayer then
                table.insert(players, player.Name)
            end
        end
    
        return players
    end
    
    --[[
        Create floating platform under character (for anti-fall)
        @param character Model - Character model
        @param hrp BasePart - HumanoidRootPart
        @param enabled boolean - Enable/disable floating
        @return Part - The floating part (if enabled)
        @return RBXScriptConnection - Heartbeat connection (if enabled)
    ]]
    function PlayerUtils.createFloatPart(character, hrp, enabled)
        if not enabled then
            local floatPart = character:FindFirstChild("FloatPart")
            if floatPart then
                floatPart:Destroy()
            end
            return nil, nil
        end
    
        local floatPart = character:FindFirstChild("FloatPart") or Instance.new("Part")
        floatPart.Name = "FloatPart"
        floatPart.Size = Vector3.new(3, 0.2, 3)
        floatPart.Transparency = 1
        floatPart.Anchored = true
        floatPart.CanCollide = true
        floatPart.Parent = character
    
        local connection = Services.RunService.Heartbeat:Connect(function()
            if character and hrp and floatPart then
                floatPart.CFrame = hrp.CFrame * CFrame.new(0, -3.1, 0)
            end
        end)
    
        return floatPart, connection
    end
    
    return PlayerUtils

end

-- Module: features/fishing/instant-fish
Modules["features/fishing/instant-fish"] = function()
    --[[
        Instant Fishing Module
    
        Automatically catches fish without minigame interaction.
        Uses the fishing sequence: Charge → Start → Wait → Complete
    
        Usage:
            local InstantFish = require("src/features/fishing/instant-fish")
            InstantFish.start()
    ]]
    
    local State = require("src/core/state")
    local Services = require("src/core/services")
    local Events = require("src/network/events")
    local Functions = require("src/network/functions")
    
    local InstantFish = {}
    
    -- Private variables
    local isRunning = false
    
    --[[
        Get current fish count from inventory UI
        @return number - Current fish count
    ]]
    function InstantFish.getFishCount()
        local bagSizeLabel = State.player.PlayerGui
            :WaitForChild("Inventory")
            :WaitForChild("Main")
            :WaitForChild("Top")
            :WaitForChild("Options")
            :WaitForChild("Fish")
            :WaitForChild("Label")
            :WaitForChild("BagSize")
    
        return tonumber((bagSizeLabel.Text or "0/???"):match("(%d+)/")) or 0
    end
    
    --[[
        Execute one fishing cycle
        @return boolean - Success status
    ]]
    local function executeFishingCycle()
        if not State.canFish then
            return false
        end
    
        State.canFish = false
    
        -- Step 1: Charge rod
        local success, _, timestamp = pcall(function()
            return Functions.ChargeRod:InvokeServer(workspace:GetServerTimeNow())
        end)
    
        if success and typeof(timestamp) == "number" then
            local direction = -1
            local power = 0.999
    
            task.wait(0.3)
    
            -- Step 2: Start minigame
            pcall(function()
                Functions.StartMini:InvokeServer(direction, power, timestamp)
            end)
    
            -- Step 3: Wait for fish data
            local startTime = tick()
            repeat
                task.wait(0.05)
            until (_G.FishMiniData and _G.FishMiniData.LastShift) or (tick() - startTime > 1)
    
            -- Apply custom delay if set
            task.wait(_G.DelayComplete or 0)
    
            -- Step 4: Complete fishing
            pcall(function()
                Events.REFishDone:FireServer()
            end)
    
            -- Step 5: Wait for fish to be added to inventory
            local oldCount = InstantFish.getFishCount()
            local waitStart = tick()
            repeat
                task.wait(0.05)
            until oldCount < InstantFish.getFishCount() or (tick() - waitStart > 1)
        end
    
        State.canFish = true
        return true
    end
    
    --[[
        Start instant fishing loop
    ]]
    function InstantFish.start()
        if isRunning then
            return
        end
    
        isRunning = true
        State.autoInstant = true
    
        -- Update counter
        _G.Celestial.InstantCount = InstantFish.getFishCount()
    
        task.spawn(function()
            while State.autoInstant and isRunning do
                local success = executeFishingCycle()
    
                if not success then
                    task.wait(0.1)
                end
    
                task.wait(0.05)
            end
        end)
    end
    
    --[[
        Stop instant fishing
    ]]
    function InstantFish.stop()
        State.autoInstant = false
        isRunning = false
    end
    
    --[[
        Check if instant fishing is running
        @return boolean
    ]]
    function InstantFish.isRunning()
        return isRunning
    end
    
    return InstantFish

end

-- Module: features/selling/auto-sell
Modules["features/selling/auto-sell"] = function()
    --[[
        Auto Sell Module
    
        Automatically sells fish based on mode:
        - Delay: Sell every X seconds
        - Count: Sell when fish count reaches X
    
        Usage:
            local AutoSell = require("src/features/selling/auto-sell")
            AutoSell.start()
    ]]
    
    local State = require("src/core/state")
    local Services = require("src/core/services")
    
    local AutoSell = {}
    
    -- Private variables
    local isRunning = false
    local SellAllItemsFunction = nil
    
    --[[
        Initialize sell function
    ]]
    local function initialize()
        if not SellAllItemsFunction then
            SellAllItemsFunction = Services.Net["RF/SellAllItems"]
        end
    end
    
    --[[
        Get current fish count from UI
        @return number - Current count
        @return number - Max capacity
    ]]
    function AutoSell.getFishCount()
        local bagSizeLabel = State.player.PlayerGui
            :WaitForChild("Inventory")
            .Main.Top.Options.Fish.Label
            :FindFirstChild("BagSize")
    
        local current = 0
        local max = 0
    
        if bagSizeLabel and bagSizeLabel:IsA("TextLabel") then
            local currentStr, maxStr = (bagSizeLabel.Text or ""):match("(%d+)%s*/%s*(%d+)")
            current = tonumber(currentStr) or 0
            max = tonumber(maxStr) or 0
        end
    
        return current, max
    end
    
    --[[
        Execute sell all items
        @return boolean - Success status
    ]]
    local function sellAllItems()
        initialize()
    
        if not SellAllItemsFunction then
            warn("[AutoSell] Sell function not available")
            return false
        end
    
        local success = pcall(function()
            SellAllItemsFunction:InvokeServer()
        end)
    
        return success
    end
    
    --[[
        Auto sell loop based on mode
    ]]
    local function autoSellLoop()
        while State.autoSellEnabled and isRunning do
            local current, max = AutoSell.getFishCount()
    
            if State.sellMode == "Delay" then
                -- Sell by delay mode
                sellAllItems()
                task.wait(State.sellDelay)
    
            elseif State.sellMode == "Count" then
                -- Sell by count mode
                local threshold = tonumber(State.inputSellCount) or max
    
                if threshold <= current then
                    sellAllItems()
                    task.wait(0.5)
                else
                    task.wait(1)
                end
            end
        end
    end
    
    --[[
        Start auto sell
    ]]
    function AutoSell.start()
        if isRunning then
            return
        end
    
        isRunning = true
        State.autoSellEnabled = true
    
        task.spawn(autoSellLoop)
    end
    
    --[[
        Stop auto sell
    ]]
    function AutoSell.stop()
        State.autoSellEnabled = false
        isRunning = false
    end
    
    --[[
        Set sell mode
        @param mode string - "Delay" or "Count"
    ]]
    function AutoSell.setMode(mode)
        if mode == "Delay" or mode == "Count" then
            State.sellMode = mode
        else
            warn("[AutoSell] Invalid mode: " .. tostring(mode))
        end
    end
    
    --[[
        Set sell delay (for Delay mode)
        @param seconds number - Delay in seconds
    ]]
    function AutoSell.setDelay(seconds)
        State.sellDelay = math.max(1, tonumber(seconds) or 60)
    end
    
    --[[
        Set sell count threshold (for Count mode)
        @param count number - Fish count threshold
    ]]
    function AutoSell.setCount(count)
        State.inputSellCount = math.max(1, tonumber(count) or 50)
    end
    
    --[[
        Check if auto sell is running
        @return boolean
    ]]
    function AutoSell.isRunning()
        return isRunning
    end
    
    return AutoSell

end

-- Module: features/favorites/auto-favorite
Modules["features/favorites/auto-favorite"] = function()
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

end

-- Module: config/locations
Modules["config/locations"] = function()
    --[[
        Locations Configuration
    
        Predefined teleport locations in the game.
    
        Usage:
            local Locations = require("src/config/locations")
            local pos = Locations["Treasure Room"]
    ]]
    
    local Locations = {
        -- Deep Sea
        ["Treasure Room"] = Vector3.new(-3602.01, -266.57, -1577.18),
        ["Sisyphus Statue"] = Vector3.new(-3703.69, -135.57, -1017.17),
    
        -- Crater Island
        ["Crater Island Top"] = Vector3.new(1011.29, 22.68, 5076.27),
        ["Crater Island Ground"] = Vector3.new(1079.57, 3.64, 5080.35),
    
        -- Coral Reefs
        ["Coral Reefs SPOT 1"] = Vector3.new(-3031.88, 2.52, 2276.36),
        ["Coral Reefs SPOT 2"] = Vector3.new(-3270.86, 2.5, 2228.1),
        ["Coral Reefs SPOT 3"] = Vector3.new(-3136.1, 2.61, 2126.11),
    
        -- Main Areas
        ["Lost Shore"] = Vector3.new(-3737.97, 5.43, -854.68),
        ["Weather Machine"] = Vector3.new(-1524.88, 2.87, 1915.56),
        ["Stingray Shores"] = Vector3.new(44.41, 28.83, 3048.93),
        ["Ice Sea"] = Vector3.new(2164, 7, 3269),
    
        -- Kohana
        ["Kohana Volcano"] = Vector3.new(-561.81, 21.24, 156.72),
        ["Kohana SPOT 1"] = Vector3.new(-367.77, 6.75, 521.91),
        ["Kohana SPOT 2"] = Vector3.new(-623.96, 19.25, 419.36),
    
        -- Tropical Grove
        ["Tropical Grove"] = Vector3.new(-2018.91, 9.04, 3750.59),
        ["Tropical Grove Cave 1"] = Vector3.new(-2151, 3, 3671),
        ["Tropical Grove Cave 2"] = Vector3.new(-2018, 5, 3756),
        ["Tropical Grove Highground"] = Vector3.new(-2139, 53, 3624),
    
        -- Fisherman Island
        ["Fisherman Island Underground"] = Vector3.new(-62, 3, 2846),
        ["Fisherman Island Mid"] = Vector3.new(33, 3, 2764),
        ["Fisherman Island Rift Left"] = Vector3.new(-26, 10, 2686),
        ["Fisherman Island Rift Right"] = Vector3.new(95, 10, 2684),
    
        -- Ancient Areas
        ["Secret Temple"] = Vector3.new(1475, -22, -632),
        ["Ancient Jungle Outside"] = Vector3.new(1488, 8, -392),
        ["Ancient Jungle"] = Vector3.new(1274, 8, -184),
        ["Underground Cellar"] = Vector3.new(2136, -91, -699),
        ["Crystalline Passage"] = Vector3.new(6051, -539, 4386),
        ["Ancient Ruin"] = Vector3.new(6090, -586, 4634)
    }
    
    return Locations

end

-- Module: features/teleport/teleport
Modules["features/teleport/teleport"] = function()
    --[[
        Teleport Module
    
        Handles character teleportation and position save/load.
    
        Usage:
            local Teleport = require("src/features/teleport/teleport")
            Teleport.toLocation("Treasure Room")
            Teleport.savePosition()
    ]]
    
    local State = require("src/core/state")
    local Services = require("src/core/services")
    local Locations = require("src/config/locations")
    local PlayerUtils = require("src/utils/player-utils")
    
    local Teleport = {}
    
    -- Position save file (completely separate from old script)
    local SAVE_FILE = "ZiviHub/SavedPosition_ZIVIHUB.json"
    
    --[[
        Get location names (sorted alphabetically)
        @return table - Array of location names
    ]]
    function Teleport.getLocationNames()
        local names = {}
    
        for name in pairs(Locations) do
            table.insert(names, name)
        end
    
        table.sort(names, function(a, b)
            return a:lower() < b:lower()
        end)
    
        return names
    end
    
    --[[
        Get location position
        @param locationName string - Name of location
        @return Vector3 - Position or nil if not found
    ]]
    function Teleport.getLocation(locationName)
        return Locations[locationName]
    end
    
    --[[
        Teleport to location by name
        @param locationName string - Name of location
        @return boolean - Success status
    ]]
    function Teleport.toLocation(locationName)
        local position = Locations[locationName]
    
        if not position then
            warn("[Teleport] Location not found: " .. tostring(locationName))
            return false
        end
    
        local character = State.player.Character
        if not character then
            warn("[Teleport] Character not found")
            return false
        end
    
        PlayerUtils.teleport(character, position)
        return true
    end
    
    --[[
        Teleport to position
        @param position Vector3 - Target position
        @return boolean - Success status
    ]]
    function Teleport.toPosition(position)
        local character = State.player.Character
        if not character then
            warn("[Teleport] Character not found")
            return false
        end
    
        PlayerUtils.teleport(character, position)
        return true
    end
    
    --[[
        Teleport to CFrame
        @param cframe CFrame - Target CFrame
        @return boolean - Success status
    ]]
    function Teleport.toCFrame(cframe)
        local character = State.player.Character
        if not character then
            warn("[Teleport] Character not found")
            return false
        end
    
        local hrp = PlayerUtils.getHumanoidRootPart(character)
        if hrp then
            hrp.CFrame = cframe
            return true
        end
    
        return false
    end
    
    --[[
        Save current position to file
        @return boolean - Success status
    ]]
    function Teleport.savePosition()
        local character = State.player.Character
        if not character then
            warn("[Teleport] Character not found")
            return false
        end
    
        local hrp = PlayerUtils.getHumanoidRootPart(character)
        if not hrp then
            warn("[Teleport] HumanoidRootPart not found")
            return false
        end
    
        -- Save CFrame components
        local components = { hrp.CFrame:GetComponents() }
    
        local success = pcall(function()
            writefile(SAVE_FILE, Services.HttpService:JSONEncode(components))
        end)
    
        if success then
            State.savedCFrame = hrp.CFrame
        end
    
        return success
    end
    
    --[[
        Load saved position from file
        @return CFrame - Saved CFrame or nil
    ]]
    function Teleport.loadPosition()
        if not isfile(SAVE_FILE) then
            return nil
        end
    
        local success, result = pcall(function()
            local data = Services.HttpService:JSONDecode(readfile(SAVE_FILE))
            return CFrame.new(unpack(data))
        end)
    
        if success and typeof(result) == "CFrame" then
            return result
        end
    
        return nil
    end
    
    --[[
        Teleport to saved position
        @return boolean - Success status
    ]]
    function Teleport.toSavedPosition()
        local savedCFrame = Teleport.loadPosition()
    
        if not savedCFrame then
            warn("[Teleport] No saved position found")
            return false
        end
    
        return Teleport.toCFrame(savedCFrame)
    end
    
    --[[
        Clear saved position
    ]]
    function Teleport.clearSavedPosition()
        if isfile(SAVE_FILE) then
            pcall(delfile, SAVE_FILE)
        end
    
        State.savedCFrame = nil
    end
    
    --[[
        Auto teleport to last position on character added
    ]]
    function Teleport.setupAutoTeleport()
        State.player.CharacterAdded:Connect(function(character)
            task.spawn(function()
                character:WaitForChild("HumanoidRootPart", 5)
                local savedCFrame = Teleport.loadPosition()
    
                if savedCFrame then
                    task.wait(2) -- Wait for character to fully load
                    Teleport.toCFrame(savedCFrame)
                    print("[Teleport] Auto teleported to saved position")
                end
            end)
        end)
    
        -- Also teleport on initial load
        if State.player.Character then
            task.spawn(function()
                local savedCFrame = Teleport.loadPosition()
                if savedCFrame then
                    task.wait(2)
                    Teleport.toCFrame(savedCFrame)
                    print("[Teleport] Teleported to saved position")
                end
            end)
        end
    end
    
    return Teleport

end

-- Module: ui/library
Modules["ui/library"] = function()
    --[[
        UI Library Module
    
        Loads and configures the UI library with Discord dark theme.
    
        Usage:
            local Library = require("src/ui/library")
            local window = Library.createWindow()
    ]]
    
    local Library = {}
    
    --[[
        Load external UI library
        @return table - UI library object
    ]]
    function Library.load()
        local success, library = pcall(function()
            return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
        end)
    
        if not success then
            warn("[UI Library] Failed to load external library")
            return nil
        end
    
        return library
    end
    
    --[[
        Create main window with AdviHub branding
        @return table - Window object
    ]]
    function Library.createWindow()
        local lib = Library.load()
    
        if not lib then
            error("[UI Library] Cannot create window - library not loaded")
        end
    
        lib:AddTheme({
            Name = "Royal Void",
            Accent = lib:Gradient({
                ["0"]   = { Color = Color3.fromHex("#FF3366"), Transparency = 0 }, -- Merah Cerah
                ["50"]  = { Color = Color3.fromHex("#1E90FF"), Transparency = 0 }, -- biru Cerah
                ["100"] = { Color = Color3.fromHex("#9B30FF"), Transparency = 0 }, -- Ungu Terang
            }, {
                Rotation = 45,
            }),
    
            Dialog = Color3.fromHex("#0A0011"),      -- Latar hitam ke ungu gelap
            Outline = Color3.fromHex("#1E90FF"),     -- Pinggir biru Cerah
            Text = Color3.fromHex("#FFE6FF"),        -- Putih ke ungu muda
            Placeholder = Color3.fromHex("#B34A7F"), -- Ungu-merah pudar
            Background = Color3.fromHex("#050008"),  -- Hitam pekat dengan nuansa ungu
            Button = Color3.fromHex("#FF00AA"),      -- Merah ke ungu neon
            Icon = Color3.fromHex("#0066CC")         -- Aksen biru
        })
        lib.TransparencyValue = 0.2
    
        -- Create window with Discord dark theme
        local window = lib:CreateWindow({
            Title = "AdviHub",
            Icon = "crown",
            Author = "Fishit | Advi",
            Folder = "AdviHub",
            Size = UDim2.fromOffset(400, 200),
            Transparent = true,
            Theme = "Royal Void",
            Resizable = true,
            ScrollBarEnabled = true,
            HideSearchBar = true,
            NewElements = true,
            User = {
                Enabled = true,
                Anonymous = false,
                Callback = function() end,
            }
        })
    
        window:EditOpenButton({
            Title = "AdviHub",
            Icon = "crown",
            CornerRadius = UDim.new(0, 30),
            StrokeThickness = 2,
            Color = ColorSequence.new( -- gradient
                Color3.fromHex("#FF3366"), -- Merah
                Color3.fromHex("#1E90FF"), -- biru
                Color3.fromHex("#9B30FF") -- Ungu
            ),
            OnlyMobile = false,
            Enabled = true,
            Draggable = true,
        })
    
        if window then
            print("[UI Library] Window created successfully")
        end
    
        return window
    end
    
    return Library

end

-- Module: ui/tabs/fishing-tab
Modules["ui/tabs/fishing-tab"] = function()
    local FishingTab = {}
    
    function FishingTab.setup(tab)
        tab:Button({
            Text = "Start Fishing",
            Icon = "fish",
            Callback = function()
                print("Start Fishing")
            end
        })
    end
    
    
    return FishingTab
end

-- Module: ui/main-window
Modules["ui/main-window"] = function()
    --[[
        Main Window Module
    
        Creates and manages the main UI window with all tabs.
    
        Usage:
            local MainWindow = require("src/ui/main-window")
            MainWindow.create()
    ]]
    
    local Library = require("src/ui/library")
    local FishingTab = require("src/ui/tabs/fishing-tab")
    
    local MainWindow = {}
    
    -- Window instance
    local Window = nil
    
    --[[
        Create main window with all tabs
        @return table - Window object
    ]]
    function MainWindow.create()
        if Window then
            warn("[MainWindow] Window already exists")
            return Window
        end
    
        -- Create window
        Window = Library.createWindow()
    
        if not Window then
            error("[MainWindow] Failed to create window")
        end
    
        local fishingTab = Window:Tab({
            Title = "Fishing",
            Icon = "fish"
        })
    
        FishingTab.setup(fishingTab)
    
        return Window
    end
    
    return MainWindow

end

-- Module: main
Modules["main"] = function()
    --[[
        Main Entry Point
    
        This is the entry point for the script.
        When bundled, this file will be executed last.
    
        Version: 2.0.0 (Refactored)
    ]]
    
    -- ============================================
    -- EXECUTOR COMPATIBILITY CHECK
    -- ============================================
    
    local httpRequest = syn and syn.request
        or http and http.request
        or http_request
        or fluxus and fluxus.request
        or request
    
    if not httpRequest then
        warn("[ERROR] Executor not supported - HTTP requests required")
        return
    end
    
    _G.httpRequest = httpRequest
    
    -- ============================================
    -- LOAD CORE MODULES
    -- ============================================
    
    print("🔄 Loading core modules...")
    
    local success, Services = pcall(function() return require("src/core/services") end)
    if not success then
        warn("❌ Failed to load Services:", Services)
        return
    end
    print("   ✓ Services loaded")
    
    local success2, Constants = pcall(function() return require("src/core/constants") end)
    if not success2 then
        warn("❌ Failed to load Constants:", Constants)
        return
    end
    print("   ✓ Constants loaded")
    
    local success3, State = pcall(function() return require("src/core/state") end)
    if not success3 then
        warn("❌ Failed to load State:", State)
        return
    end
    print("   ✓ State loaded")
    
    -- ============================================
    -- LOAD NETWORK MODULES
    -- ============================================
    
    local Events = require("src/network/events")
    local Functions = require("src/network/functions")
    local Webhook = require("src/network/webhook")
    
    -- ============================================
    -- LOAD UTILITY MODULES
    -- ============================================
    
    local PlayerUtils = require("src/utils/player-utils")
    
    -- ============================================
    -- LOAD FEATURE MODULES
    -- ============================================
    
    local InstantFish = require("src/features/fishing/instant-fish")
    local AutoSell = require("src/features/selling/auto-sell")
    local AutoFavorite = require("src/features/favorites/auto-favorite")
    local Teleport = require("src/features/teleport/teleport")
    
    -- ============================================
    -- LOAD CONFIG MODULES
    -- ============================================
    
    local Locations = require("src/config/locations")
    
    -- ============================================
    -- WAIT FOR CHARACTER
    -- ============================================
    
    local LocalPlayer = Services.LocalPlayer
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
    end
    
    -- ============================================
    -- INITIALIZE GLOBALS
    -- ============================================
    
    _G.Celestial = _G.Celestial or {}
    _G.Celestial.DetectorCount = _G.Celestial.DetectorCount or 0
    _G.Celestial.InstantCount = _G.Celestial.InstantCount or 0
    _G.TierFish = Constants.TIER_FISH
    _G.Variant = Constants.VARIANTS
    
    -- ============================================
    -- STARTUP MESSAGE
    -- ============================================
    
    print("╔═══════════════════════════════════════════════════╗")
    print("║                   Zivi Hub                       ║")
    print("║              Version 1.0.0 BETA                  ║")
    print("╚═══════════════════════════════════════════════════╝")
    print("")
    print("[OK] Core modules loaded:")
    print("   - Services ✓")
    print("   - Constants ✓")
    print("   - State ✓")
    print("")
    print("[OK] Network modules loaded:")
    print("   - Events ✓")
    print("   - Functions ✓")
    print("   - Webhook ✓")
    print("")
    print("[OK] Utility modules loaded:")
    print("   - PlayerUtils ✓")
    print("")
    print("[OK] Feature modules loaded:")
    print("   - InstantFish ✓")
    print("   - AutoSell ✓")
    print("   - AutoFavorite ✓")
    print("   - Teleport ✓")
    print("")
    print("[OK] Config modules loaded:")
    print("   - Locations ✓")
    print("")
    print("👤 Player:", LocalPlayer.Name)
    print("[INFO] Executor: Compatible")
    print("")
    
    -- ============================================
    -- LOAD UI MODULES
    -- ============================================
    
    print("🔄 Loading UI modules...")
    
    local uiSuccess, MainWindow = pcall(function() return require("src/ui/main-window") end)
    if not uiSuccess then
        warn("❌ Failed to load UI modules:", MainWindow)
        warn("[WARNING] UI will not be available")
        MainWindow = nil
    else
        print("   ✓ MainWindow loaded")
    end
    
    -- ============================================
    -- INITIALIZE AUTO TELEPORT
    -- ============================================
    
    Teleport.setupAutoTeleport()
    
    -- ============================================
    -- CREATE UI
    -- ============================================
    
    print("")
    
    if MainWindow then
        print("🎨 Creating UI...")
    
        local success, err = pcall(function()
            MainWindow.create()
        end)
    
        if success then
            print("[OK] UI created successfully!")
            print("🎨 Theme: Discord Dark Mode")
        else
            warn("❌ UI creation failed:", err)
            print("[WARNING] Features still available via console")
        end
    else
        warn("[WARNING] UI modules not loaded - UI unavailable")
        print("[WARNING] Features still available via console")
    end
    
    print("")
    print("╔═══════════════════════════════════════════════════╗")
    print("║           🎯 Zivi Hub v1.0.0 BETA Loaded!       ║")
    print("╚═══════════════════════════════════════════════════╝")

end


-- ============================================
-- ENTRY POINT
-- ============================================

-- Execute main module
require("main")
