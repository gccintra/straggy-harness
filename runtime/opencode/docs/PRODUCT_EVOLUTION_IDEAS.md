# Evolução do Harness de Product Ops — Catálogo de Ideias

> Documento de visão. Reúne possíveis evoluções do harness (skills, agents, workflows e artefatos)
> calibradas pela prática de Product Management/Product Ownership em empresas grandes
> (iFood, Mercado Livre, Itaú, Nubank, Amazon, Google). Não é compromisso de implementação —
> é um cardápio priorizado pra você escolher o que pedir.
>
> **Tese central:** o harness hoje é forte no *meio* do funil (discovery → documentação → entrega →
> design). A maior alavanca é estender para o **topo** (metas/outcomes) e o **fim** (mediu? funcionou?).
> Sair de "fábrica de features" (output) para "gestão orientada a resultado" (outcome) é o que
> caracteriza PM sênior em empresa grande.

---

## 1. Filosofia — Output vs Outcome

| | Output (onde estamos forte) | Outcome (onde está a lacuna) |
|---|---|---|
| Pergunta | "O que vamos construir?" | "Que resultado de negócio/usuário queremos?" |
| Artefato | HU, HT, regras, CA | OKR, métrica de sucesso, hipótese |
| Sucesso | Entregou no prazo | Moveu a métrica |
| Risco | Construir certo | Construir a coisa certa |

Empresas grandes amarram **toda** entrega a uma métrica. Sem isso, o backlog cresce sem direção e
ninguém sabe se o trabalho gerou valor. As evoluções abaixo fecham esse ciclo.

---

## 2. Mapa do harness atual (o que já está coberto)

| Fase do ciclo | Cobertura atual |
|---|---|
| Captura de demanda | `issue-creator`, `backlog-issue-creator`, `glab-backlog` |
| Priorização | `backlog-prioritization` (MoSCoW, ICE), `backlog-health`, `backlog-analysis` |
| Discovery | `discovery` (Double Diamond D1/D2) |
| Documentação | `doc-consolidator`, `hu-generator`, `ht-generator`, `gerar-regras` |
| Sprint | `sprint-goal-generator`, `gitlab-sprint-ops` |
| Design | `design-brief`, `design-setup`, `design-screen`, `html-to-figma` |
| Engenharia | `tech-lead`, `tech-qa`, `db-query` |
| Comunicação | `wiki`, skill `changelog-generator` + `gitlab-wiki` (changelog via PM) |
| Contexto | sync Drive→md (`sync-context.sh`), `context_docs/` |

**Lacunas estruturais:** metas/OKR, métrica de sucesso por feature, hipótese/experimentação,
loop de feedback pós-entrega, roadmap, repositório de insights, comunicação executiva, governança
(risco/LGPD/acessibilidade), forecast de entrega.

---

## 3. Modelo de maturidade (crawl / walk / run)

| Nível | Característica | O que o harness precisa |
|---|---|---|
| **1 — Documentar** (hoje) | Registra demanda e gera doc formal | ✅ já tem |
| **2 — Priorizar com método** | Decide o quê e quando com framework | parcial (MoSCoW/ICE) → +RICE/WSJF/Kano, roadmap |
| **3 — Orientar a outcome** | Toda entrega tem meta e métrica | OKR, métrica na HU, hipótese |
| **4 — Fechar o loop** | Mede impacto e aprende | post-release review, insight repo, experimentação |
| **5 — Escalar com governança** | Opera como big tech | risco/LGPD, design system, forecast, GTM, story/impact mapping |

Sugestão: subir um nível por vez. Não pular pro 5 sem o 3.

---

## 4. Catálogo de evoluções

Cada item: **O quê · Por quê (mercado) · Como encaixa · Tipo · Esforço · Impacto.**
Esforço/Impacto em S/M/G (pequeno/médio/grande).

### Tema A — Camada de Outcome (prioridade máxima)

#### A1. `okr-tracker` — OKRs e North Star
- **O quê:** mantém OKRs do produto (Objetivo + Key Results) e liga cada épico/issue a um KR.
- **Por quê:** padrão de mercado (Google popularizou; iFood/ML/Nubank operam por OKR). Dá direção ao backlog.
- **Como encaixa:** novo artefato `docs/okrs.md`; `product-manager` consulta ao priorizar; issue ganha campo "KR vinculado".
- **Tipo:** skill + agent hook · **Esforço:** M · **Impacto:** G

#### A2. Métrica de sucesso na HU
- **O quê:** campo obrigatório no `doc-consolidator`: *Métrica de sucesso · Baseline · Alvo · Como medir*.
- **Por quê:** "se não dá pra medir, não entra" — instrumentação por feature (event tracking).
- **Como encaixa:** nova seção/metadado na HU; alimenta o `post-release-review` (F1).
- **Tipo:** edição de skill · **Esforço:** S · **Impacto:** G

#### A3. `hypothesis-framer` — demanda como hipótese
- **O quê:** converte pedido em *"Acreditamos que [mudança] para [persona] gera [resultado], medido por [métrica]. Invalidamos se [sinal]."*
- **Por quê:** dual-track agile, Lean Startup (Build-Measure-Learn). Reduz desperdício.
- **Como encaixa:** roda no `discovery` D2a, antes de propor solução.
- **Tipo:** skill · **Esforço:** S · **Impacto:** M

#### A4. Métricas tree / driver tree
- **O quê:** árvore que decompõe a North Star em métricas-input acionáveis (ex: GMV → pedidos × ticket).
- **Por quê:** ML/iFood pensam por "input metrics" (Amazon: controláveis vs output).
- **Tipo:** skill + `docs/metrics-tree.md` · **Esforço:** M · **Impacto:** M

### Tema B — Continuous Discovery (evoluir o que já existe)

#### B1. `opportunity-solution-tree`
- **O quê:** mapa vivo Outcome → Oportunidades → Soluções → Experimentos, por área de produto.
- **Por quê:** Teresa Torres, "Continuous Discovery Habits" — referência atual de discovery.
- **Como encaixa:** consolida os `history/discoveries/` num mapa em vez de discovery isolado por issue.
- **Tipo:** skill + agent · **Esforço:** G · **Impacto:** G

#### B2. `insight-repo` — repositório de pesquisa
- **O quê:** sintetiza discoveries/entrevistas em insights pesquisáveis, tagueados por tema/persona.
- **Por quê:** Research Ops — empresas grandes têm repositório de insight (evita repesquisar).
- **Tipo:** skill + `docs/insights/` · **Esforço:** M · **Impacto:** M

#### B3. Personas + JTBD (Jobs To Be Done)
- **O quê:** formaliza personas e Jobs-to-be-Done a partir do contexto acumulado.
- **Por quê:** JTBD (Christensen) é linguagem padrão de produto; foca em progresso do usuário, não feature.
- **Tipo:** skill + `docs/personas.md` · **Esforço:** S · **Impacto:** M

#### B4. `assumption-test` — teste da suposição mais arriscada
- **O quê:** extrai a *riskiest assumption* de uma solução e propõe o menor experimento pra validar.
- **Por quê:** GV/Lean — testar o risco antes de construir.
- **Tipo:** skill · **Esforço:** S · **Impacto:** M

#### B5. Usability test plan + heurísticas
- **O quê:** gera roteiro de teste de usabilidade e avaliação heurística (Nielsen) de um protótipo.
- **Por quê:** discovery contínuo de solução; valida antes de codar.
- **Tipo:** skill (liga ao Figma) · **Esforço:** M · **Impacto:** M

### Tema C — Planejamento & Priorização

#### C1. Frameworks de priorização extras
- **O quê:** `RICE` (Reach·Impact·Confidence/Effort), `WSJF` (cost of delay / SAFe), `Kano` (delight vs básico).
- **Por quê:** cada framework serve um momento; MoSCoW/ICE sozinhos limitam.
- **Como encaixa:** estende `backlog-prioritization`.
- **Tipo:** edição de skill · **Esforço:** M · **Impacto:** M

#### C2. `roadmap` Now / Next / Later
- **O quê:** roadmap temático (não data-driven rígido) a partir do backlog priorizado + OKRs.
- **Por quê:** roadmap moderno é de temas/outcomes, não lista de features com data (ProductPlan, Cagan).
- **Tipo:** skill + `docs/roadmap.md` · **Esforço:** M · **Impacto:** G

#### C3. `delivery-forecast` — previsão por throughput
- **O quê:** velocity/throughput dos milestones GitLab + Monte Carlo simples ("85% de chance até dd/mm").
- **Por quê:** #NoEstimates / forecasting probabilístico (Vacanti). Substitui chute por dado.
- **Tipo:** skill (lê GitLab) · **Esforço:** M · **Impacto:** M

#### C4. Story Mapping (Jeff Patton)
- **O quê:** mapa de história — espinha dorsal da jornada × fatias de release (MVP, incrementos).
- **Por quê:** padrão pra fatiar épico em releases coerentes (vertical slicing).
- **Tipo:** skill · **Esforço:** M · **Impacto:** M

#### C5. Impact Mapping (Gojko Adzic)
- **O quê:** Meta → Atores → Impactos → Entregas. Liga feature ao objetivo visualmente.
- **Por quê:** conecta entrega a outcome; ótimo pra alinhar stakeholder.
- **Tipo:** skill · **Esforço:** S · **Impacto:** M

### Tema D — Qualidade de Entrega

#### D1. `gherkin-export` — CAs viram `.feature` executável
- **O quê:** gera Gherkin (`.feature`) a partir dos Critérios de Aceite da HU.
- **Por quê:** CA já é Given/When/Then em prosa → vira teste automatável (Cucumber/BDD). Handoff doc→QA→dev.
- **Como encaixa:** nova skill que lê a Seção 4 do `.md`; conecta `documenter`↔`tech-qa`.
- **Tipo:** skill · **Esforço:** S · **Impacto:** G *(quick win — já discutido)*

#### D2. Definition of Ready / Definition of Done
- **O quê:** checklists DoR (antes de entrar na sprint) e DoD (antes de fechar) validados automaticamente.
- **Por quê:** quality gates — padrão Scrum/SAFe. Evita issue rasa entrando na sprint.
- **Tipo:** skill + hook no `backlog`/`documenter` · **Esforço:** S · **Impacto:** M

#### D3. `test-case-generator` — matriz de teste além de BDD
- **O quê:** casos de teste (positivo/negativo/borda) a partir de CA + regras.
- **Por quê:** cobertura de QA; `tech-qa` ganha insumo estruturado.
- **Tipo:** skill · **Esforço:** M · **Impacto:** M

#### D4. Severity/priority matrix de bug + SLA de triagem
- **O quê:** matriz severidade × prioridade e SLA de resposta por nível.
- **Por quê:** operação de bug em escala (Itaú/ML têm SLA rígido).
- **Tipo:** edição `issue-creator` · **Esforço:** S · **Impacto:** M

### Tema E — Comunicação & Alinhamento

#### E1. `prd-writer` / one-pager de iniciativa
- **O quê:** brief de épico/iniciativa (problema, meta, escopo macro, riscos, métricas) — nível acima da HU.
- **Por quê:** HU é granular demais pra exec/stakeholder. PRD/one-pager é o artefato de alinhamento.
- **Tipo:** skill + agent · **Esforço:** M · **Impacto:** G

#### E2. Amazon "Working Backwards" — PR/FAQ
- **O quê:** escreve o **press release** + **FAQ** da feature *antes* de construir (começa pelo cliente).
- **Por quê:** método Amazon — força clareza de valor antes do código.
- **Tipo:** skill · **Esforço:** S · **Impacto:** M

#### E3. `stakeholder-update` — resumo executivo periódico
- **O quê:** digest (semanal/quinzenal) do que entregou, impacto e próximos passos, a partir de issues fechadas + changelog.
- **Por quê:** comunicação é metade do trabalho de PO. Stakeholder mgmt.
- **Tipo:** skill · **Esforço:** S · **Impacto:** M

#### E4. `gtm-launch-plan` — plano de lançamento
- **O quê:** checklist de go-to-market (comms, suporte, rollout, métricas de lançamento, rollback).
- **Por quê:** lançar é projeto à parte; produto + marketing + suporte alinhados.
- **Tipo:** skill · **Esforço:** M · **Impacto:** M

#### E5. Stakeholder map + RACI
- **O quê:** mapa de stakeholders e matriz RACI por iniciativa.
- **Por quê:** clareza de papéis em projeto grande/multi-time.
- **Tipo:** skill · **Esforço:** S · **Impacto:** S

### Tema F — Loop de Feedback (fecha o ciclo)

#### F1. `post-release-review` — mediu? funcionou?
- **O quê:** N dias após entrega, puxa a métrica de sucesso (A2) e avalia resultado; vira insight.
- **Por quê:** Build-**Measure**-Learn. O passo que quase ninguém faz e que separa produto de projeto.
- **Tipo:** skill + agendamento · **Esforço:** M · **Impacto:** G

#### F2. `voc-intake` — Voice of Customer
- **O quê:** canaliza feedback de usuário/suporte/NPS → triagem → backlog estruturado.
- **Por quê:** entrada de demanda baseada em dor real, não opinião interna.
- **Tipo:** skill · **Esforço:** M · **Impacto:** M

#### F3. `retro-facilitator`
- **O quê:** conduz retrospectiva (o que foi bem / mal / ações) e registra melhorias em `history/`.
- **Por quê:** melhoria contínua — ritual ágil básico.
- **Tipo:** skill · **Esforço:** S · **Impacto:** S

#### F4. Experimentação / A-B test design
- **O quê:** desenha experimento (hipótese, variantes, métrica, tamanho de amostra, critério de decisão).
- **Por quê:** ML/iFood/Nubank decidem por experimento, não opinião. Cultura de teste.
- **Tipo:** skill · **Esforço:** M · **Impacto:** G

### Tema G — Governança & Escala (perfil Itaú/regulado)

#### G1. `compliance-check` — LGPD / risco / regulatório
- **O quê:** checklist de privacidade (LGPD), dados sensíveis, trilha de auditoria por feature.
- **Por quê:** essencial em fintech/banco (Itaú). Bloqueia entrega sem conformidade.
- **Tipo:** skill + gate no `documenter` · **Esforço:** M · **Impacto:** G *(crítico se regulado)*

#### G2. `accessibility-check` — WCAG
- **O quê:** checklist de acessibilidade (WCAG 2.x) no design/entrega.
- **Por quê:** padrão legal e de qualidade; big techs têm gate de a11y.
- **Tipo:** skill (liga ao design) · **Esforço:** S · **Impacto:** M

#### G3. Tech debt register + quadrante
- **O quê:** registro de dívida técnica priorizada (impacto × esforço), ligada a HTs.
- **Por quê:** dívida visível e priorizada, não esquecida. `tech-lead` mantém.
- **Tipo:** skill · **Esforço:** S · **Impacto:** M

#### G4. ADR — Architecture Decision Records
- **O quê:** registra decisões técnicas (contexto, opções, escolha, consequência) em `docs/adr/`.
- **Por quê:** padrão de eng. em escala; memória de "por que decidimos X".
- **Tipo:** skill (liga ao `tech-lead`) · **Esforço:** S · **Impacto:** M

#### G5. Incident / postmortem blameless
- **O quê:** template de postmortem (timeline, causa-raiz, ações) sem culpa.
- **Por quê:** SRE/Google — aprender de incidente sem caçar culpado.
- **Tipo:** skill · **Esforço:** S · **Impacto:** S

#### G6. Design system governance
- **O quê:** governa tokens/componentes do design system; versão e cobertura.
- **Por quê:** consistência em escala; já tem base de design no harness.
- **Tipo:** skill (estende `design-setup`) · **Esforço:** M · **Impacto:** M

### Tema H — Dados & Analytics

#### H1. `tracking-plan` — plano de instrumentação
- **O quê:** especifica eventos/propriedades a logar por feature (nome, trigger, payload).
- **Por quê:** sem evento não há métrica (A2/F1). Padrão de data-informed product.
- **Tipo:** skill · **Esforço:** M · **Impacto:** G

#### H2. Cohort / retention / funnel analysis
- **O quê:** roteiro de análise de coorte, retenção e funil a partir dos dados (`db-query`).
- **Por quê:** AARRR (pirate metrics), retenção é a métrica que mais importa em produto digital.
- **Tipo:** skill (usa `db-query`) · **Esforço:** M · **Impacto:** M

#### H3. Guardrail metrics
- **O quê:** define métricas de guarda (não regredir) ao lado da métrica-alvo.
- **Por quê:** evita otimizar uma métrica quebrando outra (ex: subir conversão e disparar churn).
- **Tipo:** edição da HU/experimento · **Esforço:** S · **Impacto:** M

---

## 5. Roadmap de adoção sugerido (Now / Next / Later)

### 🟢 Now (alto impacto, baixo esforço — começar já)
1. **A2 — Métrica de sucesso na HU** *(S/G)*
2. **D1 — `gherkin-export`** *(S/G)*
3. **F1 — `post-release-review`** *(M/G)* — fecha o loop com A2
4. **D2 — DoR/DoD gates** *(S/M)*

> Esses 4 já elevam do nível 1 (documentar) pro nível 3 (outcome) + começam o nível 4 (loop).

### 🟡 Next (direção estratégica)
5. **A1 — `okr-tracker`** + **C2 — `roadmap` Now/Next/Later**
6. **E1 — `prd-writer`** / one-pager de iniciativa
7. **C1 — RICE/WSJF/Kano** no `backlog-prioritization`
8. **H1 — `tracking-plan`** (habilita métricas de verdade)
9. **A3 — `hypothesis-framer`** no discovery

### 🔵 Later (escala e maturidade)
10. **B1 — Opportunity Solution Tree** + **B2 — insight-repo** + **B3 — personas/JTBD**
11. **F4 — experimentação / A-B** + **H2 — coorte/retenção**
12. **G1 — compliance/LGPD** + **G2 — acessibilidade** *(antecipar se o projeto for regulado)*
13. **E4 — GTM** + **E3 — stakeholder-update** + **F2 — VoC**
14. **C3 — forecast** + **C4 — story mapping** + **C5 — impact mapping**
15. **G3/G4/G5 — tech debt / ADR / postmortem**

---

## 6. Top 3 recomendações (se for escolher pouco)

1. **Fechar o loop output→outcome: A2 (métrica na HU) + F1 (post-release-review).**
   É o salto de "fábrica de feature" para "gestão de produto". Barato, transformador.
2. **`gherkin-export` (D1).** Quick win: CA já é GWT, vira teste automatável. Liga doc↔QA↔dev.
3. **`okr-tracker` (A1) + `roadmap` Now/Next/Later (C2).** Dá direção estratégica e linguagem de
   exec ao backlog — o vocabulário de PM em iFood/ML/Itaú.

---

## 7. Glossário de frameworks citados

| Framework | Para quê | Referência |
|---|---|---|
| **OKR** | Metas e key results | Google / "Measure What Matters" (Doerr) |
| **North Star + input metrics** | Métrica única que guia + drivers | Amplitude / Amazon |
| **JTBD** | Foco no progresso do usuário | Clayton Christensen |
| **Opportunity Solution Tree** | Discovery contínuo | Teresa Torres |
| **Dual-track Agile** | Discovery + Delivery em paralelo | Marty Cagan / SVPG |
| **RICE / ICE** | Priorização por score | Intercom |
| **WSJF / Cost of Delay** | Priorização por valor/tempo | SAFe |
| **Kano** | Básico vs encanto | Noriaki Kano |
| **Story Mapping** | Fatiar release pela jornada | Jeff Patton |
| **Impact Mapping** | Ligar entrega a meta | Gojko Adzic |
| **Working Backwards / PR-FAQ** | Começar pelo cliente | Amazon |
| **Build-Measure-Learn** | Ciclo de aprendizado | Lean Startup (Ries) |
| **AARRR (pirate metrics)** | Funil de produto | Dave McClure |
| **#NoEstimates / forecasting** | Previsão probabilística | Vacanti / Duarte |
| **Blameless postmortem** | Aprender de incidente | Google SRE |
| **ADR** | Registrar decisão técnica | Michael Nygard |

---

*Próximo passo sugerido: escolher os itens do bloco **Now** e pedir o design detalhado de cada
skill (estrutura, inputs, integração com GitLab/`docs`, formato de saída) antes de implementar.*
