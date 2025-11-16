#!/bin/bash
set -euo pipefail

if [[ -z "${PETREADY_ENV:-}" ]]; then
  echo "Please set PETREADY_ENV (staging|production)"
  exit 1
fi

echo "🚀 Deploying backend to $PETREADY_ENV"
cd "$(git rev-parse --show-toplevel)/Backend"
npm install
npm run build --if-present
npm run start --if-present

echo "🚀 Triggering Fastlane lanes for iOS apps"
cd "$(git rev-parse --show-toplevel)"
for lane in owner vetpro rider admin; do
  echo "fastlane ios $lane environment:$PETREADY_ENV"
  # Placeholder: integrate Fastlane once lanes exist
  sleep 1
  echo "✅ Completed placeholder deploy for $lane"
done
