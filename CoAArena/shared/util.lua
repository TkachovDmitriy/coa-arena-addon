-- Generic, domain-agnostic helpers shared across features. Depends on nothing
-- but `ns`; must load before any feature that uses it.
local ADDON_NAME, ns = ...

local util = {}
ns.util = util

-- Print a chat message prefixed with the addon tag.
function util.Print(msg)
   DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99CoA Arena|r: " .. tostring(msg))
end
