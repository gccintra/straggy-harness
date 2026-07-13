# Websis Product Management Harness

Harness compartilhado de Product Management para Codex, Claude Code e OpenCode.
Três personas (`@product-manager`, `@tech-lead`, `@product-designer`) e as skills de
backlog, discovery, documentação, design e deploy que elas carregam.

**→ [`docs/FLUXO.md`](docs/FLUXO.md) — instalação, configuração e qual skill entra em cada
momento do trabalho. Comece por aí.**

## Instalação em um projeto

O harness vive em `<projeto>/.agents/`, como submódulo registrado **ou** clone local que o
projeto ignora no Git — o instalador funciona nos dois casos.

```bash
cd <raiz-do-projeto>
git clone https://github.com/gc-product-management/websis-pm-harness.git .agents
./.agents/install.sh
```

O instalador cria os links de integração:

```text
.claude          -> .agents/runtime/claude
.codex           -> .agents/runtime/codex
.opencode        -> .agents/runtime/opencode
sync-context.sh  -> .agents/sync-context.sh
```

E semeia os dois arquivos de configuração do projeto, **sem sobrescrever se já existirem**:

```text
project-config.md  <- project-config.template.md   (versionado no projeto)
.env               <- .env.example                 (fora do Git — tem segredo)
```

Preencha os dois antes de usar as skills. Detalhes em [`docs/FLUXO.md`](docs/FLUXO.md#2-configurar).

As skills vivem fisicamente apenas em `.agents/skills`. Codex e OpenCode descobrem esse caminho
nativamente; Claude Code acessa as mesmas skills pelo link em `runtime/claude/skills`.

## Regras de engajamento vs. override local

- **`.agents/ENGAGEMENT.md`** — regras invariantes do harness (brevidade, write-gate, context-gate,
  personas, delegação seletiva, core-vs-adapter). Versionadas com o harness, iguais para todo usuário
  e runtime. Chegam aos 3 runtimes pela camada de skill/persona, que referencia este arquivo.
- **`AGENTS.md`/`CLAUDE.md` na raiz do projeto** — override **local e opcional** do consumidor.
  Complementam, não substituem, o `ENGAGEMENT.md`. Não são shipados pelo harness (o `.agents/.gitignore`
  ignora `AGENTS.md`).

## Core vs. adapter

- Lógica de produto/processo → skill compartilhada em `.agents/skills/`.
- Regra invariante de comportamento → `.agents/ENGAGEMENT.md`.
- Como cada runtime spawna / configura / define persona → adapter em `.agents/runtime/<runtime>/`
  (ex.: personas do Codex em `runtime/codex/agents/*.toml`, do Claude em `runtime/claude/agents/*.md`,
  do OpenCode em `runtime/opencode/opencode.json`).

## Atualização

```bash
git -C .agents pull --ff-only
git add .agents
```

O segundo comando atualiza no projeto consumidor a revisão registrada do submódulo.

## Conteúdo específico do projeto

Cada projeto consumidor mantém na própria raiz:

- `.env` — credenciais e IDs (GitLab, Drive, Figma, banco). Semeado do `.env.example`. Fora do Git.
- `project-config.md` — cliente, projeto, URL das issues, caminhos de output, deploy do
  protótipo. Semeado do `project-config.template.md`. Versionado no projeto.
- `docs/context_docs/` — Drive sincronizado (cache derivado, não versionado)
- `history/` — discoveries, análises, priorizações
- `outputs/` — `.md` consolidado + `.docx` por issue

As skills resolvem esses caminhos a partir da raiz Git do projeto consumidor.
**Nenhuma skill tem valor de projeto hard-coded** — tudo que varia está no `.env` e no
`project-config.md`.
