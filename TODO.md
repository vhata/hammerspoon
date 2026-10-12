# Deferred work

Ordinary follow-ups and bugs found during other work live here. Whole-codebase review findings promoted for separate work live in [review/BACKLOG.md](review/BACKLOG.md). Follow [docket/TODO_GUIDE.md](docket/TODO_GUIDE.md) before adding, claiming, moving or resolving an entry. Entries in **Ready for separate work** are unblocked and available now; anything with an unresolved `Depends on:` belongs in an earlier stage.

## Needs triage

### P0 Critical

### P1 High

### P2 Normal

### P3 Low

### Unprioritized

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

- [TOOLING] `adopt-luacheck` — **Add luacheck to the lint gate with a `.luacheckrc` that knows the `hs` and `spoon` globals.** `luac -p` only proves files parse; luacheck would catch accidental globals and unused locals, both of which have already been fixed by hand in this repository's history.
  - Source: config review in a Claude Code session, 2026-10-07
  - Decided in triage, 2026-10-12: exclude the vendored `Spoons/AClock.spoon` and `Spoons/Emojis.spoon` (AClock defines a global `getframe`).
  - Starting point: clear the remaining warnings or record them as baseline; install via `luarocks` or apt `lua-check` in CI.

### P3 Low

- [MODULES] `spotify-artwork-timeout` — **Send the now-playing notification without art if the artwork fetch is slow.** Since the fetch became asynchronous, the notification waits for it, which on a slow or dead link can be as long as the system URL timeout.
  - Source: fixing `spotify-async-artwork`, PR #4, 2026-10-08
  - Decided in triage, 2026-10-12: a late image does not replace or resend the notification.
  - Starting point: an `hs.timer.doAfter` of a few seconds that sends without art, with the image callback sending only if the timer has not fired.

### Unprioritized
