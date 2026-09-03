# MVP — Straggy Hub

Recorte de execução: **o menor sistema que dá para colocar no ar e usar de verdade, sozinho.**
Sem cliente, sem time, sem venda. Este documento junta o discovery no essencial e declara o
que entra.

Pilha de documentos: intenção em [`PRD.md`](PRD.md) · evidência em
[`discovery/`](discovery/00-INDEX.md) · física em [`ARCHITECTURE.md`](../ARCHITECTURE.md) ·
telas em [`HUB.md`](HUB.md) · catálogo público em [`../system/ACOES.md`](../../system/ACOES.md).
Em conflito, o discovery é a fonte de evidência e a arquitetura é a fonte da física.

> **Estado.** Proposta. As Partes 1 e 4 são resumo fiel do discovery — nada aqui é evidência
> nova. A Parte 2 é decisão de escopo deste MVP, tomada em 2026-08-29, e é a única parte que
> ainda não passou por nenhum documento do discovery.

---

## Parte 1 — O discovery em duas páginas

### O problema

**O ciclo de uma demanda é lento e serial.** Entre "alguém pediu" e "o time pode começar"
existem horas de trabalho manual que só uma pessoa por vez consegue fazer — porque o
contexto e o procedimento moram nela.

Cinco causas, e nenhuma delas é falta de gente `[discovery/02]`:

| Causa | Efeito no ciclo |
|---|---|
| Contexto espalhado por 5+ ferramentas | tempo perdido localizando o que já existe, em toda demanda |
| Procedimento não executável — vive em template e na cabeça | o mesmo trabalho refeito à mão, e diferente por cada pessoa |
| Interface é ferramenta, não pedido | cada passo custa clique, tela e memória de onde fica o quê |
| Nada roda sem alguém iniciar | o assíncrono só acontece quando alguém lembra |
| IA genérica, sem contexto nem procedimento | acelera o rascunho e devolve o retrabalho |

**Falta de padrão não é a causa — é subproduto.** Quando o procedimento não é executável, o
trabalho fica lento *e* sai diferente a cada pessoa. Atacar só a segunda produz mais um
template e não muda o tempo de ciclo.

### A causa raiz

Não existe camada onde o workflow da empresa seja **configurado uma vez e executado
sempre**. Todo mecanismo disponível hoje é documento (depende de disciplina) ou código
(depende de engenharia).

### Para quem

Alvo: qualquer PM/PO. Hipótese de entrada: **time que tem padrão e sofre para replicá-lo** —
recorte por comportamento, não por modelo de negócio `[04]`. Fora: quem não tem padrão e não
quer ter.

Três papéis, com critérios opostos — e esse conflito é o principal risco de adoção:

| Papel | O que quer |
|---|---|
| **P1** líder de produto (compra) | uniformidade sem ter que revisar tudo |
| **P2** PM de execução (usa) | autonomia; abandona se o primeiro artefato precisar de reescrita |
| **P3** mantenedor do padrão (configura) | declarar o jeito da casa uma vez e parar de repeti-lo |

### A tese

**Vender velocidade cujo resultado é aproveitável.** Velocidade sozinha é a alegação mais
comum do mercado e compete de frente com chat genérico. O que separa é a **garantia
estrutural** — portão, contrato de saída e método ficam fora do alcance de quem configura, e
não por regra escrita: por ausência de campo `[ARCHITECTURE §7]`.

Outcome: **tempo de ciclo por demanda ↓** e **demandas concluídas por pessoa ↑**.
Contrapeso obrigatório: **% aceito sem retrabalho não pode cair.** Um número sem o outro
mente — se o ciclo encurta e a aceitação cai, o trabalho só migrou para a revisão `[10]`.

### O pilar que sustenta tudo: contexto único

**Todo o contexto do produto em uma ferramenta só.** É a oportunidade O1 do discovery — e a
**única marcada `[F]`**, com evidência dura: foram necessárias 5 famílias de integração só
para juntar contexto que já existia `[10]`.

Ela ficou fora das primeiras versões por um motivo que o próprio método declarou como limite:
**o ICE penaliza fundação** `[14, anomalias]`. Repositório de contexto, edição nativa e
estruturas de produto como artefato têm impacto alto, confiança boa e facilidade baixa — e o
score os empurrou para o fundo da fila enquanto itens menores subiam.

**Decisão de 2026-08-29: bancar o esforço.** O contexto deixa de ser consequência de ter
integrações e passa a ser **o recipiente**, com repositório de arquivos hospedado, documento
nativo em Markdown e estruturas de produto (roadmap, persona, OKR) vivendo dentro do sistema
como artefato editável — e não como método que só existe durante uma execução.

Duas razões, e a segunda é hipótese declarada:

| | Razão | Grau |
|---|---|---|
| 1 | sem o contexto no lugar, toda ação regride ao genérico — é a diferença entre o produto e um chat com prompt colado | `[F]` — O1 |
| 2 | é o que atrai gente para o sistema: ter roadmap, persona e canvas no mesmo lugar onde o trabalho executa é o gancho de entrada, mais que a execução em si | `[S]` — sem evidência; vira a premissa **A15** e é testada pelo uso |

### A fronteira de escopo

**O produto não é gestor de backlog** e não vai construir um `[00 v4]`. O trabalho que toca
backlog — registrar, refinar, priorizar, sprint — continua sendo trabalho de PM/PO e continua
no catálogo, mas executa **na ferramenta que o time já usa**, por integração e com portão
antes de qualquer escrita. Sem issue, quadro ou sprint próprios.

O que é nosso: **estratégia, documento e contexto do projeto.**

### O que já existe

O motor roda hoje, por linha de comando: 22 ações nomeadas, 86 métodos, esteira de 6
artefatos com portão entre eles, customização por encaixe, 5 famílias de integração `[F]`.
**O risco não é "a IA consegue fazer trabalho de produto?"** — isso está demonstrado. O risco
é a camada de produto em volta: espaço, estado, colaboração, permissão, paralelismo.

### As apostas

Nenhuma testada. É isso que o discovery entrega — a fila, não o plano `[09]`:

| | Aposta | Se for falsa |
|---|---|---|
| **A1** | o problema é caro o bastante para virar orçamento | não há negócio, há projeto interno |
| **A3** | o artefato é aceito sem reescrita, com frequência alta | o portão vira teatro e o produto só somou uma etapa |
| **A2** | a empresa realmente configura o próprio padrão | sem fosso: vira gerador genérico e perde para o que custa US$ 15/mês |
| **A14** | operar o backlog do time por integração é bom o bastante | ou as ações de backlog saem do escopo, ou a construção de backlog próprio volta à mesa |
| **A15** | o repositório de contexto — documentos, canvas e estruturas no mesmo lugar — é o que atrai gente para o sistema | o gancho de entrada é outro, e a construção mais cara do MVP foi feita pela razão errada |

### Como isto morre

Sete cenários no pré-mortem; cinco morrem pelo mesmo motivo — **decisão por otimismo com
sinal disponível e ignorado** `[16]`. Os três mais prováveis:

1. **Morreu construindo.** Dez meses de construção, nenhuma conversa com quem não é a gente.
   Defesa: nada de interface antes de evidência.
2. **O portão virou clique.** Todo mundo aprova sem ler, um requisito errado passa, a
   promessa central vira piada. Defesa: medir tempo entre "pronto" e "aprovado".
3. **A integração não deu conta.** A ação escreve "quase certo" no backlog e consertar custa
   mais que fazer à mão. Defesa: contar quantas vezes a pessoa reabre a ferramenta.

### As quatro decisões que o discovery tomou

1. O produto é para qualquer PM/PO; o beachhead é hipótese, não fato.
2. Vende-se velocidade com resultado aproveitável — não padronização, não velocidade pura.
3. O produto não gere backlog: opera o do time, por integração.
4. O alpha mede **ciclo**, não só qualidade — com baseline antes de ligar.

---

## Parte 2 — O MVP

### O que este MVP é

**Um espaço, hospedado, usado por mim primeiro — mas construído desde o dia 1 para o time
entrar.** O motor já faz o trabalho; o que falta é ele parar de morar no terminal e o
contexto parar de morar em cinco lugares.

Duas metades, e as duas são obrigatórias:

| | |
|---|---|
| **O recipiente** | repositório de contexto do produto na nuvem: documentos em Markdown criados e editados no sistema, arquivos enviados, estruturas de produto (roadmap, persona, OKR) como artefato editável, tudo indexado por metadado e legível por pessoa **e** por agente |
| **A execução** | o motor atual saindo do terminal: conversa como interface, ações executando o procedimento declarado, esteira com portão, escrita externa com preview. Roda na máquina de quem usa, com a chave de IA dele |

**Sem o recipiente, a execução regride ao genérico. Sem a execução, o recipiente é um Drive
com YAML.** É por isso que nenhuma das duas metades pode ser adiada para "depois do MVP".

Não é o alpha de `19` — aquele exige 3 contratos pagos, implantação assistida e amostra de
times. Este vem antes, e serve para outra coisa.

### Hospedado o quê, exatamente — e o que roda na sua máquina

Revisto em 2026-08-29. **A divisão é explícita, e não é a mesma para tudo:**

| | Onde | Por quê |
|---|---|---|
| **Repositório, espaço, artefatos, histórico das sessões** | servidor | é o que precisa ser compartilhado. Documento, decisão e sessão existem para o time, não para uma máquina — e o histórico no servidor é o que permite abrir de outro lugar e mostrar para outra pessoa o que foi feito |
| **Execução do agente** | máquina do usuário, com a **chave de IA dele** | é onde o motor já roda hoje. Executar no servidor exige uma plataforma de sandbox inteira, e a inferência sai da nossa conta |

**Isto é decisão de MVP, e está declarada como tal.** Começa pequeno: eu, depois alguns
colegas de equipe. Não há por que construir infraestrutura de execução para esse tamanho.
Quando o tamanho justificar, a execução gerenciada entra como implementação nova atrás da
mesma interface — não como reescrita. Detalhe em [`MVP-TECNICO.md`](MVP-TECNICO.md), DT-02.

**O que isso resolve de graça:** o custo de inferência sai da nossa conta — o cenário 4 do
pré-mortem (margem invertida) deixa de existir no MVP — e o dado de trabalho não passa pela
nossa infra durante a execução, o que enfraquece muito a objeção de nuvem que o discovery
registra como A5/D3.

**O que isso custa, registrado para não ser descoberto depois:** nada roda sem alguém com a
máquina ligada, então automação agendada fica impossível enquanto a execução for local; o
portão é interceptado no cliente, com a trilha no servidor; e **o pack fica em texto no disco
de quem usa**, contra o requisito de propriedade intelectual do `MODOS.md` §6 — irrelevante
para mim e para o time, decisão obrigatória antes da primeira venda.

**A forma do cliente:** um frontend só, que roda nativo e na web. Nativo hoje, porque precisa
de processo e disco para executar o agente; o mesmo código serve a web no dia em que a
execução hospedada existir.

### Autenticação, mesmo assim

Conteúdo de produto hospedado exige controle de acesso desde a primeira versão. Requisito,
regra de negócio e decisão são dado sensível `[11]`. O MVP entra com login e espaço fechado;
o que fica de fora é papel, permissão fina e trilha de auditoria — não o controle de acesso.

**A chave de IA do usuário nunca sai da máquina dele** — cofre do sistema operacional, nem
cifrada no nosso servidor. É higiene, e é argumento de venda.

Isso também **corrige** a leitura anterior da decisão D2 do discovery ("onde o trabalho
roda"). A resposta não é "infra do produto": é **contexto no servidor, execução no cliente**.

### O escopo cresceu — e o que isso obriga

Este MVP é maior que "colocar no ar e usar sozinho". Repositório hospedado, editor nativo,
sincronização com Drive, estruturas editáveis e camada de conexão são vários produtos
adjacentes, e o pré-mortem tem nome para isso: **cenário 1, morreu construindo** `[16]`.

Nada foi cortado. O que muda é a forma de construir, e são duas regras:

1. **Ondas que terminam em algo usável** (ordem no fim desta parte). Onda que não entrega uso
   não termina — vira construção sem sinal.
2. **A1 não espera o MVP.** A oferta paga com o motor atual continua rodando em paralelo. No
   dia em que a única atividade da semana for construir, o cenário 1 já começou.

### A exceção registrada

O discovery diz: **nenhuma linha de interface antes de 3 contratos** `[11, 16 cenário 1]`.
Este MVP contraria isso de propósito, e a exceção fica escrita para não ser normalizada
depois `[19, "Exceções"]`:

| | |
|---|---|
| **Quem aceitou** | Gustavo, 2026-08-29 |
| **Por que é aceitável** | custo baixo, usuário é o próprio autor, e nenhuma decisão comercial depende dele. É dogfood, não aposta de mercado |
| **O que ele decide** | **A3** (artefato aceito sem reescrita) e **A14** (operar o backlog por integração é bom o bastante) — as duas com n=1, o que é indício, nunca prova |
| **O que ele NÃO decide** | **A1** (vira orçamento), **A2** (a empresa configura), **A4** (P2 adota). Nenhum deles é testável com um usuário que é o dono do produto |
| **Onde a exceção fura** | se o MVP crescer para "quase pronto para vender" antes de qualquer conversa comercial, virou o cenário 1 com outro nome. Regra de corte: **A1 continua sendo testado por oferta paga com o motor atual, em paralelo, e não espera o MVP ficar bonito** |

### Lista de funcionalidades

**Origem** — `existe`: capacidade do motor, o trabalho é dar interface · `construir`: não
existe hoje.

#### A — o recipiente

| # | Funcionalidade | Por que entra | Origem |
|---|---|---|---|
| M01 | **Espaço hospedado, com login** — um espaço, várias pessoas, sem papel nem permissão fina | é o recipiente do contexto e do estado. Hospedado porque contexto é do espaço, não da pessoa; com login porque o conteúdo é sensível | construir |
| M02 | **Dados do projeto e encaixes preenchíveis** — no mínimo `procedimento` e `estrutura do documento` | é o que faz a saída ser minha e não genérica; a tese inteira depende disto | existe (arquivo) · construir (tela) |
| M03 | **Histórico do espaço** — o que foi decidido, executado e aprovado fica registrado e legível para pessoa e agente | é a oportunidade com evidência mais forte (O1): tempo perdido procurando o que já existe | parcial |
| M26 | **Escolher o fornecedor de IA e usar a própria chave** — guardada no cofre do sistema operacional, nunca no nosso servidor | tira o custo de inferência da nossa conta e o dado da nossa infra durante a execução. Sem chave, o produto funciona como repositório e só a execução fica indisponível, com aviso | construir |
| M27 | **Histórico das sessões no servidor** — abrir de outra máquina, mostrar para outra pessoa o que foi feito | a execução é local e efêmera; o registro do que aconteceu é do espaço. Sem isso, trabalho executado some com a máquina | construir |

#### B — a interface

| # | Funcionalidade | Por que entra | Origem |
|---|---|---|---|
| M04 | **Conversa como interface, em texto** — descrevo a demanda, o sistema reconhece a ação | sem isso não há produto, só configuração com outro nome | construir |
| M05 | **Catálogo reduzido de ações** — as do fluxo de uma demanda, não as 22 | mais de uma ação no fluxo é o que permite medir **ciclo** e não uma etapa isolada | existe |

#### C — a garantia

| # | Funcionalidade | Por que entra | Origem |
|---|---|---|---|
| M06 | **Esteira de artefatos com estado visível** por demanda | é o que transforma portão em coisa, não em frase no meio da conversa | construir |
| M07 | **Portão como estado**: aprovar · pedir ajuste. O passo seguinte **não existe** até aprovar | é a promessa central. Sem ele o MVP não prova nada que um chat genérico não prove | construir |
| M08 | **Preview antes de toda escrita externa**, sem exceção | uma escrita indevida num backlog real é o tipo de erro que não tem desfazer | existe (write-gate) · construir (tela) |

#### D — o trabalho

| # | Funcionalidade | Por que entra | Origem |
|---|---|---|---|
| M09 | **Discovery guiado da demanda** — exploração em fases, um registro por fase | é a primeira ação do fluxo; sem ela o documento nasce sem lastro | existe |
| M10 | **Documentar requisito** no procedimento e na estrutura declarados | é o trabalho pelo qual alguém pagaria; é o núcleo | existe |
| M11 | **Ramo de design** — brief da tela, construção do protótipo navegável, prints alimentando a documentação | demanda com interface documenta **depois** do protótipo validado; sem este ramo o ciclo medido não representa o trabalho real | existe |
| M12 | **Entregável final no destino** — documento formal, wiki ou o próprio backlog | trabalho que não aterrissa onde eu consumo não foi entregue | existe |

#### E — o backlog, na ferramenta que já uso

| # | Funcionalidade | Por que entra | Origem |
|---|---|---|---|
| M13 | **Integração GitHub ou GitLab**: ler demanda e comentários, criar, atualizar, comentar — com preview | é por onde a demanda entra e o trabalho aterrissa. São as duas implementações que existem hoje | existe |
| M14 | **Priorizar pelo funil declarado** — o funil como composição, não como código | priorização é rotina de PO e fica no escopo; o que não existe é backlog nosso | existe |

#### F — o repositório de contexto

**É a metade nova do MVP, e a mais cara.** Sem ela, tudo acima executa sobre contexto que
mora fora do sistema.

| # | Funcionalidade | Por que entra | Origem |
|---|---|---|---|
| M15 | **Repositório de arquivos do produto, hospedado** — a seção de documentos do espaço, com pastas, aberta a quem tem acesso ao espaço | é o "tudo em um lugar só" da tese. Local, ele reproduz o problema que o discovery descreve | construir |
| M16 | **Documento nativo em Markdown: criar e editar dentro do sistema** — `.md` e só `.md` | formato simples, versionável, diffável e o que a IA lê melhor. Adotar formato binário aqui é comprar dor de conversão para sempre | construir |
| M17 | **Frontmatter YAML obrigatório em todo documento** — `tipo`, `titulo`, `demanda`, `status`, `tags`, `atualizado_em`, `origem` | é o que separa um Drive de um repositório de contexto: o agente não varre tudo, ele **filtra** e lê o que importa. É a peça que faz o resto funcionar | construir |
| M18 | **Busca e filtro por metadado** — por tipo, demanda, status, tag; e é assim que a ação monta o contexto antes de executar | frontmatter sem consulta é enfeite. É esta funcionalidade que devolve o tempo de O1 | construir |
| M19 | **Upload e exclusão de arquivos** — qualquer tipo (PDF, imagem, planilha), como anexo de contexto | nem todo contexto nasce em Markdown; ata, print e contrato chegam prontos | construir |
| M20 | **Sincronização com Google Drive por link** — o que muda no Drive volta para o sistema, como documento **somente leitura** | é onde metade do contexto de time de produto já vive; exigir migração antes de ter valor mata a adoção | construir |

**Documento × arquivo — a distinção que evita duas fontes de verdade:**

| | O que é | Quem escreve |
|---|---|---|
| **Documento** | `.md` com frontmatter, nativo do sistema | eu, ou uma ação com portão |
| **Arquivo** | qualquer formato, enviado ou vindo do Drive | ninguém, dentro do sistema — é contexto, não artefato |

O material vindo do Drive entra **somente leitura**, sempre. Editar dos dois lados é o risco
"duas fontes de verdade" do PRD `[§10]`, e a regra que o evita é esta: **quem é dono lá fora,
continua dono lá fora.**

#### G — estruturas de produto como artefato editável

| # | Funcionalidade | Por que entra | Origem |
|---|---|---|---|
| M21 | **Um conjunto essencial de estruturas do produto vivendo como documento editável** — roadmap, personas, OKR, lean canvas, story map. Cada tipo com **forma declarada** (seções e campos fixos), não tela em branco | é a aposta A15: o gancho de entrada. E resolve a lacuna achada no discovery — 86 estruturas existem como método, **zero** como artefato do espaço `[13]` | parcial — a estrutura existe, falta ação e artefato |
| M22 | **Cada estrutura é contexto para a IA como qualquer outro documento** — mesmo repositório, mesmo frontmatter, mesma busca | o valor não é ter um roadmap bonito; é a ação de documentar requisito **saber** o que está no roadmap | consequência de M17/M18 |

**O que M21 não é:** whiteboard livre com post-it e colaboração simultânea no mesmo canvas.
Isso é ferramenta de outra categoria e continua fora `[13, F33]`. Aqui, cada estrutura tem
forma — é o mesmo princípio do contrato de saída: quem preenche escolhe o conteúdo, nunca a
forma.

**Regra de corte para o MVP:** um tipo essencial por necessidade, não o catálogo inteiro. As
86 estruturas do repertório entram por demanda, depois — a arquitetura já suporta declarar
mais sem tocar no núcleo.

#### H — a camada de conexão

| # | Funcionalidade | Por que entra | Origem |
|---|---|---|---|
| M23 | **Superfície de conexão de integrações no produto** — conectar, autenticar, ver o que aquela ferramenta suporta, e degradar com aviso explícito quando não suporta | é a contrapartida direta de não ter backlog próprio: se a conexão é frágil, a pivotagem de escopo não se sustenta (A14) | existe (interface de provider) · construir (tela) |
| M24 | **Trabalho no harness para viabilizar isso** — generalizar o que ainda está preso ao fluxo de origem e fechar o que falta nas operações de provider | o harness não está pronto; tratar isso como "manutenção" e não como item do MVP é o jeito clássico de ele nunca acontecer | construir |

**Por que M23 entra mesmo eu usando só GitHub/GitLab:** a decisão de não construir backlog
próprio transfere o peso todo para a integração. A camada precisa ser **pensada e extensível
agora**; cada implementação nova (Jira, Linear, Azure Boards) continua entrando por demanda
real, nunca por especulação `[11]`.

#### I — a medição

| # | Funcionalidade | Por que entra | Origem |
|---|---|---|---|
| M25 | **Registro por demanda**: tempo de ciclo · aceito sem reescrita · reescrita de formato × de conteúdo · **quantas vezes reabri a ferramenta de backlog na mão** | a promessa é velocidade. Sem baseline e sem contrapeso, o MVP não ensina nada — só parece bom | construir (planilha basta) |

### Fora do MVP

| Fora | Por quê | Volta quando |
|---|---|---|
| Papéis, permissões finas, trilha de auditoria | o espaço é fechado e o time é pequeno; login e espaço único bastam | time acima de ~10 pessoas, ou exigência de auditoria |
| Execução hospedada na nossa infra | roda na máquina de quem usa; a camada de capacidade já reserva o lugar da versão hospedada | automação agendada virar necessidade, ou alguém recusar instalar o aplicativo |
| Vários fornecedores de IA | um só, bem feito, com a interface preparada para mais | alguém do time usar outro de fato |
| Projetos dentro de espaços | hierarquia sem dor com um projeto | mais de um produto no mesmo espaço |
| Conversas em paralelo | é a aposta central da tese de velocidade e o item mais caro da lista | M15 mostrar que a espera entre demandas é a maior fatia do ciclo |
| Voz | nenhuma situação de uso identificada | situação concreta e recorrente |
| Automações agendadas | mecanismo de velocidade sem problema associado hoje | M15 mostrar ociosidade ou trabalho recorrente |
| **Backlog, quadro, issue e sprint próprios** | **fora por escopo, não por prioridade** | A14 refutada — e aí é decisão nova, com dado |
| Providers Jira, Linear, Azure Boards | não uso nenhum deles | mudar de ferramenta, ou um contrato depender |
| Métricas e gráficos de delivery | são da ferramenta que guarda o backlog | nunca, nesta forma |
| Espaço acessível por fora (MCP/API) | plataforma antes de produto | base instalada existir |
| Edição simultânea, cursor ao vivo, comentário em documento | o repositório resolve "onde está"; edição colaborativa em tempo real é outro produto | mais de uma pessoa editando o mesmo documento no mesmo dia, de fato |
| Quadro branco livre, post-it, canvas de forma aberta (F33) | outra categoria de ferramenta, e não é o que a tese pede — o pedido é pelas **estruturas**, não pelo formato visual | não previsto |
| Versionamento e histórico de mudança por documento | Git resolve isso hoje; dentro do produto é construção própria | o documento passar a ser editado por mais de uma pessoa |
| Escrita de volta no Drive | é a regra que evita duas fontes de verdade | nunca, nesta forma |
| Catálogo completo das 86 estruturas como artefato | o MVP leva o conjunto essencial; declarar mais não toca o núcleo | por demanda de uso |

### Ordem de construção — três ondas, cada uma termina em algo usável

Não é faseamento para cortar escopo: o escopo é o de cima, inteiro. É a defesa contra o
cenário 1 — cada onda tem que produzir uso real antes da seguinte começar.

| Onda | O que entra | Termina quando |
|---|---|---|
| **1 — o recipiente** | M01 espaço hospedado com login · M15 repositório · M16 documento nativo `.md` · M17 frontmatter · M18 busca por metadado · M19 upload | **já é útil sem nenhuma IA**: todo o contexto do produto num lugar só, achável. Se esta onda não for usada sozinha por duas semanas, o problema não era esse |
| **2 — a execução** | M02 encaixes · M04 conversa · M05 catálogo reduzido · M06 esteira · M07 portão · M08 preview · M09–M12 as ações · M13 integração de backlog · M25 medição · M26 chave do usuário · M27 histórico de sessão | **o motor saiu do terminal**: uma demanda entra e sai documentada e publicada, com o contexto da onda 1 alimentando a execução |
| **3 — o que atrai e o que conecta** | M21 estruturas editáveis · M22 estruturas como contexto · M14 priorização pelo funil · M20 sync com Drive · M23 camada de conexão · M03 histórico completo | **o espaço vira o lugar onde o produto inteiro mora** — roadmap, persona e OKR no mesmo índice que alimenta a execução |

A tradução disto para épicos e issues — no formato do Linear — está em
[`MVP-BACKLOG.md`](MVP-BACKLOG.md), e as decisões técnicas que precisam vir antes, com os
eixos de construção, em [`MVP-TECNICO.md`](MVP-TECNICO.md). Os dois consolidados por
release: [`MVP-RELEASES.md`](MVP-RELEASES.md).

**M24 (trabalho no harness) atravessa as três.** Não é onda: é a linha de base que precisa
acompanhar cada uma — o harness não está pronto, e tratar isso como conserto avulso é como
ele deixa de acontecer.

---

## Parte 3 — Como funciona, na prática

### Dia 0 — ligar

Entro no espaço — que está no servidor, não na minha máquina, e pede login. Ele já funciona
com o padrão de fábrica: as ações estão lá, os métodos estão lá, o contrato de saída está lá.
**Nada é obrigatório preencher para começar.**

Conecto uma integração de backlog — o GitHub ou o GitLab do projeto — e preencho os dados do
projeto. Depois, o que muda o resultado: abro a ação `documentar requisito` e preencho dois
encaixes, o **procedimento** (como eu faço este trabalho) e a **estrutura do documento** (o
que ele precisa conter). Campo vazio cai no padrão do sistema; campo preenchido passa a valer
para toda execução daquela ação.

Nada disso me deixa piorar o produto. Portão, formato de entrega e método não têm campo.

### Dia 0, segunda metade — encher o repositório

O espaço tem uma **seção de documentos**, e é ela que faz o resto valer a pena. Jogo lá tudo
que hoje está espalhado: as regras de negócio, as decisões antigas, o que foi combinado com
quem. Três caminhos:

- **Escrevo direto no sistema.** Documento novo, Markdown, editado ali mesmo. Sem exportar,
  sem abrir editor externo.
- **Subo o que já existe pronto.** Ata em PDF, print, planilha — entra como arquivo de
  contexto, do jeito que está.
- **Colo um link do Drive.** O que o time já mantém lá continua lá e aparece aqui, em
  Markdown, **somente leitura**. Editou no Drive, chegou aqui. O contrário não acontece — de
  propósito: dois donos do mesmo texto é como o conteúdo começa a divergir em silêncio.

**Todo documento nasce com um cabeçalho YAML.** Tipo, título, demanda a que pertence,
status, tags, data. Não é burocracia: é o que transforma a pasta num índice.

```yaml
---
tipo: regra-de-negocio
titulo: Política de cancelamento
demanda: "#276"
status: vigente
tags: [pagamento, cancelamento]
atualizado_em: 2026-08-29
origem: nativo
---
```

E é o que muda o comportamento do sistema: quando eu peço um trabalho, a ação **não varre o
repositório inteiro** — ela filtra por tipo, demanda e tag, e lê o que interessa. É a
diferença entre ter os arquivos guardados e ter contexto utilizável.

### As estruturas do produto moram aqui também

Roadmap, personas, OKR, lean canvas, story map: cada um é um documento do repositório, com
**forma própria** — seções e campos que aquele tipo exige. Preencho o conteúdo; a forma é do
sistema, como qualquer outro contrato de saída.

O ganho não é ter um roadmap bonito numa tela. É que, quando eu peço para documentar um
requisito, a ação **sabe o que está no roadmap** — porque é o mesmo repositório, o mesmo
frontmatter e a mesma busca. Contexto de estratégia e trabalho de execução param de viver em
ferramentas diferentes.

### O dia a dia — uma demanda de ponta a ponta

**Chega a demanda.** Colo o texto na conversa, ou aponto para o item do backlog. Não escolho
ação em menu nenhum: descrevo o que preciso e o sistema reconhece o trabalho pelo que foi
dito.

**Exploração.** O sistema conduz o discovery da demanda em fases e registra cada uma. Isso
vira artefato no espaço — não texto que some quando eu fecho a aba.

**Se a demanda tem tela**, a esteira não me deixa pular: o brief da tela sai primeiro, depois
o protótipo navegável, e só depois que eu valido é que a documentação pode existir. Os prints
do protótipo entram no documento sozinhos.

**A documentação.** A ação executa no meu procedimento, na minha estrutura, com o contexto do
projeto na mão — os documentos que o filtro trouxe do repositório, o roadmap e as personas
que moram lá, o que a integração leu do backlog, o que ficou decidido nas fases anteriores.
**É aqui que a onda 1 se paga:** a mesma ação, com e sem repositório cheio, não produz a
mesma coisa.

**O portão.** O artefato aparece com estado `aguardando revisão`. Eu leio. Aprovo, ou peço
ajuste em linguagem natural e ele regera. **Enquanto eu não aprovo, o entregável final não
existe** — não é "o sistema deveria esperar", é que o estado anterior não está lá.

**A publicação.** Aprovado, gero o entregável e mando para o destino: documento formal, wiki,
ou de volta para o item do backlog. Antes de escrever qualquer coisa fora do rascunho, o
sistema **mostra exatamente o que vai fazer e onde**, e espera clique. Toda vez. Aprovar um
passo não aprova o próximo.

**O registro.** Fecho a demanda anotando quatro números: quanto tempo levou de ponta a ponta,
se aceitei o artefato sem reescrever, se a reescrita foi de forma ou de conteúdo, e quantas
vezes precisei abrir o GitHub na mão para consertar algo que o sistema escreveu.

### Quando eu erro a configuração

O pior encaixe possível ainda para no portão e ainda entrega no formato declarado. O que
piora é o conteúdo, não a garantia — e isso aparece na revisão, que é exatamente onde deve
aparecer.

### O que fica

Cada demanda deixa no espaço: os registros das fases, o documento, o protótipo, a trilha do
que foi aprovado e quando — tudo no repositório, com frontmatter, achável por filtro. Na
demanda seguinte, isso é contexto — não arqueologia em cinco ferramentas.

**E quando o time entrar**, não há migração: o contexto já está no servidor, já é do espaço e
já é legível por quem chegar. Foi para isso que ele nasceu hospedado.

---

## Parte 4 — Como eu sei que funcionou

Com um usuário, nada aqui é prova. É **indício, e indício com viés total de origem** — quem
usa é quem construiu. Escrito antes de começar, para não ser racionalizado depois:

| Sinal | O que significa |
|---|---|
| **Baseline de ciclo medido antes de ligar o MVP** | sem ele, qualquer ganho é impressão. É a primeira coisa a fazer, não a última |
| Ciclo por demanda cai e a aceitação **não** cai | a tese sobrevive ao primeiro contato com a realidade |
| Ciclo cai e a aceitação cai junto | não houve velocidade: o trabalho migrou para a revisão. Corrigir o procedimento declarado antes de seguir |
| Reescrita concentrada em **conteúdo**, não em formato | a oportunidade não é a que o discovery escolheu (O1) — voltar a `10` antes de construir mais |
| Reabro o backlog na mão em mais de 30% das demandas | **A14 em risco** — a integração não cobre o uso real. Parar, medir onde falha, e reabrir a decisão de escopo com dado. Construir kanban por reflexo, antes disso, é o cenário 1 |
| Eu mesmo paro de usar em 30 dias | o sinal mais forte que existe aqui. Se nem o autor usa, nenhuma feature conserta |

**Sinais próprios do repositório de contexto** — a metade nova, e a que custa mais caro:

| Sinal | O que significa |
|---|---|
| **Onda 1 usada sozinha por duas semanas**, antes de qualquer execução | o repositório tem valor por si. Se eu não abro a seção de documentos sem precisar executar nada, a tese do contexto único está errada e a onda 2 vira o produto inteiro |
| Documentos do produto que **ainda** vivem fora do sistema, depois de 30 dias | mede se o "tudo num lugar só" aconteceu ou se virou mais um lugar. Repositório pela metade é pior que nenhum: some a confiança de que o contexto está lá |
| A ação achou o contexto certo **sozinha**, sem eu apontar arquivo | é o teste direto do frontmatter e da busca (M17/M18). Se eu preciso dizer onde olhar toda vez, o índice não serve |
| Documento gerado com o repositório cheio × com ele vazio | se a diferença for pequena, o contexto não era o gargalo e O1 foi mal lida |
| Eu abro uma estrutura (roadmap, persona) para **consultar**, não só para preencher | é o único sinal honesto de A15 com n=1. Preencher uma vez todo mundo preenche; voltar nela é o que indica valor |
| Conteúdo do Drive divergindo do que está aqui | a sincronização quebrou em silêncio — é o modo de falha do M20, e ele não avisa sozinho |

**O que continua em aberto depois deste MVP, aconteça o que acontecer:** A1 (vira
orçamento), A2 (a empresa configura), A4 (o PM de execução adota) e **A15 de verdade** (o
repositório atrai gente). Os quatro só se respondem com gente de fora — oferta paga e
entrevistas `[03, 07, 09]`, que rodam com o motor atual e **não esperam este MVP**.

A15 merece um aviso próprio: **é a premissa que mais influenciou o tamanho deste MVP e a que
tem menos evidência.** Ela justificou promover o ramo mais caro do discovery. Com um usuário
que é o autor, ela não se confirma nem se refuta — o máximo que este MVP produz é indício de
uso. Tratá-la como validada depois de gostar do resultado é o erro que o pré-mortem descreve
em cinco dos oito cenários: decidir por otimismo com sinal disponível e ignorado.
