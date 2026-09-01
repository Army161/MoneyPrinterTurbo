#!/usr/bin/env bash
# Per-boot startup reconciliation for the Cloud Agent.
#
# Runs on every environment start (after install). Brings up the local Redis
# instance used by the optional distributed task queue and waits until it is
# ready before returning. Idempotent: it no-ops if Redis is already responding,
# so repeated boots and restarts are safe. Dependency installation lives in
# install.sh, not here; the API and WebUI dev servers live in the terminals.
set -euo pipefail

if redis-cli ping >/dev/null 2>&1; then
  echo "Redis already running."
  exit 0
fi

# Daemonize so this startup command returns promptly. Disable persistence: this
# is an ephemeral dev cache, not durable state.
redis-server --bind 127.0.0.1 --port 6379 --daemonize yes --save "" --appendonly no

for _ in $(seq 1 20); do
  if redis-cli ping >/dev/null 2>&1; then
    echo "Redis started and ready on 127.0.0.1:6379."
    exit 0
  fi
  sleep 0.5
done

echo "Redis did not become ready in time." >&2
exit 1
