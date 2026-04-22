-- Voidcore Advisor: Tracker
-- Tracks Nebulous Voidcore count, weekly cap, and collected BiS items per difficulty.

local _, VA = ...
local Tracker = {}
VA.Tracker = Tracker

-- TODO: confirm currency ID for Nebulous Voidcore (placeholder)
local NEBULOUS_VOIDCORE_CURRENCY_ID = 0

-- Map Blizzard difficultyID -> our internal key
local DIFFICULTY_MAP = {
    [14] = "normal",       -- Normal raid
    [15] = "heroic",       -- Heroic raid
    [16] = "mythic",       -- Mythic raid
    [17] = "lfr",          -- LFR
    [23] = "mythic",       -- Mythic 5-man
    [8]  = "mythicplus",   -- M+
}

function Tracker:Init()
    self:RefreshVoidcoreCount()
end

function Tracker:RefreshVoidcoreCount()
    if NEBULOUS_VOIDCORE_CURRENCY_ID == 0 then
        self.voidcoreCount = 0
        return
    end
    local info = C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo(NEBULOUS_VOIDCORE_CURRENCY_ID)
    if info then
        self.voidcoreCount = info.quantity or 0
        self.voidcoreCap   = info.maxQuantity or 0
    end
end

function Tracker:GetVoidcoreCount()
    return self.voidcoreCount or 0
end

-- Collected items: VA.charDB.collected[itemName][difficulty] = true
function Tracker:MarkCollected(itemName, difficulty)
    if not itemName then return end
    difficulty = difficulty or "unknown"
    VA.charDB.collected[itemName] = VA.charDB.collected[itemName] or {}
    VA.charDB.collected[itemName][difficulty] = true
    VA:Debug("collected:", itemName, difficulty)
end

function Tracker:UnmarkCollected(itemName, difficulty)
    if not itemName then return end
    if VA.charDB.collected[itemName] then
        VA.charDB.collected[itemName][difficulty] = nil
    end
end

function Tracker:IsCollected(itemName, difficulty)
    local entry = VA.charDB.collected[itemName]
    if not entry then return false end
    return entry[difficulty] == true
end

-- Parse loot messages to auto-mark items.
-- Item link format: |cffa335ee|Hitem:12345::::::::...|h[Item Name]|h|r
local LOOT_PATTERN_SELF = "|Hitem:(%d+):.-|h%[(.-)%]|h"
function Tracker:OnEvent(event, ...)
    if event == "CURRENCY_DISPLAY_UPDATE" then
        self:RefreshVoidcoreCount()
    elseif event == "CHAT_MSG_LOOT" and VA.db.autoDetectLoot then
        local msg, _, _, _, target = ...
        -- only credit player loot
        if target and target ~= UnitName("player") then return end
        local _, itemName = string.match(msg or "", LOOT_PATTERN_SELF)
        if itemName and VA.Items and VA.Items[itemName] then
            local difficulty = VA.Detector and VA.Detector:GetCurrentDifficulty() or "unknown"
            self:MarkCollected(itemName, difficulty)
        end
    end
end
