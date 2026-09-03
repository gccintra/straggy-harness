#!/usr/bin/env bash
# Porta de entrada do build. A máquina mora em runtime/build.sh — este arquivo só encaminha.
set -euo pipefail
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/runtime/build.sh" "$@"
