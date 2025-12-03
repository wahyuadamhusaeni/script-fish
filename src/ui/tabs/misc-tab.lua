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
