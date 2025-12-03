--[[
    Auto Sell Module

    Automatically sells fish based on mode:
    - Delay: Sell every X seconds
    - Count: Sell when fish count reaches X

    Usage:
        local AutoSell = require("src/features/selling/auto-sell")
        AutoSell.start()
]]

local State = require("src/core/state")
local Services = require("src/core/services")

local AutoSell = {}

-- Private variables
local isRunning = false
local SellAllItemsFunction = nil

--[[
    Initialize sell function
]]
local function initialize()
    if not SellAllItemsFunction then
        SellAllItemsFunction = Services.Net["RF/SellAllItems"]
    end
end

--[[
    Get current fish count from UI
    @return number - Current count
    @return number - Max capacity
]]
function AutoSell.getFishCount()
    local bagSizeLabel = State.player.PlayerGui
        :WaitForChild("Inventory")
        .Main.Top.Options.Fish.Label
        :FindFirstChild("BagSize")

    local current = 0
    local max = 0

    if bagSizeLabel and bagSizeLabel:IsA("TextLabel") then
        local currentStr, maxStr = (bagSizeLabel.Text or ""):match("(%d+)%s*/%s*(%d+)")
        current = tonumber(currentStr) or 0
        max = tonumber(maxStr) or 0
    end

    return current, max
end

--[[
    Execute sell all items
    @return boolean - Success status
]]
local function sellAllItems()
    initialize()

    if not SellAllItemsFunction then
        warn("[AutoSell] Sell function not available")
        return false
    end

    local success = pcall(function()
        SellAllItemsFunction:InvokeServer()
    end)

    return success
end

--[[
    Auto sell loop based on mode
]]
local function autoSellLoop()
    while State.autoSellEnabled and isRunning do
        local current, max = AutoSell.getFishCount()

        if State.sellMode == "Delay" then
            -- Sell by delay mode
            sellAllItems()
            task.wait(State.sellDelay)

        elseif State.sellMode == "Count" then
            -- Sell by count mode
            local threshold = tonumber(State.inputSellCount) or max

            if threshold <= current then
                sellAllItems()
                task.wait(0.5)
            else
                task.wait(1)
            end
        end
    end
end

--[[
    Start auto sell
]]
function AutoSell.start()
    if isRunning then
        return
    end

    isRunning = true
    State.autoSellEnabled = true

    task.spawn(autoSellLoop)
end

--[[
    Stop auto sell
]]
function AutoSell.stop()
    State.autoSellEnabled = false
    isRunning = false
end

--[[
    Set sell mode
    @param mode string - "Delay" or "Count"
]]
function AutoSell.setMode(mode)
    if mode == "Delay" or mode == "Count" then
        State.sellMode = mode
    else
        warn("[AutoSell] Invalid mode: " .. tostring(mode))
    end
end

--[[
    Set sell delay (for Delay mode)
    @param seconds number - Delay in seconds
]]
function AutoSell.setDelay(seconds)
    State.sellDelay = math.max(1, tonumber(seconds) or 60)
end

--[[
    Set sell count threshold (for Count mode)
    @param count number - Fish count threshold
]]
function AutoSell.setCount(count)
    State.inputSellCount = math.max(1, tonumber(count) or 50)
end

--[[
    Check if auto sell is running
    @return boolean
]]
function AutoSell.isRunning()
    return isRunning
end

return AutoSell
