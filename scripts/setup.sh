#!/usr/bin/env bash
# Install the tracked git hooks. Idempotent; run once after cloning. The
# hooks path is shared by every worktree of this clone.
set -euo pipefail
cd "$(dirname "$0")/.."

git config core.hooksPath .githooks

echo "setup: done. Run 'bash scripts/check.sh' to verify the baseline."
