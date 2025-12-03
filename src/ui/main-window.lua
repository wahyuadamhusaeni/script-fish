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
