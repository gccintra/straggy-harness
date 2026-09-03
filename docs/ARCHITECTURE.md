# Arquitetura do harness

Referência normativa humana: decide **onde cada coisa mora** e **o que pode ser escrito** em cada
camada. A skill `harness-change` aplica estas regras de forma autônoma — o conhecimento
operacional mora nela, não neste arquivo. Uso no dia a dia e instalação: `../README.md`.
Quem manipula o quê em cada modo de entrega (repositório × aplicativo), e o contrato de
portabilidade entre eles: [`MODOS.md`](MODOS.md).

---

## 1. Camadas

| Camada | O que é | Onde | Quem edita |
|---|---|---|---|
| **L0** Constituição | restrição de comportamento invariante (gate, portão, honestidade, prosa, delegação) | `system/CONSTITUTION.md` | ninguém (sistema) |
| **L1** Profissão | como a profissão pensa: seleção de método, barra de qualidade, contrato de output | `system/professions/<profissão>/` | sistema (+ overlay em `org/professions/`) |
| **L2** Workflow | procedimento: gatilho, binding, portão, formato de entrega | `system/pack/workflows/` (padrão) + `org/workflows/` (organização) | organização |
| **Provider** | contrato de ferramenta + implementação | `system/providers/<domínio>/` (+ `org/providers/`) | sistema (+ implementação da organização) |
| **Adapter** | como um runtime monta tudo | `runtime/<runtime>/` | sistema |
| **L3** Instância | valores deste projeto | `project-config.yaml` + `.env` | projeto |

**Precedência:** em conflito, a camada de baixo vence. **L0 vence tudo** — inclusive
instrução de workflow editado pela organização. É isso que torna seguro deixar a L2
editável: customiza-se o *procedimento*, nunca o *comportamento*.

**Regra anti-erosão:** camada de cima **referencia** a de baixo, nunca copia. Mesma
explicação em dois arquivos = um deles está na camada errada.

**Método é default, não camisa de força:** o agente pode desviar do método (L1) ou do
caminho do workflow (L2) declarando o desvio e o porquê, desde que cumpra o contrato de
saída e não pule portão. Contrato e portão são invioláveis; método, não.

---

## 2. Teste de linha — o que pode ser prescrito

Modelo generalista escolhe sozinho a melhor forma de resolver. **Dizer "como pensar"
degrada o resultado** — e degrada mais a cada geração de modelo. Três tipos de instrução:

| Tipo | O que é | Veredito |
|---|---|---|
| **Contrato** | o que o resultado deve conter/formato/destino | **prescrever** — é requisito da empresa, o modelo não adivinha |
| **Restrição** | limite para controle humano (write-gate, um artefato por turno, parar para revisão) | **prescrever** — existe para o usuário manter controle |
| **Script cognitivo** | como raciocinar, em que ordem analisar | **cortar** |

Teste por linha: *"se o modelo ignorar isto e ainda entregar resultado que cumpre contrato
e portões, houve dano?"* Não → script, corte. Sim → contrato ou restrição, fica.

Cuidado com a **restrição disfarçada de script**: "uma fase por vez" existe para a cadência
de aprovação do usuário — é restrição, fica. A ordem interna dos sub-passos dentro da fase é
script — sai.

**Gradiente por camada:** L0 restrição pura · L1 seleção + barra + contrato (zero passo a
passo) · L2 spec de entregável + portões · **providers e motores: procedural à vontade** —
sintaxe de ferramenta é fato, não raciocínio.

Consequência: conteúdo declarativo continua valioso conforme os modelos melhoram; conteúdo
procedural vira teto. Escrever declarativo é o que faz o harness melhorar de graça a cada
upgrade de modelo.

---

## 3. Física: posse, pack e overlay

A divisão física é por **POSSE**, espelhando a fronteira sistema × cliente do produto:

```
system/          imutável pela organização (no produto: shipped read-only)
├── CONSTITUTION.md          L0
├── professions/             L1
├── providers/               contrato + implementações oficiais
├── schemas/                 vocabulário dos encaixes estruturados (§7)
├── pack/                    L2 PADRÃO — workflows genéricos + org-scaffold/
└── workflows/               máquina do harness (não-forkável)
org/             POSSE da organização — FORA do Git do harness, semeada pelo install.sh
├── ORG.md · workflows/ · professions/ · providers/
runtime/skills/  GERADO — a visão resolvida que os runtimes leem
runtime/claude|codex|opencode|cursor/  GERADO — adapters, a partir dos PERSONA.md resolvidos
```

O **pack padrão** é o que faz o harness funcionar sem nenhuma customização. A organização
não parte do zero: ela sobrepõe.

**`org/` nunca é versionada pelo harness.** O que o harness ships é o **scaffold**
(`system/pack/org-scaffold/`), copiado para `org/` pelo `install.sh` — arquivo a arquivo,
nunca sobrescrevendo o que já existe. Consequência: quem clona o harness recebe a camada
padrão, nunca a convenção de outra empresa; e cada organização versiona a própria camada
onde quiser. Overlay pré-existente é preservado na atualização do harness.

**Resolução:**

1. `system/workflows/<nome>` existe → vence sempre (máquina não é forkável; override é
   ignorado com aviso).
2. A organização reivindicou a **ação** do workflow do pack → §7 decide (soma ou
   substituição). O nome da pasta é endereço físico, não contrato.
3. Ação sem nada da organização → o pack atende.
4. `org/workflows/<nome>/DISABLED` → workflow do pack desligado nesta organização.

O **que** a organização pode reivindicar, e por onde, é a superfície pública de
customização: **§7**.

**Build.** A visão mesclada é gerada, nunca mantida à mão: `runtime/build.sh` produz
`runtime/skills/` como **cópia** (arquivo real, fora do Git) — é o que todos os runtimes
leem (`--list` imprime a origem de cada workflow). Overlay é por caminho, não symlink:
o Codex descarta `SKILL.md` que é link de arquivo, e o eval grava artefato no gerado
sem atravessar para `system/` ou `org/`. Ponteiro de descoberta é symlink de **pasta**
(`.agents/skills` e `runtime/{claude,codex,cursor}/skills` → `runtime/skills`). Assim
`org/` significa exatamente "propriedade da organização": nenhum arquivo de sistema mora
lá dentro.

**Fork barato.** Trocar o formato de um documento não copia a skill inteira: a organização
sobrescreve `references/<arquivo>.md` e herda o resto. Fork de SKILL.md inteiro congela a
organização na versão antiga do pack — só se o procedimento em si for outro.

**Teste do pack:** *"outra empresa usaria isto sem editar?"* Sim → `system/pack/`. Não →
`org/`. Três vazamentos que reprovam no teste e são fáceis de deixar passar: **vocabulário
de documento** da organização (siglas de tipo de HU/HT, nome de catálogo), **taxonomia
literal** (nome de label, título de página) e **valor de instância** (domínio, host, repo,
tabela). Nos três, o pack descreve o papel e lê o valor de `project-config.yaml`,
`org/ORG.md` ou do provider — nunca o decora.

**Pontos de extensão da organização:** `org/professions/` (profissão ou método próprio) e
`org/providers/` (implementação de ferramenta interna, sob a mesma INTERFACE). Overlay
adiciona e substitui procedimento/método; nunca reescreve L0 nem afrouxa portão.

---

## 4. Providers — abstração de ferramenta

Cada domínio (`backlog`, `canvas`, `knowledge`, `database`, `docs-output`, `eval-runner`) tem uma
`INTERFACE.md` com operações abstratas e N implementações.

1. **Workflow só usa operações da interface.** Nunca cita comando, endpoint ou variável de
   fornecedor. Nome de workflow também não carrega fornecedor (`wiki-publish`, não
   `gitlab-wiki`) — trocar de ferramenta não pode renomear skill.
2. **Implementação carrega a sintaxe concreta** — procedural, com receitas em `recipes/`
   quando forem longas.
3. **Gate e modo degradado moram na INTERFACE, uma vez.** O workflow só declara o regime
   ("com" ou "sem" fallback local); o texto não se repete.
4. **Seleção e capacidades são declaradas** — em frontmatter, dos dois lados, para o build
   poder conferir. A implementação diz por qual valor é ativada (`selecao`, e `default:
   true` na que atende a variável vazia) e o que suporta (`capacidades`); o workflow diz de
   qual domínio depende e o mínimo que exige (`provider: {dominio, selecao, capacidade}`);
   um encaixe cujo conteúdo só faz sentido sob uma capacidade declara a sua
   (`capacidade:`). Capacidade ausente = indisponibilidade explícita, nunca erro de comando
   nem contorno silencioso.
5. **Divergência entre encaixe preenchido e provider selecionado é aviso do build.** A
   organização preencher um encaixe é uma declaração; a instância apontar a variável de
   seleção é outra, e elas podem discordar — gerador de layout próprio no `org/`, variável
   ainda no conversor genérico. Sem a checagem isso não falha: sai um artefato plausível e
   errado. O build lê o `.env` do projeto só para isso (`--env`); sem projeto, não há
   instância para julgar e a checagem não roda.
6. **Contrato é do sistema, implementação é plugável** (`org/providers/`). Ferramenta
   interna nunca deve exigir fork do core.
7. **Implementação declara o que precisa para rodar**, no frontmatter do próprio arquivo:
   `capacidades` e `requisitos` (`binarios`, `pacotes`, `variaveis`, `servicos`, `hosts`).
   Cada bucket é uma ação diferente de quem prepara o ambiente — é o que permite um
   sandbox provisionar a execução sem ler prosa. Entra no manifesto (§8). Requisito que
   não é fixo (o cliente de banco, decidido por `DB_CONNECT_CMD`) **não se declara**:
   inventar um valor é pior que declarar a variável que o resolve.

Toda operação de escrita da interface é mutação → write-gate (L0) antes de executar.

---

## 5. Montagem por runtime

```
montagem = L0 (sempre, primeiro, imutável)
         + PROFESSION.md + reasoning.md da profissão ativa      (L1 + overlay org)
         + methods/ carregados SOB DEMANDA                      (L1 + overlay org)
         + workflows resolvidos, carregados por gatilho         (L2: pack ∪ org)
         + providers ativos conforme a configuração             (L3 decide quais)
         + project-config + contexto do projeto                 (L3)
```

| Runtime | Como monta |
|---|---|
| **Claude Code** | L0 + persona via `runtime/claude/agents\|commands`; workflows em `runtime/skills/` (`.claude/skills` → a mesma árvore) |
| **Codex** | L0 + persona via `runtime/codex/agents/*.toml`; workflows em `.agents/skills` (pasta-link para `runtime/skills/`, arquivos reais) |
| **OpenCode** | idem via `runtime/opencode/opencode.json` |
| **Cursor CLI** (`agent`) | L0 + persona via `runtime/cursor/rules/*.mdc`; pasta `.cursor` é symlink de `runtime/cursor/` como os outros runtimes, ou (se o IDE já criou `.cursor/`) só as rules são plantadas. Workflows em `.cursor/skills` → a mesma árvore. Headless: o mesmo adapter, `agent -p` — runner de eval quando o restante estiver no ar |
| **Produto (Hub)** | L0+L1 no system prompt (usuário não vê nem edita); pack servido como base e overlay da organização editável na UI; providers = integrações conectadas; L3 = formulário do projeto |

**Adapter é gerado, nunca mantido à mão.** A fonte única de uma persona é
`<workflow>/PERSONA.md` (modo, resumo, ferramentas, corpo agnóstico de runtime) mais a
`description` do `SKILL.md` do mesmo workflow — que continua sendo o único lugar do
gatilho de roteamento. `runtime/build.sh` renderiza **todos** os runtimes a partir disso
(contrato do `PERSONA.md`: `runtime/adapters/README.md`). Persona nova = um arquivo, não
um por runtime; e o `PERSONA.md` é sobrescrevível pela organização como qualquer outro
arquivo do overlay.

Princípios de portabilidade: **física única** (cada arquivo num lugar só, runtimes
referenciam) · **carregamento progressivo** (L0 e profissão são pequenos e sempre
presentes; método e workflow entram por gatilho) · **nada de API de runtime dentro de
skill, método ou provider**.

No produto, o que hoje é texto vira mecanismo: write-gate → UI de aprovação com preview;
portão do pipeline → estado do artefato com trilha de quem aprovou; roteamento → contexto
de tela + intenção. L0 e L1 permanecem read-only, versionados por release.

---

## 6. Anti-padrões (o que faz a arquitetura apodrecer)

- **L1 virar enciclopédia.** Se o modelo já sabe a teoria, não escreva. Método carrega
  seleção, barra de qualidade e contrato — nada mais.
- **Sobre-prescrição.** Script cognitivo degrada hoje e vira teto amanhã (§2). Na dúvida,
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
  só para ação que o pack não atende (§7).
- **Contrato por nome de pasta.** Exigir que a organização acerte o nome interno de um
  workflow do pack para customizá-lo. Frágil no repositório, impossível no aplicativo — o
  nome do pack é privado (§7).
- **Terceirizar o piso de qualidade.** Deixar portão, contrato de saída ou chamada de
  método dentro de algo que a organização escreve. A resposta passa a depender de quem
  configurou; o encaixe existe exatamente para isso não acontecer (§7).

---

## 7. Ações e encaixes — a superfície pública de customização

§3 define **onde** o conteúdo da organização mora. Esta seção define **o que ela pode
customizar e por onde** — sem conhecer a estrutura interna do pack e sem poder degradar o
que o sistema garante.

Dois problemas ao mesmo tempo. O override por arquivo (§3) só funciona para quem já sabe o
nome do workflow e do arquivo dentro dele — no aplicativo a organização não sabe, e **não
deve saber**. E substituir um workflow inteiro entrega junto os portões e o contrato de
saída: a qualidade da resposta passaria a depender de quem configurou. Nenhuma das duas
coisas é aceitável.

### O princípio: concatenação, não substituição

Um workflow resolvido é **a moldura do sistema mais o conteúdo da organização nos encaixes
declarados**. A organização nunca escreve o arquivo; ela preenche encaixes.

| Parte | Dono | A organização alcança? |
|---|---|---|
| Ação, gatilho de roteamento | sistema | não |
| Métodos (L1) e providers carregados | sistema | não |
| **Portões humanos e write-gate** | sistema | **não** |
| **Contrato de saída** — o que o artefato contém, onde grava, quando para | sistema | **não** |
| **Procedimento** — como o trabalho é feito nesta empresa | organização | sim, é um encaixe |
| Formato, template, vocabulário, rigor de classificação | organização | sim, são encaixes |

Consequência: o pior conteúdo possível num encaixe ainda para no portão humano, ainda
produz o artefato no formato declarado, ainda pede aprovação antes de escrever fora do
rascunho. **O piso de qualidade é estrutura, não regra escrita** — não dá para desrespeitar
porque não dá para alcançar.

**A moldura concatena; o encaixe substitui dentro dele.** Duas estruturas de documento não
se mesclam: conteúdo da organização num encaixe ocupa o lugar do padrão do pack naquele
encaixe, inteiro. O que nunca é substituído é a moldura.

### Três objetos

| Objeto | Quem define | O que é | A organização vê? |
|---|---|---|---|
| **Ação** | sistema | trabalho nomeado que o harness sabe fazer ("documentar requisito", "criar tela") | **sim** — é a lista da qual ela escolhe |
| **Encaixe** | sistema, por ação | pedaço do workflow que aceita conteúdo dela (procedimento, estrutura do documento, regras de classificação) | **sim** — nomeado por resultado, não por arquivo |
| **Registro** | organização | o texto que ela escreve para um encaixe | **é o que ela cria** |

Nunca exposto: nome de workflow, quantos workflows atendem uma ação, moldura, método,
portão, conteúdo do pack.

### A única exceção: ação nova

Quando a organização quer algo que o harness **não faz**, ela escreve o workflow inteiro e
declara uma ação nova. É livre — não existe padrão para degradar, ela está somando, não
piorando.

Fronteira, então:

- **Customizar o que existe** → só encaixe. Impossível degradar.
- **Criar o que não existe** → workflow próprio, livre.

Não existe substituir um workflow do pack. Precisa mudar o procedimento? É o encaixe
`procedimento`. Precisa mudar portão ou contrato de saída? A resposta é não — ou vira ação
nova do sistema.

### Declaração

Toda declaração aceita **forma curta** (só o identificador) e **forma longa** (mapa com o
que uma interface precisa para desenhar o campo). A curta basta no repositório, onde
ninguém precisa de rótulo; a longa é o que alimenta o Hub (`HUB.md` §3.2).

```yaml
# workflow do pack: a ação que atende e os encaixes que expõe
acao:
  id:        documentar-requisito
  rotulo:    Documentar requisito
  descricao: gera o documento consolidado da demanda (fonte de verdade)
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo:  Como fazer
    ajuda:   O passo a passo com que sua empresa faz este trabalho.
    tipo:    texto-longo          # texto-longo | arquivo | imagem | script | estrutura
  estrutura-documento:
    caminho: references/formato-md.md
    rotulo:  Estrutura do documento
    ajuda:   As seções e a ordem em que sua empresa escreve o requisito.
    tipo:    texto-longo
```

### Encaixe estruturado

`tipo: estrutura` exige `schema: <id>`, e o schema — o vocabulário fechado daquele encaixe —
é do sistema (`system/schemas/<id>.yaml`); a organização preenche uma **instância** dele.

Existe porque encaixe de texto livre é relido pelo modelo a cada execução, e parte do
conteúdo da organização alimenta **cálculo determinístico** (o funil de priorização, um mapa
de campos). Aí texto livre não é flexibilidade, é fragilidade: não valida, não pré-visualiza
impacto, não versiona.

| Regra | Consequência |
|---|---|
| **Vocabulário fechado** — o schema enumera os elementos aceitos e a forma de cada um | elemento novo é release do sistema, nunca conteúdo da organização. É o que permite à interface desenhar um construtor em vez de uma textarea, e ao motor calcular sem interpretar prosa |
| **Prosa continua ao lado**, em encaixe separado | estrutura dirige cálculo, prosa dirige julgamento — a exceção que nenhum schema segura |
| **Padrão do pack vale igual** | `padrao` é derivado do mesmo caminho; instância vazia cai no preset do sistema |
| **Instância declara a fonte** quando deriva de um documento humano | o documento continua sendo a autoridade; a instância é a projeção que a máquina lê, carimbada com a versão de onde saiu |

No repositório a instância é o arquivo declarado em `caminho`; no aplicativo é o construtor,
e o caminho é gerado. Forma da tela e trilhos de edição: `HUB.md` §3.4.

```yaml
# workflow próprio da organização — só para ação que o pack não atende
acao: gerar-narrativa-de-requisito     # forma curta: rótulo derivado do identificador
```

Dois campos completam o quadro, e **nenhum dos dois obriga a organização a preencher** —
degradação limpa continua valendo:

| Campo | Quem escreve | O que significa |
|---|---|---|
| `padrao` | **ninguém — é derivado** | o build checa se o arquivo do encaixe existe no pack: `pack` (há padrão do sistema) ou `nenhum`. Não é declarável, então não pode mentir |
| `essencial: true` | o sistema, no workflow do pack | sem conteúdo neste encaixe **a ação não roda** — é dependência da ação, não obrigação de quem configura. Só para o que o sistema não tem como ter padrão (a marca da empresa, um gerador proprietário) |
| `capacidade: <nome>` | o sistema, no workflow do pack | o conteúdo deste encaixe só produz efeito se a implementação ativa do provider suportar essa capacidade (§4.5). Encaixe preenchido sob implementação que não a declara vira aviso do build — é o caso do gerador de layout com a variável apontando o conversor genérico |

Encaixe comum sem padrão no pack e sem conteúdo da organização vira **aviso do build** — é
defeito do pack, que prometeu um padrão e não ships. Encaixe `essencial` vazio não é
defeito: é **estado**, e o manifesto marca a ação como indisponível até alguém preencher.
Organização recém-criada não pode reprovar um build por ainda não ter configurado nada.

É assim que "encaixe vazio → o padrão do pack vale" para de ser promessa e vira checagem.

### A esteira: o que a ação produz e o que ela exige

Workflow que participa do pipeline declara o artefato que entrega e o que precisa existir
antes. É a mesma sequência que hoje vive em prosa, escrita como grafo:

```yaml
produz:
  id:     documento-consolidado
  rotulo: Documento consolidado
requer:
  - solucao-definida
requer_condicional:
  - artefato: prototipo-validado
    quando:   demanda-tem-interface     # demanda sem interface pula o protótipo
```

`produz` é **o artefato que a ação entrega**; quem o marca aprovado é o portão humano do
workflow, não o workflow. Essa é exatamente a transformação que o produto faz: o portão
vira estado do artefato, e o passo seguinte fica inalcançável até a aprovação existir
(`HUB.md` §4.2).

O vocabulário de artefatos **não é uma lista mantida à parte**: é o conjunto dos `produz`
declarados. Um `requer` que não casa com nenhum `produz` reprova o build, e ciclo também —
então errar o nome é erro de build, não comportamento estranho em produção. As condições
seguem o mesmo caminho: o manifesto publica as que aparecem, e quem avalia cada uma é o
produto, não o harness.

Workflow fora da esteira (consulta, análise, operação pontual) não declara nenhum dos três.

No repositório, o encaixe é um caminho: a organização escreve em
`org/workflows/<nome>/<caminho declarado>`. No aplicativo, o encaixe é uma escolha na
interface e o caminho é gerado — ela nunca digita nome de arquivo nem de workflow.

O build avisa quando um arquivo da organização não corresponde a nenhum encaixe declarado:
conteúdo fora de encaixe é erro de configuração, não customização silenciosa.

`org/workflows/<nome>/DISABLED` continua desligando um workflow do pack — desligar não
degrada, só remove.

**Degradação limpa:** encaixe vazio → o padrão do pack vale. Ação que a organização
desconhece → continua funcionando.

### Por que a ação é o contrato público

É o único recorte que sobrevive à evolução do pack. Quebrar um workflow em três, renomear,
fundir dois — nada quebra do lado da organização, desde que a ação continue existindo. O
nome do workflow é implementação; a ação é a interface.

Vale igual nos dois modos (`MODOS.md` §3): no repositório corrige a fragilidade de acertar
o nome da pasta; no aplicativo é o que torna a customização possível sem abrir o core nem
terceirizar a qualidade.

---

## 8. O manifesto — o catálogo como dado

§7 define a superfície pública em prosa. O **manifesto** é essa superfície em formato que
uma máquina consome: `<runtime>/manifest.json`, gerado pelo `build.sh` a partir do
frontmatter das skills. É por ele que uma interface descobre o que o harness sabe fazer,
sem ler uma skill sequer.

**É contrato, não relatório.** Consequências que valem como regra:

| Propriedade | Por quê |
|---|---|
| `schema` versionado | quem consome pina o número; mudança incompatível incrementa, campo novo não |
| **determinístico** | sem timestamp, listas ordenadas — diff no manifesto significa mudança real de comportamento |
| **derivado, nunca escrito** | o que existe no manifesto existe porque uma skill declarou; não há segunda fonte |
| bloco `interno` isolado | nome de workflow, origem e caminho de arquivo são implementação — a API do Hub corta este bloco antes de servir (`MODOS.md` §7, "core exposto") |

Conteúdo: **ações** (com rótulo, gatilho, encaixes e o que a ação produz/exige),
**personas**, **artefatos** da esteira, **condições** que o produto precisa saber avaliar e
**providers** com seus requisitos de execução.

Cada ação carrega também a **ficha** que a torna legível sem abrir a skill: `objetivo` (o
problema que resolve), `entrega` (o que existe no mundo quando termina) e `portoes` (onde a
execução para e espera decisão humana). São declarações do sistema, fora de qualquer encaixe
— a organização não as alcança. O build reprova ação de trabalho que não as declare; persona
declara só `objetivo`, porque é identidade e não produz artefato.

Delas sai [`WORKFLOWS.md`](WORKFLOWS.md), a referência de manutenção: uma ficha por
workflow, gerada pelo mesmo mecanismo de bloco marcado do `ACOES.md`. O catálogo é o que a
organização **contrata**; a ficha é o que quem **edita o harness** precisa saber. Documentar
por derivação é o que impede a documentação de envelhecer — divergir do frontmatter reprova
o build.

### Pontos de troca do build

A resolução (§3) é a mesma nos dois modos; o que muda é de onde vêm as entradas e para
onde vai a saída. Tudo o que varia é parâmetro, nada é deduzido do disco:

| Ponto | Flag / variável | Para quê |
|---|---|---|
| Camada da organização | `--org` · `HARNESS_ORG_DIR` | repositório próprio, ou pasta materializada pelo produto (`MODOS.md` §6) |
| Saída gerada | `--out` · `HARNESS_OUT_DIR` | no produto o `system/` chega read-only por release — o build não escreve dentro dele |
| Referência às skills | `SKILLS_REF` | como o runtime aponta para a visão resolvida, que no produto não mora em `.agents/` |
| `.env` do projeto | `--env` · `HARNESS_ENV_FILE` | a única leitura de instância que o build faz: conferir se o provider selecionado suporta o que a organização preencheu (§4.5). Ausente → a checagem não roda |
| Rigor | `--strict` | aviso vira reprovação (código 3): é o modo de CI |
| Blocos derivados | `--fix` | regenera os blocos gerados do `ACOES.md` e do `docs/WORKFLOWS.md`; **sem a flag, o build apenas verifica** e reprova se divergiu |

Verificar por padrão e só reescrever sob pedido é o que permite rodar o build inteiro com
`system/` read-only — e ao mesmo tempo garante que o catálogo público não divirja do
frontmatter.

---

## 9. Evals — o que o build não consegue provar

§8 fecha o que o harness sabe **declarar**. Esta seção trata do que ele precisa
**provar**, e a divisão importa porque as duas coisas têm custo e alcance opostos.

### Duas camadas, e a fronteira entre elas

| Camada | Onde roda | Custo | O que só ela pega |
|---|---|---|---|
| **Contrato** | `build.sh` (`--strict` em CI) | zero, determinístico | duas declarações que discordam em silêncio: encaixe preenchido sob provider que não suporta a capacidade, grader apontando skill renomeada, caso sem grader, encaixe essencial vazio |
| **Comportamento** | `runtime/eval.sh`, provider `eval-runner` | modelo por caso | gatilho que não cobre como o usuário pede, gatilho que dispara no trabalho do vizinho, ação que inventa dado quando a ferramenta não respondeu |

A fronteira é uma pergunta: **o disco basta para responder?** Se sim, é contrato, e vira
checagem do build — nunca eval. Eval que testa o que o build já prova é caro, lento e
duplicado. O caminho contrário também vale: o que exige um modelo lendo a resposta não vira
regra de build, vira caso.

### Por que o gatilho precisa de contraprova

Uma suíte que só afirma "esta frase aciona a skill" mede metade. O modo de falha caro é o
oposto — a skill dispara no pedido do vizinho, começa o trabalho errado, e o certo não
acontece. Por isso toda ação declara **os dois**: um caso que dispara e um caso que **não**
pode disparar, com a frase da ação vizinha mais próxima. O build reprova quem tem só um dos
lados.

Persona é exceção: o gatilho dela é o adapter do runtime (`@nome`), não a tool `Skill`.
Exigir grader de disparo seria exigir teste que não pode passar.

### Fonte neutra, artefato por runtime

O harness serve Claude, Codex, opencode e Cursor CLI (§5). Um caso escrito no formato de um runner
serve **um** runtime — e `tool_used` com `tool: Skill` é a tool da Claude Code, que os
outros não têm. Então eval segue exatamente o caminho que persona já segue:

```
<workflow>/evals/<caso>/caso.yaml      fonte, versionada, neutra
  └─ render.py
       ├─ runtime/skills/<n>/evals/<caso>/prompt.md + graders/   (claude)
       ├─ codex     — sem runner de eval; o seam existe, a implementação não
       ├─ opencode  — idem
       └─ cursor    — `agent -p`; o seam existe, a implementação entra quando o restante estiver no ar
```

A fonte declara **intenção no vocabulário do harness** — que ação deve atender a frase,
quem não pode sequestrá-la, qual provider ausente deve travar a ação. Nunca nome de tool,
nunca formato de runner.

```yaml
schema: 1
tipo: roteamento              # roteamento | modo-degradado
frase: >
  gera o docx da #412 — o md consolidado já foi revisado
atende: gerar-documento-final          # ou `nenhuma`: frase que ninguém deve atender
confunde_com:
  - documentar-requisito               # quem não pode sequestrar esta frase
motivo: >
  O `.md` já existe e foi revisado; reabrir a consolidação descarta a revisão humana.
```

### O pareamento é estrutural, não convenção

De **um** arquivo saem os dois lados: o caso positivo no workflow que atende, e o caso
negativo em **cada** workflow listado em `confunde_com` — com a mesma frase, byte a byte.

Isso existe porque escrever os dois à mão tem um modo de falha invisível: a frase da
contraprova vira uma paráfrase distante, o caso passa sozinho, e ninguém descobre que a
discriminação nunca foi testada. Saindo do mesmo arquivo, não existe estado em que a frase
do negativo deixou de ser a frase real do vizinho.

O build fecha o resto: toda ação precisa aparecer em algum `atende` **e** em algum
`confunde_com`. Faltar o segundo é a metade que mede pouco.

### Posse

Mesma regra do resto (§3): a fonte mora no workflow que **atende** a frase — é lá que ela é
mantida quando o gatilho muda. A organização estende por override de caminho
(`org/workflows/<nome>/evals/<caso>/caso.yaml`).

Uma consequência que o build cobra: **fonte do pack não cita ação que só a organização
declara.** Citar quebra a organização recém-criada, que reprova por conteúdo que nunca teve
— e é o que o aceite de `--org <vazio>` existe para pegar.

`evals/` **não é encaixe**: encaixe é conteúdo que a moldura consome em execução; eval é
teste da moldura, e some do artefato.

### O runner é um provider, não uma ferramenta

A camada de contrato é do build. A de comportamento precisa de um runtime executando de
verdade — e aí vale a mesma regra de §4, pelo mesmo motivo: **um contrato, N
implementações**. Amarrar a suíte ao runner de um runtime faz a prova valer só lá, e o
harness serve N runtimes.

`system/providers/eval-runner/`, selecionado por `EVAL_RUNNER`. O que cada um consegue não é
preferência, é o que o runtime expõe:

| | `roteamento-skill` | `julgamento` | `ablacao` · `fixture` |
|---|---|---|---|
| `claude-headless` (default) | **sim** | sim | não |
| `codex-exec` | não | sim | não |
| `opencode-run` | não | sim | não |
| `claude-plugin-eval` | sim | sim | sim |

`roteamento-skill` exige o runtime **dizer qual skill engajou**. A Claude emite a chamada no
`stream-json`; o codex não tem o conceito (o adapter dele ships persona, invocada
explicitamente); o opencode roteia por persona e imprime qual — roteamento de outro objeto.

Capacidade ausente = caso **NÃO-RODADO**, reportado por caso. Nunca verde: suíte que
esconde o que não rodou mente sobre a própria cobertura.

`claude plugin eval` é **uma implementação**, não o desenho — a que tem ablação, fixture e
juiz por votação, e a que está em early access. As implementações headless leem a fonte
neutra direto; só ela consome o artefato que `render.py` gera.

### Como rodar

```bash
./runtime/build.sh --strict                    # contrato — determinístico, de graça
./runtime/eval.sh                              # comportamento — implementação do .env
./runtime/eval.sh --runner codex-exec --tipo modo-degradado
```

Toda implementação roda num **projeto descartável montado como o `install.sh` monta** —
`.agents/` apontando para o harness, mais os symlinks de runtime. Rodar na raiz do harness
não testa nada: lá as skills não estão instaladas, e o caso reprova por motivo errado.

O `.env` do projeto real **não** é copiado para lá: a ausência de configuração é justamente
o cenário dos casos `modo-degradado`.

Uma execução por **frase**, não por caso: a fonte declara `atende` e `confunde_com` da mesma
frase, e um run responde as duas coisas.

Escopo: `--skill <nome>` roda uma skill só, sem escopo roda o harness inteiro; `--tipo`
separa roteamento de modo degradado.

### O relatório

Toda corrida grava `runtime/evals/<carimbo>/` com `resultado.json` e `report.html`. O HTML é
**visão** do JSON, não segunda fonte (§8): o JSON é o que CI e diff consomem, o HTML é o que
gente lê.

O que ele mostra, e por quê: taxa dos casos **executados** como figura-herói; passou /
falhou / **não rodou** como estados separados; e a **cobertura do gatilho** — quantas ações
têm caso de disparo, quantas têm contraprova, quantas têm os dois. Essa última existe porque
o resultado mais enganoso possível é suíte verde com cobertura parcial: tudo passa, e metade
do risco nunca foi testada.

Caso não-rodado **nunca** entra na taxa como passado. Uma taxa que engole o que não rodou
mente sobre a própria cobertura, que é exatamente o que a suíte deveria denunciar.

### Como saber se a suíte presta

Suíte verde não prova nada por si. Em ordem de força:

| Prova | Como | O que denuncia |
|---|---|---|
| **Mutação** | troque a `frase` da fonte por uma de outra ação e rode | caso que continua verde não testa nada — é a única prova que vale |
| **Ablação** | `EVAL_RUNNER=claude-plugin-eval`, `--ablation with-without` | braço sem o harness com a mesma nota: o caso mede o modelo, não a skill |
| **Pareamento** | estrutural, pela geração | já garantido: a contraprova é a frase real do vizinho |
