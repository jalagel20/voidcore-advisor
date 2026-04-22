-- Voidcore Advisor: MainFrame
-- /voidcore panel. Shows the player's full ranked recommendation list with
-- collected status and source info per item.

local _, VA = ...
VA.UI = VA.UI or {}
local UI = VA.UI

local FRAME_WIDTH, FRAME_HEIGHT = 420, 480
local GOLD = "|cffC5A44E"

local function buildFrame()
    local f = CreateFrame("Frame", "VoidcoreAdvisorMain", UIParent, "BackdropTemplate")
    f:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    f:SetPoint("CENTER")
    f:SetFrameStrata("HIGH")
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

    f.subtitle = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.subtitle:SetPoint("TOP", f.title, "BOTTOM", 0, -4)

    f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)

    f.scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    f.scroll:SetPoint("TOPLEFT", 12, -56)
    f.scroll:SetPoint("BOTTOMRIGHT", -32, 12)
    f.content = CreateFrame("Frame", nil, f.scroll)
    f.content:SetSize(FRAME_WIDTH - 44, 1)
    f.scroll:SetScrollChild(f.content)

    f.rows = {}
    f:Hide()
    return f
end

local function clearRows(f)
    for _, row in ipairs(f.rows) do row:Hide() end
end

local function makeRow(parent, idx)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(FRAME_WIDTH - 50, 22)
    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.text:SetPoint("LEFT", row, "LEFT", 4, 0)
    row.text:SetJustifyH("LEFT")
    return row
end

function UI:Render()
    local f = self.frame
    clearRows(f)

    local count = (VA.Tracker and VA.Tracker:GetVoidcoreCount()) or 0
    f.subtitle:SetText(("Nebulous Voidcores: %s%d|r"):format(GOLD, count))

    local recs = VA.Advisor:Recommend(nil, nil)
    local y, line = -4, 0
    for _, rec in ipairs(recs) do
        for _, item in ipairs(rec.items) do
            line = line + 1
            local row = f.rows[line] or makeRow(f.content, line)
            f.rows[line] = row
            local prefix = ("#%d  "):format(rec.rank)
            local color  = item.collected and "|cff666666"
                        or (rec.rank == 1 and "|cff00ff66" or "|cffffffff")
            local suffix = item.collected and "  (owned)" or ""
            row.text:SetText(prefix .. color .. item.name .. "|r" .. suffix)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", f.content, "TOPLEFT", 0, y)
            row:Show()
            y = y - 22
        end
    end
    f.content:SetHeight(math.max(1, -y + 4))
end

function UI:Init()
    self.frame = self.frame or buildFrame()
end

function UI:Toggle()
    if not self.frame then self:Init() end
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self:Render()
        self.frame:Show()
    end
end
