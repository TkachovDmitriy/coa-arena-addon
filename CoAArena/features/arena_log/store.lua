-- arena_log :: store — persistence layer for the arena-log domain. Owns the
-- SavedVariables schema and migrations; every other file in this domain reads
-- and writes matches through here, never touching CoAArenaCharDB directly.
local ADDON_NAME, ns = ...

local store = {}
ns.arena_log = ns.arena_log or {}
ns.arena_log.store = store

local SCHEMA_VERSION = 1

-- Initialise (and migrate) the per-character arena-log table in place.
function store.Init(char_db)
   char_db.arena_log = char_db.arena_log or { schema = SCHEMA_VERSION, matches = {} }
   -- FIXME(phase1): migrate older schema versions up to SCHEMA_VERSION here.
   return char_db.arena_log
end

-- Append a finished match record to the persisted history.
function store.AppendMatch(match)
   -- TODO(phase1): validate `match` and insert into char_db.arena_log.matches.
end
