# Websis Product Management Harness

Harness compartilhado de Product Management para Codex, Claude Code e OpenCode.

## Instalação em um projeto

```bash
git submodule add https://github.com/gc-product-management/websis-pm-harness.git .agents
./.agents/install.sh
```

O instalador cria somente links de integração:

```text
.claude    -> .agents/runtime/claude
.codex     -> .agents/runtime/codex
.opencode  -> .agents/runtime/opencode
.mcp.json  -> .agents/runtime/claude/mcp.json
```

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

- `.env`
- `project-config.md`
- `docs/context_docs/`
- `history/`
- `outputs/`

As skills resolvem esses caminhos a partir da raiz Git do projeto consumidor.
