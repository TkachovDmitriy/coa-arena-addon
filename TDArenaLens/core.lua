-- TDArenaLens — core bootstrap.
--
-- Every file in this addon receives the same two `...` varargs from the
-- client: the addon's folder name and a private namespace table shared only
-- between our files. We hang everything off `ns` instead of the global
-- environment so we don't pollute `_G` (WoW addon best practice).
local ADDON_NAME, ns = ...

local TDArenaLens = ns.addon or {}
ns.addon = TDArenaLens
_G.TDArenaLens = TDArenaLens
_G.CoAArena = TDArenaLens -- compatibility alias for existing debug snippets

TDArenaLens.name = ADDON_NAME
TDArenaLens.version = GetAddOnMetadata(ADDON_NAME, "Version")
TDArenaLens.author = GetAddOnMetadata(ADDON_NAME, "Author")
TDArenaLens.modules = TDArenaLens.modules or {}
TDArenaLens.module_order = TDArenaLens.module_order or {}
TDArenaLens.event_modules = TDArenaLens.event_modules or {}

local function clean_error_message(message)
   return string.gsub(string.gsub(tostring(message), "[\r\n]+", " "), "|", "/")
end

-- Quarantine a module after an unhandled callback error. Continuing to invoke
-- a partially failed capture/persistence module risks corrupting session state;
-- unrelated modules may still receive their events normally.
function TDArenaLens:CallModule(module, context, handler, ...)
   if module.failed then return false end

   local ok, message = pcall(handler, module, ...)
   if ok then return true end

   module.failed = true
   module.failure_context = context
   module.failure_message = clean_error_message(message)

   local report = string.format(
      "ERROR||module=%s||context=%s||message=%s",
      tostring(module.name), tostring(context), module.failure_message
   )
   if ns.util and ns.util.Print then
      ns.util.Print(report)
   elseif DEFAULT_CHAT_FRAME then
      DEFAULT_CHAT_FRAME:AddMessage("TD ArenaLens: " .. report)
   end
   return false
end

-- Module registry -----------------------------------------------------------
-- A "module" is just a table with optional `OnEnable` and event-named methods
-- (e.g. `PLAYER_ENTERING_WORLD`). The core fans events out to them.

function TDArenaLens:NewModule(name)
   assert(not self.modules[name], "TDArenaLens: module already registered: " .. tostring(name))
   local module = { name = name }
   self.modules[name] = module
   table.insert(self.module_order, module)
   return module
end

function TDArenaLens:GetModule(name)
   return self.modules[name]
end

-- Event plumbing ------------------------------------------------------------
-- One hidden frame for the whole addon; modules never create their own event
-- frames, they just declare handlers and register interest via the core.
local frame = CreateFrame("Frame")
TDArenaLens.frame = frame

function TDArenaLens:RegisterEvent(event, module)
   assert(type(event) == "string", "TDArenaLens: event must be a string")
   assert(type(module) == "table", "TDArenaLens: event owner must be a module")

   local subscribers = self.event_modules[event]
   if not subscribers then
      subscribers = {}
      self.event_modules[event] = subscribers
      frame:RegisterEvent(event)
   end
   subscribers[module] = true
end

function TDArenaLens:UnregisterEvent(event, module)
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
      TDArenaLensDB = TDArenaLensDB or {}
      TDArenaLensCharDB = TDArenaLensCharDB or {}
      TDArenaLens.db = TDArenaLensDB
      TDArenaLens.charDB = TDArenaLensCharDB
      return
   end

   if event == "PLAYER_LOGIN" then
      for _, module in ipairs(TDArenaLens.module_order) do
         if module.OnEnable then
            TDArenaLens:CallModule(module, "OnEnable", module.OnEnable)
         end
      end
   end

   local subscribers = TDArenaLens.event_modules[event]
   if not subscribers then return end

   -- Use module load order for deterministic dispatch when multiple modules
   -- subscribe to the same event.
   for _, module in ipairs(TDArenaLens.module_order) do
      if subscribers[module] then
         local handler = module[event]
         if handler then TDArenaLens:CallModule(module, event, handler, ...) end
      end
   end
end)
