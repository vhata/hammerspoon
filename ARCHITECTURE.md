# Architecture

What the configuration is now and the invariants reviews check.

## Layout

- `init.lua`: entry point. Loads the spoons and modules, binds the leader keys, starts the reload watcher.
- `hyper.lua`: Cmd+Alt+Ctrl+<key> launches or focuses an app, then runs the external `embiggen` command on it.
- `leader.lua`: double-tap right Ctrl or right Shift opens a one-second modal; `leader.bind(key, fn)` registers actions. This is the shared interface the other modules hang off.
- `cheatsheet.lua`: renders `~/.config/nvim/CHEATSHEET.md` in a webview overlay using the vendored `marked.min.js`.
- `expanse.lua`: Cmd+Alt+E chooser over the external `~/bin/expanse` text-expansion tool; the chosen expansion goes to the clipboard.
- `spotify.lua`: F14 or keypad `/` shows a now-playing notification with album art.
- `Spoons/FloatCalendar.spoon`: the user's own month calendar overlay.
- `Spoons/AClock.spoon`, `Spoons/Calendar.spoon`, `Spoons/Emojis.spoon`, `Spoons/ReloadConfiguration.spoon`: vendored upstream spoons. `Calendar` is present but not loaded.

## Shared interfaces

- `leader.bind(key, fn)` and the leader trigger keys (right Ctrl keycode 62, right Shift keycode 60).
- External commands the config shells out to: `embiggen` (on the login-shell `PATH`), `~/bin/expanse` (`dump` and `get -- <short>`). Neither lives in this repository.
- `~/.config/nvim/CHEATSHEET.md`, owned by the user's Neovim config.

## Invariants

- Module state lives in `local`s. Accidental globals leak across reloads and between modules.
- Anything that must keep running (event taps, watchers, timers, modals) is held by a reference that outlives the function that created it, or Lua's garbage collector stops it.
- Callbacks run on Hammerspoon's main thread. A blocking call (`hs.execute`, synchronous URL fetch, slow AppleScript) freezes every hotkey until it returns.
- Event taps that return `true` swallow the event system-wide; they must be narrow and removed when their overlay closes.

## Isolation for concurrent work

The main checkout is the live config and must stay on `main`. Worktrees live outside `~/.hammerspoon` so that file edits in them do not trigger `ReloadConfiguration`; git operations in a worktree still write under `~/.hammerspoon/.git` and do trigger a reload. There is no other per-worktree state.

## Where to look first

`init.lua`, then `leader.lua`.
