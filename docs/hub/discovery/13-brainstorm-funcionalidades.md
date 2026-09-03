# 13 — Brainstorm de funcionalidades

> **Método:** `opportunity-solution-tree` (L1) — geração antes do corte. Cada ideia
> pendurada em **uma** oportunidade de 10; ideia que serve a tudo não serve a nada.
> **Estado:** lista de candidatos, sem priorização. O corte é em 14, 15 e 18.

---

## Regras usadas na geração

1. Toda ideia aponta para uma oportunidade (O1–O6 de 10).
2. Marcada por origem: **existe** (motor, PRD §8.1) · **desenhado** (§8.2) · **novo** (§8.3).
3. Ideia sem oportunidade vai para a seção "sem lastro" — e é ali que costuma estar o que a
   gente quer fazer por gosto.

## O1 — tempo perdido com formato

| # | Ideia | Origem |
|---|---|---|
| F01 | ação "documentar requisito" executando no padrão declarado | existe |
| F02 | encaixe de estrutura do documento, por tipo de artefato | existe |
| F03 | saída no destino que o time usa: backlog, wiki ou documento formal (`.docx`/PDF) | existe |
| F04 | biblioteca de presets de estrutura por tipo de artefato | novo |
| F05 | importar documento antigo e **extrair** o padrão dele automaticamente | novo |
| F06 | verificação de conformidade: apontar onde um documento foge do padrão | novo |

## O2 — padrão esquecido, descoberto na revisão

| # | Ideia | Origem |
|---|---|---|
| F07 | contrato de saída garantido por estrutura (fora do alcance de quem configura) | existe |
| F08 | portão como estado do artefato | desenhado |
| F09 | aviso de encaixe vazio / ação indisponível | existe |
| F10 | checklist de saída visível no artefato, derivado do contrato | novo |
| F11 | histórico de versões do padrão, com o que mudou entre elas | novo |

## O3 — contexto espalhado

| # | Ideia | Origem |
|---|---|---|
| F12 | integrações de backlog, conhecimento, banco, documento, canvas | existe |
| F34 | **backlog e sprint operados na ferramenta do time** — registrar, refinar, priorizar pelo funil declarado, criar e fechar sprint, consultar; tudo por integração, com preview antes da escrita. Sem backlog próprio (00, v4) | existe — provider abstrai as operações; **só GitHub e GitLab implementados** |
| F35 | implementações novas de provider de backlog (Jira, Linear, Azure Boards) | novo — construção por ferramenta, sob a mesma interface |
| F13 | contexto do produto no espaço, legível por pessoa e agente | desenhado |
| F14 | busca no histórico de decisões do espaço | novo |
| F32 | **estruturas de produto viram ação declarada e artefato do espaço** — roadmap, OKR, personas, lean canvas, story map, árvore de métricas, PR/FAQ, princípios: existem como estrutura pronta com contrato de saída, e nenhuma tem ação no catálogo | parcial — estrutura existe, ação e artefato não |
| F33 | quadro visual estilo whiteboard (post-it, colaboração simultânea no mesmo canvas) | novo — **não é o que o PRD pede**, registrado para não voltar como interpretação errada |
| F15 | repositório de arquivos do produto, **hospedado** — documento nativo em Markdown criado e editado no sistema, mais upload de arquivo de qualquer tipo | novo — **promovido à primeira versão em 2026-08-29** |
| F36 | **frontmatter YAML obrigatório em todo documento** (tipo, demanda, status, tags, data) **e busca por metadado** — a ação filtra o repositório em vez de varrer | novo — é a peça que transforma pasta de arquivo em contexto utilizável |
| F37 | sincronização com Google Drive por link, **somente leitura** — o que muda lá aparece aqui; o inverso nunca, para não criar duas fontes de verdade | novo |
| F16 | espaço acessível por outras ferramentas e agentes | novo |

## O4 — onboarding lento

| # | Ideia | Origem |
|---|---|---|
| F17 | espaço com padrão já valendo desde o primeiro dia | desenhado |
| F18 | trabalhar pela conversa, sem precisar aprender o padrão | desenhado |
| F19 | trilha de exemplos: "veja como esta empresa documenta" | novo |

## O5 — desconfiança da saída de IA

| # | Ideia | Origem |
|---|---|---|
| F20 | esteira com estado e trilha de quem aprovou | desenhado |
| F21 | preview antes de qualquer escrita externa | desenhado |
| F22 | citação de fonte no que foi afirmado | existe |
| F23 | diferença visível entre o que a IA propôs e o que a pessoa mudou | novo |
| F24 | relatório de aceitação por espaço (quanto passou sem reescrita) | novo |

## O6 — serialização

| # | Ideia | Origem |
|---|---|---|
| F25 | conversas em paralelo, várias demandas na mesma tela | novo |
| F26 | trabalho assíncrono agendado | novo |
| F27 | notificação quando um artefato entra em "aguardando revisão" | novo |

## O7 — demanda com tela parada esperando o desenho da solução

Ramo acrescentado em 2026-08-18: existe no motor e estava ausente do discovery.

| # | Ideia | Origem |
|---|---|---|
| FD1 | brief da tela a partir da demanda (o que ela vira na interface) | existe |
| FD2 | construção da tela como protótipo navegável | existe |
| FD3 | prints do protótipo alimentando a documentação | existe |
| FD4 | publicação do protótipo na infra que o cliente já tem, com HTTPS e autenticação | existe |
| FD5 | scaffold do protótipo e extração de tokens do design system | existe |
| FD6 | hospedagem gerenciada pelo próprio produto (build, domínio, certificado, storage) | novo |
| FD7 | comentário do stakeholder direto sobre o protótipo publicado | novo |

## Itens de configuração e de gestão

| # | Ideia | Origem |
|---|---|---|
| F28 | personalização de personas e agentes da empresa (identidade, escopo, fronteira) | existe parcialmente — `PERSONA.md` é sobrescrevível pela organização |
| F29 | edição de documento direto no sistema, por pessoa **e** por IA, no mesmo arquivo — só Markdown | novo — **promovido à primeira versão em 2026-08-29**; é o que torna F15 usável |
| F30 | visão de discovery e delivery por demanda: em que fase está, o que falta | parcial — a esteira modela, falta a visão |
| F31 | ação nova criada pela empresa, para trabalho que o sistema não faz | existe |

## A lacuna repertório × catálogo — achado de 2026-08-18

| | Quantidade |
|---|---|
| Estruturas de produto no repertório, com contrato de saída declarado | **86** |
| Ações no catálogo público | **28** |
| Estruturas estratégicas (roadmap, OKR, personas, lean canvas, story map, árvore de métricas, PR/FAQ, posicionamento, visão, estratégia, princípios, segmentação, impact mapping) com ação declarada | **0** |

O motor **sabe** produzir todas elas — este discovery inteiro foi escrito com essas
estruturas. O que não existe é a ação que as produza como trabalho nomeado e guarde o
resultado como artefato do espaço, com estado e portão.

Um recorte concreto dessa lacuna — a cadeia de 21 métodos que produziu este discovery
inteiro, e o que seria preciso para pedi-la como trabalho nomeado — está em
[`../DISCOVERY-DE-PRODUTO.md`](../DISCOVERY-DE-PRODUTO.md).

Consequência para o produto: o item "workshops e canvas" do PRD não é construção de uma
ferramenta nova. É **declarar ação sobre repertório que já existe** — que é exatamente o
mecanismo de extensão que a arquitetura foi feita para suportar. Por isso F32 tem confiança
alta e esforço médio, e não entra na mesma categoria de kanban ou métricas de delivery.

## Sem lastro em oportunidade — o alerta do método

Estas apareceram na lista original de features e **não se penduram em nenhuma oportunidade
evidenciada**. Não significa que sejam ruins; significa que ainda não têm problema associado:

| Ideia | O que falta para ter lastro |
|---|---|
| ~~Kanban próprio~~ | **resolvido em 2026-08-29 — virou decisão de escopo, não pergunta.** O produto não constrói backlog, quadro nem sprint próprios: o mercado é bem servido, o time já paga por uma ferramenta, e o trabalho de backlog acontece nela por integração (F34). Volta à mesa só se A14 for refutada (09) |
| Tarefas pessoais e compartilhadas | idem — hoje é dor de nenhuma persona mapeada |
| ~~Workshops e canvas~~ | **resolvido em 2026-08-18.** Não é editor de canvas: são **estruturas prontas** — 86 delas, com contrato de saída declarado (`system/professions/*/methods/`). A necessidade é *todo o contexto do produto viver no sistema*, logo pertence a O1. Vira F32 |
| Métricas, metas e gráficos de delivery | qual decisão do P1 muda com esse gráfico? |
| Voz | qual situação de uso pede voz e não texto? |
| Projetos dentro de espaços | é hierarquia de organização, não dor — só vira necessidade em qual escala? |
| Permissões e perfis | necessário para vender a empresa maior; não é dor do beachhead |

## Promoção de 2026-08-29 — o ramo O1 inteiro entra

F13, F15, F29, F32, F36 e F37 deixam de ser "novo, depois" e viram a metade nova da primeira
versão (`../MVP.md`). **O que mudou não foi a evidência — foi a disposição de pagar o
esforço.** O lastro sempre esteve em O1, a única oportunidade `[F]` da árvore; o que segurava
era o score de facilidade, e 14 já registrava isso como limite do modelo.

O que a decisão embute e não estava escrito em lugar nenhum: **a hipótese de que o
repositório de contexto é o gancho de entrada do produto** — mais que a execução. Vira a
premissa A15 em 09, `[S]`, sem evidência, e é a premissa mais cara que este discovery carrega.

**Consequência:** estas ideias não entram em 14 (não há o que pontuar sem problema
associado) e aparecem em 15 como classificação de natureza, ou em 18 como `WONT` declarado.

## Ideias descartadas na geração — e por quê

| Ideia | Descarte |
|---|---|
| "Monte seu próprio agente" **sem moldura** | destrói a garantia que é o diferencial (06). Personalizar persona dentro da moldura (F28) é outra coisa e continua na lista |
| Marketplace de padrões entre empresas | o padrão é o ativo do cliente; expor é anti-produto |
| **Backlog, quadro e sprint próprios** | descartado em 2026-08-29 por escopo: a categoria já é bem atendida, e construir a nossa vira projeto de migração para o cliente e briga de paridade com Jira para nós. O trabalho de backlog fica, executado na ferramenta do time (F34). Volta só com A14 refutada (09, 16 cenário 8) |
| Editor visual de workflow | expõe a mecânica interna — risco "núcleo exposto" (`../MODOS.md` §7) |
| Modo "sem portão" para clientes com pressa | uma exceção mata a promessa inteira |

---

## Matriz de cobertura do PRD original

Trava de completude, criada em 2026-08-18 depois de o ramo de protótipo ser omitido. **Todo
item da lista original tem que aparecer aqui com veredito.** Item sem oportunidade
evidenciada não sai do documento — recebe "sem lastro" e a pergunta que lhe falta.

| # | Item do PRD original | Onde está | Veredito |
|---|---|---|---|
| 1 | Criação de espaços | F17 · 17 · 18 | **MUST** no MVP |
| 2 | Projetos dentro de espaços | 13 sem lastro · 18 | `WONT` — hierarquia sem dor no tamanho do alvo |
| 3 | Personalização de skills e agentes | F02 (encaixes) · **F28** (personas) | encaixes **MUST**; personas `WONT` no alpha |
| 4 | Repositório de documentos compartilhados, editáveis no sistema | F15 (arquivos) · **F29** (edição) · **F36** (metadado) | **MUST** — revisto em 2026-08-29: é o recipiente do contexto único, não conforto |
| 5 | Integrações via MCP ou API | F12 (contexto) · F16 (espaço por fora) | F12 **MUST**; F16 descartado do ciclo |
| 6 | Automações com cron (assíncrono, PO valida) | F26 | segunda onda — é mecanismo de velocidade |
| 7 | Criação e hospedagem de protótipos | FD1–FD5 | brief e tela **MUST**; publicar na infra do cliente SHOULD; hospedagem pelo produto (FD6) `WONT` |
| 8 | Workshops e canvas (roadmap, personas, OKR) | **F32** (ramo O1) | **MUST**, revisto em 2026-08-29 — não como canvas livre: cada estrutura com forma declarada, um conjunto essencial, o resto por demanda. É a aposta A15 |
| 9 | Criação e edição de documentos (humano e IA) | F01 (criação) · **F29** (edição) | criação **MUST**; edição no sistema **MUST**, revisto em 2026-08-29 — só Markdown |
| 10 | Controle do repositório de arquivos | F15 · F37 | **MUST** — upload, exclusão e sincronização com Drive (somente leitura) |
| 11 | Permissões e perfis | 13 sem lastro · 18 | `WONT` — pré-requisito de venda para time maior |
| 12 | Tudo roda no PC do usuário (SDK) | 08 D2 · PRD §12 | **resolvido em 2026-08-29, e a resposta é dividida: contexto no servidor, execução no cliente.** O repositório é hospedado — local, ele reproduz o problema que O1 descreve. A **execução** roda na máquina do usuário, com a chave de IA dele: o motor já roda assim hoje, e construir plataforma de sandbox para um punhado de pessoas é o cenário 1 (16) |
| 13 | Paralelizar, voz e texto, vários chats | F25 (paralelo) · voz | paralelismo: aposta central, **segunda onda**; voz `WONT` |
| 14 | Tarefas pessoais e compartilhadas | 13 sem lastro · 18 | `WONT` — nenhuma persona mapeada tem a dor |
| 15 | Kanban com issues próprias | **F34** (o caminho escolhido) · 18 | `WONT` **por escopo** — o produto opera o backlog do time por integração, não constrói o seu. Reverso em 15; retorno só via A14 refutada (09) |
| 16 | Espaço manipulável via MCP | F16 | descartado deste ciclo — plataforma antes de produto |
| 17 | Acompanhamento de métricas e metas | 13 sem lastro · 18 | `WONT` no alpha |
| 18 | Métricas e gráficos de delivery | 13 sem lastro · 18 | `WONT` no alpha — a medição do MVP é de ciclo, não painel. Métrica **de backlog** é da ferramenta que o time já usa, e continua lá |
| 19 | Gestão de discovery e delivery | **F30** · esteira (F08, F20) | esteira **MUST**; visão consolidada COULD |
| 20 | Documentação padronizada | F01 · F02 · F03 | **MUST** — é o núcleo do MVP |

E as afirmações da seção "O que é":

| Afirmação | Onde está | Veredito |
|---|---|---|
| "realizar todas as ações de PM/PO" | 22 ações no motor; catálogo declarado | direção do produto; no MVP são 5 ações |
| "padronizada e personalizada com os padrões da empresa" | F02, F07 | **MUST** |
| "colaborativa, unifica todas as áreas em 1 ferramenta" | F13, F17 | espaço **MUST**; unificação total é direção |
| "contexto disponível para qualquer pessoa ou agente de IA" | F13, F16 | contexto para pessoas **MUST**; para agentes externos, descartado do ciclo |
| "paralelizar demandas e projetos" | F25 | segunda onda |
| "por voz ou por texto" | F18 (texto), voz | texto **MUST**; voz `WONT` |
| "IA treinada, funciona sem nenhuma configuração" | pack padrão (existe) | **MUST** — é o que faz o dia 1 funcionar |
| "orientável por workflows e templates" | F02, F31 | encaixes **MUST**; ação nova da empresa, fora do alpha |
