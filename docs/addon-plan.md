# Companion addon — implementation plan

Builds on the addon idea originally captured in the ladder-site repo
(`coa-wow-parse`, `docs/improvement-ideas.md`): per-match stats via
`COMBAT_LOG_EVENT_UNFILTERED`, inspect API, arena UI events. This doc is the
actual build plan for this addon repo.

## Repo decision

**Separate repo** (`coa-arena-addon`, this repo). Reasoning: different stack
(Lua, WoW 3.3.5 client API, `.toc` manifest), different release mechanism
(git tags → zipped GitHub Release, not GitHub Pages), zero shared code with
the ladder site's TS/React repo, and a standalone repo is easier for players
to find/understand than a subfolder buried in a Vite project. This plan doc
now lives in this repo's `docs/`; the ladder site (`coa-wow-parse`) keeps its
own backlog copy of the original idea.

## Phase 0 — Validate demand (in progress)

- Tally poll embedded on the ladder site (`feat/validation-poll-popup`)
  asking if players would use an addon like this.
- **Decision gate:** don't start Phase 1 until the poll shows real positive
  signal. No fixed threshold yet — revisit once responses come in.

## Phase 1 — Addon MVP (addon-only, no backend)

Goal: log a play session's arena matches and let the player browse that
history in-game. No site, no upload, no login — everything lives in
`SavedVariables`.

Scope:
- `.toc` scaffold targeting interface version `30300` (WotLK 3.3.5, CoA's
  client version).
- Arena session detection — reliably detect entering/leaving an arena
  match (zone/instance check) so logging doesn't run outside arenas.
- Opponent capture:
  - Identity via `COMBAT_LOG_EVENT_UNFILTERED` (who's in the match).
  - Gear/talents via `NotifyInspect` / `INSPECT_READY` — best-effort, since
    the client only returns inspect data for units actually inspected in
    time, not guaranteed for every opponent every match.
  - Result + rating delta via arena UI events fired at match end.
- Persistence: buffer matches into `SavedVariables`, per character (arena
  rating/history is per-character, not per-account). Versioned schema so a
  later addon update can migrate old saved data instead of breaking on it.
- In-game UI: a simple frame to browse logged matches (this session +
  persisted history) — list view, opponent details on click. No fancy
  styling needed for v1.
- Testing: manual only (log into CoA, queue arena, verify capture) — no Lua
  unit test tooling planned for v1, consistent with keeping this lean.

Explicitly out of scope for Phase 1: any network call (client sandboxing
makes this impossible anyway), site integration, login/auth.

## Phase 2 — Distribution

- GitHub Releases on the new repo: zip of `.toc`/`.lua`, semver git tags.
- Post in the CoA/Ascension forum's Addons category (where players actually
  look — CurseForge/WowInterface don't accept private-server addons).
- Link to the release from the ladder site once the addon is usable.

## Phase 3 — Site upload/backend (conditional)

Only build if Phase 1 gets real adoption and players specifically ask for
sharing/comparison, not just personal in-game history:

- Player copies the session's text dump, pastes into the ladder site
  (requires login to attribute it).
- Site parses the blob into per-match records — opponents faced, gear,
  win/loss, rating delta.
- Backend candidate: **Supabase** (Postgres + built-in auth + row-level
  security, free tier, no server to host ourselves). Fallback: a small
  Hetzner VPS if usage outgrows the free tier.
- New site page/domain for per-match stats, separate from the existing
  ladder table.

## Open risks / unknowns

- `SavedVariables` only writes on UI reload or logout — a client crash
  mid-session loses that session's unsaved matches.
- Inspect API can't guarantee gear/talent capture for every opponent within
  an arena match's time window.
- Need to confirm the exact 3.3.5 event/API for reliable arena start/end
  detection and for reading the post-match rating delta before writing any
  code — noted here as a spike, not solved yet.
- Combat log volume in a busy arena fight — needs a cheap filter (own
  arena unit IDs only) to avoid perf issues.

## Notes

- 2026-08-18: plan drafted, repo decision made (separate repo, created
  later). No code written yet — still gated on Phase 0 poll signal.
