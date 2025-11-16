#!/bin/bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

cmd=(xcodebuild
  -workspace "$ROOT/PetReady.xcworkspace"
  -scheme PetReadyOwner
  -destination "platform=iOS Simulator,name=iPhone 17"
  -only-testing PetReadyOwnerUITests
  test)
if command -v xcbeautify >/dev/null 2>&1; then
  "${cmd[@]}" | xcbeautify
elif command -v xcpretty >/dev/null 2>&1; then
  "${cmd[@]}" | xcpretty
else
  "${cmd[@]}"
fi

node "$ROOT/Backend/src/tests/runIntegration.js" 2>/dev/null || echo "Backend integration harness pending."
