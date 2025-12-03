--[[
    Constants Module

    Contains all constant values used throughout the script:
    - Fish tiers/rarities
    - Fish variants
    - Ignored events
    - Rod priority list
]]

local Constants = {}

-- Fish rarity tiers
Constants.TIER_FISH = {
    [1] = " ",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "Secret"
}

-- Fish variants
Constants.VARIANTS = {
    "Galaxy",
    "Corrupt",
    "Gemstone",
    "Ghost",
    "Lightning",
    "Fairy Dust",
    "Gold",
    "Midnight",
    "Radioactive",
    "Stone",
    "Holographic",
    "Albino",
    "Bloodmoon",
    "Sandy",
    "Acidic",
    "Color Burn",
    "Festive",
    "Frozen"
}

-- Events to ignore in auto-event system
Constants.IGNORED_EVENTS = {
    Cloudy = true,
    Day = true,
    ["Increased Luck"] = true,
    Mutated = true,
    Night = true,
    Snow = true,
    ["Sparkling Cove"] = true,
    Storm = true,
    Wind = true,
    UIListLayout = true,
    ["Admin - Shocked"] = true,
    ["Admin - Super Mutated"] = true,
    Radiant = true
}

-- Rod priority for auto-equip (highest priority first)
Constants.ROD_PRIORITY = {
    "Element Rod",
    "Ghostfin Rod",
    "Bambo Rod",
    "Angler Rod",
    "Ares Rod",
    "Hazmat Rod",
    "Astral Rod",
    "Midnight Rod"
}

-- Event position offsets (Y-axis)
Constants.EVENT_OFFSETS = {
    ["Worm Hunt"] = 25
}

return Constants
