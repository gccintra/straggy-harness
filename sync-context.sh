#!/usr/bin/env bash
# Sincroniza HU's + Regras do Google Drive e converte docx/pdf -> markdown.
# Fonte de verdade: Drive. md/ e _raw/ sao cache derivado.
set -euo pipefail

# O script vive no harness (.agents/), mas opera na raiz do projeto consumidor:
# .env, docs/context_docs/ e sync.log sao do projeto, nao do harness.
# O install.sh cria um symlink na raiz do projeto, e $0 nao resolve symlink —
# sem desreferenciar, o `..` subiria um nivel acima do projeto.
SCRIPT="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT" ]; do
  LINK_DIR="$(cd "$(dirname "$SCRIPT")" && pwd)"
  SCRIPT="$(readlink "$SCRIPT")"
  [[ "$SCRIPT" != /* ]] && SCRIPT="$LINK_DIR/$SCRIPT"
done
HARNESS_DIR="$(cd "$(dirname "$SCRIPT")" && pwd)"
cd "$HARNESS_DIR/.."

BASE="docs/context_docs"
RAW="$BASE/_raw"
MD="$BASE/md"

LOG_FILE="sync.log"
log(){ echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

# --- Remotes do Drive (configure por projeto no .env) ----------------------
# IDs lidos do .env do projeto. Leitura por grep (nao 'source') p/ nao quebrar
# com valores que tem espaco/aspas (ex: DB_CONNECT_CMD).
#   GDRIVE_HUS=gdrive,root_folder_id=<FOLDER_ID>:     (pasta das HUs no Drive)
#   GDRIVE_REGRAS_DOC_ID=<DOC_ID>                      (Google Doc unico de Regras)
get_env(){ grep -E "^$1=" .env 2>/dev/null | head -1 | cut -d= -f2- | sed -e "s/^['\"]//" -e "s/['\"]\$//"; }
GDRIVE_HUS="$(get_env GDRIVE_HUS)"
GDRIVE_REGRAS_DOC_ID="$(get_env GDRIVE_REGRAS_DOC_ID)"
if [ -z "$GDRIVE_HUS" ]; then
  log "GDRIVE_HUS vazio no .env — configure os IDs do Drive deste projeto. Abortando."
  exit 1
fi
# ---------------------------------------------------------------------------

# Converte uma arvore src -> dest, espelhando subpastas, docx/pdf -> .md
convert_tree(){
  local src="$1" dest="$2"
  [ -d "$src" ] || { log "skip convert: $src nao existe"; return 0; }
  find "$src" -type f \( -iname '*.docx' -o -iname '*.pdf' \) ! -name '~$*' -print0 |
  while IFS= read -r -d '' f; do
    local rel="${f#"$src"/}"
    local out="$dest/${rel%.*}.md"
    mkdir -p "$(dirname "$out")"
    case "$(printf '%s' "$f" | tr '[:upper:]' '[:lower:]')" in
      *.docx) pandoc "$f" -f docx -t gfm -o "$out" 2>/dev/null && log "docx -> $rel" ;;
      *.pdf)  pdftotext -layout "$f" "$out"          && log "pdf  -> $rel" ;;
    esac
  done
}

# --- 1. Espelha Drive -> _raw ---------------------------------------------
if [ "${SKIP_RCLONE:-0}" != "1" ]; then
  log "rclone sync HU's"
  rclone sync "$GDRIVE_HUS"    "$RAW/HUs"    --drive-export-formats docx,pdf
  if [ -n "$GDRIVE_REGRAS_DOC_ID" ]; then
    log "export doc Regras (arquivo unico)"
    rm -rf "$RAW/Regras"; mkdir -p "$RAW/Regras"
    rclone backend copyid gdrive: "$GDRIVE_REGRAS_DOC_ID" "$RAW/Regras/" --drive-export-formats docx
  else
    log "GDRIVE_REGRAS_DOC_ID vazio -> pulando Regras"
  fi
else
  log "SKIP_RCLONE=1 -> pulando download, convertendo _raw existente"
fi

# --- 2. Converte _raw -> md ------------------------------------------------
convert_tree "$RAW/HUs"    "$MD/HUs"
convert_tree "$RAW/Regras" "$MD/Regras"

log "sync-context concluido"
