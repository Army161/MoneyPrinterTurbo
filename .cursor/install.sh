#!/usr/bin/env bash
# Idempotent Cloud Agent setup for MoneyPrinterTurbo.
# Prepares system media tooling, the uv-managed Python 3.11 toolchain, and the
# locked virtual environment. Safe to run repeatedly and against cached state.
set -euo pipefail

cd "$(dirname "$0")/.."

# 1. System dependencies. ffmpeg powers the media pipeline; redis-server backs
#    the optional distributed task queue and mirrors the CI service. git/curl
#    are already present in the base image but are cheap to assert.
export DEBIAN_FRONTEND=noninteractive
if ! command -v ffmpeg >/dev/null 2>&1 || ! command -v redis-server >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo apt-get install -y -qq --no-install-recommends ffmpeg redis-server
fi

# 2. uv toolchain. Install once, then reuse the cached binary on later runs.
export PATH="$HOME/.local/bin:$PATH"
if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# 3. Python runtime + locked dependencies. The repo pins Python 3.11 and uv.lock
#    fixes the resolved environment, so use --frozen to match CI exactly.
uv python install 3.11
uv sync --frozen

echo "MoneyPrinterTurbo environment ready."
