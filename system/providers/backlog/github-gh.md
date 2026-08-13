---
capacidades: [core, comments, description-block, sprints, labels, bulk-export]
requisitos:
  binarios: [gh]
  variaveis: [GITHUB_REPO, GITHUB_TOKEN]
  hosts: [api.github.com]
---

# Provider: backlog — implementação GitHub via gh CLI

Implementação da interface (`INTERFACE.md`) sobre o `gh` CLI. Conteúdo procedural é
bem-vindo aqui — sintaxe de ferramenta é fato, não raciocínio. Seleção do provider, gate e
modo degradado moram na `INTERFACE.md` e não se repetem aqui.

**Ativa quando** `BACKLOG_PROVIDER=github`.
**Capacidades:** `core` · `comments` · `description-block` · `sprints` (milestones) ·
`labels` · `bulk-export`.
**Não suporta:** `wiki` — a wiki do GitHub é um repositório Git separado, sem API no `gh`.
Workflow que exige `wiki` deve informar indisponibilidade (ver `INTERFACE.md`).
**Variáveis da instância:** `GITHUB_REPO` (`OWNER/REPO`), `GITHUB_TOKEN` (ou `gh auth
login`), `GITHUB_HOST` (só para GitHub Enterprise Server).

Nos exemplos, `$GITHUB_REPO` é sempre explícito (`-R`): o harness roda em repositórios que
podem não ser o do backlog.

## 1. Autenticação

```bash
gh auth status
gh auth login                      # interativo, uma vez por máquina
```

Token por variável (CI, ou conta de serviço): `GH_TOKEN=$GITHUB_TOKEN gh <cmd>`.
GitHub Enterprise Server: `gh auth login --hostname "$GITHUB_HOST"`.

Vocabulário: **issue** = demanda · **milestone** = sprint · **label** = rótulo.
`gh` usa número (`#42`), não IID separado.

## 2. Ler

```bash
# listar com filtros (--state open|closed|all)
gh issue list -R "$GITHUB_REPO" --state open --limit 100
gh issue list -R "$GITHUB_REPO" --label "bug" --milestone "Sprint 2026.03"
gh issue list -R "$GITHUB_REPO" --assignee "@me"
gh issue list -R "$GITHUB_REPO" --search "vistoria in:title,body"

# ver demanda com comentários
gh issue view 42 -R "$GITHUB_REPO" --comments
```

`--json` aceita: `number,title,body,state,labels,milestone,assignees,author,createdAt,
updatedAt,closedAt,url,comments`. Campos disponíveis: `gh issue list --json` sem valor
lista todos.

## 3. Escrever — cada operação passa pelo write-gate

```bash
# criar
gh issue create -R "$GITHUB_REPO" --title "<título>" --body-file <arquivo.md> \
  --label "tipo::bug" --label "prioridade::must" --milestone "Sprint 2026.03"

# atualizar (o --body substitui o corpo inteiro — leia antes, mostre o antes/depois)
gh issue edit 42 -R "$GITHUB_REPO" --body-file <arquivo.md>
gh issue edit 42 -R "$GITHUB_REPO" --add-label "x" --remove-label "y" \
  --milestone "Sprint 2026.04" --add-assignee <login>

# comentar
gh issue comment 42 -R "$GITHUB_REPO" --body-file <arquivo.md>

# fechar / reabrir
gh issue close 42 -R "$GITHUB_REPO" --reason completed   # completed | "not planned"
gh issue reopen 42 -R "$GITHUB_REPO"
```

**Corpo sempre por `--body-file`**, nunca inline: `--body` com aspas quebra em acento,
crase, `#` e quebra de linha.

### Atualizar bloco estruturado dentro da descrição

`gh` só substitui o corpo inteiro. Para trocar um bloco (ex.: `<!-- PRIORIZACAO -->…<!--
/PRIORIZACAO -->`) sem perder o resto:

```bash
gh issue view 42 -R "$GITHUB_REPO" --json body -q .body > /tmp/body.md
python3 - <<'PY' /tmp/body.md /tmp/bloco.md
import re, sys, pathlib
corpo, bloco = (pathlib.Path(p).read_text() for p in sys.argv[1:3])
novo = re.sub(r"(?s)<!-- PRIORIZACAO -->.*?<!-- /PRIORIZACAO -->", bloco, corpo)
pathlib.Path(sys.argv[1]).write_text(novo if novo != corpo else corpo + "\n\n" + bloco)
PY
gh issue edit 42 -R "$GITHUB_REPO" --body-file /tmp/body.md
```

Marcador ausente → o bloco é acrescentado no fim. Mostre o diff antes de aplicar.

## 4. Sprints (milestones)

O `gh` não tem subcomando de milestone — vai pela API REST:

```bash
# listar
gh api "repos/$GITHUB_REPO/milestones?state=all&per_page=100" \
  -q '.[] | "\(.number)\t\(.title)\t\(.state)\t\(.due_on // "sem prazo")"'

# criar
gh api -X POST "repos/$GITHUB_REPO/milestones" \
  -f title="Sprint 2026.03" -f due_on="2026-03-27T23:59:59Z" -f description="<meta>"

# atualizar descrição / fechar
gh api -X PATCH "repos/$GITHUB_REPO/milestones/<number>" -f description="<texto>"
gh api -X PATCH "repos/$GITHUB_REPO/milestones/<number>" -f state=closed
```

`due_on` é ISO 8601 em UTC. Fechar milestone **não** fecha as issues dela.

## 5. Labels

```bash
gh label list -R "$GITHUB_REPO" --limit 100
gh label create "tipo::melhoria" -R "$GITHUB_REPO" --color 1D76DB --description "<texto>"
```

Consulte a taxonomia real antes de sugerir label — nunca invente sem aprovação.

## 6. Export em lote (capacidade `bulk-export`)

> **`DADOS`** é o diretório de export do projeto — `caminhos.dados` do `project-config.yaml`.
> Exporte antes de rodar os blocos abaixo: `export DADOS="$(...)"`. Nunca escreva o caminho literal.

Uma chamada paginada → arquivo local; toda a análise roda sobre o arquivo, nunca sobre
chamadas repetidas.

```bash
gh issue list -R "$GITHUB_REPO" --state open --limit 1000 \
  --json number,title,state,labels,milestone,assignees,createdAt,updatedAt,closedAt,url,body \
  > ${DADOS}issues_$(date +%F).json
```

`--limit` acima de 1000 pagina sozinho, mas confirme o total antes de concluir:

```bash
gh api "repos/$GITHUB_REPO" -q .open_issues_count
python3 -c "import json,sys; print(len(json.load(open(sys.argv[1]))))" ${DADOS}issues_$(date +%F).json
```

CSV para as skills de análise (descrição truncada, labels achatadas):

```bash
python3 - ${DADOS}issues_$(date +%F).json ${DADOS}issues_$(date +%F).csv <<'PY'
import csv, json, sys
issues = json.load(open(sys.argv[1]))
with open(sys.argv[2], "w", newline="", encoding="utf-8") as fh:
    w = csv.writer(fh)
    w.writerow(["number","title","state","labels","milestone","assignees",
                "created_at","updated_at","closed_at","url","body"])
    for i in issues:
        w.writerow([
            i["number"], i["title"], i["state"],
            "|".join(l["name"] for l in i["labels"]),
            (i["milestone"] or {}).get("title", ""),
            "|".join(a["login"] for a in i["assignees"]),
            i["createdAt"], i["updatedAt"], i["closedAt"] or "",
            i["url"], (i["body"] or "").replace("\n", " ")[:100],
        ])
PY
```

`closed_at` é o que alimenta burndown. Export de sprint: acrescente
`--milestone "<nome>" --state all`.

## 7. Erros comuns

| Sintoma | Causa | Ação |
|---|---|---|
| `gh: Not Found` | `GITHUB_REPO` errado, ou token sem acesso ao repo privado | confira `gh repo view -R "$GITHUB_REPO"` |
| `HTTP 403 rate limit` | muitas chamadas unitárias | use export em lote, não loop de `issue view` |
| Milestone não aparece no `issue create` | título diferente (acento, espaço) | copie do `gh api .../milestones` |
| Corpo com `\n` literal | `--body` inline | use `--body-file` |
| Label não aplicada | label inexistente no repo | `gh label list` antes; criar exige aprovação |
