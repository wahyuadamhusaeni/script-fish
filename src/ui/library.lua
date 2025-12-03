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
Library.LogoAssetId = "132435516080103" -- Chloe logo asset ID

-- Discord Dark Theme Colors
Library.Theme = {
    -- Primary colors (Discord dark mode)
    Background = Color3.fromRGB(54, 57, 63), -- Dark gray (#36393f)
    Secondary = Color3.fromRGB(47, 49, 54),  -- Darker gray (#2f3136)
    Tertiary = Color3.fromRGB(32, 34, 37),   -- Darkest gray (#202225)

    -- Accent colors
    Primary = Color3.fromRGB(88, 101, 242), -- Blurple (#5865f2)
    Success = Color3.fromRGB(67, 181, 129), -- Green (#43b581)
    Warning = Color3.fromRGB(250, 166, 26), -- Yellow (#faa61a)
    Danger = Color3.fromRGB(237, 66, 69),   -- Red (#ed4245)

    -- Text colors
    TextPrimary = Color3.fromRGB(255, 255, 255),   -- White
    TextSecondary = Color3.fromRGB(185, 187, 190), -- Gray
    TextMuted = Color3.fromRGB(114, 118, 125),     -- Muted gray

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
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
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

    lib:AddTheme({
        Name = "Royal Void",
        Accent = lib:Gradient({
            ["0"]   = { Color = Color3.fromHex("#FF3366"), Transparency = 0 }, -- Merah Cerah
            ["50"]  = { Color = Color3.fromHex("#1E90FF"), Transparency = 0 }, -- biru Cerah
            ["100"] = { Color = Color3.fromHex("#9B30FF"), Transparency = 0 }, -- Ungu Terang
        }, {
            Rotation = 45,
        }),

        Dialog = Color3.fromHex("#0A0011"),      -- Latar hitam ke ungu gelap
        Outline = Color3.fromHex("#1E90FF"),     -- Pinggir biru Cerah
        Text = Color3.fromHex("#FFE6FF"),        -- Putih ke ungu muda
        Placeholder = Color3.fromHex("#B34A7F"), -- Ungu-merah pudar
        Background = Color3.fromHex("#050008"),  -- Hitam pekat dengan nuansa ungu
        Button = Color3.fromHex("#FF00AA"),      -- Merah ke ungu neon
        Icon = Color3.fromHex("#0066CC")         -- Aksen biru
    })
    lib.TransparencyValue = 0.2

    -- Create window with Discord dark theme
    local window = lib:CreateWindow({
        Title = "AdviHub",
        Icon = "crown",
        Author = "Fishit | Advi",
        Folder = "AdviHub",
        Size = UDim2.fromOffset(400, 200),
        Transparent = true,
        Theme = "Royal Void",
        Resizable = true,
        ScrollBarEnabled = true,
        HideSearchBar = true,
        NewElements = true,
        User = {
            Enabled = true,
            Anonymous = false,
            Callback = function() end,
        }
    })

    window:EditOpenButton({
        Title = "AdviHub",
        Icon = "crown",
        CornerRadius = UDim.new(0, 30),
        StrokeThickness = 2,
        Color = ColorSequence.new( -- gradient
            Color3.fromHex("#FF3366"), -- Merah
            Color3.fromHex("#1E90FF"), -- biru
            Color3.fromHex("#9B30FF") -- Ungu
        ),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    })

    if window then
        print("[UI Library] Window created successfully")
    end

    return window
end

return Library
