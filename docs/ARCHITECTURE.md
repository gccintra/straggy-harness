# Arquitetura do harness

Referência normativa: decide **onde cada coisa mora** e **o que pode ser escrito** em cada
camada. Consultada pela skill `skill-creator` antes de qualquer alteração no harness. Uso
no dia a dia e instalação: `../README.md`. Quem manipula o quê em cada modo de entrega
(repositório × aplicativo), e o contrato de portabilidade entre eles: [`MODOS.md`](MODOS.md).

---

## 1. Camadas

| Camada | O que é | Onde | Quem edita |
|---|---|---|---|
| **L0** Constituição | restrição de comportamento invariante (gate, portão, honestidade, delegação) | `system/CONSTITUTION.md` | ninguém (sistema) |
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
├── pack/                    L2 PADRÃO — workflows genéricos + org-scaffold/
└── workflows/               máquina do harness (não-forkável)
org/             POSSE da organização — FORA do Git do harness, semeada pelo install.sh
├── ORG.md · workflows/ · professions/ · providers/
runtime/skills/  GERADO — a visão resolvida que os runtimes leem
runtime/claude|codex|opencode/  GERADO — adapters, a partir dos PERSONA.md resolvidos
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
`runtime/skills/`, fora do Git — é o que todos os runtimes leem (`--list` imprime a origem
de cada workflow). Assim `org/` significa exatamente "propriedade da organização": nenhum
arquivo de sistema mora lá dentro.

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

Cada domínio (`backlog`, `canvas`, `knowledge`, `database`, `docs-output`) tem uma
`INTERFACE.md` com operações abstratas e N implementações.

1. **Workflow só usa operações da interface.** Nunca cita comando, endpoint ou variável de
   fornecedor. Nome de workflow também não carrega fornecedor (`wiki-publish`, não
   `gitlab-wiki`) — trocar de ferramenta não pode renomear skill.
2. **Implementação carrega a sintaxe concreta** — procedural, com receitas em `recipes/`
   quando forem longas.
3. **Gate e modo degradado moram na INTERFACE, uma vez.** O workflow só declara o regime
   ("com" ou "sem" fallback local); o texto não se repete.
4. **Seleção e capacidades são declaradas.** A instância diz qual provider está ativo
   (ex.: `BACKLOG_PROVIDER`); cada implementação declara as capacidades que suporta; o
   workflow declara a que exige. Capacidade ausente = indisponibilidade explícita, nunca
   erro de comando nem contorno silencioso.
5. **Contrato é do sistema, implementação é plugável** (`org/providers/`). Ferramenta
   interna nunca deve exigir fork do core.
6. **Implementação declara o que precisa para rodar**, no frontmatter do próprio arquivo:
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
| **Claude Code** | L0 + persona via `runtime/claude/agents\|commands`; workflows descobertos em `runtime/skills/` |
| **Codex** | idem via `runtime/codex/agents/*.toml`, apontando para `runtime/skills/` |
| **OpenCode** | idem via `runtime/opencode/opencode.json` |
| **Produto (Hub)** | L0+L1 no system prompt (usuário não vê nem edita); pack servido como base e overlay da organização editável na UI; providers = integrações conectadas; L3 = formulário do projeto |

**Adapter é gerado, nunca mantido à mão.** A fonte única de uma persona é
`<workflow>/PERSONA.md` (modo, resumo, ferramentas, corpo agnóstico de runtime) mais a
`description` do `SKILL.md` do mesmo workflow — que continua sendo o único lugar do
gatilho de roteamento. `runtime/build.sh` renderiza os três runtimes a partir disso
(contrato do `PERSONA.md`: `runtime/adapters/README.md`). Persona nova = um arquivo, não
três; e o `PERSONA.md` é sobrescrevível pela organização como qualquer outro arquivo do
overlay.

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
    tipo:    texto-longo          # texto-longo | arquivo | imagem | script
  estrutura-documento:
    caminho: references/formato-md.md
    rotulo:  Estrutura do documento
    ajuda:   As seções e a ordem em que sua empresa escreve o requisito.
    tipo:    texto-longo
```

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

### Pontos de troca do build

A resolução (§3) é a mesma nos dois modos; o que muda é de onde vêm as entradas e para
onde vai a saída. Tudo o que varia é parâmetro, nada é deduzido do disco:

| Ponto | Flag / variável | Para quê |
|---|---|---|
| Camada da organização | `--org` · `HARNESS_ORG_DIR` | repositório próprio, ou pasta materializada pelo produto (`MODOS.md` §6) |
| Saída gerada | `--out` · `HARNESS_OUT_DIR` | no produto o `system/` chega read-only por release — o build não escreve dentro dele |
| Referência às skills | `SKILLS_REF` | como o runtime aponta para a visão resolvida, que no produto não mora em `.agents/` |
| Rigor | `--strict` | aviso vira reprovação (código 3): é o modo de CI |
| Catálogo derivado | `--fix` | regenera o bloco gerado do `ACOES.md`; **sem a flag, o build apenas verifica** e reprova se divergiu |

Verificar por padrão e só reescrever sob pedido é o que permite rodar o build inteiro com
`system/` read-only — e ao mesmo tempo garante que o catálogo público não divirja do
frontmatter.
