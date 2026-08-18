# Manual arena-log test

Run this checklist on the Conquest of Azeroth 3.3.5 client before releasing.
Private-server event behaviour can differ from stock WotLK even when the Lua
API has the same name.

## Setup

1. Symlink `CoAArena/` into `Interface/AddOns/CoAArena`.
2. Enable Lua errors with `/console scriptErrors 1` and run `/reload`.
3. Run `/coaarena debug`; expect `state=idle, matches=0, latest=#0` on a clean
   character database.

## Match capture

1. Enter an arena. Expect `Arena entered — preparing match capture.`
2. Run `/coaarena debug` before combat. Expect `state=preparing`.
3. Engage an opponent and run the command again. Expect `state=active`.
4. Finish the match. Before leaving, expect `Match saved: Win.` or
   `Match saved: Loss.`
5. Run `/coaarena` and verify the newest row shows the result, rating change
   when rated, and all scoreboard opponents.
6. Leave the arena and run `/reload`. Open `/coaarena` again and verify the
   record survived through `SavedVariables`.

## Failure paths

- Leave after combat but before a final scoreboard is available. Verify one
  incomplete match is stored with an unknown result.
- Enter and leave before combat. Verify no empty match is stored.
- Play two matches without `/reload`. Verify IDs increase and no opponents
  leak from the first match into the second.
- Test skirmish and rated arena separately; skirmish rating must display as
  `--`.

Record any CoA-specific differences in event order or API return values before
changing the persistence schema.
