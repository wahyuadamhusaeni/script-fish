local FishingTab = {}

function FishingTab.setup(tab)
    tab:Button({
        Text = "Start Fishing",
        Icon = "fish",
        Callback = function()
            print("Start Fishing")
        end
    })
end


return FishingTab