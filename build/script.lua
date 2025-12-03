--[[
    ╔═══════════════════════════════════════════════════╗
    ║          Roblox FishIt Script - Bundled          ║
    ║                                                   ║
    ║  Build Date: 2025-11-26 11:26:06                        ║
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
    
    -- Zivi Hub Logo Asset ID
    -- Using Chloe's original logo asset
    Library.LogoAssetId = "132435516080103"  -- Chloe logo asset ID
    
    -- Discord Dark Theme Colors
    Library.Theme = {
        -- Primary colors (Discord dark mode)
        Background = Color3.fromRGB(54, 57, 63),      -- Dark gray (#36393f)
        Secondary = Color3.fromRGB(47, 49, 54),       -- Darker gray (#2f3136)
        Tertiary = Color3.fromRGB(32, 34, 37),        -- Darkest gray (#202225)
    
        -- Accent colors
        Primary = Color3.fromRGB(88, 101, 242),       -- Blurple (#5865f2)
        Success = Color3.fromRGB(67, 181, 129),       -- Green (#43b581)
        Warning = Color3.fromRGB(250, 166, 26),       -- Yellow (#faa61a)
        Danger = Color3.fromRGB(237, 66, 69),         -- Red (#ed4245)
    
        -- Text colors
        TextPrimary = Color3.fromRGB(255, 255, 255),  -- White
        TextSecondary = Color3.fromRGB(185, 187, 190), -- Gray
        TextMuted = Color3.fromRGB(114, 118, 125),    -- Muted gray
    
        -- Interactive colors
        Interactive = Color3.fromRGB(185, 187, 190),
        InteractiveHover = Color3.fromRGB(220, 221, 222),
        InteractiveActive = Color3.fromRGB(255, 255, 255)
    }
    
    --[[
        Load external UI library
        @return table - UI library object
    ]]
    function Library.load()
        local success, library = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/TesterX14/XXXX/refs/heads/main/Library"))()
        end)
    
        if not success then
            warn("[UI Library] Failed to load external library")
            return nil
        end
    
        return library
    end
    
    --[[
        Create main window with Zivi Hub branding
        @return table - Window object
    ]]
    function Library.createWindow()
        local lib = Library.load()
    
        if not lib then
            error("[UI Library] Cannot create window - library not loaded")
        end
    
        -- Create window with Discord dark theme
        local window = lib:Window({
            Title = "Zivi Hub",
            Footer = "Version 2.5.0 BETA",
            Image = Library.LogoAssetId,  -- Chloe logo
            Color = Library.Theme.Primary,  -- Discord blurple
            Theme = 9542022979,
            Version = 3
        })
    
        if window then
            print("[UI Library] Window created successfully")
        end
    
        return window
    end
    
    --[[
        Create notification
        @param title string - Notification title
        @param message string - Notification message
        @param duration number - Duration in seconds
    ]]
    function Library.notify(title, message, duration)
        -- Implementation depends on the UI library
        -- This is a placeholder
        print(string.format("[%s] %s", title, message))
    end
    
    return Library

end

-- Module: features/fishing/legit-fish
Modules["features/fishing/legit-fish"] = function()
    --[[
        Legit Fishing Module
    
        Implements legit fishing with game mechanics compliance.
        Two modes: Always Perfect and Normal.
    
        Dependencies:
        - src/core/services
        - src/core/state
        - src/network/events
    ]]
    
    local Services = require("src/core/services")
    local State = require("src/core/state")
    local Events = require("src/network/events")
    
    local LegitFish = {}
    
    -- Initialize state
    State.legitFishing = false
    State.shakeDelay = 0
    State.autoShake = false
    State.legitMode = "Always Perfect" -- "Always Perfect" or "Normal"
    
    -- Get player user ID
    local userId = tostring(Services.LocalPlayer.UserId)
    
    -- Get cosmetic folder for bobber detection
    local cosmeticFolder = nil
    pcall(function()
        cosmeticFolder = workspace:FindFirstChild("CosmeticFolder")
    end)
    
    -- Try cast function (charges rod and releases)
    local function tryCast()
        local PlayerGui = Services.PlayerGui
        local Camera = Services.Camera
        local VIM = Services.VIM
        local LocalPlayer = Services.LocalPlayer
        local FishingController = Services.FishingController
    
        if not FishingController then
            warn("[Legit Fish] FishingController not found")
            return
        end
    
        -- Center of screen
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local lastGUID = nil
    
        while FishingController._autoLoop do
            -- If already fishing, wait
            if FishingController:GetCurrentGUID() then
                task.wait(0.05)
            else
                -- Click to start charging
                VIM:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
                task.wait(0.05)
    
                -- Wait for charge bar to appear and reach ~95%
                local chargeSuccess, chargeBar = pcall(function()
                    return PlayerGui:WaitForChild("Charge", 1)
                        :WaitForChild("Main")
                        :WaitForChild("CanvasGroup")
                        :WaitForChild("Bar")
                end)
    
                if chargeSuccess and chargeBar then
                    local startTime = tick()
                    while chargeBar:IsDescendantOf(PlayerGui) and chargeBar.Size.Y.Scale < 0.95 do
                        task.wait(0.001)
                        if tick() - startTime > 1 then
                            break
                        end
                    end
                end
    
                -- Release click to cast
                VIM:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
    
                -- Wait for shake detection (GUID appears)
                local waitStart = tick()
                local shakeDetected = false
                while tick() - waitStart < 3 do
                    local currentGUID = FishingController:GetCurrentGUID()
                    if currentGUID and currentGUID ~= lastGUID then
                        shakeDetected = true
                        print("[Legit Fish] Shake detected! GUID:", currentGUID)
                        lastGUID = currentGUID
                        break
                    else
                        task.wait(0.05)
                    end
                end
    
                -- If shake detected, wait for catch completion
                if shakeDetected then
                    local oldCaught = LocalPlayer.leaderstats and LocalPlayer.leaderstats.Caught.Value or 0
                    local catchStart = tick()
    
                    -- Wait for caught count to increase or timeout
                    while tick() - catchStart < 8
                        and (not LocalPlayer.leaderstats or oldCaught >= LocalPlayer.leaderstats.Caught.Value)
                        and FishingController:GetCurrentGUID() do
                        task.wait(0.1)
                    end
    
                    -- Wait for GUID to clear
                    while FishingController:GetCurrentGUID() do
                        task.wait(0.05)
                    end
    
                    task.wait(1.3) -- Cooldown before next cast
                end
            end
    
            task.wait(0.05)
        end
    end
    
    -- Always Perfect Mode
    local function startAlwaysPerfectMode()
        local FishingController = Services.FishingController
        if not FishingController or not cosmeticFolder then
            warn("[Legit Fish] Missing FishingController or CosmeticFolder")
            return
        end
    
        task.spawn(function()
            local completed = false
    
            while State.legitFishing and FishingController._autoLoop do
                -- Wait for bobber to appear
                if not cosmeticFolder:FindFirstChild(userId) then
                    repeat
                        tryCast()
                        task.wait(0.1)
                    until cosmeticFolder:FindFirstChild(userId) or not FishingController._autoLoop
                end
    
                -- While bobber exists (fishing in progress)
                while cosmeticFolder:FindFirstChild(userId) and FishingController._autoLoop do
                    -- If minigame active (GUID exists)
                    if FishingController:GetCurrentGUID() then
                        local startTime = tick()
    
                        -- Spam click minigame
                        while FishingController:GetCurrentGUID() and FishingController._autoLoop do
                            pcall(function()
                                FishingController:RequestFishingMinigameClick()
                            end)
    
                            -- Check if delay reached
                            if tick() - startTime >= (_G.Delay or 0) then
                                task.wait(_G.Delay or 0)
    
                                -- Complete fishing
                                repeat
                                    pcall(function()
                                        Events.REFishDone:FireServer()
                                    end)
                                    task.wait(0.05)
                                    completed = not FishingController:GetCurrentGUID() or not FishingController._autoLoop
                                until completed
                            else
                                task.wait()
                            end
    
                            if completed then
                                break
                            end
                        end
                    end
    
                    completed = false
                    task.wait(0.2)
                end
    
                -- Wait for bobber to disappear
                repeat
                    task.wait(0.1)
                until not cosmeticFolder:FindFirstChild(userId) or not FishingController._autoLoop
    
                -- Recast
                if FishingController._autoLoop then
                    task.wait(0.2)
                    tryCast()
                end
    
                task.wait(0.2)
            end
        end)
    end
    
    -- Normal Mode
    local function startNormalMode()
        local FishingController = Services.FishingController
        if not FishingController then
            warn("[Legit Fish] FishingController not found")
            return
        end
    
        -- Override power to always return max
        if not FishingController._oldGetPower then
            FishingController._oldGetPower = FishingController._getPower
        end
        FishingController._getPower = function()
            return 0.999
        end
    
        task.spawn(function()
            while State.legitFishing and FishingController._autoLoop do
                -- If shake enabled and minigame active
                if _G.ShakeEnabled and FishingController:GetCurrentGUID() then
                    local startTime = tick()
    
                    while FishingController:GetCurrentGUID()
                        and FishingController._autoLoop
                        and _G.ShakeEnabled do
    
                        -- Spam click
                        pcall(function()
                            FishingController:RequestFishingMinigameClick()
                        end)
    
                        -- Check delay
                        if tick() - startTime >= (_G.Delay or 1) then
                            pcall(function()
                                Events.REFishDone:FireServer()
                            end)
                            task.wait(0.1)
    
                            if not FishingController:GetCurrentGUID()
                                or not FishingController._autoLoop
                                or not _G.ShakeEnabled then
                                break
                            end
                        end
    
                        task.wait(0.1)
                    end
    
                -- If not fishing, auto cast
                elseif not FishingController:GetCurrentGUID() then
                    local center = Vector2.new(
                        Services.Camera.ViewportSize.X / 2,
                        Services.Camera.ViewportSize.Y / 2
                    )
    
                    pcall(function()
                        FishingController:RequestChargeFishingRod(center, true)
                    end)
    
                    task.wait(0.25)
                end
    
                task.wait(0.05)
            end
        end)
    end
    
    -- Start legit fishing
    function LegitFish.start()
        if State.legitFishing then
            return
        end
    
        local FishingController = Services.FishingController
        if not FishingController then
            warn("[Legit Fish] FishingController not available")
            return false
        end
    
        State.legitFishing = true
        FishingController._autoLoop = true
    
        -- Start appropriate mode
        if State.legitMode == "Always Perfect" then
            print("[Legit Fish] Starting Always Perfect mode")
            startAlwaysPerfectMode()
        elseif State.legitMode == "Normal" then
            print("[Legit Fish] Starting Normal mode")
            startNormalMode()
        end
    
        return true
    end
    
    -- Stop legit fishing
    function LegitFish.stop()
        State.legitFishing = false
    
        local FishingController = Services.FishingController
        if FishingController then
            FishingController._autoLoop = false
    
            -- Restore original power function
            if FishingController._oldGetPower then
                FishingController._getPower = FishingController._oldGetPower
                FishingController._oldGetPower = nil
            end
        end
    
        print("[Legit Fish] Legit fishing stopped")
    end
    
    -- Set legit mode
    function LegitFish.setMode(mode)
        if mode == "Always Perfect" or mode == "Normal" then
            State.legitMode = mode
            print("[Legit Fish] Mode set to:", mode)
            return true
        end
        return false
    end
    
    -- Start auto shake (independent feature)
    function LegitFish.startAutoShake()
        if State.autoShake then
            return
        end
    
        State.autoShake = true
    
        -- Disable click effect GUI
        local clickEffect = Services.PlayerGui:FindFirstChild("!!! Click Effect")
        if clickEffect then
            clickEffect.Enabled = false
        end
    
        task.spawn(function()
            while State.autoShake do
                pcall(function()
                    if Services.FishingController then
                        Services.FishingController:RequestFishingMinigameClick()
                    end
                end)
                task.wait(State.shakeDelay)
            end
    
            -- Re-enable click effect when stopped
            if clickEffect then
                clickEffect.Enabled = true
            end
        end)
    
        print("[Legit Fish] Auto shake started (delay:", State.shakeDelay, ")")
    end
    
    -- Stop auto shake
    function LegitFish.stopAutoShake()
        State.autoShake = false
    
        -- Re-enable click effect
        local clickEffect = Services.PlayerGui:FindFirstChild("!!! Click Effect")
        if clickEffect then
            clickEffect.Enabled = true
        end
    
        print("[Legit Fish] Auto shake stopped")
    end
    
    -- Set shake delay
    function LegitFish.setShakeDelay(delay)
        local delayNum = tonumber(delay)
        if delayNum and delayNum >= 0 then
            State.shakeDelay = delayNum
            print("[Legit Fish] Shake delay set to:", delayNum)
            return true
        end
        return false
    end
    
    return LegitFish

end

-- Module: features/fishing/blatant-fish
Modules["features/fishing/blatant-fish"] = function()
    -- src/features/fishing/blatant-fish.lua
    -- Blatant fishing (aggressive, obvious method)
    
    local Services = require("src/core/services")
    local State = require("src/core/state")
    local Functions = require("src/network/functions")
    local Events = require("src/network/events")
    
    local BlatantFish = {}
    
    -- Blatant fishing state
    State.blatantFishing = false
    State.blatantMode = "Fast" -- "Fast" or "Random Result"
    State.reelDelay = 0.5 -- Delay between catches
    
    -- Fast mode: Fastest possible fishing
    local function fishFast()
        task.spawn(function()
            -- Cancel any ongoing fishing
            pcall(function()
                Functions.Cancel:InvokeServer()
            end)
    
            -- Get server time and charge rod
            local serverTime = workspace:GetServerTimeNow()
            pcall(function()
                Functions.ChargeRod:InvokeServer(serverTime)
            end)
    
            -- Start minigame with max power
            pcall(function()
                Functions.StartMini:InvokeServer(-1, 0.999)
            end)
    
            -- Wait fishing delay
            task.wait(_G.FishingDelay or 0.1)
    
            -- Complete fishing
            pcall(function()
                Events.REFishDone:FireServer()
            end)
        end)
    end
    
    -- Random Result mode: Fishing with slight delay variation
    local function fishRandomResult()
        task.spawn(function()
            -- Cancel any ongoing fishing
            pcall(function()
                Functions.Cancel:InvokeServer()
            end)
    
            -- Get server time and charge rod
            local serverTime = workspace:GetServerTimeNow()
            pcall(function()
                Functions.ChargeRod:InvokeServer(serverTime)
            end)
    
            -- Wait a bit before starting (makes it less obvious)
            task.wait(0.2)
    
            -- Start minigame with max power
            pcall(function()
                Functions.StartMini:InvokeServer(-1, 0.999)
            end)
    
            -- Wait fishing delay
            task.wait(_G.FishingDelay or 0.1)
    
            -- Complete fishing
            pcall(function()
                Events.REFishDone:FireServer()
            end)
        end)
    end
    
    -- Start blatant fishing
    function BlatantFish.start()
        if State.blatantFishing then
            return
        end
    
        State.blatantFishing = true
    
        task.spawn(function()
            while State.blatantFishing do
                if State.blatantMode == "Fast" then
                    fishFast()
                elseif State.blatantMode == "Random Result" then
                    fishRandomResult()
                end
    
                task.wait(State.reelDelay)
            end
        end)
    
        print("[Blatant Fish] Blatant fishing started (mode:", State.blatantMode, ")")
    end
    
    -- Stop blatant fishing
    function BlatantFish.stop()
        State.blatantFishing = false
        print("[Blatant Fish] Blatant fishing stopped")
    end
    
    -- Set blatant mode
    function BlatantFish.setMode(mode)
        if mode == "Fast" or mode == "Random Result" then
            State.blatantMode = mode
            print("[Blatant Fish] Mode set to:", mode)
            return true
        end
        return false
    end
    
    -- Set reel delay
    function BlatantFish.setReelDelay(delay)
        local delayNum = tonumber(delay)
        if delayNum and delayNum >= 0 then
            State.reelDelay = delayNum
            print("[Blatant Fish] Reel delay set to:", delayNum)
            return true
        end
        return false
    end
    
    -- Recovery fishing (cancel stuck fishing)
    function BlatantFish.recovery()
        pcall(function()
            Functions.Cancel:InvokeServer()
        end)
        print("[Blatant Fish] Recovery executed")
    end
    
    return BlatantFish

end

-- Module: ui/tabs/fish-tab
Modules["ui/tabs/fish-tab"] = function()
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

end

-- Module: data/models
Modules["data/models"] = function()
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

end

-- Module: features/trading/trade-filters
Modules["features/trading/trade-filters"] = function()
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

end

-- Module: features/trading/auto-trade
Modules["features/trading/auto-trade"] = function()
    -- src/features/trading/auto-trade.lua
    -- Automated trading system for FishIt
    
    local Services = require("src/core/services")
    local State = require("src/core/state")
    local Functions = require("src/network/functions")
    local TradeFilters = require("src/features/trading/trade-filters")
    
    local AutoTrade = {}
    
    -- Send single trade with retry mechanism
    local function sendTrade(playerName, uuid, itemName, price)
        local trade = State.trade
        local retries = 0
        local maxRetries = 3
    
        while retries < maxRetries and trade.trading do
            local player = Services.Players:FindFirstChild(playerName)
    
            if not player then
                trade.trading = false
                warn("[AutoTrade] Player not found:", playerName)
                return false
            end
    
            -- Send trade request
            local success = pcall(function()
                Functions.Trade:InvokeServer(player.UserId, uuid)
            end)
    
            if not success then
                retries = retries + 1
                task.wait(1)
            else
                -- Wait for item to disappear from inventory (trade accepted)
                local startTime = tick()
                local traded = false
    
                while trade.trading and not traded do
                    if not TradeFilters.itemExists(uuid) then
                        traded = true
    
                        -- Update counters
                        if itemName then
                            trade.successCount = trade.successCount + 1
                        else
                            trade.successCoins = trade.successCoins + (price or 0)
                            trade.totalReceived = trade.successCoins
                        end
    
                        return true
                    elseif tick() - startTime > 10 then
                        -- Timeout after 10 seconds
                        break
                    end
    
                    task.wait(0.2)
                end
    
                retries = retries + 1
                task.wait(1)
            end
        end
    
        return false
    end
    
    -- Trade by item name
    function AutoTrade.startTradeByName(updateCallback)
        local trade = State.trade
    
        if trade.trading then
            return
        end
    
        if not trade.selectedPlayer or not trade.selectedItem then
            warn("[AutoTrade] Select player & item first!")
            if updateCallback then
                updateCallback("<font color='#ff3333'>Select player & item first!</font>")
            end
            return
        end
    
        trade.trading = true
        trade.successCount = 0
    
        if updateCallback then
            updateCallback(string.format("Starting trade with %s", trade.selectedPlayer))
        end
    
        -- Get grouped items
        local itemData = trade.currentGrouped[trade.selectedItem]
    
        if not itemData then
            trade.trading = false
            if updateCallback then
                updateCallback("<font color='#ff3333'>Item not found</font>")
            end
            return
        end
    
        trade.totalToTrade = math.min(trade.tradeAmount, #itemData.uuids)
    
        -- Send trades
        local index = 1
        while trade.trading and trade.successCount < trade.totalToTrade do
            local uuid = itemData.uuids[index]
    
            if sendTrade(trade.selectedPlayer, uuid, trade.selectedItem) then
                if updateCallback then
                    updateCallback(string.format(
                        "Progress: %d / %d",
                        trade.successCount,
                        trade.totalToTrade
                    ))
                end
            end
    
            index = index + 1
            if index > #itemData.uuids then
                index = 1
            end
    
            task.wait(2)
        end
    
        trade.trading = false
    
        if updateCallback then
            updateCallback("<font color='#66ccff'>All trades finished</font>")
        end
    end
    
    -- Trade by coin value
    function AutoTrade.startTradeByCoin(updateCallback)
        local trade = State.trade
    
        if trade.trading then
            return
        end
    
        if not trade.selectedPlayer or trade.targetCoins <= 0 then
            warn("[AutoTrade] Select player & coin target first!")
            if updateCallback then
                updateCallback("<font color='#ff3333'>Select player & coin target first!</font>")
            end
            return
        end
    
        trade.trading = true
        trade.sentCoins = 0
        trade.successCoins = 0
        trade.totalReceived = 0
    
        if updateCallback then
            updateCallback("<font color='#ffaa00'>Scanning inventory...</font>")
        end
    
        -- Get all fish with prices
        local fishes = TradeFilters.getFishForCoins()
    
        if #fishes == 0 then
            trade.trading = false
            if updateCallback then
                updateCallback("<font color='#ff3333'>No fish available for trading</font>")
            end
            return
        end
    
        -- Choose fishes by target coin range
        local selectedFish, totalValue = TradeFilters.chooseFishesByRange(fishes, trade.targetCoins)
    
        if #selectedFish == 0 then
            trade.trading = false
            if updateCallback then
                updateCallback("<font color='#ff3333'>No valid fishes for target</font>")
            end
            return
        end
    
        trade.totalToTrade = #selectedFish
        trade.targetCoins = totalValue
    
        if updateCallback then
            updateCallback(string.format(
                "Trading %d fish (Total: %d coins)",
                trade.totalToTrade,
                trade.targetCoins
            ))
        end
    
        -- Send trades
        for _, fish in ipairs(selectedFish) do
            if not trade.trading then
                break
            end
    
            trade.sentCoins = trade.sentCoins + fish.Price
    
            if updateCallback then
                updateCallback(string.format(
                    "<font color='#ffaa00'>Progress: %d / %d</font>",
                    trade.sentCoins,
                    trade.targetCoins
                ))
            end
    
            sendTrade(trade.selectedPlayer, fish.UUID, nil, fish.Price)
    
            task.wait(2)
        end
    
        trade.trading = false
    
        if updateCallback then
            updateCallback(string.format(
                "<font color='#66ccff'>Coin trade finished (Target: %d, Received: %d)</font>",
                trade.targetCoins,
                trade.successCoins
            ))
        end
    end
    
    -- Trade by rarity
    function AutoTrade.startTradeByRarity(updateCallback)
        local trade = State.trade
    
        if trade.trading then
            return
        end
    
        if not trade.selectedPlayer or not trade.selectedRarity then
            warn("[AutoTrade] Select player & rarity first!")
            if updateCallback then
                updateCallback("<font color='#ff3333'>Select player & rarity first!</font>")
            end
            return
        end
    
        trade.trading = true
        trade.successCount = 0
    
        if updateCallback then
            updateCallback(string.format(
                "<font color='#ffaa00'>Scanning %s fishes...</font>",
                trade.selectedRarity
            ))
        end
    
        -- Get fish by rarity
        local fishes = TradeFilters.getFishByRarity(trade.selectedRarity)
    
        if #fishes == 0 then
            trade.trading = false
            if updateCallback then
                updateCallback(string.format(
                    "<font color='#ff3333'>No %s fishes found</font>",
                    trade.selectedRarity
                ))
            end
            return
        end
    
        trade.totalToTrade = math.min(#fishes, trade.rarityAmount or #fishes)
    
        if updateCallback then
            updateCallback(string.format(
                "Sending %d %s fishes...",
                trade.totalToTrade,
                trade.selectedRarity
            ))
        end
    
        -- Send trades
        local index = 1
        while trade.trading and index <= trade.totalToTrade do
            local fish = fishes[index]
    
            if sendTrade(trade.selectedPlayer, fish.UUID, fish.Name) then
                if updateCallback then
                    updateCallback(string.format(
                        "Progress: %d / %d (%s)",
                        trade.successCount,
                        trade.totalToTrade,
                        trade.selectedRarity
                    ))
                end
            end
    
            index = index + 1
            task.wait(2.5)
        end
    
        trade.trading = false
    
        if updateCallback then
            updateCallback("<font color='#66ccff'>Rarity trade finished</font>")
        end
    end
    
    -- Stop all trading
    function AutoTrade.stop()
        State.trade.trading = false
    end
    
    -- Get list of other players
    function AutoTrade.getPlayerList()
        local players = {}
    
        for _, player in ipairs(Services.Players:GetPlayers()) do
            if player ~= Services.Players.LocalPlayer then
                table.insert(players, player.Name)
            end
        end
    
        return players
    end
    
    return AutoTrade

end

-- Module: ui/tabs/trade-tab
Modules["ui/tabs/trade-tab"] = function()
    -- src/ui/tabs/trade-tab.lua
    -- Trading UI tab with Discord dark theme
    
    local Services = require("src/core/services")
    local State = require("src/core/state")
    local AutoTrade = require("src/features/trading/auto-trade")
    local TradeFilters = require("src/features/trading/trade-filters")
    
    local TradeTab = {}
    
    -- Global reference for monitor paragraphs
    local NameMonitor, CoinMonitor, RarityMonitor
    
    function TradeTab.setup(tab)
        -- ========================================
        -- TRADE BY NAME SECTION
        -- ========================================
        local tradeByName = tab:AddSection("Trade by Name")
    
        NameMonitor = tradeByName:AddParagraph({
            Title = "Trade by Name Panel",
            Content =
            "\n<font color='rgb(173,216,230)'>Player : ???</font>\n<font color='rgb(173,216,230)'>Item   : ???</font>\n<font color='rgb(173,216,230)'>Amount : 0</font>\n<font color='rgb(200,200,200)'>Status : Idle</font>\n<font color='rgb(173,216,230)'>Success: 0 / 0</font>\n"
        })
    
        local function updateNameMonitor(status)
            local trade = State.trade
            local color = "200,200,200"
    
            if status and status:lower():find("send") then
                color = "51,153,255"
            elseif status and status:lower():find("complete") or status:lower():find("finish") then
                color = "0,204,102"
            elseif status and status:lower():find("time") or status:lower():find("error") then
                color = "255,69,0"
            end
    
            local content = string.format(
                "\n<font color='rgb(173,216,230)'>Player : %s</font>\n<font color='rgb(173,216,230)'>Item   : %s</font>\n<font color='rgb(173,216,230)'>Amount : %d</font>\n<font color='rgb(%s)'>Status : %s</font>\n<font color='rgb(173,216,230)'>Success: %d / %d</font>\n",
                trade.selectedPlayer or "???",
                trade.selectedItem or "???",
                trade.tradeAmount or 0,
                color,
                status or "Idle",
                trade.successCount or 0,
                trade.totalToTrade or 0
            )
    
            _G.safeSetContent(NameMonitor, content)
        end
    
        local itemDropdown = tradeByName:AddDropdown({
            Options = {},
            Multi = false,
            Title = "Select Item",
            Callback = function(value)
                State.trade.selectedItem = value and (value:match("^(.-) x") or value)
                updateNameMonitor("Item selected")
            end
        })
    
        tradeByName:AddButton({
            Title = "Refresh Fish",
            Callback = function()
                local grouped, options = TradeFilters.getGroupedByType("Fish")
                State.trade.currentGrouped = grouped
                itemDropdown:SetValues(options or {})
                updateNameMonitor("Fish list refreshed")
            end,
            SubTitle = "Refresh Stone",
            SubCallback = function()
                local grouped, options = TradeFilters.getGroupedByType("Enchant Stones")
                State.trade.currentGrouped = grouped
                itemDropdown:SetValues(options or {})
                updateNameMonitor("Stone list refreshed")
            end
        })
    
        tradeByName:AddInput({
            Title = "Amount to Trade",
            Default = "1",
            Callback = function(value)
                State.trade.tradeAmount = tonumber(value) or 1
                updateNameMonitor("Amount set")
            end
        })
    
        local namePlayerDropdown = tradeByName:AddDropdown({
            Options = {},
            Multi = false,
            Title = "Select Player",
            Callback = function(value)
                State.trade.selectedPlayer = value
                updateNameMonitor("Player selected")
            end
        })
    
        tradeByName:AddButton({
            Title = "Refresh Players",
            Callback = function()
                local players = AutoTrade.getPlayerList()
                namePlayerDropdown:SetValues(players)
                updateNameMonitor("Player list refreshed")
            end
        })
    
        tradeByName:AddToggle({
            Title = "Start Trade by Name",
            Default = false,
            Callback = function(enabled)
                if enabled then
                    task.spawn(function()
                        AutoTrade.startTradeByName(updateNameMonitor)
                    end)
                else
                    AutoTrade.stop()
                    updateNameMonitor("Stopped")
                end
            end
        })
    
        -- ========================================
        -- TRADE BY COIN SECTION
        -- ========================================
        local tradeByCoin = tab:AddSection("Trade by Coin")
    
        CoinMonitor = tradeByCoin:AddParagraph({
            Title = "Trade by Coin Panel",
            Content =
            "\n<font color='rgb(173,216,230)'>Player : ???</font>\n<font color='rgb(173,216,230)'>Target : 0</font>\n<font color='rgb(173,216,230)'>Sent   : 0</font>\n<font color='rgb(200,200,200)'>Status : Idle</font>\n<font color='rgb(173,216,230)'>Success: 0</font>\n"
        })
    
        local function updateCoinMonitor(status)
            local trade = State.trade
            local color = "200,200,200"
    
            if status and status:lower():find("send") then
                color = "51,153,255"
            elseif status and status:lower():find("complete") or status:lower():find("finish") then
                color = "0,204,102"
            elseif status and status:lower():find("time") or status:lower():find("error") then
                color = "255,69,0"
            end
    
            local content = string.format(
                "\n<font color='rgb(173,216,230)'>Player : %s</font>\n<font color='rgb(173,216,230)'>Target : %d</font>\n<font color='rgb(173,216,230)'>Sent   : %d</font>\n<font color='rgb(%s)'>Status : %s</font>\n<font color='rgb(173,216,230)'>Success: %d</font>\n",
                trade.selectedPlayer or "???",
                trade.targetCoins or 0,
                trade.sentCoins or 0,
                color,
                status or "Idle",
                trade.successCoins or 0
            )
    
            _G.safeSetContent(CoinMonitor, content)
        end
    
        local coinPlayerDropdown = tradeByCoin:AddDropdown({
            Options = {},
            Multi = false,
            Title = "Select Player",
            Callback = function(value)
                State.trade.selectedPlayer = value
                updateCoinMonitor("Player selected")
            end
        })
    
        tradeByCoin:AddButton({
            Title = "Refresh Players",
            Callback = function()
                local players = AutoTrade.getPlayerList()
                coinPlayerDropdown:SetValues(players)
                updateCoinMonitor("Player list refreshed")
            end
        })
    
        tradeByCoin:AddInput({
            Title = "Target Coin",
            Default = "0",
            Callback = function(value)
                State.trade.targetCoins = tonumber(value) or 0
                updateCoinMonitor("Target coin set")
            end
        })
    
        tradeByCoin:AddToggle({
            Title = "Start Trade by Coin",
            Default = false,
            Callback = function(enabled)
                if enabled then
                    task.spawn(function()
                        AutoTrade.startTradeByCoin(updateCoinMonitor)
                    end)
                else
                    AutoTrade.stop()
                    updateCoinMonitor("Stopped")
                end
            end
        })
    
        -- ========================================
        -- TRADE BY RARITY SECTION
        -- ========================================
        local tradeByRarity = tab:AddSection("Trade by Rarity")
    
        RarityMonitor = tradeByRarity:AddParagraph({
            Title = "Trade by Rarity Panel",
            Content =
            "\n<font color='rgb(173,216,230)'>Player  : ???</font>\n<font color='rgb(173,216,230)'>Rarity  : ???</font>\n<font color='rgb(173,216,230)'>Count   : 0</font>\n<font color='rgb(200,200,200)'>Status  : Idle</font>\n<font color='rgb(173,216,230)'>Success : 0 / 0</font>\n"
        })
    
        local function updateRarityMonitor(status)
            local trade = State.trade
            local color = "200,200,200"
    
            if status and status:lower():find("send") then
                color = "51,153,255"
            elseif status and status:lower():find("complete") or status:lower():find("finish") then
                color = "0,204,102"
            elseif status and status:lower():find("time") or status:lower():find("error") then
                color = "255,69,0"
            end
    
            local content = string.format(
                "\n<font color='rgb(173,216,230)'>Player  : %s</font>\n<font color='rgb(173,216,230)'>Rarity  : %s</font>\n<font color='rgb(173,216,230)'>Count   : %d</font>\n<font color='rgb(%s)'>Status  : %s</font>\n<font color='rgb(173,216,230)'>Success : %d / %d</font>\n",
                trade.selectedPlayer or "???",
                trade.selectedRarity or "???",
                trade.totalToTrade or 0,
                color,
                status or "Idle",
                trade.successCount or 0,
                trade.totalToTrade or 0
            )
    
            _G.safeSetContent(RarityMonitor, content)
        end
    
        tradeByRarity:AddDropdown({
            Options = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret" },
            Multi = false,
            Title = "Select Rarity",
            Callback = function(value)
                State.trade.selectedRarity = value
                updateRarityMonitor("Selected rarity: " .. (value or "???"))
            end
        })
    
        local rarityPlayerDropdown = tradeByRarity:AddDropdown({
            Options = {},
            Multi = false,
            Title = "Select Player",
            Callback = function(value)
                State.trade.selectedPlayer = value
                updateRarityMonitor("Player selected")
            end
        })
    
        tradeByRarity:AddButton({
            Title = "Refresh Players",
            Callback = function()
                local players = AutoTrade.getPlayerList()
                rarityPlayerDropdown:SetValues(players)
                updateRarityMonitor("Player list refreshed")
            end
        })
    
        tradeByRarity:AddInput({
            Title = "Amount to Trade",
            Default = "1",
            Callback = function(value)
                State.trade.rarityAmount = tonumber(value) or 1
                updateRarityMonitor("Set amount: " .. tostring(State.trade.rarityAmount))
            end
        })
    
        tradeByRarity:AddToggle({
            Title = "Start Trade by Rarity",
            Default = false,
            Callback = function(enabled)
                if enabled then
                    task.spawn(function()
                        AutoTrade.startTradeByRarity(updateRarityMonitor)
                    end)
                else
                    AutoTrade.stop()
                    updateRarityMonitor("Stopped")
                end
            end
        })
    
        -- ========================================
        -- AUTO ACCEPT SECTION
        -- ========================================
        local autoAccept = tab:AddSection("Auto Accept")
    
        autoAccept:AddToggle({
            Title = "Auto Accept Trade",
            Default = _G.AutoAccept or false,
            Callback = function(enabled)
                _G.AutoAccept = enabled
            end
        })
    
        -- Auto accept trade requests loop
        task.spawn(function()
            while true do
                task.wait(1)
    
                if _G.AutoAccept then
                    pcall(function()
                        local prompt = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("Prompt")
    
                        if prompt and prompt:FindFirstChild("Blackout") then
                            local blackout = prompt.Blackout
    
                            if blackout:FindFirstChild("Options") then
                                local yesButton = blackout.Options:FindFirstChild("Yes")
    
                                if yesButton then
                                    local pos = yesButton.AbsolutePosition
                                    local size = yesButton.AbsoluteSize
                                    local x = pos.X + size.X / 2
                                    local y = pos.Y + size.Y / 2 + 50
    
                                    Services.VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
                                    task.wait(0.03)
                                    Services.VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
                                end
                            end
                        end
                    end)
                end
            end
        end)
    end
    
    return TradeTab

end

-- Module: ui/tabs/teleport-tab
Modules["ui/tabs/teleport-tab"] = function()
    -- src/ui/tabs/teleport-tab.lua
    -- Teleport & Position management tab
    
    local Teleport = require("src/features/teleport/teleport")
    local State = require("src/core/state")
    
    local TeleportTab = {}
    
    -- Selected location storage
    local selectedLocation = nil
    
    function TeleportTab.setup(tab)
        -- TELEPORT TO LOCATION SECTION
        local locationSection = tab:AddSection("Teleport to Location")
    
        -- Get location names
        local locationNames = Teleport.getLocationNames()
    
        -- Location Dropdown (just select, don't teleport yet)
        locationSection:AddDropdown({
            Title = "Select Location",
            Options = locationNames,
            Multi = false,
            Callback = function(location)
                selectedLocation = location
                print("[Teleport Tab] Location selected:", location)
            end
        })
    
        -- Teleport Button (actual teleport happens here)
        locationSection:AddButton({
            Title = "Teleport to Location",
            Content = "Click to teleport to selected location",
            Callback = function()
                if selectedLocation and selectedLocation ~= "" then
                    local success = Teleport.toLocation(selectedLocation)
                    if success then
                        print("[Teleport Tab] Teleported to:", selectedLocation)
                    else
                        warn("[Teleport Tab] Teleport failed:", selectedLocation)
                    end
                else
                    warn("[Teleport Tab] Please select a location first")
                end
            end
        })
    
        -- SAVE/LOAD POSITION SECTION
        local savedPosSection = tab:AddSection("Save & Load Position")
    
        -- Save Position Button
        savedPosSection:AddButton({
            Title = "Save Current Position",
            Content = "Save your current position for later use",
            Callback = function()
                local success = Teleport.savePosition()
                if success then
                    print("[Teleport Tab] Position saved successfully")
                else
                    warn("[Teleport Tab] Failed to save position")
                end
            end
        })
    
        -- Load Position Button
        savedPosSection:AddButton({
            Title = "Teleport to Saved Position",
            Content = "Teleport to your saved position",
            Callback = function()
                local success = Teleport.toSavedPosition()
                if success then
                    print("[Teleport Tab] Teleported to saved position")
                else
                    warn("[Teleport Tab] No saved position found")
                end
            end
        })
    
        -- Clear Saved Position Button
        savedPosSection:AddButton({
            Title = "Clear Saved Position",
            Content = "Delete your saved position",
            Callback = function()
                Teleport.clearSavedPosition()
                print("[Teleport Tab] Saved position cleared")
            end
        })
    
        -- INFO SECTION
        local infoSection = tab:AddSection("Information")
    
        infoSection:AddParagraph({
            Title = "How to Use",
            Content = [[
    1. Select a location from dropdown
    2. Click "Teleport to Location" to teleport
    
    OR
    
    1. Go to desired position in game
    2. Click "Save Current Position"
    3. Use "Teleport to Saved Position" anytime
    
    Your position is saved to:
    ZiviHub/SavedPosition_ZIVIHUB.json
            ]]
        })
    
        print("[Teleport Tab] Initialized")
    end
    
    return TeleportTab

end

-- Module: ui/tabs/webhook-tab
Modules["ui/tabs/webhook-tab"] = function()
    -- src/ui/tabs/webhook-tab.lua
    -- Discord Webhook integration tab
    
    local Services = require("src/core/services")
    local State = require("src/core/state")
    local Webhook = require("src/network/webhook")
    local Events = require("src/network/events")
    local Data = require("src/data/models")
    
    local WebhookTab = {}
    
    -- Hook fish caught event for webhook
    local function setupFishCaughtHook()
        if State.webhook.fishCaughtConnection then
            return -- Already connected
        end
    
        State.webhook.fishCaughtConnection = Events.REFishGot.OnClientEvent:Connect(function(fishData)
            if not State.webhook.enabled or not State.webhook.url or State.webhook.url == "" then
                return
            end
    
            -- Get fish details
            local fishId = fishData.Id
            local itemData = Data.ItemUtility and Data.ItemUtility.GetItemDataFromItemType("Items", fishId)
    
            if not itemData or not itemData.Data then
                return
            end
    
            local fishName = itemData.Data.Name
            local rarity = _G.TierFish[itemData.Data.Tier] or "Common"
            local variant = fishData.Variant or "None"
    
            -- Check if rarity is selected for notification
            if not State.webhook.selectedRarities[rarity] then
                return -- Skip this rarity
            end
    
            -- Prepare player name
            local playerName = State.webhook.hideIdentifier and "Hidden" or Services.LocalPlayer.Name
    
            -- Send webhook
            local embed = {
                content = State.webhook.discordMention or "",
                embeds = { {
                    title = "Fish Caught",
                    description = string.format("**%s**\nRarity: **%s**\nVariant: %s\nPlayer: %s",
                        fishName, rarity, variant, playerName),
                    color = rarity == "Secret" and 0xff00ff
                        or rarity == "Mythic" and 0xffd700
                        or rarity == "Legendary" and 0xff8c00
                        or rarity == "Epic" and 0x9400d3
                        or rarity == "Rare" and 0x0000ff
                        or 0x00ff00,
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%S"),
                    footer = {
                        text = "Zivi Hub Webhook"
                    }
                } }
            }
    
            task.spawn(function()
                Webhook.send(State.webhook.url, embed)
            end)
        end)
    
        print("[Webhook] Fish caught hook enabled")
    end
    
    function WebhookTab.setup(tab)
        -- CONFIGURATION SECTION
        local configSection = tab:AddSection("Webhook Configuration")
    
        -- Webhook URL Input
        configSection:AddInput({
            Title = "Discord Webhook URL",
            Content = "Enter your Discord webhook URL",
            Placeholder = "https://discord.com/api/webhooks/...",
            Callback = function(url)
                State.webhook.url = url
                _G.WebhookURL = url -- For backwards compatibility
                print("[Webhook] Webhook URL saved")
            end
        })
    
        -- Discord Mention Input
        configSection:AddInput({
            Title = "Discord Mention (Optional)",
            Content = "Mention user/role when fish caught",
            Placeholder = "<@USER_ID> or <@&ROLE_ID>",
            Callback = function(mention)
                State.webhook.discordMention = mention
                _G.DiscordMention = mention -- For backwards compatibility
                print("[Webhook] Discord mention saved:", mention)
            end
        })
    
        -- Hide Identifier Toggle
        configSection:AddToggle({
            Title = "Hide Roblox Username",
            Content = "Hide your Roblox username in webhooks",
            Default = false,
            Callback = function(enabled)
                State.webhook.hideIdentifier = enabled
                print("[Webhook] Hide identifier:", enabled)
            end
        })
    
        -- FISH CAUGHT NOTIFICATIONS SECTION
        local fishSection = tab:AddSection("Fish Caught Notifications")
    
        -- Enable Fish Webhook Toggle
        fishSection:AddToggle({
            Title = "Enable Fish Caught Webhook",
            Content = "Send webhook when catching fish",
            Default = false,
            Callback = function(enabled)
                State.webhook.enabled = enabled
                if enabled then
                    setupFishCaughtHook()
                    print("[Webhook] Fish caught webhook enabled")
                else
                    print("[Webhook] Fish caught webhook disabled")
                end
            end
        })
    
        -- Rarity Filter Section
        local raritySection = tab:AddSection("Rarity Filter")
    
        raritySection:AddParagraph({
            Title = "Select Rarities to Notify",
            Content = "Only selected rarities will trigger webhook notifications"
        })
    
        -- Uncommon Toggle
        raritySection:AddToggle({
            Title = "Uncommon",
            Content = "Send webhook for Uncommon fish",
            Default = false,
            Callback = function(enabled)
                State.webhook.selectedRarities.Uncommon = enabled
                print("[Webhook] Uncommon notifications:", enabled)
            end
        })
    
        -- Rare Toggle
        raritySection:AddToggle({
            Title = "Rare",
            Content = "Send webhook for Rare fish",
            Default = false,
            Callback = function(enabled)
                State.webhook.selectedRarities.Rare = enabled
                print("[Webhook] Rare notifications:", enabled)
            end
        })
    
        -- Epic Toggle
        raritySection:AddToggle({
            Title = "Epic",
            Content = "Send webhook for Epic fish",
            Default = false,
            Callback = function(enabled)
                State.webhook.selectedRarities.Epic = enabled
                print("[Webhook] Epic notifications:", enabled)
            end
        })
    
        -- Legendary Toggle
        raritySection:AddToggle({
            Title = "Legendary",
            Content = "Send webhook for Legendary fish",
            Default = false,
            Callback = function(enabled)
                State.webhook.selectedRarities.Legendary = enabled
                print("[Webhook] Legendary notifications:", enabled)
            end
        })
    
        -- Mythic Toggle (Default OFF)
        raritySection:AddToggle({
            Title = "Mythic",
            Content = "Send webhook for Mythic fish",
            Default = false,
            Callback = function(enabled)
                State.webhook.selectedRarities.Mythic = enabled
                print("[Webhook] Mythic notifications:", enabled)
            end
        })
    
        -- Secret Toggle (Default ON)
        raritySection:AddToggle({
            Title = "Secret",
            Content = "Send webhook for Secret fish",
            Default = true,
            Callback = function(enabled)
                State.webhook.selectedRarities.Secret = enabled
                print("[Webhook] Secret notifications:", enabled)
            end
        })
    
        -- TESTING SECTION
        local testSection = tab:AddSection("Testing")
    
        -- Test Webhook Button
        testSection:AddButton({
            Title = "Send Test Webhook",
            Content = "Send a test message to verify webhook",
            Callback = function()
                if not State.webhook.url or State.webhook.url == "" then
                    warn("[Webhook] Please enter webhook URL first")
                    return
                end
    
                local playerName = State.webhook.hideIdentifier and "Hidden" or Services.LocalPlayer.Name
    
                local success = Webhook.send(State.webhook.url, {
                    content = State.webhook.discordMention or "",
                    embeds = { {
                        title = "Test Webhook",
                        description = string.format("Webhook is working correctly!\n\nPlayer: %s\nHide Identifier: %s",
                            playerName,
                            State.webhook.hideIdentifier and "Enabled" or "Disabled"
                        ),
                        color = 0x00ff00,
                        timestamp = os.date("!%Y-%m-%dT%H:%M:%S"),
                        footer = {
                            text = "Zivi Hub Webhook Test"
                        }
                    } }
                })
    
                if success then
                    print("[Webhook] Test webhook sent successfully")
                else
                    warn("[Webhook] Failed to send test webhook")
                end
            end
        })
    
        -- INFORMATION SECTION
        local infoSection = tab:AddSection("Information")
    
        infoSection:AddParagraph({
            Title = "How to Setup",
            Content = [[
    1. Create webhook in Discord:
       - Go to Server Settings > Integrations
       - Create Webhook
       - Copy webhook URL
    
    2. Paste URL in the input above
    
    3. (Optional) Add Discord mention:
       - For user: <@USER_ID>
       - For role: <@&ROLE_ID>
    
    4. Select rarities to notify
    
    5. Enable "Fish Caught Webhook"
    
    6. Test with "Send Test Webhook" button
    
    Privacy:
    - Enable "Hide Roblox Username" to hide your identity
    - Webhook will show "Hidden" instead of your username
            ]]
        })
    
        print("[Webhook Tab] Initialized")
    end
    
    return WebhookTab

end

-- Module: ui/tabs/misc-tab
Modules["ui/tabs/misc-tab"] = function()
    --[[
        Misc Tab Module
    
        UI for miscellaneous features (settings, credits).
    
        Usage:
            local MiscTab = require("src/ui/tabs/misc-tab")
            MiscTab.setup(tab)
    ]]
    
    local State = require("src/core/state")
    
    local MiscTab = {}
    
    --[[
        Setup misc tab UI
        @param tab table - Tab object from UI library
    ]]
    function MiscTab.setup(tab)
        -- SETTINGS SECTION
        local settingsSection = tab:AddSection("Settings")
    
        -- Theme Info (read-only for now)
        settingsSection:AddParagraph({
            Title = "Current Theme",
            Content = "Discord Dark Mode\nSimple & Modern Design"
        })
    
        -- Credits
        local creditsSection = tab:AddSection("Credits")
    
        creditsSection:AddParagraph({
            Title = "Zivi Hub",
            Content = [[
    Version: 2.0.0 BETA
    Developer: Zivi Team
    
    Features:
    - Instant Fishing
    - Auto Sell
    - Auto Favorite
    - Trading System
    - Teleportation
    - Discord Webhooks
    
    WARNING: Use at your own risk!
            ]]
        })
    
        print("[Misc Tab] Initialized")
    end
    
    return MiscTab

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
    local FishTab = require("src/ui/tabs/fish-tab")
    local TradeTab = require("src/ui/tabs/trade-tab")
    local TeleportTab = require("src/ui/tabs/teleport-tab")
    local WebhookTab = require("src/ui/tabs/webhook-tab")
    local MiscTab = require("src/ui/tabs/misc-tab")
    
    local MainWindow = {}
    
    -- Window instance
    local window = nil
    local tabs = {}
    
    --[[
        Create main window with all tabs
        @return table - Window object
    ]]
    function MainWindow.create()
        if window then
            warn("[MainWindow] Window already exists")
            return window
        end
    
        -- Create window
        window = Library.createWindow()
    
        if not window then
            error("[MainWindow] Failed to create window")
        end
    
        print("[MainWindow] Window created, type:", type(window))
        print("[MainWindow] AddTab method exists:", type(window.AddTab))
    
        -- Create tabs
        -- Icon can be string name OR rbxassetid
        print("[MainWindow] Creating Fishing tab...")
        tabs.fish = window:AddTab({
            Name = "Fishing",
            Icon = "rbxassetid://97167558235554"
        })
        print("[MainWindow] Fishing tab created:", tabs.fish ~= nil)
    
        tabs.trade = window:AddTab({
            Name = "Trading",
            Icon = "rbxassetid://114581487428395"
        })
    
        tabs.teleport = window:AddTab({
            Name = "Teleport",
            Icon = "rbxassetid://18648122722"
        })
    
        tabs.webhook = window:AddTab({
            Name = "Webhook",
            Icon = "rbxassetid://137601480983962"
        })
    
        tabs.misc = window:AddTab({
            Name = "Misc",
            Icon = "rbxassetid://6034509993"
        })
    
        -- Setup tabs
        FishTab.setup(tabs.fish)
        TradeTab.setup(tabs.trade)
        TeleportTab.setup(tabs.teleport)
        WebhookTab.setup(tabs.webhook)
        MiscTab.setup(tabs.misc)
    
        print("[MainWindow] All tabs initialized")
    
        return window
    end
    
    --[[
        Get window instance
        @return table - Window object or nil
    ]]
    function MainWindow.getWindow()
        return window
    end
    
    --[[
        Get tab by name
        @param tabName string - Tab name
        @return table - Tab object or nil
    ]]
    function MainWindow.getTab(tabName)
        return tabs[tabName:lower()]
    end
    
    --[[
        Destroy window
    ]]
    function MainWindow.destroy()
        if window then
            -- Clean up if library supports it
            window = nil
            tabs = {}
        end
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
