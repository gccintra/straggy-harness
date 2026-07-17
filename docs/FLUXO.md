# Como o harness funciona

Guia de uso do harness num projeto de produto: como instalar, como configurar e qual
skill entra em cada momento do trabalho.

Para as regras de comportamento invariantes (brevidade, write-gate, context-gate),
veja [`ENGAGEMENT.md`](../ENGAGEMENT.md). Para o motivo de cada coisa morar onde mora,
veja "Core vs. adapter" no [`README.md`](../README.md).

---

## 0. Arquitetura em 3 camadas

O harness em si (`.agents/`) tem esta física:

```
.agents/
├── ENGAGEMENT.md              regras invariantes (brevidade, write-gate, context-gate,
│                               personas, delegação seletiva, ortografia)
├── README.md                   overview + instalação + core vs. adapter
├── docs/
│   ├── FLUXO.md                 este arquivo — instalação, config, fluxo por momento
│   └── CHEAT_SHEET.md           referência rápida (triggers, mapa skill, ICE, MoSCoW)
├── SYNC_SETUP.md               setup do service account do Drive + rclone
├── install.sh                  cria os symlinks e semeia project-config.md/.env
├── sync-context.sh             Drive → docs/context_docs/md/ no projeto consumidor
├── project-config.template.md  template do project-config.md
├── .env.example                template do .env
├── skills/                     física ÚNICA de cada skill: skills/{nome}/SKILL.md
└── runtime/                     adapter por runtime — como cada um descobre/spawna
    ├── claude/agents/*.md + commands/*.md    (Claude Code: subagent + slash command)
    ├── codex/agents/*.toml                   (Codex: agent definition)
    └── opencode/opencode.json                (OpenCode: agent config)
```

**Três camadas, para não erodir a portabilidade entre Codex/Claude Code/OpenCode:**

1. **Skill compartilhada** (`skills/`) — a lógica de produto/processo em si. Um único
   `SKILL.md` por skill, lido pelos três runtimes.
2. **Regra invariante** (`ENGAGEMENT.md`) — comportamento que vale sempre, independente de
   runtime ou projeto (write-gate, context-gate, brevidade, delegação, ortografia).
3. **Adapter de runtime** (`runtime/<runtime>/`) — só "como spawnar/configurar a persona
   nesse runtime específico". Nunca lógica de produto.

No projeto consumidor (`<raiz-do-projeto>/`), o `install.sh` só cria symlinks e semeia dois
arquivos de config — ver tabela em [§1](#1-instalar-num-projeto-novo). As skills nunca são
copiadas: Codex e OpenCode leem `.agents/skills/` direto; Claude Code enxerga o mesmo caminho
via `runtime/claude/skills`.

**Sinal de que algo está na camada errada:** se você se pegar copiando a mesma skill em 3
variações por runtime, a diferença devia estar no adapter (`runtime/<runtime>/`), não na skill.

---

## 1. Instalar num projeto novo

O harness vive em `<projeto>/.agents/`. Ele pode ser um submódulo registrado **ou** um clone
local que o projeto ignora no Git — o instalador funciona nos dois casos.

```bash
cd <raiz-do-projeto>

# como clone local (o projeto ignora .agents/ no .gitignore)
git clone https://github.com/<org>/websis-pm-harness.git .agents

# ou como submódulo versionado (o projeto fixa a revisão do harness)
git submodule add https://github.com/<org>/websis-pm-harness.git .agents

./.agents/install.sh
```

O `install.sh` **não instala dependência nem toca em nada fora destes 6 caminhos**:

| Caminho na raiz do projeto | O que é | Sobrescreve? |
|---|---|---|
| `.claude` | symlink → `.agents/runtime/claude` | — |
| `.codex` | symlink → `.agents/runtime/codex` | — |
| `.opencode` | symlink → `.agents/runtime/opencode` | — |
| `sync-context.sh` | symlink → `.agents/sync-context.sh` | — |
| `project-config.md` | **cópia** de `project-config.template.md` | **não** |
| `.env` | **cópia** de `.env.example` | **não** |

Os dois últimos são cópia, não symlink: os valores são do projeto. O `project-config.md`
vai pro Git do projeto; o `.env` não — tem segredo.

Rodar de novo é seguro. Symlink já correto é deixado como está, e arquivo já existente
nunca é sobrescrito (você perderia os valores preenchidos).

> **Campo novo no harness depois que você já instalou?** O `install.sh` não mexe no seu
> `project-config.md`/`.env` existente. Compare com o template e traga o campo na mão.

### Ferramentas externas

Nenhuma é obrigatória — cada skill avisa e para se faltar a sua.

| Ferramenta | Necessária para |
|---|---|
| `glab` (autenticado) | tudo de backlog, discovery, sprint, wiki |
| `pandoc` | `.docx` → Markdown (sync) e Markdown → `.docx` (HU/HT) |
| `rclone` | sync do Google Drive |
| `pdftotext` (poppler) | PDFs no sync |
| Node 20+ | protótipo (`prototype/`) |
| cliente CLI do banco | `db-query` (`sqlcmd`, `psql`, `isql`, …) |

---

## 2. Configurar

Duas fontes de verdade, e **nenhuma skill tem valor de projeto hard-coded**:

**`project-config.md`** (raiz do projeto, versionado) — cliente, nome do projeto, token de
arquivo, responsável, URL base das issues, caminhos de output, marca/padrão dos documentos,
dados de deploy do protótipo. Campo em branco → a skill usa um placeholder (`[CLIENTE]`) no
documento gerado, para você completar depois. Ela não inventa valor.

**`.env`** (raiz do projeto, **fora do Git**) — credenciais e IDs: GitLab, Google Drive,
Figma, Firecrawl, banco. Cada bloco do `.env.example` diz quais skills leem aquelas chaves.

Preencha antes de rodar qualquer skill. Setup do service account do Drive e do rclone:
[`SYNC_SETUP.md`](../SYNC_SETUP.md).

---

## 3. As três personas

Ponto de entrada padrão: **`@product-manager`**. Em dúvida, é ele.

| Persona | Pensa em | Chame quando |
|---|---|---|
| `@product-manager` | valor, requisito, processo | backlog, discovery, documentação, sprint, changelog, wiki |
| `@tech-lead` | viabilidade, dados reais, impacto | "como isso funciona de verdade?", "o que isso quebra?", HT, consulta ao banco |
| `@product-designer` | interface, fluxo, design system | tela, protótipo, componente, tokens, export pro Figma |

Cada persona carrega as skills que precisa e executa na thread principal. Elas não
"passam a bola" entre si automaticamente — quem troca de persona é você.

---

## 4. O fluxo de produto

O caminho de uma demanda, da ideia ao documento formal.

```
issue no GitLab
      │
      ├─ backlog-issue-creator ── cria/refina a issue (template, MoSCoW, labels)
      │
      ├─ discovery ────────────── Double Diamond: D1 (problema) → D2 (solução)
      │                           grava um comentário por fase na issue;
      │                           só o bloco PRIORIZACAO da descrição é atualizado
      │
      ├─ doc-consolidator ─────── gera outputs/{ID}_{Nome}/{ID}.md
      │                           descrição + critérios de aceitação + regras (SBVR)
      │                           + mensagens + trilha do discovery
      │                           ⏸ PARA AQUI para revisão humana
      │
      └─ hu-generator ─────────── .md revisado → .docx (9 seções, História de Usuário)
         ht-generator             .md revisado → .docx (6 seções, História Técnica)
```

Dois pontos que as skills tratam como invariante:

**O `.md` é a fonte de verdade, o `.docx` é transcrição.** "Documenta a #NNN" gera **só o
`.md`** e para. O `.docx` é passo separado, e só depois de você revisar — os geradores não
releem o discovery, só transcrevem. Se algo está errado no `.docx`, conserte o `.md` e gere
de novo.

**HU vs. HT:** HU tem persona de usuário final. HT é demanda técnica sem ela — débito,
refatoração, infra, CI/CD, migração.

### Backlog e sprint

| Quero | Skill |
|---|---|
| ranquear o backlog (MoSCoW → quadrante I×E → ICE) | `backlog-prioritization` |
| métricas, velocidade, distribuição | `backlog-analysis` |
| achar issue sem tipo/prioridade/sprint, duplicata, zumbi | `backlog-health` |
| criar/fechar sprint, mover issues, documentar milestone | `gitlab-sprint-ops` |
| escrever a Meta da Sprint (outcome, não output) | `sprint-goal-generator` |
| publicar documentação na wiki | `gitlab-wiki` |
| registrar mudança no Histórico de Evolução | `changelog-generator` |

`glab-backlog` é referência de comandos `glab` — carregada **obrigatoriamente** por qualquer
skill que fale com o GitLab. Não é gatilho direto seu.

---

## 5. O fluxo de design

```
design-setup ──── uma vez por projeto: extrai tokens de prints do sistema atual,
                  faz o scaffold do prototype/ (Vite + React + TS + Tailwind)

design-brief ──── antes de codar: o que a demanda vira na interface, o que reusa,
                  o que falta no design system, o que quebra nas telas existentes

design-screen ─── cria ou ajusta a tela como rota React em prototype/
                  reusa src/components/ui/ e os tokens do tailwind.config.js

prototype-deploy ─ publica o prototype/ numa VPS: site estático, basic auth, HTTPS
                  setup do servidor é uma vez; depois, republicar é só
                  `cd prototype && ./deploy.sh`
```

A **fonte de verdade do design é o código** (`tailwind.config.js` + `components/ui/`), não o
Figma. Export pro Figma é opt-in, via `html-to-figma` — que não é gatilho direto seu, é
invocada pela `design-screen`. Idem `figma-node-reader`, que só entra quando um node do Figma
estoura o limite de token.

---

## 6. O fluxo técnico

`@tech-lead` + `db-query`: consulta o banco de homologação pelo cliente CLI do `.env`
(sem MCP; qualquer autenticação — senha, NTLM, Kerberos, `.pgpass`). Serve pra responder
"o que os dados dizem de verdade" antes de decidir. Demanda técnica sem persona de usuário
final vira HT, pelo mesmo caminho da §4 (`doc-consolidator` → `ht-generator`).

---

## 7. De onde vem o contexto

| Fonte | Como chega | Quem lê |
|---|---|---|
| Google Drive (HUs, Regras) | `./sync-context.sh` → `docs/context_docs/md/` | todas as skills de doc |
| GitLab (issues, milestones) | `glab`, com as chaves do `.env` | backlog, discovery, sprint |
| Banco de homologação | `db-query`, via `DB_CONNECT_CMD` | `@tech-lead` |
| Figma | MCP, com as chaves do `.env` | skills de design |

O sync é one-way: **o Drive é a fonte de verdade**, `_raw/` e `md/` são cache derivado e
descartável. Rode antes de trabalhar em documentação, e agende no cron se quiser
(`SYNC_SETUP.md` explica).

## Onde cada coisa é gravada

| Pasta (no projeto) | Conteúdo | No Git? |
|---|---|---|
| `outputs/{ID}_{Nome}/` | `.md` consolidado + `.docx` gerado | só o `.md` |
| `history/` | discoveries, análises, priorizações | sim |
| `docs/context_docs/md/` | Drive convertido pra Markdown | cache, não |
| `prototype/` | app de protótipo React | sim, menos `dist/` |

---

## 8. Catálogo completo de skills

As 24 skills que existem hoje em `.agents/skills/`, física única. Detalhe de cada uma no
próprio `SKILL.md`.

**Personas** (ativam a thread principal, carregam as demais sob demanda):

| Skill | O que faz |
|---|---|
| `product-manager` | Entry point padrão. Produto, backlog, processo. |
| `tech-lead` | Viabilidade, dados reais (banco), impacto técnico, HT. |
| `product-designer` | Interface, protótipo, design system, export Figma. |

**Backlog e sprint** (carregadas pelo `@product-manager`, algumas pelo `@tech-lead`):

| Skill | O que faz |
|---|---|
| `backlog-issue-creator` | Cria/refina issue: template, MoSCoW, labels. |
| `backlog-prioritization` | Funil MoSCoW → quadrante I×E → ICE score, detecta anomalias. |
| `backlog-analysis` | Export via glab+jq → CSV + relatório de métricas/velocidade. |
| `backlog-health` | Audita issue sem tipo/prioridade/sprint, duplicata, zumbi. |
| `gitlab-sprint-ops` | Cria/fecha sprint, move issues em lote, documenta milestone. |
| `sprint-goal-generator` | Escreve a Meta da Sprint focada em outcome, não output. |
| `gitlab-wiki` | Publica/atualiza página na wiki do GitLab. |
| `changelog-generator` | Registra entrada no Histórico de Evolução a partir de HU/OS. |
| `glab-backlog` | Referência de comandos `glab`. Carregada **obrigatoriamente** por toda skill que fala com GitLab — não é gatilho direto do usuário. |

**Discovery e documentação** (`@product-manager` e `@tech-lead`):

| Skill | O que faz |
|---|---|
| `discovery` | Double Diamond D1/D2 — comentário por fase, bloco PRIORIZACAO. |
| `doc-consolidator` | Gera `outputs/{ID}_{Nome}/{ID}.md` — descrição + CA + RN (SBVR) + mensagens + referências + trilha do discovery. Para para revisão humana. |
| `hu-generator` | `.md` revisado → `.docx` de História de Usuário (9 seções). Só sob pedido explícito. |
| `ht-generator` | `.md` revisado → `.docx` de História Técnica (6 seções). Só sob pedido explícito. |

**Design** (`@product-designer`):

| Skill | O que faz |
|---|---|
| `design-setup` | Uma vez por projeto: extrai tokens de prints, faz o scaffold do `prototype/`. |
| `design-brief` | Antes de codar: o que a demanda vira em tela, o que reusa, o que falta. |
| `design-screen` | Cria/ajusta tela como rota React em `prototype/`. |
| `html-to-figma` | Opt-in, invocada pela `design-screen`/`design-setup`: captura DOM → Figma. |
| `figma-node-reader` | Subagente: transcreve node do Figma que estoura o limite de token. |
| `prototype-deploy` | Publica `prototype/` numa VPS: estático, basic auth, HTTPS. |

**Técnico** (`@tech-lead`):

| Skill | O que faz |
|---|---|
| `db-query` | Consulta o banco de homologação via cliente CLI do `.env` (qualquer autenticação). |

**Apoio manual** (gatilho explícito, nunca automático):

| Skill | O que faz |
|---|---|
| `committer` | Commit convencional + push + PR. Só roda com `@committer` explícito. |

---

## 9. O que o harness nunca faz sozinho

Vale o [`ENGAGEMENT.md`](../ENGAGEMENT.md), e as skills o carregam:

- **Write-gate** — antes de mexer em estado externo (issue, comentário, label, wiki,
  changelog, arquivo entregável, servidor), a skill mostra o que vai fazer e **espera
  aprovação**. Aprovação de um passo não vale pro próximo.
- **Context-gate** — faltou informação que muda o resultado? Uma pergunta focada, sem
  assumir. Leitura segue direto; escrita, não.
- **Commit** — `committer` é **manual**. Só roda quando você chama `@committer`.
