---
name: backlog-health
description: >
  Audita a saúde do backlog detectando issues sem tipo, sem prioridade, sem sprint,
  sem assignee, possíveis duplicatas por similaridade de título e issues "zumbis"
  (abertas há mais de 6 meses sem atualização). Exporta os dados via glab + jq em
  uma única chamada, salva o CSV no repositório, e gera um relatório de saúde com
  recomendações e opção de correções em lote. Use quando o usuário pedir para limpar
  o backlog, encontrar inconsistências, ver duplicatas ou auditar a qualidade das issues.
  IMPORTANTE: Carregue obrigatoriamente a skill `glab-backlog` antes de qualquer operação no GitLab.
---

**PRÉ-REQUISITO:** Carregar a skill `glab-backlog` antes de qualquer operação no GitLab.

# backlog-health

Audita a qualidade estrutural do backlog inteiro — detecta issues sem tipo, sem prioridade, sem sprint, possíveis duplicatas e zumbis.

**Esta skill usa export CSV porque precisa varrer todas as issues abertas de uma vez.** Para operações pontuais (corrigir uma issue específica, ver o estado de uma issue), use `glab` direto — não acione esta skill.

**Quando usar esta skill:**
- "Limpar o backlog" / "auditar o backlog" / "ver a saúde do backlog"
- Detectar duplicatas ou inconsistências no backlog inteiro
- Identificar issues abandonadas há meses
- Gerar um relatório de qualidade do backlog

**Princípio de implementação:** exportar uma vez via `glab api --paginate` + `jq`, analisar o arquivo local, propor ações em lote — nunca executar nada sem aprovação do usuário.

---

## 1. Configuração

```
GITLAB_HOST:  ${GITLAB_HOST}
GITLAB_URI:   ${GITLAB_URI}
GITLAB_REPO:  ${GITLAB_REPO}
DATA_DIR:     data/
HISTORY_DIR:  history/analyses/
```

---

## 2. Exportar dados completos

A auditoria precisa de mais campos do que a análise padrão — inclua timestamps e descrição resumida para detectar zumbis e duplicatas.

```bash
REPO_ENCODED="${GITLAB_REPO//\//\%2F}"

glab api --paginate \
  "projects/${REPO_ENCODED}/issues?state=opened&per_page=100" \
  --hostname ${GITLAB_HOST} \
  | jq -r '
    ["IID","Título","Labels","Milestone","Assignees","Autor","Criada em","Atualizada em","Web URL","Descrição (100 chars)"],
    (.[] | [
      .iid,
      .title,
      (.labels | join("|")),
      (if .milestone then .milestone.title else "" end),
      (.assignees | map(.username) | join("|")),
      .author.username,
      .created_at,
      .updated_at,
      .web_url,
      (.description // "" | .[0:100] | gsub("\n";" "))
    ]) | @csv
  ' > data/health_audit_$(date +%Y-%m-%d).csv
```

Verifique o resultado:
```bash
wc -l data/health_audit_$(date +%Y-%m-%d).csv
```

---

## 3. Detectar problemas

Leia o CSV e classifique cada issue nos grupos abaixo. Uma issue pode estar em múltiplos grupos.

### 3.1 Sem tipo

Issues sem nenhuma label com prefixo de tipo (ex: `TIPO::`, `TYPE::` — identifique o prefixo correto consultando `glab label list -R ${GITLAB_REPO}`).

### 3.2 Sem prioridade

Issues sem nenhuma label com prefixo de prioridade (ex: `PRIORIDADE::`, `PRIORITY::`).

### 3.3 Sem sprint / milestone

Issues sem milestone alocada.

### 3.4 Sem assignee

Issues sem nenhum responsável.

### 3.5 Zumbis

Issues abertas com `updated_at` há mais de **180 dias** em relação à data de hoje. Calcule a diferença em dias para cada issue.

### 3.6 Possíveis duplicatas

Agrupe issues com títulos semanticamente similares. Critério prático: títulos que compartilham as mesmas 3+ palavras significativas (excluindo artigos, preposições e palavras genéricas como "criar", "adicionar", "corrigir").

Apresente os grupos suspeitos ao usuário para validação — **nunca feche ou edite issues sem confirmação explícita**.

---

## 4. Gerar o relatório de saúde

Salve em `history/analyses/YYYY-MM-DD_health_audit.md`:

```markdown
# [HEALTH] Auditoria do Backlog
Data: YYYY-MM-DD
Fonte: data/health_audit_YYYY-MM-DD.csv
Issues auditadas: N (todas abertas)

## Resumo executivo

| Problema | Issues afetadas | % do backlog |
|---|---|---|
| Sem tipo | N | XX% |
| Sem prioridade | N | XX% |
| Sem sprint | N | XX% |
| Sem assignee | N | XX% |
| Zumbis (>180 dias) | N | XX% |
| Possíveis duplicatas | N grupos | — |

## Zumbis (abertas há mais de 180 dias sem atualização)

| IID | Título | Dias sem atualização | URL |
|---|---|---|---|
| #NNN | [título] | N dias | [url] |

## Possíveis duplicatas

### Grupo 1 — [tema em comum]
| IID | Título | Criada em |
|---|---|---|
| #NNN | [título] | YYYY-MM-DD |
| #NNN | [título] | YYYY-MM-DD |

> Sugestão: manter #NNN (mais completa) e fechar as demais como duplicata.

## Issues sem tipo (amostra — top 15 mais antigas)

| IID | Título | Criada em |
|---|---|---|
| #NNN | [título] | YYYY-MM-DD |

## Issues sem prioridade (amostra — top 15 mais antigas)

| IID | Título | Criada em |
|---|---|---|
| #NNN | [título] | YYYY-MM-DD |

## Recomendações de ação

1. **Imediato:** [ação mais urgente com número de issues afetadas]
2. **Esta semana:** [segunda ação]
3. **Backlog grooming:** [terceira ação]
```

---

## 5. Propor correções em lote

Após apresentar o relatório, ofereça ao usuário as ações em lote disponíveis:

```
Ações disponíveis:
[A] Fechar issues zumbis (>180 dias) — N issues
[B] Fechar issues marcadas como duplicatas pelo usuário
[C] Aplicar label de tipo em issues sem tipo (usuário informa qual label)
[D] Nenhuma ação agora — apenas relatório
```

**Aguarde a resposta do usuário antes de executar qualquer ação.**

### Executar correção em lote (apenas após aprovação)

Para fechar issues em lote, use o `glab-backlog` como referência de comandos:

```bash
# Fechar uma issue
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab issue close NNN -R ${GITLAB_REPO}

# Adicionar label a uma issue
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab issue update NNN -R ${GITLAB_REPO} -l "LABEL_NAME"
```

Para lotes grandes, execute sequencialmente e reporte o progresso a cada 10 issues.

Registre cada ação executada em lote no relatório de saúde (seção "Ações executadas").

---

## 6. Regras de ouro

- Nunca feche, edite ou mescle issues sem aprovação explícita do usuário
- Duplicatas são sugestões — o usuário valida antes de qualquer ação
- Zumbis podem ter razão de existir — apresente a lista e deixe o usuário decidir
- O CSV exportado é a fonte de verdade da auditoria — nunca altere o arquivo após a análise
