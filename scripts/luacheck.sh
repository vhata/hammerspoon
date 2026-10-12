#!/usr/bin/env bash
# Static analysis of every tracked Lua file with luacheck, configured by
# .luacheckrc (Lua 5.4, Hammerspoon globals, vendored spoons excluded).
# Catches accidental globals, unused variables and shadowing that luac -p
# cannot. Fails when luacheck is missing or when no Lua files are left to
# check once the exclusions apply.
set -euo pipefail
cd "$(dirname "$0")/.."

command -v luacheck >/dev/null 2>&1 || {
  echo "luacheck: luacheck not found (brew install luacheck, apt install lua-check, or luarocks install luacheck)" >&2
  exit 1
}

files=()
while IFS= read -r f; do files+=("$f"); done < <(git ls-files -- '*.lua')
[ "${#files[@]}" -gt 0 ] || { echo "luacheck: no Lua files found" >&2; exit 1; }

# -q prints only files with warnings plus the summary line, whose file count
# is what is left after exclude_files; luacheck exits 0 when that is zero.
status=0
out="$(luacheck --config .luacheckrc -q --no-color "${files[@]}")" || status=$?
printf '%s\n' "$out"
[ "$status" -eq 0 ] || exit "$status"
checked="$(printf '%s\n' "$out" | sed -n 's/^Total: .* in \([0-9][0-9]*\) files\{0,1\}$/\1/p')"
[ "${checked:-0}" -gt 0 ] || { echo "luacheck: no Lua files left to check after the exclusions in .luacheckrc" >&2; exit 1; }
echo "luacheck: $checked of ${#files[@]} tracked files checked, the rest excluded by .luacheckrc ($(luacheck --version | head -n 1))"
