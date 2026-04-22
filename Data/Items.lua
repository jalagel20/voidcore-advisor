-- Voidcore Advisor: Item ID lookup and metadata
-- Source: scraped from Wowhead "Best Voidforge Bonus Roll Gear" article (Midnight 12.0.5).
--
-- Schema:
--   VA.Items[itemName] = {
--     id   = <itemID>,              -- Wowhead item ID (used for tooltips, icon, link)
--     slot = <"trinket"|"weapon"|...>,
--   }

local _, VA = ...
VA.Items = {
    -- Trinkets
    ["Gaze of the Alnseer"]         = { id = 249343, slot = "trinket" },
    ["Algeth'ar Puzzle Box"]        = { id = 193701, slot = "trinket" },
    ["Vaelgor's Final Stare"]       = { id = 249346, slot = "trinket" },
    ["Soulcatcher's Charm"]         = { id = 250223, slot = "trinket" },
    ["Lightless Lament"]            = { id = 260408, slot = "trinket" },
    ["Eye of Midnight"]             = { id = 249920, slot = "trinket" },
    ["Heart of Wind"]               = { id = 250256, slot = "trinket" },
    ["Heart of Ancient Hunger"]     = { id = 249342, slot = "trinket" },
    ["Ampoule of Pure Void"]        = { id = 151312, slot = "trinket" },
    ["Corespark Multitool"]         = { id = 251201, slot = "trinket" },

    -- Weapons
    ["Bellamy's Final Judgement"]       = { id = 249277, slot = "weapon" },
    ["Light Company Guidon"]            = { id = 249344, slot = "weapon" },
    ["Spellboon Saber"]                 = { id = 193710, slot = "weapon" },
    ["Alnscorned Spire"]                = { id = 249278, slot = "weapon" },
    ["Ceremonial Hexblade"]             = { id = 251178, slot = "weapon" },
    ["Frenzy's Rebuke"]                 = { id = 249317, slot = "weapon" },
    ["Deceiver's Rotbow"]               = { id = 251174, slot = "weapon" },
    ["Ranger-Captain's Lethal Recurve"] = { id = 249288, slot = "weapon" },
    ["Radiant Slicer"]                  = { id = 251212, slot = "weapon" },
    ["Emberwing Feather"]               = { id = 250144, slot = "weapon" },
    ["Traitor's Talon"]                 = { id = 251162, slot = "weapon" },
    ["Krick's Beetle Stabber"]          = { id = 49807,  slot = "weapon" }, -- alt ID 133491 seen in Outlaw entry
    ["Splitshroud Stinger"]             = { id = 251111, slot = "weapon" },
    ["Ward of the Spellbreaker"]        = { id = 251105, slot = "shield" },
    ["Garfrost's Two-Ton Hammer"]       = { id = 49802,  slot = "weapon" },
    ["Whirling Voidcleaver"]            = { id = 251117, slot = "weapon" },
    ["Turalyon's False Echo"]           = { id = 249295, slot = "weapon" },

    -- Armor
    ["Voidclaw Gauntlets"]              = { id = 151332, slot = "hands" },
    ["Shifting Stalker Hide Pants"]     = { id = 151314, slot = "legs" },
    ["Blooming Barklight Spaulders"]    = { id = 249333, slot = "shoulders" },
    ["Scabrous Zombie Belt"]            = { id = 49810,  slot = "waist" },
    ["Scornbane Waistguard"]            = { id = 249371, slot = "waist" },
    ["Scorn-Scarred Shul'ka's Belt"]    = { id = 249374, slot = "waist" },
    ["Flayer's Black Belt"]             = { id = 49806,  slot = "waist" },
    ["Thalassian Dawnguard"]            = { id = 249921, slot = "head" },
    ["Radiant Plume"]                   = { id = 249806, slot = "head" },
    ["Blazing Sunclaws"]                = { id = 258438, slot = "hands" },

    -- Necks / Rings / Cloaks / Offhands
    ["Eternal Voidsong Chain"]          = { id = 249368, slot = "neck" },
    ["Barbed Ymirheim Choker"]          = { id = 50228,  slot = "neck" },
    ["Amulet of the Abyssal Hymn"]      = { id = 250247, slot = "neck" },
    ["Platinum Star Band"]              = { id = 193708, slot = "finger" },
    ["Purloined Wedding Ring"]          = { id = 49812,  slot = "finger" },
    ["Alncured Riftbloom"]              = { id = 249348, slot = "finger" },
    ["Locus-Walker's Ribbon"]           = { id = 249809, slot = "back" },
    ["Umbral Plume"]                    = { id = 260235, slot = "back" },
    ["Occlusion of Void"]               = { id = 251217, slot = "offhand" },
    ["Omission of Light"]               = { id = 251093, slot = "offhand" },
    ["Litany of Lightblind Wrath"]      = { id = 249808, slot = "offhand" },
    ["Grimoire of the Eternal Light"]   = { id = 249276, slot = "offhand" },
    ["Light of the Cosmic Crescendo"]   = { id = 249811, slot = "offhand" },
}

-- Reverse lookup: itemID -> itemName (used by loot event parsing for faster match)
VA.ItemsByID = {}
for name, data in pairs(VA.Items) do
    if data.id then VA.ItemsByID[data.id] = name end
end
