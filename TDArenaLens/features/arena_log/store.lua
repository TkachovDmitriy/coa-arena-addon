-- arena_log :: store — persistence layer for the arena-log domain. Owns the
-- SavedVariables schema and migrations; every other file in this domain reads
-- and writes matches through here, never touching TDArenaLensCharDB directly.
local ADDON_NAME, ns = ...
local util = ns.util

local store = {}
ns.arena_log = ns.arena_log or {}
ns.arena_log.store = store

local SCHEMA_VERSION = 1
local arena_log_db

local function new_database()
   return { schema = SCHEMA_VERSION, matches = {}, next_id = 1 }
end

local function valid_match(match)
   return type(match) == "table"
      and type(match.started_at) == "number"
      and type(match.opponents) == "table"
end

-- Initialise (and migrate) the per-character arena-log table in place.
function store.Init(char_db)
   assert(type(char_db) == "table", "arena_log store requires character SavedVariables")
   if type(char_db.arena_log) ~= "table" then
      char_db.arena_log = new_database()
   end

   local database = char_db.arena_log
   if database.schema == nil then
      database.schema = SCHEMA_VERSION
   elseif type(database.schema) ~= "number" then
      database = new_database()
      char_db.arena_log = database
   end
   assert(database.schema == SCHEMA_VERSION, "unsupported arena_log schema")

   if type(database.matches) ~= "table" then database.matches = {} end

   local valid_matches = {}
   local highest_id = 0
   for _, match in ipairs(database.matches) do
      if valid_match(match) then
         table.insert(valid_matches, match)
         highest_id = math.max(highest_id, tonumber(match.id) or 0)
      else
         util.DebugLog("STORE||event=ignored-invalid-match")
      end
   end
   database.matches = valid_matches

   local next_id = tonumber(database.next_id)
   if not next_id or next_id < highest_id + 1 then next_id = highest_id + 1 end
   database.next_id = math.max(1, math.floor(next_id))

   arena_log_db = database
   return arena_log_db
end

-- Append a finished match record to the persisted history.
function store.AppendMatch(match)
   assert(arena_log_db, "arena_log store is not initialised")
   assert(type(match) == "table", "match must be a table")
   assert(type(match.started_at) == "number", "match.started_at must be a timestamp")
   assert(type(match.opponents) == "table", "match.opponents must be a table")

   match.id = tonumber(match.id) or arena_log_db.next_id
   arena_log_db.next_id = math.max(arena_log_db.next_id, match.id + 1)
   table.insert(arena_log_db.matches, match)
   return match
end

function store.GetMatches()
   assert(arena_log_db, "arena_log store is not initialised")
   return arena_log_db.matches
end

function store.GetLatestMatch()
   local matches = store.GetMatches()
   return matches[#matches]
end
