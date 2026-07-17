---
name: gitlab-sprint-ops
description: >
  Gerencia sprints (milestones) no GitLab: criar nova sprint com datas e objetivo,
  fechar sprint atual e gerar sumário de conclusão, mover issues entre sprints em lote,
  listar issues de uma sprint com status resumido, e documentar milestones preenchendo
  automaticamente a descrição com Meta da Sprint, Prazos e Escopo (Concluídos/Não Concluídos)
  seguindo o template padrão do projeto. Use esta skill para qualquer operação de gestão
  de sprint — criar, fechar, mover issues, ver o que está numa sprint específica, ou
  documentar/preencher a descrição de uma milestone. Acione também quando o usuário pedir
  para "documentar a sprint", "preencher a milestone", "atualizar a descrição da sprint"
  ou "registrar o escopo da sprint". Todas as operações usam variáveis de ambiente do .env.
  IMPORTANTE: Carregue obrigatoriamente a skill `glab-backlog` antes de qualquer operação no GitLab.
---

**PRÉ-REQUISITO:** Carregar a skill `glab-backlog` antes de qualquer operação no GitLab.

**GATE — GitLab habilitado.** Antes de qualquer operação, verifique:

```bash
echo $GITLAB_ENABLED
```

Se não for `true`, **pare** e responda:

> "GitLab não está habilitado neste projeto (`GITLAB_ENABLED` no `.env`). Esta skill depende da API do GitLab e não tem equivalente local. Para ativar, preencha `GITLAB_ENABLED=true` e as credenciais `GITLAB_*` no `.env`."

Não tente contornar com dados de `outputs/` ou `docs/context_docs/` — eles não substituem o estado real do backlog.

# gitlab-sprint-ops

Centraliza todas as operações de gestão de sprint (milestone) no GitLab. Sprints são milestones — este documento usa os dois termos de forma intercambiável.

---

## 1. Configuração

```
GITLAB_HOST:  ${GITLAB_HOST}
GITLAB_URI:   ${GITLAB_URI}
GITLAB_REPO:  ${GITLAB_REPO}
```

Para operações de milestone, use `--project ${GITLAB_REPO}` (não `-R`):

```bash
# Padrão correto para milestones
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab milestone <cmd> --project ${GITLAB_REPO}
```

---

## 2. Listar sprints

### Sprints ativas

```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab milestone list --project ${GITLAB_REPO} --state active
```

### Todas as sprints (incluindo encerradas)

```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab milestone list --project ${GITLAB_REPO}
```

### Listar issues de uma sprint

Exporte com jq para ter uma visão estruturada — uma chamada, resultado completo:

```bash
MILESTONE_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${MILESTONE_NAME}'))")
REPO_ENCODED="${GITLAB_REPO//\//\%2F}"

glab api --paginate \
  "projects/${REPO_ENCODED}/issues?milestone=${MILESTONE_ENCODED}&per_page=100" \
  --hostname ${GITLAB_HOST} \
  | jq -r '
    ["IID","Título","Estado","Labels","Assignee"],
    (.[] | [
      .iid,
      .title,
      .state,
      (.labels | join("|")),
      (if .assignees and (.assignees | length) > 0 then .assignees[0].username else "" end)
    ]) | @csv
  '
```

Apresente o resultado como tabela Markdown, não como CSV bruto.

---

## 3. Criar nova sprint

Antes de criar, pergunte ao usuário (se não estiver nos dados fornecidos):
- Nome da sprint (padrão comum: `Sprint YYYY.NN` — verifique o padrão das milestones existentes)
- Data de início
- Data de fim
- Objetivo da sprint (opcional — boa prática incluir)

```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab milestone create \
  --title="[NOME DA SPRINT]" \
  --project ${GITLAB_REPO} \
  --start-date="YYYY-MM-DDT08:00:00Z" \
  --due-date="YYYY-MM-DDT08:00:00Z" \
  --description="[OBJETIVO DA SPRINT]"
```

Confirme a criação retornando o título e as datas da sprint criada.

---

## 4. Fechar sprint (encerrar milestone)

Fechar uma sprint não fecha as issues — apenas marca o milestone como concluído. Antes de fechar, gere o sumário:

### 4.1 Gerar sumário da sprint

```bash
MILESTONE_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${MILESTONE_NAME}'))")
REPO_ENCODED="${GITLAB_REPO//\//\%2F}"

# Issues abertas remanescentes
glab api \
  "projects/${REPO_ENCODED}/issues?milestone=${MILESTONE_ENCODED}&state=opened&per_page=100" \
  --hostname ${GITLAB_HOST} \
  | jq '[.[] | {iid: .iid, title: .title, labels: .labels}]'

# Issues fechadas (entregues)
glab api \
  "projects/${REPO_ENCODED}/issues?milestone=${MILESTONE_ENCODED}&state=closed&per_page=100" \
  --hostname ${GITLAB_HOST} \
  | jq 'length'
```

Apresente o sumário:
```
Sprint: [nome]
Fechadas (entregues): N
Abertas (não entregues): N
Taxa de conclusão: XX%

Issues não entregues:
- #NNN [título]
- #NNN [título]
```

### 4.2 Confirmar e fechar

Só feche após confirmação do usuário. Obtenha o ID do milestone:

```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab milestone list --project ${GITLAB_REPO} --show-id
```

Então feche:

```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab milestone edit [MILESTONE_ID] \
  --project ${GITLAB_REPO} \
  --state close
```

---

## 5. Mover issues entre sprints em lote

Use quando o usuário quiser realocar issues de uma sprint para outra (ex: ao fechar a sprint, mover as não entregues para a próxima).

### 5.1 Identificar as issues a mover

Se o usuário não especificou quais, use os dados do passo 4.1 (issues abertas remanescentes).

Se precisar exportar especificamente:

```bash
REPO_ENCODED="${GITLAB_REPO//\//\%2F}"
MILESTONE_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${MILESTONE_ORIGEM}'))")

ISSUE_IDS=$(glab api --paginate \
  "projects/${REPO_ENCODED}/issues?milestone=${MILESTONE_ENCODED}&state=opened&per_page=100" \
  --hostname ${GITLAB_HOST} \
  | jq -r '.[].iid')
```

### 5.2 Confirmar antes de mover

Apresente a lista ao usuário e peça confirmação:
```
Vou mover N issues da sprint [ORIGEM] para [DESTINO]:
- #NNN [título]
- #NNN [título]
Confirmar? (sim/não)
```

### 5.3 Executar a movimentação

```bash
for IID in $ISSUE_IDS; do
  GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
    glab issue update $IID -R ${GITLAB_REPO} -m "[MILESTONE_DESTINO]"
  echo "Issue #$IID movida"
done
```

Reporte o progresso ao usuário ao final.

---

## 6. Padrão de nomes de sprint

Antes de criar uma sprint, verifique o padrão existente:

```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab milestone list --project ${GITLAB_REPO} | head -10
```

Use o mesmo padrão encontrado. Se não houver padrão definido, sugira ao usuário e aguarde confirmação antes de criar.

---

## 7. Template de documentação de milestone

A descrição de uma milestone segue **exatamente** este template, derivado das sprints recentes do projeto (Sprint 45–50):

```
**Meta da Sprint**

* [Sprint Goal — uma frase de outcome, não lista de entregas]

**Prazos**

DD/MM/YYYY - DD/MM/YYYY

## Escopo da Sprint

**Concluídos:**

#NNN+

#NNN+

**Não Concluídos:**

#NNN+

#NNN+
```

### Regras de preenchimento

| Campo | Regra |
|---|---|
| **Meta da Sprint** | `**Meta da Sprint**` em bold (não heading `##`). Uma linha em branco depois, depois `* [goal]`. |
| **Prazos** | `**Prazos**` em bold (não heading). Uma linha em branco depois, depois `DD/MM/YYYY - DD/MM/YYYY` (sem bullet). |
| **Escopo da Sprint** | `## Escopo da Sprint` como heading `##` (não bold). |
| **Concluídos** | Issues com `state: closed`. Formato: **somente `#NNN+`** — apenas o número da issue seguido de `+`. Sem título, sem OS, sem descrição, sem responsável, sem status, sem bullet, sem travessão. Uma issue por linha, **linha em branco entre cada issue**. |
| **Não Concluídos** | Issues com `state: opened`. Mesmo formato: **somente `#NNN+`**. Nenhuma informação adicional. |

**Proibições absolutas no Escopo da Sprint:**
- ❌ Nunca incluir o título da issue (`OS2026XXX | HU...`)
- ❌ Nunca incluir descrição, resumo ou bullets sobre o que a issue faz
- ❌ Nunca incluir responsável, assignee ou status da issue
- ❌ Nunca usar `* #NNN+` (bullet) nem `- #NNN+` (travessão) — só `#NNN+` puro
- ❌ Nunca omitir `**Não Concluídos:**` mesmo que a seção esteja vazia
- ❌ Não incluir `## Cerimônias` — abandonado no projeto a partir da Sprint 45

---

## 8. Fluxo de documentação automática da milestone

Use este fluxo para gerar ou atualizar a descrição de uma milestone a partir dos dados do GitLab, sem preenchimento manual.

### 8.1 Receber o nome da milestone

Se o usuário não informou, liste as milestones ativas e peça confirmação:

```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab milestone list --project ${GITLAB_REPO} --state active
```

### 8.2 Buscar dados da milestone

```bash
REPO_ENCODED="${GITLAB_REPO//\//\%2F}"
MILESTONE_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${MILESTONE_NAME}'))")

glab api "projects/${REPO_ENCODED}/milestones?search=${MILESTONE_NAME}" \
  --hostname ${GITLAB_HOST} \
  | jq '.[0] | {id: .id, title: .title, start_date: .start_date, due_date: .due_date, description: .description}'
```

Extraia:
- `start_date` e `due_date` → para o campo **Prazos**
- `description` existente → verifique se já há uma **Meta da Sprint** para reutilizar

### 8.3 Verificar Sprint Goal

Leia o campo `description` retornado no passo anterior:

- Se contém `**Meta da Sprint**` com conteúdo não vazio → **reutilize** o texto existente sem alteração.
- Se está vazio ou não tem meta → **carregue obrigatoriamente a skill `sprint-goal-generator`** para gerar a meta. Nunca escreva a meta da sprint por conta própria — a meta é sempre gerada pela skill dedicada com aprovação do usuário.

### 8.4 Buscar issues da milestone e classificar

```bash
# Issues fechadas (concluídas)
CLOSED=$(glab api --paginate \
  "projects/${REPO_ENCODED}/issues?milestone=${MILESTONE_ENCODED}&state=closed&issue_type=issue&per_page=100" \
  --hostname ${GITLAB_HOST} \
  | jq -r '[.[] | "#\(.iid)+"] | join("\n\n")')

# Issues abertas (não concluídas)
OPENED=$(glab api --paginate \
  "projects/${REPO_ENCODED}/issues?milestone=${MILESTONE_ENCODED}&state=opened&issue_type=issue&per_page=100" \
  --hostname ${GITLAB_HOST} \
  | jq -r '[.[] | "#\(.iid)+"] | join("\n\n")')
```

### 8.5 Gerar a descrição preenchida

Monte o texto seguindo o template da seção 7, substituindo os campos:

```bash
START_DATE_BR=$(date -d "${START_DATE}" +"%d/%m/%Y" 2>/dev/null || python3 -c "
from datetime import datetime
print(datetime.strptime('${START_DATE}', '%Y-%m-%d').strftime('%d/%m/%Y'))
")
DUE_DATE_BR=$(date -d "${DUE_DATE}" +"%d/%m/%Y" 2>/dev/null || python3 -c "
from datetime import datetime
print(datetime.strptime('${DUE_DATE}', '%Y-%m-%d').strftime('%d/%m/%Y'))
")
```

Exemplo de descrição gerada:

```
**Meta da Sprint**

* O portal de acesso externo deixa de fragmentar a visão por empresa — representantes multi-CNPJ e colaboradores da organização consultam candidatos de forma consolidada e sem barreiras.

**Prazos**

04/05/2026 - 15/05/2026

## Escopo da Sprint

**Concluídos:**

#607+

#632+

#591+

**Não Concluídos:**

```

O script de montagem deve gerar cada issue em sua própria linha com `\n\n` entre elas — nunca bullet, nunca lista compacta.

### 8.6 Exibir preview e confirmar

Antes de atualizar, mostre a descrição gerada ao usuário e aguarde confirmação:

```
Vou atualizar a descrição da milestone "[MILESTONE_NAME]" com o seguinte conteúdo:

[descrição gerada]

Confirmar? (sim/não)
```

### 8.7 Atualizar a milestone

Obtenha o ID numérico da milestone (retornado no passo 8.2) e execute:

```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab milestone edit ${MILESTONE_ID} \
  --project ${GITLAB_REPO} \
  --description="${NOVA_DESCRICAO}"
```

### 8.8 Registrar em history/

Após a atualização, registre em `history/YYYY-MM-DD_sprint_doc_[MILESTONE_NAME].md`:

```markdown
# [SPRINT DOC] [MILESTONE_NAME]
Data: YYYY-MM-DD
Operação: documentação de milestone (descrição atualizada)
Milestone: [título]
URL: ${GITLAB_URI}/${GITLAB_REPO}/-/milestones/[iid]

## Sumário
- Concluídas: N issues
- Não concluídas: N issues
- Meta da Sprint: [texto]
```
