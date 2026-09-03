# Discovery — Straggy Hub

Discovery de produto do Hub, conduzido com a profissão `product-specialist`
(`system/professions/product-specialist/`). Intenção do produto: [`../PRD.md`](../PRD.md).

> **Revisão v6 (2026-08-29). Onde o trabalho roda: dividido, não centralizado.** Decidido
> junto com o recorte técnico ([`../MVP-TECNICO.md`](../MVP-TECNICO.md)). **Repositório,
> artefatos e histórico das sessões ficam no servidor** — é o que precisa ser compartilhado.
> **A execução do agente roda na máquina do usuário, com a chave de IA dele.** O motor já roda
> assim hoje (modo repositório), os binários de provider já estão na máquina de quem trabalha,
> e construir plataforma de sandbox para um punhado de pessoas é o cenário 1 (16).
>
> **Responde D2** (08) e a pergunta 2 do PRD, que estavam abertas. **Enfraquece S10/A5** — a
> objeção de nuvem — porque o dado de trabalho não passa pela nossa infra durante a execução.
> **Anula o cenário 4** (margem invertida) enquanto a chave for do cliente.
>
> **E abre duas perguntas que não existiam:** se o cliente traz a chave, o que exatamente ele
> paga (D2b — a resposta é workflow, repositório e portão, e isso corrige a hipótese de preço
> em 03 §6); e o que fazer com o pack em texto puro no disco de quem usa, contra o requisito
> de propriedade intelectual do `MODOS.md` §6 (D2c — decisão antes da primeira venda, não
> antes de codar). Atingidos: 03, 08, 11, 13.

> **Revisão v5 (2026-08-29). O contexto único vira o recipiente, não a consequência.**
> Decidido pelo dono do produto, junto com o recorte do MVP ([`../MVP.md`](../MVP.md)). O
> ramo O1 — repositório de arquivos (F15), edição de documento no sistema (F29), estruturas
> de produto como artefato (F32), contexto no espaço (F13) — **sai de `WONT`/segunda onda e
> entra na primeira versão**. Junto com ele, três funcionalidades que o discovery não tinha
> nomeado: **frontmatter YAML por documento** e **busca por metadado** (F36), e
> **sincronização com Drive, somente leitura** (F37).
>
> **Isto não contradiz o método — corrige um limite que ele mesmo declarou.** O1 é a única
> oportunidade marcada `[F]`, e esses itens foram rebaixados por **facilidade baixa**, não
> por falta de lastro: "o ICE penaliza fundação e aposta por construção" está escrito em 14,
> na seção de anomalias. A decisão é bancar o esforço, no explícito.
>
> **A aposta que isso embute:** o repositório de contexto é o que atrai gente para o sistema
> — premissa **A15** (09), `[S]`, sem nenhuma evidência. Ela justificou o item mais caro da
> lista e não é testável com um usuário só. **Custo declarado:** o escopo da primeira versão
> cresceu, e com ele o risco do cenário 1 (16). A defesa está em MVP.md, na ordem de
> construção por ondas. Atingidos: 09, 10, 13, 14, 15, 18, 19.

> **Revisão v4 (2026-08-29). Recorte de escopo, decidido pelo dono do produto.** O Straggy
> **não é uma ferramenta de gestão de backlog** e não vai construir uma. O foco é
> **estratégia de produto e a aplicação técnica da gestão de produto**: criação de documentos
> e manipulação do contexto do projeto. Prioridade, refino, sprint e acompanhamento continuam
> sendo trabalho do PM/PO e continuam no catálogo — mas são executados **dentro da ferramenta
> que o time já usa**, por integração. Nada de issue, sprint, quadro ou estado de entrega
> próprios: esse mercado já é bem atendido por ferramentas cujo foco é só isso.
>
> **Ponto de atenção declarado junto com a decisão:** ferramenta de backlog é heterogênea —
> modelos de sprint diferentes, etapas de kanban customizáveis, campos próprios de cada casa.
> Operar por integração pode sair **pior** que abrir a ferramenta na mão. Se isso se
> confirmar no alpha, a decisão de manipular backlog dentro do produto é **reaberta** — ela
> está fechada por escopo, não por princípio. Vira a premissa A14 (09), o cenário 8 do
> pré-mortem (16) e o critério de saída S9 (19). Atingidos: 01, 02, 03, 04, 05, 06, 07, 08, 09,
> 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 — e, fora do discovery, `../PRD.md` e a interface do
> provider de backlog (`system/providers/backlog/INTERFACE.md`).

> **Revisão v3.2 (2026-08-18).** O ramo de protótipo/design e mais três itens da lista
> original de features estavam **ausentes** do discovery — não cortados, omitidos. Causa: os
> documentos registravam só o que tinha oportunidade evidenciada, e descartavam o resto em
> silêncio. Corrigido em 10, 13, 14, 17, 18 e 19, e criada a **[matriz de cobertura do
> PRD](13-brainstorm-funcionalidades.md#matriz-de-cobertura-do-prd-original)**: todo item da
> lista original aparece lá com veredito, inclusive os que ficam de fora.

> **Revisão v3 (2026-08-18).** A tese mudou: **o problema não é padronização, é ciclo lento
> e serial.** Padrão é consequência de ter o workflow configurado, não o destino. Outcome
> passou de "% aceito sem retrabalho" para **tempo de ciclo e throughput**, com aceitação
> como **contrapeso obrigatório** — velocidade que derruba qualidade não é velocidade.
> Reescritos: 01, 02, 10, 14. Corrigidos: 03, 06, 12, 15, 18, 19.

> **Revisão v2 (2026-08-18).** O documento 04 foi reescrito: a versão anterior tratava o
> fluxo do autor (cliente externo, ordem de serviço, HU/HT, `.docx`) como evidência de
> mercado. É amostra 1 com viés de origem. O produto é para **qualquer PM/PO**; o beachhead
> voltou a ser hipótese, recortada por comportamento. Os documentos 03, 05–09, 11–15 e 17–19
> foram corrigidos junto.

> **Estado.** Nenhuma entrevista com cliente foi realizada. Todo documento aqui declara o
> grau de evidência bloco a bloco; o que não tem fonte está marcado como suposição, e a
> saída de cada peça é uma **fila de teste**, não um plano. Documentos 05 e 07 são
> **roteiros prontos, não executados** — sem eles rodados, tudo que depende de fala de
> cliente continua hipótese.

## Legenda de evidência — vale em todos os documentos

| Marca | Significado |
|---|---|
| `[F]` | **Fato** — com fonte citada (arquivo do repositório, dado público, documento) |
| `[I]` | **Indício** — sinal real, amostra pequena ou fonte indireta |
| `[S]` | **Suposição** — sem fonte; existe para ser testada ou derrubada |

**Como este discovery foi conduzido, e o que dele pode virar capacidade da ferramenta:**
[`../DISCOVERY-DE-PRODUTO.md`](../DISCOVERY-DE-PRODUTO.md) — o mapa método → documento, os
oito mecanismos que nasceram da execução e não estavam em método nenhum, e por que declarar
isso como ação ainda seria prematuro.

**O que foi feito com este discovery:** o recorte de execução da primeira versão usável está
em [`../MVP.md`](../MVP.md) — resumo desta pasta em duas páginas, mais a lista fechada de
funcionalidades do MVP. Ele registra uma exceção declarada ao critério "nenhuma interface
antes de 3 contratos" (11, 16 cenário 1), com o que ela decide e o que não decide.

## Ordem de leitura

| # | Documento | Método (L1) | O que decide |
|---|---|---|---|
| 01 | [Visão do produto](01-visao-do-produto.md) | `product-vision` | o destino e o que ele exclui |
| 02 | [Árvore de problemas](02-arvore-de-problemas.md) | `problem-framing` | qual é a causa raiz, separada dos sintomas |
| 03 | [Lean Canvas](03-lean-canvas.md) | `lean-canvas` | o modelo de negócio como fila de hipóteses |
| 04 | [ICP + proto-persona](04-icp-proto-persona.md) | `segmentation` | para quem primeiro, e quem fica de fora |
| 05 | [JTBD + switch interviews](05-jtbd-switch-interviews.md) | `jtbd` | que progresso o cliente contrata, e o que ele demite |
| 06 | [Value Proposition Canvas](06-value-proposition-canvas.md) | `positioning` · `jtbd` | encaixe entre dor e produto |
| 07 | [Entrevistas Mom Test](07-entrevistas-mom-test.md) | `continuous-interview` | como conseguir evidência sem contaminar |
| 08 | [Matriz CSD](08-matriz-csd.md) | `csd-matrix` | o que é certeza, o que é achismo, o que ninguém sabe |
| 09 | [Assumption mapping](09-assumption-mapping.md) | `assumption-mapping` | qual premissa testar primeiro e com que teste |
| 10 | [Árvore de oportunidades](10-arvore-de-oportunidades.md) | `opportunity-solution-tree` | do outcome às soluções concorrentes |
| 11 | [Quatro riscos de Cagan](11-quatro-riscos-cagan.md) | `opportunity-assessment` | valor, usabilidade, viabilidade, negócio |
| 12 | [Impact mapping](12-impact-mapping.md) | `impact-mapping` | que comportamento precisa mudar para a meta acontecer |
| 13 | [Brainstorm de funcionalidades](13-brainstorm-funcionalidades.md) | `opportunity-solution-tree` | o repertório completo, antes do corte |
| 14 | [RICE / ICE](14-rice-ice.md) | `ice` · `prioritization-selection` | a ordem dentro de cada faixa |
| 15 | [Kano](15-kano.md) | `kano` | onde investir: obrigação, desempenho ou diferencial |
| 16 | [Pré-mortem](16-pre-mortem.md) | `experiment-design` · `decision-record` | como isto morre, e o que fazer antes |
| 17 | [User Story Mapping](17-user-story-mapping.md) | `story-mapping` | a fatia mínima que atravessa a jornada |
| 18 | [MoSCoW](18-moscow.md) | `moscow` | o que é inegociável para o alpha |
| 19 | [Pronto para alpha](19-pronto-para-alpha.md) | `definition-of-ready-done` · `launch-tiers` | quando dá para colocar na mão de alguém |

## As quatro decisões que este discovery toma

1. **O produto é para qualquer PM/PO; o beachhead é hipótese, não fato.** A hipótese de
   entrada é o time que **tem padrão e sofre para replicá-lo** — recorte por comportamento,
   não por modelo de negócio. Quem decide é 07, não este documento (04).
2. **O produto vende velocidade, não padronização** — mas velocidade **cujo resultado é
   aproveitável**. Velocidade sozinha é a alegação mais comum do mercado e compete de frente
   com chat genérico; o que separa é a garantia estrutural (portão, contrato de saída) que
   permite acelerar sem revisar tudo (01, 06).
3. **O produto não gere backlog — ele opera o backlog do time.** Gestão de backlog é
   trabalho de PM/PO e fica no catálogo, mas acontece por integração, na ferramenta que a
   empresa já paga. O que é nosso é estratégia, documento e contexto do projeto. A aposta
   embutida é que a integração dá conta da heterogeneidade dessas ferramentas — é a premissa
   A14, e ela tem condição de retorno escrita (09, 16, 18, 19).
4. **O alpha precisa medir ciclo, não só qualidade.** Baseline antes de ligar o produto,
   mais de uma ação no fluxo, aceitação como contrapeso. Paralelismo fica na segunda onda —
   é a aposta central da tese e o item mais caro da lista (14, 18, 19).

## Fontes externas consultadas

Acesso em 2026-08-18. Cada documento cita a fonte no ponto em que ela sustenta uma afirmação.

| Fonte | O que sustenta |
|---|---|
| [ChatPRD — Best AI tools for PMs 2026](https://www.chatprd.ai/learn/best-ai-tools-for-product-managers) | mapa de categorias e preço de ferramenta pontual |
| [Telos — AI PM tools compared](https://www.telos-ai.org/blog/ai-product-management-tools-compared) | comparação ChatPRD × Productboard AI × outros |
| [UserJot — Jira Product Discovery pricing 2026](https://userjot.com/blog/jira-product-discovery-pricing) | preço por criador, contribuidor grátis |
| [Featurebase — JPD pricing](https://www.featurebase.app/blog/jira-product-discovery-pricing) | benchmark de preço por assento |
| [The Agent Report — AI agent startup explosion 2026](https://the-agent-report.com/2026/07/ai-agent-startup-explosion-2026-yc-ecosystem/) | capital indo para "agente que substitui uma função", não assistente |
| [AI Funding — agentic startups](https://aifunding.me/ai-agent-funding) | volume de investimento em agentes 2025→2026 |
| [Product Leadership — Will AI replace PMs](https://www.productleadership.com/blog/will-ai-replace-product-managers/) | consenso: IA entrega artefato, não julgamento |
| [CPO Club — PM career stats 2026](https://cpoclub.com/career/statistics-career-product-management/) | ordem de grandeza da população de PMs |
| [Business Research Insights — PM software market](https://www.businessresearchinsights.com/market-reports/product-management-software-market-129242) | tamanho de mercado top-down (divergente entre casas) |
