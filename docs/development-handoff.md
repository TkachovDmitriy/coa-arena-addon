# Development handoff

Last updated: 2026-08-18.

This file is the restart point after clearing the chat history. Read it together
with `README.md`, `docs/addon-plan.md`, and `docs/manual-testing.md`.

## Product and architecture

TD ArenaLens is a pure Lua 5.1 addon for the Conquest of Azeroth WoW 3.3.5 client
(`Interface: 30300`). The first vertical slice records arena sessions,
opponents, win/loss, scoreboard data, and rated-team rating changes. History is
per-character in versioned SavedVariables and is shown with `/tdlens`.

The addon uses a private namespace, feature-based folders, one shared event
frame, deterministic module dispatch, and three-space Lua indentation. Arena
log persistence is owned only by `features/arena_log/store.lua`; its schema is
documented in `docs/match-schema.md`.

The addon was renamed from CoA Arena/`CoAArena` to TD ArenaLens/`TDArenaLens`
in the current working tree. The primary slash command is `/tdlens`, with
`/coaarena` retained as a compatibility alias. The old local SavedVariables
were inspected before the rename and contained no arena matches to migrate.

Implemented modules:

- `arena_session.lua`: arena lifecycle and final scoreboard handling.
- `opponent_capture.lua`: hostile-player combat-log capture and scoreboard
  enrichment.
- `store.lua`: schema v1, match IDs, append/read/latest operations.
- `history_frame.lua`: recent-match history UI only.
- `log_frame.lua`: copyable runtime diagnostics plus command/version/author UI.
- `reporting.lua`: shared debug, BG export, and latest-arena report generation.
- `action_bar.lua`: diagnostic-window buttons that delegate to reporting.
- `slash_commands.lua`: parsing and delegation for `/tdlens` and `/coaarena`.
- `minimap_button.lua`: draggable, position-persisted entry point for history
  and diagnostic views.

Gear/talent inspection, cooldown tracking, and a richer history UI remain
future work. Live skirmish and rated-arena validation is still a release gate.

## Repository and Git state

- Remote: `TkachovDmitriy/coa-arena-addon` on GitHub.
- Integration branch: `main`; use a new Conventional Commit feature/fix branch
  for each change and do not rewrite pushed/shared history.
- Current branch: `feat/bg-test-mode`, tracking
  `origin/feat/bg-test-mode`.
- Feature implementation and live-test documentation reached `5eac171` before
  this handoff note was added.
- `main`/`origin/main` head: `cc1149c`, which includes the merged Nix dev-shell
  PR (#4).
- BG test-mode commits: `0ad77cc` (implementation) and `5eac171` (live-test
  documentation). The branch is pushed but not merged into `main`.
- The working tree is intentionally uncommitted. It contains the live buffered
  opponent count, BG export, CoA combat-log argument fix, WoW pipe escaping,
  tests/docs, and the full TD ArenaLens rename. Git currently shows deleted
  `CoAArena/` files plus untracked `TDArenaLens/`; these are the expected
  unstaged directory renames, not lost files.
- Create/open the PR at
  `https://github.com/TkachovDmitriy/coa-arena-addon/pull/new/feat/bg-test-mode`.

`CLAUDE.md` and `.claude/` are intentionally excluded by `.gitignore` and must
not be committed. They are currently absent from the working tree, so their
contents were not available during the BG test-mode work.

## Development environment

The merged `flake.nix`/`flake.lock` provide pinned Lua 5.1, `luac`, `luacheck`,
`rg`, and Git:

```sh
nix develop
./scripts/check.sh
```

The last full `nix develop -c ./scripts/check.sh` run after all follow-up fixes
and the TD ArenaLens rename passed with 0 warnings and 0 errors in 15 Lua
files; the smoke test also passed. Do not run Lua checks after every small edit;
the agreed workflow is one full check after the change is complete, before
committing. Documentation-only edits need only `git diff --check`.

## Local WoW installation

WoW is launched through Lutris/Wine. The active client addon directory is:

```text
/home/td/Games/ascension-wow/drive_c/Program Files/Ascension Launcher/resources/ascension-live/Interface/AddOns
```

`TDArenaLens` should be a symlink from that directory to:

```text
/home/td/projects/own-develop/coa-arena-addon/TDArenaLens
```

The new symlink was created and verified. The obsolete `CoAArena` symlink was
removed; its former target was only renamed, not deleted. Because WoW discovers
addon folders at startup, fully restart the client before testing the renamed
addon rather than relying only on `/reload`.

The same rule applies when a new Lua file is added to the `.toc`. During the
minimap-launcher test, the already loaded history and diagnostic UI remained
available, but `/reload` logged `features\launcher\minimap_button.lua` in
`Logs/MissingFiles.txt` and reported the failed file in `Logs/FrameXML.log`.
Fully restart the CoA client before diagnosing the module itself; seeing the
rest of the addon UI only confirms that the addon loaded partially.
The minimap launcher now guards missing target modules and prints a restart
instruction instead of raising a Lua error when the addon loaded partially.

Quote the complete paths in shell commands because `Program Files` and
`Ascension Launcher` contain spaces. A stray self-referencing symlink named
`\` was accidentally created while copying a multiline command and was removed
by the user; it was unrelated to WoW or the addon.

## BG test mode

The current feature branch adds a runtime-only battleground mode so the capture
pipeline can be tested without an arena-ready character:

```text
/tdlens testbg on
/tdlens debug
/tdlens testbg off
```

Inside a BG, the expected lifecycle is `preparing(bg-test)`,
`active(bg-test)`, `complete(bg-test)`, then `idle` after turning the mode off.
Real arenas always take precedence over BG test mode. Test matches remain only
in memory, reset on `/reload`, and are never appended to arena SavedVariables
or displayed as arena history.

Live validation on 2026-08-18 succeeded through Lutris/Wine:

- hostile combat changed the state to `active(bg-test)`;
- the final scoreboard produced a BG captured message;
- the final debug state after disabling was `idle`;
- `test-opponents=29`;
- `matches=0` and `latest=#0`, confirming no BG data entered arena history.

This validates addon loading, commands, combat-log capture, scoreboard capture,
and the non-persistence guard. It does not validate arena instance detection,
arena-specific team/rating APIs, or CoA's arena event order.

The working tree now also makes active BG captures report their live buffered
opponent count in `/tdlens debug` and adds `/tdlens testbg export`. Export
prints one compact `BGTEST|...` line with completion, result, duration, team
IDs, opponent count, and a `Name:CLASS` list; it does not persist anything.
These follow-up changes pass the automated checks and the short live BG retest
below.

The first follow-up live attempt exposed a CoA 3.3.5 combat-log difference:
`COMBAT_LOG_EVENT_UNFILTERED` has no `hideCaster` argument. The former shifted
handler treated numeric source flags as names and eventually passed the spell
name `Razorice` to `bit.band`. The handler and smoke fixture now use the live
argument order. Literal pipe separators in the export format are also escaped
for WoW chat so `|result` is not interpreted as the `|r` color-reset code.

The 2026-08-18 follow-up BG retest exported a completed loss with 11 real player
names and no shifted numeric flags or spell names. The final debug state was
`idle`, `test-opponents=11`, `matches=0`, and `latest=#0`, confirming the
non-persistence guard after the fixes.

## Next work

1. Commit and push the follow-up changes, then merge `feat/bg-test-mode` into
   `main`.
2. Publish a GitHub pre-release for a community arena tester. `/tdlens log`
   provides a copyable runtime diagnostic window, so testers do not need to
   select export/debug output from chat.
3. Test both skirmish and rated arenas with an eligible character by using the
   full checklist in `docs/manual-testing.md`. Record CoA-specific API/event
   differences before changing the persisted schema.
