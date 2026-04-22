-- Voidcore Advisor: Advisor
-- Core ranking logic. Given player spec, content type, and difficulty, returns
-- ordered list of items the player should hope for from a Voidcore roll.
--
-- Scoring model (lower = higher priority):
--   baseScore       = rec.rank
--   attemptPenalty  = min(ATTEMPT_PENALTY_CAP, attempts * ATTEMPT_PENALTY_PER_TRY)
--   slotSaturation  = SLOT_SATURATION_PENALTY if a higher-ranked item in the same slot is owned
--   collectedItems  = excluded entirely from "available" set
--
-- The result is still presented in the original Wowhead ranking order, but
-- ShouldRoll() and the popup verdict use the score-adjusted top pick.

local _, VA = ...
local Advisor = {}
VA.Advisor = Advisor

local ATTEMPT_PENALTY_PER_TRY  = 0.4
local ATTEMPT_PENALTY_CAP      = 1.5
local SLOT_SATURATION_PENALTY  = 1.0

function Advisor:Init() end

function Advisor:GetLootSpecID()
    local lootSpec = GetLootSpecialization and GetLootSpecialization() or 0
    if lootSpec == 0 then
        local idx = GetSpecialization()
        if idx then return (GetSpecializationInfo(idx)) end
        return nil
    end
    return lootSpec
end

function Advisor:GetClassID()
    local _, _, classID = UnitClass("player")
    return classID
end

-- Build the slot-saturation map: which slots already have a higher-ranked item owned?
-- Returns: { ["trinket"] = true, ["back"] = true, ... }
local function buildOwnedSlots(specRecs, difficulty)
    local owned = {}
    for _, rec in ipairs(specRecs) do
        for _, itemName in ipairs(rec.items) do
            if VA.Tracker and VA.Tracker:IsCollected(itemName, difficulty) then
                local meta = VA.Items and VA.Items[itemName]
                if meta and meta.slot then owned[meta.slot] = true end
            end
        end
    end
    return owned
end

-- Returns ordered recommendation list for the player, annotated with status + score.
function Advisor:Recommend(contentType, difficulty)
    local classID = self:GetClassID()
    local specID  = self:GetLootSpecID()
    if not classID or not specID then return {} end

    local specRecs = VA.Recommendations[classID] and VA.Recommendations[classID][specID]
    if not specRecs then return {} end

    local ownedSlots = buildOwnedSlots(specRecs, difficulty)
    local attempts = 0
    if VA.SpendLog then
        attempts = select(1, VA.SpendLog:GetAttemptStats(contentType, difficulty))
    end
    local attemptPenalty = math.min(ATTEMPT_PENALTY_CAP, (attempts or 0) * ATTEMPT_PENALTY_PER_TRY)

    local out = {}
    for _, rec in ipairs(specRecs) do
        local itemEntries, anyAvailable, bestScore = {}, false, math.huge
        for _, itemName in ipairs(rec.items) do
            local source = VA.Sources and VA.Sources[itemName]
            local matchesContent = (not contentType) or (not source) or source.contentType == contentType
            local matchesDiff    = (not difficulty)  or (not source) or self:_diffMatches(source.difficulty, difficulty)
            local collected      = VA.Tracker and VA.Tracker:IsCollected(itemName, difficulty)
            local meta           = VA.Items and VA.Items[itemName]
            local slot           = meta and meta.slot
            local visible        = matchesContent and matchesDiff
            local score          = rec.rank + attemptPenalty
            if slot and ownedSlots[slot] and not collected then
                score = score + SLOT_SATURATION_PENALTY
            end
            if visible and not collected then
                anyAvailable = true
                if score < bestScore then bestScore = score end
            end
            table.insert(itemEntries, {
                name      = itemName,
                id        = meta and meta.id,
                slot      = slot,
                collected = collected or false,
                visible   = visible,
                score     = score,
                slotSaturated = slot and ownedSlots[slot] or false,
            })
        end
        table.insert(out, {
            rank          = rec.rank,
            items         = itemEntries,
            anyAvailable  = anyAvailable,
            bestScore     = bestScore,
        })
    end
    return out, { attempts = attempts, attemptPenalty = attemptPenalty }
end

function Advisor:_diffMatches(allowed, target)
    if not allowed then return true end
    for _, d in ipairs(allowed) do if d == target then return true end end
    return false
end

-- Convenience: should the player spend a Voidcore on this content right now?
-- Picks the lowest-score available item across all ranks (not just rank #1).
function Advisor:ShouldRoll(contentType, difficulty)
    local recs, meta = self:Recommend(contentType, difficulty)
    local best, bestRank
    for _, rec in ipairs(recs) do
        for _, item in ipairs(rec.items) do
            if item.visible and not item.collected then
                if not best or item.score < best.score then
                    best, bestRank = item, rec.rank
                end
            end
        end
    end
    if not best then
        return false, "Skip: no remaining BiS items in this content's pool", nil, meta
    end
    local cost = (contentType == "raid") and 2 or 1
    local note = ""
    if meta and meta.attempts and meta.attempts >= 3 then
        note = (" — already rolled %dx here, may want to spread attempts"):format(meta.attempts)
    elseif best.slotSaturated then
        note = " — note: slot already filled by a higher-ranked piece"
    end
    return true,
        ("Roll: rank #%d (%s) still available — costs %d core%s%s"):format(
            bestRank, best.name, cost, cost == 1 and "" or "s", note),
        best, meta
end
