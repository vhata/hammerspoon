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
- [TOOLING] `workflow-script-hygiene` — **Fix the small defects in the workflow scripts: root detection, churn threshold, temp file, help output, claim matching and the queue list.** Each is minor, they share one directory, and together they make the gates and claim checks say what they mean.
  - Findings: `review-due-vendored-dilution`, `workflow-scripts-cwd-root`, `check-links-tempfile-in-root`, `help-ranges-off`, `claim-check-substring-match`, `start-work-queue-list`
  - Source: [review/2026-10-09-0859-full.md](2026-10-09-0859-full.md), 2026-10-09
  - Starting point: the snapshot lists each site. The scripts under `docket/scripts/` are vendored from the docket skill, so fixes go to the skill and arrive by resync; the skill's current copies already match local branches and worktrees by whole component (pull request head branches still by substring) and write the link checker's scratch files under `mktemp`, so re-verify each finding against them. Excluding vendored paths from `review-due.sh` needs a `--paths` argument that no document records yet.

## Unprioritized
