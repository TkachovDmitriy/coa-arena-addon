-- Shared account-wide settings. This module loads before feature modules so
-- every feature sees validated defaults during its OnEnable callback.
local ADDON_NAME, ns = ...
local TDArenaLens = ns.addon

local Settings = TDArenaLens:NewModule("Settings")
local SCHEMA_VERSION = 1

local defaults = {
   debug_enabled = false,
}

function Settings:Init(account_db)
   assert(type(account_db) == "table", "settings require account SavedVariables")

   local settings = account_db.settings
   if type(settings) ~= "table" then
      settings = { schema = SCHEMA_VERSION }
      account_db.settings = settings
   end

   if settings.schema == nil then
      settings.schema = SCHEMA_VERSION
   elseif type(settings.schema) ~= "number" then
      settings = { schema = SCHEMA_VERSION }
      account_db.settings = settings
   end
   assert(settings.schema == SCHEMA_VERSION, "unsupported settings schema")

   for key, default in pairs(defaults) do
      if type(settings[key]) ~= type(default) then settings[key] = default end
   end

   self.db = settings
   return settings
end

function Settings:OnEnable()
   self:Init(TDArenaLens.db)
end

function Settings:IsDebugEnabled()
   return self.db and self.db.debug_enabled or false
end

function Settings:SetDebugEnabled(enabled)
   assert(self.db, "settings are not initialised")
   self.db.debug_enabled = enabled and true or false
end
