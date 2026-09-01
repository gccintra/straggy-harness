---
selecao: linear
capacidades: [core, comments, description-block, sprints, labels, wiki, bulk-export]
requisitos:
  variaveis: [LINEAR_TEAM]
  servicos: [linear-mcp]
  hosts: [api.linear.app]
---

# Provider: backlog — implementação Linear via MCP

Implementação da interface (`INTERFACE.md`) sobre o **servidor MCP do Linear**
(`linear-server`). Conteúdo procedural é bem-vindo aqui — sintaxe de ferramenta é fato, não
raciocínio. Seleção do provider, gate e modo degradado moram na `INTERFACE.md` e não se
repetem aqui.

**Ativa quando** `BACKLOG_PROVIDER=linear`.
**Capacidades:** `core` · `comments` · `description-block` · `sprints` (ciclos: leitura e
atribuição) · `labels` · `wiki` (documents) · `bulk-export`.
**Não suporta:** `sprints-write` — criar, editar e fechar ciclo não existe na API MCP; ciclo
no Linear é gerado pela cadência configurada no time. Ver §7.
**Variáveis da instância:** `LINEAR_TEAM` (key ou nome do time, ex.: `ENG`),
`LINEAR_PROJECT` (opcional, escopo default), `LINEAR_API_KEY` (opcional, só para o export
em lote fora do contexto — §8).

Nada aqui usa CLI: o transporte é o MCP. Se o servidor não estiver conectado, **pare** e
peça a conexão — não caia em `curl` improvisado nem invente número de demanda.

## 1. Transporte e autenticação

O MCP autentica por OAuth no cliente, não por token no `.env`. Conferir e conectar:

```bash
claude mcp list                      # linear-server deve aparecer conectado
```

Sem conexão, o usuário conecta pelo `/mcp` do cliente (fluxo OAuth no navegador). **Falha
da ferramenta**: reporte o erro **verbatim**, aponte este passo e ofereça repetir
(`INTERFACE.md`). Nunca contorne autenticação.

Os nomes das tools abaixo são os do servidor (`list_issues`, `save_issue`, …). O prefixo
varia por runtime (`mcp__linear-server__list_issues` no Claude Code) — use o do runtime
ativo, o nome depois do prefixo é o mesmo em todos.

## 2. Vocabulário — Linear ↔ interface

| Interface | Linear | Onde vive |
|---|---|---|
| demanda | **issue** (`ENG-123` — identifier, não número solto) | `list_issues`, `get_issue`, `save_issue` |
| sprint | **cycle** (numerado, cadência do time) | `list_cycles`, `save_issue(cycle:)` |
| rótulo | **label** (pode ser agrupada: grupo + filha) | `list_issue_labels`, `create_issue_label` |
| estado | **status** por time (`state.type`: `backlog`, `unstarted`, `started`, `completed`, `canceled`) | `list_issue_statuses` |
| página de wiki | **document** (ancorado em time, projeto, ciclo, initiative ou issue) | `list_documents`, `get_document`, `save_document` |
| épico/entrega | **project** e **project milestone** | `save_project`, `save_milestone` |

Duas diferenças que mudam procedimento, não vocabulário:

- **Fechar não é um verbo** — é mudar `state` para um status de tipo `completed` (ou
  `canceled`). Reabrir é voltar para `unstarted`/`started`. Os nomes dos status variam por
  time: liste antes de escrever (§6).
- **`Done` não é sempre "Done"** — sempre resolva pelo `type`, nunca pelo rótulo.

## 3. Escopo: time e projeto

Quase toda tool aceita `team`. Use `$LINEAR_TEAM` sempre explícito — o harness roda em
repositórios que podem não ser o do backlog, e workspace do Linear costuma ter vários times.

```
list_teams()                          # descobrir keys quando LINEAR_TEAM estiver vazio
get_team(query: "$LINEAR_TEAM")       # id do time — list_cycles exige teamId, não key
```

`LINEAR_TEAM` vazio e mais de um time no workspace → **pergunte qual**, não escolha.

## 4. Ler (`core`)

```
list_issues(team: "$LINEAR_TEAM", limit: 50, fields: ["identifier","title","status","labels","assignee","cycleId","updatedAt","url"])
```

Filtros úteis (combináveis): `query` (busca em título/descrição), `state` (nome, id ou
`type`), `label`, `assignee` (`"me"` para o usuário, `null` para sem responsável),
`cycle`, `project`, `priority` (0 none … 4 low), `createdAt`/`updatedAt`
(ISO-8601 ou duração: `-P7D`), `parentId`, `includeArchived`, `orderBy`
(`createdAt`|`updatedAt`), `cursor` (próxima página), `limit` (default 50, **máx 250**).

**`fields` é obrigatório na prática.** Sem ele vem o payload default e a descrição inteira
de cada issue entra no contexto. Peça só as colunas que a tarefa usa — o custo de token da
listagem é decidido aqui.

Uma demanda, com detalhe:

```
get_issue(id: "ENG-123")              # aceita identifier ou UUID
list_comments(issueId: "ENG-123")     # comentários em thread
```

Receitas:

```
# Demandas da sprint corrente
list_issues(team: "$LINEAR_TEAM", cycle: "current", limit: 250, fields: [...])

# Abertas por rótulo
list_issues(team: "$LINEAR_TEAM", label: "AWAITING APPROVAL", state: "unstarted")

# Busca textual
list_issues(team: "$LINEAR_TEAM", query: "autenticação")

# Paradas há mais de 30 dias (saúde)
list_issues(team: "$LINEAR_TEAM", state: "started", updatedAt: "-P30D")
```

`updatedAt: "-P30D"` filtra **atualizadas depois** desse ponto — para "paradas há 30 dias",
exporte (§8) e filtre no arquivo local, não na API.

## 5. Escrever — write-gate antes de cada operação

Toda operação desta seção é mutação: mostre alvo e conteúdo, espere aprovação
(`system/CONSTITUTION.md` §2). Uma aprovação por operação, sem lote implícito.

**Criar demanda** (`team` obrigatório; `title` obrigatório salvo com `template`):

```
save_issue(team: "$LINEAR_TEAM", title: "...", description: "<markdown>",
           labels: ["Bug","Urgent"], cycle: "current", project: "...",
           assignee: "me", priority: 2, estimate: 3)
```

**Atualizar** (mesma tool, com `id` — nunca passe `id` ao criar):

```
save_issue(id: "ENG-123", assignee: "fulano@empresa.com", cycle: "42")
```

Armadilhas do `save_issue`:

- `labels` **substitui o conjunto inteiro** — omita para não mexer; para adicionar uma,
  leia as atuais e reenvie a lista completa.
- `assignee` aceita id, nome, e-mail ou `"me"`; `null` remove. Não existe `assigneeId`.
- `cycle`, `project`, `parentId`, `dueDate`, `estimate`: `null` remove.
- Relações (`blocks`, `blockedBy`, `relatedTo`) são **append-only** — remover exige
  `removeBlocks`/`removeBlockedBy`/`removeRelatedTo`.
- `description` **substitui a descrição inteira**. Para edição parcial, use `patch` (§6).

**Comentar** (`comments`):

```
save_comment(issueId: "ENG-123", body: "<markdown>")
save_comment(parentId: "<id do comentário>", body: "...")     # resposta na thread
```

**Fechar / reabrir** — é troca de status:

```
list_issue_statuses(team: "$LINEAR_TEAM")     # pegue o status cujo type é completed/canceled
save_issue(id: "ENG-123", state: "Done")      # ou o nome que o time usa
```

**Rótulos** (`labels`):

```
list_issue_labels(team: "$LINEAR_TEAM")
create_issue_label(team: "$LINEAR_TEAM", name: "TIPO/Bug", color: "#FF0000")
```

Linear agrupa rótulo por **grupo pai**, não por prefixo `::`. Taxonomia com prefixo
(`TIPO::BUG`) continua funcionando como texto puro — o funil de priorização lê o prefixo
declarado no encaixe (`binding` do `funil`), então o que vale é o que a instância declarou,
não a convenção do GitLab.

## 6. Bloco estruturado na descrição (`description-block`)

Linear tem edição parcial nativa — **use `patch`, não releia a descrição inteira para
reescrevê-la**. As operações são atômicas (uma falha aborta o save) e cada âncora precisa
casar exatamente uma vez:

```
save_issue(id: "ENG-123", patch: [
  {op: "replace", old_string: "<bloco antigo inteiro>", new_string: "<bloco novo>"}
])

save_issue(id: "ENG-123", patch: [
  {op: "insert_after", anchor: "## Dimensões", text: "\n\n<tabela nova>"}
])

save_issue(id: "ENG-123", patch: [{op: "append", text: "\n\n<entrada nova>"}])
```

`append`/`prepend` não precisam ler a descrição — é o caminho barato para changelog e
histórico. Só use `get_issue` antes quando você **precisa raciocinar** sobre o conteúdo
atual (ex.: recalcular um bloco a partir dele).

Write-gate: mostre **só o patch** para aprovação, não a descrição inteira.

## 7. Sprints (`sprints`) — o que dá e o que não dá

Ciclo no Linear é gerado pela cadência do time (Settings → Cycles): não se cria ciclo
avulso, não se fecha ciclo à mão — ele fecha na data. A API MCP reflete isso.

| Operação da interface | Linear |
|---|---|
| listar sprints | `list_cycles(teamId: "<uuid>", type: "current"\|"previous"\|"next")` |
| demandas de uma sprint | `list_issues(team: ..., cycle: "current"\|"<número>"\|"<id>")` |
| mover demanda entre sprints | `save_issue(id: ..., cycle: "43")` — uma por vez, write-gate por operação |
| documentar a sprint | `save_document(title: ..., content: ..., cycle: "43", team: "$LINEAR_TEAM")` — ciclo não tem campo de descrição; o documento ancorado nele é o equivalente |
| **criar / editar / fechar sprint** | **não existe** (`sprints-write`) |

`list_cycles` exige o **UUID** do time (`get_team` primeiro), não a key.

Pedido de criar/fechar ciclo → indisponibilidade explícita, nunca contorno:

> "No Linear, ciclo é gerado pela cadência do time e fecha na data — criar ou fechar à mão
> não existe na API. Ajuste a cadência em Settings → Cycles. Posso listar o ciclo atual,
> mover demandas entre ciclos e documentar a sprint."

Quando o time usa **projeto** como recorte de entrega em vez de ciclo, aí há escrita:
`save_project(...)` e `save_milestone(...)`. É outro recorte, não substituto de sprint —
combine com o usuário antes de usar.

## 8. Export em lote (`bulk-export`)

Duas rotas. **A regra é a mesma da wiki grande: dado que só vai virar contagem não entra no
contexto do modelo.**

### 8.1 Rota barata — GraphQL no shell (preferida para análise)

Exige `LINEAR_API_KEY` (Linear → Settings → Security & access → Personal API keys). O
payload vai para arquivo; o modelo lê o CSV depois, não o JSON.

```bash
export LINEAR_API_KEY LINEAR_TEAM
AFTER=null
: > /tmp/linear_issues.ndjson
while :; do
  RESP=$(curl -s https://api.linear.app/graphql \
    -H "Content-Type: application/json" \
    -H "Authorization: ${LINEAR_API_KEY}" \
    --data @<(jq -n --arg team "$LINEAR_TEAM" --argjson after "$AFTER" '{
      query: "query($team:String!,$after:String){issues(first:250,after:$after,filter:{team:{key:{eq:$team}}}){pageInfo{hasNextPage endCursor} nodes{identifier title description priority estimate createdAt updatedAt completedAt canceledAt url state{name type} labels{nodes{name}} cycle{number name} project{name} assignee{displayName} creator{displayName}}}}",
      variables: {team: $team, after: $after}}'))
  echo "$RESP" | jq -c '.data.issues.nodes[]' >> /tmp/linear_issues.ndjson
  [ "$(echo "$RESP" | jq -r '.data.issues.pageInfo.hasNextPage')" = "true" ] || break
  AFTER=$(echo "$RESP" | jq '.data.issues.pageInfo.endCursor')
done
wc -l /tmp/linear_issues.ndjson
```

Erro de auth do Linear vem em `.errors[0].message` com HTTP 200 — cheque isso antes de
concluir que o export veio vazio.

Conversão para o CSV que as receitas consomem: `recipes/linear-mcp-analysis.md`
(priorização) e `recipes/linear-mcp-burndown.md` (métricas e burndown).

### 8.2 Rota MCP — sem API key

`list_issues` com `limit: 250` + `cursor` até `hasNextPage` acabar. **Cada página passa
pelo contexto do modelo** — só é aceitável com `fields` enxuto e backlog pequeno
(≲250 demandas, uma página). Antes de rodar em backlog maior, avise o custo e ofereça a
rota 8.1:

> "Sem `LINEAR_API_KEY`, o export passa inteiro pelo contexto — caro e truncável acima de
> ~250 demandas. Com a chave, ele vai direto para arquivo. Quer seguir assim mesmo?"

Nunca "amostre" o backlog para caber: análise sobre parte do backlog apresentada como
análise do backlog é dado inventado.

## 9. Wiki (`wiki`) — documents

```
list_documents(team: "$LINEAR_TEAM")             # confira duplicata antes de criar
get_document(id: "<id ou slug>")                 # ⚠ despeja a página inteira no contexto
save_document(title: "...", content: "<markdown>", team: "$LINEAR_TEAM")   # criar
save_document(id: "<id>", content: "<markdown>")                            # substituir
save_document(id: "<id>", patch: [{op: "prepend", text: "<entrada nova>\n\n"}])  # append barato
```

Ao criar, **exatamente um** pai: `team`, `project`, `cycle`, `initiative` ou `issue`.
Passar um pai no update **reparenteia** o documento — não passe sem intenção.

Append/changelog usa `patch`, nunca `get_document` + reenvio: o corpo antigo não precisa
entrar no contexto e o custo não cresce com o tamanho da página. Write-gate mostra só a
entrada nova.

## 10. Limites e sintomas

| Sintoma | Causa / saída |
|---|---|
| tool não existe no runtime | servidor MCP não conectado — `claude mcp list`, depois `/mcp` |
| `list_cycles` recusa `LINEAR_TEAM` | exige UUID; resolva com `get_team` |
| `save_issue` apagou rótulos | `labels` substitui o conjunto — reenvie a lista completa |
| status "Done" não encontrado | nome varia por time; resolva por `list_issue_statuses` e use o `type` |
| export vazio com HTTP 200 | erro em `.errors[0].message` (chave inválida/sem escopo) |
| listagem truncada | `limit` máx 250 — pagine por `cursor`, ou use a rota 8.1 |
| string com `\n` literal aparecendo no Linear | não escape a string: mande quebra de linha de verdade |
