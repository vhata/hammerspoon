# Review backlog

Only work promoted from whole-codebase reviews belongs here. Every entry is ready for separate work and carries a `Findings:` line naming the raw review findings it covers; each finding maps to at most one entry. Claiming and resolving follow [docket/TODO_GUIDE.md](../docket/TODO_GUIDE.md); promotion follows [docket/CODE_REVIEW_GUIDE.md](../docket/CODE_REVIEW_GUIDE.md).

## P0 Critical

## P1 High

## P2 Normal

## P3 Low

- [MODULES] `expanse-chooser-fixes` — **Keep the expansion chooser referenced in every focus state and preserve UTF-8 in long previews.** Normally Hammerspoon's default focus callback holds the chooser while open, but it supplies no reference when no window is focused; byte truncation independently produces invalid UTF-8.
  - Findings: `expanse-chooser-gc`, `expanse-truncate-utf8`
  - Source: [review/2026-10-24-0250-full.md](2026-10-24-0250-full.md), 2026-10-24; narrows and downgrades the original P2 claim from the 2026-10-09 review.
  - Starting point: hold one module-level `hs.chooser` in `expanse.lua`, refresh choices before showing, and cut subtext at UTF-8 boundaries. Validate long text containing `↵` or emoji and the no-frontmost-window case; distinguish Lua rooting checks from actual native GC behaviour.
- [CONFIG] `leader-stray-input` — **Stop the leader opening on clicks and staying active after unmatched typing.** Mouse/scroll input does not cancel tap detection, and an unmatched key passes through while later keys still trigger leader actions; the current tree turns `cat` into a Todoist launch when the root layer is active.
  - Findings: `leader-tap-ignores-mouse`, `leader-unbound-key-stays-live`
  - Source: [review/2026-10-24-0250-full.md](2026-10-24-0250-full.md), 2026-10-24; standing findings from 2026-10-09, reproduced against the current tree.
  - Starting point: observe mouse-down and scroll events to reset tap state; track bound combinations per modal and deactivate on unmatched input. Keep modal-bound keys working regardless of tap/hotkey dispatch order. Validate both trigger keys, modified typing and intentional nested sequences in the running app.
- [TOOLING] `workflow-script-hygiene` — **Make missing link-check input fail and remove the implementation line from start-work usage.** Earlier silent exits, substring claims, scratch-file and queue-list defects were fixed by Docket resyncs; maintained-source cadence is now documented.
  - Findings: `workflow-scripts-cwd-root`, `help-ranges-off`
  - Source: [review/2026-10-24-0250-full.md](2026-10-24-0250-full.md), 2026-10-24; narrows the 2026-10-09 batch to its remaining findings.
  - Starting point: changes belong in the Docket skill, then arrive by resync; never edit `docket/` here. Exercise the link validator from an empty cwd and with an explicit missing file, and inspect `start-work.sh` usage without arguments, under Bash 5 and macOS Bash 3.2.
- [SPOONS] `floatcalendar-follow-spaces` — **Keep calendar keys attached to a calendar the user can see on the current Space.** The default canvas behaviour leaves it on one Space while its global tap remains active.
  - Findings: `floatcalendar-keys-taken-off-space`
  - Source: [review/2026-10-24-0250-full.md](2026-10-24-0250-full.md), 2026-10-24
  - Starting point: first open the calendar and swipe to another Space without typing or clicking; check arrows, R, Escape and leader O,L there. If reproduced, make the canvas join Spaces or dismiss it on a Space change, without a Spaces-aware window filter. Record actual app evidence before choosing a behaviour fix.
- [MODULES] `overlay-follow-spaces` — **Keep overlay dismissal keys scoped to visible UI and preserve the intended window level.** The webview can stay on another Space while Escape is taken globally; the same callback also consumes modified Escape, and `bringToFront(true)` overrides the explicit overlay level.
  - Findings: `overlay-keys-taken-off-space`, `overlay-escape-ignores-modifiers`, `overlay-level-overridden`
  - Source: [review/2026-10-24-0250-full.md](2026-10-24-0250-full.md), 2026-10-24
  - Starting point: first reproduce a Space swipe with the cheatsheet and leader help. Inspect collection behaviour and window level, then choose joining Spaces or dismissal, consume only the intended Escape combination, and retain one intended level. Validate plain and modified Escape against a focused app, repeat toggle, multiple screens and Spaces.

## Unprioritized
