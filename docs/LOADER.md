# 🚀 Script Loader Guide

## Cara Menggunakan Script dari GitHub Anda

Repository Anda: `https://github.com/zildjianvitoo/script-fishit`

---

## Option 1: Script Original (6160 baris) - RECOMMENDED

Script original yang sudah working dan siap pakai.

### Copy-paste ini ke Roblox Executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/zildjianvitoo/script-fishit/main/script.lua"))()
```

**Keuntungan:**
- ✅ Langsung jalan, no build required
- ✅ Semua fitur lengkap
- ✅ Tested & stable

**Kekurangan:**
- ⚠️ Hard to maintain (1 file besar)
- ⚠️ Sulit di-customize

---

## Option 2: Modular Version (Demo) - FOR DEVELOPMENT

Version modular yang sudah di-bundle. **Note:** Ini masih demo, hanya punya 2 modules.

### Copy-paste ini ke Roblox Executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/zildjianvitoo/script-fishit/main/build/script.lua"))()
```

**Keuntungan:**
- ✅ Modular structure (easy to maintain)
- ✅ Build system ready

**Kekurangan:**
- ⚠️ Belum complete (baru demo modules)
- ⚠️ Perlu refactoring lebih lanjut

**Yang akan muncul:**
- Info script loaded
- Player name
- Services loaded status
- Guide untuk next steps

---

## 🔄 Update Script

Setelah Anda edit & push update ke GitHub:

### Update Original Script:

```bash
# Edit script.lua
# Commit & push
git add script.lua
git commit -m "Update script features"
git push origin main
```

User **TIDAK PERLU** ganti URL, script otomatis updated!

### Update Modular Version:

```bash
# Edit src files
# Build
npm run build

# Commit & push
git add build/script.lua
git commit -m "Update bundled script"
git push origin main
```

User **TIDAK PERLU** ganti URL, script otomatis updated!

---

## 📱 Short URL (Optional)

Buat short URL supaya lebih gampang:

### Menggunakan Pastebin:

1. Copy isi file `script.lua` atau `build/script.lua`
2. Paste ke [pastebin.com](https://pastebin.com)
3. Get raw URL
4. Share ke user:

```lua
loadstring(game:HttpGet("https://pastebin.com/raw/YOUR_PASTE_ID"))()
```

### Menggunakan GitHub Gist:

1. Buat [GitHub Gist](https://gist.github.com)
2. Upload file
3. Get raw URL
4. Share:

```lua
loadstring(game:HttpGet("https://gist.githubusercontent.com/YOUR_USERNAME/YOUR_GIST_ID/raw/script.lua"))()
```

---

## 🔐 Private Script

Jika ingin script private (hanya untuk user tertentu):

### Option 1: Private Repository

```bash
# Set repo jadi private di GitHub settings
# Share access ke user tertentu
```

**Kekurangan:** User perlu GitHub account & access

### Option 2: Whitelist System

Tambahkan whitelist di script:

```lua
-- Di awal script:
local whitelist = {
    "Username1",
    "Username2",
    "Username3"
}

local player = game.Players.LocalPlayer

if not table.find(whitelist, player.Name) then
    player:Kick("Not whitelisted!")
    return
end

-- Rest of script...
```

### Option 3: Key System

Implementasi key system untuk akses:

```lua
local validKeys = {
    ["KEY123"] = true,
    ["KEY456"] = true
}

-- Prompt user untuk key
local key = -- get from UI input

if not validKeys[key] then
    player:Kick("Invalid key!")
    return
end
```

---

## 📊 Monitoring Usage

Track berapa banyak yang pakai script:

```lua
-- Tambahkan di script:
local webhook = "YOUR_DISCORD_WEBHOOK"

game:GetService("HttpService"):RequestAsync({
    Url = webhook,
    Method = "POST",
    Headers = {["Content-Type"] = "application/json"},
    Body = game:GetService("HttpService"):JSONEncode({
        content = string.format("User: %s | ID: %d | Game: %s",
            game.Players.LocalPlayer.Name,
            game.Players.LocalPlayer.UserId,
            game.PlaceId
        )
    })
})
```

---

## ⚡ Performance Tips

### Cache URL (Faster Loading)

```lua
-- User bisa save script locally:
local scriptUrl = "https://raw.githubusercontent.com/zildjianvitoo/script-fishit/main/script.lua"
local scriptCache = "fishit_cache.txt"

-- Check cache first
if isfile(scriptCache) then
    local cachedScript = readfile(scriptCache)
    loadstring(cachedScript)()
else
    local script = game:HttpGet(scriptUrl)
    writefile(scriptCache, script)
    loadstring(script)()
end
```

### Auto-update with Cache:

```lua
local scriptUrl = "https://raw.githubusercontent.com/zildjianvitoo/script-fishit/main/script.lua"
local versionUrl = "https://raw.githubusercontent.com/zildjianvitoo/script-fishit/main/VERSION.txt"
local scriptCache = "fishit_cache.txt"
local versionCache = "fishit_version.txt"

-- Check version
local remoteVersion = game:HttpGet(versionUrl)
local localVersion = isfile(versionCache) and readfile(versionCache) or "0"

if remoteVersion ~= localVersion then
    print("Updating script...")
    local script = game:HttpGet(scriptUrl)
    writefile(scriptCache, script)
    writefile(versionCache, remoteVersion)
end

loadstring(readfile(scriptCache))()
```

---

## 🐛 Troubleshooting

### Error: "HttpService is not allowed"

**Solution:** Executor tidak support HTTP requests. Ganti executor.

### Error: "Script not found" (404)

**Solution:**
- Check URL benar
- Pastikan file sudah di-push ke GitHub
- Pastikan branch name benar (main/master)

### Error: "loadstring is not available"

**Solution:** Executor tidak support loadstring. Ganti executor.

### Script tidak update

**Solution:**
- Clear cache executor
- Restart Roblox
- Wait 5-10 minutes (GitHub CDN cache)

---

## 📞 Support

Jika ada masalah:

1. Check dokumentasi:
   - [README.md](README.md) - Full guide
   - [QUICKSTART.md](QUICKSTART.md) - Quick start
   - [CLAUDE.md](CLAUDE.md) - Development guide

2. Check GitHub Issues:
   - https://github.com/zildjianvitoo/script-fishit/issues

3. Create new issue dengan info:
   - Executor yang dipakai
   - Error message
   - Steps to reproduce

---

## 🎉 Quick Reference

### Main URLs:

**Original Script:**
```
https://raw.githubusercontent.com/zildjianvitoo/script-fishit/main/script.lua
```

**Modular Demo:**
```
https://raw.githubusercontent.com/zildjianvitoo/script-fishit/main/build/script.lua
```

### Loader Code:

**Original:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/zildjianvitoo/script-fishit/main/script.lua"))()
```

**Modular:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/zildjianvitoo/script-fishit/main/build/script.lua"))()
```

---

Happy scripting! 🚀
