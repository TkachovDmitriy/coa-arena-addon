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
- The technical vertical slice proceeded to retire the largest API risks.
  Distribution and any backend investment remain gated on positive demand;
  no fixed threshold has been chosen yet.

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
- Testing: Lua 5.1 syntax/static checks and a framework-free mocked smoke test;
  actual event order and data still require manual matches on CoA.

Explicitly out of scope for Phase 1: any network call (client sandboxing
makes this impossible anyway), site integration, login/auth.

### Current implementation status

The first vertical slice is implemented: arena entry/exit lifecycle, hostile
player capture through `COMBAT_LOG_EVENT_UNFILTERED`, final scoreboard capture
through `UPDATE_BATTLEFIELD_SCORE`, versioned per-character persistence, and a
minimal `/tdlens` history view. `/tdlens debug` exposes the current capture
state for live CoA testing. A runtime-only `/tdlens testbg on` mode reuses
the capture pipeline in battlegrounds without writing test data to arena
history; it is a partial validation path, not a replacement for arena tests.

Still required before calling Phase 1 complete:

- Run and document the manual arena checklist on CoA for skirmish and rated
  matches.
- Add best-effort gear/talent inspection after validating hostile-unit inspect
  behaviour on the server.
- Improve the history browser with selectable opponent details.

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
- Stock 3.3.5 exposes final arena data on `UPDATE_BATTLEFIELD_SCORE` through
  `GetBattlefieldWinner`, `GetBattlefieldScore`, and
  `GetBattlefieldTeamInfo`. The implementation follows that path, but it still
  needs live verification against CoA's server-specific behaviour.
- Combat log volume in a busy arena fight — capture currently performs only a
  bitmask check for hostile players, but live profiling should confirm the
  filter is cheap enough on CoA.

## Notes

- 2026-08-18: plan drafted and the addon scaffold created in this separate
  repository.
- 2026-08-18: first arena-log vertical slice implemented; live CoA validation
  remains the release gate.
- 2026-08-18: added a non-persistent battleground test mode for characters
  that cannot yet queue for arenas.
- 2026-08-18: validated the BG test lifecycle and hostile-player capture live
  on CoA through Lutris/Wine; 29 opponents were observed and arena history
  remained empty. Real arena validation is still required.
