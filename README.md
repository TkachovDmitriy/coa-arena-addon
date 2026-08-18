# CoA Arena Addon

A World of Warcraft companion addon that improves the arena (PvP) experience:
tracks opponents, cooldowns, and other useful in-combat information.

## Features

- Opponent tracking in arena matches
- Cooldown indicators for key abilities
- Configurable interface

> Feature set is refined as development progresses.
> Detailed roadmap: [docs/addon-plan.md](docs/addon-plan.md).

## Installation

1. Download the latest release.
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

Conventions and git-flow notes live in [CLAUDE.md](CLAUDE.md).

### Local development

Symlink the `CoAArena/` folder into WoW's `Interface/AddOns/` directory so
changes are picked up after a `/reload`:

```sh
ln -s "$(pwd)/CoAArena" "/path/to/World of Warcraft/Interface/AddOns/CoAArena"
```

## License

See [LICENSE](LICENSE) (to be added).
