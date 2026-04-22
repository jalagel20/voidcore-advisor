-- Voidcore Advisor: Detector
-- Determines what content the player just completed, whether it's eligible
-- for a Voidcore recommendation under current settings, and exposes the
-- "last completion context" for SpendLog correlation.

local _, VA = ...
local Detector = {}
VA.Detector = Detector

local DIFFICULTY_RAID = {
    [14] = "normal", [15] = "heroic", [16] = "mythic",
}

function Detector:Init()
    self.lastEvent      = nil
    self.lastContext    = nil    -- { contentType, difficulty, encounterID|mapID, ts }
    self.contextTTL     = 30     -- seconds a completion is "fresh" enough to attribute a spend to
end

function Detector:GetCurrentDifficulty()
    local _, instanceType, difficultyID = GetInstanceInfo()
    if instanceType == "raid" then
        return DIFFICULTY_RAID[difficultyID] or "unknown"
    elseif instanceType == "party" then
        if difficultyID == 8 then return "mythicplus" end
        if difficultyID == 23 then return "mythic" end
        return "heroic"
    end
    return "unknown"
end

function Detector:IsRaidEligible()
    local _, instanceType, difficultyID = GetInstanceInfo()
    if instanceType ~= "raid" then return false end
    if difficultyID == 16 then return true end
    if difficultyID == 15 and VA.db.showHeroicRaid then return true end
    return false
end

function Detector:IsMythicPlusEligible(keystoneLevel)
    return (keystoneLevel or 0) >= (VA.db.minMythicPlusLevel or 10)
end

-- Returns: contentType (string|nil), context table.
-- Also stores it as self.lastContext so SpendLog can grab it during the spend window.
function Detector:GetCompletionContext(event, ...)
    local contentType, ctx
    if event == "ENCOUNTER_END" then
        local encounterID, _, difficultyID, _, success = ...
        if success ~= 1 then return nil end
        if not self:IsRaidEligible() then return nil end
        contentType = "raid"
        ctx = {
            encounterID = encounterID,
            difficulty  = DIFFICULTY_RAID[difficultyID] or "unknown",
        }
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        local info = C_ChallengeMode and C_ChallengeMode.GetCompletionInfo and C_ChallengeMode.GetCompletionInfo()
        if not info then return nil end
        local mapID = info.mapChallengeModeID or info[1]
        local level = info.level or info[2]
        if not self:IsMythicPlusEligible(level) then return nil end
        contentType = "mythicplus"
        ctx = { mapID = mapID, level = level, difficulty = "mythicplus" }
    elseif event == "LFG_COMPLETION_REWARD" then
        -- TODO: distinguish Bountiful Delves vs Nightmare Prey Hunts via instance lookup
        contentType = "delve"
        ctx = { difficulty = "nightmare" }
    end

    if contentType and ctx then
        ctx.contentType = contentType
        ctx.ts          = time()
        self.lastContext = ctx
    end
    return contentType, ctx
end

-- Used by SpendLog to attribute a Voidcore spend to the most recently completed content.
-- Returns nil if no recent eligible completion (treat spend as "unknown context").
function Detector:GetLastCompletionContext()
    local ctx = self.lastContext
    if not ctx then return nil end
    if (time() - ctx.ts) > self.contextTTL then return nil end
    return ctx
end

function Detector:OnEvent(event, ...)
    self.lastEvent = event
    local contentType, ctx = self:GetCompletionContext(event, ...)
    if not contentType then return end
    VA:Debug("eligible completion:", contentType, ctx and ctx.difficulty)
    if VA.UI and VA.UI.BonusRollPopup and VA.UI.BonusRollPopup.Show then
        VA.UI.BonusRollPopup:Show(contentType, ctx)
    end
end
