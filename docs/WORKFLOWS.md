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

> Analisa o backlog do projeto a partir de um único export em lote do backlog, salvando o CSV bruto no repositório e gerando relatórios em Markdown com métricas, scores e gráficos texto. Use esta skill sempre que o usuário pedir análise de sprint, métricas do backlog, status de issues, velocidade do time, distribuição por tipo ou prioridade, burndown, ou qualquer visão quantitativa do backlog — com ou sem filtro de sprint. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

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

> Analisa uma demanda ANTES de construir a tela: lê a documentação do PM (`.md` consolidado, documento de requisito, issue), varre o protótipo existente (rotas, componentes de ui/, tokens, telas irmãs) e devolve em conversa o que a demanda vira na interface — navegação, reuso, gaps do design system, estados não previstos, impacto nas telas existentes, pendências de produto. Escala com a entrada: ajuste em tela existente não passa por aqui; texto simples vira análise leve; imagem vira média; documentação/issue vira completa. Gerar o {ID}_design.md é OPT-IN, no fim. Use quando o usuário pedir para analisar, avaliar, sugerir ou entender uma demanda de tela antes de codar. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

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

> Audita a saúde do backlog detectando issues sem tipo, sem prioridade, sem sprint, sem assignee, possíveis duplicatas por similaridade de título e issues "zumbis" (abertas há mais de 6 meses sem atualização). Exporta os dados do backlog em uma única chamada, salva o CSV no repositório, e gera um relatório de saúde com recomendações e opção de correções em lote. Use quando o usuário pedir para limpar o backlog, encontrar inconsistências, ver duplicatas ou auditar a qualidade das issues. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

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

> Captura as prints do protótipo (prototype/) que entram na seção Protótipo do documento de uma demanda — o .md consolidado da demanda e o .docx gerado a partir dele. Define o recorte a partir da documentação da demanda (não do git diff), organiza as prints por fluxo, e captura com Playwright em dimensões adequadas para página A4: telas longas em partes contínuas, componentes no próprio limite e todas as imagens com borda fina. Use quando o usuário pedir prints, screenshots ou imagens do protótipo para documentação — "tira as prints da #NNN", "preciso das telas pra colocar no docx", "salva as imagens do protótipo". Não use para export pro Figma (é html-to-figma) nem para criar/ajustar tela (é design-screen).

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

> Configura o design system do projeto E faz o scaffold do app de protótipo navegável (prototype/) na primeira vez que o designer é acionado. Extrai tokens de cor, tipografia, espaçamento e padrões de componentes de prints/screenshots do sistema atual; grava os tokens na configuração de estilo e cria os componentes base transcritos das evidências. Push dos guidelines para a ferramenta de canvas é opt-in. Use na primeira vez que o designer for acionado — antes de criar qualquer tela — e para atualizar o design system quando ele evoluir.

**Entrega**

- `prototype/` scaffoldado — tokens em arquivo único, componentes base próprios, uma tela por rota, menu real e wrapper de export
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

- declaradas aqui (1): `configura-design-system`
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

> Cria E ajusta telas como rotas React no app de protótipo do projeto (prototype/) a partir de uma demanda do backlog, documento de requisito, descrição livre ou número da demanda. Dois modos: AJUSTE (tela já existe → referência é o próprio protótipo, tokens e telas irmãs; NÃO pede print) e NOVO (tela inexistente → pede node do Figma, imagem ou wireframe). Reusa src/components/ui/, liga a rota ao menu real do produto e verifica por diff visual. Export de telas escolhidas pro Figma é opt-in. Use sempre que o usuário pedir criar OU ajustar uma tela, protótipo, componente ou fluxo. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

**Entrega**

- rota em `prototype/src/routes/`, registrada no roteador e alcançável pelo menu real, com estados via `?state=`
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

> Consulta e operação pontual no backlog do projeto — ver uma demanda, buscar por texto, listar por sprint/label/responsável, criar/atualizar/comentar/fechar uma demanda específica, listar labels e sprints. Use para qualquer pedido pontual de backlog: "vê a #NNN", "busca issues sobre X", "quais issues da sprint atual", "comenta na #NNN", "fecha a #NNN", "quais labels existem", e também quando o usuário citar a ferramenta direto (glab, GitLab, Linear, Jira). Para varredura do backlog inteiro use backlog-analysis, backlog-health ou backlog-prioritization.

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

> Executa consultas SQL no banco de dados de homologação do projeto usando o cliente CLI configurado no .env (sqlcmd, psql, mysql, sqlite3 ou qualquer outro). Suporta qualquer autenticação — senha, Windows/NTLM, Kerberos, .pgpass — sem depender de MCP. Use sempre que precisar consultar dados reais do banco: estrutura de tabelas, valores de registros, contagens, inconsistências entre o comportamento esperado e o estado atual dos dados.

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

> Gera a Meta da Sprint (Sprint Goal) no padrao do Guia do Scrum 2020, com foco em OUTCOME (ganho de valor para o usuario/negocio) e nao em output (funcionalidades entregues). Use sempre que o usuario pedir para criar, escrever, montar ou sugerir uma Meta da Sprint, Sprint Goal, objetivo da sprint, ou enviar HUs/backlog pedindo para definir a meta. Tambem quando perguntar qual seria a meta mesmo sem usar o termo exato. Trigger agressivo: qualquer combinacao de meta + sprint + contexto de desenvolvimento de software.

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

> Gera o documento .md consolidado de uma demanda — fonte de verdade única que reúne a descrição da funcionalidade, os critérios de aceite, as regras de negócio, as mensagens ao usuário e a trilha do discovery. Use para pedidos genéricos como "documenta a #NNN", "gera a documentação", "consolida", "gera o md", "monta o documento base" ou "cria as regras da #NNN". Gera somente o `.md` e PARA para revisão humana — formato final (`.docx` ou outro) é passo separado, só após revisão e pedido explícito. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

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

> Conduz o discovery de uma demanda seguindo o Double Diamond: explora e define o problema (D1), depois explora e define a solução (D2). Cada fase vira um registro aprovado — no backlog e no histórico local. Detecta em que fase a demanda está e propõe a próxima pendente. Use quando o usuário pedir para explorar soluções, fazer discovery, discutir alternativas ou aprofundar o entendimento de um problema — referenciando ou não uma demanda. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

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

> Passo FINAL da documentação: transcreve um `.md` consolidado JÁ REVISADO (gerado pela skill doc-consolidator) para o formato final entregável — `.docx`, `.pdf` ou o que o projeto usar. Acione quando o usuário pedir EXPLICITAMENTE o documento formal: "gera o docx", "agora o documento final", "transforma o md em docx", "exporta o documento", "gera o PDF da demanda", "cria o documento formal". NÃO acione para pedido genérico ("documenta a #NNN") — isso gera o `.md` primeiro, via doc-consolidator, com parada para revisão humana. Só transcreve o `.md`; não relê discovery nem cria conteúdo. IMPORTANTE: leia .agents/system/providers/docs-output/INTERFACE.md antes de gerar.

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

> Gerencia sprints (milestones/ciclos) no backlog do projeto — GitLab, Linear, Jira ou o que estiver configurado: criar nova sprint com datas e objetivo, fechar sprint atual e gerar sumário de conclusão, mover issues entre sprints em lote, listar issues de uma sprint com status resumido, e documentar a sprint preenchendo a descrição com Meta da Sprint, Prazos e Escopo. Use para qualquer operação de gestão de sprint — criar, fechar, mover issues, ver o que está numa sprint, ou "documentar a sprint", "preencher a milestone", "atualizar a descrição da sprint". IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

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

> Reescreve prosa para tirar cara de IA. Use sempre que o usuário disser "humaniza", "humaniza esse texto", "cheiro de IA", "cara de IA", "cara de ChatGPT", "parece GPT", "parece LLM", "padrões de LLM", "tira o GPT", "sem parecer máquina", "AI tells", "stop-slop", "stop slop", "slop", ou pedir para revisar um rascunho contra prosa formulaica. Não documenta demanda, não gera entregável, não reescreve código.

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

> Gera ou atualiza o changelog do projeto (histórico de evolução) a partir de documentação de requisito, demandas entregues ou descrição de funcionalidade. Use sempre que o usuário mencionar "changelog", "histórico de evolução", "adiciona ao changelog", "registra a mudança", "atualiza o histórico" ou enviar documentação pedindo para registrá-la. A saída é uma tabela Markdown no formato definido pela organização.

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

> Prioriza as demandas do backlog pelo funil declarado da organização — triagem, dimensões, score e faixas. Exporta os dados em lote, extrai as dimensões da demanda, ranqueia pela ordenação declarada, detecta anomalias (rótulo errado, score inconsistente, tipo errado na fila) e gera o markdown da análise no histórico. Acione SEMPRE que o usuário mencionar: priorização, priorizar, ranking, lista ranqueada, ordem de prioridade, backlog priorizado, funil, MoSCoW, ICE score, RICE, WSJF, quadrante, matriz esforço × valor, quais issues entram primeiro, anomalia de prioridade, inconsistência de label, ou qualquer pedido que combine backlog + priorizar + ordenar + analisar. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

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

> Publica e atualiza páginas na wiki do projeto (GitLab, documents do Linear, Jira ou o backlog configurado). Use sempre que precisar publicar, criar ou atualizar documentação de produto na wiki — fluxo novo, módulo documentado, decisão técnica, ou entrada de changelog. Gatilhos: "publica na wiki", "cria a página", "atualiza a wiki", "documenta o módulo na wiki". Verifica se a página já existe antes de criar, e oferece append ou replace quando existe conteúdo anterior. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

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

> Publica o app de protótipo (prototype/) num servidor como site estático, atrás de autenticação e HTTPS. Descobre o "porteiro" HTTP do servidor (nginx no host, Traefik, Caddy, nginx-proxy) antes de assumir qualquer coisa, gera o script de publicação e o bloco de configuração a partir dos valores em project-config.yaml, e produz o passo a passo a ser executado no servidor. Use quando o usuário pedir para hospedar, publicar, subir, colocar no ar ou dar deploy do protótipo — ou pedir uma URL compartilhável dele. Não use para deploy do sistema de produção (backend/banco), que não é escopo deste harness.

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

> Cria e refina demandas do backlog com template estruturado, triagem de criticidade (MoSCoW ou o que o funil declarar) e labels corretas. Acione quando o usuário mencionar criar issue, item de backlog, demanda, feature, bug, melhoria ou qualquer coisa que precise ser rastreada — em português ou inglês (criar issue, demanda, backlog, bug, melhoria, feature, nova funcionalidade, erro, tarefa). Acione também para refinar/enriquecer demanda existente com pouca informação ("refina a #NNN", "completa", "a issue só tem título"). IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

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

> Agente MANUAL de commit — só ativa quando o usuário chama @committer/$committer explicitamente. Cria commits convencionais, faz push e abre PR. Sugere branch nova por padrão (não bloqueia commit em main — bloqueio de branch é responsabilidade do GitHub, não da skill), nunca faz commit único gigante, sempre separa por camada (harness, docs/contexto, protótipo, config), sempre apresenta o plano de commit antes de rodar qualquer comando git. Lê arquivo de tarefa se existir; funciona standalone também.

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
