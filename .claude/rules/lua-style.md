# Lua style

Based on the [LuaRocks style guide](https://github.com/luarocks/lua-style-guide),
adapted for a WoW 3.3.5 addon. See also `lua-addon.md` for structure/runtime
rules. Where this repo deliberately deviates from LuaRocks, it's called out
under **WoW deviations** below.

## Formatting

- **Indent with 3 spaces.** Never tabs; never mix tabs and spaces.
- **LF (Unix) line endings.**
- One statement per line. **No semicolons** as statement terminators.
- No hard line-length limit — but if an expression gets too long/complex, split
  it into named subexpressions instead of wrapping a mind-bending statement.
- Blank line between top-level functions.
- Indent tables/callbacks relative to the **start of the line**, not the
  construct:
  ```lua
  local my_table = {
     "hello",
     "world",
  }
  using_a_callback(x, function(...)
     print("hello")
  end)
  ```

## Spacing

- Space after `--` in comments.
- Spaces around operators and `=`, after commas: `local numbers = {1, 2, 3}`.
- No space after a function name in a declaration/call: `hello(name)`, not
  `hello ( name )`.
- The concatenation operator `..` gets a pass — spaces optional.
- Don't align consecutive assignments (adds git-blame noise); align only when
  it highlights genuine logical correspondence (e.g. a table of parallel calls).

## Naming

- `snake_case` for variables and functions.
- `UPPER_CASE` only for constants, and sparingly (Lua has no real constants).
  Never uppercase names starting with `_` (reserved).
- `i` only as a numeric/`ipairs` counter; `_` for ignored values; prefer
  descriptive names over `k`/`v` unless writing a generic table helper.
- Larger scope ⇒ more descriptive name.
- Prefer `is_` for boolean functions: `is_evil(x)`, not `evil(x)`.

## Files & folders

- Lua **file and folder names are `snake_case`, all lowercase**:
  `core.lua`, `modules/arena_session.lua`, `locales/en_us.lua`.
- **Exception:** the addon folder and its `.toc` must share the exact addon
  name — `CoAArena/CoAArena.toc` (a WoW client requirement, not a style
  choice).
- **Subfolders are optional.** WoW imposes no directory layout; every file is
  found only because it's listed in the `.toc`. The layout is
  **feature-based** (`features/<domain>/`, plus `shared/` and `locales/`) —
  group by domain, not file type. See `lua-addon.md` for the structure.

## Strings, tables, values

- `"double quotes"` by default; `'single'` only to embed a double quote.
- Populate table fields all at once when possible; use **trailing commas**.
- Plain-key syntax where possible; `["key"]` only for non-identifier keys, and
  don't mix the two styles in one declaration.
- Dot notation for known fields (`luke.jedi`); `[]` for variable keys or
  list-style access.
- `false`/`nil` are falsy — use shortcuts (`if name then`), unless you must
  distinguish `false` from `nil`. Don't design APIs that depend on that
  difference.
- `and`/`or` for the ternary idiom, with parens when nesting; never use
  `x and y or z` when `y` may be `false`/`nil`.
- Use `tostring`/`tonumber` for conversions; don't rely on coercion
  (`x .. ""`).

## Functions

- Prefer `local function foo()` over `local foo = function()` for named
  functions (distinguishes named from anonymous).
- Validate early, return early.
- Assign variables at the **smallest scope** that works.
- Don't omit parentheses: not for a single string-literal arg
  (`get_data("KRP")`), nor for a single-line table arg. Parens **may** be
  omitted only for a multi-line table arg used alone in a statement
  (`Foo.new { ... }`).
- Single-line blocks only for `then return`, `then break`, and lambda
  `function ... return ... end`. Otherwise break onto multiple lines.
- Type-check assertions on arguments are welcome in non-hot code:
  `assert(type(x) == "string")`.

## Errors

- Expected failures (I/O, etc.) → return `nil, "message"` (optionally an error
  code). Callers check the first return.
- API misuse / programmer errors → `error()` or `assert()` (throw).

## WoW deviations from LuaRocks

These override the LuaRocks guide because this is a WoW 3.3.5 addon, not a
LuaRocks module:

- **No `require` / `src` / `spec` / Busted.** Files share a private namespace
  via the `...` vararg and load in the order listed in `CoAArena.toc`
  (see `lua-addon.md`). There is no module `require` graph and no unit-test
  runner.
- **PascalCase methods.** Public methods on the addon and module tables use
  PascalCase (`:RegisterEvent`, `:NewModule`, `:OnEnable`) to match the
  Blizzard/Ace3 API idiom every WoW dev expects — not LuaRocks' snake_case
  methods. Plain (non-method) locals and functions still use `snake_case`.
- **Globals.** LuaRocks forbids module globals; addons need exactly one
  (`_G.CoAArena`) plus the client-managed `SavedVariables` globals. Everything
  else stays local / on `ns`.

## Static checking

- Code should pass `luacheck` (`.luacheckcache` is gitignored). Ship a
  `.luacheckrc` with sensible exceptions rather than contorting code.
- Ignore 6xx (whitespace) warnings; don't send "fix trailing whitespace" diffs.
- Ignore 211/212/213 (unused var/arg/loop) when the name is spelled out
  deliberately (e.g. an API-mandated callback signature) — prefer a named
  argument over `_`.

## TODO / FIXME

- `TODO:` a missing feature to add later; `FIXME:` a problem in existing code.
- Prefer a good function name + a doc comment on *what* it does over inline
  comments on *how*; if it needs many how-comments, split it up.
