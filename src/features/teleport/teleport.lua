--[[
    Teleport Module

    Handles character teleportation and position save/load.

    Usage:
        local Teleport = require("src/features/teleport/teleport")
        Teleport.toLocation("Treasure Room")
        Teleport.savePosition()
]]

local State = require("src/core/state")
local Services = require("src/core/services")
local Locations = require("src/config/locations")
local PlayerUtils = require("src/utils/player-utils")

local Teleport = {}

-- Position save file (completely separate from old script)
local SAVE_FILE = "ZiviHub/SavedPosition_ZIVIHUB.json"

--[[
    Get location names (sorted alphabetically)
    @return table - Array of location names
]]
function Teleport.getLocationNames()
    local names = {}

    for name in pairs(Locations) do
        table.insert(names, name)
    end

    table.sort(names, function(a, b)
        return a:lower() < b:lower()
    end)

    return names
end

--[[
    Get location position
    @param locationName string - Name of location
    @return Vector3 - Position or nil if not found
]]
function Teleport.getLocation(locationName)
    return Locations[locationName]
end

--[[
    Teleport to location by name
    @param locationName string - Name of location
    @return boolean - Success status
]]
function Teleport.toLocation(locationName)
    local position = Locations[locationName]

    if not position then
        warn("[Teleport] Location not found: " .. tostring(locationName))
        return false
    end

    local character = State.player.Character
    if not character then
        warn("[Teleport] Character not found")
        return false
    end

    PlayerUtils.teleport(character, position)
    return true
end

--[[
    Teleport to position
    @param position Vector3 - Target position
    @return boolean - Success status
]]
function Teleport.toPosition(position)
    local character = State.player.Character
    if not character then
        warn("[Teleport] Character not found")
        return false
    end

    PlayerUtils.teleport(character, position)
    return true
end

--[[
    Teleport to CFrame
    @param cframe CFrame - Target CFrame
    @return boolean - Success status
]]
function Teleport.toCFrame(cframe)
    local character = State.player.Character
    if not character then
        warn("[Teleport] Character not found")
        return false
    end

    local hrp = PlayerUtils.getHumanoidRootPart(character)
    if hrp then
        hrp.CFrame = cframe
        return true
    end

    return false
end

--[[
    Save current position to file
    @return boolean - Success status
]]
function Teleport.savePosition()
    local character = State.player.Character
    if not character then
        warn("[Teleport] Character not found")
        return false
    end

    local hrp = PlayerUtils.getHumanoidRootPart(character)
    if not hrp then
        warn("[Teleport] HumanoidRootPart not found")
        return false
    end

    -- Save CFrame components
    local components = { hrp.CFrame:GetComponents() }

    local success = pcall(function()
        writefile(SAVE_FILE, Services.HttpService:JSONEncode(components))
    end)

    if success then
        State.savedCFrame = hrp.CFrame
    end

    return success
end

--[[
    Load saved position from file
    @return CFrame - Saved CFrame or nil
]]
function Teleport.loadPosition()
    if not isfile(SAVE_FILE) then
        return nil
    end

    local success, result = pcall(function()
        local data = Services.HttpService:JSONDecode(readfile(SAVE_FILE))
        return CFrame.new(unpack(data))
    end)

    if success and typeof(result) == "CFrame" then
        return result
    end

    return nil
end

--[[
    Teleport to saved position
    @return boolean - Success status
]]
function Teleport.toSavedPosition()
    local savedCFrame = Teleport.loadPosition()

    if not savedCFrame then
        warn("[Teleport] No saved position found")
        return false
    end

    return Teleport.toCFrame(savedCFrame)
end

--[[
    Clear saved position
]]
function Teleport.clearSavedPosition()
    if isfile(SAVE_FILE) then
        pcall(delfile, SAVE_FILE)
    end

    State.savedCFrame = nil
end

--[[
    Auto teleport to last position on character added
]]
function Teleport.setupAutoTeleport()
    State.player.CharacterAdded:Connect(function(character)
        task.spawn(function()
            character:WaitForChild("HumanoidRootPart", 5)
            local savedCFrame = Teleport.loadPosition()

            if savedCFrame then
                task.wait(2) -- Wait for character to fully load
                Teleport.toCFrame(savedCFrame)
                print("[Teleport] Auto teleported to saved position")
            end
        end)
    end)

    -- Also teleport on initial load
    if State.player.Character then
        task.spawn(function()
            local savedCFrame = Teleport.loadPosition()
            if savedCFrame then
                task.wait(2)
                Teleport.toCFrame(savedCFrame)
                print("[Teleport] Teleported to saved position")
            end
        end)
    end
end

return Teleport
