#!/usr/bin/env bash
# Per-boot runtime reconciliation. Starts the local Redis instance used by the
# optional distributed task queue. Idempotent: it exits cleanly if Redis is
# already responding. Dependency installation lives in install.sh, not here.
set -euo pipefail

if redis-cli ping >/dev/null 2>&1; then
  echo "Redis already running."
  exit 0
fi

redis-server --daemonize yes --save "" --appendonly no

for _ in $(seq 1 20); do
  if redis-cli ping >/dev/null 2>&1; then
    echo "Redis started."
    exit 0
  fi
  sleep 0.5
done

echo "Redis did not become ready in time." >&2
exit 1
