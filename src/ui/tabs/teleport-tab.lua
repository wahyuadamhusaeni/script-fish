-- src/ui/tabs/teleport-tab.lua
-- Teleport & Position management tab

local Teleport = require("src/features/teleport/teleport")
local State = require("src/core/state")

local TeleportTab = {}

-- Selected location storage
local selectedLocation = nil

function TeleportTab.setup(tab)
    -- TELEPORT TO LOCATION SECTION
    local locationSection = tab:AddSection("Teleport to Location")

    -- Get location names
    local locationNames = Teleport.getLocationNames()

    -- Location Dropdown (just select, don't teleport yet)
    locationSection:AddDropdown({
        Title = "Select Location",
        Options = locationNames,
        Multi = false,
        Callback = function(location)
            selectedLocation = location
            print("[Teleport Tab] Location selected:", location)
        end
    })

    -- Teleport Button (actual teleport happens here)
    locationSection:AddButton({
        Title = "Teleport to Location",
        Content = "Click to teleport to selected location",
        Callback = function()
            if selectedLocation and selectedLocation ~= "" then
                local success = Teleport.toLocation(selectedLocation)
                if success then
                    print("[Teleport Tab] Teleported to:", selectedLocation)
                else
                    warn("[Teleport Tab] Teleport failed:", selectedLocation)
                end
            else
                warn("[Teleport Tab] Please select a location first")
            end
        end
    })

    -- SAVE/LOAD POSITION SECTION
    local savedPosSection = tab:AddSection("Save & Load Position")

    -- Save Position Button
    savedPosSection:AddButton({
        Title = "Save Current Position",
        Content = "Save your current position for later use",
        Callback = function()
            local success = Teleport.savePosition()
            if success then
                print("[Teleport Tab] Position saved successfully")
            else
                warn("[Teleport Tab] Failed to save position")
            end
        end
    })

    -- Load Position Button
    savedPosSection:AddButton({
        Title = "Teleport to Saved Position",
        Content = "Teleport to your saved position",
        Callback = function()
            local success = Teleport.toSavedPosition()
            if success then
                print("[Teleport Tab] Teleported to saved position")
            else
                warn("[Teleport Tab] No saved position found")
            end
        end
    })

    -- Clear Saved Position Button
    savedPosSection:AddButton({
        Title = "Clear Saved Position",
        Content = "Delete your saved position",
        Callback = function()
            Teleport.clearSavedPosition()
            print("[Teleport Tab] Saved position cleared")
        end
    })

    -- INFO SECTION
    local infoSection = tab:AddSection("Information")

    infoSection:AddParagraph({
        Title = "How to Use",
        Content = [[
1. Select a location from dropdown
2. Click "Teleport to Location" to teleport

OR

1. Go to desired position in game
2. Click "Save Current Position"
3. Use "Teleport to Saved Position" anytime

Your position is saved to:
ZiviHub/SavedPosition_ZIVIHUB.json
        ]]
    })

    print("[Teleport Tab] Initialized")
end

return TeleportTab
