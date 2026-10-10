# Architecture

What the configuration is now and the invariants reviews check.

## Layout

- `init.lua`: entry point. Starts the reload watcher, then loads the spoons and modules and declares the leader tree.
- `reload.lua`: watches `~/.hammerspoon` and reloads one second after the last change to a `.lua` or `.json` file, ignoring hidden directories (`.git`, `.worktrees`) and nested checkouts.
- `leader.lua`: double-tap right Ctrl or right Shift opens the leader. `leader.setup(tree)` takes the whole key tree as one table of actions and nested groups, builds one `hs.hotkey.modal` per group, and gives each layer one second to receive a key. This is the shared interface the other modules hang off.
- `leaderhelp.lua`: the overlay behind `?` in any leader layer. It renders the items `leader.setup` actually bound, so the help cannot drift from the keys.
- `overlay.lua`: a centred borderless webview that Escape dismisses; `overlay.new()` returns one with its own `toggle(build)`.
- `cheatsheet.lua`: renders `~/.config/nvim/CHEATSHEET.md` in an `overlay.lua` webview using the vendored `marked.min.js`.
- `expanse.lua`: Cmd+Alt+E chooser over the external `~/bin/expanse` text-expansion tool; the chosen expansion goes to the clipboard.
- `spotify.lua`: F14 or keypad `/` shows a now-playing notification with album art.
- `Spoons/FloatCalendar.spoon`: the user's own month calendar overlay.
- `Spoons/AClock.spoon`, `Spoons/Emojis.spoon`: vendored upstream spoons. `Emojis` carries a local patch that removes its window filter (see `docs/DECISIONS.md`).

## Shared interfaces

- `leader.setup(tree)` and its item format (`key`, `label`, and `fn` or `items`), and the leader trigger keys (right Ctrl keycode 62, right Shift keycode 60).
- External command the config shells out to: `~/bin/expanse` (`dump` and `get -- <short>`). It lives outside this repository.
- `~/.config/nvim/CHEATSHEET.md`, owned by the user's Neovim config.

## Invariants

- Module state lives in `local`s. Accidental globals leak across reloads and between modules.
- Anything that must keep running or stay usable (event taps, watchers, timers, modals, choosers, canvases, webviews) is held by a reference that outlives the function that created it, or Lua's garbage collector stops it.
- `init.lua` starts `reload.lua` before any other load, so a load that fails part-way still reloads on the next change.
- Callbacks run on Hammerspoon's main thread. A blocking call (`hs.execute`, synchronous URL fetch, slow AppleScript) freezes every hotkey until it returns.
- No Spaces-aware `hs.window.filter` (`setCurrentSpace`, `defaultCurrentSpace`, a `currentSpace` filter field). One makes every Space change re-query every app's windows on the main thread, which the always-on `keyDown` leader tap turns into delayed typing.
- Event taps that return `true` swallow the event system-wide; they must be narrow and removed when their overlay closes.
- Transient UI takes global keys only while it is visible, and only the exact combination it means (Escape without modifiers, not every keycode 53).

## Isolation for concurrent work

The main checkout is the live config and must stay on `main`. Worktrees live outside `~/.hammerspoon`, in `~/.hammerspoon-worktrees/` (see [AGENTS.md](AGENTS.md)). The reload watcher ignores writes under `.git/`, under any hidden directory and inside any nested checkout, so neither edits in a worktree nor its git operations reload the live config, wherever the worktree is. A pull or checkout in the main checkout does reload, once its writes settle. There is no other per-worktree state.

## Where to look first

`init.lua`, then `leader.lua`.
