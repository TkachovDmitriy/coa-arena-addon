-- arena_log :: arena_session — detects entering/leaving an arena and drives the
-- rest of the domain (opponent capture, persistence). See docs/addon-plan.md,
-- Phase 1.
local ADDON_NAME, ns = ...
local CoAArena = ns.addon
local L = ns.L
local util = ns.util
local store = ns.arena_log.store

local ArenaSession = CoAArena:NewModule("ArenaSession")

local function base_name(name)
   return name and string.match(name, "^[^-]+")
end

function ArenaSession:OnEnable()
   store.Init(CoAArena.charDB)
   CoAArena:RegisterEvent("PLAYER_ENTERING_WORLD", self)
   CoAArena:RegisterEvent("ZONE_CHANGED_NEW_AREA", self)
   CoAArena:RegisterEvent("UPDATE_BATTLEFIELD_SCORE", self)
   self.phase = "idle"
   self.bg_test_enabled = false
   self.last_test_match = nil
   self:UpdateZone()
end

function ArenaSession:PLAYER_ENTERING_WORLD()
   self:UpdateZone()
end

function ArenaSession:ZONE_CHANGED_NEW_AREA()
   self:UpdateZone()
end

-- Transition detection: real arenas always take precedence. Battlegrounds are
-- accepted only while the explicit, runtime-only test mode is enabled.
function ArenaSession:UpdateZone()
   local _, instance_type = IsInInstance()
   local session_kind
   if instance_type == "arena" then
      session_kind = "arena"
   elseif instance_type == "pvp" and self.bg_test_enabled then
      session_kind = "bg_test"
   end

   if session_kind and self.phase == "idle" then
      self:OnSessionStart(session_kind)
   elseif self.phase ~= "idle" and session_kind ~= self.session_kind then
      self:OnSessionEnd()
      if session_kind then self:OnSessionStart(session_kind) end
   end
end

function ArenaSession:OnSessionStart(session_kind)
   local is_test = session_kind == "bg_test"
   local _, is_rated
   if not is_test then _, is_rated = IsActiveBattlefieldArena() end

   self.phase = "preparing"
   self.session_kind = session_kind
   self.started_at = time()
   self.first_combat_at = nil
   self.zone = GetRealZoneText()
   self.is_rated = is_rated and true or false
   util.Print(is_test and L["BG_TEST_STARTED"] or L["ARENA_ENTERED"])
   local capture = CoAArena:GetModule("OpponentCapture")
   if capture then capture:StartCapture() end
end

function ArenaSession:OnSessionEnd()
   local capture = CoAArena:GetModule("OpponentCapture")
   local opponents = capture and capture:StopCapture()

   if self.phase ~= "complete" and (self.first_combat_at or (opponents and #opponents > 0)) then
      local match = self:BuildMatch(opponents or {}, nil, nil, nil, false)
      if self.session_kind == "bg_test" then
         self:RecordTestMatch(match)
      else
         store.AppendMatch(match)
         util.Print(L["MATCH_SAVED_INCOMPLETE"])
      end
   end

   local was_test = self.session_kind == "bg_test"
   self.phase = "idle"
   self.session_kind = nil
   util.Print(was_test and L["BG_TEST_STOPPED"] or L["ARENA_LEFT"])
end

function ArenaSession:OnCombatObserved()
   if self.phase ~= "preparing" then return end
   self.phase = "active"
   self.first_combat_at = time()
end

function ArenaSession:GetPlayerScore()
   local player_name = base_name(UnitName("player"))
   for index = 1, GetNumBattlefieldScores() do
      local name, killing_blows, _, deaths, _, team, _, race, class,
         class_token, damage_done, healing_done = GetBattlefieldScore(index)
      if base_name(name) == player_name then
         return team, {
            name = name,
            race = race,
            class = class,
            class_token = class_token,
            killing_blows = killing_blows,
            deaths = deaths,
            damage_done = damage_done,
            healing_done = healing_done,
         }
      end
   end
end

function ArenaSession:BuildMatch(opponents, winner_team, player_team, player, is_complete)
   local team_name, rating_before, rating_after, matchmaking_rating
   if self.is_rated and player_team ~= nil then
      team_name, rating_before, rating_after, matchmaking_rating =
         GetBattlefieldTeamInfo(player_team)
   end

   local result = "unknown"
   if winner_team ~= nil and player_team ~= nil then
      result = winner_team == player_team and "win" or "loss"
   end

   return {
      started_at = self.started_at,
      first_combat_at = self.first_combat_at,
      ended_at = time(),
      duration = math.floor((GetBattlefieldInstanceRunTime() or 0) / 1000),
      zone = self.zone,
      is_arena = self.session_kind == "arena",
      is_test = self.session_kind == "bg_test",
      is_rated = self.is_rated,
      is_complete = is_complete,
      result = result,
      winner_team = winner_team,
      player_team = player_team,
      player = player,
      team_name = team_name,
      rating_before = rating_before,
      rating_after = rating_after,
      rating_change = rating_before and rating_after and (rating_after - rating_before) or nil,
      matchmaking_rating = matchmaking_rating,
      opponents = opponents,
   }
end

function ArenaSession:RecordTestMatch(match)
   self.last_test_match = match
   util.Print(string.format(
      L["BG_TEST_CAPTURED"],
      L[string.upper(match.result)],
      #match.opponents
   ))
end

function ArenaSession:UPDATE_BATTLEFIELD_SCORE()
   if self.phase == "idle" or self.phase == "complete" then return end

   local winner_team = GetBattlefieldWinner()
   if winner_team == nil then return end

   local player_team, player = self:GetPlayerScore()
   local capture = CoAArena:GetModule("OpponentCapture")
   if capture then capture:CaptureScoreboard(player_team) end
   local opponents = capture and capture:StopCapture() or {}

   local match = self:BuildMatch(opponents, winner_team, player_team, player, true)
   if self.session_kind == "bg_test" then
      self:RecordTestMatch(match)
   else
      store.AppendMatch(match)
      util.Print(string.format(L["MATCH_SAVED"], L[string.upper(match.result)]))
   end
   self.phase = "complete"
end

function ArenaSession:GetDebugState()
   local state = self.phase or "disabled"
   if self.session_kind == "bg_test" then state = state .. "(bg-test)" end
   return state
end

function ArenaSession:SetBgTestEnabled(enabled)
   self.bg_test_enabled = enabled and true or false
   self:UpdateZone()
end

function ArenaSession:IsBgTestEnabled()
   return self.bg_test_enabled
end

function ArenaSession:GetLastTestMatch()
   return self.last_test_match
end
