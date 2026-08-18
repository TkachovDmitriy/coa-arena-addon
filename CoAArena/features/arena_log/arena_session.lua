-- arena_log :: arena_session — detects entering/leaving an arena and drives the
-- rest of the domain (opponent capture, persistence). See docs/addon-plan.md,
-- Phase 1.
local ADDON_NAME, ns = ...
local CoAArena = ns.addon
local L = ns.L
local util = ns.util

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
   util.Print(L["ARENA_ENTERED"])
   local capture = CoAArena:GetModule("OpponentCapture")
   if capture then capture:StartCapture() end
end

function ArenaSession:OnArenaEnd()
   util.Print(L["ARENA_LEFT"])
   local capture = CoAArena:GetModule("OpponentCapture")
   local opponents = capture and capture:StopCapture()
   -- TODO(phase1): build a match record from `opponents` + arena UI result /
   -- rating delta, then ns.arena_log.store.AppendMatch(match).
end
