# Ladder test — release checklist

Use this short checklist for the final go/no-go decision. Detailed procedures
and expected messages remain in `docs/manual-testing.md`.

## Setup

- [ ] Fully restart the CoA client after installing the candidate build.
- [ ] Enable Lua errors and confirm login/reload produces no addon errors.
- [ ] Open history and diagnostics; visually check layout, buttons, text, and
      minimap dragging in the real client.
- [ ] Run `/tdlens debug on` and confirm it remains enabled after `/reload`.

## Skirmish

- [ ] Capture moves through preparing, active, and complete states.
- [ ] Win/loss and every opponent are correct in recent history.
- [ ] Leaving before combat creates no empty record.
- [ ] Leaving after combat without a final scoreboard creates one incomplete
      record instead of an error or duplicate.

## Rated arena

- [ ] Result, team IDs, rating before/after, and rating delta are correct.
- [ ] The record survives `/reload` and receives the next unique match ID.
- [ ] `/tdlens arena export` matches the visible saved record.

## Diagnostics and isolation

- [ ] Debug mode produces useful `SESSION||...` and filtered `COMBAT||...`
      lines; debug off suppresses those verbose lines.
- [ ] `/tdlens debug` reports `errors=0` throughout the clean test.
- [ ] The diagnostic text is selectable and copyable without a Lua error.
- [ ] BG test mode still leaves the persisted arena match count unchanged.

Release only when every applicable box passes. Record server-specific event or
API differences before changing the SavedVariables schema.
