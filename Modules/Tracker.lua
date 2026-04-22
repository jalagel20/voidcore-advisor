-- Voidcore Advisor: Tracker
-- Tracks Nebulous Voidcore count, weekly cap, and collected BiS items per difficulty.
-- Also detects Voidcore spends (currency decreases) and forwards them to SpendLog
-- so the Advisor can deprioritize content the player has already burned attempts on.

local _, VA = ...
local Tracker = {}
VA.Tracker = Tracker

-- TODO: confirm currency ID for Nebulous Voidcore once datamined / live.
local NEBULOUS_VOIDCORE_CURRENCY_ID = 0

local DIFFICULTY_RAID = {
    [14] = "normal", [15] = "heroic", [16] = "mythic",
}

function Tracker:Init()
    self.lastVoidcoreCount = nil
    self:RefreshVoidcoreCount(true)
end

function Tracker:RefreshVoidcoreCount(silent)
    if NEBULOUS_VOIDCORE_CURRENCY_ID == 0 or not C_CurrencyInfo then
        self.voidcoreCount = self.voidcoreCount or 0
        return
    end
    local info = C_CurrencyInfo.GetCurrencyInfo(NEBULOUS_VOIDCORE_CURRENCY_ID)
    if not info then return end
    local newCount = info.quantity or 0
    self.voidcoreCap  = info.maxQuantity or 0

    -- Detect a spend: currency dropped since last reading. Cost = magnitude of drop.
    if not silent and self.lastVoidcoreCount and newCount < self.lastVoidcoreCount then
        local cost = self.lastVoidcoreCount - newCount
        if VA.SpendLog then VA.SpendLog:RecordSpend(cost) end
    end
    self.lastVoidcoreCount = newCount
    self.voidcoreCount = newCount
end

function Tracker:GetVoidcoreCount()
    return self.voidcoreCount or 0
end

-- Collected items: VA.charDB.collected[itemName][difficulty] = true
function Tracker:MarkCollected(itemName, difficulty, fromBonusRoll)
    if not itemName then return end
    difficulty = difficulty or "unknown"
    VA.charDB.collected[itemName] = VA.charDB.collected[itemName] or {}
    VA.charDB.collected[itemName][difficulty] = true
    VA:Debug("collected:", itemName, difficulty, fromBonusRoll and "(bonus roll)" or "(natural)")
    -- If the UI panel is open, refresh it so the user sees the change immediately.
    if VA.UI and VA.UI.frame and VA.UI.frame:IsShown() and VA.UI.Render then
        VA.UI:Render()
    end
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
    if difficulty and entry[difficulty] then return true end
    -- "owned anywhere" fallback: if collected on any difficulty, treat as owned for slot-saturation.
    for _ in pairs(entry) do return true end
    return false
end

-- Loot detection. Item link format:
--   |cffa335ee|Hitem:12345::::::::...|h[Item Name]|h|r
local LOOT_PATTERN = "|Hitem:(%d+):.-|h%[(.-)%]|h"

local function resolveItemFromLink(link)
    if not link then return nil, nil end
    local idStr, name = link:match(LOOT_PATTERN)
    if not idStr then return nil, nil end
    local id = tonumber(idStr)
    -- Prefer ID-based lookup (handles localization + reskinned items with same name).
    local trackedName = VA.ItemsByID and VA.ItemsByID[id]
    if trackedName then return trackedName, id end
    if name and VA.Items and VA.Items[name] then return name, id end
    return nil, id
end

function Tracker:OnEvent(event, ...)
    if event == "CURRENCY_DISPLAY_UPDATE" then
        local currencyID = ...
        if NEBULOUS_VOIDCORE_CURRENCY_ID == 0 or currencyID == NEBULOUS_VOIDCORE_CURRENCY_ID then
            self:RefreshVoidcoreCount(false)
        end

    elseif event == "CHAT_MSG_LOOT" and VA.db.autoDetectLoot then
        local msg, _, _, _, target = ...
        if target and target ~= UnitName("player") then return end
        local trackedName, _ = resolveItemFromLink(msg or "")
        if trackedName then
            local difficulty = (VA.Detector and VA.Detector:GetCurrentDifficulty()) or "unknown"
            local fromBonus  = VA.SpendLog and VA.SpendLog:AttachLoot(trackedName) or false
            self:MarkCollected(trackedName, difficulty, fromBonus)
        end

    elseif event == "ENCOUNTER_LOOT_RECEIVED" and VA.db.autoDetectLoot then
        -- Stronger signal than CHAT_MSG_LOOT for raid encounter drops.
        -- Args: encounterID, itemID, itemLink, quantity, playerName, className
        local _, itemID, itemLink, _, playerName = ...
        if playerName and playerName ~= UnitName("player") then return end
        local trackedName = (VA.ItemsByID and VA.ItemsByID[itemID])
                         or (function() local n = resolveItemFromLink(itemLink); return n end)()
        if trackedName then
            local difficulty = (VA.Detector and VA.Detector:GetCurrentDifficulty()) or "unknown"
            local fromBonus  = VA.SpendLog and VA.SpendLog:AttachLoot(trackedName) or false
            self:MarkCollected(trackedName, difficulty, fromBonus)
        end

    elseif event == "BAG_UPDATE_DELAYED" and VA.db.autoDetectLoot then
        -- Catches items that bypass chat (auto-loot, mail, vendor refund). Cheap;
        -- BAG_UPDATE_DELAYED is debounced by Blizzard so this fires sparingly.
        self:ScanBags()

    elseif event == "BONUS_ROLL_RESULT" then
        -- Legacy event still wired for safety; if it fires for Voidcore rolls, attach.
        -- Args: success, rewardType, rewardLink, rewardQuantity, rewardSpecID
        local _success, rewardType, rewardLink = ...
        if rewardType == "item" then
            local trackedName = resolveItemFromLink(rewardLink)
            if trackedName then
                local difficulty = (VA.Detector and VA.Detector:GetCurrentDifficulty()) or "unknown"
                if VA.SpendLog then VA.SpendLog:AttachLoot(trackedName) end
                self:MarkCollected(trackedName, difficulty, true)
            end
        end
    end
end

-- One-shot bag scan: marks any tracked items already in the player's bags as collected.
-- Called once after PLAYER_LOGIN so existing-character data isn't stuck saying "not owned".
function Tracker:ScanBags()
    if not C_Container or not C_Container.GetContainerNumSlots then return end
    local difficulty = "unknown"
    for bag = 0, NUM_BAG_SLOTS or 4 do
        local numSlots = C_Container.GetContainerNumSlots(bag) or 0
        for slot = 1, numSlots do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID then
                local trackedName = VA.ItemsByID and VA.ItemsByID[info.itemID]
                if trackedName and not self:IsCollected(trackedName, difficulty) then
                    self:MarkCollected(trackedName, difficulty, false)
                end
            end
        end
    end
end
