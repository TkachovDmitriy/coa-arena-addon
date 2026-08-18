# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working in this repository.

Detailed, self-contained rules live in `.claude/rules/`
(`git-flow.md`, `lua-addon.md`); this file is the high-level overview.

## What this is

A World of Warcraft **3.3.5 (WotLK)** companion addon for the Conquest of
Azeroth private server — logs arena matches, opponents, and cooldowns. Pure
Lua, no build step. The ladder website that inspired it lives in a separate
repo (`coa-wow-parse`); this repo shares no code with it.

See `docs/addon-plan.md` for the phased roadmap.

## Layout

```
coa-arena-addon/            # repo root (docs, CI, meta)
├── docs/                   # planning / design notes
└── CoAArena/               # the actual addon — symlink THIS into AddOns/
    ├── CoAArena.toc        # manifest: interface 30300, files in load order
    ├── Core.lua            # bootstrap: namespace, module registry, events
    ├── Locales/            # enUS.lua is the base locale
    ├── Modules/            # one file per feature (e.g. ArenaSession.lua)
    ├── UI/                 # frame definitions
    └── Media/              # textures / fonts / sounds
```

## Addon conventions

- **Private namespace, not globals.** Every file starts with
  `local ADDON_NAME, ns = ...` and hangs state off `ns`. The only intentional
  global is `_G.CoAArena` (for `/`-commands and debugging).
- **One event frame.** `Core.lua` owns the single `CreateFrame("Frame")` and
  fans events out to modules. Modules never create their own event frames —
  they call `CoAArena:NewModule(name)`, declare an optional `OnEnable`, and
  add event-named methods (`PLAYER_ENTERING_WORLD`, etc.) that the core
  dispatches to.
- **Load order is explicit in the `.toc`.** Locales → `Core.lua` → modules.
  Add new files to `CoAArena.toc`; there is no autoloader.
- **SavedVariables.** `CoAArenaDB` (account) and `CoAArenaCharDB` (per
  character — arena rating/history is per character). Only populated after
  `ADDON_LOADED`; version any schema so future updates can migrate old data.
- **Target client is 3.3.5** — only use APIs available in interface `30300`.
  No retail-only functions.

## Testing

Manual only: symlink `CoAArena/` into
`World of Warcraft/Interface/AddOns/`, log in, queue an arena, verify capture.
No Lua unit-test tooling. `luacheck` is welcome for static checks if installed
(`.luacheckcache` is gitignored).

## Git flow

[`.claude/rules/git-flow.md`](.claude/rules/git-flow.md) is the general org
playbook (GitLab / Jira / `develop`). **This repo is simpler**, and these
overrides win here:

- **GitHub, `main` only** — no `develop` integration branch. Short-lived
  `feat/*` / `fix/*` branches → PR into `main`.
- **Conventional Commits** subjects (`feat:`, `fix:`, `docs:`, `chore:`) — no
  Jira keys / bracketed prefixes (there is no Jira here).
- Never commit to `main` directly; no `Co-Authored-By` trailer.

Everything else in the playbook (branch-per-change, one logical change per PR,
don't rewrite shared history) still applies.

Addon-specific: **releases** are semver git tags → a zipped GitHub Release of
the `CoAArena/` folder (see `docs/addon-plan.md`, Phase 2). No
CurseForge/WowInterface — they don't accept private-server addons.
