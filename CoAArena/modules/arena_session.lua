-- arena_session — detect entering/leaving an arena so match logging only runs
-- inside actual arena instances (see docs/addon-plan.md, Phase 1).
local ADDON_NAME, ns = ...
local CoAArena = ns.addon
local L = ns.L

local ArenaSession = CoAArena:NewModule("ArenaSession")

function ArenaSession:OnEnable()
   CoAArena:RegisterEvent("PLAYER_ENTERING_WORLD")
   CoAArena:RegisterEvent("ZONE_CHANGED_NEW_AREA")
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

   if in_arena and not self.in_arena then
      self.in_arena = true
      self:OnArenaStart()
   elseif not in_arena and self.in_arena then
      self.in_arena = false
      self:OnArenaEnd()
   end
end

function ArenaSession:OnArenaStart()
   -- TODO(phase1): begin buffering opponent capture via
   -- COMBAT_LOG_EVENT_UNFILTERED + NotifyInspect/INSPECT_READY.
   DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99CoA Arena|r: " .. L["ARENA_ENTERED"])
end

function ArenaSession:OnArenaEnd()
   -- TODO(phase1): flush the match summary into CoAArenaCharDB.
   DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99CoA Arena|r: " .. L["ARENA_LEFT"])
end
