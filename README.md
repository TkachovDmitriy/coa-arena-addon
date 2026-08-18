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
2. Extract the contents into `World of Warcraft/_retail_/Interface/AddOns/`.
3. Make sure the addon folder is named `CoAArena` (without suffixes like `-master`).
4. Restart the game or run `/reload`.

## Development

The addon is written in Lua using the WoW API.

```
CoAArena/
├── CoAArena.toc      # addon manifest
├── Core.lua          # entry point / initialization
└── modules/          # individual modules
```

### Local development

Symlink the repository directory into WoW's `AddOns` folder so changes are
picked up after a `/reload`.

## License

See [LICENSE](LICENSE) (to be added).
