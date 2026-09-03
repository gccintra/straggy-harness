# runtime/adapters — fonte dos adapters gerados

`runtime/build.sh` gera `runtime/claude/{agents,commands}/`, `runtime/codex/agents/`,
`runtime/opencode/opencode.json` e `runtime/cursor/rules/` a partir de **uma** fonte por
persona: `<workflow>/PERSONA.md`, resolvido junto com o resto do workflow (pack ∪ org — a
organização sobrescreve o `PERSONA.md` como qualquer outro arquivo).

Nada aqui é editado por skill; nada gerado é versionado (`.gitignore`).

## `PERSONA.md` — contrato

```markdown
---
mode: primary | subagent        # primary também vira slash-command
summary: <uma linha — descrição do slash-command e do agente no Codex/OpenCode>
tools: Read, Write, Bash        # opcional; restringe as ferramentas (Claude Code)
model: <id>                     # opcional; default em codex.model deste README
---

<corpo: instruções da persona, agnósticas de runtime>
```

`name` e `description` (o gatilho de roteamento) **não** aparecem aqui: saem do
`SKILL.md` do mesmo workflow, que é a fonte única.

## Arquivos desta pasta

| Arquivo | Papel |
|---|---|
| `opencode.base.json` | esqueleto do `opencode.json` — permissões e chaves fixas; o build injeta o bloco `agent` |
| `aliases.tsv` | `alias<TAB>persona<TAB>descrição` — gera um slash-command por linha (Claude) e uma rule por linha (Cursor) |
| `codex.defaults` | `model=<id>` usado quando o `PERSONA.md` não declara |

Cursor CLI (`agent`) lê `.cursor/rules/*.mdc` e `.cursor/skills/`. Claude, Codex e Cursor
ganham o mesmo ponteiro: `runtime/<runtime>/skills → ../skills` (symlink de pasta). O Codex
segue pasta-link e descarta `SKILL.md` que é link de arquivo. Install: se `.cursor` **não
existe**, symlink da pasta inteira — igual `.claude` / `.codex` / `.opencode`. Se o IDE já
criou `.cursor/` (MCP, settings), planta só os `.mdc` em `.cursor/rules/`. Headless
(`agent -p`) é o mesmo adapter; o runner de eval entra quando o restante estiver no ar.
