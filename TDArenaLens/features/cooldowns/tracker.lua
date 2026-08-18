-- cooldowns :: tracker — tracks key enemy ability cooldowns during a match.
-- Later phase (see docs/addon-plan.md); stubbed to establish the domain.
local ADDON_NAME, ns = ...
local TDArenaLens = ns.addon

local CooldownTracker = TDArenaLens:NewModule("CooldownTracker")

function CooldownTracker:OnEnable()
   -- TODO: register spell-cast events and begin tracking tracked cooldowns.
end
