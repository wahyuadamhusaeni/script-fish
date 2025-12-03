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
