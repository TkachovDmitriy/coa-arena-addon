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
L["BG_TEST_STARTED"] = "BG test capture started; this session will not be saved."
L["BG_TEST_STOPPED"] = "BG test capture stopped."
L["BG_TEST_CAPTURED"] = "BG test captured: %s, opponents=%d (not saved)."
L["BG_TEST_STATUS"] = "BG test mode: %s. Use /coaarena testbg on|off."
L["ENABLED"] = "enabled"
L["DISABLED"] = "disabled"
L["HISTORY_TITLE"] = "CoA Arena — Recent Matches"
L["NO_MATCHES"] = "No arena matches recorded yet."
L["WIN"] = "Win"
L["LOSS"] = "Loss"
L["UNKNOWN"] = "Unknown"
L["DEBUG_STATE"] = "state=%s, matches=%d, latest=#%d, test-opponents=%d"
