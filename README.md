## Hammerspoon configs

For use with [Hammerspoon](https://www.hammerspoon.org/). Clone to `~/.hammerspoon`.

### Bindings

| Keys | Action |
| --- | --- |
| Double-tap right Ctrl or right Shift, then ? | Overlay listing every leader key, generated from the tree in `init.lua` |
| Double-tap, then O, C | Toggle the floating clock |
| Double-tap, then O, L | Toggle the floating calendar, open on the current month (Left and Right change month, Up and Down change year, R returns to today, Esc closes; any other key or a click closes it and goes through to the app) |
| Double-tap, then O, E | Emoji picker |
| Double-tap, then O, V | Neovim cheatsheet from `~/.config/nvim/CHEATSHEET.md` |
| Double-tap, then A, C / V / O / D | Focus or launch Chrome / Vivaldi / Obsidian / Discord |
| Cmd+Alt+E | Text-expansion picker (needs `~/bin/expanse`) |
| F14 or keypad / | Spotify now-playing notification |

The config reloads automatically a second after the last change to a `.lua` or `.json` file under `~/.hammerspoon`. Changes under `.git/` or other hidden directories, and inside nested checkouts such as worktrees, are ignored.

### Working on it

Run `bash scripts/setup.sh` once to install the pre-commit hook, and `bash scripts/check.sh` before opening a PR. Agents (and people) working here follow [AGENTS.md](AGENTS.md). Deferred work is in [TODO.md](TODO.md).

The repository workflow (agent contract, queues, review ledger, CI) was set up with Claude Code.
