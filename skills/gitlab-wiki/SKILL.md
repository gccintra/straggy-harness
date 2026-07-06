---
name: gitlab-wiki
description: >
  Cria e atualiza páginas na wiki do GitLab do projeto via glab api. Use esta skill
  sempre que precisar publicar, criar ou atualizar documentação de produto na wiki —
  seja um fluxo novo, um módulo documentado, uma decisão técnica, ou uma entrada de
  changelog. A skill verifica se a página já existe antes de criar, e oferece append ou
  replace quando existe conteúdo anterior.
  IMPORTANTE: Carregue obrigatoriamente a skill `glab-backlog` antes de qualquer operação no GitLab.
---

**PRÉ-REQUISITO:** Carregar a skill `glab-backlog` antes de qualquer operação no GitLab.

# gitlab-wiki

Publica e mantém páginas na wiki do GitLab usando a API REST via `glab api`. O objetivo é que qualquer documentação gerada no harness chegue à wiki sem fricção manual.

---

## 1. Configuração

Todas as operações usam variáveis de ambiente — nunca valores hardcoded:

```
GITLAB_HOST:  ${GITLAB_HOST}
GITLAB_URI:   ${GITLAB_URI}
GITLAB_REPO:  ${GITLAB_REPO}
```

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

## 2. Operações

### 2.1 Listar páginas existentes

Antes de criar uma página nova, verifique se já existe — duplicatas na wiki causam confusão e perda de histórico.

```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab api "projects/${GITLAB_REPO//\//\%2F}/wikis" \
  --hostname ${GITLAB_HOST} | jq '[.[] | {slug, title}]'
```

### 2.2 Ler conteúdo de uma página existente

⚠️ Isto despeja a **página inteira no contexto do modelo** — caro em páginas grandes. Use só quando
você precisa de fato ler/raciocinar sobre o conteúdo (ex: replace de módulo). Para **append/changelog,
NÃO use isto** — use o "Append barato" (2.4), que mantém o corpo antigo no shell.

```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab api "projects/${GITLAB_REPO//\//\%2F}/wikis/<slug>" \
  --hostname ${GITLAB_HOST} | jq '.content'
```

### 2.3 Criar nova página

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

### 2.4 Atualizar página existente

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

## 3. Convenções de nomenclatura de páginas

Siga estas convenções para manter a wiki organizada e navegável:

| Tipo de conteúdo | Formato do título | Exemplo |
|---|---|---|
| Módulo do produto | `Módulo — [Nome]` | `Módulo — Gerenciamento de Inscritos` |
| Fluxo específico | `Fluxo — [Nome]` | `Fluxo — Fechamento de Turma` |
| Changelog | `Changelog — Histórico de Evolução` | (página única, append) |
| Decisão técnica | `Decisão — [Tema]` | `Decisão — Migração de Paginação` |
| Glossário | `Glossário — [Área]` | `Glossário — Status de Inscrição` |

---

## 4. Fluxo de decisão ao publicar

```
Recebeu conteúdo para publicar
        ↓
Liste páginas existentes (2.1)
        ↓
Página já existe?
  ├── Sim → Tipo de operação?
  │           ├── Append (changelog, histórico) → "Append barato" (2.4): NÃO leia a página no
  │           │     contexto; modelo escreve só a entrada nova, shell faz fetch+prepend+PUT
  │           └── Replace (atualização de módulo) → leia o atual (2.2), confirme com usuário,
  │                 envie o novo via PUT (-F content=@arquivo)
  └── Não → Crie a página (2.3)
        ↓
Retorne a URL da página criada/atualizada:
${GITLAB_URI}/${GITLAB_REPO}/-/wikis/<slug>
```

Confirmar com o usuário antes de sobrescrever conteúdo existente é importante — a wiki não tem lixeira e o histórico de versões do GitLab é a única forma de recuperar conteúdo apagado.

---

## 5. Formato de registro em history/

Após publicar na wiki, registre em `history/YYYY-MM-DD_wiki_<slug>.md`:

```markdown
# [WIKI] <Título da Página>
Data: YYYY-MM-DD
Agente: wiki | product-manager (changelog)
Operação: criada | atualizada (append) | atualizada (replace)
URL: ${GITLAB_URI}/${GITLAB_REPO}/-/wikis/<slug>

## Conteúdo publicado
[resumo do que foi publicado]
```
