#!/usr/bin/env bash
set -euo pipefail

lua_compiler="${LUA_COMPILER:-luac5.1}"
if ! command -v "$lua_compiler" >/dev/null 2>&1; then
   lua_compiler="luac"
fi

lua_runtime="${LUA_RUNTIME:-lua5.1}"
if ! command -v "$lua_runtime" >/dev/null 2>&1; then
   lua_runtime="lua"
fi

while IFS= read -r lua_file; do
   "$lua_compiler" -p "$lua_file"
done < <(rg --files TDArenaLens -g '*.lua')

luacheck TDArenaLens tests
"$lua_runtime" tests/arena_log_smoke.lua

empty_tree="$(git hash-object -t tree /dev/null)"
git diff --check "$empty_tree" HEAD
git diff --check
