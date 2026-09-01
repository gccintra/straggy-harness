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

Cursor CLI (`agent`) lê `.cursor/rules/*.mdc` e descobre skills em `.agents/skills/` (já
o ponto de descoberta do Codex). O `.cursor/` do IDE não é substituído: o install planta
só os `.mdc` gerados em `.cursor/rules/`. Quando este repo **é** o projeto, o `build.sh`
planta também `.cursor/skills` → `runtime/skills`. Headless (`agent -p`) é o mesmo
adapter; o runner de eval entra quando o restante estiver no ar.
