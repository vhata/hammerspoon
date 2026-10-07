# Decisions

Non-obvious choices and their trade-offs, dated, newest section first. Read the relevant entry before changing a mechanism that looks odd. Choices made autonomously under a delegation are recorded here for the user to review; an entry is a record, not a claim that the capability is complete.

## 2026-10-07

| Decision | Reason and trade-off |
| --- | --- |
| Worktrees live in `~/.hammerspoon-worktrees/`, not `.worktrees/` inside the repository. | `ReloadConfiguration` watches `hs.configdir` (`~/.hammerspoon`) recursively and reloads on any change, so a worktree inside it would reload the live config on every file an agent edits. A sibling directory stops edits from reloading. Git operations in a worktree (commit, fetch, worktree add) still write under `~/.hammerspoon/.git` and still trigger a reload, as commits in the main checkout always have; a reload is harmless, just noisy. Cost: `start-work.sh` needs `--dir ../.hammerspoon-worktrees`, and because `git check-ignore` cannot test a path outside the repository, each run appends `../.hammerspoon-worktrees/` to `.git/info/exclude` again and prints advice to add it to `.gitignore`. Ignore that advice; the duplicate exclude lines are inert and safe to delete. Filtering the watcher (ignore `.git/` and any worktree directory) would remove both costs and allow the default layout; queued as `reload-watcher-filter`. |
| The lint gate is `luac -p` (syntax only), preferring Lua 5.4. | Hammerspoon embeds Lua 5.4, and no Hammerspoon runtime exists outside the app, so parsing is the only check that runs in CI. luacheck would catch accidental globals and unused locals but needs a config and a clean baseline first; queued as `adopt-luacheck`. |
| Hooks are a tracked `.githooks/` directory wired by `git config core.hooksPath .githooks`. | One pre-commit check with no dependencies does not justify a hook manager. |
| No scheduled validation workflow. | Nothing here is expensive enough to run on a schedule rather than on every push. Add `main-validation.yml` when a codebase review cadence is wanted, so `review-due.sh` has somewhere to run. |
