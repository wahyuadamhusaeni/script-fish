--[[
    Legit Fishing Module

    Implements legit fishing with game mechanics compliance.
    Two modes: Always Perfect and Normal.

    Dependencies:
    - src/core/services
    - src/core/state
    - src/network/events
]]

local Services = require("src/core/services")
local State = require("src/core/state")
local Events = require("src/network/events")

local LegitFish = {}

-- Initialize state
State.legitFishing = false
State.shakeDelay = 0
State.autoShake = false
State.legitMode = "Always Perfect" -- "Always Perfect" or "Normal"

-- Get player user ID
local userId = tostring(Services.LocalPlayer.UserId)

-- Get cosmetic folder for bobber detection
local cosmeticFolder = nil
pcall(function()
    cosmeticFolder = workspace:FindFirstChild("CosmeticFolder")
end)

-- Try cast function (charges rod and releases)
local function tryCast()
    local PlayerGui = Services.PlayerGui
    local Camera = Services.Camera
    local VIM = Services.VIM
    local LocalPlayer = Services.LocalPlayer
    local FishingController = Services.FishingController

    if not FishingController then
        warn("[Legit Fish] FishingController not found")
        return
    end

    -- Center of screen
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local lastGUID = nil

    while FishingController._autoLoop do
        -- If already fishing, wait
        if FishingController:GetCurrentGUID() then
            task.wait(0.05)
        else
            -- Click to start charging
            VIM:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
            task.wait(0.05)

            -- Wait for charge bar to appear and reach ~95%
            local chargeSuccess, chargeBar = pcall(function()
                return PlayerGui:WaitForChild("Charge", 1)
                    :WaitForChild("Main")
                    :WaitForChild("CanvasGroup")
                    :WaitForChild("Bar")
            end)

            if chargeSuccess and chargeBar then
                local startTime = tick()
                while chargeBar:IsDescendantOf(PlayerGui) and chargeBar.Size.Y.Scale < 0.95 do
                    task.wait(0.001)
                    if tick() - startTime > 1 then
                        break
                    end
                end
            end

            -- Release click to cast
            VIM:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)

            -- Wait for shake detection (GUID appears)
            local waitStart = tick()
            local shakeDetected = false
            while tick() - waitStart < 3 do
                local currentGUID = FishingController:GetCurrentGUID()
                if currentGUID and currentGUID ~= lastGUID then
                    shakeDetected = true
                    print("[Legit Fish] Shake detected! GUID:", currentGUID)
                    lastGUID = currentGUID
                    break
                else
                    task.wait(0.05)
                end
            end

            -- If shake detected, wait for catch completion
            if shakeDetected then
                local oldCaught = LocalPlayer.leaderstats and LocalPlayer.leaderstats.Caught.Value or 0
                local catchStart = tick()

                -- Wait for caught count to increase or timeout
                while tick() - catchStart < 8
                    and (not LocalPlayer.leaderstats or oldCaught >= LocalPlayer.leaderstats.Caught.Value)
                    and FishingController:GetCurrentGUID() do
                    task.wait(0.1)
                end

                -- Wait for GUID to clear
                while FishingController:GetCurrentGUID() do
                    task.wait(0.05)
                end

                task.wait(1.3) -- Cooldown before next cast
            end
        end

        task.wait(0.05)
    end
end

-- Always Perfect Mode
local function startAlwaysPerfectMode()
    local FishingController = Services.FishingController
    if not FishingController or not cosmeticFolder then
        warn("[Legit Fish] Missing FishingController or CosmeticFolder")
        return
    end

    task.spawn(function()
        local completed = false

        while State.legitFishing and FishingController._autoLoop do
            -- Wait for bobber to appear
            if not cosmeticFolder:FindFirstChild(userId) then
                repeat
                    tryCast()
                    task.wait(0.1)
                until cosmeticFolder:FindFirstChild(userId) or not FishingController._autoLoop
            end

            -- While bobber exists (fishing in progress)
            while cosmeticFolder:FindFirstChild(userId) and FishingController._autoLoop do
                -- If minigame active (GUID exists)
                if FishingController:GetCurrentGUID() then
                    local startTime = tick()

                    -- Spam click minigame
                    while FishingController:GetCurrentGUID() and FishingController._autoLoop do
                        pcall(function()
                            FishingController:RequestFishingMinigameClick()
                        end)

                        -- Check if delay reached
                        if tick() - startTime >= (_G.Delay or 0) then
                            task.wait(_G.Delay or 0)

                            -- Complete fishing
                            repeat
                                pcall(function()
                                    Events.REFishDone:FireServer()
                                end)
                                task.wait(0.05)
                                completed = not FishingController:GetCurrentGUID() or not FishingController._autoLoop
                            until completed
                        else
                            task.wait()
                        end

                        if completed then
                            break
                        end
                    end
                end

                completed = false
                task.wait(0.2)
            end

            -- Wait for bobber to disappear
            repeat
                task.wait(0.1)
            until not cosmeticFolder:FindFirstChild(userId) or not FishingController._autoLoop

            -- Recast
            if FishingController._autoLoop then
                task.wait(0.2)
                tryCast()
            end

            task.wait(0.2)
        end
    end)
end

-- Normal Mode
local function startNormalMode()
    local FishingController = Services.FishingController
    if not FishingController then
        warn("[Legit Fish] FishingController not found")
        return
    end

    -- Override power to always return max
    if not FishingController._oldGetPower then
        FishingController._oldGetPower = FishingController._getPower
    end
    FishingController._getPower = function()
        return 0.999
    end

    task.spawn(function()
        while State.legitFishing and FishingController._autoLoop do
            -- If shake enabled and minigame active
            if _G.ShakeEnabled and FishingController:GetCurrentGUID() then
                local startTime = tick()

                while FishingController:GetCurrentGUID()
                    and FishingController._autoLoop
                    and _G.ShakeEnabled do

                    -- Spam click
                    pcall(function()
                        FishingController:RequestFishingMinigameClick()
                    end)

                    -- Check delay
                    if tick() - startTime >= (_G.Delay or 1) then
                        pcall(function()
                            Events.REFishDone:FireServer()
                        end)
                        task.wait(0.1)

                        if not FishingController:GetCurrentGUID()
                            or not FishingController._autoLoop
                            or not _G.ShakeEnabled then
                            break
                        end
                    end

                    task.wait(0.1)
                end

            -- If not fishing, auto cast
            elseif not FishingController:GetCurrentGUID() then
                local center = Vector2.new(
                    Services.Camera.ViewportSize.X / 2,
                    Services.Camera.ViewportSize.Y / 2
                )

                pcall(function()
                    FishingController:RequestChargeFishingRod(center, true)
                end)

                task.wait(0.25)
            end

            task.wait(0.05)
        end
    end)
end

-- Start legit fishing
function LegitFish.start()
    if State.legitFishing then
        return
    end

    local FishingController = Services.FishingController
    if not FishingController then
        warn("[Legit Fish] FishingController not available")
        return false
    end

    State.legitFishing = true
    FishingController._autoLoop = true

    -- Start appropriate mode
    if State.legitMode == "Always Perfect" then
        print("[Legit Fish] Starting Always Perfect mode")
        startAlwaysPerfectMode()
    elseif State.legitMode == "Normal" then
        print("[Legit Fish] Starting Normal mode")
        startNormalMode()
    end

    return true
end

-- Stop legit fishing
function LegitFish.stop()
    State.legitFishing = false

    local FishingController = Services.FishingController
    if FishingController then
        FishingController._autoLoop = false

        -- Restore original power function
        if FishingController._oldGetPower then
            FishingController._getPower = FishingController._oldGetPower
            FishingController._oldGetPower = nil
        end
    end

    print("[Legit Fish] Legit fishing stopped")
end

-- Set legit mode
function LegitFish.setMode(mode)
    if mode == "Always Perfect" or mode == "Normal" then
        State.legitMode = mode
        print("[Legit Fish] Mode set to:", mode)
        return true
    end
    return false
end

-- Start auto shake (independent feature)
function LegitFish.startAutoShake()
    if State.autoShake then
        return
    end

    State.autoShake = true

    -- Disable click effect GUI
    local clickEffect = Services.PlayerGui:FindFirstChild("!!! Click Effect")
    if clickEffect then
        clickEffect.Enabled = false
    end

    task.spawn(function()
        while State.autoShake do
            pcall(function()
                if Services.FishingController then
                    Services.FishingController:RequestFishingMinigameClick()
                end
            end)
            task.wait(State.shakeDelay)
        end

        -- Re-enable click effect when stopped
        if clickEffect then
            clickEffect.Enabled = true
        end
    end)

    print("[Legit Fish] Auto shake started (delay:", State.shakeDelay, ")")
end

-- Stop auto shake
function LegitFish.stopAutoShake()
    State.autoShake = false

    -- Re-enable click effect
    local clickEffect = Services.PlayerGui:FindFirstChild("!!! Click Effect")
    if clickEffect then
        clickEffect.Enabled = true
    end

    print("[Legit Fish] Auto shake stopped")
end

-- Set shake delay
function LegitFish.setShakeDelay(delay)
    local delayNum = tonumber(delay)
    if delayNum and delayNum >= 0 then
        State.shakeDelay = delayNum
        print("[Legit Fish] Shake delay set to:", delayNum)
        return true
    end
    return false
end

return LegitFish
