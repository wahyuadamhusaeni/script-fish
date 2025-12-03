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
    
    return window
end

return MainWindow
