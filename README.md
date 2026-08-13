# Harness de Product Management

Harness compartilhado de Product Management para Claude Code, Codex e OpenCode — e seed do
futuro Hub de PMs. Três profissões (`@product-specialist`, `@tech-lead`, `@product-designer`)
sobre uma arquitetura de camadas, com pack padrão que funciona sem nenhuma customização.

**Este é o único documento de leitura humana no dia a dia.** O resto do harness é
referência que os agentes carregam: comportamento em `system/CONSTITUTION.md`, camadas em
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md), modos de operação e fluxos de manipulação
em [`docs/MODOS.md`](docs/MODOS.md), fluxos de interface do Hub em
[`docs/HUB.md`](docs/HUB.md), procedimento em cada `SKILL.md`.

---

## Instalar

```bash
cd <raiz-do-projeto>
git clone <url-do-harness> .agents
./.agents/install.sh
```

O instalador cria só estes caminhos, nunca sobrescreve arquivo existente, e roda o build:

| Caminho | O que é |
|---|---|
| `.claude` / `.codex` / `.opencode` | symlinks → `.agents/runtime/<runtime>` |
| `sync-context.sh` | symlink → `.agents/sync-context.sh` |
| `project-config.yaml` | cópia do template — versionado no projeto |
| `.env` | cópia do `.env.example` — fora do Git (tem segredo) |
| `.agents/org/` | cópia de `system/pack/org-scaffold/` — **sua camada**, fora do Git do harness |

Requisito: `bash` e `python3` (o build gera os adapters). Ferramentas externas, nenhuma
obrigatória — cada provider avisa e para se faltar: `gh` ou `glab` autenticado · `pandoc` ·
`rclone` · `pdftotext` · Node 20+ (protótipo) · cliente CLI do banco.

Atualizar: `git -C .agents pull --ff-only && ./.agents/runtime/build.sh`.

## Configurar

- **`project-config.yaml`** — cliente, projeto, token de arquivo, responsável, URL de
  demandas, caminhos, deploy do protótipo. Só dado, em blocos (`identidade`, `recursos`,
  `caminhos`, `prototipo_deploy`, `documentacao`). Campo em branco vira placeholder no
  documento gerado; a skill não inventa valor. YAML enquanto a edição é na mão; migra para
  JSON + schema quando existir interface.
- **`org/ORG.md`** — convenções da **sua** organização: língua, nomenclatura, papéis,
  funil de priorização, vocabulário. Nasce do scaffold com campos `[definir]`; campo não
  preenchido = o pack decide pelo default dele, nada quebra. `org/` inteira é sua e fica
  fora do Git do harness — versione onde fizer sentido.
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
│   └── workflows/           máquina do harness (skill-creator, motores) — não-forkável
├── org/                 ✎ SUA — ORG.md, workflows/, professions/, providers/ (fora do Git)
├── skills →             symlink para runtime/skills — ponto de descoberta de skills
├── runtime/             build.sh + adapters/ (fonte dos adapters gerados)
│   ├── skills/          GERADO — visão resolvida que os runtimes leem
│   └── claude|codex|opencode/  GERADO — a partir dos PERSONA.md resolvidos
└── docs/ARCHITECTURE.md referência normativa das camadas
```

Resolução: máquina vence sempre · workflow resolvido = **moldura do pack + conteúdo da
organização nos encaixes declarados** (`docs/ARCHITECTURE.md` §7, catálogo em
`system/ACOES.md`) · `SKILL.md` em `org/` só para ação que o pack não atende ·
`org/workflows/<nome>/DISABLED` desliga um workflow do pack. **Criou, renomeou ou preencheu
encaixe? Rode `./.agents/runtime/build.sh`** — ele resolve as camadas, valida o contrato e
escreve `runtime/manifest.json` (o catálogo como dado, `docs/ARCHITECTURE.md` §8).

| Flag | Para quê |
|---|---|
| `--list` | origem, ação e quantos encaixes estão preenchidos, por workflow |
| `--fix` | regenera a tabela derivada do `system/ACOES.md` (sem a flag, o build só verifica e reprova se divergiu) |
| `--strict` | aviso vira reprovação, código de saída 3 — modo de CI |
| `--org DIR` · `--out DIR` | camada da organização e saída gerada fora dos caminhos padrão |

Portão humano, contrato de saída e método ficam **fora** de qualquer encaixe: a organização
não os alcança, então não consegue degradar a qualidade da resposta configurando errado.

| Quero mudar… | Vai em |
|---|---|
| comportamento invariante (gate, portão) | `system/CONSTITUTION.md` |
| como uma persona se apresenta em todos os runtimes | `<workflow>/PERSONA.md` + build |
| como a profissão pensa / método | `system/professions/` (ou `org/professions/`) |
| convenção da empresa (língua, nomes, papéis) | `org/ORG.md` |
| workflow que serve a qualquer empresa | `system/pack/workflows/<nome>/` |
| formato, template ou **procedimento** desta empresa | encaixe em `org/workflows/<nome>/` (`system/ACOES.md`) |
| ação que o harness não faz | `org/workflows/<nome>/SKILL.md` com `acao:` nova |
| sintaxe de ferramenta | `system/providers/<domínio>/` (ou `org/providers/`) |
| valor do projeto | `project-config.yaml` / `.env` |

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
| Backlog | `BACKLOG_PROVIDER` + chaves do `.env` | `backlog/github-gh` · `backlog/gitlab-glab` |
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

**Toda mudança em `.agents/` passa pela skill `skill-creator`** — peça em linguagem
natural ("cria uma skill de X", "refatora a discovery", "extrai esse método"). Ela
classifica a camada, propõe antes de escrever e propaga as referências. Editar na mão sem
passar por ela é como commitar sem revisão: às vezes funciona, e é assim que a arquitetura
apodrece.

Três leis de escrita (detalhe em [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)):

1. **Referência, nunca cópia** — a mesma explicação em dois arquivos = um está na camada errada.
2. **Contrato e restrição, nunca script cognitivo** — prescreva o que o resultado deve ser
   e onde parar para aprovação; nunca como raciocinar. Exceção: provider e motor, onde
   sintaxe de ferramenta é fato.
3. **Em conflito, a camada de baixo vence.** L0 vence tudo; nenhuma edição de `org/`
   afrouxa um gate — no máximo adiciona portões.

Validação antes do commit:

```bash
cd .agents && ./runtime/build.sh
for d in runtime/skills/*/; do n=$(basename "$d")
  grep -q "^name: $n$" "$d/SKILL.md" || echo "ERRO: $n"; done
python3 -c "import json; json.load(open('runtime/opencode/opencode.json'))"
python3 -m py_compile runtime/adapters/render.py
bash -n install.sh runtime/build.sh
```

Commit é sempre manual, via `@committer`.

## Limites do pack — o que ele assume

Declarado de propósito, para ninguém descobrir no meio do trabalho:

- **Escopo é produto.** As profissões cobrem produto, técnica-de-produto e design. Não há
  persona de desenvolvimento, QA, dados ou infraestrutura — e não está no roadmap: quem
  precisar cria em `org/professions/`.
- **Língua do pack é PT-BR.** Descrições de skill (que fazem o roteamento), formatos e
  prosa. Organização que trabalha noutro idioma declara em `org/ORG.md` §1 e sobrescreve
  os encaixes de formato — a moldura das skills continua em PT-BR.
- **Providers com implementação hoje:** backlog (`gh`, `glab`), documento final (`pandoc`),
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
