# Roblox FishIt Script - Documentation

## Table of Contents

1. [Introduction](#introduction)
2. [Lua Basics untuk JavaScript/TypeScript Developer](#lua-basics-untuk-javascripttypescript-developer)
3. [Script Overview](#script-overview)
4. [Main Features](#main-features)
5. [Code Structure](#code-structure)
6. [How It Works](#how-it-works)
7. [Setup & Usage](#setup--usage)
8. [Important Notes](#important-notes)

---

## Introduction

Script ini adalah **automation/exploit tool** untuk game Roblox "FishIt". Script ini mengotomasi proses fishing, selling, trading, dan berbagai aktivitas lainnya di game tersebut.

**⚠️ DISCLAIMER:**

- Menggunakan script ini **melanggar Terms of Service Roblox**
- Akun Anda bisa **di-ban** oleh Roblox
- Dokumentasi ini hanya untuk **tujuan pembelajaran**

---

## Lua Basics untuk JavaScript/TypeScript Developer

### 1. Variables & Data Types

```lua
-- Lua menggunakan 'local' untuk declare variables (seperti 'const/let' di JS)
local myVariable = "Hello"
local number = 42
local boolean = true
local table = {} -- Ini seperti object/array di JS

-- Global variable (tanpa 'local', seperti var di JS tapi scope-nya global)
globalVar = "I'm global"

-- Nil = null di JavaScript
local nothing = nil
```

### 2. Tables (Object + Array)

Lua hanya punya **1 data structure**: `table`. Table bisa berperan sebagai array ATAU object.

```lua
-- Array-style (index mulai dari 1, bukan 0!)
local fruits = {"apple", "banana", "orange"}
print(fruits[1]) -- "apple" (index dimulai dari 1!)

-- Object-style (key-value pairs)
local person = {
    name = "John",
    age = 30,
    isActive = true
}
print(person.name) -- "John"
print(person["age"]) -- 30 (sama seperti JS)

-- Mixed (bisa gabung!)
local mixed = {
    "first",        -- index [1]
    "second",       -- index [2]
    key = "value",  -- key-value
    nested = {
        data = 123
    }
}
```

### 3. Functions

```lua
-- Function declaration
local function myFunction(param1, param2)
    return param1 + param2
end

-- Anonymous function (seperti arrow function)
local add = function(a, b)
    return a + b
end

-- Function sebagai callback
table.insert(myArray, function()
    print("I'm a callback")
end)
```

### 4. Conditionals

```lua
-- If-else (mirip JS, tapi pakai 'then' dan 'end')
if condition then
    -- do something
elseif otherCondition then
    -- do other
else
    -- default
end

-- Not operator menggunakan 'not' (bukan '!')
if not isActive then
    print("Inactive")
end

-- And/Or (bukan '&&' atau '||')
if age > 18 and hasPermission then
    print("Allowed")
end
```

### 5. Loops

```lua
-- For loop (array-style)
for i = 1, 10 do
    print(i) -- print 1 sampai 10
end

-- For each (iterate table)
for index, value in ipairs(myArray) do
    print(index, value)
end

-- For object properties
for key, value in pairs(myObject) do
    print(key, value)
end

-- While loop
while condition do
    -- do something
end
```

### 6. String Operations

```lua
-- String concatenation pakai '..' (bukan '+')
local fullName = "John" .. " " .. "Doe"

-- String methods menggunakan ':'
local text = "hello world"
text:upper() -- "HELLO WORLD"
text:find("world") -- returns index

-- String formatting
string.format("Hello %s, you are %d years old", name, age)
```

### 7. Key Differences dari JavaScript

| JavaScript     | Lua                         | Keterangan                |
| -------------- | --------------------------- | ------------------------- |
| `null`         | `nil`                       | Null value                |
| `!`            | `not`                       | Logical NOT               |
| `&&`           | `and`                       | Logical AND               |
| `\|\|`         | `or`                        | Logical OR                |
| `!==`          | `~=`                        | Not equal                 |
| `array[0]`     | `table[1]`                  | Array index mulai dari 1! |
| `array.length` | `#array`                    | Get array length          |
| `obj.key`      | `obj.key` atau `obj["key"]` | Same                      |
| `function(){}` | `function() end`            | Function syntax           |
| `//` comment   | `--` comment                | Comment                   |
| `/* */`        | `--[[ ]]`                   | Multi-line comment        |

---

## Script Overview

Script ini adalah **6160 baris** automation tool yang memiliki fitur-fitur:

### Core Components:

1. **Services** - Akses ke Roblox game services
2. **Controllers** - Logic untuk fishing, trading, dll
3. **UI System** - GUI untuk mengontrol script
4. **Auto Fishing** - Otomatis memancing
5. **Auto Selling** - Otomatis jual ikan
6. **Auto Trading** - Otomatis trade item
7. **Auto Events** - Otomatis pergi ke event locations
8. **Webhook Integration** - Notifikasi ke Discord
9. **Position Saving** - Save/load posisi player

---

## Main Features

### 1. **Auto Fishing System**

- **Instant Fishing**: Langsung tangkap ikan tanpa minigame
- **Auto Shake**: Spam click selama fishing
- **Auto Cast**: Otomatis lempar kail
- **Power Control**: Set power casting (0-100%)

### 2. **Auto Sell System**

- **Sell by Count**: Jual otomatis setelah X ikan tertangkap
- **Sell by Delay**: Jual otomatis setiap X detik
- **Selective Selling**: Jual berdasarkan rarity/name/variant

### 3. **Auto Favorite**

- Otomatis favorite ikan tertentu
- Filter by: Name, Rarity, Variant
- Prevent accidental selling

### 4. **Auto Trading**

- **Trade by Name**: Trade ikan berdasarkan nama
- **Trade by Rarity**: Trade ikan berdasarkan rarity
- **Auto Accept**: Otomatis terima trade request

### 5. **Auto Events**

- Otomatis teleport ke event locations
- Priority event system
- Auto return setelah event selesai

### 6. **Webhook Notifications**

- Discord webhook integration
- Notify saat dapat ikan rare
- Notify saat disconnect
- Customizable filters

### 7. **Teleportation**

- 20+ predefined locations
- Save/load custom positions
- Auto teleport on respawn

### 8. **Rod & Bait Management**

- Auto buy rod/bait
- Auto equip best rod
- Rod priority system

---

## Code Structure

Script ini terbagi menjadi beberapa bagian besar:

```
script.lua (6160 lines)
├── Services Setup (Lines 1-11)
│   └── Game services: Players, RunService, HttpService, dll
│
├── Global Variables & State (Lines 72-160)
│   └── v8 = state management object
│
├── Data Models (Lines 72-76)
│   ├── v7.Data = Player data (Replion)
│   ├── v7.Items = Item catalog
│   └── v7.PlayerStat = Player statistics
│
├── Network Events & Functions (Lines 37-71)
│   ├── v6.Events = Remote Events (client-server communication)
│   └── v6.Functions = Remote Functions
│
├── Utility Functions (Lines 164-630)
│   ├── getFishCount() - Hitung jumlah ikan
│   ├── clickCenter() - Click tengah layar
│   ├── checkAndFavorite() - Auto favorite logic
│   ├── SavePosition() / LoadPosition() - Save/load position
│   └── Teleport functions
│
├── Auto Event System (Lines 431-584)
│   ├── Event detection
│   ├── Auto teleport ke events
│   └── Character respawn handler
│
├── UI Library (Line 649)
│   └── External UI library dari GitHub
│
├── Main UI Tabs (Lines 650+)
│   ├── Fish Tab - Fishing features
│   ├── Auto Tab - Automation features
│   ├── Farm Tab - Farming features
│   ├── Trade Tab - Trading features
│   ├── Misc Tab - Miscellaneous
│   └── Webhook Tab - Discord webhooks
│
└── Feature Implementations
    ├── Auto Fishing (Lines 900-1200)
    ├── Auto Sell (Lines 1300-1800)
    ├── Auto Trade (Lines 2800-3100)
    ├── Auto Events (Lines 500-584)
    ├── Enchanting (Lines 2034-2200)
    └── Kaitun Mode (Lines 3800-4200)
```

---

## How It Works

### 1. **Script Loading Process**

```lua
-- User paste ini ke executor:
loadstring(game:HttpGet("https://raw.githubusercontent.com/..."))()

-- Yang terjadi:
-- 1. game:HttpGet() fetch script dari URL
-- 2. loadstring() compile string jadi function
-- 3. () execute function tersebut
```

### 2. **Service Access**

```lua
-- Roblox punya "services" yang menyediakan API
local v0 = {
    Players = game:GetService("Players"),      -- Akses player data
    RunService = game:GetService("RunService"), -- Game loop/heartbeat
    HttpService = game:GetService("HttpService"), -- HTTP requests
    -- dll...
}

-- Ini seperti import modules di Node.js
```

### 3. **Remote Events (Client-Server Communication)**

Roblox menggunakan **Remote Events** untuk komunikasi client-server:

```lua
-- CLIENT → SERVER (Fire event)
v6.Events.REFishDone:FireServer() -- Beritahu server "ikan sudah tertangkap"

-- SERVER → CLIENT (Listen event)
v6.Events.REFishGot.OnClientEvent:Connect(function(fishData)
    -- Server kirim data ikan yang didapat
    print("Got fish:", fishData)
end)
```

**Analogi JavaScript:**

```javascript
// Seperti WebSocket / Socket.io
socket.emit("fishDone"); // FireServer
socket.on("fishGot", (data) => {}); // OnClientEvent
```

### 4. **Auto Fishing Flow**

```lua
-- 1. REQUEST CHARGE (mulai fishing)
v6.Functions.ChargeRod:InvokeServer(timestamp)

-- 2. START MINIGAME (lempar kail)
v6.Functions.StartMini:InvokeServer(direction, power, timestamp)

-- 3. WAIT FOR FISH DATA
repeat task.wait(0.05)
until _G.FishMiniData -- tunggu sampai ikan "gigit"

-- 4. COMPLETE FISHING (selesai)
v6.Events.REFishDone:FireServer()

-- 5. WAIT FOR FISH IN INVENTORY
local oldCount = getFishCount()
repeat task.wait(0.05)
until getFishCount() > oldCount
```

### 5. **State Management**

Script menggunakan object `v8` sebagai **global state** (seperti Redux/Zustand):

```lua
local v8 = {
    autoInstant = false,          -- Toggle instant fishing
    autoSellEnabled = false,      -- Toggle auto sell
    canFish = true,               -- Fishing cooldown flag
    selectedRarity = {},          -- Selected rarities
    trade = {                     -- Trade state
        selectedPlayer = nil,
        trading = false,
        successCount = 0
    }
    -- dll...
}
```

**Analogi TypeScript:**

```typescript
interface AppState {
  autoInstant: boolean;
  autoSellEnabled: boolean;
  canFish: boolean;
  selectedRarity: Record<string, boolean>;
  trade: {
    selectedPlayer: string | null;
    trading: boolean;
    successCount: number;
  };
}

const state: AppState = {
  /* ... */
};
```

### 6. **UI System**

Script menggunakan external UI library untuk membuat GUI:

```lua
-- Load UI library dari GitHub
local v137 = loadstring(game:HttpGet("https://..."))():Window({
    Title = "Chloe X/FishIt",
    -- config...
})

-- Buat tabs
local Fish = v137:AddTab("Fish")
local Auto = v137:AddTab("Auto")

-- Tambah controls
Fish:AddToggle({
    Title = "Auto Fishing",
    Default = false,
    Callback = function(value)
        -- Value = true/false saat user klik toggle
        v8.autoInstant = value
    end
})
```

### 7. **Webhook System**

Script bisa kirim notifikasi ke Discord via webhooks:

```lua
-- Kirim HTTP request ke Discord webhook
_G.httpRequest({
    Url = webhookURL,
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json"
    },
    Body = HttpService:JSONEncode({
        embeds = {{
            title = "Rare Fish Caught!",
            description = "You caught: **Megalodon**",
            color = 0x00ff00
        }}
    })
})
```

---

## Setup & Usage

### Prerequisites:

1. **Roblox Executor** (contoh: Synapse X, Fluxus, dll)
2. **Discord Webhook** (opsional, untuk notifikasi)
3. Game: **FishIt** di Roblox

### Installation:

1. **Copy script** ke executor:

   ```lua
   loadstring(game:HttpGet("https://raw.githubusercontent.com/MajestySkie/Chloe-X/main/Main/ChloeX"))()
   ```

2. **Execute** script di game FishIt

3. **GUI akan muncul** - Konfigurasi fitur yang diinginkan

### Basic Configuration:

#### Auto Fishing:

1. Tab **Fish** → Enable "Auto Fishing"
2. Pilih mode: "Instant" atau "Normal"
3. (Optional) Set "Auto Shake" untuk legit fishing

#### Auto Sell:

1. Tab **Auto** → Scroll ke "Auto Sell Features"
2. Enable "Auto Sell"
3. Pilih mode:
   - **Delay**: Jual setiap X detik
   - **Count**: Jual setiap X ikan tertangkap
4. Configure filters (Name/Rarity/Variant)

#### Auto Event:

1. Tab **Auto** → "Auto Event Features"
2. Select events yang ingin di-prioritas
3. Enable "Auto Event"
4. Script akan auto teleport ke event locations

#### Webhook Setup:

1. Buat Discord webhook di server Discord Anda
2. Tab **Webhook** → Input webhook URL
3. Configure filters (rarity, names, variants)
4. Enable "Auto Send Webhook"

---

## Important Notes

### Security & Risks:

1. **Ban Risk**: Script ini **AKAN** terdeteksi oleh Roblox anti-cheat jika digunakan ceroboh

   - Avoid: Instant fishing di server ramai
   - Avoid: Trading terlalu cepat
   - Recommendation: Gunakan di private server

2. **Executor Safety**: Beberapa executor bisa mengandung malware

   - Only use trusted executors
   - Never share account credentials

3. **Data Safety**:
   - Script menyimpan position ke file lokal
   - Webhook URL tersimpan di `_G` (global scope)
   - Config tidak persistent (hilang saat rejoin)

### Technical Limitations:

1. **Executor Compatibility**:

   ```lua
   -- Script check executor support:
   _G.httpRequest = syn and syn.request
                    or http and http.request
                    or http_request
                    or fluxus and fluxus.request
                    or request

   if not _G.httpRequest then
       return -- Script stop jika executor tidak support
   end
   ```

2. **Network Latency**:

   - Instant fishing membutuhkan timing yang tepat
   - Lag bisa menyebabkan fishing gagal
   - Recommendation: Gunakan VPN dengan ping rendah

3. **Game Updates**:
   - Jika game update, script mungkin break
   - Remote event names bisa berubah
   - Item IDs bisa berubah

### Best Practices:

1. **Start Small**: Test fitur satu per satu
2. **Use Delays**: Tambahkan delay untuk terlihat lebih human-like
3. **Monitor Console**: Check console untuk errors
4. **Regular Breaks**: Jangan farm 24/7
5. **Multiple Accounts**: Jangan gunakan main account

### Debugging:

Script memiliki built-in debug messages:

```lua
-- Check console untuk messages seperti:
print("[DEBUG Deep Sea Text]...")
print("[AUTO EQUIP] Equipping best rod:...")
chloex("Position saved successfully!") -- Custom notification
```

Enable Roblox Developer Console: `F9` atau `/console`

---

## Glossary

| Term             | Meaning                                    |
| ---------------- | ------------------------------------------ |
| **Executor**     | Program untuk inject/run scripts di Roblox |
| **Remote Event** | Client-Server communication method         |
| **Replion**      | Data replication library (seperti Redux)   |
| **UUID**         | Unique ID untuk items                      |
| **CFrame**       | Coordinate Frame (position + rotation)     |
| **Heartbeat**    | Game loop tick (~60 FPS)                   |
| **pcall**        | Protected call (try-catch di Lua)          |
| **task.wait()**  | Async wait (seperti await sleep())         |
| **FireServer**   | Send event dari client ke server           |
| **InvokeServer** | Send request & wait response               |

---

## Next Steps

Untuk refactoring script ini menjadi modular, lihat file **[CLAUDE.md](./docs/CLAUDE.md)** yang berisi:

- Detailed refactoring roadmap
- Modular architecture design
- Build system setup
- Development workflow

---

**Last Updated**: 2025-11-17
**Script Version**: Based on Chloe X FishIt script
