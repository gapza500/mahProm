#!/bin/bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

echo "🧪 Running SharedCode unit tests"
cd "$ROOT/SharedCode"
swift test

cd "$ROOT"
declare -a schemes=(
  "PetReadyOwner"
  "PetReadyVetPro"
  "PetReadyRider"
  "PetReadyCentralAdmin"
)

for scheme in "${schemes[@]}"; do
  echo "🧪 Running tests for $scheme"
  cmd=(xcodebuild
    -workspace PetReady.xcworkspace
    -scheme "$scheme"
    -configuration Debug
    -destination "platform=iOS Simulator,name=iPhone 17"
    test)
  if command -v xcbeautify >/dev/null 2>&1; then
    "${cmd[@]}" | xcbeautify
  elif command -v xcpretty >/dev/null 2>&1; then
    "${cmd[@]}" | xcpretty
  else
    "${cmd[@]}"
  fi
  echo "✅ Tests finished for $scheme"
done
