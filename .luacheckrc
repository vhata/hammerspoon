-- luacheck configuration, run by scripts/luacheck.sh. See docs/QUALITY.md.

-- Hammerspoon embeds Lua 5.4.
std = "lua54"

-- Globals Hammerspoon injects: the hs.* API and the table of loaded spoons.
-- Read-only: assigning either, or one of their fields (hs.foo = ...,
-- spoon.X = ...), is a warning. If the config ever needs to set a field,
-- declare that field writable here.
read_globals = { "hs", "spoon" }

-- No line-length convention here; the long lines are mostly inline
-- HTML and CSS.
max_line_length = false

-- Vendored upstream spoons are not linted. AClock defines the global
-- getframe; Emojis adds table.save and table.load to the shared table
-- library, which first-party code must not rely on (luacheck flags them
-- if it does).
exclude_files = { "Spoons/AClock.spoon/", "Spoons/Emojis.spoon/" }

-- The fallback reload watcher is a global on purpose: a local would be
-- garbage-collected, stopping it, once init.lua finishes. See
-- docs/DECISIONS.md, 2026-10-09.
files["init.lua"] = { globals = { "reloadFallbackWatcher" } }
