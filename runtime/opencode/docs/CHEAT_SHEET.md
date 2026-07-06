# Cheat Sheet — Product Ops Harness

Referência rápida de todo o harness. Para detalhes completos: `README.md`.

---

## Triggers — Qual Agente para Cada Intenção

São **3 agentes primary**. Cada um executa direto carregando as skills — não há subagentes.

| Intenção | Agente |
|---|---|
| **Qualquer coisa de produto (sem saber)** | `@product-manager` |
| Registrar bug ou feature nova | `@product-manager` |
| Enriquecer issue que só tem título | `@product-manager` (`refinar #NNN`) |
| Fazer / continuar discovery de uma issue | `@product-manager #NNN` |
| Gerar regras / HU / HT (.md → .docx) | `@product-manager` (HT também pelo `@tech-lead`) |
| Análise de sprint / saúde / priorização / sprint ops / meta / buscar issues | `@product-manager` |
| Criar/atualizar página na wiki / registrar changelog | `@product-manager` |
| Dúvida de produto / fluxo / regra | `@product-manager` (produto) ou `@tech-lead` (técnico) |
| Dados reais do banco / viabilidade técnica / impacto no sistema / HT técnica | `@tech-lead` |
| Criar tela / design system / guidelines / protótipo / wireframe no Figma | `@product-designer` |

Fora do escopo do agente aberto → ele responde e aponta para quem pedir (não abre outro agente por baixo).

---

## Agentes e Skills — Mapa Rápido

Cada agente carrega a skill certa conforme o pedido (progressive disclosure — só carrega quando precisa).

| Agente | Carrega estas skills |
|---|---|
| `@product-manager` | Issues: `backlog-issue-creator` + `glab-backlog` · Discovery: `discovery` · Docs: `gerar-regras`, `doc-consolidator`, `hu-generator`/`ht-generator` · Backlog: `backlog-analysis`, `backlog-health`, `backlog-prioritization`, `gitlab-sprint-ops`, `sprint-goal-generator` · Wiki/changelog: `gitlab-wiki`, `changelog-generator` |
| `@tech-lead` | `db-query` · `discovery` · `gerar-regras`, `doc-consolidator`, `ht-generator` · `backlog-analysis`, `backlog-health` |
| `@product-designer` | `design-setup` ou `design-screen` (+ `html-to-figma` + `frontend-design`) · `figma-implement-design` |

---

## Double Diamond — Fases e Outputs

```
PROBLEMA                              SOLUÇÃO
◇ D1a Explorar → ◆ D1b Definir  →  ◇ D2a Explorar → ◆ D2b Definir
  Comentário 1     Comentário 2        Comentário 3     Comentário 4
                   + PRIORIZACAO                        + PRIORIZACAO
                     atualizado                           (ICE final)
                   + labels                             + labels
```

| Fase | Marcador no Comentário | Conteúdo principal |
|---|---|---|
| D1a | `[D1 · Exploração do Problema]` | Fontes, afetados, contexto existente, hipóteses, perguntas abertas |
| D1b | `[D1 · Definição do Problema]` | Problem Statement, causa raiz, critérios de sucesso, non-goals, MoSCoW+Impacto+Confiança |
| D2a | `[D2 · Exploração das Soluções]` | 2-4 soluções com trade-offs, tabela comparativa |
| D2b | `[D2 · Definição da Solução]` | Fluxo, telas/campos, RN/RA rascunho, CAs, escopo, ICE completo, decomposição |

**Skip de fase:** requer avaliação + pergunta + aprovação explícita do usuário. Nunca silencioso.

---

## Priorização — Quando Calcular o Quê

| Momento | Calcula | Não calcula |
|---|---|---|
| Criação (skill `backlog-issue-creator`) | MoSCoW | Impacto, Confiança, Facilidade, ICE |
| D1b (`discovery`) | MoSCoW review + Impacto + Confiança | Facilidade, ICE |
| D2b (`discovery`) | Facilidade + ICE completo + MoSCoW final | — |

**ICE = Impacto × Confiança × Facilidade** (escala 1-10 cada → 1-1000)

**Quadrantes ICE:**
- **QUICK WIN:** Impacto ≥ 7 e Facilidade ≥ 5
- **PLAN:** Impacto ≥ 7 e Facilidade ≤ 4
- **LATER:** Impacto ≤ 6 e Facilidade ≥ 5
- **DROP:** Impacto ≤ 6 e Facilidade ≤ 4

**MoSCoW:**
- **MUST:** Inegociável — sem isso a entrega não faz sentido
- **SHOULD:** Importante, mas o produto sobrevive sem por um tempo
- **COULD:** Nice to have — valor marginal
- **WONT:** Válido, mas fora deste ciclo

---

## Estrutura da Issue — O que Fica Onde

```
Descrição da issue                      Comentários
─────────────────                      ──────────
# [TITLE] - [MODULO]                  ┌─ Comentário 1: [D1 · Exploração]
## HISTÓRIA DE USUÁRIO    ← congelada  │
## PROBLEMA               ← congelado  ├─ Comentário 2: [D1 · Definição]
## EVIDÊNCIAS DA DEMANDA  ← congelada  │
## Outros                              ├─ Comentário 3: [D2 · Exploração]
   PRIORIZACAO  ← atualizado em D1b/D2b│
   CONTEXTO     ← preenchido na criação└─ Comentário 4: [D2 · Definição]
```

**Regra:** o discovery nunca altera HISTÓRIA, PROBLEMA ou EVIDÊNCIAS. Só toca PRIORIZACAO.

---

## Comandos glab Frequentes

```bash
# Ver uma issue
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab issue view NNN -R ${GITLAB_REPO}

# Ler comentários de uma issue
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab api "projects/${GITLAB_REPO//\//%2F}/issues/NNN/notes" \
  --paginate | jq '.[] | {id: .id, excerpt: (.body | .[0:120])}'

# Postar comentário
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab issue note create NNN -R ${GITLAB_REPO} -m "[texto]"

# Atualizar descrição
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab issue update NNN -R ${GITLAB_REPO} -d "[descrição completa]"

# Atualizar labels
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab issue update NNN -R ${GITLAB_REPO} -l "label1,label2"

# Criar issue
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab issue create -R ${GITLAB_REPO} -t "[título]" -d "[descrição]" -l "[labels]" -y

# Buscar issues
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab issue list -R ${GITLAB_REPO} --search "[termo]" -A -t issue -P 20

# Listar labels
glab label list -R ${GITLAB_REPO}

# Listar milestones
glab milestone list -R ${GITLAB_REPO}

# Export issues para CSV (backlog-analysis / health / prioritization)
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab api "projects/${GITLAB_REPO//\//%2F}/issues?per_page=100" --paginate > /tmp/issues.json
jq -r '...' /tmp/issues.json > data/issues_$(date +%Y-%m-%d).csv

# Postar via API REST (fallback se glab issue note create não funcionar)
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab api "projects/${GITLAB_REPO//\//%2F}/issues/NNN/notes" \
  -X POST -f body="[conteúdo]"
```

---

## Fluxo de Documentação

`@product-manager` (ou `@tech-lead` para HT) — executa direto, com portões humanos:

```
"documenta a #NNN"
   ↓
Lê issue + Comentário 4 [D2 · Definição]  ← fonte principal
   ↓
Determina: HU (tem persona) ou HT (técnica)
   ↓
Regras: navega md/Regras/ (verdade) + outputs/*/*_regras.md → gerar-regras → usuário aprova
   ↓
.md consolidado (doc-consolidator) em outputs/{ID}_{NomeCurto}/  ← PARA para revisão humana
   ↓
(só sob pedido explícito, depois do .md revisado)
   ↓
.docx (hu-generator ou ht-generator) — só transcreve o .md
```

Um pedido = um passo. `.docx` errado → corrija o `.md` e regere, nunca edite o `.docx` à mão.

---

## Fluxo de Design

`@product-designer` — executa direto. Padrão: HTML → preview local (PARA) → Figma só sob pedido.

```
@product-designer
   ├── "cria design system"  →  design-setup
   │     Envia screenshots → extrai tokens → cria guidelines no Figma
   │
   ├── "cria tela X"         →  design-screen
   │     Lê issue/HU/descrição → copia tokens dos guidelines → HTML → preview local
   │     → (sob pedido "manda pro Figma") insere no Figma via html-to-figma
   │
   └── "implementa design"   →  figma-implement-design
         Traduz node do Figma para código de produção
```

---

## Fluxo de Backlog

`@product-manager` — executa direto:

```
@product-manager (backlog)
   ├── análise de sprint    →  backlog-analysis
   │     export CSV → relatório Markdown → history/analyses/
   │
   ├── saúde do backlog     →  backlog-health
   │     auditoria → relatório com inconsistências, duplicatas, zumbis
   │
   ├── priorização          →  backlog-prioritization
   │     ranking MoSCoW→I×E→ICE → markdown em history/analyses/
   │
   ├── gestão de sprint     →  gitlab-sprint-ops
   │     criar milestone, fechar sprint, mover issues em lote
   │
   └── meta da sprint       →  sprint-goal-generator
         Sprint Goal com foco em outcome
```

---

## Fluxo de Wiki e Changelog

`@product-manager` — executa direto:

```
wiki       →  gitlab-wiki         →  cria/atualiza página na wiki do GitLab
changelog  →  changelog-generator →  entrada formatada  →  publica na wiki (gitlab-wiki)
```

---

## Artefatos — Onde Cada Coisa é Salva

| Artefato | Local |
|---|---|
| Issue original (problema) | GitLab — descrição da issue |
| Comentários do discovery (4 fases) | GitLab — comentários na issue |
| PRIORIZACAO atualizado | GitLab — bloco PRIORIZACAO na descrição |
| Histórico do discovery | `history/discoveries/YYYY-MM-DD_discovery_issue-NNN.md` |
| .md + .docx + regras de uma issue | `outputs/{ID}_{NomeCurto}/` (tudo junto) |
| .docx de HU ou HT | `outputs/{ID}_{NomeCurto}/HU{ID}_{TOKEN}_Nome.docx` |
| Regras da iteração (RN/RA/MSG) | `outputs/{ID}_{NomeCurto}/{ID}_regras.md` |
| CSVs de export do backlog | `data/issues_YYYY-MM-DD.csv` |
| Relatórios de análise/auditoria | `history/analyses/` |
| Changelog (Histórico de Evolução) | Wiki do GitLab + `history/` |

---

## Regras de Ouro (30 segundos)

1. **Descrição = problema** → congelado após criação/refinamento (exceto PRIORIZACAO)
2. **Comentários = discovery** → 4 comentários, 1 por fase do Double Diamond
3. **ICE só no D2b** → antes não tem Facilidade para calcular
4. **Comentário 4 = handoff** → sem ele, não se gera regras/.md/.docx
5. **Skip de fase = aprovação** → nunca silencioso
6. **Critical bug = bypass** → MUST + CRITICAL + sprint atual
7. **≥2 soluções no D2a** → uma proposta única não é discovery
8. **Priorização progressiva** → MoSCoW na criação, +Impacto+Confiança no D1b, +Facilidade no D2b
9. **Sempre carregar `glab-backlog`** antes de qualquer operação no GitLab
