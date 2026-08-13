---
name: skill-creator
description: >
  Cria e edita skills e demais artefatos do próprio harness (workflows, métodos, providers,
  personas, regras de engajamento) seguindo a arquitetura de camadas definida em
  docs/ARCHITECTURE.md. Use SEMPRE que o usuário pedir para criar uma skill nova,
  editar/refatorar uma skill existente, adicionar um workflow, extrair um método, mudar a
  CONSTITUTION/ORG, mexer na estrutura do harness ou "melhorar o harness" — qualquer alteração em
  arquivo dentro de .agents/ que não seja config de instância (project-config.yaml, .env).
  Garante que toda mudança respeite: camada certa, prescrever resultado e não raciocínio,
  referência em vez de cópia, portões humanos preservados.
---

# skill-creator — criação e edição de artefatos do harness

Meta-skill: governa como o próprio harness evolui. Toda alteração em `.agents/` passa por
aqui para nascer na camada certa e no estilo certo.

**LEITURA OBRIGATÓRIA antes de qualquer proposta** (nesta ordem, sempre nesta sessão):

1. `.agents/docs/ARCHITECTURE.md` — camadas, teste de linha (§2), pack + overlay (§3),
   providers (§4), anti-padrões (§6), **ações e encaixes (§7)**.
2. `.agents/system/CONSTITUTION.md` — write-gate, autonomia (§3), brevidade (+ `org/ORG.md`).
3. `.agents/system/ACOES.md` — catálogo de ações e encaixes. Toda skill declara uma ação;
   customização da organização entra por encaixe antes de virar workflow próprio.

Este arquivo não repete o conteúdo deles — só o aplica. Se este SKILL.md e o
`ARCHITECTURE.md` divergirem, **o `ARCHITECTURE.md` vence** (é a fonte de verdade da
arquitetura; atualize lá primeiro, aqui depois).

---

## 1. Classificar ANTES de escrever — em que camada a mudança mora?

Primeira pergunta de toda demanda. Errar a camada aqui é o que erode a arquitetura.

| A mudança é... | Camada | Destino físico |
|---|---|---|
| Comportamento que vale p/ qualquer profissão/empresa (gate, honestidade, delegação) | L0 | `system/CONSTITUTION.md` |
| Conhecimento de PM/Designer/Tech Lead válido em qualquer empresa (método, critério de seleção, barra de qualidade) | L1 | `system/professions/<profissão>/methods/` ou `reasoning.md` |
| Convenção transversal da organização (língua, nomenclatura, papéis) | L2 | `org/ORG.md` (scaffold em `system/pack/org-scaffold/`) |
| Procedimento que serve a **qualquer** empresa (gatilho, binding, portão, formato genérico) | L2 pack | `system/pack/workflows/{nome}/SKILL.md` |
| Qualquer customização de ação **existente** — formato, template, vocabulário, **procedimento** | L2 org | **encaixe** declarado pelo pack: `org/workflows/{nome}/{caminho do encaixe}`. Nunca substitui o workflow |
| Ação que o harness **não faz** | L2 org | `org/workflows/{nome}/SKILL.md` com `acao:` nova + entrada em `system/ACOES.md` |
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

**Nota de implementação:** a divisão física é por POSSE — `system/` (imutável: L0 + L1 +
providers + pack padrão + máquina) × `org/` (editável/forkável: `ORG.md` + `workflows/` +
`professions/` + `providers/`). A descoberta é **gerada**: `runtime/build.sh` resolve
`system/workflows` ∪ `system/pack/workflows` ∪ `org/workflows` (máquina vence; org
sobrescreve o pack arquivo a arquivo; `DISABLED` desliga um workflow do pack) em
`runtime/skills/`, que é o que todos os runtimes leem. Nunca crie symlink de skill à mão —
rode o build.

**Teste do pack:** *"outra empresa usaria isto sem editar?"* Sim → `system/pack/`.
Não → `org/`. Só o formato muda → override do menor arquivo (`references/…`), nunca cópia
do SKILL.md inteiro — fork de arquivo inteiro congela a organização na versão antiga do
pack.

## 2. O teste de linha — o que pode ser prescrito (§2 do ARCHITECTURE)

Toda linha escrita numa skill é classificada:

- **Contrato** (o que o resultado deve conter/formato/destino) → prescrever.
- **Restrição** (limite p/ controle humano: write-gate, "um artefato por turno", parar p/
  revisão) → prescrever.
- **Script cognitivo** (como raciocinar, em que ordem analisar) → **não escrever**.

Teste: *"se o modelo ignorar esta linha e o resultado ainda cumprir contrato e portões,
houve dano?"* Não → é script, corte. Na dúvida entre prescrever e confiar no modelo:
confie no modelo e endureça o contrato de saída.

Atenção ao inverso: restrição disfarçada de script não pode ser podada — se a sequência
existe para cadência de aprovação do usuário, é restrição e fica.

## 3. Contrato de uma skill nova (o que "boa" significa)

**Frontmatter:**

- `name` em kebab-case; `description` com **gatilhos agressivos** — frases literais que o
  usuário diria, sinônimos, variações PT/EN. É a description que faz o runtime acionar a
  skill; description vaga = skill morta.
- `acao` — obrigatória, do catálogo `system/ACOES.md`. Ação nova = entrada nova no catálogo,
  aprovada junto. Workflow do pack que aceita conteúdo da organização declara também
  `encaixes:`. Ambos aceitam forma curta (só o identificador) e forma longa; **workflow do
  pack usa a longa** — sem `rotulo`, `ajuda` e `tipo` a interface não tem como desenhar o
  campo, e o build avisa. Schema completo, incluindo `essencial` e o `padrao` derivado:
  `docs/ARCHITECTURE.md` §7.
- `produz` / `requer` — só para workflow que participa da esteira de artefatos. Declara o
  que o trabalho entrega e o que precisa estar aprovado antes (`docs/ARCHITECTURE.md` §7).
  O build reprova requisito sem produtor e ciclo.
- **Separe moldura de encaixe ao escrever a skill.** Fica na moldura (do sistema, fora de
  qualquer encaixe): portões, write-gate, contrato de saída, métodos e providers carregados.
  Vai para encaixe: formato, template, vocabulário e o **procedimento**. Skill em que o
  portão está embutido no meio do procedimento não pode expor o encaixe `procedimento` —
  separe primeiro (§7: o piso de qualidade é estrutura, não regra escrita).
- **Encaixe não-essencial declarado = arquivo padrão escrito no mesmo commit.** Declarar sem
  shippar o default é defeito do pack: a organização que não customiza recebe a ação rodando
  só com a moldura. O build denuncia e reprova em `--strict`. Encaixe `essencial: true` é a
  exceção — sem padrão possível (marca da empresa, gerador proprietário), a ação nasce
  indisponível e isso é estado, não defeito.
- Se usa provider: a description termina apontando a `INTERFACE.md` do domínio (ex.:
  `system/providers/backlog/INTERFACE.md`) — nunca a implementação nem o nome da
  ferramenta.

**Corpo:**

- PT-BR correto e acentuado (`org/ORG.md` §1). UTF-8.
- Abra com a tabela de camadas (Restrições / Métodos / Providers / Formatos) — ver
  qualquer skill migrada como modelo.
- Workflow (L2): alvo **< 100 linhas**. Estourou → método vazando (extrair p/ seção L1 /
  `references/`) ou sintaxe de ferramenta vazando (extrair p/ skill de referência).
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

**Estrutura de pastas da skill:** `{system/pack|org}/workflows/{nome}/SKILL.md` + opcionais `references/`
(material longo carregado sob demanda), `assets/`, `evals/evals.json` (casos de gatilho:
frases que DEVEM acionar e frases que NÃO devem).

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
precedência entre camadas (é o build que resolve, `ARCHITECTURE.md` §3 e §7). Copie literal:

> **Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
> seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
> sempre e não é substituível.

## 4. Contrato de edição de skill existente

- **Ler o SKILL.md inteiro antes de propor** — nunca editar por trecho isolado.
- Os textos atuais foram **calibrados com uso real**: portões, desempates de gatilho e
  princípios são conteúdo valioso. Edição realoca/poda com critério (§2), não reescreve
  do zero.
- Edição é oportunidade de poda: encontrou script cognitivo no caminho → proponha cortar
  na mesma passada (item separado da proposta, para o usuário aprovar em separado).
- Mudança de comportamento invariante (gate, portão) NÃO se faz numa skill — se a demanda
  pede isso, o alvo é `system/CONSTITUTION.md`/`ARCHITECTURE.md` e a discussão sobe de nível.
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
      `<workflow>/PERSONA.md` (fonte única) e rode o build. **Nunca edite
      `runtime/claude|codex|opencode/` à mão** — são gerados e sobrescritos a cada build.
      Contrato do `PERSONA.md`: `runtime/adapters/README.md`. Skill comum não tem persona.
- [ ] **`system/ACOES.md`** — ação **do sistema** nova, encaixe novo, ação renomeada ou
      aposentada. É contrato público: renomear quebra as organizações que reivindicaram a
      ação — trate como mudança de API. Encaixe novo é aditivo e não quebra ninguém. Ação
      criada pela organização **não** entra no catálogo do sistema.
- [ ] **`docs/ARCHITECTURE.md`** — só se a mudança altera a arquitetura (camada nova,
      regra de resolução, contrato de provider). Aí ele é atualizado PRIMEIRO (é a fonte
      de verdade) e esta skill depois.

### Aceite — o que precisa passar antes de entregar

| Checagem | Critério |
|---|---|
| `./.agents/runtime/build.sh --strict` | sai **0**; aviso é reprovação neste modo |
| `--org <diretório vazio> --out <temporário>` | nenhum aviso de "sem padrão no pack" — é o teste da organização recém-criada |
| `--fix` | não muda `system/ACOES.md` quando nenhuma ação ou encaixe mudou |
| `org/` | nenhum arquivo novo, salvo quando a demanda era escrever registro da organização |

Reprovou → conserte antes de entregar. Aceite que não vale nesta demanda se declara com o
motivo, nunca se omite.

## 7. Fora do escopo

- `project-config.yaml` / `.env` — config de instância, não é artefato do harness.
- Documentos de produto do projeto (`{caminhos.entregaveis}`, `{caminhos.historico}`, wiki) — são das skills de
  produto, não desta.
- Commit/push — `@committer`.
