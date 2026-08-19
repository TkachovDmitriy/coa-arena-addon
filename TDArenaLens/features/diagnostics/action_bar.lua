-- diagnostics :: action_bar — controls embedded in the diagnostic log window.
-- Report generation remains owned by DiagnosticReporting.
local ADDON_NAME, ns = ...
local TDArenaLens = ns.addon
local L = ns.L

ns.diagnostics = ns.diagnostics or {}
local action_bar = {}
ns.diagnostics.action_bar = action_bar

local function create_button(parent, previous, text, width, on_click)
   local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
   button:SetWidth(width)
   button:SetHeight(24)
   if previous then
      button:SetPoint("LEFT", previous, "RIGHT", 8, 0)
   else
      button:SetPoint("BOTTOMLEFT", 24, 54)
   end
   button:SetText(text)
   button:SetScript("OnClick", on_click)
   return button
end

function action_bar.Create(parent)
   local reporting = TDArenaLens:GetModule("DiagnosticReporting")
   local buttons = {}

   buttons.status = create_button(parent, nil, L["STATUS"], 76, function()
      reporting:PrintDebugState()
   end)
   buttons.debug_toggle = create_button(
      parent, buttons.status, L["DEBUG_TOGGLE"], 76,
      function() reporting:ToggleDebugEnabled() end
   )
   buttons.arena_export = create_button(
      parent, buttons.debug_toggle, L["ARENA_EXPORT_BUTTON"], 104,
      function() reporting:ExportLatestArena() end
   )
   buttons.bg_start = create_button(
      parent, buttons.arena_export, L["BG_START"], 82,
      function() reporting:SetBgTestEnabled(true) end
   )
   buttons.bg_stop = create_button(
      parent, buttons.bg_start, L["BG_STOP"], 82,
      function() reporting:SetBgTestEnabled(false) end
   )
   buttons.bg_export = create_button(
      parent, buttons.bg_stop, L["BG_EXPORT_BUTTON"], 94,
      function() reporting:ExportBgTest() end
   )

   return buttons
end
