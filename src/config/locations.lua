--[[
    Locations Configuration

    Predefined teleport locations in the game.

    Usage:
        local Locations = require("src/config/locations")
        local pos = Locations["Treasure Room"]
]]

local Locations = {
    -- Deep Sea
    ["Treasure Room"] = Vector3.new(-3602.01, -266.57, -1577.18),
    ["Sisyphus Statue"] = Vector3.new(-3703.69, -135.57, -1017.17),

    -- Crater Island
    ["Crater Island Top"] = Vector3.new(1011.29, 22.68, 5076.27),
    ["Crater Island Ground"] = Vector3.new(1079.57, 3.64, 5080.35),

    -- Coral Reefs
    ["Coral Reefs SPOT 1"] = Vector3.new(-3031.88, 2.52, 2276.36),
    ["Coral Reefs SPOT 2"] = Vector3.new(-3270.86, 2.5, 2228.1),
    ["Coral Reefs SPOT 3"] = Vector3.new(-3136.1, 2.61, 2126.11),

    -- Main Areas
    ["Lost Shore"] = Vector3.new(-3737.97, 5.43, -854.68),
    ["Weather Machine"] = Vector3.new(-1524.88, 2.87, 1915.56),
    ["Stingray Shores"] = Vector3.new(44.41, 28.83, 3048.93),
    ["Ice Sea"] = Vector3.new(2164, 7, 3269),

    -- Kohana
    ["Kohana Volcano"] = Vector3.new(-561.81, 21.24, 156.72),
    ["Kohana SPOT 1"] = Vector3.new(-367.77, 6.75, 521.91),
    ["Kohana SPOT 2"] = Vector3.new(-623.96, 19.25, 419.36),

    -- Tropical Grove
    ["Tropical Grove"] = Vector3.new(-2018.91, 9.04, 3750.59),
    ["Tropical Grove Cave 1"] = Vector3.new(-2151, 3, 3671),
    ["Tropical Grove Cave 2"] = Vector3.new(-2018, 5, 3756),
    ["Tropical Grove Highground"] = Vector3.new(-2139, 53, 3624),

    -- Fisherman Island
    ["Fisherman Island Underground"] = Vector3.new(-62, 3, 2846),
    ["Fisherman Island Mid"] = Vector3.new(33, 3, 2764),
    ["Fisherman Island Rift Left"] = Vector3.new(-26, 10, 2686),
    ["Fisherman Island Rift Right"] = Vector3.new(95, 10, 2684),

    -- Ancient Areas
    ["Secret Temple"] = Vector3.new(1475, -22, -632),
    ["Ancient Jungle Outside"] = Vector3.new(1488, 8, -392),
    ["Ancient Jungle"] = Vector3.new(1274, 8, -184),
    ["Underground Cellar"] = Vector3.new(2136, -91, -699),
    ["Crystalline Passage"] = Vector3.new(6051, -539, 4386),
    ["Ancient Ruin"] = Vector3.new(6090, -586, 4634)
}

return Locations
