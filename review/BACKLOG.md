# Review backlog

Only work promoted from whole-codebase reviews belongs here. Every entry is ready for separate work and carries a `Findings:` line naming the raw review findings it covers; each finding maps to at most one entry. Claiming and resolving follow [docs/TODO_GUIDE.md](../docs/TODO_GUIDE.md); promotion follows [docs/CODE_REVIEW_GUIDE.md](../docs/CODE_REVIEW_GUIDE.md).

## P0 Critical

## P1 High

## P2 Normal

- [MODULES] `expanse-chooser-fixes` — **Keep the expansion picker usable while it is open, and stop its subtext showing broken characters.** The chooser is referenced only by a local in `pick_expanse`, so garbage collection can drop its callback mid-use, and the subtext truncation cuts multibyte characters such as `↵` in half.
  - Findings: `expanse-chooser-gc`, `expanse-truncate-utf8`
  - Source: [review/2026-10-09-0859-full.md](2026-10-09-0859-full.md), 2026-10-09
  - Starting point: one module-level `hs.chooser` in `expanse.lua` (as `Spoons/Emojis.spoon` holds `obj.chooser`), `:choices()` refreshed before each `:show()`; cut the subtext with `utf8.offset`.
  - Related: `expanse-error-feedback`
- [TOOLING] `workflow-script-silent-exits` — **Make `review-due.sh` and `check-pr-markers.sh` report instead of exiting 1 silently when a `grep` finds nothing.** Under `set -euo pipefail` a no-match `grep` in a substitution or pipeline ends the script; `review-due.sh` hits this on the first run after the 2026-10-09 review when no source has changed.
  - Findings: `review-due-silent-exit-no-churn`, `pr-markers-silent-exit-remaining-from`
  - Source: [review/2026-10-09-0859-full.md](2026-10-09-0859-full.md), 2026-10-09
  - Starting point: `|| true` inside `churn_since` in `scripts/workflow/review-due.sh` and inside both `orig="$(...)"` substitutions in `scripts/workflow/check-pr-markers.sh`. The scripts are identical to the repo-workflow skill's bundled copies, so make the same fix there.

## P3 Low

- [CONFIG] `leader-stray-input` — **Stop the leader opening on clicks and staying open after a key it does not bind.** Two right-Shift or right-Ctrl clicks within half a second open it, and a stray key in an open layer passes through while the layer stays live for the next key.
  - Findings: `leader-tap-ignores-mouse`, `leader-unbound-key-stays-live`
  - Source: [review/2026-10-09-0859-full.md](2026-10-09-0859-full.md), 2026-10-09
  - Starting point: add mouse-down and scroll events to `M.tap` in `leader.lua` and reset the tap state on them; record each modal's bound keys in `build` and call `deactivate()` from the tap's `keyDown` branch when the active layer does not bind the key.
- [TOOLING] `workflow-script-hygiene` — **Fix the small defects in the workflow scripts: root detection, churn threshold, temp file, help output, claim matching and the queue list.** Each is minor, they share one directory, and together they make the gates and claim checks say what they mean.
  - Findings: `review-due-vendored-dilution`, `workflow-scripts-cwd-root`, `check-links-tempfile-in-root`, `help-ranges-off`, `claim-check-substring-match`, `start-work-queue-list`
  - Source: [review/2026-10-09-0859-full.md](2026-10-09-0859-full.md), 2026-10-09
  - Starting point: the snapshot lists each site. Excluding vendored paths from `review-due.sh` may be better done by passing `--paths` from `docs/CODE_REVIEW_GUIDE.md`. Same upstream note as `workflow-script-silent-exits`.
  - Related: `workflow-script-silent-exits`

## Unprioritized
