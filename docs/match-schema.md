# Arena match schema v1

Arena history lives at `TDArenaLensCharDB.arena_log`. The container has a
`schema`, a monotonic `next_id`, and an ordered `matches` array. All fields are
plain Lua values so the WoW client can serialize them as `SavedVariables`.

Each match contains:

- Identity: `id`, `started_at`, `first_combat_at`, `ended_at`, `duration`,
  `zone`.
- Status: `is_arena`, `is_rated`, `is_complete`, `result`, `winner_team`.
- Player: `player_team`, `player`, `team_name`, `rating_before`,
  `rating_after`, `rating_change`, `matchmaking_rating`.
- Opponents: an array of combat-log/scoreboard records with `guid`, `name`,
  race/class fields, team, killing blows, deaths, damage and healing.

Optional or unavailable values are omitted by the SavedVariables serializer.
`result` is always `win`, `loss`, or `unknown`. An incomplete record represents
a match where combat was observed but the final scoreboard was unavailable
before the player left the arena.

Schema migrations belong exclusively in `features/arena_log/store.lua`.
Feature code must use the store API instead of accessing
`TDArenaLensCharDB.arena_log` directly.
