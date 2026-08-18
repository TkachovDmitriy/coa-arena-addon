-- enUS is the default/base locale. Other locale files should reuse these
-- keys and fall back to English when a translation is missing.
local ADDON_NAME, ns = ...

ns.L = ns.L or {}
local L = ns.L

L["ADDON_NAME"] = "CoA Arena"
L["ARENA_ENTERED"] = "Arena entered — preparing match capture."
L["ARENA_LEFT"] = "Arena match ended."
L["MATCH_SAVED"] = "Match saved: %s."
L["MATCH_SAVED_INCOMPLETE"] = "Incomplete match saved for diagnostics."
L["HISTORY_TITLE"] = "CoA Arena — Recent Matches"
L["NO_MATCHES"] = "No arena matches recorded yet."
L["WIN"] = "Win"
L["LOSS"] = "Loss"
L["UNKNOWN"] = "Unknown"
L["DEBUG_STATE"] = "state=%s, matches=%d, latest=#%d"
