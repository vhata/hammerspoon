# Quality and validation

Read when changing code or preparing a PR. This document describes the gates as they exist now; history and rationale for past changes live in `docs/DECISIONS.md` and git.

## What quality means here

- Hotkeys and overlays do what they say, every time, without firing during ordinary typing.
- Nothing blocks Hammerspoon's main thread long enough to notice; a stuck callback freezes every binding.
- A reload never fails halfway. A Lua error in any module stops the rest of `init.lua` from loading.
- Behaviour is verified by hand in the running app. No headless Hammerspoon exists, so the mechanical gates prove only that the code parses and passes luacheck, and that the records are consistent.
- Review focus: blocking calls on Hammerspoon's main thread (`hs.execute`, synchronous network fetches, AppleScript), event taps and global hotkeys that swallow or misfire on ordinary input, accidental globals, objects that must stay referenced to avoid garbage collection (watchers, taps, timers), shell commands built from unquoted input, and screen geometry that assumes a single display at the origin.

## Gates

Each check is a standalone script in `scripts/` (this project's gates) or `docket/scripts/` (the vendored workflow validators), runnable from any directory, exiting non-zero on failure. The hook, CI and agents run the same scripts.

| Script | Runs | Pre-commit | CI on PR | CI on main |
| --- | --- | --- | --- | --- |
| `scripts/lint.sh` | `luac -p` on every tracked `.lua` file; fails if none are found | yes | yes | yes |
| `scripts/luacheck.sh` | luacheck on every tracked `.lua` file with `.luacheckrc`: Lua 5.4, `hs` and `spoon` as read-only globals, the vendored `AClock` and `Emojis` spoons excluded; fails on any warning, if luacheck is missing or if no files are found | | yes | yes |
| `docket/scripts/ci.sh` | queue hygiene, relative Markdown links and, on pull requests, PR markers against the queues | | yes | yes |
| `scripts/check.sh` | lint, luacheck, then `docket/scripts/check-queues.sh --strict` and `docket/scripts/check-links.sh`, in order | | | |

The hook lives in `.githooks/pre-commit` and is installed by `bash scripts/setup.sh` (`core.hooksPath`). It runs `scripts/lint.sh` only. It checks the working tree rather than the staged content, so a partially staged file is linted as it is on disk. It checks only and never rewrites files, and takes well under a second. Bypassing it is for a broken toolchain only; state the bypass and the equivalent checks in the PR.

Toolchain: CI installs Ubuntu's `lua5.4`, matching the Lua version Hammerspoon embeds. Locally `scripts/lint.sh` prefers `luac5.4` and falls back to whatever `luac` is installed (Homebrew currently ships 5.5), so a local pass on a newer Lua is not proof of a 5.4 pass; CI is. luacheck comes from Ubuntu's `lua-check` package in CI (1.1.2 on 24.04) and from `brew install luacheck` locally (1.2.0); it uses its own parser and checks against the Lua 5.4 standard library whichever Lua runs it. A warning that is deliberate gets an inline `-- luacheck: ignore <code>/<name>` or a `.luacheckrc` entry, each with the reason beside it.

## Test policy

- There are no automated tests. Every PR that changes behaviour states, in its Validation section, the exact steps for the user to try in Hammerspoon after merging (keys to press, what should appear) and what the old behaviour was.
- Pure logic that can run outside Hammerspoon (date arithmetic in FloatCalendar, parsing in `expanse.lua`) may be exercised with a standalone `lua` script in the PR's validation, quoted with its output. Such scripts are evidence, not a suite, until a test runner is adopted.
- An agent never reports a behaviour change as verified unless it observed it.

## CI

`.github/workflows/ci.yml` runs on pull requests and on pushes to `main`. Jobs: `check` (lint, then luacheck) and `Queue and PR hygiene` (one call to `docket/scripts/ci.sh`: queues, links, PR markers on pull requests). Superseded runs are cancelled on PR branches only, never on `main`.

## Scheduled validation of main

None. See `docs/DECISIONS.md`.

## Branch protection

Applied on 2026-10-07. A pull request is required with zero approving reviews (independent agent review is recorded in `## Review`); required checks `check` and `Queue and PR hygiene`; branches need not be up to date with `main` before merging; linear history required; conversation resolution not required; force pushes and deletions on `main` allowed for the owner (agents never use them); not enforced for administrators, which permits the direct-to-main exceptions in [`docket/CONTRACT.md`](../docket/CONTRACT.md). Squash merging only, PR title and body as the commit message, head branches deleted on merge.

## Review inputs

What the vendored review guide ([`docket/CODE_REVIEW_GUIDE.md`](../docket/CODE_REVIEW_GUIDE.md)) reads from this project.

- Focus areas: the review-focus list under [What quality means here](#what-quality-means-here).
- Baseline commands beyond `bash scripts/check.sh`: none. No headless runtime exists; behaviour is checked by reloading the live config in Hammerspoon and reading its console.
- Drift checks for an incremental review: hotkeys and leader bindings documented in `README.md` against `init.lua` and the modules; this document against the hook and CI; `bash ~/.claude/skills/docket/install.sh --check` for drift in `docket/`.

## PR evidence

Every PR lists the commands run and their results, the manual steps for any behaviour change, what was not run and why, and the independent review. See [`docket/CODE_REVIEW_GUIDE.md`](../docket/CODE_REVIEW_GUIDE.md).
