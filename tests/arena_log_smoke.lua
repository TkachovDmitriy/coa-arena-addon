-- Minimal Lua 5.1 smoke test for the arena-log vertical slice. This deliberately
-- avoids a test framework and mocks only the WoW globals touched during startup.
local registered_events = {}
local event_script
local messages = {}
local in_arena = false
local winner_team

local event_frame = {}

function event_frame:RegisterEvent(event)
   registered_events[event] = true
end

function event_frame:UnregisterEvent(event)
   registered_events[event] = nil
end

function event_frame:SetScript(script, handler)
   if script == "OnEvent" then event_script = handler end
end

function CreateFrame()
   return event_frame
end

function GetAddOnMetadata()
   return "test"
end

DEFAULT_CHAT_FRAME = {
   AddMessage = function(_, message)
      table.insert(messages, message)
   end,
}

bit = {
   band = function(left, right)
      local result = 0
      local place = 1
      while left > 0 and right > 0 do
         if left % 2 == 1 and right % 2 == 1 then result = result + place end
         left = math.floor(left / 2)
         right = math.floor(right / 2)
         place = place * 2
      end
      return result
   end,
}

COMBATLOG_OBJECT_TYPE_PLAYER = 1
COMBATLOG_OBJECT_REACTION_HOSTILE = 2
SlashCmdList = {}

function IsInInstance()
   return in_arena, in_arena and "arena" or "none"
end

function IsActiveBattlefieldArena()
   return in_arena, true
end

function GetRealZoneText()
   return "Test Arena"
end

function UnitName()
   return "Player"
end

local scores = {
   { "Player", 1, 0, 0, 0, 0, 0, "Human", "Warrior", "WARRIOR", 1000, 50 },
   { "Enemy", 2, 0, 1, 0, 1, 0, "Orc", "Shaman", "SHAMAN", 800, 200 },
}

function GetNumBattlefieldScores()
   return #scores
end

function GetBattlefieldScore(index)
   return unpack(scores[index])
end

function GetBattlefieldWinner()
   return winner_team
end

function GetBattlefieldTeamInfo(team)
   if team == 0 then return "Our Team", 1500, 1512, 1600 end
   return "Enemy Team", 1490, 1478, 1580
end

function GetBattlefieldInstanceRunTime()
   return 90000
end

function time()
   return 1000
end

local namespace = {}
local function load_addon_file(path)
   local chunk = assert(loadfile(path))
   chunk("CoAArena", namespace)
end

load_addon_file("CoAArena/locales/en_us.lua")
load_addon_file("CoAArena/core.lua")
load_addon_file("CoAArena/shared/util.lua")
load_addon_file("CoAArena/features/arena_log/store.lua")
load_addon_file("CoAArena/features/arena_log/opponent_capture.lua")
load_addon_file("CoAArena/features/arena_log/arena_session.lua")
load_addon_file("CoAArena/features/arena_log/history_frame.lua")

event_script(event_frame, "ADDON_LOADED", "CoAArena")
event_script(event_frame, "PLAYER_LOGIN")

local session = namespace.addon:GetModule("ArenaSession")
assert(session:GetDebugState() == "idle")

in_arena = true
event_script(event_frame, "PLAYER_ENTERING_WORLD")
assert(session:GetDebugState() == "preparing")
assert(registered_events.COMBAT_LOG_EVENT_UNFILTERED)

event_script(
   event_frame,
   "COMBAT_LOG_EVENT_UNFILTERED",
   0,
   "SPELL_DAMAGE",
   false,
   "enemy-guid",
   "Enemy",
   3,
   0,
   "player-guid",
   "Player",
   1,
   0
)
assert(session:GetDebugState() == "active")

winner_team = 0
event_script(event_frame, "UPDATE_BATTLEFIELD_SCORE")
assert(session:GetDebugState() == "complete")
assert(not registered_events.COMBAT_LOG_EVENT_UNFILTERED)

local matches = namespace.arena_log.store.GetMatches()
assert(#matches == 1)
assert(matches[1].result == "win")
assert(matches[1].rating_change == 12)
assert(matches[1].is_complete)
assert(#matches[1].opponents == 1)
assert(matches[1].opponents[1].guid == "enemy-guid")
assert(matches[1].opponents[1].class_token == "SHAMAN")

in_arena = false
event_script(event_frame, "PLAYER_ENTERING_WORLD")
assert(session:GetDebugState() == "idle")
assert(#namespace.arena_log.store.GetMatches() == 1)

winner_team = nil
in_arena = true
event_script(event_frame, "PLAYER_ENTERING_WORLD")
in_arena = false
event_script(event_frame, "PLAYER_ENTERING_WORLD")
assert(#namespace.arena_log.store.GetMatches() == 1)

in_arena = true
event_script(event_frame, "PLAYER_ENTERING_WORLD")
event_script(
   event_frame,
   "COMBAT_LOG_EVENT_UNFILTERED",
   0,
   "SPELL_DAMAGE",
   false,
   "second-enemy-guid",
   "SecondEnemy",
   3,
   0,
   "player-guid",
   "Player",
   1,
   0
)
in_arena = false
event_script(event_frame, "PLAYER_ENTERING_WORLD")
assert(#namespace.arena_log.store.GetMatches() == 2)
assert(namespace.arena_log.store.GetLatestMatch().id == 2)
assert(namespace.arena_log.store.GetLatestMatch().result == "unknown")
assert(not namespace.arena_log.store.GetLatestMatch().is_complete)

SlashCmdList.COAARENA("debug")
assert(#messages > 0)
