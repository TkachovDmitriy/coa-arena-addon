# Manual arena-log test

Run this checklist on the Conquest of Azeroth 3.3.5 client before releasing.
Private-server event behaviour can differ from stock WotLK even when the Lua
API has the same name.

## Setup

1. Symlink `TDArenaLens/` into `Interface/AddOns/TDArenaLens`.
2. Enable Lua errors with `/console scriptErrors 1` and run `/reload`.
3. Run `/tdlens debug`; expect `state=idle, matches=0, latest=#0` on a clean
   character database.
4. Verify the arena icon appears at the bottom-left of the minimap. Left-click it
   to open recent matches and right-click it to open the diagnostic log. Drag it
   around the minimap, run `/reload`, and verify that its position is restored.

When testing a newly added Lua file, fully exit and restart the CoA client.
`/reload` can reload the addon's existing UI while the new file still fails to
open and is recorded in `Logs/MissingFiles.txt`; the presence of other addon UI
therefore does not prove every file listed in the `.toc` was loaded. Check
`Logs/FrameXML.log` for the exact file when a newly added module is missing.

## Match capture

1. Enter an arena. Expect `Arena entered — preparing match capture.`
2. Run `/tdlens debug` before combat. Expect `state=preparing`.
3. Engage an opponent and run the command again. Expect `state=active`.
4. Finish the match. Before leaving, expect `Match saved: Win.` or
   `Match saved: Loss.`
5. Run `/tdlens` and verify the newest row shows the result, rating change
   when rated, and all scoreboard opponents.
6. Leave the arena and run `/reload`. Open `/tdlens` again and verify the
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

## Battleground test mode

Use this when an arena-ready character is unavailable. It exercises the same
combat-log and scoreboard capture pipeline but never writes the result to arena
history or SavedVariables.

1. Enter a battleground and run `/tdlens testbg on`.
2. Expect `BG test capture started` and `state=preparing(bg-test)` from
   `/tdlens debug`.
   During the pre-match countdown, hostile buffs must not create `COMBAT`
   lines, add test opponents, or change the state to `active(bg-test)`.
3. Engage a hostile player and expect `state=active(bg-test)`.
   Run `/tdlens debug` and verify `test-opponents` immediately reflects the
   opponents captured so far, before the scoreboard is final.
   Open `/tdlens log` and verify useful hostile-player casts, interrupts,
   dispels, aura applications, and deaths appear as copyable
   `COMBAT||event=...||source=...||dest=...` lines. Routine damage, healing,
   periodic ticks, and events exclusively between unrelated players must not
   be printed. Only events involving the player or their current target are
   traced. Spell events should also include `spell-id` and `spell` when CoA
   supplies them. Aura refresh/removal noise is intentionally omitted.
   Repeated instances of the same visible event, source name, destination
   name, and spell combination should appear only once per match, including
   equivalent summoned units with different GUIDs.
4. At the final scoreboard, expect `BG test captured`, including the result and
   opponent count. Arena `matches` must not increase.
5. Run `/tdlens testbg export`. Expect one `BGTEST|...` diagnostic line with
   the result, duration, team IDs, opponent count, and `Name:CLASS` list. Verify
   that `|result` is visible, names are player names rather than numeric flags
   or spell names, and exporting does not increase arena `matches`. Open
   `/tdlens log`, click `Select All`, and press Ctrl+C to copy the same line
   without selecting it from chat. The `Status`, `BG Start`, `BG Stop`, and
   `BG Export` buttons must perform the same actions as their slash commands.
6. Run `/tdlens testbg off` when finished. The mode is runtime-only and also
   resets to disabled on `/reload`.

Real arenas start and stop automatically; they intentionally have no manual
start/stop buttons. In `/tdlens log`, use `Arena Export` (or run
`/tdlens arena export`) to append the latest saved arena record to the copyable
diagnostic text.

BG testing does not validate arena instance detection, arena-specific team and
rating APIs, or CoA's arena event order. Complete the arena checklist above
before release.

### Live validation log

- 2026-08-18 — CoA client launched through Lutris/Wine: BG test capture moved
  through `preparing(bg-test)`, `active(bg-test)`, `complete(bg-test)`, and
  back to `idle`. The final debug state reported 29 test opponents while
  `matches=0` and `latest=#0`, confirming that capture worked without writing
  BG data to arena history. Arena-specific validation remains outstanding.
- 2026-08-18 — Follow-up BG retest completed after correcting the CoA combat-log
  argument order and WoW pipe escaping. Export reported `complete=1`,
  `result=loss`, 1158 seconds, player team 0, winner team 1, and 11 real player
  names. Final debug state was `idle`, `test-opponents=11`, `matches=0`, and
  `latest=#0`. One scoreboard entry had an unavailable class token (`?`), which
  is retained as unknown rather than guessed.
- 2026-08-18 — Final short post-`/reload` BG validation completed with the
  filtered combat trace. It retained useful target casts, aura applications,
  and a dispel without damage/heal/tick or aura refresh/removal noise; no Lua
  errors were observed. Export reported `complete=1`, `result=loss`, 716
  seconds, player team 1, winner team 0, and 15 named opponents with valid
  class tokens. Final debug state was `idle`, `test-opponents=15`, `matches=0`,
  and `latest=#0`, confirming once more that BG data was not persisted. A
  multi-target `Harvesting Grounds` aura burst produced several distinct
  destination lines as expected.
