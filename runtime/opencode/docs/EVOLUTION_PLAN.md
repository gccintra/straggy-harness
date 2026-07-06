# Plano de Evolução — Workflow de Product Ops

Roadmap para evoluir o harness (11 agents, 21 skills). **Premissa: humano no
meio.** Nada de rotinas/cron/eventos nem execução autônoma — o usuário dispara
cada etapa na mão. Objetivo: deixar **cada invocação manual mais inteligente e
confiável**, não tirar o humano do processo.

## Princípio
Não automatizar o *disparo* (é do humano). Automatizar o *trabalho pesado dentro
de cada etapa*: mais contexto carregado sozinho, menos perguntas, portão de
qualidade quando o usuário pedir.

---

## Tier 0 — Correções concretas (baratas, fazer primeiro)

### 0.1 Bug de caminho de CSV 🔴
Harness manda salvar CSV em `data/`, mas os CSVs reais estão em
`docs/backlog-data/`. ~27 refs (`backlog` agent + skills `backlog-analysis`/
`backlog-health`/`backlog-prioritization`/`backlog-issue-creator` + README +
CHEAT_SHEET). → padronizar tudo em **`docs/backlog-data/`** (onde os dados já estão).

### 0.2 Agents não usam o corpus `md/` sincronizado 🟡
10 agents dizem "leia `docs/context_docs/`" genérico. Agora há 271 HUs + Regras em
`md/` greppável. Apontar explícito pra `md/HUs/` (grep por módulo) e `md/Regras/`.
Já ajustados: tech-lead, tech-qa, documenter, wiki. Faltam: **discovery,
issue-creator, product-manager, backlog, product-designer, designer**.

### 0.3 Alinhamento dos fluxos do `issue-creator` (Create vs Refine) 🔴
**Sintoma:** usuário cria a issue direto no GitLab (só título), pede "cria a
descrição da #NNN" → a palavra "criar" dispara **Flow 1 Create**, que tenta abrir
issue nova do zero. Conflito, porque a issue já existe.

**Causa raiz:** a detecção de fluxo (skill `backlog-issue-creator`, seção 2)
decide pelo **verbo** do usuário, não pelo **estado da issue**.

**Correção:**
1. Prioridade de detecção = **existência da issue, não o verbo.** Se há
   `#NNN` / URL / "essa issue" referenciada → **sempre Refine**, mesmo que o
   usuário diga "criar". Create só quando NÃO existe issue.
2. Reenquadrar o Flow 2 (Refine) para cobrir explicitamente o caso "issue criada
   direto no GitLab, só com título, preciso da **descrição inicial completa**" —
   mesma profundidade e template do Create, mas escrevendo NA issue existente
   (não criando outra).
3. Espelhar a regra no agent `issue-creator` (mesma moldura Create/Refine).

### 0.4 Caminho do arquivo de priorização 🟢
Todos os agents re-descobrem o arquivo de priorização por "procure por arquivo que
descreva fórmula…" — custo de token toda sessão. Padronizar o caminho exato:
`docs/context_docs/sistema_priorizacao_funcionamento.md`.

---

## Tier 1 — Confiança

### 1.1 `@reviewer` (novo) — portão de qualidade sob demanda
Invocado pelo usuário ("revisa essa HU", "checa essas regras"). Valida:
- HU/HT: seções completas, critérios de aceite **testáveis**.
- RN/RA/MSG: sem duplicata/contradição vs corpus `md/Regras/`.
- `.docx` vs `.md`: transcrição fiel (diff).

### 1.2 Evals nos geradores críticos
Só `backlog-issue-creator` e `backlog-prioritization` têm evals. Adicionar a
`doc-consolidator`, `hu-generator`, `ht-generator`, `gerar-regras`, `discovery`.
Qualidade de *dev* (roda ao mexer na skill), não automação de runtime.

---

## Tier 2 — Cada etapa mais inteligente (dispara você, trabalha o agent)

| Alvo | Hoje | Evolução |
|---|---|---|
| `issue-creator` | cria sem checar duplicata | **dupe-check** contra issues GitLab + `md/HUs` antes de criar |
| `discovery` | "carregar contexto relevante" (vago) | **grep dirigido em `md/HUs/` por módulo** + auto-puxar HUs relacionadas + consultar `@tech-lead`/DB sozinho |
| `product-manager` | mapa de decisão estático | **detecta a fase da issue** (lê comentários) e **sugere** o próximo passo — você dispara |
| `gerar-regras` / `documenter` | cruza regras parcial | grep no `md/Regras/` completo → reúso/conflito de RN |
| `tech-qa` / `tech-lead` | lê context genérico | grep no corpus `md/` + **cita a HU fonte** |
| skills sem `references/` | — | `gerar-regras`, `ht-generator`, `discovery` ganham templates de referência |

---

## Tier 3 — Novos agents (todos invocados por você)

| Agent novo | Papel |
|---|---|
| `@reviewer` | (Tier 1.1) valida saídas quando pedido |
| `@sprint-planner` | Propõe montagem de sprint do backlog priorizado + capacidade — você aprova/ajusta |
| `@metrics` | Sob pedido pós-entrega: puxa adoção/uso do DB, diz se moveu a métrica |

Cortados (automação autônoma, fora da régua atual): `@orchestrator` em modo auto,
`@triage` de inbox, rotinas cron, disparo por evento de MR/issue.

---

## Sequência recomendada
1. **Tier 0** — correções concretas (bug CSV, md pointers, alinhamento issue-creator, priorização).
2. **Tier 1** — reviewer + evals (confiança nas saídas).
3. **Tier 2** — inteligência por etapa explorando o corpus `md/`.
4. **Tier 3** — novos agents conforme a necessidade.

Nada roda sozinho. Tudo espera você pedir.
