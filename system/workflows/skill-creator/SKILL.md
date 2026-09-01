---
name: skill-creator
description: >
  Cria e edita skills e demais artefatos do próprio harness (workflows, métodos, providers,
  personas, regras de engajamento) seguindo a arquitetura de camadas do harness. Use SEMPRE
  que o usuário pedir para criar uma skill nova, editar/refatorar uma skill existente,
  adicionar um workflow, extrair um método, mudar a CONSTITUTION/ORG, mexer na estrutura do
  harness ou "melhorar o harness" — qualquer alteração em arquivo dentro de .agents/ que não
  seja config de instância (project-config.yaml, .env).
  Garante que toda mudança respeite: camada certa, prescrever resultado e não raciocínio,
  referência em vez de cópia, portões humanos preservados.
---

# skill-creator — criação e edição de artefatos do harness

Meta-skill: governa como o próprio harness evolui. Toda alteração em `.agents/` passa por
aqui para nascer na camada certa e no estilo certo.

**Este arquivo é autossuficiente.** Não leia `docs/ARCHITECTURE.md` (nem outro doc de
`docs/`) para aplicar estas regras — o conhecimento operacional mora aqui. O ensaio em
`docs/` é leitura humana; se uma regra nova de arquitetura nascer, atualize **esta skill**
e o ensaio no mesmo movimento.

Consultas pontuais, não pré-leitura:

- `system/ACOES.md` — catálogo vigente de ações (tabela derivada; o lugar de mudar é o
  frontmatter). Precisa saber se a ação já existe ou se a vizinha de `confunde_com` é outra.
- `org/ORG.md` — só quando a mudança é L2 org (língua, nomenclatura, papéis desta empresa).
- `system/providers/<domínio>/INTERFACE.md` — só quando o artefato usa aquele domínio:
  operações, regime de modo degradado, capacidades. A skill criada aponta a interface, nunca
  a implementação.

L0 (`system/CONSTITUTION.md`) já está carregada: write-gate, autonomia, brevidade e prosa,
portões, honestidade. Esta skill **nunca afrouxa** nada disso.

---

## 1. Classificar ANTES de escrever — em que camada a mudança mora?

Primeira pergunta de toda demanda. Errar a camada aqui é o que erode a arquitetura.

**Precedência:** em conflito, a camada de baixo vence. **L0 vence tudo** — inclusive
instrução de workflow editado pela organização. Customiza-se o *procedimento*, nunca o
*comportamento*. Camada de cima **referencia** a de baixo, nunca copia. Mesma explicação em
dois arquivos = um deles está na camada errada.

**Método é default, não camisa de força:** o agente pode desviar do método (L1) ou do
caminho do workflow (L2) declarando o desvio e o porquê, desde que cumpra o contrato de
saída e não pule portão. Contrato e portão são invioláveis; método, não.

| A mudança é... | Camada | Destino físico |
|---|---|---|
| Comportamento que vale p/ qualquer profissão/empresa (gate, honestidade, prosa, delegação) | L0 | `system/CONSTITUTION.md` |
| Conhecimento de PM/Designer/Tech Lead válido em qualquer empresa (método, critério de seleção, barra de qualidade) | L1 | `system/professions/<profissão>/methods/` ou `reasoning.md` |
| Convenção transversal da organização (língua, nomenclatura, papéis) | L2 | `org/ORG.md` (scaffold em `system/pack/org-scaffold/`) |
| Procedimento que serve a **qualquer** empresa (gatilho, binding, portão, formato genérico) | L2 pack | `system/pack/workflows/{nome}/SKILL.md` |
| Qualquer customização de ação **existente** — formato, template, vocabulário, **procedimento** | L2 org | **encaixe** declarado pelo pack: `org/workflows/{nome}/{caminho do encaixe}`. Nunca substitui o workflow |
| Ação que o harness **não faz** | L2 org | `org/workflows/{nome}/SKILL.md` com `acao:` nova. Não entra em `system/ACOES.md` |
| Máquina do harness (governança, motor procedural, tooling de repo) | system | `system/workflows/{nome}/` (não-forkável, sem symlink) |
| Método/profissão própria da organização | L1 org | `org/professions/<profissão>/` |
| Sintaxe/uso de ferramenta (glab, pandoc, Figma MCP, banco) | provider | `system/providers/<domínio>/` (INTERFACE + implementação) ou `org/providers/` quando a ferramenta é interna |
| Como um runtime descobre/configura persona | adapter | `runtime/<runtime>/` |
| Valor do projeto (cliente, URL, credencial) | L3 | `project-config.yaml` / `.env` — **fora do escopo desta skill** |

Regras de desempate:

- Conteúdo serve a mais de uma skill → camada de baixo (método ou provider), nunca copiar.
- "Isso vale em qualquer empresa?" sim → L1. "É como NÓS fazemos?" → L2.
  "É comando de ferramenta?" → provider.
- Demanda mistura camadas (o caso comum) → **dividir a proposta por camada** e dizer
  explicitamente o que vai para onde.

**Física por POSSE.** `system/` é imutável pela organização (L0 + L1 + providers + pack
padrão + máquina). `org/` é da organização — fora do Git do harness, semeada pelo
`install.sh` a partir de `system/pack/org-scaffold/` (arquivo a arquivo, nunca sobrescreve
o que já existe). Overlay pré-existente sobrevive à atualização do harness.

```
system/          imutável (no produto: shipped read-only)
├── CONSTITUTION.md          L0
├── professions/             L1
├── providers/               contrato + implementações oficiais
├── schemas/                 vocabulário dos encaixes estruturados
├── pack/                    L2 PADRÃO — workflows genéricos + org-scaffold/
└── workflows/               máquina do harness (não-forkável) — esta skill mora aqui
org/             posse da organização
├── ORG.md · workflows/ · professions/ · providers/
runtime/skills/  GERADO — a visão resolvida que os runtimes leem
runtime/claude|codex|opencode|cursor/  GERADO — adapters, a partir dos PERSONA.md
```

**Resolução** (`runtime/build.sh`, nunca à mão):

1. `system/workflows/<nome>` existe → vence sempre (máquina não é forkável; override é
   ignorado com aviso).
2. A organização reivindicou a **ação** do workflow do pack → a moldura do pack concatena
   com o conteúdo da organização nos encaixes declarados. O nome da pasta é endereço
   físico, não contrato.
3. Ação sem nada da organização → o pack atende.
4. `org/workflows/<nome>/DISABLED` → workflow do pack desligado nesta organização.

Nunca crie symlink de skill à mão — rode o build. `runtime/skills/` e os adapters são
gerados e fora do Git.

**Fork barato.** Trocar o formato de um documento não copia a skill inteira: a organização
preenche o encaixe (`references/<arquivo>.md`) e herda o resto. Fork de `SKILL.md` inteiro
congela a organização na versão antiga do pack — só se o procedimento em si for outro, e
mesmo aí o caminho é o encaixe `procedimento`, não substituir o workflow. **Não existe
substituir um workflow do pack.** Precisa mudar portão ou contrato de saída? A resposta é
não — ou vira ação nova do sistema.

**Teste do pack:** *"outra empresa usaria isto sem editar?"* Sim → `system/pack/`.
Não → `org/`. Três vazamentos que reprovam: **vocabulário de documento** da organização
(siglas de tipo de HU/HT, nome de catálogo), **taxonomia literal** (nome de label, título
de página) e **valor de instância** (domínio, host, repo, tabela). Nos três, o pack descreve
o papel e lê o valor de `project-config.yaml`, `org/ORG.md` ou do provider — nunca o decora.

## 2. O teste de linha — o que pode ser prescrito

Toda linha escrita numa skill é classificada:

- **Contrato** (o que o resultado deve conter/formato/destino) → prescrever.
- **Restrição** (limite p/ controle humano: write-gate, "um artefato por turno", parar p/
  revisão) → prescrever.
- **Script cognitivo** (como raciocinar, em que ordem analisar) → **não escrever**.

Teste: *"se o modelo ignorar esta linha e o resultado ainda cumprir contrato e portões,
houve dano?"* Não → é script, corte. Na dúvida entre prescrever e confiar no modelo:
confie no modelo e endureça o contrato de saída.

Atenção ao inverso: restrição disfarçada de script não pode ser podada — se a sequência
existe para cadência de aprovação do usuário, é restrição e fica. A ordem interna dos
sub-passos dentro da fase é script — sai.

**Gradiente por camada:** L0 restrição pura · L1 seleção + barra + contrato (zero passo a
passo) · L2 spec de entregável + portões · **providers e motores: procedural à vontade** —
sintaxe de ferramenta é fato, não raciocínio. Conteúdo declarativo continua valioso conforme
os modelos melhoram; conteúdo procedural vira teto.

### Anti-padrões (o que faz a arquitetura apodrecer)

- **L1 virar enciclopédia.** Se o modelo já sabe a teoria, não escreva. Método carrega
  seleção, barra de qualidade e contrato — nada mais.
- **Sobre-prescrição.** Script cognitivo degrada hoje e vira teto amanhã. Na dúvida,
  confie no modelo e endureça o contrato de saída.
- **L2 reabsorver método.** Sinal: workflow passando de ~100 linhas ou repetindo conteúdo
  de `methods/`.
- **Interface anêmica ou vazando.** Se a interface só espelha os comandos de uma
  ferramenta, não abstraiu; se o workflow cita endpoint, vazou. Teste: *"este workflow
  funciona igual com outra ferramenta?"*
- **Roteamento mantido à mão.** Tabela de gatilhos dentro da persona quebra a cada skill
  instalada. Gatilho mora na `description` da skill; a persona guarda escopo, fronteira
  entre profissões e desempates.
- **Pack virar depósito da empresa.** Workflow que só faz sentido com o formato de um
  cliente é overlay, não pack.
- **Override maior que o necessário.** Escreva o encaixe, não o workflow. Workflow próprio
  só para ação que o pack não atende.
- **Contrato por nome de pasta.** Exigir que a organização acerte o nome interno de um
  workflow do pack para customizá-lo. O nome do pack é privado; a ação é o contrato público.
- **Terceirizar o piso de qualidade.** Deixar portão, contrato de saída ou chamada de
  método dentro de algo que a organização escreve. O piso é estrutura, não regra escrita.

## 3. Contrato de uma skill nova (o que "boa" significa)

**Ação, encaixe e registro** — três objetos. Ação é o trabalho nomeado que o harness sabe
fazer (a organização vê e escolhe). Encaixe é o pedaço do workflow que aceita conteúdo dela,
nomeado por resultado, não por arquivo. Registro é o texto que ela escreve num encaixe.
Nunca exposto: nome de workflow, quantos workflows atendem uma ação, moldura, método,
portão, conteúdo do pack.

**Concatenação, não substituição.** Um workflow resolvido é a moldura do sistema mais o
conteúdo da organização nos encaixes declarados. A organização nunca escreve o arquivo da
moldura; ela preenche encaixes. O pior conteúdo possível num encaixe ainda para no portão
humano, ainda produz o artefato no formato declarado, ainda pede aprovação antes de
escrever fora do rascunho.

| Parte | Dono | A organização alcança? |
|---|---|---|
| Ação, gatilho de roteamento | sistema | não |
| Métodos (L1) e providers carregados | sistema | não |
| **Portões humanos e write-gate** | sistema | **não** |
| **Contrato de saída** — o que o artefato contém, onde grava, quando para | sistema | **não** |
| **Procedimento** — como o trabalho é feito nesta empresa | organização | sim, é um encaixe |
| Formato, template, vocabulário, rigor de classificação | organização | sim, são encaixes |

A moldura concatena; o encaixe substitui **dentro dele**. Duas estruturas de documento não
se mesclam: conteúdo da organização num encaixe ocupa o lugar do padrão do pack naquele
encaixe, inteiro. O que nunca é substituído é a moldura.

Fronteira: **customizar o que existe → só encaixe.** **Criar o que não existe → workflow
próprio, livre.** Encaixe vazio → o padrão do pack vale. Arquivo da organização que não
corresponde a nenhum encaixe declarado → o build avisa (erro de configuração, não
customização silenciosa).

**Frontmatter:**

- `name` em kebab-case; `description` com **gatilhos agressivos** — frases literais que o
  usuário diria, sinônimos, variações PT/EN. É a description que faz o runtime acionar a
  skill; description vaga = skill morta.
- `acao` — obrigatória, do catálogo vigente (`system/ACOES.md`). Ação nova do sistema =
  entrada nova no catálogo, aprovada junto (`--fix` regenera a tabela; editar a tabela à
  mão não muda comportamento). Ação da organização **não** entra no catálogo do sistema.
  Workflow do pack que aceita conteúdo da organização declara também `encaixes:`. Ambos
  aceitam forma curta (só o identificador) e forma longa; **workflow do pack usa a longa** —
  sem `rotulo`, `ajuda` e `tipo` a interface não tem como desenhar o campo, e o build avisa.
- `produz` / `requer` — só para workflow que participa da esteira de artefatos. Declara o
  que o trabalho entrega e o que precisa estar aprovado antes. O vocabulário de artefatos é
  o conjunto dos `produz` declarados: requisito sem produtor ou ciclo reprova o build.
  Workflow fora da esteira (consulta, análise, operação pontual) não declara nenhum dos dois.
- **Separe moldura de encaixe ao escrever a skill.** Fica na moldura (do sistema, fora de
  qualquer encaixe): portões, write-gate, contrato de saída, métodos e providers carregados.
  Vai para encaixe: formato, template, vocabulário e o **procedimento**. Skill em que o
  portão está embutido no meio do procedimento não pode expor o encaixe `procedimento` —
  separe primeiro (o piso de qualidade é estrutura, não regra escrita).
- **Encaixe não-essencial declarado = arquivo padrão escrito no mesmo commit.** Declarar sem
  shippar o default é defeito do pack: a organização que não customiza recebe a ação rodando
  só com a moldura. O build denuncia e reprova em `--strict`. Encaixe `essencial: true` é a
  exceção — sem padrão possível (marca da empresa, gerador proprietário), a ação nasce
  indisponível e isso é estado, não defeito. `padrao` **não se declara**: o build deriva se
  o arquivo existe no pack (`pack` ou `nenhum`).
- Se usa provider: a description termina apontando a `INTERFACE.md` do domínio (ex.:
  `system/providers/backlog/INTERFACE.md`) — nunca a implementação nem o nome da
  ferramenta. Nome de workflow também não carrega fornecedor (`wiki-publish`, não
  `gitlab-wiki`).

Forma longa (pack — copie a estrutura, não o exemplo):

```yaml
acao:
  id:        documentar-requisito
  rotulo:    Documentar requisito
  descricao: gera o documento consolidado da demanda (fonte de verdade)
provider:
  dominio: backlog
  selecao: BACKLOG_PROVIDER
  capacidade: core          # mínima que a implementação ativa precisa declarar
produz:
  id:     documento-consolidado
  rotulo: Documento consolidado
requer:
  - solucao-definida
requer_condicional:
  - artefato: prototipo-validado
    quando:   demanda-tem-interface
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo:  Como fazer
    ajuda:   O passo a passo com que sua empresa faz este trabalho.
    tipo:    texto-longo      # texto-longo | arquivo | imagem | script | estrutura
  estrutura-documento:
    caminho: references/formato-md.md
    rotulo:  Estrutura do documento
    ajuda:   As seções e a ordem em que sua empresa escreve o requisito.
    tipo:    texto-longo
```

`tipo: estrutura` exige `schema: <id>`; o schema (vocabulário fechado) mora em
`system/schemas/<id>.yaml` e é do sistema — a organização preenche uma **instância**.
Elemento novo no schema é release do sistema, nunca conteúdo da organização. Prosa
continua ao lado, em encaixe separado: estrutura dirige cálculo, prosa dirige julgamento.
Instância declara `fonte` quando deriva de um documento humano — o documento continua
sendo a autoridade.

```yaml
  funil:
    caminho: references/funil.yaml
    rotulo:  Funil de priorização
    ajuda:   As etapas do funil da sua empresa.
    tipo:    estrutura
    schema:  funil-priorizacao
```

Encaixe cujo conteúdo só faz sentido sob uma capacidade do provider declara
`capacidade:`. Encaixe preenchido sob implementação que não a declara vira aviso do
build (o `.env` da instância é lido só para isso, `--env`). Sem projeto, a checagem não
roda.

Forma curta (workflow próprio da organização — rótulo derivado do identificador):

```yaml
acao: gerar-narrativa-de-requisito
```

**Corpo:**

- PT-BR correto e acentuado (`org/ORG.md` §1, quando a mudança é desta organização). UTF-8.
- Abra com a tabela de camadas. Esqueleto do corpo (pack):

```markdown
# {nome} — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` (o que nesta skill é escrita → write-gate) |
| Métodos | `system/professions/<profissão>/methods/<arquivo>.md` |
| Provider | `system/providers/<domínio>/` — **sem fallback local**. Capacidade exigida: `<cap>` |
| Formatos | encaixe `<id>` |

Portões, nesta ordem: … Nenhum é pulável pelo procedimento.

**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.
```

Persona e shim de provider omitem seções que não têm (persona não tem encaixe; shim não tem
procedimento próprio). Workflow (L2): alvo **< 100 linhas**. Estourou → método vazando
(extrair p/ L1 / `references/`) ou sintaxe de ferramenta vazando (extrair p/ provider).

- Referencia métodos e ferramentas; **nunca** copia explicação que já existe em outra skill
  ou que o modelo já sabe (anti-enciclopédia).
- Declara os **portões**: onde para para aprovação humana, o que mostra antes de escrever
  em estado externo. Toda operação de escrita externa herda o write-gate — a skill nunca o
  afrouxa, no máximo adiciona portões.
- Declara **qual regime de modo degradado** usa quando a ferramenta está
  desabilitada — os regimes vivem UMA vez na `system/providers/<domínio>/INTERFACE.md`; a skill
  só declara "sem fallback local" ou "com fallback local", nunca repete o texto.
- Sequência obrigatória SÓ onde há portão humano. Resto é sugestão ou ordem livre.
- Método default é escapável: o agente pode desviar declarando o desvio, desde que cumpra
  contrato e portões.

**Provider — o que a skill declara, o que não declara.**

1. Workflow só usa operações da `INTERFACE.md` do domínio. Nunca cita comando, endpoint ou
   variável de fornecedor.
2. Implementação (arquivo em `system/providers/<domínio>/` ou `org/providers/`) carrega a
   sintaxe concreta — procedural, com receitas em `recipes/` quando forem longas.
3. Gate e modo degradado moram na INTERFACE, uma vez. O workflow só declara o regime.
4. Frontmatter dos dois lados: a implementação diz por qual valor é ativada (`selecao`, e
   `default: true` na que atende a variável vazia) e o que suporta (`capacidades`); o
   workflow diz de qual domínio depende e o mínimo que exige (`provider: {dominio, selecao,
   capacidade}`). Capacidade ausente = indisponibilidade explícita, nunca erro de comando
   nem contorno silencioso.
5. Implementação declara o que precisa para rodar, no próprio frontmatter: `capacidades` e
   `requisitos` (`binarios`, `pacotes`, `variaveis`, `servicos`, `hosts`). Requisito que não
   é fixo (ex.: cliente de banco decidido por variável) **não se declara** — inventar um
   valor é pior que declarar a variável que o resolve.
6. Contrato é do sistema, implementação é plugável. Ferramenta interna nunca deve exigir
   fork do core.
7. Toda operação de escrita da interface é mutação → write-gate antes de executar.

**Estrutura de pastas da skill:** `{system/pack|org}/workflows/{nome}/SKILL.md` + opcionais
`references/` (material longo carregado sob demanda) e `assets/`, mais **`evals/`
obrigatório** para workflow que declara ação (§3.1). `evals/` **não é encaixe**: encaixe é
conteúdo que a moldura consome em execução; eval é teste da moldura.

### 3.1 Contrato de eval — nasce com a skill, não depois

Skill sem eval é gatilho sem prova: ninguém sabe se ela dispara no pedido real, nem se ela
rouba o pedido da vizinha. Ação nova não fica pronta sem isso.

Duas camadas, e a fronteira é uma pergunta: **o disco basta para responder?** Sim →
checagem de build (`runtime/adapters/harness.py`), nunca eval. Não (exige modelo lendo a
resposta) → caso. Eval que duplica o que o `--strict` já prova custa modelo para não
descobrir nada.

| Camada | Onde roda | O que só ela pega |
|---|---|---|
| Contrato | `build.sh --strict` | declarações que discordam em silêncio |
| Comportamento | `runtime/eval.sh`, provider `eval-runner` | gatilho que não cobre o pedido, gatilho que dispara no trabalho do vizinho, ação que inventa dado quando a ferramenta não respondeu |

**Você escreve fonte neutra, nunca artefato de runner.** Quem executa é o provider
`eval-runner` (`EVAL_RUNNER` no `.env`), e cada implementação lê a fonte do seu jeito: as
headless direto, a `claude-plugin-eval` a partir do que `render.py` gera em
`runtime/skills/`. Editar o gerado é trabalho que o próximo build apaga. A fonte declara
intenção no vocabulário do harness — nunca nome de tool, nunca formato de runner.

```yaml
# system/pack/workflows/<nome>/evals/<slug>/caso.yaml
schema: 1
tipo: roteamento              # roteamento | modo-degradado
frase: >
  a frase como o usuário realmente pede — não a paráfrase da description
atende: <ação que deve atender>        # ou `nenhuma`
confunde_com: [<ação vizinha>]         # quem não pode sequestrar a frase
motivo: >
  por que sequestrar seria caro
```

De **um** arquivo saem os dois lados: o caso positivo no workflow que atende, e o caso
negativo em **cada** workflow listado em `confunde_com` — com a mesma frase, byte a byte.
Não existe estado em que a frase do negativo deixou de ser a frase real do vizinho.

| Cobertura mínima | Como se consegue |
|---|---|
| a ação dispara | uma fonte com `atende: <sua ação>` |
| a ação **não** sequestra | alguma outra fonte com `confunde_com: <sua ação>` — o build cobra |
| para e avisa | só no regime **sem fallback local**: `tipo: modo-degradado` + `provider:` |

**`confunde_com` é a escolha que decide se o eval vale.** Nomeie a ação vizinha mais fácil
de confundir — aquela que o desempate da `description` existe para separar. O caso negativo
reusa a frase do positivo automaticamente, então uma vizinha mal escolhida não produz um
caso frouxo: produz um caso que não testa a confusão que existe.

**A fonte mora com quem atende a frase**, não com quem não pode atendê-la. É lá que ela é
mantida quando o gatilho muda; o build reprova fonte fora de lugar. A organização estende
por override de caminho (`org/workflows/<nome>/evals/<caso>/caso.yaml`).

**Fonte do pack nunca cita ação que só a organização declara** — quebra a organização
recém-criada. Precisa disso? A extensão é o override acima.

Persona é exceção: o gatilho dela é o adapter do runtime (`@nome`), não a skill. Exigir
grader de disparo seria exigir teste que não pode passar.

Capacidade ausente no runner = caso **NÃO-RODADO**, reportado por caso. Nunca conte como
passado. `./runtime/eval.sh` monta um projeto descartável como o `install.sh` monta — rodar
na raiz do harness não testa nada.

### Contrato do registro de encaixe (o arquivo que preenche um encaixe)

Vale para o padrão do pack e para o registro da organização — o encaixe é o mesmo objeto.

**Nunca entra:**

- Portão humano, write-gate, contrato de saída, chamada de método, provider. É moldura, e o
  encaixe não a alcança — escrever um portão aqui faz a organização apagá-lo ao customizar.
- Vocabulário da organização (sigla de tipo de documento, nome de label, catálogo interno) e
  valor de instância (domínio, repositório, tabela, caminho literal) — no pack, use as
  chaves de `project-config.yaml`.
- Script cognitivo (§2).

**Entra:** o mínimo genérico que a moldura não diz — a forma do trabalho que qualquer
empresa reconheceria. Alvo **15-40 linhas**; curto e vazio é melhor que longo e prescritivo.
Não passa no teste do pack → não escreva o padrão: proponha remover a declaração do encaixe,
com o custo explícito (a organização perde aquele ponto de customização).

**Frase canônica da moldura** — a skill nunca nomeia a camada de origem do arquivo nem a
precedência entre camadas (é o build que resolve). Copie literal:

> **Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
> seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
> sempre e não é substituível.

### 3.2 Contrato por tipo de artefato — o arquivo que se escreve

A §3 cobre o workflow do pack. O resto do harness tem forma própria. Não aponte para
`docs/` nem para README de adapter: o contrato está aqui. Consulte um arquivo irmão só
para copiar tom calibrado, nunca para descobrir a forma.

**Workflow do sistema** (`system/workflows/{nome}/`) — máquina, não-forkável. `acao` é
opcional (o build não cobra). Sem ação, sem `evals/`. Override em `org/` é ignorado.

**Registro de encaixe da organização** — `org/workflows/{nome-do-pack}/{caminho declarado}`.
Nunca `SKILL.md` para ação que o pack já atende (o build avisa). Arquivo fora dos
`caminho:` declarados também. Para desligar um workflow do pack: arquivo vazio
`org/workflows/{nome}/DISABLED`.

**Workflow próprio da organização** — `org/workflows/{nome}/SKILL.md` com `acao:` que **não**
está no catálogo do sistema. Forma curta basta. Entra `evals/` com cobertura de §3.1, sem
citar a ação em fonte do pack.

**Método (L1)** — `system/professions/{profissão}/methods/{nome}.md` (overlay:
`org/professions/{profissão}/methods/{nome}.md`). Três seções, nesta ordem, e nada mais:

```markdown
# {Nome do método}

## Quando usar / quando não
- Use para …
- Não use quando … → aponte o método/profissão certo.

## Barra de qualidade
O que passa / o que é erro. Exemplos curtos ✅/❌.

## Contrato de output
A cadeia do artefato (o que vem em que ordem). Numeração, nome de arquivo e seções
exatas são do workflow (L2), não daqui.
```

Zero passo a passo. Zero vocabulário de empresa. Overlay adiciona ou substitui o arquivo;
nunca reescreve L0 nem afrouxa portão.

**Profissão** — dois arquivos em `system/professions/{profissão}/` (overlay em
`org/professions/{profissão}/`):

- `PROFESSION.md`: identidade, lentes, escopo (faz / não faz), autonomia, tom. Universal —
  nada de empresa nem de projeto.
- `reasoning.md`: gatilhos de julgamento em forma *situação → considere a lente Y*. **Forma,
  não fluxo** — nada de sequência obrigatória.

**Persona** — dois arquivos no mesmo workflow (`system/pack/workflows/{nome}/`). Ação no
catálogo (`persona-produto` etc.); **sem `encaixes:`** — persona é identidade, não
procedimento. Sem tabela de roteamento: gatilho mora na `description` das skills; a persona
guarda escopo, fronteira entre profissões e **desempates**.

`SKILL.md`: `name`, `description` (único gatilho), `acao` na forma longa. Corpo: ordem de
montagem (L0 → PROFESSION+reasoning → ORG), contexto L3, desempates. Não duplica a
constituição.

`PERSONA.md` — o que o build renderiza para os runtimes. `name` e `description` **não**
aparecem aqui (saem do `SKILL.md`):

```markdown
---
mode: primary | subagent        # primary também vira slash-command
summary: <uma linha — slash-command e o agente no Codex/OpenCode>
tools: Read, Write, Bash        # opcional; restringe ferramentas (Claude Code)
model: <id>                     # opcional
---

Você é o **{papel}** do projeto.

1. Carregue a skill `{nome}` e siga-a. Não duplique regra aqui.
2. Execute na thread principal por padrão. Delegue só quando compensa, com aprovação.
3. Corpo agnóstico de runtime — nada de API de spawn, de slash-command, de caminho de
   adapter.
```

Alias extra de invocação: uma linha em `runtime/adapters/aliases.tsv`
(`alias<TAB>persona<TAB>descrição`). **Nunca edite** `runtime/claude|codex|opencode|cursor/`
à mão.

**Provider — domínio novo** — pasta `system/providers/{domínio}/`:

1. `INTERFACE.md` (contrato, uma vez): variável de seleção; tabela de operações com
   Leitura/Escrita e capacidade; **gate e modo degradado neste arquivo**, os dois regimes
   ("pare e avise" / "degrade para fonte local") escritos aqui; capacidades por
   implementação. Workflow nunca cita comando, endpoint ou variável de fornecedor.
2. Pelo menos uma implementação (`{nome}.md`) com o frontmatter abaixo. A que atende a
   variável vazia declara `default: true`.
3. Ferramenta interna: `org/providers/{domínio}/{nome}.md`, sob a mesma INTERFACE.
4. Domínio ou implementação nova documenta a variável de seleção e as de instância em
   `.env.example` (é template do harness). O `.env` preenchido do projeto é L3 e continua
   fora do escopo.

```yaml
# system/providers/{domínio}/{implementação}.md
---
selecao: gitlab                 # valor que ativa esta implementação
default: true                   # só a que atende a variável vazia
capacidades: [core, comments, wiki]
requisitos:
  binarios: [glab]
  variaveis: [GITLAB_HOST, GITLAB_URI, GITLAB_REPO, GITLAB_TOKEN]
  # buckets possíveis: binarios, pacotes, variaveis, servicos, hosts
  # requisito que não é fixo (cliente decidido por variável) NÃO se declara
---
```

Corpo da implementação: sintaxe concreta, procedural à vontade; receitas longas em
`recipes/`. Não repita gate nem modo degradado — estão na INTERFACE.

**Schema de encaixe estruturado** — `system/schemas/{id}.yaml`. Vocabulário fechado: quais
elementos existem e que forma cada um tem. Elemento novo é release do sistema. O pack ships
uma instância padrão no `caminho:` do encaixe; a organização sobrescreve a instância, nunca
o schema. Use `tipo: estrutura` só quando uma máquina precisa **calcular** (funil, mapa de
campos). Procedimento, template e formato de documento continuam `texto-longo`.

**Eval `modo-degradado`** — só workflow **sem fallback local**. Sem `confunde_com`. O
`provider:` é o domínio, não a implementação:

```yaml
schema: 1
tipo: modo-degradado
frase: >
  lista as issues abertas da sprint atual
atende: consultar-backlog
provider: backlog
```

## 4. Contrato de edição de skill existente

- **Ler o arquivo-alvo inteiro antes de propor** (`SKILL.md`, método, INTERFACE,
  implementação, PERSONA, schema) — nunca editar por trecho isolado.
- Os textos atuais foram **calibrados com uso real**: portões, desempates de gatilho e
  princípios são conteúdo valioso. Edição realoca/poda com critério (§2), não reescreve
  do zero.
- Edição é oportunidade de poda: encontrou script cognitivo no caminho → proponha cortar
  na mesma passada (item separado da proposta, para o usuário aprovar em separado).
- Mudança de comportamento invariante (gate, portão) NÃO se faz numa skill — se a demanda
  pede isso, o alvo é `system/CONSTITUTION.md` e a discussão sobe de nível. Se a demanda
  inventa camada, regra de resolução ou contrato de provider, o alvo é **esta skill** (e o
  ensaio humano em `docs/ARCHITECTURE.md` no mesmo movimento).
- **Mover bloco entre arquivos exige conferência de perda.** Extrair procedimento para um
  encaixe, ou mecânica para uma referência, é o tipo de edição que apaga conteúdo calibrado
  sem dar erro. Compare linha a linha o arquivo original contra a **união** dos arquivos
  resultantes e declare, um a um, cada delta que não é movimentação pura.
- **Mover procedimento para o encaixe não pode piorar a skill.** Enquanto o passo a passo
  vive dentro do `SKILL.md`, um padrão de pack mais fino que ele é regressão: o texto da
  moldura manda seguir o arquivo do encaixe. Separe primeiro, shippe o padrão depois.

## 5. Processo (portões desta skill)

1. **Entender e classificar** — demanda → camada(s) (§1) → arquivos-alvo.
2. **Propor** (write-gate): antes de tocar em qualquer arquivo, apresentar
   - o que será criado/editado (lista de arquivos),
   - camada de cada mudança e por quê,
   - para skill nova: frontmatter completo + esqueleto de seções,
   - para edição: diff conceitual (o que entra, o que sai, o que é poda de script).
   **Esperar aprovação.**
3. **Escrever** conforme aprovado.
4. **Propagar** (checklist §6) — propor as atualizações decorrentes, também sob aprovação.
5. **Commit é do `@committer`**, manual — esta skill nunca commita.

## 6. Checklist de propagação (skill criada/renomeada/removida)

A skill não existe isolada — o harness a referencia em 4 lugares. Verificar e propor
atualização de cada um que se aplique:

- [ ] **Build** — `./.agents/runtime/build.sh` da raiz do projeto (regenera
      `runtime/skills/`). Sem isso a skill nova não existe para nenhum runtime.
- [ ] **Persona** — só se a mudança cria **ambiguidade de escolha**: o desempate entra em
      `.../workflows/product-specialist|tech-lead|product-designer`. Gatilho normal vive na
      `description` da própria skill; não há tabela de roteamento para manter.
- [ ] **`README.md`** (raiz do harness) — único doc humano: só se a mudança altera fluxo,
      instalação, configuração ou estrutura. Skill nova comum não entra lá.
- [ ] **Persona** — só se a mudança cria ou altera uma persona: edite o
      `<workflow>/PERSONA.md` (fonte única, contrato em §3.2) e rode o build. **Nunca edite
      `runtime/claude|codex|opencode|cursor/` à mão** — são gerados e sobrescritos a cada
      build. Skill comum não tem persona. Alias novo: linha em `runtime/adapters/aliases.tsv`.
- [ ] **`.env.example`** — só se nasceu domínio ou implementação de provider (variável de
      seleção + variáveis de instância). O `.env` do projeto não se toca.
- [ ] **`system/ACOES.md`** — ação **do sistema** nova, encaixe novo, ação renomeada ou
      aposentada. É contrato público: renomear quebra as organizações que reivindicaram a
      ação — trate como mudança de API. Encaixe novo é aditivo e não quebra ninguém. Ação
      criada pela organização **não** entra no catálogo do sistema. A tabela é derivada:
      `--fix` regenera; sem a flag o build só verifica e reprova se divergiu.
- [ ] **Esta skill + ensaio humano** — só se a mudança altera a arquitetura (camada nova,
      regra de resolução, contrato de provider). O operacional entra **aqui**; o ensaio
      `docs/ARCHITECTURE.md` acompanha no mesmo movimento. Skill comum não toca nenhum dos
      dois.
- [ ] **`evals/`** — ação nova exige a cobertura de §3.1. Ação **renomeada** exige varrer
      os `atende`/`confunde_com` de TODAS as fontes, não só as dela: o nome antigo também
      aparece nas fontes das vizinhas. Ação aposentada leva a fonte junto — e libera as
      vizinhas que a citavam.
- [ ] **`provider:` no frontmatter** — workflow que depende de ferramenta declara domínio,
      variável de seleção e capacidade mínima. Sem isso o build não tem como conferir se a
      implementação ativa suporta o que a skill exige.

### Aceite — o que precisa passar antes de entregar

| Checagem | Critério |
|---|---|
| `./.agents/runtime/build.sh --strict` | sai **0**; aviso é reprovação neste modo |
| `--org <diretório vazio> --out <temporário>` | nenhum aviso de "sem padrão no pack" — é o teste da organização recém-criada |
| `--fix` | não muda `system/ACOES.md` quando nenhuma ação ou encaixe mudou |
| `org/` | nenhum arquivo novo, salvo quando a demanda era escrever registro da organização |
| Suíte de eval | a ação aparece em algum `atende` **e** em algum `confunde_com`; nenhuma fonte cita ação inexistente (o `--strict` reprova) |
| Fonte × artefato | nenhum `prompt.md` ou `graders/` versionado em `system/`ou `org/` — se apareceu, alguém editou o gerado |
| `./runtime/eval.sh --caso <slug>` | roda a camada de comportamento na implementação do `.env`. Caso reportado NÃO-RODADO → diga qual capacidade falta, nunca conte como passado |
| Mutação | trocou a `frase` por uma de outra ação e o caso ficou vermelho? Verde é caso que não testa nada |

Reprovou → conserte antes de entregar. Aceite que não vale nesta demanda se declara com o
motivo, nunca se omite.

## 7. Fora do escopo

- `project-config.yaml` / `.env` — config de instância, não é artefato do harness.
- Documentos de produto do projeto (`{caminhos.entregaveis}`, `{caminhos.historico}`, wiki) — são das skills de
  produto, não desta.
- Commit/push — `@committer`.
- Ensaio humano em `docs/` — não é pré-leitura nem fonte operacional desta skill.
