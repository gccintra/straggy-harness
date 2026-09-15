#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

SOURCE_HARNESS="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
PROJECT="$TEST_ROOT/project"
BIN="$TEST_ROOT/bin"
SCRIPT="$PROJECT/.agents/sync-context.sh"

mkdir -p \
  "$PROJECT/.agents" \
  "$PROJECT/docs/context_docs/_raw/HUs/antiga" \
  "$PROJECT/docs/context_docs/_raw/Regras" \
  "$PROJECT/docs/context_docs/_raw/Outros" \
  "$PROJECT/docs/context_docs/_raw/ReferenciasGlobais" \
  "$BIN"
cp "$SOURCE_HARNESS/sync-context.sh" "$SCRIPT"
chmod +x "$SCRIPT"
printf 'GDRIVE_HUS=fake-folder-id\n' > "$PROJECT/.env"

cat > "$BIN/pandoc" <<'FAKE_PANDOC'
#!/usr/bin/env bash
set -euo pipefail
[ "${FAIL_PANDOC:-0}" = "0" ] || exit 1
input="$1"
shift
out=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -o) out="$2"; shift 2 ;;
    *) shift ;;
  esac
done
cp "$input" "$out"
FAKE_PANDOC
chmod +x "$BIN/pandoc"

run_sync(){
  (
    cd "$PROJECT"
    PATH="$BIN:$PATH" SKIP_RCLONE=1 ./.agents/sync-context.sh >/dev/null
  )
}

RAW="$PROJECT/docs/context_docs/_raw/HUs"
MD="$PROJECT/docs/context_docs/md/HUs"

printf 'versao 1\n' > "$RAW/antiga/Documento.docx"
run_sync
[ -f "$MD/antiga/Documento.md" ]

mkdir -p "$RAW/nova"
mv "$RAW/antiga/Documento.docx" "$RAW/nova/Documento.docx"
rmdir "$RAW/antiga"
run_sync
[ -f "$MD/nova/Documento.md" ]
[ ! -e "$MD/antiga/Documento.md" ]
[ ! -d "$MD/antiga" ]

if (
  cd "$PROJECT"
  PATH="$BIN:$PATH" SKIP_RCLONE=1 FAIL_PANDOC=1 ./.agents/sync-context.sh >/dev/null 2>&1
); then
  echo "esperava falha de conversao" >&2
  exit 1
fi
[ -f "$MD/nova/Documento.md" ]

rm "$RAW/nova/Documento.docx"
rmdir "$RAW/nova"
run_sync
[ ! -e "$MD/nova/Documento.md" ]
[ ! -d "$MD/nova" ]

echo "ok: movimentacao, falha e exclusao reconciliadas"
