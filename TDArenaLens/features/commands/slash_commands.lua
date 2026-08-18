-- commands :: slash_commands — the single routing boundary for user commands.
-- Feature modules own behaviour and UI; this adapter only parses and delegates.
local ADDON_NAME, ns = ...
local TDArenaLens = ns.addon

local SlashCommands = TDArenaLens:NewModule("SlashCommands")

function SlashCommands:OnEnable()
   SLASH_TDARENALENS1 = "/tdlens"
   SLASH_TDARENALENS2 = "/coaarena"
   SlashCmdList.TDARENALENS = function(message) self:Handle(message) end
end

function SlashCommands:HandleBgTest(command)
   local reporting = TDArenaLens:GetModule("DiagnosticReporting")
   local setting = string.match(command, "^testbg%s+(%S+)$")

   if setting == "export" then
      reporting:ExportBgTest()
   elseif setting == "on" or setting == "off" then
      reporting:SetBgTestEnabled(setting == "on")
   else
      reporting:PrintBgTestStatus()
   end
end

function SlashCommands:Handle(message)
   local command = string.lower(message or "")
   command = string.match(command, "^%s*(.-)%s*$")

   if command == "log" then
      TDArenaLens:GetModule("DiagnosticLogFrame"):Toggle()
   elseif command == "help" or command == "about" or command == "commands" then
      TDArenaLens:GetModule("DiagnosticLogFrame"):Show()
   elseif command == "testbg" or string.match(command, "^testbg%s+") then
      self:HandleBgTest(command)
   elseif command == "arena export" then
      TDArenaLens:GetModule("DiagnosticReporting"):ExportLatestArena()
   elseif command == "debug" then
      TDArenaLens:GetModule("DiagnosticReporting"):PrintDebugState()
   else
      TDArenaLens:GetModule("HistoryFrame"):Toggle()
   end
end
