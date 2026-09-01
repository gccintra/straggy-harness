# Export e análise — código de referência

Procedural (jq/python). O contrato do que produzir está no SKILL.md.

**Nada aqui decora funil.** Faixas, dimensões, cortes, ordenação e rótulos do backlog saem
do encaixe `funil` da ação `priorizar-backlog` (schema
`system/schemas/funil-priorizacao.yaml`). Leia a instância e preencha o bloco de constantes
da §1 antes de rodar qualquer coisa.

## 1. Constantes — transcritas do funil

```bash
# --- de `binding` no funil ---
PREFIXO_TIPO="<prefixo do rótulo de tipo, com ::>"
PREFIXO_TRIAGEM="<prefixo do rótulo da etapa de triagem, com ::>"
PREFIXO_FAIXA="<prefixo do rótulo da etapa de faixa, com ::>"
ROTULOS_FILA="<rótulo1>|<rótulo2>"      # binding.fila, separados por |
BLOCO_DIMENSOES="<identificador do bloco na descrição>"   # quando modo = bloco-na-descricao

# --- de `etapas` no funil ---
DIMENSOES='["<Dim1>","<Dim2>","<Dim3>"]'                  # ids/rótulos das escalas, na ordem da tabela
FAIXAS_TRIAGEM="<FAIXA1>|<FAIXA2>|<FAIXA3>|<FAIXA4>"      # ids da triagem, na ordem de precedência

# Linha do bloco de dimensões: célula da triagem, depois uma célula por dimensão e o score.
RE_LINHA="\\|\\s*\\*{0,2}(?<t>${FAIXAS_TRIAGEM})\\*{0,2}\\s*\\|(?<resto>[^\\n]*)"
```

Funil sem etapa de triagem, ou com outro número de dimensões, muda só este bloco — o resto
do código não conhece nome nenhum.

---

## 2. Exportar — uma única chamada à API

> **`DADOS`** é o diretório de export do projeto — `caminhos.dados` do `project-config.yaml`.
> Exporte antes de rodar os blocos abaixo: `export DADOS="$(...)"`. Nunca escreva o caminho literal.

**Princípio:** toda a análise roda sobre o CSV local. Zero chamadas adicionais à API.

```bash
export GITLAB_HOST GITLAB_URI GITLAB_TOKEN GITLAB_REPO
REPO_ENCODED="${GITLAB_REPO//\//\%2F}"

# Montar filtros opcionais
MILESTONE_PARAM=""
if [ -n "$MILESTONE_NAME" ]; then
  MILESTONE_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$MILESTONE_NAME'))")
  MILESTONE_PARAM="&milestone=${MILESTONE_ENCODED}"
fi

glab api --paginate \
  "projects/${REPO_ENCODED}/issues?per_page=100&state=opened${MILESTONE_PARAM}" \
  --hostname "${GITLAB_HOST}" \
  | jq -r \
      --arg   ptipo "$PREFIXO_TIPO" \
      --arg   ptri  "$PREFIXO_TRIAGEM" \
      --arg   pfai  "$PREFIXO_FAIXA" \
      --arg   fila  "$ROTULOS_FILA" \
      --arg   re    "$RE_LINHA" \
      --argjson dims "$DIMENSOES" '
    # Células do bloco de dimensões: triagem na primeira, depois uma por dimensão, score no fim.
    def celulas:
      (if .description then ((.description | capture($re)) // null) else null end)
      | if . == null then null
        else { t: .t,
               v: (.resto | split("|")
                          | map(gsub("\\*"; "") | gsub("^\\s+|\\s+$"; ""))) }
        end;

    def rotulo($p): (.labels | map(select(startswith($p)))
                             | if length > 0 then .[0] else "" end);

    ($fila | split("|")) as $filas
    | (["IID","Titulo","Estado","Tipo","Faixa_Label","Triagem_Label","Triagem_Desc","Score"]
       + $dims
       + ["Workflow","Milestone","Assignee","Autor","Criada","Atualizada","Weight","Labels_Todas"]),
      (.[]
       | celulas as $c
       | [
        .iid,
        .title,
        .state,
        (rotulo($ptipo) | if . == "" then "SEM TIPO" else . end),
        (rotulo($pfai)  | if . == "" then "SEM FAIXA" else . end),
        rotulo($ptri),
        (if $c then $c.t else "" end)
      ]
      + [ (if $c then ($c.v[($dims | length)] // "") else "" end) ]   # score registrado
      + [ range(0; ($dims | length)) as $i
          | (if $c then ($c.v[$i] // "") else "" end) ]
      + [
        # Workflow: rótulos que não são de tipo, faixa, triagem nem de fila
        (.labels | map(select(
          (startswith($ptipo) or startswith($pfai) or startswith($ptri)
           or (. as $l | $filas | index($l) != null)) | not)) | join("|")),
        (if .milestone then .milestone.title else "" end),
        (if .assignees and (.assignees | length) > 0 then .assignees[0].username else "" end),
        .author.username,
        .created_at,
        .updated_at,
        (if .weight then .weight else "" end),
        (.labels | join("|"))
      ] | @csv)
  ' > "${DADOS}issues_$(date +%Y-%m-%d).csv"
```

Verificar antes de prosseguir:
```bash
wc -l "${DADOS}issues_$(date +%Y-%m-%d).csv"   # deve ser > 1
head -2 "${DADOS}issues_$(date +%Y-%m-%d).csv"
```

---

## 3. Analisar

Com o CSV gerado, siga **`analise-funil.md`** — cálculo de score, bandas, anomalias,
ranking e markdown do relatório. Esse trecho roda sobre o arquivo local e não conhece
ferramenta; o que é do GitLab acaba aqui.
