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
