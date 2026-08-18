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
   self:UpdateZone()
end

function ArenaSession:PLAYER_ENTERING_WORLD()
   self:UpdateZone()
end

function ArenaSession:ZONE_CHANGED_NEW_AREA()
   self:UpdateZone()
end

-- Transition detection: fire OnArenaStart/OnArenaEnd only on edges.
function ArenaSession:UpdateZone()
   local _, instance_type = IsInInstance()
   local in_arena = instance_type == "arena"

   if in_arena and self.phase == "idle" then
      self:OnArenaStart()
   elseif not in_arena and self.phase ~= "idle" then
      self:OnArenaEnd()
   end
end

function ArenaSession:OnArenaStart()
   local _, is_rated = IsActiveBattlefieldArena()
   self.phase = "preparing"
   self.started_at = time()
   self.first_combat_at = nil
   self.zone = GetRealZoneText()
   self.is_rated = is_rated and true or false
   util.Print(L["ARENA_ENTERED"])
   local capture = CoAArena:GetModule("OpponentCapture")
   if capture then capture:StartCapture() end
end

function ArenaSession:OnArenaEnd()
   local capture = CoAArena:GetModule("OpponentCapture")
   local opponents = capture and capture:StopCapture()

   if self.phase ~= "complete" and (self.first_combat_at or (opponents and #opponents > 0)) then
      store.AppendMatch(self:BuildMatch(opponents or {}, nil, nil, nil, false))
      util.Print(L["MATCH_SAVED_INCOMPLETE"])
   end

   self.phase = "idle"
   util.Print(L["ARENA_LEFT"])
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
      is_arena = true,
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

function ArenaSession:UPDATE_BATTLEFIELD_SCORE()
   if self.phase == "idle" or self.phase == "complete" then return end

   local winner_team = GetBattlefieldWinner()
   if winner_team == nil then return end

   local player_team, player = self:GetPlayerScore()
   local capture = CoAArena:GetModule("OpponentCapture")
   if capture then capture:CaptureScoreboard(player_team) end
   local opponents = capture and capture:StopCapture() or {}

   local match = self:BuildMatch(opponents, winner_team, player_team, player, true)
   store.AppendMatch(match)
   self.phase = "complete"
   util.Print(string.format(L["MATCH_SAVED"], L[string.upper(match.result)]))
end

function ArenaSession:GetDebugState()
   return self.phase or "disabled"
end
