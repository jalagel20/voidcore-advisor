-- Voidcore Advisor: BonusRollPopup
-- Compact overlay shown next to Blizzard's bonus roll prompt with the addon's
-- recommendation for whether to spend a Nebulous Voidcore.

local _, VA = ...
VA.UI = VA.UI or {}
local Popup = {}
VA.UI.BonusRollPopup = Popup

local FRAME_WIDTH, FRAME_HEIGHT = 280, 140
local GOLD = "|cffC5A44E"

local function buildFrame()
    local f = CreateFrame("Frame", "VoidcoreAdvisorPopup", UIParent, "BackdropTemplate")
    f:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    f:SetPoint("CENTER", UIParent, "CENTER", 250, 0)
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    if f.SetBackdrop then
        f:SetBackdrop({
            bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        f:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
        f:SetBackdropBorderColor(0.77, 0.64, 0.31, 1)
    end

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOP", f, "TOP", 0, -10)
    f.title:SetText(GOLD .. "Voidcore Advisor|r")

    f.verdict = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.verdict:SetPoint("TOP", f.title, "BOTTOM", 0, -8)
    f.verdict:SetWidth(FRAME_WIDTH - 20)
    f.verdict:SetJustifyH("CENTER")

    f.detail = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.detail:SetPoint("TOP", f.verdict, "BOTTOM", 0, -6)
    f.detail:SetWidth(FRAME_WIDTH - 20)
    f.detail:SetJustifyH("CENTER")

    f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)

    f:Hide()
    return f
end

function Popup:Show(contentType, ctx)
    self.frame = self.frame or buildFrame()
    local should, reason, top = VA.Advisor:ShouldRoll(contentType, ctx and ctx.difficulty)
    local color = should and "|cff00ff66" or "|cffff5050"
    self.frame.verdict:SetText(color .. (should and "ROLL" or "SKIP") .. "|r")
    self.frame.detail:SetText(reason or "")
    self.frame:Show()
    -- auto-hide after 20s if user ignores
    if self.timer then self.timer:Cancel() end
    self.timer = C_Timer.NewTimer(20, function() self.frame:Hide() end)
end

function Popup:Hide()
    if self.frame then self.frame:Hide() end
end
