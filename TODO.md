# Deferred work

Ordinary follow-ups and bugs found during other work live here. Whole-codebase review findings promoted for separate work live in [review/BACKLOG.md](review/BACKLOG.md). Follow [docs/TODO_GUIDE.md](docs/TODO_GUIDE.md) before adding, claiming, moving or resolving an entry. Entries in **Ready for separate work** are unblocked and available now; anything with an unresolved `Depends on:` belongs in an earlier stage.

## Needs triage

### P0 Critical

### P1 High

### P2 Normal

### P3 Low

### Unprioritized

- [MODULES] `expanse-multiline-dump` — **Parse `expanse dump` output correctly when an expansion spans several lines.** The `gmatch` in `expanse.lua:35` assumes each expansion is exactly one line, so a multi-line snippet desynchronises every short/expansion pair after it.
  - `dump` in `~/src/expanse/expanse/cli.py:123` already replaces newlines in expansions with `↵`, so multi-line expansions may parse fine today; a short name containing a newline would still desynchronise. Confirm before fixing (independent review of PR #5, 2026-10-08).
  - Source: config review in a Claude Code session, 2026-10-07
  - Starting point: check what `~/bin/expanse dump` emits for a multi-line expansion; the fix depends on whether the format is delimited at all, which may need a change to `expanse` itself.
- [TOOLING] `adopt-luacheck` — **Add luacheck to the lint gate with a `.luacheckrc` that knows the `hs` and `spoon` globals.** `luac -p` only proves files parse; luacheck would catch accidental globals and unused locals, both of which have already been fixed by hand in this repository's history.
  - Source: config review in a Claude Code session, 2026-10-07
  - Starting point: decide whether vendored spoons are excluded (AClock defines a global `getframe`), then clear the remaining warnings or record them as baseline; install via `luarocks` or apt `lua-check` in CI.
  - Related: `remove-dead-code`
- [MODULES] `spotify-artwork-timeout` — **Send the now-playing notification without art if the artwork fetch is slow.** Since the fetch became asynchronous, the notification waits for it, which on a slow or dead link can be as long as the system URL timeout.
  - Source: fixing `spotify-async-artwork`, PR #4, 2026-10-08
  - Starting point: an `hs.timer.doAfter` of a few seconds that sends without art, with the image callback sending only if the timer has not fired; decide whether a late image should replace the notification.

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

- [CONFIG] `remove-dead-code` — **Remove unused code and variables.** `spoon.AClock:init()` in `init.lua:10` repeats what `hs.loadSpoon` already does; the `expanse` and `spotify` locals in `init.lua` are never read; `logger` in FloatCalendar is unused; `Spoons/Calendar.spoon` is tracked but never loaded.
  - Source: config review in a Claude Code session, 2026-10-07
  - Related: `adopt-luacheck`
- [SPOONS] `floatcalendar-global-hotkeys` — **Stop the open FloatCalendar from swallowing R, the arrow keys and Escape in other apps.** `obj:show()` in `Spoons/FloatCalendar.spoon/init.lua` binds them as global hotkeys while the calendar is shown, so typing `r` anywhere resets the calendar instead of reaching the focused app.
  - Source: independent review of PR #1, 2026-10-07
  - Starting point: an `hs.hotkey.modal` entered on show, or hide the calendar on any unbound key; decide whether the calendar should take focus.
- [CONFIG] `reload-watcher-filter` — **Reload only when config files change, not on writes under `.git/` or worktree directories.** `ReloadConfiguration` reloads on any change under `~/.hammerspoon`, including every git operation, which is why worktrees have to live outside the repository.
  - Source: independent review of PR #1, 2026-10-07
  - Starting point: the pathwatcher callback receives the changed paths; filter to `.lua` files outside `.git/`, either in `init.lua` via `watch_paths` replacement or a small wrapper instead of the vendored spoon.
  - Related: `reload-mid-checkout`
- [CONFIG] `reload-mid-checkout` — **Survive a `git pull` that renames or deletes a module, instead of leaving Hammerspoon on a dead config until a manual reload.** `ReloadConfiguration` calls `hs.reload` on the first file event, so a pull can be loaded half-applied; the failed load then stops before `spoon.ReloadConfiguration:start()` at the bottom of `init.lua`, so nothing reloads once the checkout finishes.
  - Seen pulling `763544a` (#13) into `~/.hammerspoon` at 17:38:33: the reload a second later ran the old `init.lua` against a tree where `hyper.lua` was already deleted and failed with `module 'hyper' not found` at `init.lua:7`.
  - Source: debugging a live reload failure in a Claude Code session, 2026-10-08
  - Starting point: debounce the reload (an `hs.timer.delayed` of about a second, restarted on each event) and start the watcher before any `require` in `init.lua`, so a failed load still reloads on the next change. The spoon is vendored, so do it in `init.lua` or a small wrapper; this likely shares the wrapper with `reload-watcher-filter`.
  - Related: `reload-watcher-filter`
- [SPOONS] `floatcalendar-title-offset` — **Position the FloatCalendar title using the canvas height.** The title's `frame.y` in `obj:init()` divides by `self.calw` where `self.calh` is meant, so the title sits about 3 px off.
  - Source: fixing `floatcalendar-seventh-row`, PR #7, 2026-10-08
- [SPOONS] `floatcalendar-midnight-refresh` — **Move the today highlight when the date changes while the calendar is open.** `updateCalCanvas` reads the date only on redraw, so a calendar left open past midnight highlights yesterday until the user navigates or presses R.
  - Source: fixing `floatcalendar-seventh-row`, PR #7, 2026-10-08
  - Starting point: a timer started in `show()` and stopped in `hide()` that redraws at the next midnight. `self.year` and `self.month` are reset to today only in `init()` and `resetDate()`, so a redraw across a month boundary keeps showing the old month; reset them unless the user has navigated away.
  - The same staleness affects a calendar closed and reopened after the month changes: `show()` does not reset the viewed month, so it reopens on the month that was current at load time.
