#!/bin/bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

echo "🔧 Ensuring Homebrew dependencies"
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required for installing tooling."
else
  brew bundle --file="$ROOT/Brewfile" --no-lock || true
fi

echo "📦 Installing backend dependencies"
cd "$ROOT"
npm install

if [[ ! -f "$ROOT/.env" ]]; then
  cp .env.example .env 2>/dev/null || true
fi

cd "$ROOT/SharedCode"
swift package resolve

echo "✅ Development environment ready"
