#!/usr/bin/env bash
# Regenera o runtime quando a fonte do harness mudou (HRN-017). Chamado pelos hooks do Git
# desta pasta — ligados pelo install.sh com `git config core.hooksPath .githooks`.
#
#   _runtime.sh <gancho> [--sempre]   → sai com o código do build (0 ok, 3 contrato)
#
# --sempre (pre-commit): roda o build mesmo em dia — o commit precisa da validação do
# contrato, não só do frescor. Sem a flag, em dia: silêncio. Desatualizado: roda o build e avisa em uma linha no terminal do Git.
set -uo pipefail

GANCHO="${1:-git}"
HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG="$HARNESS_DIR/runtime/.build.log"

if [ "${2:-}" != --sempre ]; then
  "$HARNESS_DIR/build.sh" --check >/dev/null 2>&1 && exit 0
fi

"$HARNESS_DIR/build.sh" >"$LOG" 2>&1
codigo=$?
if [ "$codigo" = 0 ]; then
  [ "${2:-}" = --sempre ] || echo "harness ($GANCHO): fonte mudou — runtime regenerado."
else
  echo "harness ($GANCHO): runtime regenerado, mas o contrato reprovou (código $codigo). Veja runtime/.build.log." >&2
fi
exit "$codigo"
