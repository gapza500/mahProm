#!/bin/bash
set -euo pipefail

echo "🚧 Building PetReady Shared Module"
cd "$(git rev-parse --show-toplevel)/SharedCode"
swift build

cd "$(git rev-parse --show-toplevel)"
declare -a apps=("Owner" "VetPro" "Rider" "CentralAdmin")
for app in "${apps[@]}"; do
  echo "📱 Building PetReady-${app} (Debug)"
  cmd=(xcodebuild
    -workspace PetReady.xcworkspace
    -scheme "PetReady${app}"
    -configuration Debug
    -destination "platform=iOS Simulator,name=iPhone 17"
    build)
  if command -v xcbeautify >/dev/null 2>&1; then
    "${cmd[@]}" | xcbeautify
  elif command -v xcpretty >/dev/null 2>&1; then
    "${cmd[@]}" | xcpretty
  else
    "${cmd[@]}"
  fi
  echo "✅ Completed build for PetReady-${app}"
done
