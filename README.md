# Websis Product Management Harness

Harness compartilhado de Product Management para Codex, Claude Code e OpenCode.

## Instalação em um projeto

```bash
git submodule add https://github.com/gc-product-management/websis-pm-harness.git .agents
./.agents/install.sh
```

O instalador cria somente links de integração:

```text
AGENTS.md  -> .agents/AGENTS.md
CLAUDE.md  -> .agents/AGENTS.md
.claude    -> .agents/runtime/claude
.codex     -> .agents/runtime/codex
.opencode  -> .agents/runtime/opencode
.mcp.json  -> .agents/runtime/claude/mcp.json
```

As skills vivem fisicamente apenas em `.agents/skills`. Codex e OpenCode descobrem esse caminho
nativamente; Claude Code acessa as mesmas skills pelo link em `runtime/claude/skills`.

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
