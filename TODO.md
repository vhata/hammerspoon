# Deferred work

Ordinary follow-ups and bugs found during other work live here. Whole-codebase review findings promoted for separate work live in [review/BACKLOG.md](review/BACKLOG.md). Follow [docs/TODO_GUIDE.md](docs/TODO_GUIDE.md) before adding, claiming, moving or resolving an entry. Entries in **Ready for separate work** are unblocked and available now; anything with an unresolved `Depends on:` belongs in an earlier stage.

## Needs triage

### P0 Critical

### P1 High

### P2 Normal

### P3 Low

### Unprioritized

- [MODULES] `expanse-multiline-dump` — **Parse `expanse dump` output correctly when an expansion spans several lines.** The `gmatch` in `expanse.lua:23` assumes each expansion is exactly one line, so a multi-line snippet desynchronises every short/expansion pair after it.
  - Source: config review in a Claude Code session, 2026-10-07
  - Starting point: check what `~/bin/expanse dump` emits for a multi-line expansion; the fix depends on whether the format is delimited at all, which may need a change to `expanse` itself.
  - Related: `expanse-shell-quoting`
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

- [SPOONS] `floatcalendar-sunday-start` — **Show the 1st of the month when it falls on a Sunday.** The grid header is Monday-first but `Spoons/FloatCalendar.spoon/init.lua:73` offsets by Lua's Sunday-first `wday`, so Feb, Mar and Nov 2026 all start their first row on the 2nd and drop the 1st.
  - Source: config review in a Claude Code session, 2026-10-07
  - Starting point: let `mwday = (wday + 5) % 7 + 1` (Monday 1, Sunday 7) and compute `caltable_idx - mwday + 1`; the existing `+ 2` constant must become `+ 1` or every month shifts. The same offset positions the today highlight. Six rows are then enough (a 31-day month starting Sunday ends at cell 37).
  - Related: `floatcalendar-iso-weeks`
- [CONFIG] `leader-false-trigger-while-typing` — **Stop the leader modal firing when right Shift is used twice in quick succession while typing.** The event tap in `leader.lua:39` only sees `flagsChanged`, so Shift+I, release, Shift+A within half a second counts as a double-tap.
  - Source: config review in a Claude Code session, 2026-10-07
  - Starting point: add `keyDown` to the tap's event types and reset `lastKey`/`lastRelease` on it without swallowing the event.
- [SPOONS] `floatcalendar-iso-weeks` — **Show ISO 8601 week numbers in FloatCalendar without shelling out.** `%W` gives week 00 for 1 Jan 2026 where ISO `%V` gives 01, so numbers are off by one in years starting Tuesday to Thursday, and `init.lua:96` runs `date` through `hs.execute` on every redraw.
  - Source: config review in a Claude Code session, 2026-10-07
  - Starting point: compute each row's week from the Monday that starts it with `os.date("%V", ...)`; rows can cross a year boundary, so do not just add the row index.
  - Related: `floatcalendar-sunday-start`
- [MODULES] `expanse-shell-quoting` — **Quote the abbreviation passed to `~/bin/expanse get`.** `expanse.lua:16` concatenates `choice.text` into a shell command unquoted, so a short name with a space, quote or `$` breaks or misbehaves.
  - Source: config review in a Claude Code session, 2026-10-07
  - Starting point: single-quote each argument in `call_expanse` (escaping embedded single quotes), or switch to `hs.task` with an argument list.
  - Related: `expanse-multiline-dump`
- [MODULES] `overlays-multi-display` — **Centre the cheatsheet and FloatCalendar on the screen they open on.** Both compute position from the screen frame's width and height but ignore its `x` and `y`, so on a second display they open on the wrong screen; FloatCalendar also fixes its position once at load time.
  - Source: config review in a Claude Code session, 2026-10-07
  - Starting point: `cheatsheet.lua:44` and `Spoons/FloatCalendar.spoon/init.lua:109`; recompute the frame from `hs.screen.mainScreen():frame()` on each show.
- [CONFIG] `hyper-embiggen-blocking` — **Run `embiggen` without blocking Hammerspoon.** `hyper.lua:16` runs it through a login shell with `hs.execute(..., true)`, which blocks every hotkey while the shell profile loads and may run before the app's window exists.
  - Source: config review in a Claude Code session, 2026-10-07
  - Starting point: `hs.task` with the resolved path to `embiggen`; consider a short delay or an application watcher for apps that are still launching.
- [MODULES] `cheatsheet-json-encode` — **Escape the cheatsheet markdown with `hs.json.encode`.** `cheatsheet.lua:41` hand-escapes into a JS string literal inside a `<script>` block, so a `</script>` in the markdown ends the script early and breaks the page.
  - Source: config review in a Claude Code session, 2026-10-07
  - Starting point: `hs.json.encode` takes a table, so encode `{md}` and read element `[0]` in the page; confirm the encoded output escapes `/` so `</script>` cannot appear literally.
- [MODULES] `spotify-async-artwork` — **Fetch Spotify album art without blocking.** `hs.image.imageFromURL` in `spotify.lua:19` is a synchronous network fetch, so a slow connection briefly freezes Hammerspoon.
  - Source: config review in a Claude Code session, 2026-10-07
  - Starting point: `hs.image.imageFromURL(url, callbackFn)` is asynchronous when given a callback; send the notification from the callback, or without an image when the URL is nil.
- [CONFIG] `remove-dead-code` — **Remove unused code and variables.** `spoon.AClock:init()` in `init.lua:11` repeats what `hs.loadSpoon` already does; the `expanse`, `spotify` and `hyper` locals in `init.lua` are never read; `j, st, t, rc` in `hyper.lua:16`, `notification` in `spotify.lua:42` and `logger` in FloatCalendar are unused; `Spoons/Calendar.spoon` is tracked but never loaded.
  - Source: config review in a Claude Code session, 2026-10-07
  - Related: `adopt-luacheck`
- [SPOONS] `floatcalendar-global-hotkeys` — **Stop the open FloatCalendar from swallowing R, the arrow keys and Escape in other apps.** `Spoons/FloatCalendar.spoon/init.lua:263-275` binds them as global hotkeys while the calendar is shown, so typing `r` anywhere resets the calendar instead of reaching the focused app.
  - Source: independent review of PR #1, 2026-10-07
  - Starting point: an `hs.hotkey.modal` entered on show, or hide the calendar on any unbound key; decide whether the calendar should take focus.
- [CONFIG] `reload-watcher-filter` — **Reload only when config files change, not on writes under `.git/` or worktree directories.** `ReloadConfiguration` reloads on any change under `~/.hammerspoon`, including every git operation, which is why worktrees have to live outside the repository.
  - Source: independent review of PR #1, 2026-10-07
  - Starting point: the pathwatcher callback receives the changed paths; filter to `.lua` files outside `.git/`, either in `init.lua` via `watch_paths` replacement or a small wrapper instead of the vendored spoon.
- [TOOLING] `gitignore-macos` — **Replace the generic C `.gitignore` with one for this repository.** The current file lists compiled-object patterns that never occur here and misses `.DS_Store`.
  - Source: config review in a Claude Code session, 2026-10-07
