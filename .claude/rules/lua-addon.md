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
  `snake_case` (`core.lua`, `modules/arena_session.lua`).
- **Subfolders are optional** — WoW imposes no layout; files are found only via
  the `.toc`. Keep a small addon flat if you like; group into
  `modules/`/`locales/`/`ui/`/`media/` as it grows.
- **Explicit load order in `CoAArena.toc`** — locales → `core.lua` → modules.
  There is no autoloader; every new file must be added to the `.toc`.

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
