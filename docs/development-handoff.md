# Development handoff

Last updated: 2026-08-19.

This is the current restart point for TD ArenaLens. Read it with `README.md`,
`docs/addon-plan.md`, `docs/manual-testing.md`, and
`docs/debug-settings-and-validation-plan.md`.

## Current repository state

- Baseline: `v0.1.0-alpha.1`, commit `5864542` on `main`.
- The alpha release, BG test mode, combat diagnostic trace, and persisted
  minimap position are merged into `main`.
- The repository was clean before the debug/settings work began.
- Use a new Conventional Commit branch for each independently reviewable
  change; do not rewrite shared history.

Earlier versions of this handoff described BG and combat-diagnostic work as
uncommitted. That information became obsolete when those changes were merged
and tagged, and has intentionally been removed.

## Product and architecture

TD ArenaLens is a pure Lua 5.1 addon for the Conquest of Azeroth WoW 3.3.5
client (`Interface: 30300`). It uses a private namespace, feature-based
folders, one shared event frame, deterministic module dispatch, and
three-space Lua indentation.

The implemented vertical slice detects arena sessions, captures hostile
players and the final scoreboard, calculates rated-team rating changes,
stores versioned per-character match records, and shows recent history through
`/tdlens`. The diagnostic window is available through `/tdlens log`; the
draggable minimap button opens history with left-click and diagnostics with
right-click.

Arena persistence is owned by `features/arena_log/store.lua`. Account-wide
settings are owned by `shared/settings.lua`. Other modules must use those
boundaries instead of writing SavedVariables directly.

## Validation completed

BG test mode was validated live on 2026-08-18 through Lutris/Wine. It moved
through the expected preparing, active, complete, and idle states; captured
real opponent names and scoreboard data; produced copyable exports; and did
not write BG matches into arena history.

The combat diagnostic trace was also validated live. It retains useful casts,
interrupts, dispels, aura applications, and hostile deaths involving the
player or current target, while excluding routine damage/healing noise. The
runtime buffer is limited to 500 lines and is not persisted.

The repository checks at the `v0.1.0-alpha.1` baseline pass with zero warnings
or errors in 15 Lua files, including the mocked arena/BG smoke test.

## Validation still pending

Live skirmish and rated-arena testing is the release gate. BG testing does not
validate arena instance detection, CoA's arena event order, final arena team
IDs, or rating APIs. Follow `docs/manual-testing.md` before declaring Phase 1
complete.

Gear/talent inspection, cooldown tracking, and selectable opponent details in
the history UI remain future work.

## Current implementation group

The ordered plan is in `docs/debug-settings-and-validation-plan.md`. The
current implementation covers items 1–5:

1. update this handoff;
2. introduce versioned, account-wide persistent settings;
3. add persistent `/tdlens debug on|off` controls and a diagnostic UI toggle;
4. gate detailed combat and lifecycle traces behind that setting;
5. repair malformed SavedVariables while rejecting unknown future schemas.

Item 6 now quarantines failed modules and reports contextual errors while
unrelated modules continue. Deterministic error-dispatch behavior is covered
by the smoke test. Visual UI checks remain manual. The short release gate is
in `docs/ladder-release-checklist.md`; final live ladder validation remains
pending.

## Development environment

Run the complete repository checks from the pinned Nix environment:

```sh
nix develop --command ./scripts/check.sh
```

The active local addon path is expected to be a symlink named `TDArenaLens`
inside the Ascension client's `Interface/AddOns` directory. Fully restart the
client after adding a Lua file to the `.toc`; `/reload` is not sufficient for
the client to discover a newly listed file reliably.
