# Hammerspoon config: agent contract

Personal [Hammerspoon](https://www.hammerspoon.org/) configuration for one macOS user: app hotkeys, a double-tap leader key, overlays (clock, calendar, emoji picker, cheatsheet), a text-expansion picker and a Spotify now-playing notification. There is no deliverable; priorities follow what the user notices day to day.

## Workflow

- Every unit of work is a branch, a worktree and a pull request. Branch `<queue>/<slug>` (`todo/`, `review/`; `fix/` or `task/` for direct requests). 
- Two things go straight to `main` without a branch or PR. Documentation that records work to be done: adding or triaging `TODO.md` entries, and plans (`plans/YYYY-MM-DD-<slug>.md`); a plan is planning for work, not work, and everything it describes still goes through branches, PRs and review. Housekeeping metadata files such as `.git-blame-ignore-revs`, only when the user says so for that case. Extrapolate with common sense and say so in the commit; everything else, including all code and any documentation that describes behaviour, goes through a PR.
- **The main checkout at `~/.hammerspoon` is the live config.** Hammerspoon loads whatever is checked out there and reloads when a `.lua` or `.json` file under it changes (see `reload.lua`). Keep it on `main`, never switch its branch, and never create worktrees inside it. Worktrees live in `~/.hammerspoon-worktrees/` (pass `--dir ~/.hammerspoon-worktrees` to `start-work.sh`). See [`docs/DECISIONS.md`](docs/DECISIONS.md).
- Before claiming anything run `bash scripts/workflow/claim-check.sh <slug>`, then create the branch and worktree immediately with `bash scripts/workflow/start-work.sh <queue> <slug> --dir ~/.hammerspoon-worktrees`.
- Open a draft PR after the first meaningful commit. The body follows `.github/pull_request_template.md` and opens with `## Why`. PRs are squash-merged, so the body is the commit message. If no PR can be opened, save the body as `.feral/pr-<slug>.md`, say so, and leave the branch and worktree for the user.
- Parallelise independent work through sub-agents in separate worktrees with disjoint file ownership. The coordinating agent integrates, serialises edits to `TODO.md` and `review/BACKLOG.md`, and holds the push and merge gates. No concurrency cap is needed; nothing here is heavy to build.
- Every code-writing agent, including the coordinator, gets a separate reviewer agent before a PR is marked ready. The reviewer verifies the PR's claims and reports findings; the author fixes; the PR body records the review in a `## Review` section.
- Keep the branch on its stated outcome. A separately shippable idea becomes a `TODO.md` entry with a `Source:` line (and a `Files TODO: <slug>` marker in the PR), then the original work continues.
- Run `bash scripts/check.sh` before opening or updating a PR; `bash scripts/setup.sh` installs the pre-commit hook that runs the same lint gate. These checks only prove the Lua parses. Behaviour can only be checked in the running Hammerspoon app, so every PR states which behaviour the user needs to try after merging, and agents never claim a behaviour change was verified unless they ran it.
- Linear history: rebase, never merge `main` into a branch; `--force-with-lease` on PR branches only. The user merges. There is no standing merge delegation.
- Commit regularly, one logical change per commit, in the style of the existing log (short, lowercase, imperative). No attribution trailers. The repository's git `user.email` is the user's personal address and is already set; sub-agents never change `git config`.
- Vendored spoons (`AClock`, `Calendar`, `Emojis`, `ReloadConfiguration`) are upstream code. Edit them only when the entry being worked says so; `FloatCalendar` is the user's own.
- Update documentation in the same PR when a change makes it inaccurate. Each rule has one authoritative home; link to it rather than restating it.

## In force

Branch and PR per unit of work, claim checks and markers, independent review, the check entrypoint, the pre-commit hook, CI on PRs and `main`, the review ledger (empty until the first review is requested). Deferred: scheduled validation of `main` (nothing expensive to run), stacked PRs.

## Process guides

Read only the guide the task needs.

- An idea surfaces, or you are selecting, claiming, moving or resolving deferred work: [`docs/TODO_GUIDE.md`](docs/TODO_GUIDE.md). "Grab a TODO" means `TODO.md` only; "grab a review finding" means `review/BACKLOG.md` only. Never switch queues.
- A codebase review is requested, or a PR resolves a review finding: [`docs/CODE_REVIEW_GUIDE.md`](docs/CODE_REVIEW_GUIDE.md).
- Changing code or validating a PR: [`docs/QUALITY.md`](docs/QUALITY.md).
- Working unattended under a broad autonomy grant: no pushes, merges or tags without the user's word; local branches with PR bodies in `.feral/pr-<slug>.md`; load-bearing decisions in `AUDIT.md` (excluded from git) with an undo line each.

## Where to find what

- `README.md`: what the config does and its key bindings.
- `ARCHITECTURE.md`: modules, load order, invariants.
- `docs/DECISIONS.md`: non-obvious choices and their trade-offs. Read before changing a mechanism that looks odd.
- `TODO.md`, `review/`: deferred work and the review ledger.

Keep this file short. Add a line only when it prevents a concrete recurring mistake; details go in the guide that owns them.
