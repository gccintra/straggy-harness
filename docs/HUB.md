# Hub — fluxos de interface

Especificação de produto do **modo aplicativo**. Arquitetura e precedência de camadas:
[`ARCHITECTURE.md`](ARCHITECTURE.md). Quem manipula o quê em cada modo e o contrato de
portabilidade: [`MODOS.md`](MODOS.md). Catálogo público: [`../system/ACOES.md`](../system/ACOES.md).

> **Estado.** Nada aqui está implementado. `MODOS.md` §6 dá a *direção* da costura entre os
> modos; este documento dá a *forma* das telas. Muda em ritmo de produto, não de arquitetura —
> por isso vive fora do `MODOS.md`.

O que não pode mudar ao virar produto está em `MODOS.md` §3 (contrato de portabilidade). O
mais importante para este documento: **o número de portões nunca diminui** — eles mudam de
forma, não de existência.

---

## 1. Dois papéis, duas superfícies

| Papel | Faz | Vê |
|---|---|---|
| **Administrador da organização** | conecta integrações, preenche encaixes, cria ação nova | catálogo de ações e campos de encaixe |
| **Pessoa que trabalha** (PM, designer, tech lead) | conversa, revisa, aprova | conversa e esteira de artefatos |

Nenhum dos dois vê nome de workflow, divisão interna do pack, procedimento do sistema,
portões ou métodos. A superfície pública é **ação + encaixe** (`ARCHITECTURE.md` §7).

---

## 2. Entrada da organização — uma vez

1. **Criar organização** → o pack padrão já está valendo. Zero configuração obrigatória.
2. **Conectar integrações** — backlog, base de conhecimento, banco. É o que no modo
   repositório vive no `.env`; aqui é OAuth/cofre, nunca conteúdo.
3. **Dados do projeto** — cliente, projeto, responsável, caminhos. É o
   `project-config.yaml` virado formulário. Campo vazio → placeholder no documento gerado;
   o sistema não inventa valor.

Sai usável no passo 1. Os passos 2 e 3 ampliam o que funciona, não destravam o básico.

---

## 3. Telas de configuração

### 3.1 Catálogo de ações

Lista de trabalhos que o harness sabe fazer, em linguagem de resultado. Nunca lista de
skills.

```
Documentar requisito          ✎ personalizado por esta organização
Explorar solução              ✎ personalizado
Registrar demanda             — padrão do sistema
Criar tela                    — padrão
...
```

### 3.2 Encaixes de uma ação

Abrir uma ação mostra os campos que ela aceita:

```
Documentar requisito
├── Como fazer                  [texto longo]   ← encaixe `procedimento`
├── Estrutura do documento      [texto longo]
└── Regras de classificação     [texto longo]

Campo vazio = vale o padrão do sistema.
```

Contrato da tela:

- Cada campo é **substituição inteira** daquele encaixe, nunca mistura com o padrão.
- Salvar passa por **aprovação** antes de valer para a organização (`MODOS.md` §5).
- Campos fora do catálogo **não existem**: portão, contrato de saída, método e L0 não são
  encaixe, então não têm campo. É assim que a configuração não degrada a qualidade.

### 3.3 Criar ação

Só para o que o harness não faz — não há padrão para degradar.

```
Nome:            Relatório mensal para o cliente
Quando acionar:  "relatório do mês", "manda pro cliente", "fechamento"
Como fazer:      [texto longo]
```

"Quando acionar" é o gatilho de roteamento — no modo repositório, a `description` do
`SKILL.md`. Gatilho fraco = ação morta; a tela deve exigir frases literais, não um resumo.

### 3.4 Encaixe estruturado — o construtor de funil

Encaixe de texto longo (3.2) serve para procedimento: o modelo lê e julga. Não serve quando
o conteúdo da organização vira **conta** — funil de priorização é o caso. Fórmula em campo
livre exige parser, aceita lixo, não pré-visualiza impacto e não versiona; regex de extração
nenhum administrador escreve. `tipo: estrutura` (`ARCHITECTURE.md` §7) existe para isso.

#### Vocabulário fechado de etapas

Um funil é uma lista ordenada de etapas. Cada etapa tem um tipo do conjunto fechado abaixo —
a organização **compõe e nomeia**, nunca inventa tipo. Schema: `funil-priorizacao`.

| Tipo | O que a organização configura | Widget |
|---|---|---|
| `triagem` | N faixas nomeadas, em ordem de precedência | lista reordenável |
| `escala` | nome, mínimo, máximo, direção, rubrica por faixa de nota | 3 campos + tabela de rubrica |
| `score` | operador ∈ `produto · soma · media · soma-ponderada · razao` e quais escalas entram | dropdown + seleção |
| `faixa` | bandas nomeadas por corte sobre uma escala ou sobre o score; 1-D ou 2-D | sliders com pré-visualização |
| `ordenacao` | etapas em ordem, cada uma ↑ ou ↓ | lista reordenável |

Cobertura sem nenhum tipo novo: MoSCoW+ICE (`triagem` + 3 `escala` + `score:produto` +
`faixa` 2-D) · RICE (`score:razao`) · WSJF (`score:razao`) · Value/Effort (`faixa` 2-D) ·
Kano (só `triagem`). Modelo que não couber nos cinco é **release do sistema**, não
configuração — mesma fronteira da ação nova (§3.3).

#### A tela

```
Funil de priorização                      Preset: [MoSCoW + ICE ▾]   v3 · ativo

1  Triagem     MUST › SHOULD › COULD › WONT                    [editar faixas]
2  Escalas     Impacto 1–10 · Confiança 1–10 · Facilidade 1–10  [rubricas]
3  Score       produto( Impacto, Confiança, Facilidade )        [operador ▾]
4  Faixas      2-D  Impacto × Facilidade → 4 bandas             [ajustar cortes]
5  Ordenação   Triagem → Faixa → Score ↓

Nuances (texto)  ─────────────────────────────────────────────────────────
Criticidade real bypassa a fila…                    ← encaixe `procedimento`
```

Presets são obrigatórios na tela. Funil em branco é o modo de falha conhecido — ninguém
monta um do zero, e o resultado é uma organização sem funil nenhum.

#### Anomalias deixam de ser conteúdo

Com etapas tipadas, a inconsistência **deriva da definição** — a organização não escreve nem
configura regra de anomalia:

| Anomalia | Deriva de |
|---|---|
| score registrado ≠ recalculado | operador + escalas |
| rótulo aplicado ≠ faixa calculada | cortes da faixa |
| item na fila sem dimensão obrigatória | escalas declaradas |
| faixa de triagem alta caindo em banda de descarte | ambas são ordenadas |
| nota fora do intervalo | mínimo/máximo da escala |

#### Binding — onde o valor mora

Separado do funil de propósito: **o funil é da organização, o binding é da integração**.

```
Onde gravar a priorização no backlog
  Triagem     → [rótulo com prefixo ▾]  MSCW::
  Dimensões   → [campo próprio ▾ | tabela na descrição (legado)]
```

No produto o valor é **estado do artefato** (§4.2), canônico no Hub e projetado para o
backlog. Extração por expressão regular vira adaptador do modo legado, escondido no
provider — nunca superfície de configuração.

#### Trilhos de edição

Editar funil de produção mexe em fila viva. Quatro trilhos, todos obrigatórios:

| Trilho | Comportamento |
|---|---|
| Pré-visualização de impacto | *"34 demandas mudam de banda, 3 saem do topo"* **antes** de salvar |
| Versão | o funil é versionado e cada item pontuado carimba a versão — reranquear sob versão nova é re-pontuação explícita, nunca silenciosa |
| Migração | remover faixa ou escala exige mapear destino ou marcar para re-triagem; nunca perda silenciosa |
| Aprovação | salvar passa pelo mesmo portão de 3.2 |

#### Fora do alcance de quem configura

Portão humano · contrato de saída · a regra de que a análise **só identifica** e nunca
corrige sozinha · o export em lote único · os cinco tipos de etapa. Pior funil possível
ainda para no portão e ainda produz o artefato no formato declarado — é o §7 do
`ARCHITECTURE.md` aplicado a um encaixe que calcula.

---

## 4. Telas de trabalho

### 4.1 Conversa

Escolhe a persona, fala em linguagem natural. O sistema resolve a ação pelos gatilhos, sem
o usuário escolher skill. Contexto de tela soma à intenção (`MODOS.md` §5).

### 4.2 Portão vira estado — a transformação central

No modo repositório o portão é uma frase no procedimento (*"apresente e PARE"*) e depende
do modelo obedecer. No produto, é **estado do artefato**, e o passo seguinte fica
inalcançável até a aprovação existir.

```
Demanda #276
├── Discovery       ✓ aprovado · Gustavo · 10/08
├── Protótipo       ✓ validado · Gustavo · 11/08
├── Documento .md   ⏸ aguardando revisão    [Ver] [Aprovar] [Pedir ajuste]
└── Entregável      🔒 bloqueado até o .md ser aprovado
```

O entregável não é "o agente não deveria gerar ainda" — é **impossível**: o estado anterior
não foi aprovado. Risco correspondente: `MODOS.md` §7, "portão colapsado no app".

### 4.3 Escrita externa vira confirmação com preview

Toda mutação fora do rascunho — criar demanda, comentar, publicar na wiki, gravar arquivo —
mostra o que vai fazer e espera clique:

```
Vou criar esta demanda no backlog:

  [TÍTULO] - [MÓDULO]
  Criticidade: MUST
  Labels: TIPO::BUG, PARA DESCOBERTA

[Criar]  [Editar]  [Cancelar]
```

É o write-gate da `CONSTITUTION.md` §2 virado interface. Aprovação de um passo não vale
para o próximo.

---

## 5. O pipeline como esteira

```
demanda  →  discovery  →  protótipo  →  documento  →  entregável
             4 fases      só demanda    ⏸ revisão     ⏸ pedido
             ⏸ por fase   com tela      humana        explícito
```

Cada seta é um portão: uma transição de estado que exige humano. Cada caixa tem estado,
responsável e data.

Demanda sem interface pula o protótipo — a esteira se ajusta pela natureza da demanda, não
por configuração (`org/ORG.md` §4).

---

## 6. Trilha

Todo artefato guarda quem aprovou, quando, qual versão e contra qual release do harness foi
produzido. É o que no modo repositório é o histórico do Git.

Serve para auditoria (`MODOS.md` §5) e para responder "de onde veio esse comportamento?" —
equivalente ao `build.sh --list`.

---

## 7. O que adaptar no harness antes — pré-requisito

O harness de hoje é legível por humano e por modelo, mas **não por interface**. Estes são os
ajustes dentro de `.agents/` que destravam o desenvolvimento do Hub. Nenhum depende do
produto existir; todos continuam valendo no modo repositório.

> **Estado: 7.1 a 7.8 implementados.** O build passa em `--strict` sem avisos.

### 7.1 Encaixe ganha metadado de interface 🔴 — feito

O frontmatter declarava só `nome: caminho`. Agora aceita a forma longa, com o que a tela
3.2 precisa para desenhar o campo: `rotulo`, `ajuda` e `tipo`
(`texto-longo | arquivo | imagem | script`). Schema completo: `ARCHITECTURE.md` §7.

Duas correções em relação ao desenho original:

- **Não existe encaixe obrigatório em ação do pack.** Obrigar a organização a preencher
  contradiz a degradação limpa (`ARCHITECTURE.md` §7). O campo que existe é
  `essencial: true`, e diz outra coisa: *o sistema não tem como ter padrão para isto*
  (a marca da empresa, um gerador proprietário), então a **ação** fica indisponível até
  alguém preencher. É estado do catálogo, não validação de formulário.
- **`padrao` é derivado, não declarado.** O build checa se o arquivo existe no pack.

Isso expôs um buraco real: **o pack não ships nenhum `references/procedimento.md`** — 14
ações declaram o encaixe `procedimento` sem padrão do sistema por trás. Enquanto ficar
assim, "encaixe vazio → o padrão do pack vale" é falso para elas, e o build avisa a cada
execução. Escrever esses padrões é trabalho de conteúdo, pendente.

### 7.2 `build.sh` emite um manifesto 🔴 — feito

`<runtime>/manifest.json`: ações, encaixes com metadado, gatilhos, personas, artefatos e
condições — o catálogo como **dado**, determinístico e versionado por `schema`. É o que a
API do Hub lê. Contrato e fronteira do bloco `interno`: `ARCHITECTURE.md` §8.

`ACOES.md` deixou de ser mantido à mão: o build **verifica** o bloco derivado e reprova
quando ele diverge do frontmatter (`--fix` regenera). Verificar em vez de reescrever é o
que permite rodar com `system/` read-only no sandbox do produto.

### 7.3 Origem da camada da organização vira parâmetro 🔴 — feito

`build.sh --org DIR` / `HARNESS_ORG_DIR`. Junto veio o que faltava para o sandbox:
`--out DIR` / `HARNESS_OUT_DIR` (a saída gerada não pode cair dentro de um `system/`
servido read-only), `--strict` (aviso vira reprovação, código 3) e `SKILLS_REF` (como o
runtime se refere às skills resolvidas, que no produto não moram em `.agents/`).

### 7.4 Workflow declara o artefato que produz e o que exige 🟡 — feito

É o pré-requisito de "portão como estado" (§8.1). Hoje a esteira da §5 existe só em prosa,
espalhada por `ORG.md` §4, pelo encerramento do discovery e pelas precondições do
consolidador. O produto precisa disso como grafo:

```yaml
produz:  documento-consolidado
requer:  solucao-definida
requer_condicional:
  - artefato: prototipo-validado
    quando:   demanda-tem-interface
```

Seis ações declaram a esteira (`demanda-registrada` → `solucao-definida` →
`prototipo-validado` → `documento-consolidado` → `documento-final`, com
`prints-capturadas` ao lado). O backend bloqueia o passo seguinte sem interpretar texto, e
o modo repositório ganhou uma checagem que antes dependia do modelo obedecer: requisito sem
produtor e ciclo reprovam o build.

O vocabulário de artefatos não é lista mantida à parte — é o conjunto dos `produz`
declarados (`ARCHITECTURE.md` §7). A esteira saiu da prosa do `ORG.md` §4, onde estava na
camada errada: portão é do sistema, não da organização.

### 7.5 Provider declara o que precisa para rodar 🟡 — feito

Cada implementação declara, no frontmatter, `capacidades` e `requisitos` — `binarios`,
`pacotes`, `variaveis`, `servicos`, `hosts`. Cada bucket é uma ação diferente de quem
provisiona o sandbox (§8.5). Entra no manifesto, com a posse (sistema ou organização) de
cada implementação.

Requisito que não é fixo — o cliente de banco, decidido por `DB_CONNECT_CMD` — não se
declara: inventar um valor seria pior que declarar a variável que o resolve.

### 7.6 Auditar caminho de artefato hardcoded 🟢 — feito

`project-config.yaml` ganhou `caminhos.entregaveis`, `caminhos.historico` e
`caminhos.dados` ao lado de `pasta_por_demanda`; 76 linhas em 30 arquivos passaram a
referenciar a chave em vez do literal. Três exceções, com motivo: o `committer` opera sobre
a árvore de trabalho do Git, onde o caminho é literal por natureza; e dois casos que citam
um arquivo real do passado, não um destino de escrita.

Em bloco executável (shell, Python) o valor entra por variável (`$DADOS`), não por
placeholder — placeholder dentro de f-string é código quebrado, não documentação.

### 7.7 Renderizador de persona para um quarto runtime 🟢 — absorvido pelo §7.2

Não virou um quarto adapter: o Hub consome a API, não arquivo em disco. Persona é registro
no manifesto (identificador, rótulo, gatilho, modo) — um alvo a menos para manter.

### 7.8 Encaixe estruturado 🟡 — feito

`TIPOS_ENCAIXE` ganhou `estrutura`, que exige `schema: <id>` apontando para
`system/schemas/<id>.yaml` — o vocabulário fechado é do sistema, a instância é da
organização. O manifesto publica o identificador do schema, e é por ele que a interface sabe
**qual construtor** desenhar (§3.4); sem isso, encaixe que alimenta cálculo cairia numa
textarea genérica.

Primeiro schema: `funil-priorizacao`. O funil da organização saiu da prosa e virou instância
declarada, com a rubrica de cada faixa de nota junto — o que antes só existia no documento
humano e era relido a cada execução.

Não vale para todo encaixe: procedimento, template e vocabulário continuam texto. `estrutura`
é para o conteúdo que uma máquina precisa **calcular**, não interpretar.

---

## 8. O que construir no produto, em ordem

| # | Peça | Por que nesta ordem |
|---|---|---|
| 1 | **Portão como estado** | é o coração das telas de trabalho e o item do contrato de portabilidade que mais arrisca ser violado |
| 2 | **Materializador** | "de onde vem a camada da organização" vira ponto de troca: disco **ou** dado do produto. Quem consome é o `build.sh`, não uma skill (`MODOS.md` §6) |
| 3 | **API do catálogo** | serve o manifesto do §7.2 e recebe o conteúdo dos encaixes de volta |
| 4 | **Armazenamento de artefatos** | `outputs/`, `history/` viram dado do produto. Escrita dos dois lados — problema separado, declarado em `MODOS.md` §6 |
| 5 | **Sandbox de execução** | as ferramentas dos providers (`gh`, `pandoc`, `rclone`, Python) rodando fora da máquina do usuário |
| 6 | **Fronteira de IP** | a visão resolvida materializada **só** no sandbox, nunca no que a organização enxerga ou baixa (`MODOS.md` §6) |

1 e 2 mudam o desenho do backend. 3 a 6 são encanamento. Todos pressupõem o §7 feito — sem
manifesto e sem metadado de encaixe, não há o que a interface consuma.

---

## 9. Decisões ainda em aberto

Vivem em `MODOS.md` §6 e valem para este documento:

- Como o conteúdo da organização é guardado e versionado do lado do produto.
- Se a organização pode manter a camada fora do produto, e como o produto exibe algo que
  não controla.
- Contrato do materializador: atomicidade, integridade, comportamento sem rede.
- Até onde o encaixe `procedimento` pode ir sem virar substituição disfarçada.
- Quantos schemas estruturados (§3.4) o sistema mantém antes de virar zoológico — cada um é
  um construtor de interface a desenhar e versionar.
- Como rastrear contra qual release do harness uma camada foi validada.
