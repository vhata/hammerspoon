#!/usr/bin/env bash
# Syntax-check every tracked Lua file with luac -p. Prefers Lua 5.4, the
# version Hammerspoon embeds. Fails when no Lua files are found.
set -euo pipefail
cd "$(dirname "$0")/.."

luac=""
for candidate in luac5.4 luac-5.4 luac; do
  if command -v "$candidate" >/dev/null 2>&1; then luac="$candidate"; break; fi
done
[ -n "$luac" ] || { echo "lint: no luac found (install Lua 5.4)" >&2; exit 1; }

files=()
while IFS= read -r f; do files+=("$f"); done < <(git ls-files -- '*.lua')
[ "${#files[@]}" -gt 0 ] || { echo "lint: no Lua files found" >&2; exit 1; }

"$luac" -p "${files[@]}"
echo "lint: ${#files[@]} files parsed with $("$luac" -v 2>&1 | awk '{print $1, $2}')"
