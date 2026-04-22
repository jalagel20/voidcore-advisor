-- Voidcore Advisor: Core
-- Wires modules together, dispatches events, registers slash commands.

local addonName, VA = ...
_G.VoidcoreAdvisor = VA

VA.version = "0.1.0"

-- Default settings (account-wide). Per-character data lives in VoidcoreAdvisorCharDB.
local DEFAULTS = {
    enabled            = true,
    showHeroicRaid     = false,    -- toggle for heroic raid trinket edge cases
    minMythicPlusLevel = 10,
    showMinimapButton  = true,
    autoDetectLoot     = true,     -- parse CHAT_MSG_LOOT to mark items collected
    debug              = false,
}

local function applyDefaults(target, defaults)
    for k, v in pairs(defaults) do
        if target[k] == nil then target[k] = v end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

-- Events the advisor cares about; subscribed lazily after PLAYER_LOGIN
local LIFECYCLE_EVENTS = {
    "PLAYER_LOOT_SPEC_UPDATED",
    "CURRENCY_DISPLAY_UPDATE",
    "BONUS_ROLL_RESULT",
    "ENCOUNTER_END",
    "CHALLENGE_MODE_COMPLETED",
    "CHAT_MSG_LOOT",
    "LFG_COMPLETION_REWARD",   -- delves, prey hunts trigger via this
}

local function dispatch(event, ...)
    if not VA.db.enabled then return end
    if VA.Detector and VA.Detector.OnEvent then
        VA.Detector:OnEvent(event, ...)
    end
    if VA.Tracker and VA.Tracker.OnEvent then
        VA.Tracker:OnEvent(event, ...)
    end
end

frame:SetScript("OnEvent", function(self, event, arg1, ...)
    if event == "ADDON_LOADED" and arg1 == addonName then
        VoidcoreAdvisorDB     = VoidcoreAdvisorDB     or {}
        VoidcoreAdvisorCharDB = VoidcoreAdvisorCharDB or {}
        applyDefaults(VoidcoreAdvisorDB, DEFAULTS)
        VoidcoreAdvisorCharDB.collected = VoidcoreAdvisorCharDB.collected or {}
        -- collected schema: collected[itemName][difficulty] = true
        VA.db     = VoidcoreAdvisorDB
        VA.charDB = VoidcoreAdvisorCharDB
    elseif event == "PLAYER_LOGIN" then
        for _, e in ipairs(LIFECYCLE_EVENTS) do self:RegisterEvent(e) end
        if VA.Tracker  and VA.Tracker.Init  then VA.Tracker:Init()  end
        if VA.Detector and VA.Detector.Init then VA.Detector:Init() end
        if VA.Advisor  and VA.Advisor.Init  then VA.Advisor:Init()  end
        if VA.UI       and VA.UI.Init       then VA.UI:Init()       end
    else
        dispatch(event, arg1, ...)
    end
end)

-- Slash commands
SLASH_VOIDCORE1 = "/voidcore"
SLASH_VOIDCORE2 = "/vca"
SlashCmdList.VOIDCORE = function(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")
    if msg == "" or msg == "show" then
        if VA.UI and VA.UI.Toggle then VA.UI:Toggle() end
    elseif msg == "heroic" then
        VA.db.showHeroicRaid = not VA.db.showHeroicRaid
        print(("|cffC5A44EVoidcore Advisor:|r heroic raid recommendations %s"):format(
            VA.db.showHeroicRaid and "enabled" or "disabled"))
    elseif msg == "debug" then
        VA.db.debug = not VA.db.debug
        print(("|cffC5A44EVoidcore Advisor:|r debug %s"):format(VA.db.debug and "on" or "off"))
    elseif msg == "reset" then
        wipe(VA.charDB.collected)
        print("|cffC5A44EVoidcore Advisor:|r per-character collected items cleared.")
    else
        print("|cffC5A44EVoidcore Advisor|r commands:")
        print("  /voidcore        - open main panel")
        print("  /voidcore heroic - toggle heroic raid recommendations")
        print("  /voidcore debug  - toggle debug logging")
        print("  /voidcore reset  - clear collected-items list for this character")
    end
end

function VA:Debug(...)
    if self.db and self.db.debug then
        print("|cffC5A44E[VCA]|r", ...)
    end
end
