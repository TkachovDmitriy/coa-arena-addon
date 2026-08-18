-- arena_log :: store — persistence layer for the arena-log domain. Owns the
-- SavedVariables schema and migrations; every other file in this domain reads
-- and writes matches through here, never touching TDArenaLensCharDB directly.
local ADDON_NAME, ns = ...

local store = {}
ns.arena_log = ns.arena_log or {}
ns.arena_log.store = store

local SCHEMA_VERSION = 1
local arena_log_db

-- Initialise (and migrate) the per-character arena-log table in place.
function store.Init(char_db)
   assert(type(char_db) == "table", "arena_log store requires character SavedVariables")
   char_db.arena_log = char_db.arena_log or { schema = SCHEMA_VERSION, matches = {} }
   assert(char_db.arena_log.schema == SCHEMA_VERSION, "unsupported arena_log schema")

   char_db.arena_log.matches = char_db.arena_log.matches or {}
   if not char_db.arena_log.next_id then
      local highest_id = 0
      for _, match in ipairs(char_db.arena_log.matches) do
         highest_id = math.max(highest_id, tonumber(match.id) or 0)
      end
      char_db.arena_log.next_id = highest_id + 1
   end
   arena_log_db = char_db.arena_log
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
