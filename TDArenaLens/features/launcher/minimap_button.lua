-- launcher :: minimap_button — a small, always-available entry point to the
-- match history and diagnostic log. It delegates all screen behaviour to the
-- UI modules that own those views.
local ADDON_NAME, ns = ...
local TDArenaLens = ns.addon
local L = ns.L

local MinimapButton = TDArenaLens:NewModule("MinimapButton")

function MinimapButton:OnEnable()
   self:CreateButton()
end

function MinimapButton:CreateButton()
   local button = CreateFrame("Button", "TDArenaLensMinimapButton", Minimap)
   button:SetWidth(32)
   button:SetHeight(32)
   button:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -4, -4)
   button:SetFrameStrata("MEDIUM")
   button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
   button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

   local icon = button:CreateTexture(nil, "ARTWORK")
   icon:SetTexture("Interface\\Icons\\Achievement_Arena_2v2_7")
   icon:SetPoint("TOPLEFT", 7, -6)
   icon:SetPoint("BOTTOMRIGHT", -6, 7)

   local border = button:CreateTexture(nil, "OVERLAY")
   border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
   border:SetWidth(54)
   border:SetHeight(54)
   border:SetPoint("TOPLEFT")

   button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
   button:SetScript("OnClick", function(_, mouse_button)
      if mouse_button == "RightButton" then
         TDArenaLens:GetModule("DiagnosticLogFrame"):Toggle()
      else
         TDArenaLens:GetModule("HistoryFrame"):Toggle()
      end
   end)
   button:SetScript("OnEnter", function(current)
      GameTooltip:SetOwner(current, "ANCHOR_LEFT")
      GameTooltip:AddLine(string.format(
         L["ADDON_ABOUT"],
         L["ADDON_NAME"],
         TDArenaLens.version or "?",
         TDArenaLens.author or "?"
      ))
      GameTooltip:AddLine(L["MINIMAP_LEFT_CLICK"], 1, 1, 1)
      GameTooltip:AddLine(L["MINIMAP_RIGHT_CLICK"], 1, 1, 1)
      GameTooltip:Show()
   end)
   button:SetScript("OnLeave", function() GameTooltip:Hide() end)

   self.button = button
end
