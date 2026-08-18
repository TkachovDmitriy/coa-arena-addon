-- arena_log :: history_frame — in-game UI to browse logged matches (this
-- session + persisted history). Reads through ns.arena_log.store.
local ADDON_NAME, ns = ...
local CoAArena = ns.addon
local L = ns.L
local util = ns.util
local store = ns.arena_log.store

local HistoryFrame = CoAArena:NewModule("HistoryFrame")

function HistoryFrame:OnEnable()
   SLASH_COAARENA1 = "/coaarena"
   SlashCmdList.COAARENA = function(message)
      self:HandleCommand(message)
   end
end

-- Show/hide the match-history browser, building it lazily on first open.
function HistoryFrame:Toggle()
   if not self.frame then self:CreateFrame() end
   if self.frame:IsShown() then
      self.frame:Hide()
   else
      self:Refresh()
      self.frame:Show()
   end
end

function HistoryFrame:CreateFrame()
   local frame = CreateFrame("Frame", "CoAArenaHistoryFrame", UIParent)
   frame:SetWidth(560)
   frame:SetHeight(360)
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
   title:SetText(L["HISTORY_TITLE"])

   local content = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
   content:SetPoint("TOPLEFT", 22, -52)
   content:SetPoint("BOTTOMRIGHT", -22, 22)
   content:SetJustifyH("LEFT")
   content:SetJustifyV("TOP")

   local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
   close:SetPoint("TOPRIGHT", -5, -5)

   frame.content = content
   frame:Hide()
   self.frame = frame
end

function HistoryFrame:Refresh()
   local matches = store.GetMatches()
   if #matches == 0 then
      self.frame.content:SetText(L["NO_MATCHES"])
      return
   end

   local lines = {}
   local first = math.max(1, #matches - 9)
   for index = #matches, first, -1 do
      local match = matches[index]
      local opponent_names = {}
      for _, opponent in ipairs(match.opponents) do
         table.insert(opponent_names, opponent.name or L["UNKNOWN"])
      end
      local result = L[string.upper(match.result or "unknown")]
      local rating = match.rating_change and string.format("%+d", match.rating_change) or "--"
      table.insert(lines, string.format(
         "#%d  %s  %s  [%s]  %s",
         match.id,
         date("%Y-%m-%d %H:%M", match.ended_at),
         result,
         rating,
         table.concat(opponent_names, ", ")
      ))
   end
   self.frame.content:SetText(table.concat(lines, "\n\n"))
end

function HistoryFrame:HandleCommand(message)
   local command = string.lower(message or "")
   local test_setting = string.match(command, "^testbg%s+(%S+)$")
   if command == "testbg" or string.match(command, "^testbg%s+") then
      local session = CoAArena:GetModule("ArenaSession")
      if test_setting == "on" or test_setting == "off" then
         session:SetBgTestEnabled(test_setting == "on")
      end
      util.Print(string.format(
         L["BG_TEST_STATUS"],
         session:IsBgTestEnabled() and L["ENABLED"] or L["DISABLED"]
      ))
      return
   end

   if command == "debug" then
      local session = CoAArena:GetModule("ArenaSession")
      local latest = store.GetLatestMatch()
      local last_test = session and session:GetLastTestMatch()
      util.Print(string.format(
         L["DEBUG_STATE"],
         session and session:GetDebugState() or "missing",
         #store.GetMatches(),
         latest and latest.id or 0,
         last_test and #last_test.opponents or 0
      ))
      return
   end

   self:Toggle()
end
