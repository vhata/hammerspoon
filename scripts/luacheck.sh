#!/usr/bin/env bash
# Static analysis of every tracked Lua file with luacheck, configured by
# .luacheckrc (Lua 5.4, Hammerspoon globals, vendored spoons excluded).
# Catches accidental globals, unused variables and shadowing that luac -p
# cannot. Fails when luacheck is missing or no Lua files are found.
set -euo pipefail
cd "$(dirname "$0")/.."

command -v luacheck >/dev/null 2>&1 || {
  echo "luacheck: luacheck not found (brew install luacheck, apt install lua-check, or luarocks install luacheck)" >&2
  exit 1
}

files=()
while IFS= read -r f; do files+=("$f"); done < <(git ls-files -- '*.lua')
[ "${#files[@]}" -gt 0 ] || { echo "luacheck: no Lua files found" >&2; exit 1; }

luacheck --config .luacheckrc --formatter plain "${files[@]}"
echo "luacheck: ${#files[@]} tracked files passed, less the exclusions in .luacheckrc ($(luacheck --version | head -n 1))"
