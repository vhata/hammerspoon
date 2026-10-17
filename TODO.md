# Deferred work

Ordinary follow-ups and bugs found during other work live here. Whole-codebase review findings promoted for separate work live in [review/BACKLOG.md](review/BACKLOG.md). Follow [docket/TODO_GUIDE.md](docket/TODO_GUIDE.md) before adding, claiming, moving or resolving an entry. Entries in **Ready for separate work** are unblocked and available now; anything with an unresolved `Depends on:` belongs in an earlier stage.

## Needs triage

### P0 Critical

### P1 High

### P2 Normal

### P3 Low

### Unprioritized

- [MODULES] `capture-url-handler` — **Expose quick capture as a `hammerspoon://capture` URL, so a Stream Deck button, a Shortcut or a shell can open the Intake or Books prompt.** Hyper+K and Hyper+B reach it only from the keyboard; a URL handler makes the same code callable from anything that can open a URL.
  - Source: user request after the global-shortcut survey, 2026-10-17
  - Blocked by: PR #30 landing, which adds capture.lua and the Hyper+K and Hyper+B bindings.
  - Starting point: `hs.urlevent.bind("capture", function(_, params) ... end)` calling `capture.prompt(params.vault)`, rejecting an unknown vault with an alert. Decide whether a `text` parameter should create the note directly with no prompt. Stream Deck's Website action can open the URL in the background; `open -g "hammerspoon://capture?vault=Books"` works from a shell. Decide whether the menu-bar Intake shortcut is then replaced or left as it is.
  - Related: `capture-menubar`
- [MODULES] `capture-menubar` — **Add an `hs.menubar` item for quick capture and similar mouse-driven actions, in place of the Intake shortcut's menu-bar entry.** The Shortcuts menu-bar entry reaches only the Personal vault, and a Hammerspoon menu can offer Personal and Books from the same code the hotkeys use.
  - Source: user request after the global-shortcut survey, 2026-10-17
  - Blocked by: PR #30 landing, which adds capture.lua.
  - Starting point: one module-level `hs.menubar.new()` (held against garbage collection) with a menu built from a list of labelled actions, the way the leader tree is a list of items. Decide what else belongs in it (overlays, the leader help) and whether the menu, like the help, is generated from what is actually bound.
  - Related: `capture-url-handler`

## Needs proof of concept

### P0 Critical

### P1 High

### P2 Normal

### P3 Low

### Unprioritized

## Ready for separate work

### P0 Critical

### P1 High

### P2 Normal

### P3 Low

### Unprioritized

- [CONFIG] `enable-ipc` — **Load `hs.ipc` so the `hs` command-line tool can run Lua in the live Hammerspoon.** The CLI is already installed at `/opt/homebrew/bin/hs` but cannot connect without the module, and with it an agent could reload the config, call functions such as `hotkeys.list()` and read the console instead of handing every behaviour check to the user.
  - Source: user request after the global-shortcut survey, 2026-10-17
  - Starting point: `require("hs.ipc")` early in `init.lua`, right after the reload watcher and inside a `pcall`, so the CLI still works when a later module fails to load. Then update the Verification line in `AGENTS.md` and the test policy in `docs/QUALITY.md` to say what agents may run through `hs -c` (read-only queries, reload, or anything) and that the live instance only ever runs `main`.
  - Trade-off to record in `docs/DECISIONS.md`: any process running as the user can then execute Lua inside Hammerspoon, which holds the Accessibility grant (synthetic keystrokes, reading other apps' windows).
