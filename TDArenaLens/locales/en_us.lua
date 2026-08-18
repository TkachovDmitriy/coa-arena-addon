-- enUS is the default/base locale. Other locale files should reuse these
-- keys and fall back to English when a translation is missing.
local ADDON_NAME, ns = ...

ns.L = ns.L or {}
local L = ns.L

L["ADDON_NAME"] = "TD ArenaLens"
L["ARENA_ENTERED"] = "Arena entered — preparing match capture."
L["ARENA_LEFT"] = "Arena match ended."
L["MATCH_SAVED"] = "Match saved: %s."
L["MATCH_SAVED_INCOMPLETE"] = "Incomplete match saved for diagnostics."
L["BG_TEST_STARTED"] = "BG test capture started; this session will not be saved."
L["BG_TEST_STOPPED"] = "BG test capture stopped."
L["BG_TEST_CAPTURED"] = "BG test captured: %s, opponents=%d (not saved)."
L["BG_TEST_STATUS"] = "BG test mode: %s. Use /tdlens testbg on|off|export."
L["BG_TEST_EXPORT"] = "BGTEST||complete=%d||result=%s||duration=%d||player-team=%s||winner-team=%s||opponents=%d||list=%s"
L["BG_TEST_EXPORT_EMPTY"] = "No completed BG test is available to export."
L["ENABLED"] = "enabled"
L["DISABLED"] = "disabled"
L["HISTORY_TITLE"] = "Gladiator's Ledger — Recent Matches"
L["NO_MATCHES"] = "No arena matches recorded yet."
L["WIN"] = "Win"
L["LOSS"] = "Loss"
L["UNKNOWN"] = "Unknown"
L["DEBUG_STATE"] = "state=%s, matches=%d, latest=#%d, test-opponents=%d"
L["DIAGNOSTIC_LOG_TITLE"] = "TD ArenaLens — Diagnostic Log"
L["ADDON_ABOUT"] = "%s v%s — by %s"
L["COMMAND_LIST"] = "/tdlens — recent matches\n/tdlens log — copyable diagnostic log\n/tdlens debug — capture status\n/tdlens testbg on|off|export — BG test controls\n/tdlens help — commands and addon information"
L["DIAGNOSTIC_LOG_HINT"] = "Select all, then press Ctrl+C to copy. Logs reset on /reload."
L["SELECT_ALL"] = "Select All"
L["CLEAR"] = "Clear"
