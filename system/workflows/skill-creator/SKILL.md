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
   providers (§4), anti-padrões (§6).
2. `.agents/system/CONSTITUTION.md` — write-gate, autonomia (§3), brevidade (+ `org/ORG.md`).

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
| Procedimento desta empresa, ou formato que substitui o do pack | L2 org | `org/workflows/{nome}/` — arquivo a arquivo (override) |
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

## 4. Contrato de edição de skill existente

- **Ler o SKILL.md inteiro antes de propor** — nunca editar por trecho isolado.
- Os textos atuais foram **calibrados com uso real**: portões, desempates de gatilho e
  princípios são conteúdo valioso. Edição realoca/poda com critério (§2), não reescreve
  do zero.
- Edição é oportunidade de poda: encontrou script cognitivo no caminho → proponha cortar
  na mesma passada (item separado da proposta, para o usuário aprovar em separado).
- Mudança de comportamento invariante (gate, portão) NÃO se faz numa skill — se a demanda
  pede isso, o alvo é `system/CONSTITUTION.md`/`ARCHITECTURE.md` e a discussão sobe de nível.

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

- [ ] **Build** — `./runtime/build.sh` (regenera `runtime/skills/`). Sem isso a skill nova
      não existe para nenhum runtime.
- [ ] **Persona** — só se a mudança cria **ambiguidade de escolha**: o desempate entra em
      `.../workflows/product-specialist|tech-lead|product-designer`. Gatilho normal vive na
      `description` da própria skill; não há tabela de roteamento para manter.
- [ ] **`README.md`** (raiz do harness) — único doc humano: só se a mudança altera fluxo,
      instalação, configuração ou estrutura. Skill nova comum não entra lá.
- [ ] **Persona** — só se a mudança cria ou altera uma persona: edite o
      `<workflow>/PERSONA.md` (fonte única) e rode o build. **Nunca edite
      `runtime/claude|codex|opencode/` à mão** — são gerados e sobrescritos a cada build.
      Contrato do `PERSONA.md`: `runtime/adapters/README.md`. Skill comum não tem persona.
- [ ] **`docs/ARCHITECTURE.md`** — só se a mudança altera a arquitetura (camada nova,
      regra de resolução, contrato de provider). Aí ele é atualizado PRIMEIRO (é a fonte
      de verdade) e esta skill depois.

## 7. Fora do escopo

- `project-config.yaml` / `.env` — config de instância, não é artefato do harness.
- Documentos de produto do projeto (`outputs/`, `history/`, wiki) — são das skills de
  produto, não desta.
- Commit/push — `@committer`.
