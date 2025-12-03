-- src/ui/tabs/trade-tab.lua
-- Trading UI tab with Discord dark theme

local Services = require("src/core/services")
local State = require("src/core/state")
local AutoTrade = require("src/features/trading/auto-trade")
local TradeFilters = require("src/features/trading/trade-filters")

local TradeTab = {}

-- Global reference for monitor paragraphs
local NameMonitor, CoinMonitor, RarityMonitor

function TradeTab.setup(tab)
    -- ========================================
    -- TRADE BY NAME SECTION
    -- ========================================
    local tradeByName = tab:AddSection("Trade by Name")

    NameMonitor = tradeByName:AddParagraph({
        Title = "Trade by Name Panel",
        Content =
        "\n<font color='rgb(173,216,230)'>Player : ???</font>\n<font color='rgb(173,216,230)'>Item   : ???</font>\n<font color='rgb(173,216,230)'>Amount : 0</font>\n<font color='rgb(200,200,200)'>Status : Idle</font>\n<font color='rgb(173,216,230)'>Success: 0 / 0</font>\n"
    })

    local function updateNameMonitor(status)
        local trade = State.trade
        local color = "200,200,200"

        if status and status:lower():find("send") then
            color = "51,153,255"
        elseif status and status:lower():find("complete") or status:lower():find("finish") then
            color = "0,204,102"
        elseif status and status:lower():find("time") or status:lower():find("error") then
            color = "255,69,0"
        end

        local content = string.format(
            "\n<font color='rgb(173,216,230)'>Player : %s</font>\n<font color='rgb(173,216,230)'>Item   : %s</font>\n<font color='rgb(173,216,230)'>Amount : %d</font>\n<font color='rgb(%s)'>Status : %s</font>\n<font color='rgb(173,216,230)'>Success: %d / %d</font>\n",
            trade.selectedPlayer or "???",
            trade.selectedItem or "???",
            trade.tradeAmount or 0,
            color,
            status or "Idle",
            trade.successCount or 0,
            trade.totalToTrade or 0
        )

        _G.safeSetContent(NameMonitor, content)
    end

    local itemDropdown = tradeByName:AddDropdown({
        Options = {},
        Multi = false,
        Title = "Select Item",
        Callback = function(value)
            State.trade.selectedItem = value and (value:match("^(.-) x") or value)
            updateNameMonitor("Item selected")
        end
    })

    tradeByName:AddButton({
        Title = "Refresh Fish",
        Callback = function()
            local grouped, options = TradeFilters.getGroupedByType("Fish")
            State.trade.currentGrouped = grouped
            itemDropdown:SetValues(options or {})
            updateNameMonitor("Fish list refreshed")
        end,
        SubTitle = "Refresh Stone",
        SubCallback = function()
            local grouped, options = TradeFilters.getGroupedByType("Enchant Stones")
            State.trade.currentGrouped = grouped
            itemDropdown:SetValues(options or {})
            updateNameMonitor("Stone list refreshed")
        end
    })

    tradeByName:AddInput({
        Title = "Amount to Trade",
        Default = "1",
        Callback = function(value)
            State.trade.tradeAmount = tonumber(value) or 1
            updateNameMonitor("Amount set")
        end
    })

    local namePlayerDropdown = tradeByName:AddDropdown({
        Options = {},
        Multi = false,
        Title = "Select Player",
        Callback = function(value)
            State.trade.selectedPlayer = value
            updateNameMonitor("Player selected")
        end
    })

    tradeByName:AddButton({
        Title = "Refresh Players",
        Callback = function()
            local players = AutoTrade.getPlayerList()
            namePlayerDropdown:SetValues(players)
            updateNameMonitor("Player list refreshed")
        end
    })

    tradeByName:AddToggle({
        Title = "Start Trade by Name",
        Default = false,
        Callback = function(enabled)
            if enabled then
                task.spawn(function()
                    AutoTrade.startTradeByName(updateNameMonitor)
                end)
            else
                AutoTrade.stop()
                updateNameMonitor("Stopped")
            end
        end
    })

    -- ========================================
    -- TRADE BY COIN SECTION
    -- ========================================
    local tradeByCoin = tab:AddSection("Trade by Coin")

    CoinMonitor = tradeByCoin:AddParagraph({
        Title = "Trade by Coin Panel",
        Content =
        "\n<font color='rgb(173,216,230)'>Player : ???</font>\n<font color='rgb(173,216,230)'>Target : 0</font>\n<font color='rgb(173,216,230)'>Sent   : 0</font>\n<font color='rgb(200,200,200)'>Status : Idle</font>\n<font color='rgb(173,216,230)'>Success: 0</font>\n"
    })

    local function updateCoinMonitor(status)
        local trade = State.trade
        local color = "200,200,200"

        if status and status:lower():find("send") then
            color = "51,153,255"
        elseif status and status:lower():find("complete") or status:lower():find("finish") then
            color = "0,204,102"
        elseif status and status:lower():find("time") or status:lower():find("error") then
            color = "255,69,0"
        end

        local content = string.format(
            "\n<font color='rgb(173,216,230)'>Player : %s</font>\n<font color='rgb(173,216,230)'>Target : %d</font>\n<font color='rgb(173,216,230)'>Sent   : %d</font>\n<font color='rgb(%s)'>Status : %s</font>\n<font color='rgb(173,216,230)'>Success: %d</font>\n",
            trade.selectedPlayer or "???",
            trade.targetCoins or 0,
            trade.sentCoins or 0,
            color,
            status or "Idle",
            trade.successCoins or 0
        )

        _G.safeSetContent(CoinMonitor, content)
    end

    local coinPlayerDropdown = tradeByCoin:AddDropdown({
        Options = {},
        Multi = false,
        Title = "Select Player",
        Callback = function(value)
            State.trade.selectedPlayer = value
            updateCoinMonitor("Player selected")
        end
    })

    tradeByCoin:AddButton({
        Title = "Refresh Players",
        Callback = function()
            local players = AutoTrade.getPlayerList()
            coinPlayerDropdown:SetValues(players)
            updateCoinMonitor("Player list refreshed")
        end
    })

    tradeByCoin:AddInput({
        Title = "Target Coin",
        Default = "0",
        Callback = function(value)
            State.trade.targetCoins = tonumber(value) or 0
            updateCoinMonitor("Target coin set")
        end
    })

    tradeByCoin:AddToggle({
        Title = "Start Trade by Coin",
        Default = false,
        Callback = function(enabled)
            if enabled then
                task.spawn(function()
                    AutoTrade.startTradeByCoin(updateCoinMonitor)
                end)
            else
                AutoTrade.stop()
                updateCoinMonitor("Stopped")
            end
        end
    })

    -- ========================================
    -- TRADE BY RARITY SECTION
    -- ========================================
    local tradeByRarity = tab:AddSection("Trade by Rarity")

    RarityMonitor = tradeByRarity:AddParagraph({
        Title = "Trade by Rarity Panel",
        Content =
        "\n<font color='rgb(173,216,230)'>Player  : ???</font>\n<font color='rgb(173,216,230)'>Rarity  : ???</font>\n<font color='rgb(173,216,230)'>Count   : 0</font>\n<font color='rgb(200,200,200)'>Status  : Idle</font>\n<font color='rgb(173,216,230)'>Success : 0 / 0</font>\n"
    })

    local function updateRarityMonitor(status)
        local trade = State.trade
        local color = "200,200,200"

        if status and status:lower():find("send") then
            color = "51,153,255"
        elseif status and status:lower():find("complete") or status:lower():find("finish") then
            color = "0,204,102"
        elseif status and status:lower():find("time") or status:lower():find("error") then
            color = "255,69,0"
        end

        local content = string.format(
            "\n<font color='rgb(173,216,230)'>Player  : %s</font>\n<font color='rgb(173,216,230)'>Rarity  : %s</font>\n<font color='rgb(173,216,230)'>Count   : %d</font>\n<font color='rgb(%s)'>Status  : %s</font>\n<font color='rgb(173,216,230)'>Success : %d / %d</font>\n",
            trade.selectedPlayer or "???",
            trade.selectedRarity or "???",
            trade.totalToTrade or 0,
            color,
            status or "Idle",
            trade.successCount or 0,
            trade.totalToTrade or 0
        )

        _G.safeSetContent(RarityMonitor, content)
    end

    tradeByRarity:AddDropdown({
        Options = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret" },
        Multi = false,
        Title = "Select Rarity",
        Callback = function(value)
            State.trade.selectedRarity = value
            updateRarityMonitor("Selected rarity: " .. (value or "???"))
        end
    })

    local rarityPlayerDropdown = tradeByRarity:AddDropdown({
        Options = {},
        Multi = false,
        Title = "Select Player",
        Callback = function(value)
            State.trade.selectedPlayer = value
            updateRarityMonitor("Player selected")
        end
    })

    tradeByRarity:AddButton({
        Title = "Refresh Players",
        Callback = function()
            local players = AutoTrade.getPlayerList()
            rarityPlayerDropdown:SetValues(players)
            updateRarityMonitor("Player list refreshed")
        end
    })

    tradeByRarity:AddInput({
        Title = "Amount to Trade",
        Default = "1",
        Callback = function(value)
            State.trade.rarityAmount = tonumber(value) or 1
            updateRarityMonitor("Set amount: " .. tostring(State.trade.rarityAmount))
        end
    })

    tradeByRarity:AddToggle({
        Title = "Start Trade by Rarity",
        Default = false,
        Callback = function(enabled)
            if enabled then
                task.spawn(function()
                    AutoTrade.startTradeByRarity(updateRarityMonitor)
                end)
            else
                AutoTrade.stop()
                updateRarityMonitor("Stopped")
            end
        end
    })

    -- ========================================
    -- AUTO ACCEPT SECTION
    -- ========================================
    local autoAccept = tab:AddSection("Auto Accept")

    autoAccept:AddToggle({
        Title = "Auto Accept Trade",
        Default = _G.AutoAccept or false,
        Callback = function(enabled)
            _G.AutoAccept = enabled
        end
    })

    -- Auto accept trade requests loop
    task.spawn(function()
        while true do
            task.wait(1)

            if _G.AutoAccept then
                pcall(function()
                    local prompt = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("Prompt")

                    if prompt and prompt:FindFirstChild("Blackout") then
                        local blackout = prompt.Blackout

                        if blackout:FindFirstChild("Options") then
                            local yesButton = blackout.Options:FindFirstChild("Yes")

                            if yesButton then
                                local pos = yesButton.AbsolutePosition
                                local size = yesButton.AbsoluteSize
                                local x = pos.X + size.X / 2
                                local y = pos.Y + size.Y / 2 + 50

                                Services.VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
                                task.wait(0.03)
                                Services.VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
                            end
                        end
                    end
                end)
            end
        end
    end)
end

return TradeTab
