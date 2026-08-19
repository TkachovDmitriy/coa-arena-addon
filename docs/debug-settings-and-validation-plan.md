# Debug, settings, and validation plan

This plan follows the `v0.1.0-alpha.1` baseline. Implementation is intentionally
split into small reviewable groups. Items 1–5 are implemented in the current
working tree. Item 6 and the deterministic portion of item 7 are implemented;
items 8–9 are documentation and final verification.

## 1. Update the handoff documentation

- Correct outdated branch and working-tree information.
- Record `v0.1.0-alpha.1` as the current baseline.
- Separate completed BG validation from pending live ladder validation.

## 2. Introduce persistent settings

- Add a versioned account-wide settings table to `TDArenaLensDB`.
- Define safe defaults, initially `debug_enabled = false`.
- Preserve valid existing settings across `/reload`.
- Reset missing or malformed setting values to their defaults.

## 3. Add a controllable debug mode

- `/tdlens debug` prints capture and debug status.
- `/tdlens debug on` and `/tdlens debug off` update the persistent setting.
- Add a debug toggle to the diagnostic window.
- Keep detailed combat-log gating out of this group; that belongs to item 4.

## 4. Gate detailed logs behind debug mode

- Keep normal operational messages available.
- Record detailed `COMBAT||...` traces only when debug mode is enabled.
- Add useful lifecycle diagnostics without persisting the runtime log.

Status: implemented.

## 5. Harden SavedVariables handling

- Cover initialization, reload, existing history, and match ID continuity.
- Recover safely from malformed containers and values.
- Refuse unsupported future schemas without silently overwriting them.

Status: implemented.

## 6. Improve runtime error handling

- Isolate module startup and event-handler failures.
- Report the module and event involved in each error.
- Avoid continuing when doing so could corrupt persisted match data.

Status: implemented by quarantining a failed module while allowing unrelated
modules to continue.

## 7. Expand deterministic tests

- Cover commands, settings, persistence, debug gating, and event dispatch.
- Simulate unavailable modules and event-handler failures.
- Leave layout, readability, dragging feel, and other visual UI checks to the
  real client; improve UI only when those checks expose an issue.

Status: implemented for behavior that can be represented reliably by the
mocked Lua environment.

## 8. Create a concise ladder release checklist

- Retain the detailed manual guide and add a short go/no-go checklist.
- Cover skirmish, rated matches, opponents, rating changes, persistence,
  incomplete matches, diagnostic export, and BG non-persistence.

Status: documented in `docs/ladder-release-checklist.md`.

## 9. Verify the completed change

- Run Lua 5.1 syntax checks, `luacheck`, smoke tests, and whitespace checks.
- Review SavedVariables compatibility and the final diff.
- Keep live skirmish and rated-arena validation marked as a release gate.

Status: repository checks pass with zero warnings/errors in 16 Lua files;
live ladder validation remains pending.
