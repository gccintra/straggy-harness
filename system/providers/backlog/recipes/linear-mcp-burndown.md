# Export do Linear para métricas e burndown — código de referência

Procedural (GraphQL/jq). O contrato do relatório está no SKILL.md. As métricas e o HTML do
burndown estão em `burndown-local.md` — este arquivo só produz o CSV e a janela da sprint.

Transporte e autenticação: `linear-mcp.md` §1 e §8. Sem `LINEAR_API_KEY`, a rota é a MCP
(`linear-mcp.md` §8.2), que passa pelo contexto — avise o custo antes.

## 1. Escopo

| Escopo | Filtro GraphQL |
|---|---|
| backlog completo (abertas e fechadas) | `{team:{key:{eq:$team}}}` |
| só abertas | `{team:{key:{eq:$team}}, state:{type:{nin:["completed","canceled"]}}}` |
| uma sprint | `{team:{key:{eq:$team}}, cycle:{number:{eq:<N>}}}` |

O burndown exige o escopo de sprint: a linha real sai da data de conclusão de cada demanda,
que só faz sentido dentro da janela do ciclo.

## 2. Exportar

```bash
export LINEAR_API_KEY LINEAR_TEAM
export DADOS="$(...)"     # caminhos.dados do project-config.yaml

FILTER='{team:{key:{eq:$team}}}'          # troque conforme a tabela da §1

AFTER=null
: > "${DADOS}linear_raw.ndjson"
while :; do
  RESP=$(curl -s https://api.linear.app/graphql \
    -H "Content-Type: application/json" \
    -H "Authorization: ${LINEAR_API_KEY}" \
    --data @<(jq -n --arg team "$LINEAR_TEAM" --argjson after "$AFTER" --arg f "$FILTER" '{
      query: ("query($team:String!,$after:String){issues(first:250,after:$after,filter:" + $f + "){pageInfo{hasNextPage endCursor} nodes{identifier title priority estimate createdAt updatedAt completedAt canceledAt state{name type} labels{nodes{name}} cycle{number name} project{name} assignee{displayName} creator{displayName}}}}"),
      variables: {team: $team, after: $after}}'))
  if [ "$(echo "$RESP" | jq -r 'has("errors")')" = "true" ]; then
    echo "$RESP" | jq -r '.errors[0].message'; break
  fi
  echo "$RESP" | jq -c '.data.issues.nodes[]' >> "${DADOS}linear_raw.ndjson"
  [ "$(echo "$RESP" | jq -r '.data.issues.pageInfo.hasNextPage')" = "true" ] || break
  AFTER=$(echo "$RESP" | jq '.data.issues.pageInfo.endCursor')
done
```

CSV com as colunas que `burndown-local.md` espera:

```bash
PREFIXO_PRIORIDADE="PRIORIDADE::"     # ajuste à taxonomia do projeto (list_issue_labels)

jq -r -s --arg pprio "$PREFIXO_PRIORIDADE" '
  def rots: (.labels.nodes | map(.name));
  ["IID","Título","Estado","Tipo","Labels","Prioridade","Milestone","Assignee","Autor","Criada em","Atualizada em","Fechada em","Weight"],
  (.[] | [
    .identifier,
    .title,
    (if (.state.type == "completed" or .state.type == "canceled") then "closed" else "opened" end),
    .state.name,
    (rots | join("|")),
    (rots | map(select(startswith($pprio))) | if length > 0 then .[0] else "" end),
    (if .cycle then (.cycle.name // ("Ciclo " + (.cycle.number|tostring))) else "" end),
    (if .assignee then .assignee.displayName else "" end),
    (if .creator then .creator.displayName else "" end),
    .createdAt,
    .updatedAt,
    (.completedAt // .canceledAt // ""),
    (if .estimate then .estimate else "" end)
  ] | @csv)
  ' "${DADOS}linear_raw.ndjson" > "${DADOS}issues_$(date +%Y-%m-%d).csv"
```

`Tipo` aqui é o **status do workflow** (`state.name`) — no Linear não há `issue_type`; o
tipo de demanda, quando a organização usa um, é rótulo e sai em `Labels`.

Verificar:
```bash
wc -l "${DADOS}issues_$(date +%Y-%m-%d).csv"   # 0 ou 1 linha = export falhou
head -3 "${DADOS}issues_$(date +%Y-%m-%d).csv"
```

## 3. Datas da sprint (só quando o escopo é uma sprint)

O ciclo carrega a janela; o CSV não. Pelo MCP (`linear-mcp.md` §7):

```
get_team(query: "$LINEAR_TEAM")                    # UUID
list_cycles(teamId: "<uuid>", type: "current")     # startsAt / endsAt / number
```

Ou no mesmo transporte do export:

```bash
curl -s https://api.linear.app/graphql \
  -H "Content-Type: application/json" -H "Authorization: ${LINEAR_API_KEY}" \
  --data @<(jq -n --arg team "$LINEAR_TEAM" '{query:("query($team:String!){cycles(filter:{team:{key:{eq:$team}}}){nodes{number name startsAt endsAt completedAt}}}"),variables:{team:$team}}') \
  | jq '.data.cycles.nodes'
```

## 4. Analisar e gerar o burndown

Com o CSV e a janela em mãos, siga **`burndown-local.md`** — métricas de volume,
distribuição, saúde, score do backlog e o HTML do burndown. Nada do Linear a partir daí.
