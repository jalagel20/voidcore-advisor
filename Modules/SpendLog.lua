-- Voidcore Advisor: SpendLog
-- Tracks every Voidcore spend with the surrounding context (content, difficulty,
-- boss/dungeon ID, cost) and correlates the spend with whatever loot follows
-- so the Advisor can deprioritize content the player has already burned attempts on.
--
-- Detection model:
--   1. Tracker watches the Voidcore currency. A decrease of 1 or 2 = a spend.
--   2. SpendLog opens a "pending spend" with the Detector's current encounter context.
--   3. Loot events within CORRELATION_WINDOW seconds get attached to that spend.
--   4. After CORRELATION_WINDOW, if no loot arrived, the spend is closed as "no drop".
--   5. Stats are aggregated into VA.charDB.attempts for the Advisor to read.

local _, VA = ...
local SpendLog = {}
VA.SpendLog = SpendLog

local CORRELATION_WINDOW = 6 -- seconds between currency-drop and loot event

-- Per-character persisted state lives on VA.charDB:
--   spendLog: append-only history { ts, contentType, difficulty, contextID, cost, outcomeItem }
--   attempts: aggregated counters keyed by content fingerprint
function SpendLog:Init()
    VA.charDB.spendLog = VA.charDB.spendLog or {}
    VA.charDB.attempts = VA.charDB.attempts or {}
    self.pending = nil -- {ts, contentType, difficulty, contextID, cost, timer}
end

local function fingerprint(contentType, difficulty, contextID)
    return string.format("%s:%s:%s", contentType or "?", difficulty or "?", tostring(contextID or "?"))
end

-- Called by Tracker when the Voidcore currency drops.
function SpendLog:RecordSpend(cost)
    local ctx = VA.Detector and VA.Detector:GetLastCompletionContext() or nil
    local contentType = ctx and ctx.contentType or "unknown"
    local difficulty  = ctx and ctx.difficulty  or "unknown"
    local contextID   = ctx and (ctx.encounterID or ctx.mapID) or nil

    self.pending = {
        ts          = time(),
        contentType = contentType,
        difficulty  = difficulty,
        contextID   = contextID,
        cost        = cost or 1,
        outcomeItem = nil,
    }
    VA:Debug("spend opened:", fingerprint(contentType, difficulty, contextID), "cost", cost)

    -- After the correlation window, finalize whatever we have.
    C_Timer.After(CORRELATION_WINDOW, function()
        if self.pending then self:_finalize() end
    end)
end

-- Called when loot arrives that we recognize as a tracked BiS item.
-- Returns true if attached to a pending spend (i.e. came from a bonus roll).
function SpendLog:AttachLoot(itemName)
    if not self.pending then return false end
    if (time() - self.pending.ts) > CORRELATION_WINDOW then return false end
    self.pending.outcomeItem = itemName
    self:_finalize()
    return true
end

function SpendLog:_finalize()
    local p = self.pending
    self.pending = nil
    if not p then return end

    table.insert(VA.charDB.spendLog, {
        ts          = p.ts,
        contentType = p.contentType,
        difficulty  = p.difficulty,
        contextID   = p.contextID,
        cost        = p.cost,
        outcomeItem = p.outcomeItem,
    })
    -- Cap log to last 200 entries to bound disk size.
    if #VA.charDB.spendLog > 200 then
        table.remove(VA.charDB.spendLog, 1)
    end

    local key = fingerprint(p.contentType, p.difficulty, p.contextID)
    local agg = VA.charDB.attempts[key] or { rolls = 0, hits = 0, lastTs = 0 }
    agg.rolls  = agg.rolls + 1
    agg.lastTs = p.ts
    if p.outcomeItem then agg.hits = agg.hits + 1 end
    VA.charDB.attempts[key] = agg
    VA:Debug("spend finalized:", key, "outcome:", p.outcomeItem or "no drop")
end

-- Lookup helper for Advisor: how many times has the player rolled into a pool
-- that would have included this content? We aggregate by contentType+difficulty
-- (ignoring contextID) so scoring isn't fragmented per-boss when a player has
-- only run a few times.
function SpendLog:GetAttemptStats(contentType, difficulty)
    local rolls, hits = 0, 0
    for key, agg in pairs(VA.charDB.attempts) do
        local ct, d = key:match("^(.-):(.-):")
        if (not contentType or ct == contentType) and (not difficulty or d == difficulty) then
            rolls = rolls + agg.rolls
            hits  = hits  + agg.hits
        end
    end
    return rolls, hits
end

-- Per-context lookup (boss-specific) for the popup footnote.
function SpendLog:GetContextStats(contentType, difficulty, contextID)
    local key = fingerprint(contentType, difficulty, contextID)
    local agg = VA.charDB.attempts[key]
    if not agg then return 0, 0 end
    return agg.rolls, agg.hits
end
