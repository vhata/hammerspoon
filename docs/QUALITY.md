# Quality and validation

Read when changing code or preparing a PR. This document describes the gates as they exist now; history and rationale for past changes live in `docs/DECISIONS.md` and git.

## What quality means here

- Hotkeys and overlays do what they say, every time, without firing during ordinary typing.
- Nothing blocks Hammerspoon's main thread long enough to notice; a stuck callback freezes every binding.
- A reload never fails halfway. A Lua error in any module stops the rest of `init.lua` from loading.
- Behaviour is verified by hand in the running app. No headless Hammerspoon exists, so the mechanical gates prove only that the code parses and the records are consistent.

## Gates

Each check is a standalone script, runnable from any directory, exiting non-zero on failure. The hook, CI and agents run the same scripts.

| Script | Runs | Pre-commit | CI on PR | CI on main |
| --- | --- | --- | --- | --- |
| `scripts/lint.sh` | `luac -p` on every tracked `.lua` file; fails if none are found | yes | yes | yes |
| `scripts/workflow/check-queues.sh --strict` | queue hygiene | | yes | yes |
| `scripts/workflow/check-pr-markers.sh` | PR markers against queues | | yes | |
| `scripts/workflow/check-links.sh` | relative Markdown links | | yes | yes |
| `scripts/check.sh` | lint, queues, links, in order | | | |

The hook lives in `.githooks/pre-commit` and is installed by `bash scripts/setup.sh` (`core.hooksPath`). It checks only and never rewrites files; it takes well under a second. Bypassing it is for a broken toolchain only; state the bypass and the equivalent checks in the PR.

Toolchain: CI installs Ubuntu's `lua5.4`, matching the Lua version Hammerspoon embeds. Locally `scripts/lint.sh` prefers `luac5.4` and falls back to whatever `luac` is installed (Homebrew currently ships 5.5), so a local pass on a newer Lua is not proof of a 5.4 pass; CI is.

## Test policy

- There are no automated tests. Every PR that changes behaviour states, in its Validation section, the exact steps for the user to try in Hammerspoon after merging (keys to press, what should appear) and what the old behaviour was.
- Pure logic that can run outside Hammerspoon (date arithmetic in FloatCalendar, parsing in `expanse.lua`) may be exercised with a standalone `lua` script in the PR's validation, quoted with its output. Such scripts are evidence, not a suite, until a test runner is adopted.
- An agent never reports a behaviour change as verified unless it observed it.

## CI

`.github/workflows/ci.yml` runs on pull requests and on pushes to `main`. Jobs: `check` (lint) and `Queue and PR hygiene` (queues, links, PR markers). Superseded runs are cancelled on PR branches only, never on `main`.

## Scheduled validation of main

None. See `docs/DECISIONS.md`.

## Branch protection

Not configured. `main` accepts direct pushes. The proposed settings are in the PR that installed this document; once applied, record them here.

## PR evidence

Every PR lists the commands run and their results, the manual steps for any behaviour change, what was not run and why, and the independent review. See [CODE_REVIEW_GUIDE.md](CODE_REVIEW_GUIDE.md).
