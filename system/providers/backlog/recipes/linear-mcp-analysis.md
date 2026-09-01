# Export do Linear para análise — código de referência

Procedural (GraphQL/jq). O contrato do que produzir está no SKILL.md. O cálculo do funil
está em `analise-funil.md` — este arquivo só produz o CSV que ele consome.

**Nada aqui decora funil.** Faixas, dimensões, cortes, ordenação e rótulos saem do encaixe
`funil` da ação `priorizar-backlog` (schema `system/schemas/funil-priorizacao.yaml`). Leia a
instância e preencha o bloco de constantes da §1 antes de rodar qualquer coisa.

Transporte e autenticação: `linear-mcp.md` §1 e §8. O `LINEAR_API_KEY` é o que mantém o
backlog **fora do contexto do modelo** — sem ele, use a rota MCP (`linear-mcp.md` §8.2) e
avise o custo.

## 1. Constantes — transcritas do funil

```bash
# --- de `binding` no funil ---
PREFIXO_TIPO="<prefixo do rótulo de tipo>"          # ex: "TIPO::" ou "Tipo/"
PREFIXO_TRIAGEM="<prefixo do rótulo da etapa de triagem>"
PREFIXO_FAIXA="<prefixo do rótulo da etapa de faixa>"
ROTULOS_FILA="<rótulo1>|<rótulo2>"                  # binding.fila, separados por |
BLOCO_DIMENSOES="<identificador do bloco na descrição>"   # quando modo = bloco-na-descricao

# --- de `etapas` no funil ---
DIMENSOES='["<Dim1>","<Dim2>","<Dim3>"]'
FAIXAS_TRIAGEM="<FAIXA1>|<FAIXA2>|<FAIXA3>|<FAIXA4>"

RE_LINHA="\\|\\s*\\*{0,2}(?<t>${FAIXAS_TRIAGEM})\\*{0,2}\\s*\\|(?<resto>[^\\n]*)"
```

No Linear o rótulo pode ser **agrupado** (grupo pai + filha) em vez de prefixado. O funil lê
o prefixo declarado — se a instância usa grupos, o `name` que a API devolve é só o da filha:
declare no `binding` o prefixo vazio e trate o grupo como rótulo de fila, ou renomeie as
filhas com o prefixo. O código abaixo não conhece nenhum dos dois nomes.

## 2. Exportar — uma passada paginada, direto para arquivo

```bash
export LINEAR_API_KEY LINEAR_TEAM
export DADOS="$(...)"     # caminhos.dados do project-config.yaml — nunca literal

# Escopo: abertas do time. Para uma sprint, some ao filter: , cycle:{number:{eq:<N>}}
FILTER='{team:{key:{eq:$team}}, state:{type:{nin:["completed","canceled"]}}}'

AFTER=null
: > "${DADOS}linear_raw.ndjson"
while :; do
  RESP=$(curl -s https://api.linear.app/graphql \
    -H "Content-Type: application/json" \
    -H "Authorization: ${LINEAR_API_KEY}" \
    --data @<(jq -n --arg team "$LINEAR_TEAM" --argjson after "$AFTER" --arg f "$FILTER" '{
      query: ("query($team:String!,$after:String){issues(first:250,after:$after,filter:" + $f + "){pageInfo{hasNextPage endCursor} nodes{identifier title description priority estimate createdAt updatedAt completedAt canceledAt state{name type} labels{nodes{name}} cycle{number name} project{name} assignee{displayName} creator{displayName}}}}"),
      variables: {team: $team, after: $after}}'))
  if [ "$(echo "$RESP" | jq -r 'has("errors")')" = "true" ]; then
    echo "$RESP" | jq -r '.errors[0].message'; break     # erro do Linear vem com HTTP 200
  fi
  echo "$RESP" | jq -c '.data.issues.nodes[]' >> "${DADOS}linear_raw.ndjson"
  [ "$(echo "$RESP" | jq -r '.data.issues.pageInfo.hasNextPage')" = "true" ] || break
  AFTER=$(echo "$RESP" | jq '.data.issues.pageInfo.endCursor')
done
wc -l "${DADOS}linear_raw.ndjson"
```

Converter para o CSV que `analise-funil.md` espera — mesmas colunas, mesma ordem:

```bash
jq -r -s \
  --arg   ptipo "$PREFIXO_TIPO" \
  --arg   ptri  "$PREFIXO_TRIAGEM" \
  --arg   pfai  "$PREFIXO_FAIXA" \
  --arg   fila  "$ROTULOS_FILA" \
  --arg   re    "$RE_LINHA" \
  --argjson dims "$DIMENSOES" '
  def celulas:
    (if .description then ((.description | capture($re)) // null) else null end)
    | if . == null then null
      else { t: .t,
             v: (.resto | split("|")
                        | map(gsub("\\*"; "") | gsub("^\\s+|\\s+$"; ""))) }
      end;
  def rots: (.labels.nodes | map(.name));
  def rotulo($p): (rots | map(select(startswith($p)))
                        | if length > 0 then .[0] else "" end);

  ($fila | split("|")) as $filas
  | (["IID","Titulo","Estado","Tipo","Faixa_Label","Triagem_Label","Triagem_Desc","Score"]
     + $dims
     + ["Workflow","Milestone","Assignee","Autor","Criada","Atualizada","Weight","Labels_Todas"]),
    (.[]
     | celulas as $c
     | [
      .identifier,
      .title,
      (if (.state.type == "completed" or .state.type == "canceled") then "closed" else "opened" end),
      (rotulo($ptipo) | if . == "" then "SEM TIPO" else . end),
      (rotulo($pfai)  | if . == "" then "SEM FAIXA" else . end),
      rotulo($ptri),
      (if $c then $c.t else "" end)
    ]
    + [ (if $c then ($c.v[($dims | length)] // "") else "" end) ]   # score registrado
    + [ range(0; ($dims | length)) as $i
        | (if $c then ($c.v[$i] // "") else "" end) ]
    + [
      (rots | map(select(
        (startswith($ptipo) or startswith($pfai) or startswith($ptri)
         or (. as $l | $filas | index($l) != null)) | not)) | join("|")),
      (if .cycle then (.cycle.name // ("Ciclo " + (.cycle.number|tostring))) else "" end),
      (if .assignee then .assignee.displayName else "" end),
      (if .creator then .creator.displayName else "" end),
      .createdAt,
      .updatedAt,
      (if .estimate then .estimate else "" end),
      (rots | join("|"))
    ] | @csv)
  ' "${DADOS}linear_raw.ndjson" > "${DADOS}issues_$(date +%Y-%m-%d).csv"
```

Diferenças de vocabulário já resolvidas acima, sem tocar no cálculo:
`identifier` → `IID` · `state.type` → `Estado` (`opened`/`closed`) · `cycle` → `Milestone` ·
`estimate` → `Weight` · `creator` → `Autor`.

Verificar antes de prosseguir:
```bash
wc -l "${DADOS}issues_$(date +%Y-%m-%d).csv"   # deve ser > 1
head -2 "${DADOS}issues_$(date +%Y-%m-%d).csv"
```

Zero linhas com o NDJSON cheio = prefixo de rótulo errado na §1, não falha de API.

---

## 3. Analisar

Com o CSV gerado, siga **`analise-funil.md`** — cálculo de score, bandas, anomalias,
ranking e markdown do relatório. Esse trecho roda sobre o arquivo local e não conhece
ferramenta; o que é do Linear acaba aqui.
