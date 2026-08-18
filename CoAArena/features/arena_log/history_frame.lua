-- arena_log :: history_frame — in-game UI to browse logged matches (this
-- session + persisted history). Reads through ns.arena_log.store.
local ADDON_NAME, ns = ...
local CoAArena = ns.addon
local L = ns.L

local HistoryFrame = CoAArena:NewModule("HistoryFrame")

function HistoryFrame:OnEnable()
   -- TODO(phase1): register a /coaarena slash command to toggle the frame.
end

-- Show/hide the match-history browser, building it lazily on first open.
function HistoryFrame:Toggle()
   -- TODO(phase1): build the frame on first call, then toggle visibility.
end
