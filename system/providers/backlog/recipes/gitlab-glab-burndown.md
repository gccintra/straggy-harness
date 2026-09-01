# Export e burndown — código de referência

Procedural (jq / HTML do burndown). O contrato do relatório está no SKILL.md.

### Passo 2 — Exportar com glab + jq

> **`DADOS`** é o diretório de export do projeto — `caminhos.dados` do `project-config.yaml`.
> Exporte antes de rodar os blocos abaixo: `export DADOS="$(...)"`. Nunca escreva o caminho literal.

**Para backlog completo (todas as issues, sem limite de paginação):**

```bash
REPO_ENCODED="${GITLAB_REPO//\//\%2F}"

glab api --paginate \
  "projects/${REPO_ENCODED}/issues?per_page=100" \
  --hostname ${GITLAB_HOST} \
  | jq -r '
    ["IID","Título","Estado","Tipo","Labels","Prioridade","Milestone","Assignee","Autor","Criada em","Atualizada em","Fechada em","Weight"],
    (.[] | [
      .iid,
      .title,
      .state,
      (if .issue_type then .issue_type else "issue" end),
      (.labels | join("|")),
      (.labels | map(select(startswith("PRIORIDADE::"))) | if length > 0 then .[0] else "" end),
      (if .milestone then .milestone.title else "" end),
      (if .assignees and (.assignees | length) > 0 then .assignees[0].username else "" end),
      .author.username,
      .created_at,
      .updated_at,
      (if .closed_at then .closed_at else "" end),
      (if .weight then .weight else "" end)
    ]) | @csv
  ' > ${DADOS}issues_$(date +%Y-%m-%d).csv
```

**Para uma sprint específica (filtro de milestone):**

O export de sprint inclui `closed_at` — campo obrigatório para o burndown chart do Passo 3.5.

```bash
MILESTONE_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${MILESTONE_NAME}'))")
REPO_ENCODED="${GITLAB_REPO//\//\%2F}"

glab api --paginate \
  "projects/${REPO_ENCODED}/issues?milestone=${MILESTONE_ENCODED}&per_page=100" \
  --hostname ${GITLAB_HOST} \
  | jq -r '
    ["IID","Título","Estado","Labels","Prioridade","Assignee","Criada em","Atualizada em","Fechada em","Weight"],
    (.[] | [
      .iid,
      .title,
      .state,
      (.labels | join("|")),
      (.labels | map(select(startswith("PRIORIDADE::"))) | if length > 0 then .[0] else "" end),
      (if .assignees and (.assignees | length) > 0 then .assignees[0].username else "" end),
      .created_at,
      .updated_at,
      (if .closed_at then .closed_at else "" end),
      (if .weight then .weight else "" end)
    ]) | @csv
  ' > ${DADOS}sprint_${MILESTONE_NAME// /_}_$(date +%Y-%m-%d).csv
```

> **Nota sobre labels:** o campo `Labels` contém todas as labels separadas por `|`. A coluna `Prioridade` extrai especificamente as labels com prefixo `PRIORIDADE::`. Adapte o prefixo conforme a taxonomia do projeto — identifique os prefixos de tipo e prioridade consultando `glab label list -R ${GITLAB_REPO}` antes de exportar se não souber.

### Passo 3 — Verificar o export

```bash
wc -l ${DADOS}issues_$(date +%Y-%m-%d).csv
head -3 ${DADOS}issues_$(date +%Y-%m-%d).csv
```

Se o arquivo tiver 0 ou 1 linha (só cabeçalho), o export falhou — verificar autenticação e variáveis de ambiente.

### Passo 4 — Datas da sprint (só quando o escopo é uma sprint)

O burndown precisa da janela da sprint, que não está no CSV:

```bash
REPO_ENCODED="${GITLAB_REPO//\//\%2F}"

glab api \
  "projects/${REPO_ENCODED}/milestones?search=${MILESTONE_NAME}&per_page=10" \
  --hostname ${GITLAB_HOST} \
  | jq '.[] | {title, start_date, due_date}'
```

## 3. Analisar e gerar o burndown

Com o CSV gerado, siga **`burndown-local.md`** — métricas de volume, saúde, score do
backlog e o HTML do burndown. Esse trecho roda sobre o arquivo local; o que é do GitLab
acaba aqui, com uma exceção declarada lá: as datas da sprint (`start_date`/`due_date`)
vêm da operação "listar sprint" da implementação ativa.
