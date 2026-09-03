# 14 — RICE / ICE

> **Métodos:** `prioritization-selection` + `ice` (L1). **Contrato:** modelo escolhido e o
> que ele ignora · escala e quem pontua · dimensões + score + banda + justificativa · itens
> tratados fora do score.
> **Estado:** repontuado em 2026-08-18 (v3) contra o **novo outcome** (tempo de ciclo, 10).
> Score muda quando o outcome muda — não é inconsistência, é o método funcionando.

---

## Escolha do modelo — e por que RICE foi recusado

| Modelo | Exige | Temos? | Veredito |
|---|---|---|---|
| **RICE** | *Reach* medido | **não** — zero usuários | **recusado**: alcance inventado contamina o ranking |
| **WSJF** | custo do atraso estimável | não com esta incerteza | recusado |
| **ICE** | impacto, confiança, facilidade | sim, com rubrica | **escolhido** |

**O que o ICE ignora aqui, declarado:** dependência entre itens (F03 sem F01 não existe),
efeito composto do workflow acumulado, e risco de tese. Nada disso entra no número.

**Quem pontua:** Gustavo, sozinho — limite honesto desta rodada. O contrapeso é a rubrica
pública abaixo e a revisão depois de 07.

## Rubrica

**Impacto — quanto o item reduz o tempo de ciclo ou aumenta demandas concluídas por pessoa**
(mudou na v3: antes era "quanto melhora a aceitação do artefato")

| Nota | Critério |
|---|---|
| 5 | sem isto o ciclo não encurta |
| 4 | corta tempo de forma direta e observável |
| 3 | corta tempo indiretamente, ou destrava outro item que corta |
| 2 | melhora a experiência sem mexer no ciclo |
| 1 | sem relação demonstrável com o ciclo |

**Confiança**: 5 em uso real com efeito observado · 4 evidência forte `[F]` sem efeito
medido · 3 indício `[I]` · 2 suposição `[S]` · 1 palpite.

**Facilidade**: 5 já existe · 4 dias · 3 semanas · 2 mês+ · 1 trimestre+ com arquitetura em
aberto.

**Score = I × C × F** (1–125) · **Bandas:** ≥ 80 fazer já · 40–79 planejar · 15–39 depois ·
< 15 descartar deste ciclo.

## Ranking

| # | Item | I | C | F | Score | Banda |
|---|---|---|---|---|---|---|
| F01 | ação executando o procedimento declarado | 5 | 5 | 5 | **125** | fazer já |
| FD2 | construção da tela como protótipo navegável | 5 | 5 | 5 | **125** | fazer já |
| F12 | integrações de contexto (backlog, conhecimento, banco) | 5 | 5 | 5 | **125** | fazer já |
| F34 | backlog e sprint operados na ferramenta do time | 4 | 3 | 5 | **60** | planejar |
| F02 | encaixes: como fazer, estrutura, classificação | 5 | 4 | 5 | **100** | fazer já |
| F03 | saída no destino que o time usa | 4 | 5 | 5 | **100** | fazer já |
| FD1 | brief da tela a partir da demanda | 4 | 5 | 5 | **100** | fazer já |
| F07 | contrato de saída fora do alcance de quem configura | 4 | 5 | 5 | **100** | fazer já |
| FD3 | prints do protótipo na documentação | 3 | 5 | 5 | **75** | planejar |
| F18 | conversa como interface | 5 | 4 | 3 | **60** | planejar |
| F21 | preview antes de escrita externa | 3 | 5 | 4 | **60** | planejar |
| FD4 | publicar protótipo na infra do cliente | 3 | 5 | 4 | **60** | planejar |
| F09 | aviso de encaixe vazio | 2 | 5 | 5 | **50** | planejar |
| FD5 | scaffold do protótipo e tokens do design system | 2 | 5 | 5 | **50** | planejar |
| F08 | portão como estado do artefato | 4 | 4 | 3 | **48** | planejar |
| F24 | medição de ciclo e aceitação por espaço | 3 | 4 | 4 | **48** | planejar |
| F17 | espaço com o padrão valendo | 5 | 4 | 2 | **40** | planejar |
| F22 | citação de fonte | 2 | 4 | 5 | **40** | planejar |
| F32 | estruturas de produto viram ação e artefato do espaço | 3 | 4 | 3 | **36** | depois — **decisão sobrepôs o score** (ver abaixo) |
| F36 | frontmatter por documento + busca por metadado | 4 | 3 | 3 | **36** | depois — **decisão sobrepôs o score** |
| F15 | repositório de arquivos hospedado, com documento nativo | 4 | 3 | 2 | **24** | depois — **decisão sobrepôs o score** |
| F37 | sincronização com Drive, somente leitura | 3 | 3 | 2 | **18** | depois |
| F04 | presets de estrutura por tipo de artefato | 3 | 3 | 4 | **36** | depois |
| F14 | busca no histórico de decisões | 4 | 3 | 3 | **36** | depois |
| F20 | trilha de quem aprovou | 3 | 4 | 3 | **36** | depois |
| F27 | notificação de artefato aguardando revisão | 3 | 3 | 4 | **36** | depois |
| F28 | personalização de personas e agentes da empresa | 2 | 4 | 4 | **32** | depois |
| F13 | contexto do produto no espaço | 5 | 3 | 2 | **30** | depois |
| F31 | ação nova criada pela empresa | 2 | 4 | 3 | **24** | depois |
| F35 | provider novo de backlog (Jira, Linear, Azure Boards) | 3 | 3 | 2 | **18** | depois — por contrato, não por especulação (11) |
| F11 | histórico de versões do padrão | 2 | 3 | 3 | **18** | depois |
| F29 | edição de documento no sistema (pessoa e IA) | 3 | 3 | 2 | **18** | depois |
| F30 | visão consolidada de discovery e delivery | 2 | 3 | 3 | **18** | depois |
| F05 | extrair o padrão de documentos antigos | 4 | 2 | 2 | **16** | depois |
| F26 | trabalho assíncrono agendado | 4 | 2 | 2 | **16** | depois |
| F06 | verificação de conformidade | 2 | 2 | 3 | **12** | descartar |
| F23 | diferença entre proposto e editado | 2 | 2 | 3 | **12** | descartar |
| F10 | checklist de saída visível | 1 | 3 | 4 | **12** | descartar |
| F25 | conversas em paralelo | 5 | 2 | 1 | **10** | descartar |
| F16 | espaço acessível por fora | 2 | 2 | 2 | **8** | descartar |
| FD7 | comentário de stakeholder sobre o protótipo | 2 | 2 | 2 | **8** | descartar |
| F19 | trilha de exemplos | 1 | 2 | 4 | **8** | descartar |
| FD6 | hospedagem gerenciada pelo produto | 3 | 2 | 1 | **6** | descartar |
| — | voz | 2 | 1 | 2 | **4** | descartar |
| — | métricas e gráficos de delivery | 2 | 2 | 1 | **4** | descartar |
| F33 | quadro visual estilo whiteboard | 1 | 2 | 1 | **2** | descartar |
| — | workshops e canvas editáveis | 2 | 1 | 1 | **2** | descartar |


**Kanban próprio saiu do ranking em 2026-08-29.** Não é item com score baixo: é item fora de
escopo (00, v4). Pontuar mantinha a discussão viva toda rodada — está agora na tabela de
itens tratados fora do score, com a condição de retorno.

## Correção v3.1 — o ramo de design estava ausente

As linhas `FD*` foram acrescentadas em 2026-08-18. O ramo de protótipo existe no motor
(quatro ações) e **não constava** em nenhum documento do discovery — não foi cortado, foi
omitido. Consequência: o alpha atenderia só demanda sem interface, e o ciclo medido não
representaria o trabalho real de um time de produto.

`FD2` entra empatado no topo porque a construção da tela é a etapa mais longa do ciclo de
uma demanda com interface — e já roda hoje. `FD6` (hospedagem pelo próprio produto) é a
única do ramo que não existe, e a única descartada: é produto de infraestrutura e não
encurta ciclo nenhum.

## O que mudou de posição com o novo outcome

| Item | v2 (outcome = aceitação) | v3 (outcome = ciclo) | Por quê |
|---|---|---|---|
| **F12 integrações de contexto** | 100 | **125** | contexto espalhado é o custo de tempo com evidência mais forte (10, O1) |
| **F14 busca no histórico** | 27 | **36** | achar decisão passada é tempo direto |
| **F13 contexto no espaço** | 24 | **30** | idem, mas caro |
| **F27 notificação** | 24 | **36** | paralelismo sem aviso não funciona |
| **F26 assíncrono agendado** | 8 | **16** | sai de "descartar" — é mecanismo de velocidade |
| **F25 conversas em paralelo** | 6 | **10** | impacto 3→5, mas facilidade 1 segura o score. Ver abaixo |
| **F24 medição** | 64 | **48** | mede, não acelera — desceu ao mudar a régua |
| **F22 citação de fonte** | 60 | **40** | qualidade percebida, não ciclo |
| **F10 checklist visível** | 24 | **12** | vira descarte: não mexe no ciclo |

## Correção v5 — a decisão sobrepôs o score no ramo O1

Em 2026-08-29 o ramo O1 inteiro (F13, F15, F29, F32, F36) foi promovido à primeira versão,
**contra a banda que este documento atribuiu a cada um deles**. Registrado aqui como
sobreposição explícita, não como repontuação — repontuar depois de decidir é maquiar o
método:

| Item | Score | Banda | Decisão |
|---|---|---|---|
| F32 estruturas como artefato | 36 | depois | **entra** |
| F36 frontmatter + busca | 36 | depois | **entra** |
| F13 contexto do produto no espaço | 30 | depois | **entra** |
| F15 repositório hospedado | 24 | depois | **entra** |
| F29 edição de documento no sistema | 18 | depois | **entra** |

**A justificativa é a anomalia que este documento já tinha declarado:** o ICE penaliza
fundação por construção, e o fator que rebaixou os cinco foi **facilidade**, nunca impacto ou
confiança. Todos pendem de O1 — a única oportunidade `[F]` da árvore.

**O que a sobreposição custa, dito sem eufemismo:** o argumento "o score não captura
fundação" é verdadeiro e também é o argumento perfeito para justificar qualquer item caro que
alguém queira fazer. O que o separa de racionalização é a premissa A15 estar escrita, marcada
`[S]`, e com o sinal que a refuta declarado antes (`../MVP.md`, Parte 4). Se a onda 1 não for
usada sozinha, a sobreposição estava errada — e isso precisa ser dito, não reinterpretado.

## Itens tratados fora do score

O método manda tirar da fila o que o modelo não sabe pontuar:

| Item | Por que sai | Decisão |
|---|---|---|
| **F34 — backlog e sprint na ferramenta do time** | o score (60) engana nos dois sentidos: a mecânica já existe e é barata, mas a **confiança 3** é o número que importa — ninguém verificou se a integração cobre a customização real dos times (A14 em 09). Um número de facilidade alta esconde que o risco não é construir, é a cobertura | manter em "planejar", e tratar A14 como o gate: se 07 mostrar times fora do que a interface cobre, F34 sobe de esforço e F35 vira caminho crítico |
| **Backlog, quadro e sprint próprios** | não é item de fila: é escopo recusado (00, v4). Score não decide isso — decisão de produto decide | volta a ser pontuado apenas se A14 for refutada (09, 16 cenário 8) |
| **F25 — conversas em paralelo** | é a **aposta central da nova tese** (velocidade vem de quebrar a serialização) e tem o pior score da metade de cima: impacto 5, facilidade 1, confiança 2. O número diz "descartar"; a tese diz "é o produto". **Um dos dois está errado, e o score não resolve isso** | decidir no explícito depois de 10 (experimento de ciclo): se a medição mostrar que a espera entre demandas é a maior fatia do ciclo, F25 vira prioridade máxima e a facilidade deixa de ser argumento |
| **F05 — extrair o padrão de documentos antigos** | aposta de entrada: resolve o atrito de declarar o workflow | decidir depois de 07 |
| **Permissões e perfis** | pré-requisito de venda, não valor | quando entrar time maior |
| **Decisão "onde o trabalho roda"** (D2) | escolha de arquitetura com efeito comercial | decidir antes do alpha |

## Anomalias — reportadas, não corrigidas

| Anomalia | O que significa |
|---|---|
| **Os dois itens de maior impacto da tese (F25 paralelismo, F17 espaço) estão abaixo de itens de impacto menor** | ICE penaliza fundação e aposta por construção. É o limite do modelo, não do julgamento — a ordem de execução vem de 17, não do score |
| F03 depende de F01, e a dependência não aparece no número | o ranking sugere paralelismo que não existe |
| Nenhum item "novo" (PRD §8.3) alcança a banda "fazer já" | esperado: são caros e sem evidência. Se a tese de velocidade estiver certa, a evidência precisa vir do experimento de 10 — não de repontuar |
