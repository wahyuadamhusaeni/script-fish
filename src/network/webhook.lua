--[[
    Webhook Module

    Discord webhook integration for notifications.

    Usage:
        local Webhook = require("src/network/webhook")
        Webhook.sendFishCaught(url, "Megalodon", "Mythic", "Galaxy")
]]

local Services = require("src/core/services")

local Webhook = {}

-- Initialize httpRequest based on executor
Webhook.httpRequest = syn and syn.request
    or http and http.request
    or http_request
    or fluxus and fluxus.request
    or request

--[[
    Send generic webhook
    @param url string - Discord webhook URL
    @param data table - Webhook payload
    @return boolean - Success status
]]
function Webhook.send(url, data)
    if not Webhook.httpRequest then
        warn("[Webhook] HTTP request not supported by executor")
        return false
    end

    local success = pcall(function()
        Webhook.httpRequest({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = Services.HttpService:JSONEncode(data)
        })
    end)

    return success
end

--[[
    Send fish caught notification
    @param webhookUrl string - Discord webhook URL
    @param fishName string - Name of fish
    @param rarity string - Fish rarity
    @param variant string - Fish variant (optional)
]]
function Webhook.sendFishCaught(webhookUrl, fishName, rarity, variant)
    local embed = {
        embeds = {{
            title = "[FISH] Fish Caught!",
            description = string.format("**%s**\nRarity: %s\nVariant: %s",
                fishName, rarity, variant or "None"),
            color = 0x00ff00,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
        }}
    }

    return Webhook.send(webhookUrl, embed)
end

--[[
    Send disconnect notification
    @param webhookUrl string - Discord webhook URL
    @param reason string - Disconnect reason
    @param customName string - Custom player name (optional)
]]
function Webhook.sendDisconnect(webhookUrl, reason, customName)
    local embed = {
        content = _G.DiscordMention or "",
        embeds = {{
            title = "[WARNING] Disconnected",
            description = string.format("**%s** disconnected\nReason: %s",
                customName or "Player", reason),
            color = 0xff0000,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
        }}
    }

    return Webhook.send(webhookUrl, embed)
end

--[[
    Send trade notification
    @param webhookUrl string - Discord webhook URL
    @param itemName string - Item traded
    @param targetPlayer string - Player traded with
    @param success boolean - Trade success status
]]
function Webhook.sendTrade(webhookUrl, itemName, targetPlayer, success)
    local color = success and 0x00ff00 or 0xff0000
    local title = success and "[SUCCESS] Trade Success" or "[FAILED] Trade Failed"

    local embed = {
        embeds = {{
            title = title,
            description = string.format("Item: **%s**\nPlayer: **%s**",
                itemName, targetPlayer),
            color = color,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
        }}
    }

    return Webhook.send(webhookUrl, embed)
end

return Webhook
