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

    local automaticallyTab = Window:Tab({
        Title = "Automatically",
        Icon = "circle-play"
    })

    local tradingTab = Window:Tab({
        Title = "Trading",
        Icon = "trade"
    })

    local teleportTab = Window:Tab({
        Title = "Teleport",
        Icon = "teleport"
    })

    local webhookTab = Window:Tab({
        Title = "Webhook",
        Icon = "webhook"
    })

    local miscTab = Window:Tab({
        Title = "Misc",
        Icon = "misc"
    })

    FishingTab.setup(fishingTab)

    return Window
end

return MainWindow
