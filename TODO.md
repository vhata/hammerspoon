# Deferred work

Ordinary follow-ups and bugs found during other work live here. Whole-codebase review findings promoted for separate work live in [review/BACKLOG.md](review/BACKLOG.md). Follow [docs/TODO_GUIDE.md](docs/TODO_GUIDE.md) before adding, claiming, moving or resolving an entry. Entries in **Ready for separate work** are unblocked and available now; anything with an unresolved `Depends on:` belongs in an earlier stage.

## Needs triage

### P0 Critical

### P1 High

### P2 Normal

### P3 Low

### Unprioritized

- [MODULES] `expanse-multiline-dump` — **Parse `expanse dump` output correctly when an expansion spans several lines.** The `gmatch` in `expanse.lua:35` assumes each expansion is exactly one line, so a multi-line snippet desynchronises every short/expansion pair after it.
  - Source: config review in a Claude Code session, 2026-10-07
  - Starting point: check what `~/bin/expanse dump` emits for a multi-line expansion; the fix depends on whether the format is delimited at all, which may need a change to `expanse` itself.
- [TOOLING] `adopt-luacheck` — **Add luacheck to the lint gate with a `.luacheckrc` that knows the `hs` and `spoon` globals.** `luac -p` only proves files parse; luacheck would catch accidental globals and unused locals, both of which have already been fixed by hand in this repository's history.
  - Source: config review in a Claude Code session, 2026-10-07
  - Starting point: decide whether vendored spoons are excluded (AClock defines a global `getframe`), then clear the remaining warnings or record them as baseline; install via `luarocks` or apt `lua-check` in CI.
  - Related: `remove-dead-code`

## Needs proof of concept

### P0 Critical

### P1 High

### P2 Normal

### P3 Low

### Unprioritized

## Ready for separate work

### P0 Critical

### P1 High

### P2 Normal

### P3 Low

### Unprioritized

- [CONFIG] `hyper-embiggen-blocking` — **Run `embiggen` without blocking Hammerspoon.** `hyper.lua:16` runs it through a login shell with `hs.execute(..., true)`, which blocks every hotkey while the shell profile loads and may run before the app's window exists.
  - Source: config review in a Claude Code session, 2026-10-07
  - Starting point: `hs.task` with the resolved path to `embiggen`; consider a short delay or an application watcher for apps that are still launching.
- [CONFIG] `remove-dead-code` — **Remove unused code and variables.** `spoon.AClock:init()` in `init.lua:11` repeats what `hs.loadSpoon` already does; the `expanse`, `spotify` and `hyper` locals in `init.lua` are never read; `j, st, t, rc` in `hyper.lua:16` and `logger` in FloatCalendar are unused; `Spoons/Calendar.spoon` is tracked but never loaded.
  - Source: config review in a Claude Code session, 2026-10-07
  - Related: `adopt-luacheck`
- [SPOONS] `floatcalendar-global-hotkeys` — **Stop the open FloatCalendar from swallowing R, the arrow keys and Escape in other apps.** `obj:show()` in `Spoons/FloatCalendar.spoon/init.lua` binds them as global hotkeys while the calendar is shown, so typing `r` anywhere resets the calendar instead of reaching the focused app.
  - Source: independent review of PR #1, 2026-10-07
  - Starting point: an `hs.hotkey.modal` entered on show, or hide the calendar on any unbound key; decide whether the calendar should take focus.
- [CONFIG] `reload-watcher-filter` — **Reload only when config files change, not on writes under `.git/` or worktree directories.** `ReloadConfiguration` reloads on any change under `~/.hammerspoon`, including every git operation, which is why worktrees have to live outside the repository.
  - Source: independent review of PR #1, 2026-10-07
  - Starting point: the pathwatcher callback receives the changed paths; filter to `.lua` files outside `.git/`, either in `init.lua` via `watch_paths` replacement or a small wrapper instead of the vendored spoon.
- [TOOLING] `gitignore-macos` — **Replace the generic C `.gitignore` with one for this repository.** The current file lists compiled-object patterns that never occur here and misses `.DS_Store`.
  - Source: config review in a Claude Code session, 2026-10-07
