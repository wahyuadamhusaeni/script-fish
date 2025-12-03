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
