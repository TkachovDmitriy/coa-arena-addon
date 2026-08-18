-- arena_log :: opponent_capture — collects opponent identity/gear during a
-- match. Driven by arena_session (start/stop), not by its own zone logic.
local ADDON_NAME, ns = ...
local CoAArena = ns.addon

local OpponentCapture = CoAArena:NewModule("OpponentCapture")

local function opponent_key(name)
   local name_without_realm = name and string.match(name, "^[^-]+")
   return name_without_realm and string.lower(name_without_realm)
end

local function is_hostile_player(flags)
   if not flags then return false end
   return bit.band(flags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
      and bit.band(flags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0
end

function OpponentCapture:AddOpponent(guid, name, details)
   if not name then return end

   local key = guid or opponent_key(name)
   local opponent = self.opponents_by_key[key] or self.opponents_by_name[opponent_key(name)]
   if not opponent then
      opponent = {
         guid = guid,
         name = name,
      }
      self.opponents_by_key[key] = opponent
      self.opponents_by_name[opponent_key(name)] = opponent
      table.insert(self.opponents, opponent)
   elseif guid and not opponent.guid then
      opponent.guid = guid
      self.opponents_by_key[guid] = opponent
   end

   if details then
      for field, value in pairs(details) do
         if value ~= nil then opponent[field] = value end
      end
   end
end

-- Begin buffering opponents for the current match.
function OpponentCapture:StartCapture()
   self.opponents = {}
   self.opponents_by_key = {}
   self.opponents_by_name = {}
   self.is_capturing = true
   CoAArena:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self)
end

-- Stop buffering and return what was collected this match.
function OpponentCapture:StopCapture()
   if self.is_capturing then
      CoAArena:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self)
   end
   self.is_capturing = false
   return self.opponents
end

function OpponentCapture:COMBAT_LOG_EVENT_UNFILTERED(
   _, _, _, source_guid, source_name, source_flags, _,
   dest_guid, dest_name, dest_flags
)
   if not self.is_capturing then return end

   local observed_opponent
   if is_hostile_player(source_flags) then
      self:AddOpponent(source_guid, source_name)
      observed_opponent = true
   end
   if is_hostile_player(dest_flags) then
      self:AddOpponent(dest_guid, dest_name)
      observed_opponent = true
   end

   if observed_opponent then
      local session = CoAArena:GetModule("ArenaSession")
      if session then session:OnCombatObserved() end
   end
end

-- The final scoreboard is more complete than the combat log and provides
-- class, race and basic performance data even when a player emitted no CLEU.
function OpponentCapture:CaptureScoreboard(player_team)
   if player_team == nil then return end

   for index = 1, GetNumBattlefieldScores() do
      local name, killing_blows, _, deaths, _, team, _, race, class,
         class_token, damage_done, healing_done = GetBattlefieldScore(index)
      if team ~= nil and team ~= player_team then
         self:AddOpponent(nil, name, {
            race = race,
            class = class,
            class_token = class_token,
            killing_blows = killing_blows,
            deaths = deaths,
            damage_done = damage_done,
            healing_done = healing_done,
            team = team,
         })
      end
   end
end
