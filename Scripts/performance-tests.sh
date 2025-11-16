#!/bin/bash
set -euo pipefail

echo "⚡ Running performance smoke tests"
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT/Backend"
npx autocannon --connections 50 --duration 15 http://localhost:3001/health || echo "Start backend before running load tests."
