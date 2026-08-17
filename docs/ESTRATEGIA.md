# Hub — Estratégia de Produto

> Registro da conversa de estratégia de **17/08/2026**. Documenta o que o produto é,
> por que há espaço contra Jira/Atlassian, como as funcionalidades funcionam, a economia
> por assento e as decisões tomadas (com o porquê de cada uma).
>
> ⚠️ **Conteúdo comercial — este repositório é privado por causa deste arquivo.**
> Preço por assento, margem, ICP e análise competitiva. Antes de dar acesso de leitura a
> qualquer empresa avaliada no teste do §10, distribua por `git archive` com
> `export-ignore` neste caminho — acesso ao repositório entrega o arquivo junto.
>
> Documentos irmãos, mesma pasta:
> [`HUB.md`](HUB.md) (telas do modo aplicativo) · [`ARCHITECTURE.md`](ARCHITECTURE.md)
> (camadas do harness) · [`MODOS.md`](MODOS.md) (repositório × aplicativo) ·
> [`ARQUITETURA_WEB.md`](ARQUITETURA_WEB.md) (infra do ramo interno) ·
> [`AGENT_SDK.md`](AGENT_SDK.md) (como o backend fala com o runtime).

---

## 1. O que é o produto

Não é "SaaS de execução de produto". Dito com precisão:

> **Máquina de estados sobre artefatos de produto, com portão humano em cada transição,
> e IA fazendo o trabalho entre os portões.**

Essa frase é o produto. Vende-se ela, não "IA que ajuda PM".

O `HUB.md` §4.2 já descreve a transformação central: no modo repositório o portão é uma
frase no procedimento (*"apresente e PARE"*) que depende do modelo obedecer; no produto é
**estado do artefato**, e o passo seguinte fica inalcançável até a aprovação existir.

E o `MODOS.md` §3 tem o princípio que nenhum concorrente tem: **o número de portões nunca
diminui**. Em 2026 todo mundo vende automação; a diferença é vender automação **auditável**.
Em entrega contratada, é isso que o cliente paga.

---

## 2. Por que ainda somos diferentes do Jira — e por que há espaço

### 2.1 O que a Atlassian já tem

Foi levantado numa pesquisa separada (⚠️ **não verificado por mim** — checar antes de usar
em pitch): Confluence Whiteboards com criação por prompt, Jira Product Discovery para
roadmap, Confluence Databases, Atlassian Analytics com conexão a banco, Rovo Studio para
agentes com cron, partner agents (Lovable/Replit/Gamma) gerando protótipo via MCP, e um
Remote MCP que já edita whiteboards e databases.

Ou seja: **cada perna existe**. Não é lacuna de feature.

### 2.2 A lacuna real

Três coisas que o ecossistema Atlassian não entrega:

| Lacuna | Por quê |
|---|---|
| **Harness opinado de product management** | Rovo dá o motor; o método é você que escreve como prompt. Não existe um agente de PM com framework, barra de qualidade e portões embutidos |
| **Loop fechado requisito → protótipo → documento → entrega** | Cada perna existe isolada; a costura é trabalho manual do cliente |
| **Auditabilidade estrutural** | Automação sem portão. Não há artefato com estado, trilha de aprovação e passo seguinte bloqueado |

### 2.3 Por que não é copiável em uma sprint

O que se copia em 5 minutos é um prompt. O que **não** se copia:

| Peça | Onde está |
|---|---|
| Disciplina de camada — portão estruturalmente inalcançável por configuração | `system/CONSTITUTION.md` (L0) |
| ~70 métodos calibrados, declarativos | `system/professions/*/methods/` |
| Superfície pública ação + encaixe: **o pior conteúdo possível ainda para no portão** | `ARCHITECTURE.md` §7 |
| Catálogo como dado, determinístico, `schema` versionado | `runtime/manifest.json` |
| Build que **reprova** quando a config da org diverge | `runtime/build.sh --strict` |
| 5 providers sob interface abstrata | `system/providers/` |
| Esteira `produz`/`requer` — requisito sem produtor reprova o build | `ARCHITECTURE.md` §7 |
| **O overlay acumulado de cada cliente** | `org/` — custo de troca real |

O último é o que importa comercialmente. O `funil.yaml` de hoje levou uma tarde e carrega a
v2.3 de um documento real. Multiplique por 20 encaixes × 2 anos de uso.

### 2.4 O contra-argumento que precisa ser aceito

"Protótipo virou commodity" é verdade para *texto → app*. Não é verdade para:

> requisito que é fonte de verdade → protótipo na stack do cliente → prints recortadas por
> fluxo → `.docx` entregável, com portão humano em cada seta.

Isso já existe hoje em `design-screen` + `prototype-prints` + `doc-final-generator`.

---

## 3. Modelo de dados — a decisão central

### 3.1 Não é um schema por artefato. São ~4 primitivas

Roadmap, jornada, story map e persona **não** são schemas separados. Por baixo, quase todo
artefato de produto é uma de quatro formas:

| Primitiva | O que é | Artefatos que são isso |
|---|---|---|
| `lista` | registros com campos | backlog, personas, riscos, KPIs, decisões |
| `grade` | eixo × faixa, com células | **roadmap** (tempo × time), **story map** (atividade × release), **jornada** (fase × dimensão), matriz 2D |
| `grafo` | nós + arestas dirigidas | dependências, opportunity solution tree, impact map, fluxo |
| `ficha` | um registro, campos ricos | persona individual, PRD, one-pager |

Roadmap é uma `grade` com eixo = trimestre e faixa = time. Jornada é a **mesma** `grade` com
eixo = fase e faixa = dimensão. Mesmo motor, configuração e nomes diferentes.

**É exatamente o padrão de `funil-priorizacao`**: vocabulário fechado de tipos de etapa, a
organização compõe e nomeia. Já implementado, já validado.

Consequência: você padroniza **como se renderiza e edita**, não *o que* o artefato é.

### 3.2 Quatro camadas de liberdade

| Camada | Quem define | Quando muda |
|---|---|---|
| As 4 primitivas | sistema | release (raro) |
| Configuração de instância (eixos, faixas, colunas, nomes) | organização | uma vez, na configuração |
| **Base ad-hoc com campos próprios** | **usuário ou IA, em tempo de execução** | qualquer pedido novo |
| Quadro branco livre | integração (FigJam/Miro via provider) | workshop, ideação |

A camada 3 é a válvula de escape. Uma `lista` com propriedades definidas em runtime +
vistas trocáveis (tabela, quadro, linha do tempo, matriz 2D, grafo) cobre toda a cauda longa
sem release nenhum. **É como o Notion ganhou** — não com um schema por tipo de documento,
mas com database de propriedades livres + vistas.

### 3.3 Quando de fato precisa release do sistema

Só quando o pedido **não é** lista, grade, grafo nem ficha. Exemplos reais: Gantt com
nivelamento de recurso, planilha com motor de fórmulas, desenho colaborativo em tempo real.
Raro. Todo o resto o usuário resolve sozinho na camada 3.

### 3.4 Por que NÃO canvas livre — o argumento decisivo

O objetivo declarado é *"tudo estará como contexto para a IA"*. Canvas de desenho livre é o
**pior formato possível** para isso:

- É caixa com `(x,y)` e texto solto. Sem semântica, sem relação, sem consulta.
- A IA lê "retângulo em 340,120 escrito 'Medições Q3'" e não sabe o que é.

Roadmap **tipado** é contexto ótimo. A IA responde *"o que atrasou"*, *"o que depende
disso"*, *"quais itens do roadmap não têm HU documentada"* — porque é **dado**.

Ou seja: o que se quer (IA que sabe onde focar, que resgata contexto) **exige** estrutura
tipada e é **impedida** por canvas livre.

Custo comparado:

| | Dado tipado + render determinístico | Canvas colaborativo livre |
|---|---|---|
| Construir | semanas por tipo | **anos-engenheiro** (CRDT, presença, conflito em geometria, viewport, hit testing) |
| Diff / versão | trivial | quase impossível |
| Como contexto pra IA | excelente | péssimo |

E: **canvas nem aparece na ordem de construção do `HUB.md` §8**. A própria arquitetura já
tinha respondido.

---

## 4. Como as funcionalidades funcionam

### 4.1 Uma base, várias vistas

O ganho visível de tipar — canvas nenhum faz isso:

```
Roadmap — Obrasim                    [Linha do tempo ▾] [Quadro] [Tabela] [Dependências]

              2026 Q3          2026 Q4          2027 Q1
            ┌───────────────┬────────────────┬───────────────┐
 Medições   │ ▓ Curva S     │ ▓ Aditivos     │               │
            │   HU08 ✓doc   │   HU09 ⏸ rev   │               │
            ├───────────────┼────────────────┼───────────────┤
 Contratos  │ ▓ Vincular    │                │ ▓ Reajuste    │
            │   HU06 ✓doc   │                │   sem HU ⚠️    │
            ├───────────────┼────────────────┼───────────────┤
 Plataforma │               │ ▓ SSO          │ ▓ Auditoria   │
            └───────────────┴────────────────┴───────────────┘
```

Mesmo objeto, outra vista:

```
[Dependências ▾]

  Vincular Projeto ──▶ Curva S ──▶ Aditivos
         │                            ▲
         └──────▶ Reajuste ───────────┘   ⚠️ sem HU documentada
```

O `⚠️ sem HU` **não é etiqueta que alguém desenhou**. É derivado: o item do roadmap não tem
artefato `documento-consolidado` ligado — a esteira `produz`/`requer` já sabe disso.

### 4.2 Quem edita o quê

Nunca "só a IA edita" — é o modo de falha de toda ferramenta AI-first: vira caixa-preta que
o usuário não consegue corrigir, e ele abandona.

| Ação | Quem | Passa por portão? |
|---|---|---|
| Arrastar card Q3→Q4 | usuário, direto | não |
| Renomear faixa, editar célula, adicionar coluna | usuário, direto | não |
| Criar base nova com campos próprios | usuário **ou** IA | não |
| "Reorganiza o roadmap pelo funil de priorização" | IA | **sim** — proposta como diff |
| Cron semanal atualizando status | IA | **sim** |

A assimetria tem razão: sua própria edição você já conhece; a da IA mexe em 30 itens de uma
vez e você não viu. Mesma lógica do write-gate (`CONSTITUTION.md` §2).

```
IA propõe — Roadmap                                    [Ver diff]

  Curva S       Q3 → Q4    ⚠️ HU08 ainda em revisão
  Aditivos      Q4 → Q4    (sem mudança)
  Reajuste      Q1 → Q2    ICE 180, abaixo do corte do trimestre
  SSO           novo item  vindo da demanda #341

  3 mudanças, 1 item novo          [Aceitar tudo] [Item a item] [Descartar]
```

### 4.3 Por que a edição direta é barata aqui

| | Dado tipado | Canvas de desenho |
|---|---|---|
| Arrastar card | muda **um campo** (`trimestre: Q4`) | geometria, encaixe, colisão, z-order, sincronizar viewport |
| IA editar | muda o mesmo campo | só sabe **regenerar o desenho inteiro** |
| Os dois no mesmo objeto | natural | é aí que nasce o CRDT |

No canvas, IA e usuário não editam a mesma coisa — a IA regenera, o usuário desenha por
cima, e as versões divergem. Por isso ferramenta de IA com canvas livre sempre vira
"gerar de novo" em vez de "editar".

### 4.4 O pedido inesperado, passo a passo

> *"quero um mapa de stakeholders por influência e interesse"*

1. IA cria uma `lista` com propriedades `nome`, `papel`, `influência` (1–5), `interesse`
   (1–5), `estratégia`
2. Aplica a vista **matriz 2D** (influência × interesse)
3. Preenche a partir do contexto do projeto que já tem
4. O usuário arrasta os pontos que discorda — muda o número, não a posição

Nenhum schema novo. Nenhum release. E o resultado continua sendo **dado**: depois a IA
responde *"quem são os stakeholders de alta influência não consultados na #341"*.

**A liberdade que se quer não vem de canvas livre — vem de campos livres.**

### 4.5 O que significa "colaborativo"

| | Custo | Serve o modelo? |
|---|---|---|
| Digitação simultânea (Google Docs) | alto (CRDT) | **não** — briga com o portão: artefato tem estado e trilha (`HUB.md` §4.2) |
| Comentário + sugestão + aprovação + versão | baixo | **sim** — é a esteira já especificada |

Trabalho de PM é assíncrono. Cursor ao vivo é o requisito que parece obrigatório e quase
nunca é usado.

---

## 5. Economia

### 5.1 Preço de inferência

Anthropic first-party, por 1M tokens (cache da doc: 2026-06-24 — reconferir antes de
planilhar):

| Modelo | Input | Output |
|---|---|---|
| Opus 5 | $5 | $25 |
| Sonnet 5 | $3 ($2 promo até 31/08/2026) | $15 ($10) |
| Haiku 4.5 | $1 | $5 |

Prompt caching: leitura **0,1×** do input, escrita 1,25× (TTL 5min). Empata em 2 requisições.

### 5.2 O harness é o caso ideal de cache

L0 + profissão + métodos + overlay da org ≈ 30–40k tokens **estáveis**, idênticos entre
todos os usuários da mesma organização. Depois da primeira chamada, carregar o harness
inteiro custa ~$0,02 em vez de ~$0,20.

### 5.3 Custo por operação (Opus 5, com cache no prefixo)

| Operação | Input | Output | Custo |
|---|---|---|---|
| Documentar requisito (HU completa) | ~80k | ~12k | **~$0,55** |
| Fase de discovery | ~40k | ~4k | ~$0,25 |
| Priorizar backlog | ~50k | ~8k | ~$0,35 |
| Criar tela no protótipo | ~120k | ~20k | ~$1,00 |
| Consulta / chat | ~15k | ~2k | ~$0,10 |

### 5.4 Custo por assento

Assento pesado (PM de agência, semana cheia): 4 documentos + 8 turnos de discovery +
2 telas + 20 consultas ≈ **$12/semana ≈ $50/mês** tudo em Opus.

Com roteamento por modelo (Haiku para extração e triagem, Sonnet para escrita, Opus só na
síntese): **$20–25/mês**.

**Veredito: a $99–149/assento/mês, margem bruta 70–80%.** SaaS saudável. BYO API key
resolveria um problema que não existe e destruiria a conversão (atrito de configuração +
sensação de cobrança dupla).

### 5.5 O que realmente queima dinheiro

Não é gerar documento. É **agente autônomo em loop sem teto**. Um cron aberto pode gastar
500k+ tokens numa execução (~$3–5). Diário × 30 dias × N projetos e a margem some.

Ferramentas que existem exatamente pra isso:

| Mecanismo | O que faz |
|---|---|
| **session budget** (Managed Agents) | teto em dólar por sessão; o agente **pausa** com `stop_reason: budget_reached` em vez de estourar |
| **task_budget** | o modelo se autorregula sabendo quanto resta do orçamento |
| **effort** (`low`…`max`) | no Opus 5, `low`/`medium` rendem muito — sweep obrigatório por rota |

**Regra: todo cron nasce com teto.** Não é otimização depois, é requisito do dia 1.

---

## 6. Decisões tomadas

| # | Decisão | Por quê |
|---|---|---|
| 1 | **Hospedado, não local com a IA do usuário** | Rodar local otimiza o custo de inferência — que o cliente já aceita pagar — e destrói o único ativo defensável: estado compartilhado, trilha de aprovação, artefato que circula. Além disso, revender rate limit do plano do usuário é o padrão vetado no ToS; shell-out no Claude Code que ele já logou é a mesma coisa com outro nome |
| 2 | **Cobrança por assento, inferência embutida** | BYO key como opção para avançado, não como default |
| 3 | **Sem canvas colaborativo próprio** | Anos-engenheiro para empatar com Figma/FigJam, e é o pior formato como contexto de IA. Canvas continua provider (`canvas/figma-mcp.md`) |
| 4 | **4 primitivas tipadas + base de campos livres** | Cobre 95% dos artefatos sem virar zoológico de schemas, e mantém tudo consultável pela IA |
| 5 | **MCP não é diferencial** | É encanamento; todo mundo tem. O diferencial é a camada acima: qual ação roda, qual portão trava, qual artefato desbloqueia o próximo |
| 6 | **ICP: software house / agência / fábrica de software** | Não PM de startup (sem orçamento, churn alto, ticket baixo) |
| 7 | **Manter os 3 runtimes vivos** | `claude`, `codex`, `opencode` — hedge real contra dependência de plataforma única |

### 6.1 Por que esse ICP

Sinais dentro do próprio repositório: `.docx` com marca, `identidade` com Cliente + Ordem
de Serviço, catálogo GL, HU/HT, wiki, GitLab. O harness nasceu para entrega contratada.

Nesse ICP:

- o comprador **é** o usuário (head de entrega)
- orçamento existe — é custo faturável, não ferramenta de produtividade
- documentação é **obrigação contratual**, não higiene
- a dor é aguda e mensurável: escrever HU é o gargalo

Mercado menor que "PM global". Muito mais fácil de vender.

---

## 7. O que NÃO construir

Canvas livre próprio · editor colaborativo em tempo real · geração de protótipo genérica ·
marketplace · multi-modelo no MVP.

Tudo isso é depois de alguém pagar.

---

## 8. Sequência

| Fase | O quê |
|---|---|
| **MVP** | Esteira PM/PO com portões + **armazenamento de artefatos** (`HUB.md` §8 item 4) — é o "lugar para os arquivos do projeto" que falta hoje, e não é canvas |
| **+1** | Schemas `roadmap` e `jornada-usuario` + renderizadores + comentários |
| **+2** | MCP próprio sobre os artefatos tipados — aqui a IA "sabe onde focar" de verdade |
| **+3** | `persona`, `story-map`, OST — mais instâncias das mesmas primitivas, custo marginal |
| **talvez nunca** | Canvas livre próprio |

A ordem do `HUB.md` §8 continua valendo para o backend: portão como estado (1),
materializador (2), API do catálogo (3), armazenamento (4), sandbox (5), fronteira de IP (6).

---

## 9. Riscos honestos

| Risco | Leitura |
|---|---|
| **Platform risk** | A Anthropic pode lançar um plugin oficial de product management. Se o produto for só bons prompts, morre no dia do anúncio. Se for servidor de estado + integrações + overlay acumulado, sobrevive |
| **Modelo melhora e come a camada** | `ARCHITECTURE.md` §2 aposta certo (conteúdo declarativo melhora de graça). Mas provider recipe e procedimento L2 são **teto** — quanto mais L2 procedural acumular, mais o produto envelhece |
| **Mercado de ferramenta de PM é ruim** | Verdade no geral. Mitigado pela escolha de ICP (§6.1), onde o comprador é o usuário e o custo é faturável |
| **Dependência de plataforma única** | Todo o produto pressupõe que o cliente já paga Claude. Ótimo pro custo, péssimo pro TAM. Os 3 adapters são o hedge |
| **"Tudo em um lugar"** | É como toda ferramenta horizontal morre — contra Notion, Confluence, Jira, Miro e Figma ao mesmo tempo. A versão que pode ganhar é mais estreita: **dono do modelo de dados dos artefatos de produto + máquina de estados com portões**. Aí renderizar nativo fica barato e integrar vira opcional |

---

## 10. O teste que falsifica a tese

Não é publicar plugin grátis. É:

> Instalar o harness em **2–3 outras empresas de entrega**, em modo repositório, e elas
> configurarem o `org/` **sem você**.

Mede exatamente a coisa certa:

- configuraram os encaixes sozinhas → **tem produto**
- precisaram de você em cada encaixe → tem consultoria com passos extras
- configuraram e abandonaram em 4 semanas → a dor não era essa

Custo: zero de código. `install.sh`, scaffold e build validador já existem. Nenhuma linha de
SaaS antes desse sinal.

---

## 11. A pergunta que decide o resto

Isso é **produto para vender** ou **arma para ganhar e entregar mais contrato na Websis com
margem maior**?

- Segunda opção: já está pronto, ROI é agora, produtizar depois é opcional e mais barato —
  com clientes reais de prova.
- Primeira opção: o teste do §10 vem antes de qualquer linha de interface.

Palpite pela forma do repositório: começa como a segunda e vira a primeira. Não forçar a
ordem inversa.

---

## 12. Em aberto

- Verificar as afirmações sobre Atlassian/Rovo/marketplace (§2.1) antes de usar em pitch.
- Preço de assento definitivo e faixa de uso incluída.
- Onde o estado dos artefatos é guardado e versionado do lado do produto (`MODOS.md` §6).
- Quantos schemas estruturados o sistema mantém antes de virar zoológico (`HUB.md` §9).
- Se a organização pode manter a camada dela fora do produto, e como o produto exibe algo
  que não controla.
