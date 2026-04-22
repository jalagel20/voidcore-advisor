-- Voidcore Advisor: Maps items to where they drop
-- Lets the Advisor answer "for THIS boss / dungeon, which BiS items are still obtainable?"
--
-- Schema:
--   VA.Sources[itemName] = {
--     contentType = "raid" | "mythicplus" | "delve" | "preyhunt",
--     instanceID  = <Blizzard journal/instance ID>, -- raid or dungeon
--     bossID      = <encounter ID>,                 -- raid only
--     difficulty  = { "heroic", "mythic" },         -- difficulties this drops on
--   }
--
-- TODO: Populate from Wowhead source data.

local _, VA = ...
VA.Sources = {
    -- example shape:
    -- ["Gaze of the Alnseer"] = {
    --     contentType = "raid",
    --     instanceID  = 1296,           -- Manaforge Omega placeholder
    --     bossID      = 2900,           -- placeholder
    --     difficulty  = { "heroic", "mythic" },
    -- },
}
