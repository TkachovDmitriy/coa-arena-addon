-- arena_log :: opponent_capture — collects opponent identity/gear during a
-- match. Driven by arena_session (start/stop), not by its own zone logic.
local ADDON_NAME, ns = ...
local CoAArena = ns.addon

local OpponentCapture = CoAArena:NewModule("OpponentCapture")

-- Begin buffering opponents for the current match.
function OpponentCapture:StartCapture()
   self.opponents = {}
   -- TODO(phase1): register COMBAT_LOG_EVENT_UNFILTERED for identity and drive
   -- NotifyInspect / INSPECT_READY for gear/talents (best-effort).
end

-- Stop buffering and return what was collected this match.
function OpponentCapture:StopCapture()
   -- TODO(phase1): unregister events.
   return self.opponents
end
