-- CoAArena — core bootstrap.
--
-- Every file in this addon receives the same two `...` varargs from the
-- client: the addon's folder name and a private namespace table shared only
-- between our files. We hang everything off `ns` instead of the global
-- environment so we don't pollute `_G` (WoW addon best practice).
local ADDON_NAME, ns = ...

local CoAArena = ns.addon or {}
ns.addon = CoAArena
_G.CoAArena = CoAArena -- also exposed globally for /commands and debugging

CoAArena.name = ADDON_NAME
CoAArena.version = GetAddOnMetadata(ADDON_NAME, "Version")
CoAArena.modules = CoAArena.modules or {}

-- Module registry -----------------------------------------------------------
-- A "module" is just a table with optional `OnEnable` and event-named methods
-- (e.g. `PLAYER_ENTERING_WORLD`). The core fans events out to them.

function CoAArena:NewModule(name)
    assert(not self.modules[name], "CoAArena: module already registered: " .. tostring(name))
    local module = { name = name }
    self.modules[name] = module
    return module
end

function CoAArena:GetModule(name)
    return self.modules[name]
end

-- Event plumbing ------------------------------------------------------------
-- One hidden frame for the whole addon; modules never create their own event
-- frames, they just declare handlers and register interest via the core.
local frame = CreateFrame("Frame")
CoAArena.frame = frame

function CoAArena:RegisterEvent(event)
    frame:RegisterEvent(event)
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local loaded = ...
        if loaded ~= ADDON_NAME then return end
        -- SavedVariables are only populated by the client at this point.
        CoAArenaDB = CoAArenaDB or {}
        CoAArenaCharDB = CoAArenaCharDB or {}
        CoAArena.db = CoAArenaDB
        CoAArena.charDB = CoAArenaCharDB
        return
    end

    if event == "PLAYER_LOGIN" then
        for _, module in pairs(CoAArena.modules) do
            if module.OnEnable then module:OnEnable() end
        end
    end

    -- Fan every registered event out to any module declaring a same-named
    -- handler method.
    for _, module in pairs(CoAArena.modules) do
        local handler = module[event]
        if handler then handler(module, ...) end
    end
end)
