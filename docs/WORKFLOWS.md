# O que o harness faz — ficha por workflow

Referência de manutenção: **o que existe hoje, o que cada coisa entrega, onde ela para e em
que arquivo se mexe.** Serve tanto para você quanto para o agente que vai editar o harness.

Como ler esta página: `HARNESS.md` explica o mecanismo em uma página · `ARCHITECTURE.md` é a
regra normativa de camadas · `MANUTENCAO.md` é o processo para mudar qualquer coisa daqui ·
`../system/ACOES.md` é o catálogo público (o que a organização contrata). Nada nesta pasta
descreve o Hub — o produto com interface vive em [`hub/`](hub/) e **não está implementado**.

> **Este documento é gerado.** O bloco abaixo sai do frontmatter das skills, por
> `runtime/build.sh --fix`. Editar aqui à mão não muda comportamento nenhum e o próximo
> build desfaz. O lugar de mudar é o `SKILL.md` do workflow — campos `objetivo`, `entrega`,
> `portoes`, `acao`, `produz`, `requer`, `provider` e `encaixes`. Sem `--fix`, o build só
> confere e reprova quando divergiu.

## O vocabulário

| Termo | O que é |
|---|---|
| **Ação** | o trabalho nomeado, em linguagem de resultado. É o contrato público — renomear quebra quem a reivindicou |
| **Workflow** | a pasta que implementa a ação (`system/pack/workflows/<nome>/`). Endereço físico, não contrato |
| **Encaixe** | o pedaço de conteúdo que a organização escreve dentro da moldura do sistema. Único ponto de customização |
| **Provider** | a abstração da ferramenta externa (backlog, banco, wiki, canvas). O workflow fala com a interface, nunca com o comando |
| **Esteira** | o grafo `requer`/`produz`: que artefato precisa existir antes, e qual nasce depois |
| **Portão** | onde a execução para e espera decisão humana. Não é encaixe — a organização não o alcança |
| **Persona** | quem conversa com você (`@product-specialist` e as outras). Identidade, não procedimento |

Toda ação aceita o encaixe `procedimento`. As fichas listam os encaixes de cada uma.

<!-- gerado: fichas — regenerado por runtime/build.sh --fix -->

| Ação | Objetivo | Workflow | Origem |
|---|---|---|---|
| [`analisar-backlog`](#analisar-backlog) | Responder em números o que o backlog diz — volume, distribuição, saúde e ritmo da sprint. | `backlog-analysis` | pack padrão |
| [`analisar-demanda-de-tela`](#analisar-demanda-de-tela) | Descobrir o que a demanda vira na interface, e o que ela quebra, antes de alguém escrever JSX. | `design-brief` | pack padrão |
| [`auditar-backlog`](#auditar-backlog) | Achar o que apodreceu no backlog — demanda sem tipo, sem prioridade, sem dono, parada há mais de 180 dias e provável duplicata. | `backlog-health` | pack padrão |
| [`capturar-prints`](#capturar-prints) | Ilustrar uma demanda com as imagens que dizem algo sobre ela, em vez de um álbum do protótipo inteiro. | `prototype-prints` | pack padrão |
| [`configurar-design-system`](#configurar-design-system) | Dar ao projeto um protótipo com design system próprio, medido das evidências reais em vez de estimado. | `design-setup` | pack padrão |
| [`construir-tela`](#construir-tela) | Construir a tela da demanda como rota real do protótipo, transcrevendo a referência em vez de re-autorar. | `design-screen` | pack padrão |
| [`consultar-backlog`](#consultar-backlog) | Resolver o pedido pontual numa demanda — ver, buscar, listar, comentar, fechar — sem varrer o backlog inteiro. | `backlog-query` | pack padrão |
| [`consultar-dados`](#consultar-dados) | Responder o que os dados realmente dizem, quando a documentação só diz o comportamento esperado. | `db-query` | pack padrão |
| [`definir-meta-de-sprint`](#definir-meta-de-sprint) | Escrever a meta da sprint como ganho para o usuário ou o negócio, não como lista de entregas. | `sprint-goal-generator` | pack padrão |
| [`documentar-requisito`](#documentar-requisito) | Reunir a demanda inteira num `.md` autocontido que passa a ser a fonte de verdade do requisito. | `doc-consolidator` | pack padrão + encaixes desta organização |
| [`explorar-solucao`](#explorar-solucao) | Levar a demanda do problema à solução definida, uma fase por vez, com a origem declarada em cada regra capturada. | `discovery` | pack padrão + encaixes desta organização |
| [`gerar-documento-final`](#gerar-documento-final) | Transcrever o `.md` já revisado para o formato entregável, sem reinterpretar, resumir ou completar nada. | `doc-final-generator` | pack padrão + encaixes desta organização |
| [`gerar-narrativa-de-requisito`](#gerar-narrativa-de-requisito) | Transformar uma HU já documentada em narrativa funcional corrida, legível por produto, design, desenvolvimento, QA e negócio. | `hu-narrative-generator` | própria desta organização |
| [`gerenciar-sprint`](#gerenciar-sprint) | Operar a sprint no backlog — criar, listar, mover em lote, fechar e documentar. | `sprint-ops` | pack padrão + encaixes desta organização |
| [`limpar-prosa`](#limpar-prosa) | Tirar de um texto os padrões previsíveis de prosa de IA sem mudar o que ele afirma. | `stop-slop` | pack padrão |
| [`manter-changelog`](#manter-changelog) | Manter o histórico de evolução do produto na linguagem de quem usa, não na de quem commitou. | `changelog-generator` | pack padrão + encaixes desta organização |
| [`priorizar-backlog`](#priorizar-backlog) | Ordenar a fila do backlog pelo funil declarado e mostrar onde os dados contradizem o funil. | `backlog-prioritization` | pack padrão + encaixes desta organização |
| [`publicar-na-wiki`](#publicar-na-wiki) | Publicar e atualizar a documentação de produto na wiki sem sobrescrever em silêncio o que já estava lá. | `wiki-publish` | pack padrão + encaixes desta organização |
| [`publicar-prototipo`](#publicar-prototipo) | Pôr o protótipo num endereço que dá para mandar ao cliente, com autenticação e HTTPS. | `prototype-deploy` | pack padrão |
| [`registrar-demanda`](#registrar-demanda) | Transformar um pedido em demanda registrada no backlog — o problema, não a solução que veio junto. | `backlog-issue-creator` | pack padrão + encaixes desta organização |
| [`versionar-mudancas`](#versionar-mudancas) | Fechar o trabalho em commits atômicos por camada, com push e PR — sem `git add -A` e sem commit gigante. | `committer` | pack padrão |

**Personas** — identidade de quem conversa com você, sem artefato próprio.

| Persona | Objetivo |
|---|---|
| `@product-designer` | A persona de design do projeto — pensa interface, fluxo e design system, e escreve o código do protótipo. |
| `@product-specialist` | A persona de produto do projeto — ponto de entrada padrão; pensa valor, requisito e processo, e escolhe qual workflow carregar. |
| `@tech-lead` | A persona técnica do projeto — separa comportamento esperado (documentação) de estado real (banco) antes de decidir. |

**Máquina do harness** — governa e opera o harness em si. Não declara ação, então não entra no catálogo público. Algumas são motores, invocados por outra skill; outras você chama direto.

| Workflow | Objetivo |
|---|---|
| `figma-node-reader` | Transcrever node grande do Figma para HTML em disco, queimando o contexto num subagente em vez da thread principal. |
| `harness-change` | Governar como o próprio harness evolui — spec com impacto antes, e a mudança nascendo na camada certa e no estilo certo. |
| `harness-guide` | Responder o que o harness já faz, onde cada coisa mora e o que quebra ao mudá-la — sem tocar em arquivo nenhum. |
| `html-to-figma` | Exportar a rota renderizada do protótipo para um node no Figma. |

---

## Fichas

### analisar-backlog

**Analisar backlog** — Responder em números o que o backlog diz — volume, distribuição, saúde e ritmo da sprint.

| | |
|---|---|
| Workflow | `backlog-analysis` (pack padrão) |
| Exige antes | — |
| Produz na esteira | — |
| Ferramenta externa | `backlog`, escolhido por `BACKLOG_PROVIDER`, exige a capacidade `bulk-export` |

**Dispara quando**

> Métricas do backlog por export em lote: status, distribuição por tipo ou prioridade, velocidade do time, burndown, análise de sprint. Use para "métricas do backlog", "velocidade", "burndown". Ranquear é backlog-prioritization; auditar é backlog-health.

**Entrega**

- CSV do export em lote em `{caminhos.dados}`, com data no nome e nunca sobrescrito
- relatório `{caminhos.historico}analyses/YYYY-MM-DD_analysis_[escopo].md` com score de saúde 0–100, distribuições, top 10 e 3 recomendações
- burndown HTML em `{caminhos.dados}` quando o escopo é uma sprint

**Portões**

- escopo ambíguo (backlog inteiro, sprint, período) → pergunta antes de exportar
- write-gate antes de gravar o CSV e o relatório
- não altera nenhuma demanda — a ação só lê o backlog

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/backlog-analysis/SKILL.md` | existe |
| Encaixe `procedimento` — Como fazer | `org/workflows/backlog-analysis/references/procedimento.md` | padrão do pack |

**Provas de comportamento**

- declaradas aqui (2): `metricas-do-backlog` · `sem-provider`
- contraprova em (2): `backlog-health` · `backlog-prioritization`

`./runtime/eval.sh --skill backlog-analysis`

---

### analisar-demanda-de-tela

**Analisar demanda de tela** — Descobrir o que a demanda vira na interface, e o que ela quebra, antes de alguém escrever JSX.

| | |
|---|---|
| Workflow | `design-brief` (pack padrão) |
| Exige antes | — |
| Produz na esteira | — |
| Ferramenta externa | nenhuma |

**Dispara quando**

> Analisa o que uma demanda vira na interface antes de construir: navegação, reuso, lacunas do design system, estados, impacto em telas. Use para "analisa a tela da #NNN antes de eu construir", "o que reusa e o que falta". Construir é design-screen.

**Entrega**

- a análise na conversa — superfície de tela, o que o protótipo já tem, navegação, estados, impacto no que existe e pendências de produto
- opcional `{caminhos.pasta_por_demanda}{ID}_design.md`, o plano que a construção da tela consome

**Portões**

- PARA na conversa e itera ali — é ordens de grandeza mais barato que iterar em JSX
- o documento é opt-in (write-gate); vira obrigatório só quando a demanda tem ID e vai virar documento consolidado

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/design-brief/SKILL.md` | existe |
| Encaixe `procedimento` — Como fazer | `org/workflows/design-brief/references/procedimento.md` | padrão do pack |

**Provas de comportamento**

- declaradas aqui (1): `analisa-demanda-de-tela`
- contraprova em (1): `design-screen`

`./runtime/eval.sh --skill design-brief`

---

### auditar-backlog

**Auditar backlog** — Achar o que apodreceu no backlog — demanda sem tipo, sem prioridade, sem dono, parada há mais de 180 dias e provável duplicata.

| | |
|---|---|
| Workflow | `backlog-health` (pack padrão) |
| Exige antes | — |
| Produz na esteira | — |
| Ferramenta externa | `backlog`, escolhido por `BACKLOG_PROVIDER`, exige a capacidade `bulk-export` |

**Dispara quando**

> Audita a saúde do backlog: issues sem tipo, prioridade, sprint ou responsável, duplicatas e zumbis, com correção em lote opcional. Use para "limpa o backlog", "acha as duplicatas", "o backlog está uma bagunça". Métricas são backlog-analysis.

**Entrega**

- CSV `{caminhos.dados}health_audit_YYYY-MM-DD.csv`
- relatório `{caminhos.historico}analyses/YYYY-MM-DD_health_audit.md` com resumo por problema, zumbis, grupos de duplicata e 3 recomendações

**Portões**

- correção em lote é opt-in e só existe depois do relatório entregue
- cada lote (fechar zumbi, fechar duplicata, aplicar label) é um portão separado
- duplicata é sugestão da ação; quem valida é o usuário

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/backlog-health/SKILL.md` | existe |
| Encaixe `procedimento` — Como fazer | `org/workflows/backlog-health/references/procedimento.md` | padrão do pack |

**Provas de comportamento**

- declaradas aqui (2): `audita-cadastro` · `sem-provider`
- contraprova em (1): `backlog-analysis`

`./runtime/eval.sh --skill backlog-health`

---

### capturar-prints

**Capturar prints** — Ilustrar uma demanda com as imagens que dizem algo sobre ela, em vez de um álbum do protótipo inteiro.

| | |
|---|---|
| Workflow | `prototype-prints` (pack padrão) |
| Exige antes | `prototipo-validado` |
| Produz na esteira | `prints-capturadas` |
| Ferramenta externa | nenhuma |

**Dispara quando**

> Captura prints do protótipo, por fluxo e em A4, para o documento da demanda. Use para "tira as prints da #NNN", "telas pra colocar no docx". Export pro Figma é html-to-figma; publicar é prototype-deploy.

**Entrega**

- PNGs numerados em `{caminhos.pasta_por_demanda}prototipo-prints/`, na ordem de leitura
- seção Protótipo do `.md` com um heading por print lógica e o link da rota por fluxo

**Portões**

- sem documentação da demanda → PARA e pede; sem ela não há critério de recorte
- propõe destino, lista numerada e o que fica de fora, e espera o aval antes de capturar
- apagar print já entregue também pede confirmação

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/prototype-prints/SKILL.md` | existe |
| Encaixe `procedimento` — Como fazer | `org/workflows/prototype-prints/references/procedimento.md` | padrão do pack |
| Encaixe `secao-prototipo` — Seção Protótipo do documento | `org/workflows/prototype-prints/references/secao-prototipo.md` | padrão do pack |

**Provas de comportamento**

- declaradas aqui (1): `captura-prints`
- contraprova em (1): `prototype-deploy`

`./runtime/eval.sh --skill prototype-prints`

---

### configurar-design-system

**Configurar design system** — Dar ao projeto um protótipo com design system próprio, medido das evidências reais em vez de estimado.

| | |
|---|---|
| Workflow | `design-setup` (pack padrão) |
| Exige antes | — |
| Produz na esteira | — |
| Ferramenta externa | nenhuma |

**Dispara quando**

> Primeira configuração do design system e scaffold do protótipo a partir de prints do sistema atual: tokens e componentes base. Use na primeira vez do designer, para atualizar o design system ou para instalar/atualizar o painel de cenários (seletor de estados no canto). Tela específica é design-screen.

**Entrega**

- `prototype/` scaffoldado — tokens em arquivo único, componentes base próprios, uma tela por rota, menu real, wrapper de export e painel de cenários
- registro em `{caminhos.historico}YYYY-MM-DD_design-setup.md`

**Portões**

- faltou evidência do visual → pergunta, não estima
- guidelines no canvas só sob pedido explícito
- re-execução edita tokens e componentes — nunca recria o protótipo

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/design-setup/SKILL.md` | existe |
| Encaixe `procedimento` — Como fazer | `org/workflows/design-setup/references/procedimento.md` | padrão do pack |
| Encaixe `stack-prototipo` — Stack do protótipo | `org/workflows/design-setup/references/stack-react-vite.md` | padrão do pack |

**Provas de comportamento**

- declaradas aqui (2): `configura-design-system` · `instala-painel`
- contraprova em (1): `design-screen`

`./runtime/eval.sh --skill design-setup`

---

### construir-tela

**Construir tela** — Construir a tela da demanda como rota real do protótipo, transcrevendo a referência em vez de re-autorar.

| | |
|---|---|
| Workflow | `design-screen` (pack padrão) |
| Exige antes | — |
| Produz na esteira | `prototipo-validado` |
| Ferramenta externa | nenhuma |

**Dispara quando**

> Cria ou ajusta telas como rotas no protótipo (prototype/) a partir de demanda, requisito ou descrição. Use para "cria a tela", "ajusta a tela", protótipo, componente, fluxo. Analisar antes de construir é design-brief.

**Entrega**

- rota em `prototype/src/routes/`, registrada no roteador e alcançável pelo menu real, com estados na query declarados ao painel de cenários
- `{caminhos.pasta_por_demanda}{ID}_design.md` atualizado com o que a tela faz de fato
- registro em `{caminhos.historico}YYYY-MM-DD_design_<nome>.md`

**Portões**

- PARA após a verificação visual — entrega a URL, os estados e a lista do que assumiu
- registrar o protótipo no `{ID}_design.md` é write-gate
- export pro Figma é opt-in, tela a tela

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/design-screen/SKILL.md` | existe |
| Encaixe `procedimento` — Como fazer | `org/workflows/design-screen/references/procedimento.md` | padrão do pack |

**Provas de comportamento**

- declaradas aqui (1): `cria-tela`
- contraprova em (2): `design-brief` · `design-setup`

`./runtime/eval.sh --skill design-screen`

---

### consultar-backlog

**Consultar backlog** — Resolver o pedido pontual numa demanda — ver, buscar, listar, comentar, fechar — sem varrer o backlog inteiro.

| | |
|---|---|
| Workflow | `backlog-query` (pack padrão) |
| Exige antes | — |
| Produz na esteira | — |
| Ferramenta externa | `backlog`, escolhido por `BACKLOG_PROVIDER`, exige a capacidade `core` |

**Dispara quando**

> Operação pontual no backlog: ver, buscar, listar por sprint/label/responsável, comentar, atualizar, fechar. Use para "vê a #NNN", "busca issues sobre X", "comenta na #NNN", "fecha a #NNN", ou ao citar glab, GitLab, Linear, Jira. Demanda nova é backlog-issue-creator.

**Entrega**

- a resposta na conversa
- na operação de escrita, a demanda criada, atualizada, comentada ou fechada

**Portões**

- leitura segue direto, sem portão
- toda escrita mostra alvo e conteúdo e espera aprovação (L0 §2)

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/backlog-query/SKILL.md` | existe |
| Encaixe `procedimento` — Como fazer | `org/workflows/backlog-query/references/procedimento.md` | padrão do pack |

**Provas de comportamento**

- declaradas aqui (2): `sem-provider` · `ve-a-demanda`
- contraprova em (2): `backlog-issue-creator` · `db-query`

`./runtime/eval.sh --skill backlog-query`

---

### consultar-dados

**Consultar dados** — Responder o que os dados realmente dizem, quando a documentação só diz o comportamento esperado.

| | |
|---|---|
| Workflow | `db-query` (pack padrão) |
| Exige antes | — |
| Produz na esteira | — |
| Ferramenta externa | nenhuma |

**Dispara quando**

> Consulta SQL no banco de homologação pelo cliente do .env: tabelas, registros, contagens, "quantos X estão com status Y", dado real que diverge do esperado. Estado de issue é backlog-query.

**Entrega**

- resultado da consulta na conversa, formatado conforme a INTERFACE do provider `database`

**Portões**

- somente leitura — nenhuma escrita no banco, sob nenhum pedido
- gate `DB_ENABLED` — desligado, a ação não roda e diz por quê

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/db-query/SKILL.md` | existe |
| Encaixe `procedimento` — Como fazer | `org/workflows/db-query/references/procedimento.md` | padrão do pack |

**Provas de comportamento**

- declaradas aqui (1): `consulta-banco`
- contraprova em (1): `backlog-query`

`./runtime/eval.sh --skill db-query`

---

### definir-meta-de-sprint

**Definir meta da sprint** — Escrever a meta da sprint como ganho para o usuário ou o negócio, não como lista de entregas.

| | |
|---|---|
| Workflow | `sprint-goal-generator` (pack padrão) |
| Exige antes | — |
| Produz na esteira | — |
| Ferramenta externa | nenhuma |

**Dispara quando**

> Escreve a Meta da Sprint (Guia do Scrum 2020) com foco em outcome. Use para "meta da sprint", "sprint goal", "objetivo da sprint". Criar, fechar ou mover sprint é sprint-ops.

**Entrega**

- 2 a 3 opções de meta na conversa, cada uma com por que é outcome e como verificar
- recomendação e alertas

**Portões**

- input vago demais → uma pergunta antes de gerar
- só propõe — quem grava a meta na sprint é a ação `gerenciar-sprint`, com aprovação

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/sprint-goal-generator/SKILL.md` | existe |
| Encaixe `procedimento` — Como fazer | `org/workflows/sprint-goal-generator/references/procedimento.md` | padrão do pack |

**Provas de comportamento**

- declaradas aqui (1): `escreve-meta`
- contraprova em (1): `sprint-ops`

`./runtime/eval.sh --skill sprint-goal-generator`

---

### documentar-requisito

**Documentar requisito** — Reunir a demanda inteira num `.md` autocontido que passa a ser a fonte de verdade do requisito.

| | |
|---|---|
| Workflow | `doc-consolidator` (pack padrão + encaixes desta organização) |
| Exige antes | `solucao-definida` · `prototipo-validado` (se `demanda-tem-interface`) |
| Produz na esteira | `documento-consolidado` |
| Ferramenta externa | nenhuma |

**Dispara quando**

> Gera o .md consolidado da demanda (critérios de aceite, regras de negócio, mensagens) e para para revisão. Use para "documenta a #NNN", "consolida", "gera o md", "monta o documento base". O docx/PDF final é doc-final-generator.

**Entrega**

- um `.md` por demanda em `{caminhos.entregaveis}`, com história, critérios de aceite verificáveis, regras de negócio como invariante, mensagens ao usuário e rastreabilidade até o discovery

**Portões**

- sem solução definida em nenhuma fonte → PARA e pergunta; não inventa o requisito
- demanda com tela sem protótipo validado → PARA e pergunta
- PARA no fim e aguarda revisão humana — o formato final é ação separada
- não publica nada no backlog

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/doc-consolidator/SKILL.md` | existe |
| Encaixe `estrutura-documento` — Estrutura do documento | `org/workflows/doc-consolidator/references/formato-md.md` | preenchido por esta organização |
| Encaixe `procedimento` — Como fazer | `org/workflows/doc-consolidator/references/procedimento.md` | preenchido por esta organização |
| Encaixe `regras-classificacao` — Regras de classificação | `org/workflows/doc-consolidator/references/regras.md` | preenchido por esta organização |

**Provas de comportamento**

- declaradas aqui (1): `documenta-a-demanda`
- contraprova em (4): `discovery` · `doc-final-generator` · `hu-narrative-generator` · `stop-slop`

`./runtime/eval.sh --skill doc-consolidator`

---

### explorar-solucao

**Explorar solução** — Levar a demanda do problema à solução definida, uma fase por vez, com a origem declarada em cada regra capturada.

| | |
|---|---|
| Workflow | `discovery` (pack padrão + encaixes desta organização) |
| Exige antes | — |
| Produz na esteira | `solucao-definida` |
| Ferramenta externa | nenhuma |

**Dispara quando**

> Discovery no Double Diamond: problema (D1), depois solução (D2), cada fase aprovada. Use para "explorar alternativas", "fazer discovery", "não sei qual é o problema de verdade". Escrever o requisito é doc-consolidator.

**Entrega**

- um registro por fase — comentário na demanda com marcador `[D1a]` a `[D2b]`
- bloco append em `{caminhos.historico}discoveries/YYYY-MM-DD_discovery_<ref>.md`
- priorização acordada gravada na demanda pelo bloco estruturado e pela label correspondente

**Portões**

- uma fase por turno — pular fase só com justificativa e aprovação
- depois de montar a lista de incógnitas, PARA — o usuário decide como resolver cada uma
- write-gate por fase, antes de comentar na demanda ou gravar o registro

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/discovery/SKILL.md` | existe |
| Encaixe `formato-fase` — Registro de cada fase | `org/workflows/discovery/references/fases.md` | preenchido por esta organização |
| Encaixe `procedimento` — Como fazer | `org/workflows/discovery/references/procedimento.md` | preenchido por esta organização |

**Provas de comportamento**

- declaradas aqui (1): `explora-alternativas`
- contraprova em (1): `doc-consolidator`

`./runtime/eval.sh --skill discovery`

---

### gerar-documento-final

**Gerar documento final** — Transcrever o `.md` já revisado para o formato entregável, sem reinterpretar, resumir ou completar nada.

| | |
|---|---|
| Workflow | `doc-final-generator` (pack padrão + encaixes desta organização) |
| Exige antes | `documento-consolidado` |
| Produz na esteira | `documento-final` |
| Ferramenta externa | `docs-output`, escolhido por `DOCS_OUTPUT_PROVIDER`, exige a capacidade `render` |

**Dispara quando**

> Transcreve um .md consolidado já revisado para .docx ou .pdf. Só com pedido explícito: "gera o docx", "documento final", "gera o PDF da demanda". Pedido genérico ("documenta a #NNN") é doc-consolidator.

**Entrega**

- arquivo no formato final, na mesma pasta e com o mesmo nome do `.md`
- relato do que a implementação ativa do provider não conseguiu fazer e ficou manual

**Portões**

- `.md` inexistente → aponta a ação `documentar-requisito` e PARA
- `.md` não revisado por humano → confirma antes de gerar
- mostra arquivo de origem, destino e implementação ativa, e espera aprovação
- regeração depois de corrigir o `.md` é um novo portão

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/doc-final-generator/SKILL.md` | existe |
| Encaixe `estrutura-final` — Modelo do entregável | `org/workflows/doc-final-generator/references/template.md` | preenchido por esta organização |
| Encaixe `exemplos` — Exemplos de referência | `org/workflows/doc-final-generator/references/exemplos.md` | preenchido por esta organização |
| Encaixe `gerador` — Gerador do entregável | `org/workflows/doc-final-generator/generate_doc.py` | preenchido por esta organização |
| Encaixe `marca` — Marca no cabeçalho | `org/workflows/doc-final-generator/assets/header_logo.png` | preenchido por esta organização |
| Encaixe `procedimento` — Como fazer | `org/workflows/doc-final-generator/references/procedimento.md` | preenchido por esta organização |

**Provas de comportamento**

- declaradas aqui (2): `gera-o-docx` · `sem-provider`
- contraprova em (1): `doc-consolidator`

`./runtime/eval.sh --skill doc-final-generator`

---

### gerar-narrativa-de-requisito

**Gerar narrativa de requisito** — Transformar uma HU já documentada em narrativa funcional corrida, legível por produto, design, desenvolvimento, QA e negócio.

| | |
|---|---|
| Workflow | `hu-narrative-generator` (própria desta organização) |
| Exige antes | — |
| Produz na esteira | — |
| Ferramenta externa | nenhuma |

**Dispara quando**

> Gera uma descrição narrativa em Markdown a partir de documentação existente de História de Usuário, preservando requisitos, regras, estados, permissões, exceções e efeitos operacionais em texto corrido e coeso. Use quando o usuário pedir "descrição narrativa", "narrativa da HU", "transformar a HU em texto corrido", "explicar o comportamento da HU" ou um documento no padrão `HU{ID}_Descricao_Narrativa.md`. Não cria requisitos nem substitui o documento consolidado.

**Entrega**

- `{caminhos.pasta_por_demanda}HU{ID}_Descricao_Narrativa.md` — só Markdown narrativo, nunca `.docx`

**Portões**

- aprovação explícita antes de salvar o arquivo
- conflito entre fontes que muda o comportamento esperado → PARA e faz uma pergunta objetiva

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `org/workflows/hu-narrative-generator/SKILL.md` | existe |

**Provas de comportamento**

- declaradas aqui (1): `gera-narrativa`
- contraprova em (1): `doc-consolidator`

`./runtime/eval.sh --skill hu-narrative-generator`

---

### gerenciar-sprint

**Gerenciar sprint** — Operar a sprint no backlog — criar, listar, mover em lote, fechar e documentar.

| | |
|---|---|
| Workflow | `sprint-ops` (pack padrão + encaixes desta organização) |
| Exige antes | — |
| Produz na esteira | — |
| Ferramenta externa | `backlog`, escolhido por `BACKLOG_PROVIDER`, exige a capacidade `sprints` |

**Dispara quando**

> Gestão de sprint no backlog: criar, fechar com sumário, mover issues em lote, listar, documentar a milestone. Use para "fecha a sprint", "cria a sprint", "move pra próxima", "documenta a sprint". Só a meta é sprint-goal-generator.

**Entrega**

- sprint criada, fechada ou com issues movidas, conforme a operação
- descrição da sprint no template do encaixe `template-sprint`
- registro em `{caminhos.historico}YYYY-MM-DD_sprint_doc_[SPRINT].md`

**Portões**

- cada operação de escrita tem preview e aprovação própria
- fechar sprint gera o sumário antes e espera confirmação
- capacidade `sprints-write` ausente → informa a indisponibilidade e nunca tenta o comando mesmo assim
- a meta da sprint nunca é escrita aqui — vem da ação `definir-meta-de-sprint`

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/sprint-ops/SKILL.md` | existe |
| Encaixe `procedimento` — Como fazer | `org/workflows/sprint-ops/references/procedimento.md` | padrão do pack |
| Encaixe `template-sprint` — Modelo de sprint | `org/workflows/sprint-ops/references/milestone-doc.md` | preenchido por esta organização |

**Provas de comportamento**

- declaradas aqui (2): `fecha-sprint` · `sem-provider`
- contraprova em (1): `sprint-goal-generator`

`./runtime/eval.sh --skill sprint-ops`

---

### limpar-prosa

**Limpar prosa** — Tirar de um texto os padrões previsíveis de prosa de IA sem mudar o que ele afirma.

| | |
|---|---|
| Workflow | `stop-slop` (pack padrão) |
| Exige antes | — |
| Produz na esteira | — |
| Ferramenta externa | nenhuma |

**Dispara quando**

> Reescreve prosa para tirar cara de IA. Use para "humaniza", "cheiro de IA", "cara de ChatGPT", "parece LLM", "stop-slop", ou rascunho formulaico. Não documenta demanda nem reescreve código.

**Entrega**

- o texto reescrito, com o mesmo conteúdo factual do original
- score nas cinco dimensões (direteza, ritmo, confiança, autenticidade, densidade)

**Portões**

- reescrita entregue na conversa segue direto
- gravar o resultado fora do rascunho (arquivo, demanda, wiki) é write-gate

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/stop-slop/SKILL.md` | existe |
| Encaixe `procedimento` — Como fazer | `org/workflows/stop-slop/references/procedimento.md` | padrão do pack |

**Provas de comportamento**

- declaradas aqui (1): `limpa-prosa`
- contraprova em (1): `doc-consolidator`

`./runtime/eval.sh --skill stop-slop`

---

### manter-changelog

**Manter changelog** — Manter o histórico de evolução do produto na linguagem de quem usa, não na de quem commitou.

| | |
|---|---|
| Workflow | `changelog-generator` (pack padrão + encaixes desta organização) |
| Exige antes | — |
| Produz na esteira | — |
| Ferramenta externa | nenhuma |

**Dispara quando**

> Gera ou atualiza o changelog (histórico de evolução) a partir de requisito, entrega ou funcionalidade. Use para "changelog", "registra essa entrega", "atualiza o histórico de evolução". Página de wiki é wiki-publish.

**Entrega**

- entrada nova no changelog do projeto, no formato do encaixe `formato-changelog`, mais recente no topo

**Portões**

- mostra a entrada antes de gravar
- publicar na wiki é ação separada (`publicar-na-wiki`), com portão próprio

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/changelog-generator/SKILL.md` | existe |
| Encaixe `formato-changelog` — Formato do changelog | `org/workflows/changelog-generator/references/formato.md` | preenchido por esta organização |
| Encaixe `procedimento` — Como fazer | `org/workflows/changelog-generator/references/procedimento.md` | preenchido por esta organização |

**Provas de comportamento**

- declaradas aqui (1): `registra-changelog`
- contraprova em (1): `wiki-publish`

`./runtime/eval.sh --skill changelog-generator`

---

### priorizar-backlog

**Priorizar backlog** — Ordenar a fila do backlog pelo funil declarado e mostrar onde os dados contradizem o funil.

| | |
|---|---|
| Workflow | `backlog-prioritization` (pack padrão + encaixes desta organização) |
| Exige antes | — |
| Produz na esteira | — |
| Ferramenta externa | `backlog`, escolhido por `BACKLOG_PROVIDER`, exige a capacidade `bulk-export` |

**Dispara quando**

> Prioriza o backlog pelo funil da organização: score, faixas, lista ranqueada e anomalias de rótulo ou score. Use para "prioriza", "ranking", "o que entra primeiro", MoSCoW, RICE, ICE, WSJF, esforço × valor. Métricas sem ordenar são backlog-analysis.

**Entrega**

- CSV `{caminhos.dados}issues_YYYY-MM-DD.csv`
- relatório `{caminhos.historico}analyses/YYYY-MM-DD_priorizacao_backlog.md` com lista priorizada, anomalias por categoria e resumo de ações por severidade

**Portões**

- escopo ambíguo → pergunta antes de exportar
- a ação só identifica anomalia — corrigir rótulo ou descrição é passo separado, aprovado pelo usuário

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/backlog-prioritization/SKILL.md` | existe |
| Encaixe `funil` — Funil de priorização | `org/workflows/backlog-prioritization/references/funil.yaml` | preenchido por esta organização |
| Encaixe `procedimento` — Como fazer | `org/workflows/backlog-prioritization/references/procedimento.md` | preenchido por esta organização |

**Provas de comportamento**

- declaradas aqui (2): `roda-priorizacao` · `sem-provider`
- contraprova em (1): `backlog-analysis`

`./runtime/eval.sh --skill backlog-prioritization`

---

### publicar-na-wiki

**Publicar na wiki** — Publicar e atualizar a documentação de produto na wiki sem sobrescrever em silêncio o que já estava lá.

| | |
|---|---|
| Workflow | `wiki-publish` (pack padrão + encaixes desta organização) |
| Exige antes | — |
| Produz na esteira | — |
| Ferramenta externa | `backlog`, escolhido por `BACKLOG_PROVIDER`, exige a capacidade `wiki` |

**Dispara quando**

> Publica ou atualiza páginas na wiki do projeto, conferindo antes se existem. Use para "publica na wiki", "cria a página", "atualiza a wiki". Entrada de changelog é changelog-generator.

**Entrega**

- página criada, atualizada em replace ou acrescida em append, e a URL devolvida
- registro em `{caminhos.historico}YYYY-MM-DD_wiki_<slug>.md`

**Portões**

- publicar e sobrescrever são escrita com preview e aprovação — a wiki normalmente não tem lixeira
- em replace, mostra o conteúdo atual antes
- em append, mostra só a entrada nova e nunca lê a página inteira

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/wiki-publish/SKILL.md` | existe |
| Encaixe `nomenclatura-pagina` — Nome e lugar da página | `org/workflows/wiki-publish/references/nomenclatura.md` | preenchido por esta organização |
| Encaixe `procedimento` — Como fazer | `org/workflows/wiki-publish/references/procedimento.md` | padrão do pack |

**Provas de comportamento**

- declaradas aqui (2): `publica-na-wiki` · `sem-provider`
- contraprova em (1): `changelog-generator`

`./runtime/eval.sh --skill wiki-publish`

---

### publicar-prototipo

**Publicar protótipo** — Pôr o protótipo num endereço que dá para mandar ao cliente, com autenticação e HTTPS.

| | |
|---|---|
| Workflow | `prototype-deploy` (pack padrão) |
| Exige antes | — |
| Produz na esteira | — |
| Ferramenta externa | nenhuma |

**Dispara quando**

> Publica o protótipo num servidor como site estático, com autenticação e HTTPS. Use para "publica o protótipo", "coloca no ar", "URL compartilhável". Deploy de produção fora do escopo.

**Entrega**

- protótipo publicado com SPA fallback, autenticação, HTTPS renovável e cache correto
- comando de republicação que roda num passo, buildando local
- bloco `prototipo_deploy` do `project-config.yaml` preenchido

**Portões**

- cada passo de configuração, comando destrutivo e escrita no `project-config.yaml` é um portão separado
- campo de configuração faltando → pergunta, não inventa (domínio errado queima o rate limit do certificado)
- desligar a autenticação exige decisão explícita do responsável, registrada

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/prototype-deploy/SKILL.md` | existe |
| Encaixe `procedimento` — Como fazer | `org/workflows/prototype-deploy/references/procedimento.md` | padrão do pack |
| Encaixe `receita-servidor` — Receita do servidor | `org/workflows/prototype-deploy/references/vps-nginx.md` | padrão do pack |

**Provas de comportamento**

- declaradas aqui (1): `publica-prototipo`
- contraprova em (1): `prototype-prints`

`./runtime/eval.sh --skill prototype-deploy`

---

### registrar-demanda

**Registrar demanda** — Transformar um pedido em demanda registrada no backlog — o problema, não a solução que veio junto.

| | |
|---|---|
| Workflow | `backlog-issue-creator` (pack padrão + encaixes desta organização) |
| Exige antes | — |
| Produz na esteira | `demanda-registrada` |
| Ferramenta externa | `backlog`, escolhido por `BACKLOG_PROVIDER`, exige a capacidade `core` |

**Dispara quando**

> Cria ou refina demanda no backlog com template, criticidade e labels. Use para "cria uma issue", "abre um bug", "registra essa melhoria", "refina a #NNN", "a issue só tem título". Ver, comentar ou fechar demanda existente é backlog-query.

**Entrega**

- demanda criada ou refinada no backlog, com o corpo no formato do encaixe `template-demanda`
- etapa de triagem do funil aplicada na entrada, com justificativa

**Portões**

- apresenta a demanda documentada e itera na conversa antes de tocar no backlog
- aprovação explícita antes de criar ou atualizar a demanda
- label nova nunca é inventada sem aprovação — a taxonomia real vem do provider
- no refino, mostra o conteúdo atual antes de sobrescrever

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/backlog-issue-creator/SKILL.md` | existe |
| Encaixe `procedimento` — Como fazer | `org/workflows/backlog-issue-creator/references/procedimento.md` | preenchido por esta organização |
| Encaixe `template-demanda` — Modelo de demanda | `org/workflows/backlog-issue-creator/references/templates.md` | preenchido por esta organização |

**Provas de comportamento**

- declaradas aqui (2): `cria-issue` · `sem-provider`
- contraprova em (1): `backlog-query`

`./runtime/eval.sh --skill backlog-issue-creator`

---

### versionar-mudancas

**Versionar mudanças** — Fechar o trabalho em commits atômicos por camada, com push e PR — sem `git add -A` e sem commit gigante.

| | |
|---|---|
| Workflow | `committer` (pack padrão) |
| Exige antes | — |
| Produz na esteira | — |
| Ferramenta externa | nenhuma |

**Dispara quando**

> Commit manual: só com @committer ou $committer explícito. Commits convencionais separados por camada, plano mostrado antes de rodar git, push e PR.

**Entrega**

- branch, commits convencionais separados por camada, push e PR aberto
- resumo com hash, mensagem e URL do PR

**Portões**

- só ativa com `@committer` explícito — nenhuma persona ou skill a chama por baixo
- Plano de Commit, com a linha `Branch:` sempre visível, aprovado antes de qualquer `git add`
- arquivo sensível no diff para o fluxo e avisa, mesmo que o usuário tenha pedido o diretório inteiro

**Onde se edita**

| O quê | Arquivo | Estado |
|---|---|---|
| Moldura (do sistema) | `system/pack/workflows/committer/SKILL.md` | existe |
| Encaixe `procedimento` — Como fazer | `org/workflows/committer/references/procedimento.md` | padrão do pack |

**Provas de comportamento**

- declaradas aqui (2): `chama-committer` · `commita-sem-chamar`
- contraprova em (1): `committer`

`./runtime/eval.sh --skill committer`

---

<!-- /gerado -->
