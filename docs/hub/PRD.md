# PRD — Straggy Hub

Documento de produto do Hub: o que ele é, para quem, o que já existe, o que falta e o que
está em aberto. **Sem decisão técnica.** Camadas e precedência:
[`ARCHITECTURE.md`](../ARCHITECTURE.md). Quem manipula o quê em cada modo:
[`MODOS.md`](../MODOS.md). Forma das telas: [`HUB.md`](HUB.md). Catálogo público de ações:
[`../system/ACOES.md`](../../system/ACOES.md).

> **Estado.** O motor descrito em §3 **existe e roda hoje** (modo repositório). Todo o resto
> é produto: §8.2 é desenho registrado em `HUB.md`, §8.1 é capacidade já entregue por outro
> meio, e **§8.3 não tem nada por baixo**. Nenhuma feature do Hub está implementada.

Este é o documento mais alto da pilha: dá a **intenção** do produto. `HUB.md` dá a forma das
telas, `MODOS.md` o contrato entre os modos, `ARCHITECTURE.md` a física. Em conflito, o
documento mais baixo vence — arquitetura não se dobra a PRD.

A evidência por trás das escolhas deste documento — problema, segmento, priorização, riscos
e o corte do alpha — está em [`discovery/`](discovery/00-INDEX.md). Onde os dois divergirem,
**o discovery é a fonte**: ele carrega o grau de evidência de cada afirmação.

O recorte de execução — a primeira versão usável, para uso próprio, com a lista do que entra
e a narrativa de como funciona — está em [`MVP.md`](MVP.md); a tradução dele para épicos e
issues, em [`MVP-BACKLOG.md`](MVP-BACKLOG.md); as decisões técnicas e os eixos de construção,
em [`MVP-TECNICO.md`](MVP-TECNICO.md); e tudo isso consolidado numa fila por release, em
[`MVP-RELEASES.md`](MVP-RELEASES.md).

---

## 1. O que é

**Straggy Hub é uma ferramenta AI Native que faz o trabalho de um Product Owner / Product
Manager** — de ponta a ponta, no padrão da empresa que a usa.

Três características a definem:

- **Faz, não assiste.** Não é um editor com IA acoplada. A conversa é a interface: o
  trabalho de produto é executado a partir dela, por voz ou por texto — várias demandas ao
  mesmo tempo.
- **Colaborativa e única.** Discovery, design, delivery, documentação e métricas em uma
  ferramenta só. Todo o contexto do produto disponível para qualquer pessoa e para qualquer
  agente de IA.
- **Não é gestor de backlog.** O Hub faz estratégia de produto, documento e contexto do
  projeto. O trabalho que toca backlog — registrar, refinar, priorizar, sprint — continua no
  catálogo, mas é executado **na ferramenta que o time já usa**, por integração. Não existe
  issue, quadro nem sprint dentro do produto: essa categoria já é bem servida, e o time-alvo
  já paga por ela. Decisão de escopo de 2026-08-29, com a aposta e a condição de retorno
  declaradas em [`discovery/09`](discovery/09-assumption-mapping.md) (A14).
- **Configurável sem poder piorar.** A empresa configura **como trabalha** e o sistema passa
  a executar assim — é daí que vem a velocidade, e o padrão uniforme vem junto, de graça. O
  que garante a qualidade (portão, contrato de entrega, método) ela não alcança.

---

## 2. O problema

**O ciclo de uma demanda é lento e serial.** Entre "alguém pediu" e "o time pode começar"
existem horas de trabalho manual que só uma pessoa por vez consegue fazer — porque o
contexto e o procedimento moram nela.

| Sintoma | Custo |
|---|---|
| Contexto fragmentado entre backlog, drive, wiki, protótipo e chat | tempo perdido localizando o que já existe, em toda demanda |
| Procedimento vive em template e na cabeça, não em execução | o mesmo trabalho manual refeito sempre — e diferente por cada pessoa |
| Cada passo é operar ferramenta, não pedir trabalho | cliques, telas e memória de onde fica o quê |
| Nada roda sem alguém iniciar | trabalho assíncrono só acontece quando alguém lembra |
| IA avulsa, sem contexto nem procedimento | acelera o rascunho e devolve o retrabalho |

Duas consequências que costumam ser confundidas com o problema: **capacidade presa ao número
de pessoas** e **falta de padrão**. As duas são efeito de o workflow não ser executável —
tratar a segunda como causa produz mais um template, e não muda o tempo de ciclo.

Detalhamento e evidência: [`discovery/02`](discovery/02-arvore-de-problemas.md).

---

## 3. Onde estamos hoje

**O Hub não começa do zero.** O motor que faz o trabalho já existe e roda — hoje via linha
de comando, dentro do projeto, com PM, designer e tech lead usando de verdade.

O que já está de pé:

| | Hoje |
|---|---|
| Profissões | 3 — especialista de produto, tech lead, product designer |
| Repertório | 86 métodos de produto, design e técnica, carregados conforme a situação |
| Ações | 22 trabalhos nomeados que o sistema sabe fazer (19 de trabalho + 3 personas) |
| Esteira | 6 artefatos encadeados, com portão humano entre eles |
| Customização | camada da empresa por encaixes, sem tocar no núcleo |
| Integrações | 5 famílias — backlog, base de conhecimento, banco, documento final, canvas |
| Portões | aprovação obrigatória antes de qualquer escrita externa |

**O Hub é a mudança do modo de entrega, não um produto novo por baixo.** A mesma execução,
sem terminal, colaborativa, com estado compartilhado e com a customização virando tela.

| Dimensão | Modo repositório (hoje) | Straggy Hub |
|---|---|---|
| Quem usa | quem tem terminal e IDE | qualquer pessoa de produto |
| Onde o contexto vive | no computador de quem rodou | no espaço, para todo mundo |
| Portão humano | uma parada na conversa; depende do agente obedecer | estado do artefato: o passo seguinte não existe até aprovar |
| Customização | arquivos e caminhos | formulário por ação |
| Colaboração | um por vez | espaço compartilhado, várias demandas em paralelo |

Consequência para o roadmap: **o risco não está em "a IA consegue fazer trabalho de
produto?"** — isso já está demonstrado. O risco está na camada de produto em volta: espaço,
colaboração, estado, permissão, paralelismo.

---

## 4. Para quem

| Persona | O que busca no Hub | Sinal de sucesso |
|---|---|---|
| **Product Manager / Owner** | tirar da frente o trabalho repetível de documentação, priorização e acompanhamento, e tocar várias demandas ao mesmo tempo | fecha o dia com mais demandas avançadas, não com mais documentos escritos à mão |
| **Product Designer** | ir de ideia a protótipo navegável sem depender de fila de dev | protótipo publicado e validado dentro do próprio fluxo da demanda |
| **Tech Lead** | requisito claro, contexto completo, e o que os dados dizem de verdade antes de decidir | menos idas e voltas antes de começar a implementar |
| **Head / Diretoria** | padrão de qualidade garantido em todo o time e visão de entrega em tempo real | não precisa revisar formato, revisa conteúdo |
| **Administrador da organização** | fazer o Hub trabalhar do jeito da empresa, uma vez, para todos | configura por resultado, não por arquivo |

Os dois últimos são superfícies diferentes: **quem trabalha** vê conversa e artefatos; **quem
administra** vê o catálogo de ações e os campos de configuração. Nenhum dos dois vê a
mecânica interna.

---

## 5. Princípios do produto

1. **Útil sem configuração, melhor com ela.** O padrão do sistema já é bom. Configuração
   amplia, nunca destrava o básico. Campo vazio cai no padrão.
2. **O piso de qualidade é estrutura, não regra escrita.** Portão, formato de entrega e
   método são do sistema e ficam fora do alcance de quem configura. A pior configuração
   possível ainda para no portão e ainda entrega no formato certo.
3. **Nada sai sem aprovação humana.** Toda escrita fora do rascunho mostra o que vai fazer
   e espera clique. Aprovação de um passo não vale para o próximo.
4. **Contexto é do espaço, não da pessoa.** O que foi decidido, escrito e medido fica
   disponível para quem chegar depois — pessoa ou agente.
5. **A empresa configura o quê e o como; nunca o piso.** Procedimento, formato, vocabulário
   e critérios são dela. Portão, contrato de entrega e método, não.
6. **Trabalho paralelo é o normal.** A unidade de trabalho é a demanda, não a sessão.

---

## 6. O modelo do produto

O Hub tem um vocabulário só, e é ele que aparece na interface.

| Objeto | O que é | Quem define |
|---|---|---|
| **Ação** | um trabalho nomeado que o Hub sabe fazer: *documentar requisito*, *explorar solução*, *priorizar backlog*, *criar tela*. Ação que toca backlog executa na ferramenta conectada do time | sistema |
| **Encaixe** | um campo da ação que a empresa preenche para ela sair do jeito dela: como fazer, estrutura do documento, regras de classificação, funil | sistema declara quais existem; empresa preenche |
| **Artefato** | o que a ação entrega, com estado visível e trilha de aprovação | sistema |

Fora do alcance de quem configura: **portão humano, o que o artefato precisa conter, onde
ele é gravado, quando o sistema para, e os métodos.** Não é regra escrita pedindo boa fé —
é ausência de campo.

Três consequências de produto:

- **Configurar não é projeto.** A empresa preenche campos por resultado, nunca edita o
  sistema.
- **Configurar mal não quebra.** O piso continua de pé.
- **O produto pode evoluir por baixo.** Mudar como uma ação é feita internamente não quebra
  a configuração de ninguém — a ação é o contrato, o resto é implementação.

**A esteira.** Cada ação declara o que entrega e o que exige antes. É isso que transforma
portão em estado:

```
Demanda #276
├── Discovery         aprovado
├── Protótipo         validado
├── Documento         aguardando revisão   [Ver] [Aprovar] [Pedir ajuste]
└── Entregável        bloqueado — o documento ainda não foi aprovado
```

O entregável não é "a IA não deveria gerar ainda". É **impossível**: o estado anterior não
existe. Demanda sem interface pula o protótipo — a esteira se ajusta à natureza da demanda.

---

## 7. A jornada

**Entrada da organização — uma vez.** Cria o espaço e já sai usável, com o padrão do
sistema valendo. Conecta as integrações que a empresa já usa e preenche os dados do
projeto. Opcional: ajusta os encaixes das ações que importam e monta o funil de
priorização a partir de um preset.

**O dia a dia.** A pessoa fala com o Straggy AI, por voz ou texto. Descreve a demanda; o
sistema reconhece a ação pelo que foi dito e executa: documenta, prioriza, gera o
protótipo, registra a demanda **no backlog do time** — por integração, com preview antes de
escrever. Cada entrega vira artefato com estado. A pessoa revisa e aprova — e só então o
próximo passo existe.

**Em paralelo.** Enquanto uma demanda espera revisão, outras correm em conversas
simultâneas na mesma tela. Automações agendadas cuidam do assíncrono.

**Para o time.** Todo mundo no espaço vê os mesmos documentos, o mesmo contexto e o mesmo
estado de cada demanda — e edita direto no sistema, humano ou IA. O quadro continua sendo o
da ferramenta de backlog do time.

---

## 8. Funcionalidades, por maturidade

O que separa este PRD de uma lista de desejos: **três blocos com origem diferente.** O
esforço de cada um é de outra ordem de grandeza.

### 8.1 Existe e funciona — herdado do motor

Chega ao Hub como capacidade, não como construção. O trabalho é dar interface.

| Capacidade | O que faz hoje |
|---|---|
| **Documentação padronizada** | documento consolidado da demanda no formato da empresa, com revisão obrigatória antes do entregável |
| **Discovery guiado** | conduz a exploração da demanda em fases, um registro por fase |
| **Priorização** | ranqueia o backlog pelo funil declarado pela empresa; presets de mercado como composição, não como código |
| **Operação de backlog** | registra, refina, consulta, analisa saúde e métricas **do backlog conectado do time** — por integração, nunca num backlog próprio |
| **Sprint** | cria, fecha, move, documenta e escreve a meta orientada a resultado, na ferramenta conectada |
| **Design e protótipo** | brief da tela, construção da tela, tokens do design system, prints e publicação do protótipo |
| **Consulta a dados** | o que os dados dizem de verdade antes da decisão |
| **Comunicação** | changelog e páginas de wiki no padrão da empresa |
| **Personalização por ação** | procedimento, formato, template, vocabulário, critérios e funil |
| **Repertório de estruturas** | 86 estruturas de produto, design e técnica com contrato de saída declarado — hoje usadas durante a execução; virar **artefato editável do espaço** é o que a primeira versão acrescenta ([`MVP.md`](MVP.md), grupo G). Um recorte já executado dessa lacuna: [`DISCOVERY-DE-PRODUTO.md`](DISCOVERY-DE-PRODUTO.md) |
| **Integrações** | backlog, base de conhecimento, banco, documento final, canvas. Backlog implementado hoje: GitHub e GitLab; Jira, Linear e Azure Boards são construção por contrato |

### 8.2 Desenhado, falta construir — é o Hub

Existe como decisão de desenho, nada implementado. É o núcleo da primeira versão.

| Feature | O que muda |
|---|---|
| **Espaços** | a unidade de organização: contexto, padrão e permissões deixam de ser locais |
| **Portão como estado** | aprovação vira trilha registrada, não frase no meio da conversa |
| **Aprovação com preview** | toda escrita externa mostra exatamente o que vai fazer e espera clique |
| **Catálogo de ações na tela** | o administrador vê os trabalhos por resultado e preenche os encaixes |
| **Construtor de funil** | monta o funil com presets, pré-visualização de impacto e versão |
| **Conversa como interface** | fala, o sistema resolve a ação; contexto de tela soma à intenção |
| **Esteira de artefatos visível** | o estado de cada demanda, para todo mundo |
| **Generalização do harness** | tirar do caminho o vocabulário e os campos do fluxo de origem (cliente, ordem de serviço, HU/HT, `.docx` como destino) — o produto é para qualquer PM/PO, não para um tipo de operação |

### 8.3 Não existe nem no desenho — produto novo

Está nas anotações e não tem nada por baixo. **É aqui que mora o grosso do esforço** e é o
que precisa ser cortado ou faseado primeiro.

| Feature | Observação |
|---|---|
| **Projetos dentro de espaços** | hoje existe "um projeto"; a hierarquia é nova |
| **Perfis e permissões** | não existe conceito de usuário no motor |
| **Voz** | interface nova |
| **Paralelismo real (canvas de conversas)** | o motor executa um pedido por vez, por desenho |
| **Tarefas pessoais e compartilhadas** | conceito inexistente |
| ~~**Workshops e canvas** (roadmap, personas, OKR)~~ | **movido para a primeira versão em 2026-08-29** — não como canvas livre: cada estrutura com forma declarada. Ver [`MVP.md`](MVP.md), grupo G |
| **Métricas e metas de produto** | hoje só análise de backlog sob demanda; métrica de entrega é da ferramenta que guarda o backlog |
| **Automações agendadas** | nada roda sem alguém pedir |
| **Editor colaborativo em tempo real** | criar e editar documento no sistema **entra** na primeira versão (só Markdown); o que continua fora é edição simultânea, cursor ao vivo e comentário |
| ~~**Repositório de arquivos**~~ | **movido para a primeira versão em 2026-08-29**: hospedado, com documento nativo em Markdown, frontmatter obrigatório, busca por metadado e sincronização somente leitura com Drive. É o recipiente do contexto único |
| **Espaço acessível por fora** | catálogo e execução expostos para outras ferramentas e agentes |

---

## 9. Fora de escopo

- **Papéis fora de produto.** As profissões cobrem produto, técnica-de-produto e design.
  Não há desenvolvimento, QA, dados ou infraestrutura — e não está no roadmap. Quem
  precisar, cria na própria camada.
- **Ferramenta de design visual.** Protótipo existe para validar solução, não para competir
  com ferramenta de design.
- **BI.** Métricas acompanham produto e entrega, não análise de dados corporativa.
- **Execução técnica.** O Hub entrega requisito, contexto e decisão — não escreve o código
  do produto da empresa.
- **Gestão de backlog como produto.** Sem issue, quadro, sprint ou estado de entrega
  próprios. O Hub opera o backlog que o time já tem, por integração e com portão antes de
  qualquer escrita. Reabrir isso exige refutar A14 no alpha
  ([`discovery/19`](discovery/19-pronto-para-alpha.md), critério S9), não pedido comercial.
- **Gestão de projetos genérica.** Tarefas e acompanhamento servem o fluxo de produto, não a
  operação da empresa inteira.
- **Configurar portão, formato de entrega ou método.** Não é limitação de versão: é o que
  sustenta o princípio 2.

---

## 10. Riscos

| Risco | Sintoma | O que o produto faz a respeito |
|---|---|---|
| **Portão colapsado** | a interface "adianta" etapas para parecer fluida e a garantia evapora | portão é estado do artefato: só pode ser aprovado, nunca pulado. O número de portões nunca diminui |
| **Qualidade terceirizada** | a empresa configura mal e a resposta piora sem rede | portão, formato de entrega e método ficam fora de qualquer campo configurável |
| **Núcleo exposto** | a empresa deduz a mecânica interna pela interface e o produto vira template copiável | a superfície pública é ação + encaixe; nada além disso é servido |
| **Duas fontes de verdade** | alguém edita por fora o que o produto gerou e o sistema lê de volta | escrita só pelo produto; o que é gerado é efêmero e somente leitura |
| **Escopo do Hub ≫ escopo do motor** | metade da lista de features é produto novo (§8.3) e a primeira versão não sai | fasear por bloco de maturidade; §8.2 primeiro |
| **Ação renomeada quebra a empresa** | uma ação some e a configuração da empresa vira órfã | ação é contrato público; renomear é mudança de API, não refatoração |
| **A integração não cobre a ferramenta do cliente** | cada time configura sprint, etapas e campos do seu jeito; a ação escreve "quase certo" e a pessoa volta a abrir o Jira para consertar | é o preço de não ter backlog próprio, e está medido: A14 na fila de teste do discovery, S9 como critério de saída do alpha. Refutada, a decisão de escopo é reaberta com dado |
| **Dependência de plataforma de terceiro** | limite de API, mudança de contrato ou preço na ferramenta que guarda o backlog | operações abstratas na interface de provider: trocar a implementação não toca workflow. Não elimina o risco comercial |

---

## 11. Métricas de sucesso

> Proposta inicial — não estava nas anotações. Precisa de validação antes de virar meta.

| Dimensão | O que medir |
|---|---|
| **Farol — velocidade** | tempo de ciclo da demanda (de "chegou" a "pronta para o time começar") · demandas concluídas por pessoa/semana |
| **Contrapeso — qualidade** | % de artefatos aceitos sem reescrita **não pode cair** enquanto o ciclo encurta; se cair, o trabalho migrou para a revisão |
| **Contrapeso — confiança** | portões aprovados sem leitura (tempo de aprovação incompatível com ler) — mede se a velocidade veio de pular a garantia |
| **Adoção** | % de demandas do time que nascem e vivem no Hub · pessoas ativas por espaço, por papel · ações executadas por semana |
| **Personalização** | % de espaços que preenchem ao menos um encaixe · nº de ações personalizadas por espaço (sinal de que virou o padrão da casa) |
| **Retenção** | espaços que passam da configuração inicial para uso semanal recorrente |

---

## 12. Perguntas em aberto

| # | Questão | Por que importa |
|---|---|---|
| 1 | **"Espaço" e "projeto" são o mesmo objeto que a organização e o projeto de hoje?** | o motor conhece organização (convenções, customização) e projeto (valores, caminhos). Se espaço = organização, metade do modelo já existe; se não, é modelo de dados novo |
| 2 | ~~**Onde o trabalho roda?**~~ **Resolvido em 2026-08-29, e a resposta é dividida.** Contexto, artefatos e histórico das sessões: **infra do produto** — precisam ser compartilhados. Execução do agente: **máquina do usuário**, com a chave de IA dele | o que continua aberto: o que o cliente paga se traz a própria chave, e o que fazer com o pack em texto no disco dele antes da primeira venda ([`MVP-TECNICO.md`](MVP-TECNICO.md), DT-19) |
| 3 | **A empresa pode manter a camada dela fora do produto?** | quem já tem a customização versionada não quer perder; mas o produto exibir uma camada que não controla é outro produto |
| 4 | **Qual é o primeiro papel atendido por completo?** | PM, designer e tech lead têm jornadas diferentes; os três de uma vez diluem a primeira versão |
| 5 | **Quais ferramentas de backlog o beachhead usa de fato?** | resolvida a pergunta anterior (kanban próprio não existe — escopo, 2026-08-29), sobra a lista: hoje só GitHub e GitLab funcionam. Cada ferramenta nova é construção, e a lista sai de 07, não da nossa preferência |
| 6 | **Até onde o encaixe "como fazer" pode ir sem virar substituição disfarçada?** | é o encaixe mais poderoso e o único que pode contradizer a moldura sem que ninguém perceba |
| 7 | **Workshops e canvas são ações novas ou um tipo novo de artefato?** | roadmap, personas e OKR existem hoje como método, não como coisa editável. A resposta define se é feature ou plataforma |
| 8 | **Quem mantém o catálogo de ações, e o que acontece quando uma ação é aposentada?** | ação é contrato com todas as empresas; sem regra de depreciação, cada release quebra alguém |
| 9 | **Como cobrar: por pessoa, por espaço ou por uso?** | trabalho paralelo faz o custo crescer por demanda, não por assento |
