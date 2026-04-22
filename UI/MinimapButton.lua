-- Voidcore Advisor: MinimapButton
-- Lightweight minimap icon (no LibDBIcon dependency).

local _, VA = ...
VA.UI = VA.UI or {}

local function build()
    local btn = CreateFrame("Button", "VoidcoreAdvisorMinimap", Minimap)
    btn:SetSize(28, 28)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:SetPoint("CENTER", Minimap, "CENTER", 70, 0)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:RegisterForDrag("LeftButton")
    btn:SetMovable(true)

    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\inv_misc_voidcore")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT")

    btn:SetScript("OnClick", function()
        VA.UI:Toggle()
    end)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("|cffC5A44EVoidcore Advisor|r")
        GameTooltip:AddLine("Click to open panel", 1, 1, 1)
        local count = (VA.Tracker and VA.Tracker:GetVoidcoreCount()) or 0
        GameTooltip:AddLine(("Voidcores: %d"):format(count), 0.77, 0.64, 0.31)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    return btn
end

-- Hook into UI:Init
local origInit = VA.UI.Init
function VA.UI:Init(...)
    if origInit then origInit(self, ...) end
    if VA.db and VA.db.showMinimapButton then
        self.minimap = self.minimap or build()
    end
end
