# Development handoff

Last updated: 2026-08-18.

This file is the restart point after clearing the chat history. Read it together
with `README.md`, `docs/addon-plan.md`, and `docs/manual-testing.md`.

## Product and architecture

CoA Arena is a pure Lua 5.1 addon for the Conquest of Azeroth WoW 3.3.5 client
(`Interface: 30300`). The first vertical slice records arena sessions,
opponents, win/loss, scoreboard data, and rated-team rating changes. History is
per-character in versioned SavedVariables and is shown with `/coaarena`.

The addon uses a private namespace, feature-based folders, one shared event
frame, deterministic module dispatch, and three-space Lua indentation. Arena
log persistence is owned only by `features/arena_log/store.lua`; its schema is
documented in `docs/match-schema.md`.

Implemented modules:

- `arena_session.lua`: arena lifecycle and final scoreboard handling.
- `opponent_capture.lua`: hostile-player combat-log capture and scoreboard
  enrichment.
- `store.lua`: schema v1, match IDs, append/read/latest operations.
- `history_frame.lua`: `/coaarena`, `/coaarena debug`, and BG test commands.

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

The last full check after implementing BG test mode passed with 0 warnings and
0 errors. Do not run Lua checks after every small edit; the agreed workflow is
one full check after the change is complete, before committing. Documentation-
only edits need only `git diff --check`.

## Local WoW installation

WoW is launched through Lutris/Wine. The active client addon directory is:

```text
/home/td/Games/ascension-wow/drive_c/Program Files/Ascension Launcher/resources/ascension-live/Interface/AddOns
```

`CoAArena` should be a symlink from that directory to:

```text
/home/td/projects/own-develop/coa-arena-addon/CoAArena
```

Quote the complete paths in shell commands because `Program Files` and
`Ascension Launcher` contain spaces. A stray self-referencing symlink named
`\` was accidentally created while copying a multiline command and was removed
by the user; it was unrelated to WoW or the addon.

## BG test mode

The current feature branch adds a runtime-only battleground mode so the capture
pipeline can be tested without an arena-ready character:

```text
/coaarena testbg on
/coaarena debug
/coaarena testbg off
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

## Next work

Before merging the BG test-mode branch:

1. Improve `/coaarena debug` so an active BG test shows the current buffered
   opponent count. It currently shows opponents only from the last completed
   test, which caused understandable confusion during live testing.
2. Add `/coaarena testbg export` to print a compact diagnostic result that can
   be copied without persisting it as arena history.
3. Update the smoke test and manual-testing documentation for both behaviours.
4. Run one final `nix develop -c ./scripts/check.sh`, push, and repeat the short
   live BG test.
5. Merge `feat/bg-test-mode` into `main` after the retest passes.

Later, test both skirmish and rated arenas with an eligible character by using
the full checklist in `docs/manual-testing.md`. Record CoA-specific API/event
differences before changing the persisted schema.
