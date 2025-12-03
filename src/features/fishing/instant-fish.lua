--[[
    Instant Fishing Module

    Automatically catches fish without minigame interaction.
    Uses the fishing sequence: Charge → Start → Wait → Complete

    Usage:
        local InstantFish = require("src/features/fishing/instant-fish")
        InstantFish.start()
]]

local State = require("src/core/state")
local Services = require("src/core/services")
local Events = require("src/network/events")
local Functions = require("src/network/functions")

local InstantFish = {}

-- Private variables
local isRunning = false

--[[
    Get current fish count from inventory UI
    @return number - Current fish count
]]
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

--[[
    Execute one fishing cycle
    @return boolean - Success status
]]
local function executeFishingCycle()
    if not State.canFish then
        return false
    end

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
        until (_G.FishMiniData and _G.FishMiniData.LastShift) or (tick() - startTime > 1)

        -- Apply custom delay if set
        task.wait(_G.DelayComplete or 0)

        -- Step 4: Complete fishing
        pcall(function()
            Events.REFishDone:FireServer()
        end)

        -- Step 5: Wait for fish to be added to inventory
        local oldCount = InstantFish.getFishCount()
        local waitStart = tick()
        repeat
            task.wait(0.05)
        until oldCount < InstantFish.getFishCount() or (tick() - waitStart > 1)
    end

    State.canFish = true
    return true
end

--[[
    Start instant fishing loop
]]
function InstantFish.start()
    if isRunning then
        return
    end

    isRunning = true
    State.autoInstant = true

    -- Update counter
    _G.Celestial.InstantCount = InstantFish.getFishCount()

    task.spawn(function()
        while State.autoInstant and isRunning do
            local success = executeFishingCycle()

            if not success then
                task.wait(0.1)
            end

            task.wait(0.05)
        end
    end)
end

--[[
    Stop instant fishing
]]
function InstantFish.stop()
    State.autoInstant = false
    isRunning = false
end

--[[
    Check if instant fishing is running
    @return boolean
]]
function InstantFish.isRunning()
    return isRunning
end

return InstantFish
