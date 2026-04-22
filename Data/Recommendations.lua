-- Voidcore Advisor: BiS bonus roll rankings per spec
-- Source: Wowhead "Best Voidforge Bonus Roll Gear for All Classes in Midnight Patch 12.0.5"
--
-- Schema:
--   VA.Recommendations[classID][specID] = { { rank = N, items = { "Item Name", ... } }, ... }
--   - `items` is a list because some ranks are tied (e.g. Arms Warrior #1).
--   - Item names are placeholders; resolved to itemIDs in Data/Items.lua.

local _, VA = ...
VA.Recommendations = {}

-- Class IDs match GetClassInfo() / Blizzard's class index
-- Spec IDs match GetSpecializationInfo() return value (the global spec ID)

-- Death Knight (6)
VA.Recommendations[6] = {
    [250] = { -- Blood
        { rank = 1, items = { "Gaze of the Alnseer" } },
        { rank = 2, items = { "Voidclaw Gauntlets" } },
        { rank = 3, items = { "Eternal Voidsong Chain" } },
        { rank = 4, items = { "Occlusion of Void" } },
        { rank = 5, items = { "Omission of Light" } },
    },
    [251] = { -- Frost
        { rank = 1, items = { "Bellamy's Final Judgement" } },
        { rank = 2, items = { "Gaze of the Alnseer" } },
        { rank = 3, items = { "Light Company Guidon" } },
    },
    [252] = { -- Unholy
        { rank = 1, items = { "Bellamy's Final Judgement" } },
        { rank = 2, items = { "Light Company Guidon" } },
        { rank = 3, items = { "Gaze of the Alnseer" } },
    },
}

-- Demon Hunter (12)
VA.Recommendations[12] = {
    [577] = { -- Havoc
        { rank = 1, items = { "Algeth'ar Puzzle Box" } },
        { rank = 2, items = { "Gaze of the Alnseer" } },
        { rank = 3, items = { "Platinum Star Band" } },
    },
    [581] = { -- Vengeance
        { rank = 1, items = { "Lightless Lament" } },
        { rank = 2, items = { "Gaze of the Alnseer" } },
        { rank = 3, items = { "Occlusion of Void" } },
    },
    -- Devourer (new Midnight spec) — spec ID TBD; placeholder key 0 to fill in
    [0] = { -- Devourer (FILL spec ID)
        { rank = 1, items = { "Gaze of the Alnseer" } },
        { rank = 2, items = { "Vaelgor's Final Stare" } },
        { rank = 3, items = { "Spellboon Saber" } },
    },
}

-- Druid (11)
VA.Recommendations[11] = {
    [102] = { -- Balance
        { rank = 1, items = { "Vaelgor's Final Stare" } },
        { rank = 2, items = { "Gaze of the Alnseer" } },
        { rank = 3, items = { "Occlusion of Void" } },
        { rank = 4, items = { "Omission of Light" } },
    },
    [103] = { -- Feral
        { rank = 1, items = { "Alnscorned Spire" } },
        { rank = 2, items = { "Gaze of the Alnseer" } },
        { rank = 3, items = { "Algeth'ar Puzzle Box" } },
    },
    [104] = { -- Guardian
        { rank = 1, items = { "Gaze of the Alnseer" } },
        { rank = 2, items = { "Algeth'ar Puzzle Box" } },
        { rank = 3, items = { "Alnscorned Spire" } },
    },
    [105] = { -- Restoration
        { rank = 1, items = { "Gaze of the Alnseer" } },
        { rank = 2, items = { "Locus-Walker's Ribbon" } },
        { rank = 3, items = { "Corespark Multitool" } },
    },
}

-- Evoker (13)
VA.Recommendations[13] = {
    [1473] = { -- Augmentation
        { rank = 1, items = { "Barbed Ymirheim Choker" } },
        { rank = 2, items = { "Scabrous Zombie Belt" } },
        { rank = 3, items = { "Ceremonial Hexblade" } },
        { rank = 4, items = { "Soulcatcher's Charm" } },
        { rank = 5, items = { "Grimoire of the Eternal Light" } },
        { rank = 6, items = { "Frenzy's Rebuke" } },
    },
    [1467] = { -- Devastation
        { rank = 1, items = { "Locus-Walker's Ribbon" } },
        { rank = 2, items = { "Soulcatcher's Charm" } },
        { rank = 3, items = { "Vaelgor's Final Stare" } },
    },
    [1468] = { -- Preservation
        { rank = 1, items = { "Gaze of the Alnseer" } },
        { rank = 2, items = { "Locus-Walker's Ribbon" } },
        { rank = 3, items = { "Corespark Multitool" } },
    },
}

-- Hunter (3)
VA.Recommendations[3] = {
    [253] = { -- Beast Mastery
        { rank = 1, items = { "Deceiver's Rotbow" } },
        { rank = 2, items = { "Algeth'ar Puzzle Box" } },
        { rank = 3, items = { "Gaze of the Alnseer" } },
    },
    [254] = { -- Marksmanship
        { rank = 1, items = { "Ranger-Captain's Lethal Recurve" } },
        { rank = 2, items = { "Algeth'ar Puzzle Box" } },
        { rank = 3, items = { "Umbral Plume" } },
    },
    [255] = { -- Survival
        { rank = 1, items = { "Algeth'ar Puzzle Box" } },
        { rank = 2, items = { "Gaze of the Alnseer" } },
        { rank = 3, items = { "Scornbane Waistguard" } },
        { rank = 4, items = { "Occlusion of Void" } },
        { rank = 5, items = { "Omission of Light" } },
        { rank = 6, items = { "Radiant Slicer" } },
    },
}

-- Mage (8)
VA.Recommendations[8] = {
    [62] = { -- Arcane
        { rank = 1, items = { "Vaelgor's Final Stare" } },
        { rank = 2, items = { "Gaze of the Alnseer" } },
        { rank = 3, items = { "Eye of Midnight" } },
    },
    [63] = { -- Fire
        { rank = 1, items = { "Emberwing Feather" } },
        { rank = 2, items = { "Locus-Walker's Ribbon" } },
        { rank = 3, items = { "Gaze of the Alnseer" } },
    },
    [64] = { -- Frost
        { rank = 1, items = { "Gaze of the Alnseer" } },
        { rank = 2, items = { "Vaelgor's Final Stare" } },
        { rank = 3, items = { "Eye of Midnight" } },
    },
}

-- Monk (10)
VA.Recommendations[10] = {
    [268] = { -- Brewmaster
        { rank = 1, items = { "Gaze of the Alnseer" } },
        { rank = 2, items = { "Shifting Stalker Hide Pants" } },
        { rank = 3, items = { "Ampoule of Pure Void" } },
        { rank = 4, items = { "Radiant Plume" } },
    },
    [270] = { -- Mistweaver
        { rank = 1, items = { "Litany of Lightblind Wrath" } },
        { rank = 2, items = { "Blooming Barklight Spaulders" } },
        { rank = 3, items = { "Gaze of the Alnseer" } },
        { rank = 4, items = { "Scorn-Scarred Shul'ka's Belt" } },
        { rank = 5, items = { "Barbed Ymirheim Choker" } },
        { rank = 6, items = { "Flayer's Black Belt" } },
    },
    [269] = { -- Windwalker
        { rank = 1, items = { "Traitor's Talon" } },
        { rank = 2, items = { "Algeth'ar Puzzle Box" } },
        { rank = 3, items = { "Gaze of the Alnseer" } },
    },
}

-- Paladin (2)
VA.Recommendations[2] = {
    [65] = { -- Holy
        { rank = 1, items = { "Gaze of the Alnseer" } },
        { rank = 2, items = { "Locus-Walker's Ribbon" } },
        { rank = 3, items = { "Spellboon Saber" } },
    },
    [66] = { -- Protection
        { rank = 1, items = { "Turalyon's False Echo" } },
        { rank = 2, items = { "Thalassian Dawnguard" } },
        { rank = 3, items = { "Gaze of the Alnseer" } },
    },
    [70] = { -- Retribution
        { rank = 1, items = { "Amulet of the Abyssal Hymn" } },
        { rank = 2, items = { "Algeth'ar Puzzle Box" } },
        { rank = 3, items = { "Gaze of the Alnseer" } },
    },
}

-- Priest (5)
VA.Recommendations[5] = {
    [256] = { -- Discipline
        { rank = 1, items = { "Gaze of the Alnseer" } },
        { rank = 2, items = { "Vaelgor's Final Stare" } },
        { rank = 3, items = { "Litany of Lightblind Wrath" } },
    },
    [257] = { -- Holy
        { rank = 1, items = { "Litany of Lightblind Wrath" } },
        { rank = 2, items = { "Locus-Walker's Ribbon" } },
        { rank = 3, items = { "Gaze of the Alnseer" } },
    },
    [258] = { -- Shadow
        { rank = 1, items = { "Gaze of the Alnseer" } },
        { rank = 2, items = { "Corespark Multitool" } },
        { rank = 3, items = { "Omission of Light" } },
        { rank = 4, items = { "Occlusion of Void" } },
        { rank = 5, items = { "Vaelgor's Final Stare" } },
    },
}

-- Rogue (4)
VA.Recommendations[4] = {
    [259] = { -- Assassination
        { rank = 1, items = { "Krick's Beetle Stabber" } },
        { rank = 2, items = { "Purloined Wedding Ring" } },
        { rank = 3, items = { "Algeth'ar Puzzle Box" } },
        { rank = 4, items = { "Gaze of the Alnseer" } },
    },
    [260] = { -- Outlaw
        { rank = 1, items = { "Gaze of the Alnseer" } },
        { rank = 2, items = { "Alncured Riftbloom" } },
        { rank = 3, items = { "Scorn-Scarred Shul'ka's Belt" } },
        { rank = 4, items = { "Krick's Beetle Stabber" } },
        { rank = 5, items = { "Barbed Ymirheim Choker" } },
    },
    [261] = { -- Subtlety
        { rank = 1, items = { "Light Company Guidon" } },
        { rank = 2, items = { "Gaze of the Alnseer" } },
        { rank = 3, items = { "Algeth'ar Puzzle Box" } },
        { rank = 4, items = { "Eternal Voidsong Chain" } },
    },
}

-- Shaman (7)
VA.Recommendations[7] = {
    [262] = { -- Elemental
        { rank = 1, items = { "Emberwing Feather" } },
        { rank = 2, items = { "Gaze of the Alnseer" } },
        { rank = 3, items = { "Locus-Walker's Ribbon" } },
    },
    [263] = { -- Enhancement
        { rank = 1, items = { "Algeth'ar Puzzle Box" } },
        { rank = 2, items = { "Gaze of the Alnseer" } },
        { rank = 3, items = { "Blazing Sunclaws" } },
    },
    [264] = { -- Restoration
        { rank = 1, items = { "Splitshroud Stinger" } },
        { rank = 2, items = { "Ward of the Spellbreaker" } },
        { rank = 3, items = { "Gaze of the Alnseer" } },
        { rank = 4, items = { "Light of the Cosmic Crescendo" } },
        { rank = 5, items = { "Locus-Walker's Ribbon" } },
    },
}

-- Warlock (9)
VA.Recommendations[9] = {
    [265] = { -- Affliction
        { rank = 1, items = { "Gaze of the Alnseer" } },
        { rank = 2, items = { "Emberwing Feather" } },
    },
    [266] = { -- Demonology
        { rank = 1, items = { "Gaze of the Alnseer" } },
        { rank = 2, items = { "Emberwing Feather" } },
        { rank = 3, items = { "Heart of Wind" } },
    },
    [267] = { -- Destruction
        { rank = 1, items = { "Gaze of the Alnseer" } },
        { rank = 2, items = { "Vaelgor's Final Stare" } },
    },
}

-- Warrior (1)
VA.Recommendations[1] = {
    [71] = { -- Arms
        { rank = 1, items = { "Gaze of the Alnseer", "Umbral Plume" } }, -- tied
        { rank = 2, items = { "Heart of Ancient Hunger" } },
        { rank = 3, items = { "Garfrost's Two-Ton Hammer" } },
        { rank = 4, items = { "Voidclaw Gauntlets" } },
    },
    [72] = { -- Fury
        { rank = 1, items = { "Gaze of the Alnseer" } },
        { rank = 2, items = { "Heart of Ancient Hunger" } },
        { rank = 3, items = { "Whirling Voidcleaver" } },
        { rank = 4, items = { "Voidclaw Gauntlets" } },
    },
    [73] = { -- Protection
        { rank = 1, items = { "Turalyon's False Echo" } },
        { rank = 2, items = { "Thalassian Dawnguard" } },
        { rank = 3, items = { "Gaze of the Alnseer" } },
    },
}
