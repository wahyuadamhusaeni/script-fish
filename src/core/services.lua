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
