# Hammerspoon config: agent contract

Personal [Hammerspoon](https://www.hammerspoon.org/) configuration for one macOS user: app hotkeys, a double-tap leader key, overlays (clock, calendar, emoji picker, cheatsheet), a text-expansion picker and a Spotify now-playing notification. There is no deliverable; priorities follow what the user notices day to day.

<!-- docket:begin -->
## Docket

This project is run with docket. Read [docket/CONTRACT.md](docket/CONTRACT.md) before any work; it is the authoritative workflow, and this section records only this project's settings. The installer keeps this section current: the text above the list is rewritten on every run, the list keeps the values this project has set.

- Queue areas: `[CONFIG]` (`init.lua`, `leader.lua`, `leaderhelp.lua`, `reload.lua`), `[MODULES]` (`cheatsheet.lua`, `expanse.lua`, `overlay.lua`, `spotify.lua`), `[SPOONS]`, `[TOOLING]`, `[DOCS]`.
- Concurrency cap: none needed; nothing here is heavy to build.
- Merging and releases: the user merges. There is no standing merge delegation.
- Optional pieces in force: branch and PR per unit of work, claim checks and markers, independent review, the check entrypoint, the pre-commit hook, CI on PRs and `main`, the review ledger. Deferred: scheduled validation of `main` (nothing expensive to run), stacked PRs.
- Environment: **the main checkout at `~/.hammerspoon` is the live config.** Hammerspoon loads whatever is checked out there and reloads when a `.lua` or `.json` file under it changes (see `reload.lua`). Keep it on `main`, never switch its branch, and never create worktrees inside it. Worktrees live in `~/.hammerspoon-worktrees/`: always pass `--dir ~/.hammerspoon-worktrees` to `docket/scripts/start-work.sh`. See [`docs/DECISIONS.md`](docs/DECISIONS.md).
- Verification: the gates only prove the Lua parses. Behaviour can only be checked in the running Hammerspoon app, so every PR states which behaviour the user needs to try after merging, and agents never claim a behaviour change was verified unless they ran it.
- Commits and PRs: short, lowercase, imperative subjects in the style of the existing log; no attribution trailers. PR bodies follow `.github/pull_request_template.md`. The repository's git `user.email` is the user's personal address and is already set.
- Review snapshots: open the review PR from a `task/` branch. A `review/<slug>` branch must claim a backlog slug, which a review does not have.
- Vendored spoons: `AClock` and `Emojis` are upstream code; edit them only when the entry being worked says so. `FloatCalendar` is the user's own.
<!-- docket:end -->

## Where to find what

- `README.md`: what the config does and its key bindings.
- `ARCHITECTURE.md`: modules, load order, invariants.
- `docs/DECISIONS.md`: non-obvious choices and their trade-offs. Read before changing a mechanism that looks odd.
- `docs/QUALITY.md`: what quality means here, the gates, and the review inputs.
- `TODO.md`, `review/`: deferred work and the review ledger.
