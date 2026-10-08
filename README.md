## Hammerspoon configs

For use with [Hammerspoon](https://www.hammerspoon.org/). Clone to `~/.hammerspoon`.

### Bindings

| Keys | Action |
| --- | --- |
| Cmd+Alt+Ctrl+C / V / O / D | Focus or launch Chrome / Vivaldi / Obsidian / Discord |
| Double-tap right Ctrl or right Shift, then O, C | Toggle the floating clock |
| Double-tap, then O, L | Toggle the floating calendar (arrows change month and year, R resets, Esc closes) |
| Double-tap, then O, E | Emoji picker |
| Double-tap, then O, V | Neovim cheatsheet from `~/.config/nvim/CHEATSHEET.md` |
| Cmd+Alt+E | Text-expansion picker (needs `~/bin/expanse`) |
| F14 or keypad / | Spotify now-playing notification |

The config reloads automatically when any file under `~/.hammerspoon` changes.

### Working on it

Run `bash scripts/setup.sh` once to install the pre-commit hook, and `bash scripts/check.sh` before opening a PR. Agents (and people) working here follow [AGENTS.md](AGENTS.md). Deferred work is in [TODO.md](TODO.md).

The repository workflow (agent contract, queues, review ledger, CI) was set up with Claude Code.
