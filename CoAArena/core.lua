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
CoAArena.module_order = CoAArena.module_order or {}
CoAArena.event_modules = CoAArena.event_modules or {}

-- Module registry -----------------------------------------------------------
-- A "module" is just a table with optional `OnEnable` and event-named methods
-- (e.g. `PLAYER_ENTERING_WORLD`). The core fans events out to them.

function CoAArena:NewModule(name)
   assert(not self.modules[name], "CoAArena: module already registered: " .. tostring(name))
   local module = { name = name }
   self.modules[name] = module
   table.insert(self.module_order, module)
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

function CoAArena:RegisterEvent(event, module)
   assert(type(event) == "string", "CoAArena: event must be a string")
   assert(type(module) == "table", "CoAArena: event owner must be a module")

   local subscribers = self.event_modules[event]
   if not subscribers then
      subscribers = {}
      self.event_modules[event] = subscribers
      frame:RegisterEvent(event)
   end
   subscribers[module] = true
end

function CoAArena:UnregisterEvent(event, module)
   local subscribers = self.event_modules[event]
   if not subscribers then return end

   subscribers[module] = nil
   if next(subscribers) then return end

   self.event_modules[event] = nil
   frame:UnregisterEvent(event)
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
      for _, module in ipairs(CoAArena.module_order) do
         if module.OnEnable then module:OnEnable() end
      end
   end

   local subscribers = CoAArena.event_modules[event]
   if not subscribers then return end

   -- Use module load order for deterministic dispatch when multiple modules
   -- subscribe to the same event.
   for _, module in ipairs(CoAArena.module_order) do
      if subscribers[module] then
         local handler = module[event]
         if handler then handler(module, ...) end
      end
   end
end)
