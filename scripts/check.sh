#!/usr/bin/env bash
# Local entry point: run the mechanical gates in order, cheapest first, and
# stop at the first failure, naming the gate. Hooks and CI call the same
# scripts. See docs/QUALITY.md.
set -euo pipefail
cd "$(dirname "$0")/.."

run() {
  local name="$1"; shift
  echo "==> $name"
  if ! "$@"; then
    echo "check: gate '$name' failed ($*)" >&2
    exit 1
  fi
}

run lint bash scripts/lint.sh
run queues bash scripts/workflow/check-queues.sh --strict
run links bash scripts/workflow/check-links.sh
echo "check: all gates passed"
