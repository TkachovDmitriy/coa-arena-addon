-- launcher :: minimap_button — a small, always-available entry point to the
-- match history and diagnostic log. It delegates all screen behaviour to the
-- UI modules that own those views.
local ADDON_NAME, ns = ...
local TDArenaLens = ns.addon
local L = ns.L
local util = ns.util

local MinimapButton = TDArenaLens:NewModule("MinimapButton")
local DEFAULT_ANGLE = 225
local MINIMAP_RADIUS = 80

local function toggle_module(module_name)
   local module = TDArenaLens:GetModule(module_name)
   if module and module.Toggle then
      module:Toggle()
   else
      util.Print(string.format(L["MODULE_UNAVAILABLE"], module_name))
   end
end

function MinimapButton:OnEnable()
   self:CreateButton()
end

function MinimapButton:SetPosition(angle)
   angle = tonumber(angle) or DEFAULT_ANGLE
   local radians = math.rad(angle)
   self.button:ClearAllPoints()
   self.button:SetPoint(
      "CENTER",
      Minimap,
      "CENTER",
      math.cos(radians) * MINIMAP_RADIUS,
      math.sin(radians) * MINIMAP_RADIUS
   )
end

function MinimapButton:UpdatePositionFromCursor()
   local center_x, center_y = Minimap:GetCenter()
   if not center_x or not center_y then return end

   local cursor_x, cursor_y = GetCursorPosition()
   local scale = UIParent:GetEffectiveScale()
   cursor_x, cursor_y = cursor_x / scale, cursor_y / scale

   local delta_x, delta_y = cursor_x - center_x, cursor_y - center_y
   local angle
   if delta_x == 0 then
      angle = delta_y >= 0 and 90 or 270
   else
      angle = math.deg(math.atan(delta_y / delta_x))
      if delta_x < 0 then angle = angle + 180 end
      if angle < 0 then angle = angle + 360 end
   end

   TDArenaLens.db.minimap_angle = angle
   self:SetPosition(angle)
end

function MinimapButton:CreateButton()
   local button = CreateFrame("Button", "TDArenaLensMinimapButton", Minimap)
   button:SetWidth(32)
   button:SetHeight(32)
   button:SetFrameStrata("MEDIUM")
   button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
   button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
   button:RegisterForDrag("LeftButton")

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
         toggle_module("DiagnosticLogFrame")
      else
         toggle_module("HistoryFrame")
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
      GameTooltip:AddLine(L["MINIMAP_DRAG"], 1, 1, 1)
      GameTooltip:Show()
   end)
   button:SetScript("OnLeave", function() GameTooltip:Hide() end)
   button:SetScript("OnDragStart", function(current)
      current:LockHighlight()
      current:SetScript("OnUpdate", function() self:UpdatePositionFromCursor() end)
   end)
   button:SetScript("OnDragStop", function(current)
      current:SetScript("OnUpdate", nil)
      current:UnlockHighlight()
   end)

   self.button = button
   self:SetPosition(TDArenaLens.db.minimap_angle)
end
