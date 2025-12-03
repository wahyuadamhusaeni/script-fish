-- ============================================
-- EXECUTOR COMPATIBILITY CHECK
-- ============================================

local httpRequest = syn and syn.request
    or http and http.request
    or http_request
    or fluxus and fluxus.request
    or request

if not httpRequest then
    warn("[ERROR] Executor not supported - HTTP requests required")
    return
end

_G.httpRequest = httpRequest

-- ============================================
-- LOAD CORE MODULES
-- ============================================

print("🔄 Loading core modules...")

local success, Services = pcall(function() return require("src/core/services") end)
if not success then
    warn("❌ Failed to load Services:", Services)
    return
end
print("   ✓ Services loaded")

local success2, Constants = pcall(function() return require("src/core/constants") end)
if not success2 then
    warn("❌ Failed to load Constants:", Constants)
    return
end
print("   ✓ Constants loaded")

local success3, State = pcall(function() return require("src/core/state") end)
if not success3 then
    warn("❌ Failed to load State:", State)
    return
end
print("   ✓ State loaded")

-- ============================================
-- LOAD NETWORK MODULES
-- ============================================

local Events = require("src/network/events")
local Functions = require("src/network/functions")
local Webhook = require("src/network/webhook")

-- ============================================
-- LOAD UTILITY MODULES
-- ============================================

local PlayerUtils = require("src/utils/player-utils")

-- ============================================
-- LOAD FEATURE MODULES
-- ============================================

local InstantFish = require("src/features/fishing/instant-fish")
local AutoSell = require("src/features/selling/auto-sell")
local AutoFavorite = require("src/features/favorites/auto-favorite")
local Teleport = require("src/features/teleport/teleport")

-- ============================================
-- LOAD CONFIG MODULES
-- ============================================

local Locations = require("src/config/locations")

-- ============================================
-- WAIT FOR CHARACTER
-- ============================================

local LocalPlayer = Services.LocalPlayer
if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
end

-- ============================================
-- INITIALIZE GLOBALS
-- ============================================

_G.Celestial = _G.Celestial or {}
_G.Celestial.DetectorCount = _G.Celestial.DetectorCount or 0
_G.Celestial.InstantCount = _G.Celestial.InstantCount or 0
_G.TierFish = Constants.TIER_FISH
_G.Variant = Constants.VARIANTS

-- ============================================
-- LOAD UI MODULES
-- ============================================

print("🔄 Loading UI modules...")

local uiSuccess, MainWindow = pcall(function() return require("src/ui/main-window") end)
if not uiSuccess then
    warn("❌ Failed to load UI modules:", MainWindow)
    warn("[WARNING] UI will not be available")
    MainWindow = nil
else
    print("   ✓ MainWindow loaded")
end

-- ============================================
-- INITIALIZE AUTO TELEPORT
-- ============================================

Teleport.setupAutoTeleport()

-- ============================================
-- CREATE UI
-- ============================================

print("")

if MainWindow then
    print("🎨 Creating UI...")

    local success, err = pcall(function()
        MainWindow.create()
    end)

    if success then
        print("[OK] UI created successfully!")
        print("🎨 Theme: Discord Dark Mode")
    else
        warn("❌ UI creation failed:", err)
        print("[WARNING] Features still available via console")
    end
else
    warn("[WARNING] UI modules not loaded - UI unavailable")
    print("[WARNING] Features still available via console")
end