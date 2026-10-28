## Hammerspoon configs

For use with [Hammerspoon](https://www.hammerspoon.org/). Clone to `~/.hammerspoon`.

### Bindings

| Keys | Action |
| --- | --- |
| Double-tap right Ctrl or right Shift, then ? | Overlay listing every leader key and the global hotkeys bound through `hotkeys.lua`, generated from what actually bound |
| Double-tap, then E, E | Paste the `email` expansion from Expanse into the focused app |
| Double-tap, then O, C | Toggle the floating clock |
| Double-tap, then O, L | Toggle the floating calendar, open on the current month (Left and Right change month, Up and Down change year, R returns to today, Esc closes; any other key or a click closes it and goes through to the app) |
| Double-tap, then O, E | Emoji picker |
| Double-tap, then O, V | Neovim cheatsheet from `~/.config/nvim/CHEATSHEET.md` |
| Double-tap, then A, C / V / O / D | Focus or launch Chrome / Vivaldi / Obsidian / Discord |
| Double-tap, then A, T / S / B / W / M | Focus or launch Todoist / Signal / Bitwarden / WhatsApp / Spotify |
| Double-tap, then S, Space | Spotify play / pause |
| Double-tap, then S, L | Like the current Spotify song (one-time authorization below) |
| Double-tap, then S, / | Spotify now-playing notification |
| Double-tap, then S, N / P | Next / previous Spotify track |
| Double-tap, then S, Left / Right | Rewind / forward 10 seconds, bounded by the current track |
| Double-tap, then S, R | Restart the current Spotify track |
| Double-tap, then S, S | Toggle Spotify shuffle |
| Double-tap, then S, Up / Down | Raise / lower Spotify's volume by 5%, bounded to 0–100% |
| Double-tap, then S, O | Open Spotify |
| Hyper+K | Type a line; it becomes a new note in the Personal vault's `Intake/` folder, as `~/bin/intake` makes. Press again or Esc to cancel |
| Hyper+B | The same, in the Books vault's `Intake/` folder |
| Hyper+E | Text-expansion picker; copies the selection to the clipboard (needs `~/bin/expanse`) |
| F14 or keypad / | Spotify now-playing notification |

Hyper is Ctrl+Alt+Shift+Cmd, which Karabiner-Elements maps Caps Lock to. Global hotkeys are bound through `hotkeys.bind` in `hotkeys.lua` so that the help overlay lists them.

The config reloads automatically a second after the last change to a `.lua` or `.json` file under `~/.hammerspoon`. Changes under `.git/` or other hidden directories, and inside nested checkouts such as worktrees, are ignored.

### Expanse shortcuts

Double-tap right Ctrl or right Shift, then `E`, `E` to fetch the named
`email` expansion from `~/bin/expanse` and paste it with Cmd+V. The text
stays on the clipboard. Hyper+E opens the existing picker and copies its
selection without pasting.

Add more single-letter shortcuts in the `Expanse` group in `init.lua`,
using `expanse.paste("name")` with an existing Expanse name. The leader's
`?` help lists these shortcuts automatically. Lookup runs in the background;
a response taking longer than three seconds is discarded. A failed, missing
or empty expansion leaves the clipboard alone. The paste is cancelled if
a different window or app has focus when lookup finishes.

### Spotify likes

Playback controls use the running Spotify desktop app; `S`, then `O` opens it. They run in the background and report failures without taking focus. The leader closes after each action, as it does for the other groups. F14 and keypad `/` still show the existing now-playing notification.

Liking uses the `spotify-cli` package already installed in `~/.venv/3.12`, through `scripts/spotify-like.py`. This is separate from the `spotify` command installed by Homebrew. Authorize library changes once:

```bash
~/.venv/3.12/bin/spotify auth login
```

Keep your existing permissions selected and enable **Modify user library and followed artists/users.** Complete the browser authorization. It grants `user-library-modify`, which is required to save a song. A missing login or permission produces an alert pointing here; playback controls do not need this login.

`S`, then `L` saves the desktop app's captured song to Liked Songs, even if playback changes while the request is in flight. Saving an already-liked song leaves it liked. Local files, podcasts, and ads are not supported. The helper reuses the CLI's credentials and token refresh; it never starts login itself or displays tokens. Requests have an eight-second socket timeout and the background process has a 30-second deadline. On a timeout or network failure, check Liked Songs before retrying because a save might already have reached Spotify.

### Working on it

Run `bash scripts/setup.sh` once to install the pre-commit hook, and `bash scripts/check.sh` before opening a PR. The checks and hook need `luac` and `luacheck` (`brew install lua luacheck`); setup only configures the hook path. Hammerspoon and CI use Lua 5.4, while the local Homebrew Lua is 5.5; the versions can reject different syntax (see [toolchain details](docs/QUALITY.md#gates)). Agents (and people) working here follow [AGENTS.md](AGENTS.md). Deferred work is in [TODO.md](TODO.md).

The repository workflow (agent contract, queues, review ledger, CI) was set up with Claude Code.
