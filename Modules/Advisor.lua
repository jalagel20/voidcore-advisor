-- Voidcore Advisor: Advisor
-- Core ranking logic. Given player spec, content type, and difficulty, returns
-- ordered list of items the player should hope for from a Voidcore roll.

local _, VA = ...
local Advisor = {}
VA.Advisor = Advisor

function Advisor:Init() end

-- Returns the player's current loot spec ID (falls back to active spec).
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

-- Returns ordered recommendation list for the player, annotated with status.
--   contentType: "raid" | "mythicplus" | "delve" | "preyhunt" (optional filter)
--   difficulty:  "heroic" | "mythic" | "mythicplus" | ... (optional filter)
--
-- Output: { { rank, items = { {name, collected, source} }, anyAvailable } }
function Advisor:Recommend(contentType, difficulty)
    local classID = self:GetClassID()
    local specID  = self:GetLootSpecID()
    if not classID or not specID then return {} end

    local specRecs = VA.Recommendations[classID] and VA.Recommendations[classID][specID]
    if not specRecs then return {} end

    local out = {}
    for _, rec in ipairs(specRecs) do
        local itemEntries, anyAvailable = {}, false
        for _, itemName in ipairs(rec.items) do
            local source = VA.Sources and VA.Sources[itemName]
            local matchesContent = (not contentType) or (not source) or source.contentType == contentType
            local matchesDiff    = (not difficulty)  or (not source) or self:_diffMatches(source.difficulty, difficulty)
            local collected      = VA.Tracker and VA.Tracker:IsCollected(itemName, difficulty or "unknown")
            local visible        = matchesContent and matchesDiff
            if visible and not collected then anyAvailable = true end
            table.insert(itemEntries, {
                name      = itemName,
                collected = collected or false,
                visible   = visible,
                source    = source,
            })
        end
        table.insert(out, {
            rank          = rec.rank,
            items         = itemEntries,
            anyAvailable  = anyAvailable,
        })
    end
    return out
end

function Advisor:_diffMatches(allowed, target)
    if not allowed then return true end
    for _, d in ipairs(allowed) do if d == target then return true end end
    return false
end

-- Convenience: should the player spend a Voidcore on this content right now?
-- Returns: shouldRoll (bool), reason (string), topAvailable (item entry or nil)
function Advisor:ShouldRoll(contentType, difficulty)
    local recs = self:Recommend(contentType, difficulty)
    for _, rec in ipairs(recs) do
        if rec.anyAvailable then
            for _, item in ipairs(rec.items) do
                if item.visible and not item.collected then
                    local cost = (contentType == "raid") and 2 or 1
                    return true,
                        ("Roll: rank #%d (%s) still available — costs %d core%s")
                            :format(rec.rank, item.name, cost, cost == 1 and "" or "s"),
                        item
                end
            end
        end
    end
    return false, "Skip: no remaining BiS items in this content's pool", nil
end
