-- src/features/fishing/blatant-fish.lua
-- Blatant fishing (aggressive, obvious method)

local Services = require("src/core/services")
local State = require("src/core/state")
local Functions = require("src/network/functions")
local Events = require("src/network/events")

local BlatantFish = {}

-- Blatant fishing state
State.blatantFishing = false
State.blatantMode = "Fast" -- "Fast" or "Random Result"
State.reelDelay = 0.5 -- Delay between catches

-- Fast mode: Fastest possible fishing
local function fishFast()
    task.spawn(function()
        -- Cancel any ongoing fishing
        pcall(function()
            Functions.Cancel:InvokeServer()
        end)

        -- Get server time and charge rod
        local serverTime = workspace:GetServerTimeNow()
        pcall(function()
            Functions.ChargeRod:InvokeServer(serverTime)
        end)

        -- Start minigame with max power
        pcall(function()
            Functions.StartMini:InvokeServer(-1, 0.999)
        end)

        -- Wait fishing delay
        task.wait(_G.FishingDelay or 0.1)

        -- Complete fishing
        pcall(function()
            Events.REFishDone:FireServer()
        end)
    end)
end

-- Random Result mode: Fishing with slight delay variation
local function fishRandomResult()
    task.spawn(function()
        -- Cancel any ongoing fishing
        pcall(function()
            Functions.Cancel:InvokeServer()
        end)

        -- Get server time and charge rod
        local serverTime = workspace:GetServerTimeNow()
        pcall(function()
            Functions.ChargeRod:InvokeServer(serverTime)
        end)

        -- Wait a bit before starting (makes it less obvious)
        task.wait(0.2)

        -- Start minigame with max power
        pcall(function()
            Functions.StartMini:InvokeServer(-1, 0.999)
        end)

        -- Wait fishing delay
        task.wait(_G.FishingDelay or 0.1)

        -- Complete fishing
        pcall(function()
            Events.REFishDone:FireServer()
        end)
    end)
end

-- Start blatant fishing
function BlatantFish.start()
    if State.blatantFishing then
        return
    end

    State.blatantFishing = true

    task.spawn(function()
        while State.blatantFishing do
            if State.blatantMode == "Fast" then
                fishFast()
            elseif State.blatantMode == "Random Result" then
                fishRandomResult()
            end

            task.wait(State.reelDelay)
        end
    end)

    print("[Blatant Fish] Blatant fishing started (mode:", State.blatantMode, ")")
end

-- Stop blatant fishing
function BlatantFish.stop()
    State.blatantFishing = false
    print("[Blatant Fish] Blatant fishing stopped")
end

-- Set blatant mode
function BlatantFish.setMode(mode)
    if mode == "Fast" or mode == "Random Result" then
        State.blatantMode = mode
        print("[Blatant Fish] Mode set to:", mode)
        return true
    end
    return false
end

-- Set reel delay
function BlatantFish.setReelDelay(delay)
    local delayNum = tonumber(delay)
    if delayNum and delayNum >= 0 then
        State.reelDelay = delayNum
        print("[Blatant Fish] Reel delay set to:", delayNum)
        return true
    end
    return false
end

-- Recovery fishing (cancel stuck fishing)
function BlatantFish.recovery()
    pcall(function()
        Functions.Cancel:InvokeServer()
    end)
    print("[Blatant Fish] Recovery executed")
end

return BlatantFish
