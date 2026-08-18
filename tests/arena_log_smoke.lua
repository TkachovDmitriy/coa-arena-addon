-- Minimal Lua 5.1 smoke test for the arena-log vertical slice. This deliberately
-- avoids a test framework and mocks only the WoW globals touched during startup.
local registered_events = {}
local event_script
local messages = {}
local instance_type = "none"
local winner_team
local battlefield_runtime = 90000
local target_guid = "enemy-guid"
local create_frame_count = 0

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

local function new_ui_object()
   local object = { scripts = {} }
   setmetatable(object, {
      __index = function(_, method)
         if method == "CreateTexture" or method == "CreateFontString" then
            return function() return new_ui_object() end
         elseif method == "GetFrameLevel" then
            return function() return 1 end
         elseif method == "IsShown" then
            return function() return false end
         elseif method == "SetScript" then
            return function(_, script, handler) object.scripts[script] = handler end
         end
         return function() end
      end,
   })
   return object
end

function CreateFrame()
   create_frame_count = create_frame_count + 1
   if create_frame_count == 1 then return event_frame end
   return new_ui_object()
end

function GetAddOnMetadata()
   return "test"
end

DEFAULT_CHAT_FRAME = {
   AddMessage = function(_, message)
      table.insert(messages, message)
   end,
}

ChatFontNormal = {}
UIParent = new_ui_object()
Minimap = new_ui_object()
GameTooltip = new_ui_object()
UIParent.GetEffectiveScale = function() return 1 end
Minimap.GetCenter = function() return 0, 0 end

function GetCursorPosition()
   return 10, 10
end

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
   return instance_type ~= "none", instance_type
end

function IsActiveBattlefieldArena()
   return instance_type == "arena", true
end

function GetRealZoneText()
   return "Test Arena"
end

function UnitName()
   return "Player"
end

function UnitGUID(unit)
   if unit == "player" then return "player-guid" end
   if unit == "target" then return target_guid end
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
   return battlefield_runtime
end

function time()
   return 1000
end

local namespace = {}
local function load_addon_file(path)
   local chunk = assert(loadfile(path))
   chunk("TDArenaLens", namespace)
end

load_addon_file("TDArenaLens/locales/en_us.lua")
load_addon_file("TDArenaLens/core.lua")
load_addon_file("TDArenaLens/shared/util.lua")
load_addon_file("TDArenaLens/features/arena_log/store.lua")
load_addon_file("TDArenaLens/features/arena_log/opponent_capture.lua")
load_addon_file("TDArenaLens/features/arena_log/arena_session.lua")
load_addon_file("TDArenaLens/features/arena_log/history_frame.lua")
load_addon_file("TDArenaLens/features/diagnostics/reporting.lua")
load_addon_file("TDArenaLens/features/diagnostics/action_bar.lua")
load_addon_file("TDArenaLens/features/diagnostics/log_frame.lua")
load_addon_file("TDArenaLens/features/commands/slash_commands.lua")
load_addon_file("TDArenaLens/features/launcher/minimap_button.lua")

event_script(event_frame, "ADDON_LOADED", "TDArenaLens")
event_script(event_frame, "PLAYER_LOGIN")

assert(SLASH_TDARENALENS1 == "/tdlens")
assert(SLASH_TDARENALENS2 == "/coaarena")
assert(type(SlashCmdList.TDARENALENS) == "function")

local session = namespace.addon:GetModule("ArenaSession")
assert(session:GetDebugState() == "idle")
assert(namespace.addon:GetModule("DiagnosticLogFrame"))
assert(namespace.addon:GetModule("DiagnosticReporting"))
assert(namespace.addon:GetModule("SlashCommands"))
local minimap_button = namespace.addon:GetModule("MinimapButton").button
assert(minimap_button)
minimap_button.scripts.OnClick(minimap_button, "LeftButton")
assert(namespace.addon:GetModule("HistoryFrame").frame)
minimap_button.scripts.OnClick(minimap_button, "RightButton")
assert(namespace.addon:GetModule("DiagnosticLogFrame").frame)
assert(namespace.addon:GetModule("DiagnosticLogFrame").frame.actions)
minimap_button.scripts.OnEnter(minimap_button)
minimap_button.scripts.OnLeave(minimap_button)
minimap_button.scripts.OnDragStart(minimap_button)
assert(minimap_button.scripts.OnUpdate)
minimap_button.scripts.OnUpdate(minimap_button)
assert(math.floor(namespace.addon.db.minimap_angle) == 45)
minimap_button.scripts.OnDragStop(minimap_button)
assert(not minimap_button.scripts.OnUpdate)

local diagnostic_module = namespace.addon.modules.DiagnosticLogFrame
namespace.addon.modules.DiagnosticLogFrame = nil
minimap_button.scripts.OnClick(minimap_button, "RightButton")
assert(string.find(messages[#messages], "DiagnosticLogFrame is unavailable", 1, true))
namespace.addon.modules.DiagnosticLogFrame = diagnostic_module

instance_type = "arena"
event_script(event_frame, "PLAYER_ENTERING_WORLD")
assert(session:GetDebugState() == "preparing")
assert(registered_events.COMBAT_LOG_EVENT_UNFILTERED)

event_script(
   event_frame,
   "COMBAT_LOG_EVENT_UNFILTERED",
   0,
   "SPELL_CAST_SUCCESS",
   "enemy-guid",
   "Enemy",
   3,
   "player-guid",
   "Player",
   1,
   50401,
   "Razorice"
)
assert(session:GetDebugState() == "active")
assert(string.find(
   namespace.util.GetLogText(),
   "COMBAT||event=SPELL_CAST_SUCCESS||source=Enemy||dest=Player||spell-id=50401||spell=Razorice",
   1,
   true
))

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

instance_type = "none"
event_script(event_frame, "PLAYER_ENTERING_WORLD")
assert(session:GetDebugState() == "idle")
assert(#namespace.arena_log.store.GetMatches() == 1)

winner_team = nil
instance_type = "arena"
event_script(event_frame, "PLAYER_ENTERING_WORLD")
instance_type = "none"
event_script(event_frame, "PLAYER_ENTERING_WORLD")
assert(#namespace.arena_log.store.GetMatches() == 1)

instance_type = "arena"
event_script(event_frame, "PLAYER_ENTERING_WORLD")
event_script(
   event_frame,
   "COMBAT_LOG_EVENT_UNFILTERED",
   0,
   "SPELL_CAST_SUCCESS",
   "second-enemy-guid",
   "SecondEnemy",
   3,
   "player-guid",
   "Player",
   1
)
instance_type = "none"
event_script(event_frame, "PLAYER_ENTERING_WORLD")
assert(#namespace.arena_log.store.GetMatches() == 2)
assert(namespace.arena_log.store.GetLatestMatch().id == 2)
assert(namespace.arena_log.store.GetLatestMatch().result == "unknown")
assert(not namespace.arena_log.store.GetLatestMatch().is_complete)

SlashCmdList.TDARENALENS("arena export")
assert(string.find(messages[#messages], "ARENA||id=2||complete=0", 1, true))

-- Battleground test mode exercises capture without polluting arena history.
instance_type = "pvp"
event_script(event_frame, "PLAYER_ENTERING_WORLD")
assert(session:GetDebugState() == "idle")
SlashCmdList.TDARENALENS("testbg on")
assert(session:GetDebugState() == "preparing(bg-test)")
assert(registered_events.COMBAT_LOG_EVENT_UNFILTERED)

battlefield_runtime = 0
event_script(
   event_frame,
   "COMBAT_LOG_EVENT_UNFILTERED",
   0,
   "SPELL_AURA_APPLIED",
   "waiting-enemy-guid",
   "WaitingEnemy",
   3,
   "waiting-enemy-guid",
   "WaitingEnemy",
   3,
   12345,
   "Preparation Buff"
)
assert(session:GetDebugState() == "preparing(bg-test)")
assert(session:GetTestOpponentCount() == 0)
assert(not string.find(namespace.util.GetLogText(), "WaitingEnemy", 1, true))

battlefield_runtime = 90000
target_guid = "bg-enemy-guid"
event_script(
   event_frame,
   "COMBAT_LOG_EVENT_UNFILTERED",
   0,
   "SPELL_CAST_SUCCESS",
   "bg-enemy-guid",
   "BattlegroundEnemy",
   3,
   "player-guid",
   "Player",
   1
)
assert(session:GetDebugState() == "active(bg-test)")
assert(string.find(
   namespace.util.GetLogText(),
   "COMBAT||event=SPELL_CAST_SUCCESS||source=BattlegroundEnemy||dest=Player",
   1,
   true
))
local log_lines_before_duplicate = namespace.util.GetLogLineCount()
event_script(
   event_frame,
   "COMBAT_LOG_EVENT_UNFILTERED",
   0,
   "SPELL_CAST_SUCCESS",
   "bg-enemy-guid",
   "BattlegroundEnemy",
   3,
   "player-guid",
   "Player",
   1
)
assert(namespace.util.GetLogLineCount() == log_lines_before_duplicate)
event_script(
   event_frame,
   "COMBAT_LOG_EVENT_UNFILTERED",
   0,
   "SPELL_DAMAGE",
   "bg-enemy-guid",
   "BattlegroundEnemy",
   3,
   "player-guid",
   "Player",
   1,
   99999,
   "Spam Damage"
)
assert(not string.find(namespace.util.GetLogText(), "Spam Damage", 1, true))
SlashCmdList.TDARENALENS("debug")
assert(string.find(messages[#messages], "test%-opponents=1"))

SlashCmdList.TDARENALENS("testbg export")
assert(string.find(messages[#messages], "No completed BG test"))

winner_team = 0
event_script(event_frame, "UPDATE_BATTLEFIELD_SCORE")
assert(session:GetDebugState() == "complete(bg-test)")
assert(#namespace.arena_log.store.GetMatches() == 2)
assert(session:GetLastTestMatch().is_test)
assert(not session:GetLastTestMatch().is_arena)
assert(#session:GetLastTestMatch().opponents == 2)

SlashCmdList.TDARENALENS("testbg export")
assert(string.find(messages[#messages], "BGTEST||complete=1||result=win", 1, true))
assert(string.find(messages[#messages], "||opponents=2||", 1, true))
assert(string.find(messages[#messages], "BattlegroundEnemy:?", 1, true))
assert(string.find(messages[#messages], "Enemy:SHAMAN", 1, true))
assert(string.find(namespace.util.GetLogText(), "BGTEST||complete=1||result=win", 1, true))
assert(#namespace.arena_log.store.GetMatches() == 2)

local actions = namespace.addon:GetModule("DiagnosticLogFrame").frame.actions
actions.status.scripts.OnClick(actions.status)
assert(string.find(messages[#messages], "matches=2", 1, true))
actions.arena_export.scripts.OnClick(actions.arena_export)
assert(string.find(messages[#messages], "ARENA||id=2", 1, true))
actions.bg_export.scripts.OnClick(actions.bg_export)
assert(string.find(messages[#messages], "BGTEST||complete=1", 1, true))
actions.bg_stop.scripts.OnClick(actions.bg_stop)
assert(session:GetDebugState() == "idle")
assert(not session:IsBgTestEnabled())
actions.bg_start.scripts.OnClick(actions.bg_start)
assert(session:GetDebugState() == "preparing(bg-test)")
assert(session:IsBgTestEnabled())

SlashCmdList.TDARENALENS("testbg off")
assert(session:GetDebugState() == "idle")
assert(#namespace.arena_log.store.GetMatches() == 2)

SlashCmdList.TDARENALENS("debug")
assert(#messages > 0)
assert(namespace.util.GetLogLineCount() > 0)
namespace.util.ClearLog()
assert(namespace.util.GetLogText() == "")
assert(namespace.util.GetLogLineCount() == 0)
