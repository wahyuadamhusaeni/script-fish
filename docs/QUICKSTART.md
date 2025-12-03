# Quick Start Guide

Panduan cepat untuk mulai menggunakan dan develop script ini.

## 📋 Prerequisites

- **Node.js** (v16 or higher) - [Download here](https://nodejs.org/)
- **Roblox Executor** (Synapse X, Fluxus, dll)
- **Discord Webhook** (optional) - untuk notifikasi

## 🚀 Installation

```bash
# 1. Clone atau download repository
cd roblox-fishit-script

# 2. Install dependencies
npm install
```

## 🎮 Usage (Current Script)

Script yang ada sekarang (`script.lua`) bisa langsung digunakan:

1. Buka Roblox FishIt game
2. Buka executor
3. Paste script ke executor:
   ```lua
   loadstring(game:HttpGet("https://raw.githubusercontent.com/MajestySkie/Chloe-X/main/Main/ChloeX"))()
   ```
4. Execute!

## 🛠️ Development (Modular Version)

Untuk mulai refactoring ke modular structure:

### 1. Create Source Files

```bash
# Create folder structure
mkdir -p src/{core,network,data,features,ui,utils,config}
```

### 2. Extract First Module

**Example**: Extract services (lihat [CLAUDE.md](./CLAUDE.md) Phase 1)

**File**: `src/core/services.lua`
```lua
local Services = {}

Services.Players = game:GetService("Players")
Services.RunService = game:GetService("RunService")
Services.HttpService = game:GetService("HttpService")
-- ... dll

return Services
```

### 3. Create Main Entry Point

**File**: `src/main.lua`
```lua
-- Entry point
local Services = require("src/core/services")

print("[Script] Loaded!")
print("Players service:", Services.Players)
```

### 4. Build Bundle

```bash
# Build single file from modules
npm run build
```

Output: `build/script.lua`

### 5. Test in Roblox

1. Copy content dari `build/script.lua`
2. Paste ke executor
3. Execute & test!

## 📝 Development Workflow

### Auto-rebuild on changes:

```bash
# Watch mode - auto rebuild saat file berubah
npm run dev
```

Ini akan monitor folder `src/` dan auto-rebuild setiap kali ada perubahan.

### Manual build:

```bash
npm run build
```

## 📁 Project Structure

```
roblox-fishit-script/
├── src/                    # Source files (modular)
│   ├── core/              # Core modules
│   ├── features/          # Feature modules
│   ├── ui/                # UI components
│   └── main.lua           # Entry point
│
├── build/                 # Build output
│   └── script.lua         # Final bundled script
│
├── tools/                 # Build tools
│   └── bundler.js         # Bundler script
│
├── script.lua             # Original script (backup)
├── README.md              # Full documentation
├── CLAUDE.md              # Refactoring roadmap
└── package.json           # Node.js config
```

## 🔧 Common Tasks

### Add New Feature Module

1. Create file di `src/features/`:
   ```lua
   -- src/features/my-feature.lua
   local MyFeature = {}

   function MyFeature.doSomething()
       print("Hello!")
   end

   return MyFeature
   ```

2. Use di `src/main.lua`:
   ```lua
   local MyFeature = require("src/features/my-feature")
   MyFeature.doSomething()
   ```

3. Build:
   ```bash
   npm run build
   ```

### Debug Build Issues

Jika build gagal:

1. Check console error
2. Pastikan semua `require()` paths benar
3. Pastikan semua files return module:
   ```lua
   return ModuleName  -- Harus ada di akhir file!
   ```

## 📚 Next Steps

1. ✅ Baca [README.md](./README.md) - Understand script & Lua basics
2. ✅ Baca [CLAUDE.md](./CLAUDE.md) - Detailed refactoring plan
3. ✅ Follow Phase 1 in CLAUDE.md - Start refactoring

## ❓ FAQ

### Q: Kenapa perlu build system?
**A**: Roblox executor hanya bisa execute 1 file. Build system merge multiple files jadi 1.

### Q: Apakah harus refactor sekarang?
**A**: Tidak. Script asli (`script.lua`) sudah bisa digunakan langsung. Refactoring optional untuk maintenance yang lebih baik.

### Q: Bisa pakai tanpa Node.js?
**A**: Bisa! Gunakan `script.lua` langsung tanpa build system. Node.js hanya untuk development modular version.

### Q: Build script error "Module not found"
**A**: Pastikan:
- Path di `require()` benar
- File `.lua` ada
- Module return something: `return ModuleName`

### Q: Hot reload untuk testing?
**A**:
```bash
# Terminal 1: Auto rebuild
npm run dev

# Terminal 2: Manual test di Roblox
# Copy dari build/script.lua setiap rebuild selesai
```

## 🐛 Troubleshooting

### Build Error: "Cannot find module"
```bash
# Make sure Node.js installed
node --version

# Reinstall dependencies
rm -rf node_modules
npm install
```

### Build Error: "Module not found: xyz"
- Check require path di source files
- Pastikan file xyz.lua exists

### Executor Error: "loadstring not supported"
- Ganti executor yang support loadstring
- Try: Synapse X, Fluxus, Script-Ware

## 📞 Support

Issues? Questions?
- Check [README.md](./README.md) - Full documentation
- Check [CLAUDE.md](./CLAUDE.md) - Refactoring guide
- Review console errors untuk debug

---

Happy coding! 🚀
