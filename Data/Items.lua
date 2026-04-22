-- Voidcore Advisor: Item ID lookup and metadata
-- Populated incrementally; resolves item names from Recommendations.lua to itemIDs.
--
-- Schema:
--   VA.Items[itemName] = {
--     id = <itemID>,
--     icon = <fileID or texture path>,  -- optional, GetItemIcon(id) at runtime is fine
--     slot = <"trinket"|"weapon"|"head"|...>,  -- for slot-based filtering / display
--     stats = { "haste", "crit" },     -- optional, future use for secondary-stat filtering
--   }
--
-- TODO: Populate from Wowhead. Items left empty here will fall back to name-only display.

local _, VA = ...
VA.Items = {
    -- Universal trinket / signature item across most specs
    ["Gaze of the Alnseer"] = { id = nil, slot = "trinket" },

    -- Trinkets
    ["Algeth'ar Puzzle Box"]      = { id = nil, slot = "trinket" },
    ["Vaelgor's Final Stare"]     = { id = nil, slot = "trinket" },
    ["Soulcatcher's Charm"]       = { id = nil, slot = "trinket" },
    ["Lightless Lament"]          = { id = nil, slot = "trinket" },
    ["Eye of Midnight"]           = { id = nil, slot = "trinket" },
    ["Heart of Wind"]             = { id = nil, slot = "trinket" },
    ["Heart of Ancient Hunger"]   = { id = nil, slot = "trinket" },
    ["Ampoule of Pure Void"]      = { id = nil, slot = "trinket" },
    ["Corespark Multitool"]       = { id = nil, slot = "trinket" },

    -- Weapons
    ["Bellamy's Final Judgement"]      = { id = nil, slot = "weapon" },
    ["Light Company Guidon"]           = { id = nil, slot = "weapon" },
    ["Spellboon Saber"]                = { id = nil, slot = "weapon" },
    ["Alnscorned Spire"]               = { id = nil, slot = "weapon" },
    ["Ceremonial Hexblade"]            = { id = nil, slot = "weapon" },
    ["Frenzy's Rebuke"]                = { id = nil, slot = "weapon" },
    ["Deceiver's Rotbow"]              = { id = nil, slot = "weapon" },
    ["Ranger-Captain's Lethal Recurve"]= { id = nil, slot = "weapon" },
    ["Radiant Slicer"]                 = { id = nil, slot = "weapon" },
    ["Emberwing Feather"]              = { id = nil, slot = "weapon" },
    ["Traitor's Talon"]                = { id = nil, slot = "weapon" },
    ["Krick's Beetle Stabber"]         = { id = nil, slot = "weapon" },
    ["Splitshroud Stinger"]            = { id = nil, slot = "weapon" },
    ["Ward of the Spellbreaker"]       = { id = nil, slot = "shield" },
    ["Garfrost's Two-Ton Hammer"]      = { id = nil, slot = "weapon" },
    ["Whirling Voidcleaver"]           = { id = nil, slot = "weapon" },
    ["Turalyon's False Echo"]          = { id = nil, slot = "weapon" },

    -- Armor
    ["Voidclaw Gauntlets"]             = { id = nil, slot = "hands" },
    ["Shifting Stalker Hide Pants"]    = { id = nil, slot = "legs" },
    ["Blooming Barklight Spaulders"]   = { id = nil, slot = "shoulders" },
    ["Scabrous Zombie Belt"]           = { id = nil, slot = "waist" },
    ["Scornbane Waistguard"]           = { id = nil, slot = "waist" },
    ["Scorn-Scarred Shul'ka's Belt"]   = { id = nil, slot = "waist" },
    ["Flayer's Black Belt"]            = { id = nil, slot = "waist" },
    ["Thalassian Dawnguard"]           = { id = nil, slot = "head" },
    ["Radiant Plume"]                  = { id = nil, slot = "head" },

    -- Necks / Rings / Cloaks / Misc
    ["Eternal Voidsong Chain"]   = { id = nil, slot = "neck" },
    ["Barbed Ymirheim Choker"]   = { id = nil, slot = "neck" },
    ["Amulet of the Abyssal Hymn"] = { id = nil, slot = "neck" },
    ["Platinum Star Band"]       = { id = nil, slot = "finger" },
    ["Purloined Wedding Ring"]   = { id = nil, slot = "finger" },
    ["Alncured Riftbloom"]       = { id = nil, slot = "finger" },
    ["Locus-Walker's Ribbon"]    = { id = nil, slot = "back" },
    ["Umbral Plume"]             = { id = nil, slot = "back" },
    ["Occlusion of Void"]        = { id = nil, slot = "offhand" },
    ["Omission of Light"]        = { id = nil, slot = "offhand" },
    ["Litany of Lightblind Wrath"] = { id = nil, slot = "offhand" },
    ["Grimoire of the Eternal Light"] = { id = nil, slot = "offhand" },
    ["Light of the Cosmic Crescendo"] = { id = nil, slot = "offhand" },
    ["Blazing Sunclaws"]         = { id = nil, slot = "hands" },
}
