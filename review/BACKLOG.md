# Review backlog

Only work promoted from whole-codebase reviews belongs here. Every entry is ready for separate work and carries a `Findings:` line naming the raw review findings it covers; each finding maps to at most one entry. Claiming and resolving follow [docket/TODO_GUIDE.md](../docket/TODO_GUIDE.md); promotion follows [docket/CODE_REVIEW_GUIDE.md](../docket/CODE_REVIEW_GUIDE.md).

## P0 Critical

## P1 High

## P2 Normal

- [MODULES] `expanse-chooser-fixes` — **Keep the expansion picker usable while it is open, and stop its subtext showing broken characters.** The chooser is referenced only by a local in `pick_expanse`, so garbage collection can drop its callback mid-use, and the subtext truncation cuts multibyte characters such as `↵` in half.
  - Findings: `expanse-chooser-gc`, `expanse-truncate-utf8`
  - Source: [review/2026-10-09-0859-full.md](2026-10-09-0859-full.md), 2026-10-09
  - Starting point: one module-level `hs.chooser` in `expanse.lua` (as `Spoons/Emojis.spoon` holds `obj.chooser`), `:choices()` refreshed before each `:show()`; cut the subtext with `utf8.offset`.

## P3 Low

- [CONFIG] `leader-stray-input` — **Stop the leader opening on clicks and staying open after a key it does not bind.** Two right-Shift or right-Ctrl clicks within half a second open it, and a stray key in an open layer passes through while the layer stays live for the next key.
  - Findings: `leader-tap-ignores-mouse`, `leader-unbound-key-stays-live`
  - Source: [review/2026-10-09-0859-full.md](2026-10-09-0859-full.md), 2026-10-09
  - Starting point: add mouse-down and scroll events to `M.tap` in `leader.lua` and reset the tap state on them; record each modal's bound keys in `build` and call `deactivate()` from the tap's `keyDown` branch when the active layer does not bind the key.
- [TOOLING] `workflow-script-hygiene` — **Make `check-links.sh` fail when it has nothing real to check, and fix `start-work.sh`'s usage output.** Both are small defects in the vendored workflow scripts; of the other four it once covered, three were fixed when the scripts were vendored from the docket skill and one by recording `--paths` in `docs/QUALITY.md`.
  - Findings: `workflow-scripts-cwd-root`, `help-ranges-off`
  - Source: [review/2026-10-09-0859-full.md](2026-10-09-0859-full.md), 2026-10-09; narrowed by [review/2026-10-12-1753-incremental.md](2026-10-12-1753-incremental.md), 2026-10-12
  - Starting point: the scripts under `docket/scripts/` are vendored from the docket skill, so fixes go to the skill and arrive by resync. `check-links.sh` falls back to `pwd` outside a repository (`:19`) and accepts a missing file argument or `--help` as a file (`:31-33`); `start-work.sh:14` prints lines 2-10, one past the header.
- [SPOONS] `floatcalendar-follow-spaces` — **Stop the open calendar taking keys on a Space where it is not shown.** A Space switch does not close it, so its tap keeps swallowing arrows, R and Escape meant for the app on the new Space.
  - Findings: `floatcalendar-keys-taken-off-space`
  - Source: [review/2026-10-12-1753-incremental.md](2026-10-12-1753-incremental.md), 2026-10-12
  - Starting point: confirm first in the running app (`spoon.FloatCalendar.canvas:behaviorAsLabels()`, then open the calendar and swipe to another Space). If it reproduces, set `self.canvas:behavior("canJoinAllSpaces")` in `obj:init()` in `Spoons/FloatCalendar.spoon/init.lua`, or hide the calendar from an `hs.spaces.watcher`.
- [MODULES] `overlay-follow-spaces` — **Stop an open cheatsheet or leader help taking Escape on a Space where it is not shown, and give the overlay one deliberate window level.** A Space switch leaves the overlay's Escape tap running, and `:bringToFront(true)` silently replaces the level set just before it.
  - Findings: `overlay-keys-taken-off-space`, `overlay-level-overridden`
  - Source: [review/2026-10-13-2309-full.md](2026-10-13-2309-full.md), 2026-10-13
  - Related: `floatcalendar-follow-spaces`
  - Starting point: confirm first in the running app (open the cheatsheet, check `:behaviorAsLabels()` on the webview, swipe to another Space, press Escape). If it reproduces, set `canJoinAllSpaces` on the webview in `o.toggle` in `overlay.lua`, or close the overlay when it is not on the current Space, matching whatever `floatcalendar-follow-spaces` does. Then keep one of `:level(...)` and `:bringToFront(true)`.
- [TOOLING] `lua-gate-file-checks` — **Make the Lua gates check exactly the first-party files that exist on disk.** An unstaged deletion of a tracked `.lua` file makes `scripts/lint.sh` and `scripts/luacheck.sh` fail every commit, and widening `exclude_files` past the vendored spoons still passes luacheck.
  - Findings: `lint-unstaged-deletion-blocks-commit`, `luacheck-partial-exclusion-silent`
  - Source: [review/2026-10-13-2309-full.md](2026-10-13-2309-full.md), 2026-10-13
  - Starting point: skip listed paths that do not exist in both scripts; in `scripts/luacheck.sh`, compare the checked count with the tracked Lua files outside `Spoons/AClock.spoon/` and `Spoons/Emojis.spoon/` and fail when they differ.
- [TOOLING] `ci-checkout-v5` — **Move CI off the deprecated Node 20 checkout action.** Both jobs use `actions/checkout@v4`, which runs only because GitHub forces it onto Node 24.
  - Findings: `ci-checkout-node20`
  - Source: [review/2026-10-13-2309-full.md](2026-10-13-2309-full.md), 2026-10-13
  - Starting point: `actions/checkout@v5` or later at `.github/workflows/ci.yml:33` and `:43`. A CI change, so it needs the user's go-ahead.

## Unprioritized
