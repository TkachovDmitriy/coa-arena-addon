-- diagnostics :: inspect_probe — live hostile-target Inspect capability test.
-- This deliberately does not read or persist equipment. It only establishes
-- whether CoA permits the request and delivers INSPECT_READY for the target.
local ADDON_NAME, ns = ...
local TDArenaLens = ns.addon
local L = ns.L
local util = ns.util

local InspectProbe = TDArenaLens:NewModule("InspectProbe")

function InspectProbe:OnEnable()
   self.pending_guid = nil
   self.pending_name = nil
   TDArenaLens:RegisterEvent("INSPECT_READY", self)
end

function InspectProbe:Run()
   if not UnitExists("target") then
      util.Print(L["INSPECT_NO_TARGET"])
      return
   end

   local name = UnitName("target") or L["UNKNOWN"]
   local guid = UnitGUID("target")
   local allowed = CanInspect("target") and true or false
   util.Print(string.format(
      L["INSPECT_CHECK"],
      name,
      allowed and "yes" or "no",
      tostring(guid)
   ))

   if not allowed then
      self.pending_guid = nil
      self.pending_name = nil
      return
   end

   self.pending_guid = guid
   self.pending_name = name
   NotifyInspect("target")
   util.Print(string.format(L["INSPECT_REQUESTED"], name))
end

function InspectProbe:INSPECT_READY(guid)
   if not self.pending_guid then return end

   if guid and guid ~= self.pending_guid then
      util.Log(string.format(
         L["INSPECT_READY_OTHER"],
         tostring(guid),
         tostring(self.pending_guid)
      ))
      return
   end

   util.Print(string.format(
      L["INSPECT_READY"],
      self.pending_name or L["UNKNOWN"],
      tostring(guid or self.pending_guid)
   ))
   self.pending_guid = nil
   self.pending_name = nil
end
