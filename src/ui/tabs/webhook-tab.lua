-- src/ui/tabs/webhook-tab.lua
-- Discord Webhook integration tab

local Services = require("src/core/services")
local State = require("src/core/state")
local Webhook = require("src/network/webhook")
local Events = require("src/network/events")
local Data = require("src/data/models")

local WebhookTab = {}

-- Hook fish caught event for webhook
local function setupFishCaughtHook()
    if State.webhook.fishCaughtConnection then
        return -- Already connected
    end

    State.webhook.fishCaughtConnection = Events.REFishGot.OnClientEvent:Connect(function(fishData)
        if not State.webhook.enabled or not State.webhook.url or State.webhook.url == "" then
            return
        end

        -- Get fish details
        local fishId = fishData.Id
        local itemData = Data.ItemUtility and Data.ItemUtility.GetItemDataFromItemType("Items", fishId)

        if not itemData or not itemData.Data then
            return
        end

        local fishName = itemData.Data.Name
        local rarity = _G.TierFish[itemData.Data.Tier] or "Common"
        local variant = fishData.Variant or "None"

        -- Check if rarity is selected for notification
        if not State.webhook.selectedRarities[rarity] then
            return -- Skip this rarity
        end

        -- Prepare player name
        local playerName = State.webhook.hideIdentifier and "Hidden" or Services.LocalPlayer.Name

        -- Send webhook
        local embed = {
            content = State.webhook.discordMention or "",
            embeds = { {
                title = "Fish Caught",
                description = string.format("**%s**\nRarity: **%s**\nVariant: %s\nPlayer: %s",
                    fishName, rarity, variant, playerName),
                color = rarity == "Secret" and 0xff00ff
                    or rarity == "Mythic" and 0xffd700
                    or rarity == "Legendary" and 0xff8c00
                    or rarity == "Epic" and 0x9400d3
                    or rarity == "Rare" and 0x0000ff
                    or 0x00ff00,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S"),
                footer = {
                    text = "Zivi Hub Webhook"
                }
            } }
        }

        task.spawn(function()
            Webhook.send(State.webhook.url, embed)
        end)
    end)

    print("[Webhook] Fish caught hook enabled")
end

function WebhookTab.setup(tab)
    -- CONFIGURATION SECTION
    local configSection = tab:AddSection("Webhook Configuration")

    -- Webhook URL Input
    configSection:AddInput({
        Title = "Discord Webhook URL",
        Content = "Enter your Discord webhook URL",
        Placeholder = "https://discord.com/api/webhooks/...",
        Callback = function(url)
            State.webhook.url = url
            _G.WebhookURL = url -- For backwards compatibility
            print("[Webhook] Webhook URL saved")
        end
    })

    -- Discord Mention Input
    configSection:AddInput({
        Title = "Discord Mention (Optional)",
        Content = "Mention user/role when fish caught",
        Placeholder = "<@USER_ID> or <@&ROLE_ID>",
        Callback = function(mention)
            State.webhook.discordMention = mention
            _G.DiscordMention = mention -- For backwards compatibility
            print("[Webhook] Discord mention saved:", mention)
        end
    })

    -- Hide Identifier Toggle
    configSection:AddToggle({
        Title = "Hide Roblox Username",
        Content = "Hide your Roblox username in webhooks",
        Default = false,
        Callback = function(enabled)
            State.webhook.hideIdentifier = enabled
            print("[Webhook] Hide identifier:", enabled)
        end
    })

    -- FISH CAUGHT NOTIFICATIONS SECTION
    local fishSection = tab:AddSection("Fish Caught Notifications")

    -- Enable Fish Webhook Toggle
    fishSection:AddToggle({
        Title = "Enable Fish Caught Webhook",
        Content = "Send webhook when catching fish",
        Default = false,
        Callback = function(enabled)
            State.webhook.enabled = enabled
            if enabled then
                setupFishCaughtHook()
                print("[Webhook] Fish caught webhook enabled")
            else
                print("[Webhook] Fish caught webhook disabled")
            end
        end
    })

    -- Rarity Filter Section
    local raritySection = tab:AddSection("Rarity Filter")

    raritySection:AddParagraph({
        Title = "Select Rarities to Notify",
        Content = "Only selected rarities will trigger webhook notifications"
    })

    -- Uncommon Toggle
    raritySection:AddToggle({
        Title = "Uncommon",
        Content = "Send webhook for Uncommon fish",
        Default = false,
        Callback = function(enabled)
            State.webhook.selectedRarities.Uncommon = enabled
            print("[Webhook] Uncommon notifications:", enabled)
        end
    })

    -- Rare Toggle
    raritySection:AddToggle({
        Title = "Rare",
        Content = "Send webhook for Rare fish",
        Default = false,
        Callback = function(enabled)
            State.webhook.selectedRarities.Rare = enabled
            print("[Webhook] Rare notifications:", enabled)
        end
    })

    -- Epic Toggle
    raritySection:AddToggle({
        Title = "Epic",
        Content = "Send webhook for Epic fish",
        Default = false,
        Callback = function(enabled)
            State.webhook.selectedRarities.Epic = enabled
            print("[Webhook] Epic notifications:", enabled)
        end
    })

    -- Legendary Toggle
    raritySection:AddToggle({
        Title = "Legendary",
        Content = "Send webhook for Legendary fish",
        Default = false,
        Callback = function(enabled)
            State.webhook.selectedRarities.Legendary = enabled
            print("[Webhook] Legendary notifications:", enabled)
        end
    })

    -- Mythic Toggle (Default OFF)
    raritySection:AddToggle({
        Title = "Mythic",
        Content = "Send webhook for Mythic fish",
        Default = false,
        Callback = function(enabled)
            State.webhook.selectedRarities.Mythic = enabled
            print("[Webhook] Mythic notifications:", enabled)
        end
    })

    -- Secret Toggle (Default ON)
    raritySection:AddToggle({
        Title = "Secret",
        Content = "Send webhook for Secret fish",
        Default = true,
        Callback = function(enabled)
            State.webhook.selectedRarities.Secret = enabled
            print("[Webhook] Secret notifications:", enabled)
        end
    })

    -- TESTING SECTION
    local testSection = tab:AddSection("Testing")

    -- Test Webhook Button
    testSection:AddButton({
        Title = "Send Test Webhook",
        Content = "Send a test message to verify webhook",
        Callback = function()
            if not State.webhook.url or State.webhook.url == "" then
                warn("[Webhook] Please enter webhook URL first")
                return
            end

            local playerName = State.webhook.hideIdentifier and "Hidden" or Services.LocalPlayer.Name

            local success = Webhook.send(State.webhook.url, {
                content = State.webhook.discordMention or "",
                embeds = { {
                    title = "Test Webhook",
                    description = string.format("Webhook is working correctly!\n\nPlayer: %s\nHide Identifier: %s",
                        playerName,
                        State.webhook.hideIdentifier and "Enabled" or "Disabled"
                    ),
                    color = 0x00ff00,
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%S"),
                    footer = {
                        text = "Zivi Hub Webhook Test"
                    }
                } }
            })

            if success then
                print("[Webhook] Test webhook sent successfully")
            else
                warn("[Webhook] Failed to send test webhook")
            end
        end
    })

    -- INFORMATION SECTION
    local infoSection = tab:AddSection("Information")

    infoSection:AddParagraph({
        Title = "How to Setup",
        Content = [[
1. Create webhook in Discord:
   - Go to Server Settings > Integrations
   - Create Webhook
   - Copy webhook URL

2. Paste URL in the input above

3. (Optional) Add Discord mention:
   - For user: <@USER_ID>
   - For role: <@&ROLE_ID>

4. Select rarities to notify

5. Enable "Fish Caught Webhook"

6. Test with "Send Test Webhook" button

Privacy:
- Enable "Hide Roblox Username" to hide your identity
- Webhook will show "Hidden" instead of your username
        ]]
    })

    print("[Webhook Tab] Initialized")
end

return WebhookTab
