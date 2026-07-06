# Product Ops Harness

Harness de product ops para o projeto ITL — Sistema de Gerenciamento de Cursos (SEST SENAT). Roda sobre o OpenCode e orquestra o ciclo completo de produto — da captura de demanda ao design, documentação formal, análise de backlog, changelog e wiki — usando agentes especializados, skills e o GitLab como fonte de verdade.

---

## Arquitetura

```
Agentes (quem faz)          Skills (como faz)               Fontes de verdade
───────────────             ───────────────                 ─────────────────
@product-manager            backlog-issue-creator           GitLab (issues, labels, milestones)
@tech-lead                  discovery                       docs/context_docs/ (produto)
@product-designer           gerar-regras / doc-consolidator history/ (decisões)
                            hu-generator / ht-generator     Banco de homologação (DB_CONNECT_CMD)
                            glab-backlog (core)
                            backlog-analysis / -health
                            backlog-prioritization
                            changelog-generator
                            gitlab-sprint-ops / gitlab-wiki
                            sprint-goal-generator
                            design-setup / design-screen
                            html-to-figma / frontend-design
                            figma-implement-design
                            db-query
```

**São 3 agentes primary.** Cada um executa direto carregando a skill certa — **não há subagentes** (cada Task seria um cold start que relê contexto e queima token). Se o pedido foge do escopo do agente aberto, ele responde e aponta para qual agente pedir; não abre outro por baixo.

**Agente:** decide o que fazer e carrega a skill.  
**Skill:** contém o fluxo detalhado, templates e comandos (carregada sob demanda — progressive disclosure).

---

## Agentes

**3 agentes primary.** O ponto de entrada padrão do dia a dia é o `@product-manager`. Cada agente executa direto, carregando a skill certa conforme o pedido — não há subagentes. Fora do escopo → o agente aponta para quem pedir.

| Agente | Papel | Quando usar | Skills que carrega |
|---|---|---|---|
| `@product-manager` | PO — ponto de entrada universal de produto | Qualquer demanda de produto/backlog/processo: criar/refinar issue, discovery, regras, HU/HT, análise e saúde de backlog, priorização, sprint ops, meta, changelog, wiki, dúvida de produto | `backlog-issue-creator`, `discovery`, `gerar-regras`, `doc-consolidator`, `hu-generator`/`ht-generator`, `backlog-analysis`, `backlog-health`, `backlog-prioritization`, `gitlab-sprint-ops`, `sprint-goal-generator`, `changelog-generator`, `gitlab-wiki`, `glab-backlog` |
| `@tech-lead` | Viabilidade, dados reais, HTs, arquitetura | "Como funciona X de verdade?", "O que está no banco para Y?", impacto/risco técnico, discovery técnico, gerar HT | `db-query`, `discovery`, `gerar-regras`, `doc-consolidator`, `ht-generator`, `backlog-analysis`, `backlog-health` |
| `@product-designer` | Design — telas, design system, protótipos | Criar tela no Figma, setup/atualizar guidelines, protótipo, wireframe, consistência visual | `design-setup`, `design-screen`, `html-to-figma`, `frontend-design`, `figma-implement-design` |

> HU é do `@product-manager`; HT pode ser do `@product-manager` ou do `@tech-lead`. Ambos seguem os mesmos portões humanos: `regras → .md → (sob pedido) .docx`.

---

## Skills — por domínio

### Core (pré-requisito para muitas skills)

| Skill | Função |
|---|---|
| `glab-backlog` | Referência completa de comandos `glab` para GitLab — issues, milestones, labels, boards, todos. PRÉ-REQUISITO para toda operação no GitLab. |

### Captura e Discovery

| Skill | Função |
|---|---|
| `backlog-issue-creator` | Dual flow: Create (nova issue com triage MoSCoW) e Refine (enriquecer issue rasa). Templates com HISTÓRIA, PROBLEMA, EVIDÊNCIAS DA DEMANDA. |
| `discovery` | Double Diamond: 4 fases → 4 comentários na issue. D1 explora/define problema. D2 explora/define solução. Priorização progressiva. |

### Documentação Formal

| Skill | Função |
|---|---|
| `doc-consolidator` | **Fonte de verdade.** Gera o `.md` consolidado por issue: descrição + regras (texto completo) + trilha de discovery. Base do `.docx`. Modelo pesado escreve o `.md`; modelo leve gera o `.docx` a partir dele. |
| `hu-generator` | Transcreve o `.md` consolidado para História de Usuário (.docx) — 7 seções. Seção 5 leva só os rótulos das regras. |
| `ht-generator` | Gera História Técnica (.docx) no padrão do projeto — 6 seções. Para débito técnico, infra, migração, refatoração. |
| `gerar-regras` | Gera RN, RA e MSG no padrão oficial do projeto com separação estrita de domínio/interface. |

### Análise e Saúde do Backlog

| Skill | Função |
|---|---|
| `backlog-analysis` | Export via `glab api --paginate` + jq → CSV → relatório Markdown com métricas, scores e gráficos texto. |
| `backlog-health` | Auditoria: issues sem tipo/prioridade/sprint/assignee, duplicatas por similaridade, zumbis (>6 meses sem update). |
| `backlog-prioritization` | Ranqueamento MoSCoW → I×E → ICE. Detecta anomalias (label errada, ICE inconsistente). Gera markdown em `history/analyses/`. |

### Gestão de Sprint

| Skill | Função |
|---|---|
| `gitlab-sprint-ops` | Criar milestone, fechar sprint com sumário, mover issues entre sprints em lote. |
| `sprint-goal-generator` | Gera Sprint Goal no padrão Scrum Guide 2020 — foco em outcome, não em output. |

### Changelog e Wiki

| Skill | Função |
|---|---|
| `changelog-generator` | Gera/atualiza o Histórico de Evolução (tabela Markdown padrão do projeto, nome em project-configSIM). |
| `gitlab-wiki` | Cria/atualiza páginas na wiki do GitLab via `glab api`. Detecta páginas existentes; suporta append ou replace. |

### Design

| Skill | Função |
|---|---|
| `design-setup` | Cria o design system no Figma a partir de prints do sistema. Extrai tokens de cor, tipografia, espaçamento, componentes. |
| `design-screen` | Cria telas/componentes no Figma a partir de issue, HU ou descrição. Copia tokens e componentes dos guidelines. |
| `html-to-figma` | Cria tela HTML com design system e insere no Figma via captura. |
| `frontend-design` | Interfaces frontend com alta qualidade visual e acessibilidade. |
| `figma-implement-design` | Traduz nodes do Figma para código de produção com fidelidade 1:1. |

### Banco de Dados

| Skill | Função |
|---|---|
| `db-query` | Executa SQL no banco de homologação via CLI (`sqlcmd`, `psql`, `mysql`, etc.) configurado no `.env`. Suporta NTLM, Kerberos, `.pgpass`. |

---

## Fluxo Principal — Ciclo Completo de uma Demanda

Todo o ciclo roda no `@product-manager` (parte técnica pode ir ao `@tech-lead`), carregando a skill de cada etapa:

```
[Captura]              [Diamond 1 — Problema]          [Diamond 2 — Solução]         [Documentação]
backlog-issue-creator →D1a Explorar  →  D1b Definir  →  D2a Explorar  →  D2b Definir  →  doc-consolidator
   (Flow 1/2)          (Comentário 1)   (Comentário 2)   (Comentário 3)   (Comentário 4)   (.md → .docx + RN/RA)
```

### 1. Captura do Problema — skill `backlog-issue-creator`

**Flow 1 — Create:** nova issue do zero.
- Entrevista o usuário (2-4 perguntas)
- Preenche template com HISTÓRIA DE USUÁRIO, PROBLEMA, EVIDÊNCIAS DA DEMANDA
- Aplica triage **MoSCoW apenas** (ICE calculado no discovery depois)
- Critical bug: bypassa MoSCoW → MUST + label CRITICAL
- Cria no GitLab com labels e workflow label

**Flow 2 — Refine:** enriquecer issue existente com info rasa.
- Lê a issue, identifica gaps, entrevista para preencher
- Atualiza a descrição — foco exclusivo no problema

**Estrutura da descrição (Feature):**
```
# [TITLE] - [MODULO]
## HISTÓRIA DE USUÁRIO       ← congelada após criação/refinamento
## PROBLEMA                  ← congelado após criação/refinamento
## EVIDÊNCIAS DA DEMANDA     ← volume, origem, quem pediu, links
## Outros
   PRIORIZACAO               ← atualizado em: criação → D1b → D2b
   CONTEXTO & DISCOVERY      ← módulo, épico, relacionadas, dependências
```

### 2. Diamond 1 — Espaço do Problema — skill `discovery`

O discovery detecta automaticamente em qual fase a issue está (lendo comentários) e propõe a próxima.

#### D1a — Exploração (Diverge) → Comentário 1 `[D1 · Exploração do Problema]`
- Lê `docs/context_docs/`, busca issues relacionadas
- Mapeia: quem é afetado, contexto existente, hipóteses, perguntas em aberto

#### D1b — Definição (Converge) → Comentário 2 `[D1 · Definição do Problema]`
- Problem Statement claro, causa raiz, critérios de sucesso, non-goals
- Calcula **MoSCoW + Impacto + Confiança** (Facilidade no D2b)
- **Atualiza** bloco PRIORIZACAO na descrição + labels

### 3. Diamond 2 — Espaço da Solução — skill `discovery`

#### D2a — Exploração (Diverge) → Comentário 3 `[D2 · Exploração das Soluções]`
- **Sempre ≥ 2 soluções** com trade-offs (prós, contras, complexidade)
- Análise comparativa quando múltiplas candidatas
- Para épicos: propõe decomposição em HUs/HTs

#### D2b — Definição (Converge) → Comentário 4 `[D2 · Definição da Solução]`
- Fluxo do sistema (passo a passo, pré/pós-condições)
- Telas e campos (tipo, obrigatoriedade, validações)
- RN/RA rascunhadas (formalizar com `gerar-regras` depois)
- Critérios de Aceite verificáveis
- Escopo (inclui / não inclui) + Decomposição com estimativas
- Calcula **ICE completo** (Impacto × Confiança × Facilidade)
- **Atualiza** bloco PRIORIZACAO + labels
- **Registra** `history/discoveries/YYYY-MM-DD_discovery_issue-NNN.md`

### 4. Documentação Formal — skills `doc-consolidator` → `hu-generator`/`ht-generator`

Fonte primária: **Comentário 4** (`[D2 · Definição da Solução]`). Duas etapas:

**4a. `.md` consolidado (modelo pesado) — `doc-consolidator`**
- Lê issue + comentários D1a→D2b + `history/discoveries/` + regras da issue (`outputs/{ID}_*/{ID}_regras.md`)
- Formaliza RN/RA/MSG (numeração sequencial), salva em `outputs/{ID}_{Nome}/{ID}_regras.md`
- Escreve `outputs/{ID}_{NomeCurto}/{HU|HT}{ID}_{TOKEN}_{Nome}.md` — seções do docx com regras de **texto
  completo** + apêndice com a trilha de discovery. **Fonte de verdade.** (Tudo da issue na mesma pasta.)

**4b. `.docx` (modelo leve) — `hu-generator` / `ht-generator`**
- Lê o `.md` consolidado (não relê o discovery) e **transcreve** para `.docx` (7 seções HU / 6 HT)
- Seção 5 leva só os **rótulos** das regras (`RN_XXXX — Título`)

### Priorização Progressiva

| Momento | Skill | O quê | Atualiza |
|---|---|---|---|
| Criação | `backlog-issue-creator` | MoSCoW apenas | Labels |
| D1b | `discovery` | MoSCoW + Impacto + Confiança | PRIORIZACAO na descrição + labels |
| D2b | `discovery` | ICE completo + MoSCoW final | PRIORIZACAO na descrição + labels |

**Quadrantes ICE:**
- QUICK WIN: Impacto ≥ 7 e Facilidade ≥ 5
- PLAN: Impacto ≥ 7 e Facilidade ≤ 4
- LATER: Impacto ≤ 6 e Facilidade ≥ 5
- DROP: Impacto ≤ 6 e Facilidade ≤ 4

---

## Fluxo de Design

```
@product-designer   →   setup?   →   design-setup   →  guidelines no Figma
                        screen?  →   design-screen  →  HTML → preview local (PARA) → (sob pedido) Figma
```

- **Setup:** criar design system a partir de screenshots do sistema atual
- **Screen:** criar tela copiando tokens/componentes dos guidelines. Padrão: HTML → preview local; push pro Figma só sob pedido explícito ("manda pro Figma")
- **Implementação:** `figma-implement-design` para traduzir Figma → código

---

## Fluxo de Backlog

```
@product-manager (backlog)
  ├── análise de sprint → backlog-analysis        → export CSV → relatório em history/analyses/
  ├── saúde do backlog  → backlog-health          → auditoria → relatório + correções em lote
  ├── priorização       → backlog-prioritization  → ranking I×E → markdown em history/analyses/
  ├── sprint ops        → gitlab-sprint-ops       → criar/fechar/mover milestones
  └── meta da sprint    → sprint-goal-generator   → Sprint Goal (outcome)
```

---

## Fluxo de Changelog e Wiki

`@product-manager` — executa direto:

```
changelog  →  changelog-generator  →  entrada formatada → wiki (gitlab-wiki)
wiki       →  gitlab-wiki          →  página na wiki do GitLab
```

---

## Regras de Ouro

1. **Descrição da issue = problema congelado.** HISTÓRIA, PROBLEMA e EVIDÊNCIAS nunca são alterados após criação/refinamento. Só o bloco PRIORIZACAO é atualizado pelo discovery.
2. **Soluções e discovery vivem nos comentários.** A descrição foca no problema; os 4 comentários documentam a evolução.
3. **ICE nunca é calculado na criação.** Facilidade só é estimável após a solução ser definida no D2b.
4. **Comentário 4 é o handoff para a documentação.** Sem ele, regras/.md/.docx não podem ser gerados.
5. **Skip de fase requer aprovação explícita.** O discovery nunca pula fases silenciosamente.
6. **Critical bug bypassa tudo.** MUST + label CRITICAL + sprint atual — sem MoSCoW, sem discovery moroso.
7. **Sempre ao menos 2 soluções no D2a.** Uma proposta única não é discovery — é decisão unilateral.

---

## Configuração do Ambiente

Todas as variáveis lidas do arquivo `.env` na raiz do projeto:

```env
GITLAB_HOST=git179.websis.com.br
GITLAB_URI=https://git179.websis.com.br
GITLAB_REPO=sest2/itl

DB_ENABLED=true
DB_CONNECT_CMD=sqlcmd -S ... -Q "$DB_QUERY"

FIGMA_FILE_KEY=...
FIGMA_GUIDELINES_NODE_ID=...
```

---

## Estrutura de Diretórios

```
.opencode/
├── agents/              ← 3 agentes primary (sem subagentes)
│   ├── product-manager.md   ← PO — ponto de entrada universal (issues, discovery, docs, backlog, wiki, changelog)
│   ├── tech-lead.md         ← Viabilidade, dados reais, HTs, arquitetura
│   └── product-designer.md  ← Telas, design system, protótipos (HTML → preview local → Figma)
├── skills/              ← Skills com fluxos detalhados
│   ├── glab-backlog/        ← Core: referência de comandos glab
│   ├── backlog-issue-creator/  ← Dual flow create/refine
│   ├── discovery/           ← Double Diamond
│   ├── doc-consolidator/         ← Gera .md consolidado (fonte de verdade)
│   ├── hu-generator/   ← Transcreve .md → .docx de HU
│   ├── ht-generator/   ← Transcreve .md → .docx de HT
│   ├── gerar-regras/   ← Gera RN/RA/MSG
│   ├── backlog-analysis/    ← Métricas de sprint
│   ├── backlog-health/      ← Auditoria de saúde
│   ├── backlog-prioritization/  ← Ranking I×E
│   ├── gitlab-sprint-ops/   ← Gestão de milestones
│   ├── sprint-goal-generator/   ← Meta da sprint
│   ├── changelog-generator/ ← Entradas de changelog
│   ├── gitlab-wiki/         ← Páginas na wiki
│   ├── db-query/            ← Consultas SQL
│   ├── design-setup/        ← Design system no Figma
│   ├── design-screen/       ← Telas no Figma
│   ├── html-to-figma/       ← HTML → Figma
│   ├── frontend-design/     ← Interfaces frontend
│   └── figma-implement-design/  ← Figma → código
├── README.md            ← Este arquivo
├── CHEAT_SHEET.md       ← Referência rápida
└── opencode.json        ← Configuração do OpenCode

docs/
└── context_docs/        ← INPUT — documentação de produto mantida por humanos
    ├── onepage/         ← (opcional) ONEPAGE.md
    ├── md/HUs/          ← HUs de referência (.md, sincronizadas do Google Drive)
    ├── md/Regras/       ← regras de negócio (.md, sincronizadas do Google Drive)
    ├── _raw/            ← cache binário do sync (.docx/.pdf) — descartável
    └── priorizacao.md   ← sistema_priorizacao_funcionamento.md

history/                 ← REGISTROS — gerados por agentes, commitados para auditoria
├── discoveries/         ← 2026-05-22_discovery_issue-782.md
├── rules/               ← 2026-05-24_regras_issue-795.md
└── analyses/            ← relatórios de sprint, auditorias, priorizações

data/                    ← DADOS — CSVs exportados do GitLab
└── YYYY-MM-DD_backlog-export.csv

outputs/                 ← ENTREGÁVEIS — artefatos finais (não commitado)
├── md/                  ← HU003.22_{TOKEN}_*.md (fonte de verdade, base do .docx)
└── docx/                ← HU003.22_{TOKEN}_*.docx
```
