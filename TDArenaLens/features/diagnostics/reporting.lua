-- diagnostics :: reporting — builds human-copyable runtime reports. Both the
-- slash-command adapter and diagnostic UI call this module.
local ADDON_NAME, ns = ...
local TDArenaLens = ns.addon
local L = ns.L
local util = ns.util
local store = ns.arena_log.store

local Reporting = TDArenaLens:NewModule("DiagnosticReporting")

local function opponent_list(match)
   local opponents = {}
   for _, opponent in ipairs(match.opponents or {}) do
      table.insert(opponents, string.format(
         "%s:%s",
         opponent.name or L["UNKNOWN"],
         opponent.class_token or "?"
      ))
   end
   return table.concat(opponents, ",")
end

function Reporting:PrintDebugState()
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

function Reporting:PrintBgTestStatus()
   local session = TDArenaLens:GetModule("ArenaSession")
   util.Print(string.format(
      L["BG_TEST_STATUS"],
      session:IsBgTestEnabled() and L["ENABLED"] or L["DISABLED"]
   ))
end

function Reporting:SetBgTestEnabled(enabled)
   TDArenaLens:GetModule("ArenaSession"):SetBgTestEnabled(enabled)
   self:PrintBgTestStatus()
end

function Reporting:ExportBgTest()
   local match = TDArenaLens:GetModule("ArenaSession"):GetLastTestMatch()
   if not match then
      util.Print(L["BG_TEST_EXPORT_EMPTY"])
      return
   end

   util.Print(string.format(
      L["BG_TEST_EXPORT"],
      match.is_complete and 1 or 0,
      match.result or "unknown",
      match.duration or 0,
      tostring(match.player_team),
      tostring(match.winner_team),
      #(match.opponents or {}),
      opponent_list(match)
   ))
end

function Reporting:ExportLatestArena()
   local match = store.GetLatestMatch()
   if not match then
      util.Print(L["ARENA_EXPORT_EMPTY"])
      return
   end

   util.Print(string.format(
      L["ARENA_EXPORT"],
      match.id or 0,
      match.is_complete and 1 or 0,
      match.is_rated and 1 or 0,
      match.result or "unknown",
      match.duration or 0,
      tostring(match.player_team),
      tostring(match.winner_team),
      tostring(match.rating_before),
      tostring(match.rating_after),
      tostring(match.rating_change),
      #(match.opponents or {}),
      opponent_list(match)
   ))
end
