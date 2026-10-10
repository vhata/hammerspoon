# Decisions

Non-obvious choices and their trade-offs, dated, newest section first. Read the relevant entry before changing a mechanism that looks odd. Choices made autonomously under a delegation are recorded here for the user to review; an entry is a record, not a claim that the capability is complete.

## 2026-10-09

| Decision | Reason and trade-off |
| --- | --- |
| The vendored Emojis spoon carries a local patch: it no longer refocuses the previous window through `hs.window.filter.defaultCurrentSpace`. | That filter is Spaces-aware, so `hs.window.filter` keeps a watcher on every running app and re-queries every app's windows on each Space change, on the main thread, from the moment the spoon loads. Since the leader tap began watching `keyDown`, a stall there delays typing too. `hs.chooser`'s default global callback already saves the frontmost window when a chooser opens and refocuses it in `hide`, before the completion callback runs, so the spoon's refocus was redundant. Cost: an upstream update of the spoon would bring the filter back; reapply the patch. |

## 2026-10-08

| Decision | Reason and trade-off |
| --- | --- |
| The leader's keys are one table passed to `leader.setup` in `init.lua`, and the `?` overlay is rendered from the items that call actually bound. | The help overlay and the bindings come from the same data, so they cannot drift; an invalid item (unknown or duplicate key, missing label) is skipped with a console message rather than failing the reload, and is left out of the help too. Cost: other modules cannot add leader keys themselves; they export functions and `init.lua` places them in the tree. |
| Each leader group is its own `hs.hotkey.modal`, and each layer gets the full one-second timeout. | Swapping modals keeps every layer's keys independent (`o` can mean Overlays at the top and Obsidian under `a`) and needs no key-sequence parser. Restarting the timeout per layer keeps a three-key sequence from having to fit in one second. The alert now stays up for as long as its layer is live, rather than half a second. |
| `?` and Escape are bound by the leader in every layer, so tree items cannot use Escape. `?` is bound as Shift+`/`, so a plain `/` item is still possible. | One help key that works wherever you are in the tree, without each group having to declare it. |
| The Cmd+Alt+Ctrl app hotkeys and `hyper.lua` were removed when the apps moved under leader `a`. | The point of the leader is to free global shortcuts. Restoring them is a loop over the same app list calling `hs.hotkey.bind({"cmd", "alt", "ctrl"}, key, ...)` with `hs.application.launchOrFocus`. |

## 2026-10-07

| Decision | Reason and trade-off |
| --- | --- |
| Worktrees live in `~/.hammerspoon-worktrees/`, not `.worktrees/` inside the repository. | `ReloadConfiguration` watches `hs.configdir` (`~/.hammerspoon`) recursively and reloads on any change, so a worktree inside it would reload the live config on every file an agent edits. A sibling directory stops edits from reloading. Git operations in a worktree of the `~/.hammerspoon` clone (commit, fetch, worktree add) still write under `~/.hammerspoon/.git` and still trigger a reload, as commits in the main checkout always have; a reload is harmless, just noisy. Cost: `start-work.sh` needs `--dir ~/.hammerspoon-worktrees`, and because `git check-ignore` cannot test a path outside the repository, each run appends the expanded `~/.hammerspoon-worktrees/` path to `.git/info/exclude` again and prints advice to add it to `.gitignore`. Ignore that advice; the duplicate exclude lines are inert and safe to delete. Filtering the watcher (ignore `.git/` and any worktree directory) would remove both costs and allow the default layout; queued as `reload-watcher-filter`. |
| The lint gate is `luac -p` (syntax only), preferring Lua 5.4. | Hammerspoon embeds Lua 5.4, and no Hammerspoon runtime exists outside the app, so parsing is the only check that runs in CI. luacheck would catch accidental globals and unused locals but needs a config and a clean baseline first; queued as `adopt-luacheck`. |
| Hooks are a tracked `.githooks/` directory wired by `git config core.hooksPath .githooks`. | One pre-commit check with no dependencies does not justify a hook manager. |
| No scheduled validation workflow. | Nothing here is expensive enough to run on a schedule rather than on every push. Add `main-validation.yml` when a codebase review cadence is wanted, so `review-due.sh` has somewhere to run. |
