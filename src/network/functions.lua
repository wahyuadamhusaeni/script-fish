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
