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
#   GDRIVE_HUS=<FOLDER_ID>                             (ID puro da pasta das HUs no Drive; script monta o remote)
#   GDRIVE_REGRAS_DOC_ID=<DOC_ID_1> <DOC_ID_2> ...     (1+ Google Docs de Regras de Negocio, separados por espaco)
#   GDRIVE_REFERENCIAS_GLOBAIS_DOC_ID=<DOC_ID>         (opcional; 1 Google Doc — sempre vira Referencias-Globais.md, nome fixo)
#   GDRIVE_OUTROS=gdrive,root_folder_id=<FOLDER_ID>:   (opcional; pasta de contexto diverso — persona, glossario, decisoes, etc.)
get_env(){ grep -E "^$1=" .env 2>/dev/null | head -1 | cut -d= -f2- | sed -e "s/^['\"]//" -e "s/['\"]\$//"; }
GDRIVE_HUS="$(get_env GDRIVE_HUS)"
GDRIVE_REGRAS_DOC_ID="$(get_env GDRIVE_REGRAS_DOC_ID)"
GDRIVE_REFERENCIAS_GLOBAIS_DOC_ID="$(get_env GDRIVE_REFERENCIAS_GLOBAIS_DOC_ID)"
GDRIVE_OUTROS="$(get_env GDRIVE_OUTROS)"
if [ -z "$GDRIVE_HUS" ]; then
  log "GDRIVE_HUS vazio no .env — configure os IDs do Drive deste projeto. Abortando."
  exit 1
fi
# .env guarda so o folder ID puro; aqui monta a string de remote do rclone.
GDRIVE_HUS_REMOTE="gdrive,root_folder_id=$GDRIVE_HUS:"
# ---------------------------------------------------------------------------

# Converte uma arvore src -> dest, espelhando subpastas.
# docx/pdf -> .md (conversao real). Qualquer outro formato -> copia como esta
# (extensao original preservada) — nada fica preso em _raw/ sem chegar em md/,
# onde os agentes de fato leem o contexto.
convert_tree(){
  local src="$1" dest="$2"
  [ -d "$src" ] || { log "skip convert: $src nao existe"; return 0; }
  find "$src" -type f ! -name '~$*' -print0 |
  while IFS= read -r -d '' f; do
    local rel="${f#"$src"/}"
    case "$(printf '%s' "$f" | tr '[:upper:]' '[:lower:]')" in
      *.docx)
        local out="$dest/${rel%.*}.md"
        mkdir -p "$(dirname "$out")"
        pandoc "$f" -f docx -t gfm -o "$out" 2>/dev/null && log "docx  -> $rel" ;;
      *.pdf)
        local out="$dest/${rel%.*}.md"
        mkdir -p "$(dirname "$out")"
        pdftotext -layout "$f" "$out" && log "pdf   -> $rel" ;;
      *)
        local out="$dest/$rel"
        mkdir -p "$(dirname "$out")"
        cp "$f" "$out" && log "copia -> $rel" ;;
    esac
  done
}

# Converte 1 arquivo (docx/pdf) de um dir p/ um destino de nome FIXO — usado
# quando o nome final nao pode depender do titulo do doc no Drive.
convert_single(){
  local dir="$1" out="$2"
  local f
  f="$(find "$dir" -maxdepth 1 -type f \( -iname '*.docx' -o -iname '*.pdf' \) ! -name '~$*' 2>/dev/null | head -1)"
  [ -n "$f" ] || { log "skip convert: $dir vazio"; return 0; }
  mkdir -p "$(dirname "$out")"
  case "$(printf '%s' "$f" | tr '[:upper:]' '[:lower:]')" in
    *.docx) pandoc "$f" -f docx -t gfm -o "$out" 2>/dev/null && log "docx -> $(basename "$out")" ;;
    *.pdf)  pdftotext -layout "$f" "$out"          && log "pdf  -> $(basename "$out")" ;;
  esac
}

# --- 1. Espelha Drive -> _raw ---------------------------------------------
if [ "${SKIP_RCLONE:-0}" != "1" ]; then
  log "rclone sync HU's"
  rclone sync "$GDRIVE_HUS_REMOTE"    "$RAW/HUs"    --drive-export-formats docx,pptx,xlsx,pdf
  if [ -n "$GDRIVE_REGRAS_DOC_ID" ]; then
    log "export docs Regras ($(echo "$GDRIVE_REGRAS_DOC_ID" | wc -w | tr -d ' ') arquivo(s))"
    rm -rf "$RAW/Regras"; mkdir -p "$RAW/Regras"
    for doc_id in $GDRIVE_REGRAS_DOC_ID; do
      rclone backend copyid gdrive: "$doc_id" "$RAW/Regras/" --drive-export-formats docx
    done
  else
    log "GDRIVE_REGRAS_DOC_ID vazio -> pulando Regras"
  fi
  if [ -n "$GDRIVE_REFERENCIAS_GLOBAIS_DOC_ID" ]; then
    log "export doc Referencias Globais"
    rm -rf "$RAW/ReferenciasGlobais"; mkdir -p "$RAW/ReferenciasGlobais"
    rclone backend copyid gdrive: "$GDRIVE_REFERENCIAS_GLOBAIS_DOC_ID" "$RAW/ReferenciasGlobais/" --drive-export-formats docx
  else
    log "GDRIVE_REFERENCIAS_GLOBAIS_DOC_ID vazio -> pulando Referencias Globais"
  fi
  if [ -n "$GDRIVE_OUTROS" ]; then
    log "rclone sync Outros"
    rclone sync "$GDRIVE_OUTROS" "$RAW/Outros" --drive-export-formats docx,pptx,xlsx,pdf
  else
    log "GDRIVE_OUTROS vazio -> pulando Outros"
  fi
else
  log "SKIP_RCLONE=1 -> pulando download, convertendo _raw existente"
fi

# --- 2. Converte _raw -> md ------------------------------------------------
convert_tree "$RAW/HUs"    "$MD/HUs"
convert_tree "$RAW/Regras" "$MD/Regras"
convert_tree "$RAW/Outros" "$MD/Outros"
convert_single "$RAW/ReferenciasGlobais" "$MD/Referencias-Globais.md"

log "sync-context concluido"
