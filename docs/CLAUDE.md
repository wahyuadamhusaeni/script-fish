# CLAUDE.md - Refactoring Roadmap & Development Guide

## PROJECT STATUS: IN PROGRESS

**Script Name:** Zivi Hub
**Version:** 2.5.0 BETA
**Status:** Feature Complete
**Last Updated:** November 26, 2025

### ✅ Completed Phases:

- **Phase 1: Core & Network** ✅ (8 modules, 654 lines, 21.5 KB)
  - Core modules: services, constants, state
  - Network modules: events, functions, webhook
  - Utility modules: player-utils

- **Phase 2: Features** ✅ (13 modules, 1,470 lines, 43.9 KB)
  - Fishing: instant-fish
  - Selling: auto-sell
  - Favorites: auto-favorite
  - Teleport: teleport with save/load
  - Config: locations (25+ spots)

- **Phase 3: UI & Rebranding** ✅ (18 modules, 2,124 lines, 62.86 KB)
  - UI modules: library, main-window, fish-tab, auto-tab, misc-tab
  - Discord dark theme (#36393F, #5865F2)
  - Rebranded to "Zivi Hub v1.0.0 BETA"
  - All file saves use `_ZIVIHUB` suffix

- **Phase 4: Trading System** ✅ (22 modules, 3,252 lines, 96.40 KB)
  - Trading modules: auto-trade, trade-filters, trade-tab
  - Data module: models (Replion, ItemUtility access)
  - Trade by Name: Send specific items
  - Trade by Coin: Target coin value
  - Trade by Rarity: Send by rarity level
  - Auto Accept: Automatic trade acceptance

- **Phase 5: Tab Separation** ✅ (24 modules, 3,429 lines, 107.03 KB)
  - New tabs: teleport-tab, webhook-tab
  - Teleport: Separate tab with button-based teleport
  - Webhook: Complete fish caught notifications with rarity filter
  - Hide identifier: Privacy option for webhooks
  - Removed all emojis from codebase

- **Phase 6: Fishing Modes** ✅ (25 modules, 4,044 lines, 134 KB)
  - Legit Fishing: Two modes (Always Perfect + Normal)
    - Always Perfect: Auto cast + bobber detection + perfect catch
    - Normal: Power override + auto cast + shake integration
    - Complete tryCast logic with charge bar detection
  - Blatant Fishing: Aggressive method (Fast/Random Result modes)
  - Auto Shake: Independent spam click feature
  - Recovery: Cancel stuck fishing state
  - Complete fishing mode coverage with original logic restored

### 📊 Current Statistics:

```
Total Modules:     25
Total Lines:       4,044
Bundle Size:       134 KB
Theme:            Discord Dark Mode
Build System:     Node.js bundler
File Naming:      ZiviHub/*_ZIVIHUB.json (separate folder)
Trading:          Fully Implemented
Fishing Modes:    All 3 modes (Instant, Legit, Blatant)
Legit Modes:      2 modes (Always Perfect, Normal)
Webhook:          Complete with rarity filter
Tabs:             6 (Fishing, Auto, Trading, Teleport, Webhook, Misc)
```

### 🚀 Load Script:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/zildjianvitoo/script-fishit/main/build/script.lua"))()
```

---

## Table of Contents
1. [Overview](#overview)
2. [Current Problems](#current-problems)
3. [Modular Architecture Design](#modular-architecture-design)
4. [Refactoring Steps](#refactoring-steps)
5. [Build System](#build-system)
6. [Development Workflow](#development-workflow)
7. [File Structure](#file-structure)
8. [Best Practices](#best-practices)
9. [Testing Strategy](#testing-strategy)
10. [Deployment](#deployment)

---

## Overview

**Original Script:** Single file 6160 lines yang sulit di-maintain
**Refactored Script:** 18 modular files (2,124 lines total)

### Tujuan Refactoring (COMPLETED ✅):

✅ **Modularisasi** - Break down jadi multiple files (18 modules)
✅ **Maintainability** - Lebih mudah dibaca & di-edit (descriptive names, clean structure)
✅ **Reusability** - Reuse components (shared services, utilities)
✅ **Testability** - Easier to test individual modules (isolated functions)
✅ **Collaboration** - Multiple developers bisa work on different modules (git-friendly)
✅ **Branding** - Renamed to "Zivi Hub" with Discord dark theme
✅ **File Naming** - All saved files use `_ZIVIHUB` suffix for clarity

### Key Challenge: Roblox Executor Limitation

**Problem**: Roblox executors hanya bisa execute **1 file Lua** atau `loadstring()` dari 1 URL.

**Solution**:
- ✅ Development: Multiple modular files
- ✅ Production: Build script merge semua jadi 1 file
- ✅ Similar to: Webpack/Rollup bundling

---

## Original Problems (SOLVED ✅)

### 1. **Monolithic Structure** → SOLVED
- ❌ 6160 lines in 1 file
- ✅ Now: 18 modules (~120 lines each)

### 2. **Variable Naming** → SOLVED
```lua
-- Before: Obfuscated/minified names
local v0, v1, v2, v3... -- What are these?

-- After: Descriptive names
local Services, Constants, State
local InstantFish, AutoSell, Teleport
```

### 3. **No Separation of Concerns** → SOLVED
- ❌ UI, Logic, Network all mixed
- ✅ Now: Organized into core/, network/, features/, ui/

### 4. **Global State Pollution** → SOLVED
- ❌ Too many scattered globals
- ✅ Now: Centralized State module

### 5. **No Code Reuse** → SOLVED
- ❌ Duplicate code patterns
- ✅ Now: Shared utils/, services

### 6. **Hard to Extend** → SOLVED
- ❌ Risk of breaking features
- ✅ Now: Add new files without touching existing code

---

## Modular Architecture Design

### Actual Implemented Structure:

```
roblox-fishit-script/
│
├── src/                          # ✅ Source files (18 modules)
│   ├── core/                     # ✅ Core modules (3 files)
│   │   ├── services.lua          # ✅ Roblox services initialization
│   │   ├── constants.lua         # ✅ Constants (fish tiers, variants)
│   │   └── state.lua             # ✅ Global state management
│   │
│   ├── network/                  # ✅ Network & communication (3 files)
│   │   ├── events.lua            # ✅ Remote events (FireServer)
│   │   ├── functions.lua         # ✅ Remote functions (InvokeServer)
│   │   └── webhook.lua           # ✅ Discord webhook handler
│   │
│   ├── features/                 # ✅ Feature modules (4 files)
│   │   ├── fishing/
│   │   │   └── instant-fish.lua  # ✅ Instant fishing (auto catch)
│   │   ├── selling/
│   │   │   └── auto-sell.lua     # ✅ Auto sell (delay/count modes)
│   │   ├── favorites/
│   │   │   └── auto-favorite.lua # ✅ Auto favorite (name/rarity/variant filters)
│   │   └── teleport/
│   │       └── teleport.lua      # ✅ Teleportation + save/load position
│   │
│   ├── ui/                       # ✅ User interface (5 files)
│   │   ├── library.lua           # ✅ UI library loader (Discord theme)
│   │   ├── main-window.lua       # ✅ Main window manager
│   │   └── tabs/
│   │       ├── fish-tab.lua      # ✅ Fishing controls + real-time stats
│   │       ├── auto-tab.lua      # ✅ Auto sell + auto favorite
│   │       └── misc-tab.lua      # ✅ Teleport + webhook + settings
│   │
│   ├── utils/                    # ✅ Utility functions (1 file)
│   │   └── player-utils.lua      # ✅ Player helpers (teleport, getHRP)
│   │
│   ├── config/                   # ✅ Configuration (1 file)
│   │   └── locations.lua         # ✅ 25+ fishing locations
│   │
│   └── main.lua                  # ✅ Entry point (orchestration)
│
├── build/                        # ✅ Build output
│   └── script.lua                # ✅ Final bundled script (62.86 KB)
│
├── tools/                        # ✅ Build tools
│   └── bundler.js                # ✅ Node.js bundler (18 modules → 1 file)
│
├── docs/                         # ✅ Documentation
│   ├── CLAUDE.md                 # ✅ This file (developer guide)
│   ├── CHANGELOG.md              # ✅ Version history
│   ├── FINAL_SUMMARY.md          # ✅ Project completion summary
│   ├── LOADER.md                 # ✅ Loading instructions
│   ├── PROJECT_SUMMARY.md        # ✅ Project overview
│   └── QUICKSTART.md             # ✅ Quick start guide
│
├── .gitignore                    # ✅ Git ignore rules
├── README.md                     # ✅ User documentation
├── CLAUDE.md                     # ✅ Developer guide (this file)
├── package.json                  # ✅ Node.js build scripts
└── script.lua                    # ⚠️  Original 6160-line script (archived)
```

### 📁 File Naming Convention:

All saved files use `_ZIVIHUB` suffix to avoid conflicts:
- **Position Save:** `FishIt/SavedPosition_ZIVIHUB.json`
- **Config (future):** `fishit-config_ZIVIHUB.json`

---

## Refactoring Steps

### Phase 1: Setup & Core Extraction

**Goal**: Setup build system & extract core modules

#### Step 1.1: Create Folder Structure
```bash
mkdir -p src/{core,network,data,features,ui,utils,config}
mkdir -p build tools tests
```

#### Step 1.2: Extract Services (Lines 1-11)
**File**: `src/core/services.lua`

```lua
-- src/core/services.lua
local Services = {}

Services.Players = game:GetService("Players")
Services.RunService = game:GetService("RunService")
Services.HttpService = game:GetService("HttpService")
Services.RS = game:GetService("ReplicatedStorage")
Services.VIM = game:GetService("VirtualInputManager")
Services.PG = game:GetService("Players").LocalPlayer.PlayerGui
Services.Camera = workspace.CurrentCamera
Services.GuiService = game:GetService("GuiService")
Services.CoreGui = game:GetService("CoreGui")

return Services
```

#### Step 1.3: Extract Constants
**File**: `src/core/constants.lua`

```lua
-- src/core/constants.lua
local Constants = {}

Constants.TIER_FISH = {
    [1] = " ",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "Secret"
}

Constants.VARIANTS = {
    "Galaxy",
    "Corrupt",
    "Gemstone",
    "Ghost",
    "Lightning",
    -- ... dll
}

Constants.IGNORED_EVENTS = {
    Cloudy = true,
    Day = true,
    ["Increased Luck"] = true,
    -- ... dll
}

return Constants
```

#### Step 1.4: Extract State Management
**File**: `src/core/state.lua`

```lua
-- src/core/state.lua
local Services = require("src/core/services")

local State = {
    -- Fishing
    autoInstant = false,
    canFish = true,

    -- Selling
    autoSellEnabled = false,
    sellMode = "Delay",
    sellDelay = 60,
    inputSellCount = 50,

    -- Favorites
    autoFavEnabled = false,
    selectedName = {},
    selectedRarity = {},
    selectedVariant = {},

    -- Events
    autoEventActive = false,
    selectedEvents = {},

    -- Player references
    player = Services.Players.LocalPlayer,
    stats = Services.Players.LocalPlayer:WaitForChild("leaderstats"),
    caught = Services.Players.LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Caught"),
    char = Services.Players.LocalPlayer.Character or Services.Players.LocalPlayer.CharacterAdded:Wait(),

    -- Trading
    trade = {
        selectedPlayer = nil,
        selectedItem = nil,
        tradeAmount = 1,
        trading = false,
        successCount = 0,
        failCount = 0
    }
}

return State
```

### Phase 2: Extract Network Layer

#### Step 2.1: Remote Events
**File**: `src/network/events.lua`

```lua
-- src/network/events.lua
local Services = require("src/core/services")
local Net = Services.RS.Packages._Index["sleitnick_net@0.2.0"].net

local Events = {
    RECutscene = Net["RE/ReplicateCutscene"],
    REStop = Net["RE/StopCutscene"],
    REFav = Net["RE/FavoriteItem"],
    REFavChg = Net["RE/FavoriteStateChanged"],
    REFishDone = Net["RE/FishingCompleted"],
    REFishGot = Net["RE/FishCaught"],
    RENotify = Net["RE/TextNotification"],
    REEquip = Net["RE/EquipToolFromHotbar"],
    REEquipItem = Net["RE/EquipItem"],
    REAltar = Net["RE/ActivateEnchantingAltar"],
    REAltar2 = Net["RE/ActivateSecondEnchantingAltar"],
    UpdateOxygen = Net["URE/UpdateOxygen"],
    REPlayFishEffect = Net["RE/PlayFishingEffect"],
    RETextEffect = Net["RE/ReplicateTextEffect"],
    REEvReward = Net["RE/ClaimEventReward"],
    Totem = Net["RE/SpawnTotem"],
    REObtainedNewFishNotification = Net["RE/ObtainedNewFishNotification"],
    FishingMinigameChanged = Net["RE/FishingMinigameChanged"],
    FishingStopped = Net["RE/FishingStopped"]
}

return Events
```

#### Step 2.2: Remote Functions
**File**: `src/network/functions.lua`

```lua
-- src/network/functions.lua
local Services = require("src/core/services")
local Net = Services.RS.Packages._Index["sleitnick_net@0.2.0"].net

local Functions = {
    Trade = Net["RF/InitiateTrade"],
    BuyRod = Net["RF/PurchaseFishingRod"],
    BuyBait = Net["RF/PurchaseBait"],
    BuyWeather = Net["RF/PurchaseWeatherEvent"],
    ChargeRod = Net["RF/ChargeFishingRod"],
    StartMini = Net["RF/RequestFishingMinigameStarted"],
    UpdateRadar = Net["RF/UpdateFishingRadar"],
    Cancel = Net["RF/CancelFishingInputs"],
    Dialogue = Net["RF/SpecialDialogueEvent"],
    Done = Net["RF/RequestFishingMinigameStarted"]
}

return Functions
```

#### Step 2.3: Webhook Handler
**File**: `src/network/webhook.lua`

```lua
-- src/network/webhook.lua
local Services = require("src/core/services")

local Webhook = {}

-- Initialize httpRequest based on executor
Webhook.httpRequest = syn and syn.request
    or http and http.request
    or http_request
    or fluxus and fluxus.request
    or request

function Webhook.send(url, data)
    if not Webhook.httpRequest then
        warn("HTTP request not supported by executor")
        return false
    end

    local success = pcall(function()
        Webhook.httpRequest({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = Services.HttpService:JSONEncode(data)
        })
    end)

    return success
end

function Webhook.sendFishCaught(webhookUrl, fishName, rarity, variant)
    local embed = {
        embeds = {{
            title = "🎣 Fish Caught!",
            description = string.format("**%s**\nRarity: %s\nVariant: %s",
                fishName, rarity, variant or "None"),
            color = 0x00ff00,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
        }}
    }

    return Webhook.send(webhookUrl, embed)
end

function Webhook.sendDisconnect(webhookUrl, reason, customName)
    local embed = {
        content = _G.DiscordMention or "",
        embeds = {{
            title = "⚠️ Disconnected",
            description = string.format("**%s** disconnected\nReason: %s",
                customName or "Player", reason),
            color = 0xff0000,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
        }}
    }

    return Webhook.send(webhookUrl, embed)
end

return Webhook
```

### Phase 3: Extract Features

#### Step 3.1: Auto Fishing Module
**File**: `src/features/fishing/instant-fish.lua`

```lua
-- src/features/fishing/instant-fish.lua
local State = require("src/core/state")
local Events = require("src/network/events")
local Functions = require("src/network/functions")

local InstantFish = {}

function InstantFish.getFishCount()
    local bagSizeLabel = State.player.PlayerGui
        :WaitForChild("Inventory")
        :WaitForChild("Main")
        :WaitForChild("Top")
        :WaitForChild("Options")
        :WaitForChild("Fish")
        :WaitForChild("Label")
        :WaitForChild("BagSize")

    return tonumber((bagSizeLabel.Text or "0/???"):match("(%d+)/")) or 0
end

function InstantFish.start()
    if not State.autoInstant then return end

    task.spawn(function()
        while State.autoInstant do
            if State.canFish then
                State.canFish = false

                -- Step 1: Charge rod
                local success, _, timestamp = pcall(function()
                    return Functions.ChargeRod:InvokeServer(workspace:GetServerTimeNow())
                end)

                if success and typeof(timestamp) == "number" then
                    local direction = -1
                    local power = 0.999

                    task.wait(0.3)

                    -- Step 2: Start minigame
                    pcall(function()
                        Functions.StartMini:InvokeServer(direction, power, timestamp)
                    end)

                    -- Step 3: Wait for fish data
                    local startTime = tick()
                    repeat
                        task.wait(0.05)
                    until _G.FishMiniData and _G.FishMiniData.LastShift
                        or tick() - startTime > 1

                    task.wait(_G.DelayComplete or 0)

                    -- Step 4: Complete fishing
                    pcall(function()
                        Events.REFishDone:FireServer()
                    end)

                    -- Step 5: Wait for inventory update
                    local oldCount = InstantFish.getFishCount()
                    local waitStart = tick()
                    repeat
                        task.wait(0.05)
                    until oldCount < InstantFish.getFishCount()
                        or tick() - waitStart > 1
                end

                State.canFish = true
            end

            task.wait(0.05)
        end
    end)
end

function InstantFish.stop()
    State.autoInstant = false
end

return InstantFish
```

#### Step 3.2: Auto Sell Module
**File**: `src/features/selling/auto-sell.lua`

```lua
-- src/features/selling/auto-sell.lua
local State = require("src/core/state")
local Services = require("src/core/services")
local SellFilters = require("src/features/selling/sell-filters")

local AutoSell = {}

function AutoSell.getMerchantUI()
    return {
        Root = Services.PG.Merchant.Main.Background,
        ItemsFrame = Services.PG.Merchant.Main.Background.Items.ScrollingFrame,
        RefreshButton = Services.PG.Merchant.Main.Background.RefreshLabel
    }
end

function AutoSell.sellItem(itemButton)
    -- Click item in merchant
    local pos = itemButton.AbsolutePosition
    local size = itemButton.AbsoluteSize

    local x = pos.X + size.X / 2
    local y = pos.Y + size.Y / 2

    Services.VIM:SendMouseButtonEvent(x, y, 0, true, nil, 0)
    task.wait(0.05)
    Services.VIM:SendMouseButtonEvent(x, y, 0, false, nil, 0)
end

function AutoSell.sellAll()
    local merchant = AutoSell.getMerchantUI()

    for _, itemButton in ipairs(merchant.ItemsFrame:GetChildren()) do
        if itemButton:IsA("ImageButton") then
            local itemData = itemButton:FindFirstChild("ItemData")

            if itemData and SellFilters.shouldSell(itemData) then
                AutoSell.sellItem(itemButton)
                task.wait(0.1)
            end
        end
    end
end

function AutoSell.start()
    task.spawn(function()
        while State.autoSellEnabled do
            if State.sellMode == "Delay" then
                task.wait(State.sellDelay)
            elseif State.sellMode == "Count" then
                local fishCount = require("src/features/fishing/instant-fish").getFishCount()

                repeat
                    task.wait(1)
                until fishCount >= State.inputSellCount
            end

            if State.autoSellEnabled then
                AutoSell.sellAll()
            end
        end
    end)
end

return AutoSell
```

### Phase 4: Extract UI

#### Step 4.1: Main Window
**File**: `src/ui/main-window.lua`

```lua
-- src/ui/main-window.lua
local Library = require("src/ui/library")
local FishTab = require("src/ui/tabs/fish-tab")
local AutoTab = require("src/ui/tabs/auto-tab")
local TradeTab = require("src/ui/tabs/trade-tab")
local WebhookTab = require("src/ui/tabs/webhook-tab")

local MainWindow = {}

function MainWindow.create()
    local window = Library:Window({
        Title = "Chloe X/FishIt",
        SubTitle = "Premium Edition",
        TabWidth = 140,
        Size = UDim2.fromOffset(520, 470),
        Acrylic = true,
        Theme = "Dark"
    })

    -- Create tabs
    local tabs = {
        fish = window:AddTab("Fish"),
        auto = window:AddTab("Auto"),
        farm = window:AddTab("Farm"),
        trade = window:AddTab("Trade"),
        misc = window:AddTab("Misc"),
        webhook = window:AddTab("Webhook")
    }

    -- Setup each tab
    FishTab.setup(tabs.fish)
    AutoTab.setup(tabs.auto)
    TradeTab.setup(tabs.trade)
    WebhookTab.setup(tabs.webhook)

    return window
end

return MainWindow
```

#### Step 4.2: Fish Tab
**File**: `src/ui/tabs/fish-tab.lua`

```lua
-- src/ui/tabs/fish-tab.lua
local State = require("src/core/state")
local InstantFish = require("src/features/fishing/instant-fish")

local FishTab = {}

function FishTab.setup(tab)
    local fishingSection = tab:AddSection("Fishing Features")

    -- Auto Fishing Toggle
    fishingSection:AddToggle({
        Title = "Auto Fishing",
        Content = "Automatically fish",
        Default = false,
        Callback = function(enabled)
            State.autoInstant = enabled

            if enabled then
                InstantFish.start()
            else
                InstantFish.stop()
            end
        end
    })

    -- Delay Input
    fishingSection:AddInput({
        Title = "Delay Complete",
        Value = tostring(_G.DelayComplete or 0),
        Callback = function(value)
            local delay = tonumber(value)
            if delay and delay >= 0 then
                _G.DelayComplete = delay
            end
        end
    })

    -- More fishing controls...
end

return FishTab
```

### Phase 5: Utilities

#### Step 5.1: Player Utils
**File**: `src/utils/player-utils.lua`

```lua
-- src/utils/player-utils.lua
local Services = require("src/core/services")

local PlayerUtils = {}

function PlayerUtils.getHumanoidRootPart(character)
    return character and (
        character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChildWhichIsA("BasePart")
    )
end

function PlayerUtils.teleport(character, position)
    local hrp = PlayerUtils.getHumanoidRootPart(character)
    if hrp then
        hrp.CFrame = CFrame.new(position)
    end
end

function PlayerUtils.setAnchored(character, anchored)
    if not character then return end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = anchored
        end
    end
end

function PlayerUtils.getPlayers(excludeSelf)
    local players = {}

    for _, player in ipairs(Services.Players:GetPlayers()) do
        if not excludeSelf or player ~= Services.Players.LocalPlayer then
            table.insert(players, player.Name)
        end
    end

    return players
end

return PlayerUtils
```

### Phase 6: Main Entry Point

**File**: `src/main.lua`

```lua
-- src/main.lua
-- Entry point - This gets executed when script loads

-- Check executor compatibility
local httpRequest = syn and syn.request
    or http and http.request
    or http_request
    or fluxus and fluxus.request
    or request

if not httpRequest then
    warn("Executor not supported - HTTP requests required")
    return
end

_G.httpRequest = httpRequest

-- Wait for character
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
end

-- Load modules
local Services = require("src/core/services")
local State = require("src/core/state")
local Constants = require("src/core/constants")
local MainWindow = require("src/ui/main-window")

-- Initialize globals
_G.Celestial = _G.Celestial or {}
_G.Celestial.DetectorCount = _G.Celestial.DetectorCount or 0
_G.Celestial.InstantCount = _G.Celestial.InstantCount or 0
_G.TierFish = Constants.TIER_FISH
_G.Variant = Constants.VARIANTS

-- Create UI
local window = MainWindow.create()

print("[Chloe X] Script loaded successfully!")
```

---

## Build System

### Option 1: Lua-based Bundler (Recommended)

**File**: `tools/bundler.lua`

```lua
-- tools/bundler.lua
-- Simple Lua bundler to merge all modules into one file

local function readFile(path)
    local file = io.open(path, "r")
    if not file then
        error("Could not open file: " .. path)
    end
    local content = file:read("*all")
    file:close()
    return content
end

local function writeFile(path, content)
    local file = io.open(path, "w")
    if not file then
        error("Could not write to file: " .. path)
    end
    file:write(content)
    file:close()
end

local function extractRequires(content)
    local requires = {}
    for requirePath in content:gmatch('require%("([^"]+)"%)') do
        table.insert(requires, requirePath)
    end
    return requires
end

local function bundle(entryPoint, outputPath)
    local bundled = {}
    local processed = {}
    local modules = {}

    local function processFile(filePath)
        if processed[filePath] then return end
        processed[filePath] = true

        print("Processing: " .. filePath)

        local content = readFile(filePath .. ".lua")
        local requires = extractRequires(content)

        -- Process dependencies first
        for _, reqPath in ipairs(requires) do
            processFile(reqPath)
        end

        -- Store module
        local moduleName = filePath:gsub("src/", "")
        modules[moduleName] = content
    end

    -- Process from entry point
    processFile(entryPoint)

    -- Generate bundled code
    local output = [[
-- Auto-generated bundle
-- Build date: ]] .. os.date("%Y-%m-%d %H:%M:%S") .. [[

local Modules = {}
local LoadedModules = {}

local function require(moduleName)
    -- Remove "src/" prefix if present
    moduleName = moduleName:gsub("^src/", "")

    if LoadedModules[moduleName] then
        return LoadedModules[moduleName]
    end

    local moduleFunc = Modules[moduleName]
    if not moduleFunc then
        error("Module not found: " .. moduleName)
    end

    local result = moduleFunc()
    LoadedModules[moduleName] = result
    return result
end

]]

    -- Add all modules
    for moduleName, content in pairs(modules) do
        -- Wrap module in function
        local wrapped = string.format([[
Modules["%s"] = function()
%s
end

]], moduleName, content)
        output = output .. wrapped
    end

    -- Add main execution
    output = output .. [[

-- Execute main
require("main")
]]

    writeFile(outputPath, output)
    print("Bundle created: " .. outputPath)
end

-- Run bundler
bundle("src/main", "build/script.lua")
```

**Usage**:
```bash
# Run bundler
lua tools/bundler.lua

# Output: build/script.lua (single file)
```

### Option 2: Node.js-based Bundler (Alternative)

**File**: `tools/bundler.js`

```javascript
// tools/bundler.js
const fs = require('fs');
const path = require('path');

const modules = new Map();
const processed = new Set();

function readFile(filePath) {
    return fs.readFileSync(filePath, 'utf8');
}

function extractRequires(content) {
    const regex = /require\("([^"]+)"\)/g;
    const requires = [];
    let match;

    while ((match = regex.exec(content)) !== null) {
        requires.push(match[1]);
    }

    return requires;
}

function processFile(filePath) {
    if (processed.has(filePath)) return;
    processed.add(filePath);

    console.log(`Processing: ${filePath}`);

    const fullPath = path.join(__dirname, '..', filePath + '.lua');
    const content = readFile(fullPath);
    const requires = extractRequires(content);

    // Process dependencies first
    requires.forEach(reqPath => processFile(reqPath));

    // Store module
    const moduleName = filePath.replace('src/', '');
    modules.set(moduleName, content);
}

function bundle(entryPoint, outputPath) {
    processFile(entryPoint);

    let output = `-- Auto-generated bundle\n`;
    output += `-- Build date: ${new Date().toISOString()}\n\n`;
    output += `local Modules = {}\n`;
    output += `local LoadedModules = {}\n\n`;

    output += `local function require(moduleName)\n`;
    output += `    moduleName = moduleName:gsub("^src/", "")\n`;
    output += `    if LoadedModules[moduleName] then\n`;
    output += `        return LoadedModules[moduleName]\n`;
    output += `    end\n`;
    output += `    local moduleFunc = Modules[moduleName]\n`;
    output += `    if not moduleFunc then\n`;
    output += `        error("Module not found: " .. moduleName)\n`;
    output += `    end\n`;
    output += `    local result = moduleFunc()\n`;
    output += `    LoadedModules[moduleName] = result\n`;
    output += `    return result\n`;
    output += `end\n\n`;

    // Add modules
    for (const [moduleName, content] of modules) {
        output += `Modules["${moduleName}"] = function()\n`;
        output += content;
        output += `\nend\n\n`;
    }

    // Execute main
    output += `require("main")\n`;

    fs.writeFileSync(outputPath, output);
    console.log(`Bundle created: ${outputPath}`);
}

bundle('src/main', 'build/script.lua');
```

**Setup**:
```bash
npm init -y
node tools/bundler.js
```

**File**: `package.json`

```json
{
  "name": "roblox-fishit-script",
  "version": "1.0.0",
  "scripts": {
    "build": "node tools/bundler.js",
    "dev": "nodemon --watch src -e lua --exec 'npm run build'"
  },
  "devDependencies": {
    "nodemon": "^3.0.0"
  }
}
```

---

## Development Workflow

### Daily Development:

1. **Edit source files** in `src/`
   ```bash
   # Edit any file
   code src/features/fishing/instant-fish.lua
   ```

2. **Build bundle**
   ```bash
   # Lua bundler
   lua tools/bundler.lua

   # OR Node.js bundler
   npm run build
   ```

3. **Test in Roblox**
   - Copy `build/script.lua` content
   - Paste in executor
   - Test features

4. **Iterate**
   - Fix bugs in source files
   - Rebuild
   - Retest

### Auto-rebuild on change (Node.js only):

```bash
npm run dev
```

This watches `src/` folder and auto-rebuilds on file changes.

---

## Best Practices

### 1. Module Design

**✅ DO:**
```lua
-- Good: Single responsibility
local AutoFish = {}

function AutoFish.start() end
function AutoFish.stop() end
function AutoFish.getFishCount() end

return AutoFish
```

**❌ DON'T:**
```lua
-- Bad: Mixed responsibilities
local Everything = {}

function Everything.fish() end
function Everything.sell() end
function Everything.trade() end
function Everything.teleport() end

return Everything
```

### 2. Naming Conventions

**✅ DO:**
```lua
-- Clear, descriptive names
local InstantFish = require("src/features/fishing/instant-fish")
local playerPosition = Vector3.new(0, 0, 0)
local function getFishCount() end
```

**❌ DON'T:**
```lua
-- Cryptic names
local v0 = require("src/f/if")
local l_pos_0 = Vector3.new(0, 0, 0)
local function fn1() end
```

### 3. Error Handling

**✅ DO:**
```lua
function AutoFish.start()
    local success, error = pcall(function()
        -- Risky operation
    end)

    if not success then
        warn("[AutoFish] Error:", error)
        return false
    end

    return true
end
```

**❌ DON'T:**
```lua
function AutoFish.start()
    -- No error handling
    Functions.ChargeRod:InvokeServer()
end
```

### 4. Documentation

**✅ DO:**
```lua
--[[
    AutoFish Module

    Handles automatic fishing functionality.

    Functions:
    - start() : Begin auto fishing
    - stop() : Stop auto fishing
    - getFishCount() : Returns current fish count

    Dependencies:
    - src/core/state
    - src/network/functions
]]
local AutoFish = {}
```

### 5. State Management

**✅ DO:**
```lua
-- Centralized state
local State = require("src/core/state")

function AutoFish.start()
    State.autoFishEnabled = true
end
```

**❌ DON'T:**
```lua
-- Scattered globals
_G.autoFish = true
_G.fishCount = 0
_G.lastFish = nil
```

---

## Testing Strategy

### Manual Testing Checklist:

```markdown
## Pre-Release Testing

### Core Features
- [ ] Script loads without errors
- [ ] UI opens correctly
- [ ] All tabs are accessible

### Fishing
- [ ] Auto fishing starts/stops
- [ ] Instant fishing catches fish
- [ ] Fish count updates correctly
- [ ] No errors in console

### Selling
- [ ] Auto sell triggers correctly
- [ ] Filters work (by name, rarity, variant)
- [ ] Merchant UI interaction works

### Trading
- [ ] Can select player
- [ ] Trade sends correctly
- [ ] Auto accept works

### Teleportation
- [ ] Can teleport to locations
- [ ] Save/load position works
- [ ] No falling through map

### Webhooks
- [ ] Webhook sends on fish caught
- [ ] Webhook sends on disconnect
- [ ] Correct embed format

### Error Handling
- [ ] No crashes on network errors
- [ ] Graceful handling of missing data
- [ ] Clear error messages
```

### Unit Testing (Future):

```lua
-- tests/test-utils.lua
local function assert_equals(actual, expected, message)
    if actual ~= expected then
        error(string.format(
            "%s\nExpected: %s\nActual: %s",
            message or "Assertion failed",
            tostring(expected),
            tostring(actual)
        ))
    end
end

-- Test example
local PlayerUtils = require("src/utils/player-utils")

local function test_getPlayers()
    local players = PlayerUtils.getPlayers(true)
    assert_equals(type(players), "table", "Should return table")
    print("✓ test_getPlayers passed")
end

test_getPlayers()
```

---

## Deployment

### Production Build:

1. **Build final script**
   ```bash
   npm run build
   ```

2. **Minify (optional)**
   ```bash
   # Using external tool
   luamin -f build/script.lua -o build/script.min.lua
   ```

3. **Upload to GitHub**
   ```bash
   git add build/script.lua
   git commit -m "Build: Update production script"
   git push origin main
   ```

4. **Get raw URL**
   ```
   https://raw.githubusercontent.com/username/repo/main/build/script.lua
   ```

5. **Usage**
   ```lua
   -- Users load with:
   loadstring(game:HttpGet("https://raw.githubusercontent.com/username/repo/main/build/script.lua"))()
   ```

### Version Management:

**File**: `src/core/version.lua`

```lua
-- src/core/version.lua
return {
    VERSION = "2.0.0",
    BUILD_DATE = "2025-01-17",
    CHANGELOG = {
        ["2.0.0"] = {
            "Refactored to modular architecture",
            "Improved performance",
            "Better error handling"
        },
        ["1.0.0"] = {
            "Initial release"
        }
    }
}
```

---

## Migration Path

### Step-by-Step Migration from Current Script:

**Week 1**: Setup & Core
- [ ] Create folder structure
- [ ] Setup build system
- [ ] Extract services, constants, state
- [ ] Test basic build

**Week 2**: Network & Data
- [ ] Extract network layer (events, functions)
- [ ] Extract data models
- [ ] Extract webhook system
- [ ] Test network operations

**Week 3**: Features Part 1
- [ ] Extract auto fishing
- [ ] Extract auto selling
- [ ] Extract auto favorites
- [ ] Test fishing workflow

**Week 4**: Features Part 2
- [ ] Extract trading system
- [ ] Extract teleportation
- [ ] Extract enchanting
- [ ] Test all features

**Week 5**: UI
- [ ] Extract UI library loader
- [ ] Extract all tabs
- [ ] Extract components
- [ ] Test UI interactions

**Week 6**: Polish & Testing
- [ ] Add error handling
- [ ] Add logging
- [ ] Full integration testing
- [ ] Documentation

**Week 7**: Deployment
- [ ] Final build
- [ ] Upload to GitHub
- [ ] Update README
- [ ] Announce release

---

## Future Improvements

### 1. **Config Persistence**
```lua
-- Save/load config from file
local Config = {}

function Config.save()
    local data = {
        autoFish = State.autoFishEnabled,
        sellMode = State.sellMode,
        webhookURL = _G.WebhookURL
    }
    writefile("fishit-config_ZIVIHUB.json", HttpService:JSONEncode(data))
end

function Config.load()
    if isfile("fishit-config_ZIVIHUB.json") then
        local data = HttpService:JSONDecode(readfile("fishit-config_ZIVIHUB.json"))
        State.autoFishEnabled = data.autoFish
        State.sellMode = data.sellMode
        _G.WebhookURL = data.webhookURL
    end
end
```

### 2. **Plugin System**
```lua
-- Allow users to add custom plugins
local PluginManager = {}

function PluginManager.loadPlugin(pluginUrl)
    local pluginCode = game:HttpGet(pluginUrl)
    local plugin = loadstring(pluginCode)()
    plugin.init(State, Services, Events)
end
```

### 3. **Auto-Update System**
```lua
-- Check for updates
local version = "2.0.0"
local updateUrl = "https://api.github.com/repos/user/repo/releases/latest"

local response = game:HttpGet(updateUrl)
local data = HttpService:JSONDecode(response)

if data.tag_name ~= version then
    print("Update available:", data.tag_name)
    -- Prompt user to update
end
```

### 4. **Performance Monitoring**
```lua
-- Track performance metrics
local Profiler = {}

function Profiler.start(name)
    Profiler[name] = tick()
end

function Profiler.stop(name)
    local elapsed = tick() - (Profiler[name] or 0)
    print(string.format("[Profiler] %s: %.3fs", name, elapsed))
end

-- Usage
Profiler.start("AutoFish")
-- ... fishing code ...
Profiler.stop("AutoFish")
```

---

## Important Reminders

### ⚠️ Before Starting Refactor:

1. **Backup original script** - Keep `script.lua` safe
2. **Test incrementally** - Don't refactor everything at once
3. **Version control** - Use git commits frequently
4. **Document changes** - Update README as you go

### ⚠️ Common Pitfalls:

1. **Circular Dependencies**
   ```lua
   -- Module A requires Module B
   -- Module B requires Module A
   -- ❌ This will cause infinite loop!
   ```

2. **Missing Dependencies**
   ```lua
   -- Forgot to include module in bundle
   -- ❌ Runtime error: "Module not found"
   ```

3. **Global Pollution**
   ```lua
   -- Avoid creating too many globals
   -- ✅ Use local variables
   -- ✅ Return from modules
   ```

4. **Path Issues**
   ```lua
   -- Inconsistent paths
   -- ✅ Always use: "src/core/services"
   -- ❌ Not: "../core/services" or "core/services"
   ```

---

## Questions to Resolve

Before starting refactoring, confirm:

1. **Executor Target**:
   - Which executor(s) will you support?
   - Does it support `loadstring()`?
   - Does it support `readfile()`/`writefile()`?

2. **Distribution Method**:
   - GitHub raw URL?
   - Pastebin?
   - Private server?

3. **Update Frequency**:
   - How often will you update?
   - Automatic updates or manual?

4. **Collaboration**:
   - Working solo or with team?
   - Need code review process?

5. **Backward Compatibility**:
   - Support old version?
   - Migration path for users?

---

**Ready to start refactoring?** Begin with Phase 1, Step 1.1!

Good luck! 🚀
