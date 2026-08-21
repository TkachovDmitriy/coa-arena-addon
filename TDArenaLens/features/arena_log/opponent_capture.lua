-- arena_log :: opponent_capture — collects opponent identity/gear during a
-- match. Driven by arena_session (start/stop), not by its own zone logic.
local ADDON_NAME, ns = ...
local TDArenaLens = ns.addon
local util = ns.util

local OpponentCapture = TDArenaLens:NewModule("OpponentCapture")

local function opponent_key(name)
   local name_without_realm = name and string.match(name, "^[^-]+")
   return name_without_realm and string.lower(name_without_realm)
end

local function is_hostile_player(flags)
   if not flags then return false end
   return bit.band(flags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
      and bit.band(flags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0
end

-- The full BG combat log contains tens of thousands of damage/heal ticks.
-- Keep the copyable trace focused on events useful for cooldown diagnostics.
local traced_events = {
   SPELL_CAST_START = true,
   SPELL_CAST_SUCCESS = true,
   SPELL_INTERRUPT = true,
   SPELL_DISPEL = true,
   SPELL_STOLEN = true,
   SPELL_AURA_APPLIED = true,
   UNIT_DIED = true,
}

local function involves_player_or_target(source_guid, dest_guid)
   local player_guid = UnitGUID("player")
   local target_guid = UnitGUID("target")
   return (player_guid and (source_guid == player_guid or dest_guid == player_guid))
      or (target_guid and (source_guid == target_guid or dest_guid == target_guid))
end

local function should_trace_event(
   event_name, hostile_source, hostile_dest, source_guid, dest_guid
)
   if not traced_events[event_name] then return false end
   if not involves_player_or_target(source_guid, dest_guid) then return false end
   if event_name == "UNIT_DIED" then return hostile_dest end
   return hostile_source
end

local function combat_event_line(
   event_name, source_name, dest_name, spell_id, spell_name
)
   local fields = {
      "COMBAT",
      "event=" .. tostring(event_name or "UNKNOWN"),
      "source=" .. tostring(source_name or "?"),
      "dest=" .. tostring(dest_name or "?"),
   }

   if spell_id ~= nil then
      table.insert(fields, "spell-id=" .. tostring(spell_id))
   end
   if spell_name ~= nil then
      table.insert(fields, "spell=" .. tostring(spell_name))
   end

   return table.concat(fields, "||")
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
   self.traced_event_keys = {}
   self.is_capturing = true
   TDArenaLens:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self)
end

-- Stop buffering and return what was collected this match.
function OpponentCapture:StopCapture()
   if self.is_capturing then
      TDArenaLens:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self)
   end
   self.is_capturing = false
   return self.opponents
end

function OpponentCapture:GetOpponentCount()
   return self.opponents and #self.opponents or 0
end

function OpponentCapture:COMBAT_LOG_EVENT_UNFILTERED(
   _, event_name, source_guid, source_name, source_flags,
   dest_guid, dest_name, dest_flags, ...
)
   if not self.is_capturing then return end

   local session = TDArenaLens:GetModule("ArenaSession")
   if session and not session:IsCombatCaptureOpen() then return end

   local hostile_source = is_hostile_player(source_flags)
   local hostile_dest = is_hostile_player(dest_flags)
   local observed_opponent
   if hostile_source then
      self:AddOpponent(source_guid, source_name)
      observed_opponent = true
   end
   if hostile_dest then
      self:AddOpponent(dest_guid, dest_name)
      observed_opponent = true
   end

   if observed_opponent then
      if should_trace_event(
         event_name, hostile_source, hostile_dest, source_guid, dest_guid
      ) then
         local spell_id, spell_name
         if string.match(event_name or "", "^SPELL_")
            or string.match(event_name or "", "^RANGE_") then
            spell_id, spell_name = ...
         end
         local trace_key = table.concat({
            tostring(event_name),
            tostring(source_name),
            tostring(dest_name),
            tostring(spell_id),
         }, ":")
         if not self.traced_event_keys[trace_key] then
            self.traced_event_keys[trace_key] = true
            util.DebugLog(combat_event_line(
               event_name, source_name, dest_name, spell_id, spell_name
            ))
         end
      end

      if session then session:OnCombatObserved() end
   end
end

-- The final scoreboard is more complete than the combat log and provides
-- class, race and basic performance data even when a player emitted no CLEU.
function OpponentCapture:CaptureScoreboard(player_team)
   if player_team == nil then return end

   for index = 1, GetNumBattlefieldScores() do
      local name, killing_blows, _, deaths, _, team, _, race, class,
         class_token, damage_done, healing_done, pvp_rating, rating_change,
         pre_match_mmr, mmr_change, talent_spec = GetBattlefieldScore(index)
      if team ~= nil and team ~= player_team then
         self:AddOpponent(nil, name, {
            race = race,
            class = class,
            class_token = class_token,
            killing_blows = killing_blows,
            deaths = deaths,
            damage_done = damage_done,
            healing_done = healing_done,
            pvp_rating = pvp_rating,
            rating_change = rating_change,
            pre_match_mmr = pre_match_mmr,
            mmr_change = mmr_change,
            talent_spec = talent_spec,
            team = team,
         })
      end
   end
end
