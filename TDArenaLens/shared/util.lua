-- Generic, domain-agnostic helpers shared across features. Depends on nothing
-- but `ns`; must load before any feature that uses it.
local ADDON_NAME, ns = ...

local util = {}
ns.util = util

local MAX_LOG_LINES = 200
local log_lines = {}
local log_listener

local function append_log(msg)
   -- Preserve WoW's escaped "||" form so the EditBox renders literal pipes
   -- instead of treating fields such as "|complete" as formatting codes.
   table.insert(log_lines, "TD ArenaLens: " .. tostring(msg))
   if #log_lines > MAX_LOG_LINES then table.remove(log_lines, 1) end
   if log_listener then log_listener() end
end

-- Print a chat message prefixed with the addon tag.
function util.Print(msg)
   append_log(msg)
   DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99TD ArenaLens|r: " .. tostring(msg))
end

function util.GetLogText()
   return table.concat(log_lines, "\n")
end

function util.GetLogLineCount()
   return #log_lines
end

function util.ClearLog()
   log_lines = {}
   if log_listener then log_listener() end
end

function util.SetLogListener(listener)
   assert(listener == nil or type(listener) == "function", "log listener must be a function")
   log_listener = listener
end
