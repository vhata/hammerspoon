# Deferred work

Ordinary follow-ups and bugs found during other work live here. Whole-codebase review findings promoted for separate work live in [review/BACKLOG.md](review/BACKLOG.md). Follow [docs/TODO_GUIDE.md](docs/TODO_GUIDE.md) before adding, claiming, moving or resolving an entry. Entries in **Ready for separate work** are unblocked and available now; anything with an unresolved `Depends on:` belongs in an earlier stage.

## Needs triage

### P0 Critical

### P1 High

### P2 Normal

### P3 Low

### Unprioritized

- [SPOONS] `aclock-reinit-watcher-leak` — **Stop AClock starting another screen watcher each time a setting changes after load.** The vendored spoon re-runs `init()` on every setting assignment, and each run starts a new `hs.screen.watcher` and drops the old reference; nothing in this config sets AClock options after loading today, so it only matters if `init.lua` starts customising the clock.
  - Source: writing `remove-dead-code`, 2026-10-10
  - Starting point: `Spoons/AClock.spoon/init.lua` lines 22-27 and the watcher setup in `obj:init()`; vendored, so either a local patch recorded in `docs/DECISIONS.md` or set options before `hs.loadSpoon` returns.
- [SPOONS] `floatcalendar-take-focus` — **Decide whether the open FloatCalendar should take keyboard focus.** Since `floatcalendar-global-hotkeys` it takes its keys through an event tap and closes on any other key or click; a focused window would instead keep keys out of other apps without closing, and would keep working under secure input, which taps cannot see through.
  - Source: independent review of the `floatcalendar-global-hotkeys` PR, 2026-10-09
  - Starting point: `hs.canvas` cannot take focus, so this means rebuilding the calendar as an `hs.webview` (or an `hs.webview` host for the canvas); weigh that against the current tap.
- [MODULES] `expanse-multiline-dump` — **Parse `expanse dump` output correctly when an expansion spans several lines.** The `gmatch` in `expanse.lua:35` assumes each expansion is exactly one line, so a multi-line snippet desynchronises every short/expansion pair after it.
  - `dump` in `~/src/expanse/expanse/cli.py:123` already replaces newlines in expansions with `↵`, so multi-line expansions may parse fine today; a short name containing a newline would still desynchronise. Confirm before fixing (independent review of PR #5, 2026-10-08).
  - Source: config review in a Claude Code session, 2026-10-07
  - Starting point: check what `~/bin/expanse dump` emits for a multi-line expansion; the fix depends on whether the format is delimited at all, which may need a change to `expanse` itself.
- [TOOLING] `adopt-luacheck` — **Add luacheck to the lint gate with a `.luacheckrc` that knows the `hs` and `spoon` globals.** `luac -p` only proves files parse; luacheck would catch accidental globals and unused locals, both of which have already been fixed by hand in this repository's history.
  - Source: config review in a Claude Code session, 2026-10-07
  - Starting point: decide whether vendored spoons are excluded (AClock defines a global `getframe`), then clear the remaining warnings or record them as baseline; install via `luarocks` or apt `lua-check` in CI.
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
