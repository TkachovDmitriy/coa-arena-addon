-- enUS is the default/base locale. Other locale files should reuse these
-- keys and fall back to English when a translation is missing.
local ADDON_NAME, ns = ...

ns.L = ns.L or {}
local L = ns.L

L["ADDON_NAME"] = "CoA Arena"
L["ARENA_ENTERED"] = "Arena match started — logging opponents."
L["ARENA_LEFT"] = "Arena match ended."
