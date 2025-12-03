--[[
    Player Utilities Module

    Helper functions for player operations.

    Usage:
        local PlayerUtils = require("src/utils/player-utils")
        PlayerUtils.teleport(character, Vector3.new(0, 10, 0))
]]

local Services = require("src/core/services")

local PlayerUtils = {}

--[[
    Get HumanoidRootPart from character
    @param character Model - Character model
    @return BasePart - HumanoidRootPart or first BasePart
]]
function PlayerUtils.getHumanoidRootPart(character)
    return character and (
        character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChildWhichIsA("BasePart")
    )
end

--[[
    Teleport character to position
    @param character Model - Character to teleport
    @param position Vector3 - Target position
]]
function PlayerUtils.teleport(character, position)
    local hrp = PlayerUtils.getHumanoidRootPart(character)
    if hrp then
        hrp.CFrame = CFrame.new(position)
    end
end

--[[
    Set all parts in character to anchored
    @param character Model - Character model
    @param anchored boolean - Anchored state
]]
function PlayerUtils.setAnchored(character, anchored)
    if not character then return end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = anchored
        end
    end
end

--[[
    Get list of player names (excluding self)
    @param excludeSelf boolean - Whether to exclude local player
    @return table - Array of player names
]]
function PlayerUtils.getPlayers(excludeSelf)
    local players = {}

    for _, player in ipairs(Services.Players:GetPlayers()) do
        if not excludeSelf or player ~= Services.LocalPlayer then
            table.insert(players, player.Name)
        end
    end

    return players
end

--[[
    Create floating platform under character (for anti-fall)
    @param character Model - Character model
    @param hrp BasePart - HumanoidRootPart
    @param enabled boolean - Enable/disable floating
    @return Part - The floating part (if enabled)
    @return RBXScriptConnection - Heartbeat connection (if enabled)
]]
function PlayerUtils.createFloatPart(character, hrp, enabled)
    if not enabled then
        local floatPart = character:FindFirstChild("FloatPart")
        if floatPart then
            floatPart:Destroy()
        end
        return nil, nil
    end

    local floatPart = character:FindFirstChild("FloatPart") or Instance.new("Part")
    floatPart.Name = "FloatPart"
    floatPart.Size = Vector3.new(3, 0.2, 3)
    floatPart.Transparency = 1
    floatPart.Anchored = true
    floatPart.CanCollide = true
    floatPart.Parent = character

    local connection = Services.RunService.Heartbeat:Connect(function()
        if character and hrp and floatPart then
            floatPart.CFrame = hrp.CFrame * CFrame.new(0, -3.1, 0)
        end
    end)

    return floatPart, connection
end

return PlayerUtils
