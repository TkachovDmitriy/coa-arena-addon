-- commands :: slash_commands — the single routing boundary for user commands.
-- Feature modules own behaviour and UI; this adapter only parses and delegates.
local ADDON_NAME, ns = ...
local TDArenaLens = ns.addon
local L = ns.L
local util = ns.util
local store = ns.arena_log.store

local SlashCommands = TDArenaLens:NewModule("SlashCommands")

function SlashCommands:OnEnable()
   SLASH_TDARENALENS1 = "/tdlens"
   SLASH_TDARENALENS2 = "/coaarena"
   SlashCmdList.TDARENALENS = function(message) self:Handle(message) end
end

function SlashCommands:ExportBgTest(session)
   local match = session:GetLastTestMatch()
   if not match then
      util.Print(L["BG_TEST_EXPORT_EMPTY"])
      return
   end

   local opponents = {}
   for _, opponent in ipairs(match.opponents) do
      table.insert(opponents, string.format(
         "%s:%s",
         opponent.name or L["UNKNOWN"],
         opponent.class_token or "?"
      ))
   end

   util.Print(string.format(
      L["BG_TEST_EXPORT"],
      match.is_complete and 1 or 0,
      match.result or "unknown",
      match.duration or 0,
      tostring(match.player_team),
      tostring(match.winner_team),
      #match.opponents,
      table.concat(opponents, ",")
   ))
end

function SlashCommands:HandleBgTest(command)
   local session = TDArenaLens:GetModule("ArenaSession")
   local setting = string.match(command, "^testbg%s+(%S+)$")

   if setting == "export" then
      self:ExportBgTest(session)
      return
   end
   if setting == "on" or setting == "off" then
      session:SetBgTestEnabled(setting == "on")
   end
   util.Print(string.format(
      L["BG_TEST_STATUS"],
      session:IsBgTestEnabled() and L["ENABLED"] or L["DISABLED"]
   ))
end

function SlashCommands:PrintDebugState()
   local session = TDArenaLens:GetModule("ArenaSession")
   local latest = store.GetLatestMatch()
   util.Print(string.format(
      L["DEBUG_STATE"],
      session and session:GetDebugState() or "missing",
      #store.GetMatches(),
      latest and latest.id or 0,
      session and session:GetTestOpponentCount() or 0
   ))
end

function SlashCommands:Handle(message)
   local command = string.lower(message or "")
   command = string.match(command, "^%s*(.-)%s*$")

   if command == "log" then
      TDArenaLens:GetModule("DiagnosticLogFrame"):Toggle()
   elseif command == "help" or command == "about" or command == "commands" then
      TDArenaLens:GetModule("DiagnosticLogFrame"):Show()
   elseif command == "testbg" or string.match(command, "^testbg%s+") then
      self:HandleBgTest(command)
   elseif command == "debug" then
      self:PrintDebugState()
   else
      TDArenaLens:GetModule("HistoryFrame"):Toggle()
   end
end
