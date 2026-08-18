# Lua / WoW addon rules

Target client is **WoW 3.3.5 (WotLK)**, interface version `30300`. Only use
APIs available in that client — no retail-only functions.

Formatting/naming conventions are in `lua-style.md` (3-space indent,
`snake_case` files, etc.). This file covers addon runtime/structure.

## Structure

- The addon lives in the `CoAArena/` folder (symlinked into `AddOns/`). The
  repo root holds docs and meta only.
- The addon folder and its `.toc` **must** share the exact addon name
  (`CoAArena/CoAArena.toc`) — a WoW requirement. Everything else is
  `snake_case` (`core.lua`, `features/arena_log/store.lua`).
- **Feature-based (DDD-lite) layout.** Group by *domain*, not by file type —
  everything for one feature (logic, its UI, its persistence) lives together:
  ```
  CoAArena/
     core.lua                 # bootstrap + module registry (thin)
     shared/                  # cross-domain, domain-agnostic helpers
     features/<domain>/       # one folder per feature
     locales/                 # en_us.lua base locale (cross-domain)
  ```
  Current domains: `arena_log` (session detection, opponent capture, store,
  history UI) and `cooldowns`. Add a new feature = a new `features/<domain>/`
  folder; don't reach for technical sub-layers (`api`/`application`/…) — Lua
  3.3.5 has no module system to make them meaningful.
- **Folders are still optional to WoW** — files are found only via the `.toc`.
  The layout is for humans; a tiny addon could be flat.
- **Explicit load order in `CoAArena.toc`** — locales → `core.lua` → `shared/`
  → feature domains. Within a domain, load the data/`store` before the modules
  that use it. There is no autoloader; every new file must be added to the
  `.toc`.
- **Cross-file wiring:** data/helpers hang off `ns` (`ns.util`,
  `ns.arena_log.store`); event-reactive things are modules
  (`CoAArena:NewModule`) and find siblings at runtime via
  `CoAArena:GetModule(name)`.

## Code conventions

- **Private namespace, not globals.** Start every file with
  `local ADDON_NAME, ns = ...` and hang state off `ns`. The only intentional
  global is `_G.CoAArena`.
- **One event frame.** `Core.lua` owns the single `CreateFrame("Frame")` and
  dispatches events. Modules never create their own event frames — call
  `CoAArena:NewModule(name)`, add an optional `OnEnable`, and define
  event-named methods (e.g. `PLAYER_ENTERING_WORLD`) the core routes to.
- **Localized strings** go through `ns.L` (base locale `Locales/enUS.lua`);
  don't hardcode user-facing English elsewhere.

## SavedVariables

- `CoAArenaDB` (account) and `CoAArenaCharDB` (per character — arena
  rating/history is per character).
- Only populated after `ADDON_LOADED`; never read them before that.
- Version any schema so future updates can migrate old saved data instead of
  breaking on it.

## Testing

Manual: symlink `CoAArena/` into `Interface/AddOns/`, log in, queue an arena,
verify capture. No Lua unit-test tooling. Run `luacheck` if installed
(`.luacheckcache` is gitignored).
