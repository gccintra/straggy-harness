---
capacidades: [core, comments, description-block, sprints, labels, wiki, bulk-export]
requisitos:
  binarios: [glab]
  variaveis: [GITLAB_HOST, GITLAB_URI, GITLAB_REPO, GITLAB_TOKEN]
---

# Provider: backlog — implementação GitLab via glab CLI

Implementação da interface (`INTERFACE.md`) sobre o `glab` CLI. Referência completa de
comandos — conteúdo procedural é bem-vindo aqui (sintaxe de ferramenta é fato, não
raciocínio). A seleção do provider, o gate e o modo degradado estão na `INTERFACE.md` —
não se repetem aqui.

**Ativa quando** `BACKLOG_PROVIDER=gitlab` (ou, por compatibilidade, `GITLAB_ENABLED=true`).
**Capacidades:** `core` · `comments` · `description-block` · `sprints` (milestones) ·
`labels` · `wiki` · `bulk-export`.
**Variáveis da instância:** `GITLAB_HOST`, `GITLAB_URI`, `GITLAB_REPO`, `GITLAB_TOKEN`.
**Receitas de export em lote:** `recipes/gitlab-glab-analysis.md` (priorização),
`recipes/gitlab-glab-burndown.md` (métricas e burndown).


> Reference version: glab 1.95.0+  
> Scope: issues, milestones, labels, boards, todos, and direct API access. Does not cover MRs, CI/CD, releases, or snippets.

> **Configuration:** All project values come from environment variables in `.env`. The examples in this skill use literal values for illustration — always replace them with the actual env vars when executing:
> - `gitlab.exemplo.com` → `${GITLAB_HOST}`
> - `https://gitlab.exemplo.com` → `${GITLAB_URI}`
> - `grupo/projeto` → `${GITLAB_REPO}`
> - `grupo%2Fprojeto` → URL-encoded form of `${GITLAB_REPO}` (replace `/` with `%2F`)

## 1. Authentication and Host Selection

### Check authentication
```bash
glab auth status
```

### Select a self-managed host

| Method | When to use |
|---|---|
| `GITLAB_HOST=... GITLAB_URI=... glab <cmd>` | **Universal** — works with any command |
| `glab api <endpoint> --hostname gitlab.exemplo.com` | Only in `glab api` and `glab auth login` |
| `glab issue list -R grupo/projeto` | When the remote already points to the correct instance |
| Inside a git repo with a configured remote | Auto-detected |

**Standard example for self-managed instances:**
```bash
GITLAB_HOST=gitlab.exemplo.com GITLAB_URI=https://gitlab.exemplo.com \
  glab <command> -R grupo/projeto
```

### Environment variables

| Variable | Purpose |
|---|---|
| `GITLAB_HOST` | Hostname (e.g. `gitlab.exemplo.com`) |
| `GITLAB_URI` | Full base URL |
| `GITLAB_TOKEN` / `GITLAB_ACCESS_TOKEN` | Overrides the stored token |

---

## 2. Global Flags

| Flag | Description |
|---|---|
| `-R, --repo` | Select another repository (`OWNER/REPO`, URL, or Git URL) |
| `-F, --output` | `text` (table) or `json` |
| `-p, --page` | Page number (starts at 1) |
| `-P, --per-page` | Items per page |

---

## 3. Issues

### List issues
```bash
glab issue list [--flags]
```

Main flags:

| Flag | Description |
|---|---|
| `-A, --all` | Open + closed |
| `-c, --closed` | Closed only |
| `-a, --assignee` | By assignee (`@me` for yourself) |
| `--author` | By author |
| `-l, --label` | By label (comma-separated or repeatable) |
| `--not-label` | Exclude label |
| `-m, --milestone` | By milestone title or ID |
| `-t, --issue-type` | `issue`, `incident`, `test_case` |
| `-g, --group` | Target a group instead of a project |
| `--search` | Search in title/description |
| `--order` | `created_at`, `updated_at`, `priority`, `due_date`, etc. |
| `-s, --sort` | `asc` or `desc` |
| `-F, --output-format` | `details`, `ids`, `urls` |

**Recipes:**
```bash
# All issues in a sprint (excluding tasks/work items)
GITLAB_HOST=gitlab.exemplo.com GITLAB_URI=https://gitlab.exemplo.com \
  glab issue list -R grupo/projeto -m "Sprint 2026.10" -A -P 100 -t issue

# Open issues in a sprint
glab issue list -R grupo/projeto -m "Sprint 2026.10" -P 100 -t issue

# By label
glab issue list -R grupo/projeto -l "AWAITING APPROVAL" -A -t issue

# Text search
glab issue list -R grupo/projeto --search "authentication" -A -t issue

# By author
glab issue list -R grupo/projeto -m "Sprint 2026.10" --author gustavo.cintra -A -t issue

# Count by state (JSON + jq)
glab issue list -R grupo/projeto -m "Sprint 2026.10" -A -P 100 -t issue -F json \
  | jq 'group_by(.state) | map({state: .[0].state, count: length})'
```

### View issue details
```bash
glab issue view <id> [-R grupo/projeto] [-c]   # -c shows comments
glab issue view <id> -w                      # opens in browser
```

### Create an issue
```bash
glab issue create -R grupo/projeto \
  -t "Issue title" \
  -d "Description..." \
  -l "TYPE::IMPROVEMENT,PRIORITY::QUICK WIN" \
  -m "Sprint 2026.11" \
  -y
```

Additional flags: `--assignee`, `--weight`, `--due-date`, `--confidential`, `--epic`, `--template`

### Update an issue
```bash
glab issue update <id> -R grupo/projeto [--flags]
```

Flags: `-t` (title), `-d` (description), `-a` (assignee: `!user` removes, `+user` adds), `-l` (add label), `-u` (remove label), `-m` (milestone; `""` disassociates), `-w` (weight)

### Close / Reopen
```bash
glab issue close <id>   # or URL
glab issue reopen <id>
```

### Comment
```bash
glab issue note <id> -m "Comment text"
```

### Delete
```bash
glab issue delete <id>
```

---

## 4. Milestones

> ⚠️ `milestone list` requires `--project` or `--group` — it does not auto-detect the current repo.

### List milestones
```bash
GITLAB_HOST=gitlab.exemplo.com GITLAB_URI=https://gitlab.exemplo.com \
  glab milestone list --project grupo/projeto --state active
```

Flags: `--state` (`active`/`closed`), `--search`, `--title`, `--include-ancestors`, `--show-id`

### Create a milestone
```bash
glab milestone create \
  --title="Sprint 2026.13" \
  --project grupo/projeto \
  --due-date="2026-06-15T08:00:00Z" \
  --start-date="2026-06-01T08:00:00Z" \
  --description="Sprint goal"
```

### Edit a milestone
```bash
glab milestone edit <id> --title="New Title" --project grupo/projeto
# --state: 'activate' or 'close'
# --due-date, --start-date, --description also available
```

### Delete
```bash
glab milestone delete <id> --project grupo/projeto
```

---

## 5. Labels

```bash
# List
glab label list -R grupo/projeto

# Create
glab label create -n "label-name" -c "#FF0000" -d "Description" -R grupo/projeto

# Edit
glab label edit -l <label-id> -n "new-name" -c "#00FF00" -R grupo/projeto

# Delete
glab label delete "label-name" -R grupo/projeto
```

---

## 6. To-Do

```bash
# List pending todos
glab todo list                          # pending (default)
glab todo list -s all                   # all states
glab todo list -t Issue                 # issues only

# Mark as done
glab todo done <id>
glab todo done --all                    # mark all as done
```

---

## 7. `glab api` — Direct API Access

```bash
glab api <endpoint> [--flags]
```

| Flag | Description |
|---|---|
| `-X` | HTTP method (`GET`, `POST`, etc.) |
| `-F, --field` | Parameter with type inference |
| `-f, --raw-field` | Parameter as a raw string |
| `--hostname` | Override host (only here and in `auth login`) |
| `--paginate` | Fetch all pages automatically |
| `--output` | `json` or `ndjson` (ideal for piping with `jq`) |

**Examples:**
```bash
# Active milestones (REST)
glab api projects/grupo%2Fprojeto/milestones?state=active --hostname gitlab.exemplo.com

# Issues for a milestone with full pagination
glab api "projects/grupo%2Fprojeto/issues?milestone=Sprint+2026.10&issue_type=issue&per_page=100" \
  --hostname gitlab.exemplo.com --paginate --output ndjson

# Issue detail
glab api projects/grupo%2Fprojeto/issues/632 --hostname gitlab.exemplo.com

# GraphQL — aggregated data
glab api graphql --hostname gitlab.exemplo.com -f query='
query {
  project(fullPath: "grupo/projeto") {
    name
    issues(state: opened) { count }
    milestones(state: active) {
      nodes { title dueDate startDate }
    }
  }
}'
```

**Pipeline with jq:**
```bash
# Via issue list
glab issue list -m "Sprint 2026.10" -A -F json -t issue \
  | jq '.[] | {iid: .iid, title: .title, state: .state, labels: .labels}'

# Via glab api (streaming)
glab api issues --paginate --output ndjson | jq 'select(.state == "opened") | .title'
```

---

## 8. Troubleshooting

| Symptom | Solution |
|---|---|
| Command hits gitlab.com instead of your instance | Set `GITLAB_HOST` and `GITLAB_URI` |
| "Unknown flag: --project" in `glab issue` | `--project` only exists for `milestone`. Use `-R` for issues. |
| `--hostname` doesn't work in top-level commands | Only works in `glab api` and `glab auth login`. Use `GITLAB_HOST`. |
| `-m` doesn't find the milestone | Accepts title as a string: `-m "Sprint 2026.10"` |
| `-t` does the wrong thing | In `issue list` it's `--issue-type`; in `issue create` it's `--title`. Check `--help`. |

---

## 9. Discover More

```bash
glab --help
glab issue --help
glab issue list --help
glab milestone --help
glab auth status
glab config edit
```

Online docs: https://docs.gitlab.com/ee/editor_extensions/gitlab_cli/

---

## 10. Wiki (REST via glab api)

A wiki do GitLab é acessada via endpoint REST:
```
${GITLAB_URI}/api/v4/projects/<project_id>/wikis
```

Para obter o `project_id` do repo:
```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab api "projects/${GITLAB_REPO//\//\%2F}" --hostname ${GITLAB_HOST} \
  | jq '.id'
```

---

### Operações

#### 1 Listar páginas existentes

Antes de criar uma página nova, verifique se já existe — duplicatas na wiki causam confusão e perda de histórico.

```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab api "projects/${GITLAB_REPO//\//\%2F}/wikis" \
  --hostname ${GITLAB_HOST} | jq '[.[] | {slug, title}]'
```

#### 2 Ler conteúdo de uma página existente

⚠️ Isto despeja a **página inteira no contexto do modelo** — caro em páginas grandes. Use só quando
você precisa de fato ler/raciocinar sobre o conteúdo (ex: replace de módulo). Para **append/changelog,
NÃO use isto** — use o "Append barato" (2.4), que mantém o corpo antigo no shell.

```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab api "projects/${GITLAB_REPO//\//\%2F}/wikis/<slug>" \
  --hostname ${GITLAB_HOST} | jq '.content'
```

#### 3 Criar nova página

```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab api "projects/${GITLAB_REPO//\//\%2F}/wikis" \
  -X POST \
  -f title="<Título da Página>" \
  -f content="<conteúdo em markdown>" \
  -f format="markdown" \
  --hostname ${GITLAB_HOST}
```

O `slug` é gerado automaticamente pelo GitLab a partir do título (espaços → hífens, lowercase).

#### 4 Atualizar página existente

O PUT substitui o conteúdo **inteiro** — a wiki do GitLab não tem patch/append nativo. Há dois modos.

#### Replace (sobrescreve tudo — ex: atualização de módulo)

```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab api "projects/${GITLAB_REPO//\//\%2F}/wikis/<slug>" \
  -X PUT -f title="<Título>" -f format="markdown" \
  -F content=@/tmp/page.md \
  --hostname ${GITLAB_HOST}
```

#### Append BARATO (changelog/histórico) — ⚠️ NÃO leia a página no contexto do modelo

Para inserir uma entrada nova **sem gastar tokens** com o conteúdo antigo, faça fetch + concat + PUT
**no shell**. O modelo escreve **só a entrada nova** num arquivo; o corpo antigo vai para uma
variável de shell e **nunca entra no contexto**. O custo de token não cresce com o tamanho da página.

```bash
PROJ="${GITLAB_REPO//\//%2F}"
SLUG="<slug-da-pagina>"     # ex: pegue da listagem 2.1 (só slugs, barato)
# (o modelo já escreveu A ENTRADA NOVA, pequena, em /tmp/entry.md)

# corpo antigo -> variável de shell (NÃO é impresso, NÃO vai pro modelo):
old=$(GITLAB_HOST=${GITLAB_HOST} glab api "projects/$PROJ/wikis/$SLUG" --hostname ${GITLAB_HOST} | jq -r '.content')

# prepend: entrada nova no TOPO + corpo antigo embaixo, montado em arquivo:
{ cat /tmp/entry.md; printf '\n\n%s' "$old"; } > /tmp/page_new.md
unset old   # descarta o corpo antigo

# PUT lê do arquivo (-F content=@...), então o tool-call também não carrega o corpo:
GITLAB_HOST=${GITLAB_HOST} glab api "projects/$PROJ/wikis/$SLUG" \
  -X PUT -f format=markdown -F content=@/tmp/page_new.md --hostname ${GITLAB_HOST}
```

- `old=$(...)` em variável de shell → corpo antigo **fora do contexto do modelo**.
- `-F content=@arquivo` → o PUT lê do disco; o conteúdo não passa pelo tool-call.
- **Write-gate:** o modelo mostra ao usuário **só a entrada nova** (`/tmp/entry.md`) para aprovar, depois roda o PUT. Não precisa mostrar a página inteira.
- Nunca use a 2.2 (`jq '.content'`) para append — ela despeja a página toda no contexto.

---

