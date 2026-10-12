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
- [TOOLING] `workflow-script-hygiene` — **Make `check-links.sh` fail when it has nothing real to check, and fix `start-work.sh`'s usage output.** Both are small defects in the vendored workflow scripts; the other four findings this entry once covered were fixed when the scripts were vendored from the docket skill.
  - Findings: `workflow-scripts-cwd-root`, `help-ranges-off`
  - Source: [review/2026-10-09-0859-full.md](2026-10-09-0859-full.md), 2026-10-09; narrowed by [review/2026-10-12-1753-incremental.md](2026-10-12-1753-incremental.md), 2026-10-12
  - Starting point: the scripts under `docket/scripts/` are vendored from the docket skill, so fixes go to the skill and arrive by resync. `check-links.sh` falls back to `pwd` outside a repository (`:19`) and accepts a missing file argument or `--help` as a file (`:31-33`); `start-work.sh:14` prints lines 2-10, one past the header.
- [SPOONS] `floatcalendar-follow-spaces` — **Stop the open calendar taking keys on a Space where it is not shown.** A Space switch does not close it, so its tap keeps swallowing arrows, R and Escape meant for the app on the new Space.
  - Findings: `floatcalendar-keys-taken-off-space`
  - Source: [review/2026-10-12-1753-incremental.md](2026-10-12-1753-incremental.md), 2026-10-12
  - Starting point: confirm first in the running app (`spoon.FloatCalendar.canvas:behaviorAsLabels()`, then open the calendar and swipe to another Space). If it reproduces, set `self.canvas:behavior("canJoinAllSpaces")` in `obj:init()` in `Spoons/FloatCalendar.spoon/init.lua`, or hide the calendar from an `hs.spaces.watcher`.

## Unprioritized
