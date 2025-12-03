-- src/features/trading/auto-trade.lua
-- Automated trading system for FishIt

local Services = require("src/core/services")
local State = require("src/core/state")
local Functions = require("src/network/functions")
local TradeFilters = require("src/features/trading/trade-filters")

local AutoTrade = {}

-- Send single trade with retry mechanism
local function sendTrade(playerName, uuid, itemName, price)
    local trade = State.trade
    local retries = 0
    local maxRetries = 3

    while retries < maxRetries and trade.trading do
        local player = Services.Players:FindFirstChild(playerName)

        if not player then
            trade.trading = false
            warn("[AutoTrade] Player not found:", playerName)
            return false
        end

        -- Send trade request
        local success = pcall(function()
            Functions.Trade:InvokeServer(player.UserId, uuid)
        end)

        if not success then
            retries = retries + 1
            task.wait(1)
        else
            -- Wait for item to disappear from inventory (trade accepted)
            local startTime = tick()
            local traded = false

            while trade.trading and not traded do
                if not TradeFilters.itemExists(uuid) then
                    traded = true

                    -- Update counters
                    if itemName then
                        trade.successCount = trade.successCount + 1
                    else
                        trade.successCoins = trade.successCoins + (price or 0)
                        trade.totalReceived = trade.successCoins
                    end

                    return true
                elseif tick() - startTime > 10 then
                    -- Timeout after 10 seconds
                    break
                end

                task.wait(0.2)
            end

            retries = retries + 1
            task.wait(1)
        end
    end

    return false
end

-- Trade by item name
function AutoTrade.startTradeByName(updateCallback)
    local trade = State.trade

    if trade.trading then
        return
    end

    if not trade.selectedPlayer or not trade.selectedItem then
        warn("[AutoTrade] Select player & item first!")
        if updateCallback then
            updateCallback("<font color='#ff3333'>Select player & item first!</font>")
        end
        return
    end

    trade.trading = true
    trade.successCount = 0

    if updateCallback then
        updateCallback(string.format("Starting trade with %s", trade.selectedPlayer))
    end

    -- Get grouped items
    local itemData = trade.currentGrouped[trade.selectedItem]

    if not itemData then
        trade.trading = false
        if updateCallback then
            updateCallback("<font color='#ff3333'>Item not found</font>")
        end
        return
    end

    trade.totalToTrade = math.min(trade.tradeAmount, #itemData.uuids)

    -- Send trades
    local index = 1
    while trade.trading and trade.successCount < trade.totalToTrade do
        local uuid = itemData.uuids[index]

        if sendTrade(trade.selectedPlayer, uuid, trade.selectedItem) then
            if updateCallback then
                updateCallback(string.format(
                    "Progress: %d / %d",
                    trade.successCount,
                    trade.totalToTrade
                ))
            end
        end

        index = index + 1
        if index > #itemData.uuids then
            index = 1
        end

        task.wait(2)
    end

    trade.trading = false

    if updateCallback then
        updateCallback("<font color='#66ccff'>All trades finished</font>")
    end
end

-- Trade by coin value
function AutoTrade.startTradeByCoin(updateCallback)
    local trade = State.trade

    if trade.trading then
        return
    end

    if not trade.selectedPlayer or trade.targetCoins <= 0 then
        warn("[AutoTrade] Select player & coin target first!")
        if updateCallback then
            updateCallback("<font color='#ff3333'>Select player & coin target first!</font>")
        end
        return
    end

    trade.trading = true
    trade.sentCoins = 0
    trade.successCoins = 0
    trade.totalReceived = 0

    if updateCallback then
        updateCallback("<font color='#ffaa00'>Scanning inventory...</font>")
    end

    -- Get all fish with prices
    local fishes = TradeFilters.getFishForCoins()

    if #fishes == 0 then
        trade.trading = false
        if updateCallback then
            updateCallback("<font color='#ff3333'>No fish available for trading</font>")
        end
        return
    end

    -- Choose fishes by target coin range
    local selectedFish, totalValue = TradeFilters.chooseFishesByRange(fishes, trade.targetCoins)

    if #selectedFish == 0 then
        trade.trading = false
        if updateCallback then
            updateCallback("<font color='#ff3333'>No valid fishes for target</font>")
        end
        return
    end

    trade.totalToTrade = #selectedFish
    trade.targetCoins = totalValue

    if updateCallback then
        updateCallback(string.format(
            "Trading %d fish (Total: %d coins)",
            trade.totalToTrade,
            trade.targetCoins
        ))
    end

    -- Send trades
    for _, fish in ipairs(selectedFish) do
        if not trade.trading then
            break
        end

        trade.sentCoins = trade.sentCoins + fish.Price

        if updateCallback then
            updateCallback(string.format(
                "<font color='#ffaa00'>Progress: %d / %d</font>",
                trade.sentCoins,
                trade.targetCoins
            ))
        end

        sendTrade(trade.selectedPlayer, fish.UUID, nil, fish.Price)

        task.wait(2)
    end

    trade.trading = false

    if updateCallback then
        updateCallback(string.format(
            "<font color='#66ccff'>Coin trade finished (Target: %d, Received: %d)</font>",
            trade.targetCoins,
            trade.successCoins
        ))
    end
end

-- Trade by rarity
function AutoTrade.startTradeByRarity(updateCallback)
    local trade = State.trade

    if trade.trading then
        return
    end

    if not trade.selectedPlayer or not trade.selectedRarity then
        warn("[AutoTrade] Select player & rarity first!")
        if updateCallback then
            updateCallback("<font color='#ff3333'>Select player & rarity first!</font>")
        end
        return
    end

    trade.trading = true
    trade.successCount = 0

    if updateCallback then
        updateCallback(string.format(
            "<font color='#ffaa00'>Scanning %s fishes...</font>",
            trade.selectedRarity
        ))
    end

    -- Get fish by rarity
    local fishes = TradeFilters.getFishByRarity(trade.selectedRarity)

    if #fishes == 0 then
        trade.trading = false
        if updateCallback then
            updateCallback(string.format(
                "<font color='#ff3333'>No %s fishes found</font>",
                trade.selectedRarity
            ))
        end
        return
    end

    trade.totalToTrade = math.min(#fishes, trade.rarityAmount or #fishes)

    if updateCallback then
        updateCallback(string.format(
            "Sending %d %s fishes...",
            trade.totalToTrade,
            trade.selectedRarity
        ))
    end

    -- Send trades
    local index = 1
    while trade.trading and index <= trade.totalToTrade do
        local fish = fishes[index]

        if sendTrade(trade.selectedPlayer, fish.UUID, fish.Name) then
            if updateCallback then
                updateCallback(string.format(
                    "Progress: %d / %d (%s)",
                    trade.successCount,
                    trade.totalToTrade,
                    trade.selectedRarity
                ))
            end
        end

        index = index + 1
        task.wait(2.5)
    end

    trade.trading = false

    if updateCallback then
        updateCallback("<font color='#66ccff'>Rarity trade finished</font>")
    end
end

-- Stop all trading
function AutoTrade.stop()
    State.trade.trading = false
end

-- Get list of other players
function AutoTrade.getPlayerList()
    local players = {}

    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= Services.Players.LocalPlayer then
            table.insert(players, player.Name)
        end
    end

    return players
end

return AutoTrade
