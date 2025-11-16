#!/bin/bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

echo "🛡️ Running npm audit"
cd "$ROOT"
npm audit || true

echo "🔍 Running Swift lint placeholder"
if command -v swiftlint >/dev/null 2>&1; then
  swiftlint
else
  echo "SwiftLint not installed; skipping."
fi
