-- diagnostics :: log_frame — a copyable in-game view of addon messages. The
-- buffer is runtime-only and intentionally resets on reload/login.
local ADDON_NAME, ns = ...
local TDArenaLens = ns.addon
local L = ns.L
local util = ns.util

local DiagnosticLogFrame = TDArenaLens:NewModule("DiagnosticLogFrame")

function DiagnosticLogFrame:OnEnable()
   util.SetLogListener(function()
      if self.frame and self.frame:IsShown() then self:Refresh() end
   end)
end

function DiagnosticLogFrame:Toggle()
   if not self.frame then self:CreateFrame() end
   if self.frame:IsShown() then
      self.frame:Hide()
   else
      self:Refresh()
      self.frame:Show()
   end
end

function DiagnosticLogFrame:Show()
   if not self.frame then self:CreateFrame() end
   self:Refresh()
   self.frame:Show()
end

function DiagnosticLogFrame:CreateFrame()
   local frame = CreateFrame("Frame", "TDArenaLensDiagnosticLogFrame", UIParent)
   frame:SetWidth(680)
   frame:SetHeight(470)
   frame:SetPoint("CENTER")
   frame:SetFrameStrata("DIALOG")
   frame:SetMovable(true)
   frame:EnableMouse(true)
   frame:RegisterForDrag("LeftButton")
   frame:SetScript("OnDragStart", function(current) current:StartMoving() end)
   frame:SetScript("OnDragStop", function(current) current:StopMovingOrSizing() end)
   frame:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true,
      tileSize = 32,
      edgeSize = 32,
      insets = { left = 11, right = 12, top = 12, bottom = 11 },
   })

   local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
   title:SetPoint("TOP", 0, -18)
   title:SetText(L["DIAGNOSTIC_LOG_TITLE"])

   local about = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
   about:SetPoint("TOP", 0, -44)
   about:SetText(string.format(
      L["ADDON_ABOUT"],
      L["ADDON_NAME"],
      TDArenaLens.version or "?",
      TDArenaLens.author or "?"
   ))

   local commands = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
   commands:SetPoint("TOPLEFT", 24, -66)
   commands:SetPoint("TOPRIGHT", -24, -66)
   commands:SetJustifyH("LEFT")
   commands:SetText(L["COMMAND_LIST"])

   local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
   hint:SetPoint("TOPLEFT", 24, -142)
   hint:SetText(L["DIAGNOSTIC_LOG_HINT"])

   local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
   scroll:SetPoint("TOPLEFT", 24, -166)
   scroll:SetPoint("BOTTOMRIGHT", -46, 58)

   local edit = CreateFrame("EditBox", nil, scroll)
   edit:SetMultiLine(true)
   edit:SetAutoFocus(false)
   edit:EnableMouse(true)
   edit:SetFontObject(ChatFontNormal)
   edit:SetWidth(594)
   edit:SetHeight(280)
   edit:SetScript("OnEscapePressed", function(current) current:ClearFocus() end)
   scroll:SetScrollChild(edit)

   local select_all = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
   select_all:SetWidth(110)
   select_all:SetHeight(24)
   select_all:SetPoint("BOTTOMLEFT", 24, 22)
   select_all:SetText(L["SELECT_ALL"])
   select_all:SetScript("OnClick", function()
      edit:SetFocus()
      edit:HighlightText()
   end)

   local clear = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
   clear:SetWidth(90)
   clear:SetHeight(24)
   clear:SetPoint("LEFT", select_all, "RIGHT", 8, 0)
   clear:SetText(L["CLEAR"])
   clear:SetScript("OnClick", function() util.ClearLog() end)

   local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
   close:SetPoint("TOPRIGHT", -5, -5)

   frame.scroll = scroll
   frame.edit = edit
   frame:Hide()
   self.frame = frame
end

function DiagnosticLogFrame:Refresh()
   local text = util.GetLogText()
   self.frame.edit:SetText(text)
   self.frame.edit:SetHeight(math.max(280, (util.GetLogLineCount() + 1) * 15))
   self.frame.edit:ClearFocus()
   self.frame.scroll:SetVerticalScroll(0)
end
