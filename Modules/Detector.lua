-- Voidcore Advisor: Detector
-- Determines what content the player just completed and whether it's eligible
-- for a Voidcore recommendation under current settings.

local _, VA = ...
local Detector = {}
VA.Detector = Detector

-- Eligibility rules per user config:
--   - Mythic raid: always eligible
--   - Heroic raid: only if VA.db.showHeroicRaid
--   - M+ runs:    only at or above VA.db.minMythicPlusLevel (default 10)
--   - Bountiful Delves & Nightmare Prey Hunts: always eligible
function Detector:Init()
    self.lastEvent = nil
end

local DIFFICULTY_RAID = {
    [14] = "normal",
    [15] = "heroic",
    [16] = "mythic",
}

function Detector:GetCurrentDifficulty()
    local _, instanceType, difficultyID = GetInstanceInfo()
    if instanceType == "raid" then
        return DIFFICULTY_RAID[difficultyID] or "unknown"
    elseif instanceType == "party" then
        if difficultyID == 8 then return "mythicplus" end
        if difficultyID == 23 then return "mythic" end
        return "heroic" -- coarse fallback
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

-- Returns: contentType ("raid"|"mythicplus"|"delve"|"preyhunt"|nil), context table
function Detector:GetCompletionContext(event, ...)
    if event == "ENCOUNTER_END" then
        local encounterID, _, difficultyID, _, success = ...
        if success ~= 1 then return nil end
        if not self:IsRaidEligible() then return nil end
        return "raid", {
            encounterID = encounterID,
            difficulty  = DIFFICULTY_RAID[difficultyID] or "unknown",
        }
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        local info = C_ChallengeMode and C_ChallengeMode.GetCompletionInfo()
        if not info then return nil end
        local mapID, level = info.mapChallengeModeID or info[1], info.level or info[2]
        if not self:IsMythicPlusEligible(level) then return nil end
        return "mythicplus", { mapID = mapID, level = level, difficulty = "mythicplus" }
    elseif event == "LFG_COMPLETION_REWARD" then
        -- TODO: distinguish Bountiful Delves vs Nightmare Prey Hunts via instance lookup
        return "delve", { difficulty = "nightmare" }
    end
    return nil
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
