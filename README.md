# Harness de Product Management

Harness compartilhado de Product Management para Claude Code, Codex e OpenCode — e seed do
futuro Hub de PMs. Três profissões (`@product-specialist`, `@tech-lead`, `@product-designer`)
sobre uma arquitetura de camadas, com pack padrão que funciona sem nenhuma customização.

**Este documento é o uso no dia a dia: instalar, configurar, trabalhar.** Para entender ou
mudar o harness por dentro, o índice é [`docs/README.md`](docs/README.md):

| Quero… | Vai em |
|---|---|
| entender como funciona, em uma página | [`docs/HARNESS.md`](docs/HARNESS.md) |
| saber o que já existe, ficha por ficha | [`docs/WORKFLOWS.md`](docs/WORKFLOWS.md) — gerado do frontmatter |
| editar qualquer coisa do harness | [`docs/MANUTENCAO.md`](docs/MANUTENCAO.md) |
| a regra normativa das camadas | [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) |
| o produto com interface (nada implementado) | [`docs/hub/`](docs/hub/) |

---

## Instalar

Na raiz do projeto:

```bash
npx straggy-harness
```

Antes de publicar no npm, o mesmo comando via GitHub:

```bash
npx github:gccintra/straggy-harness
```

Sem Node: `curl -fsSL https://raw.githubusercontent.com/gccintra/straggy-harness/main/get.sh | bash`.

O bootstrap clona o harness em `.agents/` **sem a pasta `docs/`** (discovery, PRD e
arquitetura de produto ficam no repositório do harness, não no projeto) e roda o
`install.sh` — que liga os runtimes (Claude, Codex, OpenCode, Cursor CLI), semeia o que
faltar e gera os adapters. Pin de versão: `HARNESS_REF=<tag> npx straggy-harness`. Para
materializar `docs/` depois: `git -C .agents sparse-checkout add docs`.

O instalador cria só estes caminhos, nunca sobrescreve arquivo existente, e roda o build:

| Caminho | O que é |
|---|---|
| `.claude` / `.codex` / `.opencode` / `.cursor` | symlinks → `.agents/runtime/<runtime>` |
| `.cursor/` já existia (IDE) | o install **não** substitui: planta só `.cursor/rules/*.mdc` |
| `sync-context.sh` | symlink → `.agents/sync-context.sh` |
| `project-config.yaml` | cópia do template — versionado no projeto |
| `.env` | cópia do `.env.example` — fora do Git (tem segredo) |
| `.agents/org/` | cópia de `system/pack/org-scaffold/` — **sua camada**, fora do Git do harness |

Requisito: `bash` e `python3` (o build gera os adapters). Ferramentas externas, nenhuma
obrigatória — cada provider avisa e para se faltar: `gh` ou `glab` autenticado (ou o
servidor MCP do Linear conectado) · `pandoc` · `rclone` · `pdftotext` · Node 20+
(protótipo) · cliente CLI do banco.

Atualizar: `git -C .agents pull --ff-only && ./.agents/build.sh`.

## Configurar

- **`project-config.yaml`** — cliente, projeto, token de arquivo, responsável, URL de
  demandas, caminhos, deploy do protótipo. Só dado, em blocos (`identidade`, `recursos`,
  `caminhos`, `prototipo_deploy`, `documentacao`). Campo em branco vira placeholder no
  documento gerado; a skill não inventa valor. YAML enquanto a edição é na mão; migra para
  JSON + schema quando existir interface.
- **`org/ORG.md`** — convenções da **sua** organização: língua, nomenclatura, papéis,
  vocabulário. Nasce do scaffold com campos `[definir]`; campo não
  preenchido = o pack decide pelo default dele, nada quebra. `org/` inteira é sua e fica
  fora do Git do harness — versione onde fizer sentido. O **funil de priorização** não mora
  aqui: é o encaixe estruturado `funil` (`org/workflows/backlog-prioritization/references/funil.yaml`),
  validado contra `system/schemas/funil-priorizacao.yaml`.
- **`.env`** — credenciais e IDs + seleção de provider (`BACKLOG_PROVIDER`,
  `DOCS_OUTPUT_PROVIDER`, `DB_ENABLED`).
  Sem backlog configurado o harness continua funcionando: workflows que dependem do estado
  real param e avisam; os que usam a demanda só como contexto caem para o repo local.
  Regimes: `system/providers/*/INTERFACE.md`.
- **`AGENTS.md` / `CLAUDE.md`** na raiz do projeto — override local opcional; complementa,
  nunca substitui a `CONSTITUTION.md`.

---

## Estrutura

```
.agents/
├── system/              ★ IMUTÁVEL pela organização (no produto: shipped read-only)
│   ├── CONSTITUTION.md      L0 — write-gate, autonomia, honestidade, portões, delegação
│   ├── professions/         L1 — PROFESSION.md + reasoning.md + methods/ por profissão
│   ├── providers/           contrato (INTERFACE.md) + implementações + recipes/
│   ├── ACOES.md             catálogo público: ações e encaixes (o que a organização escreve)
│   ├── pack/                L2 PADRÃO — workflows genéricos + org-scaffold/
│   └── workflows/           máquina do harness (harness-change, harness-guide, motores) — não-forkável
├── org/                 ✎ SUA — ORG.md, workflows/, professions/, providers/ (fora do Git)
├── build.sh             porta de entrada — chama runtime/build.sh
├── skills →             symlink para runtime/skills — ponto de descoberta de skills
├── runtime/             resolvedor + adapters/ + saída gerada
│   ├── skills/          GERADO — visão resolvida que os runtimes leem
│   └── claude|codex|opencode|cursor/  GERADO — a partir dos PERSONA.md resolvidos
└── docs/             HARNESS.md (como funciona) · WORKFLOWS.md (o que existe, gerado)
                     MANUTENCAO.md (como editar) · ARCHITECTURE.md (normativa) · hub/ (futuro)
```

Resolução: máquina vence sempre · workflow resolvido = **moldura do pack + conteúdo da
organização nos encaixes declarados** (`docs/ARCHITECTURE.md` §7, catálogo em
`system/ACOES.md`) · `SKILL.md` em `org/` só para ação que o pack não atende ·
`org/workflows/<nome>/DISABLED` desliga um workflow do pack. **Criou, renomeou ou preencheu
encaixe? Rode `./.agents/build.sh`** — ele resolve as camadas, valida o contrato e
escreve `runtime/manifest.json` (o catálogo como dado, `docs/ARCHITECTURE.md` §8).

| Flag | Para quê |
|---|---|
| `--list` | origem, ação e quantos encaixes estão preenchidos, por workflow |
| `--fix` | regenera os blocos derivados de `system/ACOES.md` e `docs/WORKFLOWS.md` (sem a flag, o build só verifica e reprova se divergiu) |
| `--strict` | aviso vira reprovação, código de saída 3 — modo de CI |
| `--org DIR` · `--out DIR` | camada da organização e saída gerada fora dos caminhos padrão |
| `--env FILE` | `.env` a conferir contra o que a organização preencheu (default: o do projeto) |

Portão humano, contrato de saída e método ficam **fora** de qualquer encaixe: a organização
não os alcança, então não consegue degradar a qualidade da resposta configurando errado.

**Onde se edita cada coisa**: a tabela por camada está em
[`docs/MANUTENCAO.md`](docs/MANUTENCAO.md) §1, e o arquivo exato de cada workflow na
ficha dele em [`docs/WORKFLOWS.md`](docs/WORKFLOWS.md).

---

## As três profissões

Ponto de entrada padrão: **`@product-specialist`**. Em dúvida, é ele. Nenhuma persona aciona
outra por baixo dos panos — quem troca é você.

| Persona | Pensa em | Chame quando |
|---|---|---|
| `@product-specialist` | valor, requisito, processo | backlog, discovery, documentação, sprint, changelog, wiki |
| `@tech-lead` | viabilidade, dados reais, impacto | "como funciona de verdade?", "o que quebra?", HT, banco |
| `@product-designer` | interface, fluxo, design system | tela, protótipo, componente, tokens, export Figma |

Você fala em linguagem natural; o runtime escolhe o workflow pela `description` de cada
skill. Não existe tabela de roteamento para manter.

## Fluxo de produto

```
demanda no backlog
  ├─ backlog-issue-creator   cria/refina a demanda (template, MoSCoW, labels)
  ├─ discovery               Double Diamond D1→D2, um registro por fase
  ├─ [só demanda com tela]   design-brief → design-screen → protótipo validado
  ├─ doc-consolidator        gera o .md consolidado  ⏸ PARA para revisão humana
  └─ doc-final-generator     .md revisado → formato final (transcrição mecânica)
```

**Demanda com interface documenta depois do protótipo validado** — é ali que a solução
converge, e escrever requisito antes gera retrabalho. O `{ID}_design.md` nasce plano na
`design-brief` e termina registro na `design-screen`; é a entrada do `doc-consolidator`.
Divergência: o protótipo manda em fluxo, estado, rótulo e mensagem; o discovery manda em
regra e escopo. Demanda sem tela vai direto ao consolidado.

O **`.md` é a fonte de verdade; o formato final é transcrição**: "documenta a #NNN" gera só
o `.md` e para; o documento final só sob pedido explícito, após revisão; documento errado →
conserta o `.md` e regera, nunca se edita o final à mão.

Backlog e sprint: `backlog-query` (consulta pontual) · `backlog-prioritization` (MoSCoW →
I×E → ICE) · `backlog-analysis` (métricas, burndown) · `backlog-health` (duplicatas,
zumbis) · `sprint-ops` · `sprint-goal-generator` · `wiki-publish` · `changelog-generator`.

## Fluxo de design

```
design-setup      1x por projeto: tokens a partir de prints + scaffold do prototype/
design-brief      antes de codar: o que a demanda vira na interface
design-screen     cria/ajusta a tela como rota React em prototype/
prototype-prints  prints da demanda para a documentação
prototype-deploy  publica o prototype/ numa VPS (estático, basic auth, HTTPS)
```

Fonte de verdade do design é **o código** (arquivo de tokens + componentes base). A stack do
protótipo é do projeto — o pack traz Vite + React + TS + Tailwind como default, em
`design-setup/references/stack-react-vite.md`; outra stack preenche o encaixe `stack-prototipo`.
Export pro Figma é opt-in (`html-to-figma`, invocada pela `design-screen`).

## Fluxo técnico

`@tech-lead` + `db-query`: responde "o que os dados dizem de verdade" antes de decidir.
Comportamento **esperado** sai da documentação com fonte citada; estado **real** sai do
banco. Demanda técnica documentada segue os mesmos portões (`.md` → revisão → formato
final).

## De onde vem o contexto e onde as coisas são gravadas

| Fonte | Como chega | Provider |
|---|---|---|
| Google Drive (HUs, regras) | `./sync-context.sh` → `docs/context_docs/md/` | `knowledge/drive-rclone` |
| Backlog | `BACKLOG_PROVIDER` + chaves do `.env` | `backlog/github-gh` · `backlog/gitlab-glab` · `backlog/linear-mcp` |
| Documento final | `DOCS_OUTPUT_PROVIDER` | `docs-output/pandoc-cli` |
| Banco | `DB_CONNECT_CMD` | `database/cli` |
| Figma | MCP | `canvas/figma-mcp` |

| Pasta (projeto) | Conteúdo | Git? |
|---|---|---|
| `outputs/{ID}_{Nome}/` | `.md` consolidado + documento final + prints | só `.md` |
| `history/` | discoveries, análises, registros | sim |
| `data/` | exports CSV, burndown | sim |
| `docs/context_docs/` | cache do Drive | não (derivado) |
| `prototype/` | app de protótipo | sim, menos `dist/` |

---

## Editar o harness

Duas skills cobrem o harness por dentro: **`harness-guide`** responde o que ele já faz,
onde algo mora e o que quebra se você mexer — só leitura. **`harness-change`** especifica e
executa a mudança. O processo completo (camada, spec com análise de impacto, critérios de
aceite e o que faz estar pronto) está em [`docs/MANUTENCAO.md`](docs/MANUTENCAO.md). O
resumo:

**Toda mudança em `.agents/` passa pela skill `harness-change`** — peça em linguagem
natural ("cria uma skill de X", "refatora a discovery", "extrai esse método"). Ela classifica
a camada, levanta o impacto, escreve a spec em `docs/mudancas/`, propõe antes de escrever e
propaga as referências. Editar na mão sem passar por ela é como commitar sem revisão: às
vezes funciona, e é assim que a arquitetura apodrece.

Três leis de escrita (detalhe em [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)):

1. **Referência, nunca cópia** — a mesma explicação em dois arquivos = um está na camada errada.
2. **Contrato e restrição, nunca script cognitivo** — prescreva o que o resultado deve ser
   e onde parar para aprovação; nunca como raciocinar. Exceção: provider e motor, onde
   sintaxe de ferramenta é fato.
3. **Em conflito, a camada de baixo vence.** L0 vence tudo; nenhuma edição de `org/`
   afrouxa um gate — no máximo adiciona portões.

Validação antes do commit:

```bash
cd .agents && ./build.sh --strict
for d in runtime/skills/*/; do n=$(basename "$d")
  grep -q "^name: $n$" "$d/SKILL.md" || echo "ERRO: $n"; done
python3 -c "import json; json.load(open('runtime/opencode/opencode.json'))"
test -f runtime/cursor/rules/harness.mdc
python3 -m py_compile runtime/adapters/render.py
bash -n install.sh get.sh build.sh runtime/build.sh
```

Isso é a **camada de contrato**: determinística, de graça, e é o que pega duas declarações
discordando em silêncio — encaixe preenchido sob provider que não suporta a capacidade,
fonte de eval citando ação renomeada, ação sem contraprova de gatilho.

A **camada de comportamento** (o gatilho dispara no pedido certo, e não no do vizinho)
precisa de um runtime executando, e roda à parte:

```bash
./.agents/runtime/eval.sh                        # harness inteiro
./.agents/runtime/eval.sh --skill doc-final-generator
./.agents/runtime/eval.sh --tipo modo-degradado --runner codex-exec
```

Toda corrida grava `runtime/evals/<carimbo>/` com `resultado.json` (o que CI consome) e
`report.html` (o que gente lê — taxa, estados, cobertura do gatilho por ação).

Quem executa é o provider `eval-runner` — `claude-headless` (default), `codex-exec`,
`opencode-run`, `claude-plugin-eval`. Só a Claude expõe **qual skill engajou**, então caso de
roteamento só roda nela; os de modo degradado rodam nos três. Capacidade que falta vira caso
**NÃO-RODADO**, nunca verde.

A fonte versionada é neutra — `<workflow>/evals/<caso>/caso.yaml`, no vocabulário do harness.
Cada implementação a lê do seu jeito; editar o que `render.py` gera em `runtime/skills/` é
trabalho que o próximo build apaga.

Suíte verde não prova nada por si — quebre o gatilho de propósito e confira que o caso fica
vermelho. Formato, pareamento e as três provas: `docs/ARCHITECTURE.md` §9.

Commit é sempre manual, via `@committer`.

## Limites do pack — o que ele assume

Declarado de propósito, para ninguém descobrir no meio do trabalho:

- **Escopo é produto.** As profissões cobrem produto, técnica-de-produto e design. Não há
  persona de desenvolvimento, QA, dados ou infraestrutura — e não está no roadmap: quem
  precisar cria em `org/professions/`.
- **Língua do pack é PT-BR.** Descrições de skill (que fazem o roteamento), formatos e
  prosa. Organização que trabalha noutro idioma declara em `org/ORG.md` §1 e sobrescreve
  os encaixes de formato — a moldura das skills continua em PT-BR.
- **Providers com implementação hoje:** backlog (`gh`, `glab`, Linear via MCP), documento final (`pandoc`),
  conhecimento (Drive + rclone), banco (qualquer cliente CLI), canvas (Figma). Outra
  ferramenta = implementação nova em `org/providers/`, sob a mesma `INTERFACE.md` — nunca
  fork do core.
- **Sem backlog configurado o harness funciona**, em modo degradado declarado por
  workflow (`system/providers/backlog/INTERFACE.md`).

## O que o harness nunca faz sozinho

- **Escrita externa** (demanda, comentário, wiki, changelog, entregável, servidor, arquivo
  do harness) só com aprovação — e aprovação de um passo não vale para o próximo.
- **Falta contexto que muda o resultado** → uma pergunta focada, sem assumir.
- **Portões humanos** — o `.md` para para revisão; um pedido = um passo.
- **Commit** — só quando você pedir.
