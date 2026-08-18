# CoA Arena Addon

A World of Warcraft companion addon for the Conquest of Azeroth arena scene.
It records match history and opponents, with cooldown tracking planned for a
later phase.

## Development status

- Detects arena sessions and records completed matches
- Captures opponent identity and final scoreboard statistics
- Stores win/loss and rated-team rating changes per character
- Shows the ten most recent matches with `/coaarena`
- Reports capture state with `/coaarena debug`

Gear/talent inspection and enemy cooldown indicators remain planned work. See
the [roadmap](docs/addon-plan.md) for scope and known API constraints. The
current vertical slice passes mocked Lua 5.1 checks but still requires the
documented live validation on CoA before its first release.

## Installation

1. Download a source archive (or the latest release once one is published).
2. Copy the `CoAArena/` folder into `World of Warcraft/Interface/AddOns/`.
3. Make sure the folder is named `CoAArena` (without suffixes like `-master`).
4. Restart the game or run `/reload`.

## Development

The addon targets WoW **3.3.5 (WotLK)** and is written in pure Lua — no build
step. The addon itself lives in the `CoAArena/` folder; the repo root holds
docs and meta.

The layout is **feature-based** — grouped by domain, not by file type:

```
coa-arena-addon/                  # repo root
├── docs/                         # planning / design notes
└── CoAArena/                     # the addon — symlink THIS into AddOns/
    ├── CoAArena.toc              # manifest (interface 30300, load order)
    ├── core.lua                  # bootstrap: namespace, registry, events
    ├── shared/                   # cross-domain helpers
    ├── features/                 # one folder per domain
    │   ├── arena_log/            #   session, opponent capture, store, UI
    │   └── cooldowns/            #   tracker, icons
    └── locales/                  # en_us.lua base locale
```

The `CoAArena/` folder and `CoAArena.toc` must share that exact name (a WoW
requirement); everything else is lowercase `snake_case`. Folders are optional
to WoW (files load only via the `.toc`) — the layout is for humans.

Repository conventions are enforced by `.editorconfig`, `.luacheckrc`, and the
quality workflow.

### Quality checks

Enter the reproducible development shell, then run the checks:

```sh
nix develop
./scripts/check.sh
```

The shell provides Lua 5.1, `luac`, `luacheck`, `rg`, and Git. Their Nixpkgs
revision is pinned in `flake.lock`; nothing needs to be installed globally.

GitHub Actions runs the same syntax, static-analysis, smoke-test, and
whitespace checks. Arena behaviour still requires the
[manual CoA checklist](docs/manual-testing.md). The persisted record shape is
documented in [docs/match-schema.md](docs/match-schema.md).

### Local development

Symlink the `CoAArena/` folder into WoW's `Interface/AddOns/` directory so
changes are picked up after a `/reload`:

```sh
ln -s "$(pwd)/CoAArena" "/path/to/World of Warcraft/Interface/AddOns/CoAArena"
```

## License

[MIT](LICENSE)
