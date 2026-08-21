-- diagnostics :: inspect_probe — live hostile-target Inspect capability test.
-- CoA signals completed inspect data with INSPECT_TALENT_READY rather than
-- the retail-style INSPECT_READY event. Keep both paths for compatibility.
local ADDON_NAME, ns = ...
local TDArenaLens = ns.addon
local L = ns.L
local util = ns.util

local InspectProbe = TDArenaLens:NewModule("InspectProbe")

local function clean_field(value)
   value = tostring(value or "?")
   value = string.gsub(value, "[\r\n]+", " ")
   return string.gsub(value, "|", "/")
end

function InspectProbe:OnEnable()
   self.pending_guid = nil
   self.pending_name = nil
   self.timeout_frame = CreateFrame("Frame")
   self.timeout_frame:Hide()
   self.timeout_frame:SetScript("OnUpdate", function(current, elapsed)
      current.elapsed = current.elapsed + elapsed
      if current.elapsed < 12 then return end

      current:Hide()
      util.Print(string.format(
         L["INSPECT_TIMEOUT"],
         clean_field(self.pending_name),
         clean_field(self.pending_guid)
      ))
      self.pending_guid = nil
      self.pending_name = nil
   end)
   TDArenaLens:RegisterEvent("INSPECT_TALENT_READY", self)
   TDArenaLens:RegisterEvent("INSPECT_READY", self)
end

function InspectProbe:LogEquipment(unit)
   local item_count = 0
   local average = "?"

   if type(UnitAverageItemLevel) == "function" then
      local value = UnitAverageItemLevel(unit)
      if type(value) == "number" and value > 0 then
         average = string.format("%.1f", value)
      end
   end

   for slot = 1, 19 do
      local link = GetInventoryItemLink(unit, slot)
      if link then
         item_count = item_count + 1
         local item_id = string.match(link, "item:([%-]?%d+)") or "?"
         local name, _, _, item_level = GetItemInfo(link)
         util.Log(string.format(
            L["INSPECT_ITEM"],
            clean_field(self.pending_name),
            slot,
            clean_field(item_id),
            clean_field(item_level),
            clean_field(name)
         ))
      end
   end

   util.Print(string.format(
      L["INSPECT_EQUIPMENT"],
      clean_field(self.pending_name),
      clean_field(self.pending_guid),
      average,
      item_count
   ))
end

function InspectProbe:Complete(event, guid)
   if not self.pending_guid then return end

   local current_guid = UnitGUID("target")
   if current_guid ~= self.pending_guid then
      util.Log(string.format(
         L["INSPECT_TARGET_CHANGED"],
         clean_field(event),
         clean_field(current_guid),
         clean_field(self.pending_guid)
      ))
      return
   end

   if guid and guid ~= self.pending_guid then
      util.Log(string.format(
         L["INSPECT_READY_OTHER"],
         tostring(guid),
         tostring(self.pending_guid)
      ))
      return
   end

   self.timeout_frame:Hide()
   util.Print(string.format(
      L["INSPECT_READY"],
      self.pending_name or L["UNKNOWN"],
      tostring(guid or self.pending_guid),
      event
   ))
   self:LogEquipment("target")
   self.pending_guid = nil
   self.pending_name = nil
end

function InspectProbe:Run()
   if not UnitExists("target") then
      self.timeout_frame:Hide()
      self.pending_guid = nil
      self.pending_name = nil
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
      self.timeout_frame:Hide()
      self.pending_guid = nil
      self.pending_name = nil
      return
   end

   self.pending_guid = guid
   self.pending_name = name
   self.timeout_frame.elapsed = 0
   self.timeout_frame:Show()
   NotifyInspect("target")
   util.Print(string.format(L["INSPECT_REQUESTED"], name))
end

function InspectProbe:INSPECT_READY(guid)
   self:Complete("INSPECT_READY", guid)
end

function InspectProbe:INSPECT_TALENT_READY()
   self:Complete("INSPECT_TALENT_READY")
end
