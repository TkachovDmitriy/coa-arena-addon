-- diagnostics :: reporting — builds human-copyable runtime reports. Both the
-- slash-command adapter and diagnostic UI call this module.
local ADDON_NAME, ns = ...
local TDArenaLens = ns.addon
local L = ns.L
local util = ns.util
local store = ns.arena_log.store

local Reporting = TDArenaLens:NewModule("DiagnosticReporting")

local function export_field(value)
   value = tostring(value or "?")
   value = string.gsub(value, "[\r\n]+", " ")
   return string.gsub(value, "[|,]", "/")
end

local function opponent_list(match)
   local opponents = {}
   for _, opponent in ipairs(match.opponents or {}) do
      table.insert(opponents, string.format(
         "%s:%s:spec=%s:rating=%s:rating-change=%s:mmr=%s:mmr-change=%s",
         export_field(opponent.name or L["UNKNOWN"]),
         export_field(opponent.class_token),
         export_field(opponent.talent_spec),
         export_field(opponent.pvp_rating),
         export_field(opponent.rating_change),
         export_field(opponent.pre_match_mmr),
         export_field(opponent.mmr_change)
      ))
   end
   return table.concat(opponents, ",")
end

function Reporting:PrintDebugState()
   local session = TDArenaLens:GetModule("ArenaSession")
   local settings = TDArenaLens:GetModule("Settings")
   local latest = store.GetLatestMatch()
   util.Print(string.format(
      L["DEBUG_STATE"],
      session and session:GetDebugState() or "missing",
      settings and settings:IsDebugEnabled() and L["ENABLED"] or L["DISABLED"],
      #store.GetMatches(),
      latest and latest.id or 0,
      session and session:GetTestOpponentCount() or 0,
      self:GetFailedModuleCount()
   ))
end

function Reporting:GetFailedModuleCount()
   local count = 0
   for _, module in ipairs(TDArenaLens.module_order) do
      if module.failed then count = count + 1 end
   end
   return count
end

function Reporting:SetDebugEnabled(enabled)
   TDArenaLens:GetModule("Settings"):SetDebugEnabled(enabled)
   self:PrintDebugState()
end

function Reporting:ToggleDebugEnabled()
   local settings = TDArenaLens:GetModule("Settings")
   self:SetDebugEnabled(not settings:IsDebugEnabled())
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
