# runtime/adapters — fonte dos adapters gerados

`runtime/build.sh` gera `runtime/claude/{agents,commands}/`, `runtime/codex/agents/` e
`runtime/opencode/opencode.json` a partir de **uma** fonte por persona:
`<workflow>/PERSONA.md`, resolvido junto com o resto do workflow (pack ∪ org — a
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
| `aliases.tsv` | `alias<TAB>persona<TAB>descrição` — gera um slash-command por linha |
| `codex.defaults` | `model=<id>` usado quando o `PERSONA.md` não declara |
