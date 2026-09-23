# runtime/adapters — fonte dos adapters gerados

`runtime/build.sh` gera `runtime/claude/{agents,commands}/`, `runtime/codex/agents/`,
`runtime/opencode/opencode.json` e `runtime/cursor/rules/` a partir de **uma** fonte por
persona: `<workflow>/PERSONA.md`, resolvido junto com o resto do workflow (pack ∪ org — a
organização sobrescreve o `PERSONA.md` como qualquer outro arquivo).

Nada aqui é editado por skill; nada gerado é versionado (`.gitignore`).

## `PERSONA.md` — contrato

```markdown
---
mode: primary | subagent        # primary: pode ser o agente padrão do OpenCode
summary: <uma linha — descrição do agente no Codex/OpenCode>
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
| `aliases.tsv` | `alias<TAB>persona<TAB>descrição` — gera um slash-command por linha (Claude). Nos outros runtimes a persona é invocada pelo nome da skill |
| `codex.defaults` | `model=<id>` usado quando o `PERSONA.md` não declara |

**Um ponteiro de skills por runtime, e só onde ele não acha sozinho.** `.agents/skills`
(plantado pelo `build.sh`) é lido por Codex, Cursor e OpenCode. O Claude só lê
`.claude/skills`, então é o único com `runtime/claude/skills → ../skills`. O Codex segue
pasta-link e descarta `SKILL.md` que é link de arquivo. Persona é skill: `/<persona>` em
todos os runtimes. O Claude ganha também o subagente (`agents/`), que é a porta de
delegação, mas não ganha slash-command por persona, porque a skill de mesmo nome já é o
comando. Cursor: só `harness.mdc` (`alwaysApply`). Install: se `.cursor` **não existe**,
symlink da pasta inteira — igual `.claude` / `.codex` / `.opencode`. Se o IDE já criou
`.cursor/` (MCP, settings), planta só `harness.mdc` em `.cursor/rules/` e remove os links
órfãos de rule que o harness deixou de gerar. Headless
(`agent -p`) é o mesmo adapter; o runner de eval entra quando o restante estiver no ar.
