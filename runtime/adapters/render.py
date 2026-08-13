#!/usr/bin/env python3
"""Renderiza os adapters de runtime a partir dos PERSONA.md resolvidos.

Fonte única por persona: <workflow>/PERSONA.md (mode, summary, tools, model + corpo) e
<workflow>/SKILL.md (name + description — o gatilho de roteamento). Chamado por
runtime/build.sh; não é executado à mão.
"""
import json
import os
import pathlib
import re
import shutil
import sys

from harness import descobrir_personas

ADAPTERS = pathlib.Path(os.environ["ADAPTERS_DIR"])
SKILLS = pathlib.Path(os.environ["OUT_DIR"])
RUNTIME = pathlib.Path(os.environ["RUNTIME_DIR"])

# Como o runtime se refere às skills resolvidas dentro do projeto. Configurável porque
# no sandbox do produto a visão resolvida não mora em `.agents/`.
SKILLS_REF = os.environ.get("SKILLS_REF", ".agents/runtime/skills")

CLAUDE_AGENTS = RUNTIME / "claude/agents"
CLAUDE_COMMANDS = RUNTIME / "claude/commands"
CODEX_AGENTS = RUNTIME / "codex/agents"
OPENCODE_JSON = RUNTIME / "opencode/opencode.json"


def bloco_yaml(valor, indent="  "):
    linhas = [l for l in re.split(r"\s*\n\s*", valor.strip()) if l]
    texto = " ".join(linhas)
    envoltas, atual = [], ""
    for palavra in texto.split(" "):
        if len(atual) + len(palavra) + 1 > 92:
            envoltas.append(atual)
            atual = palavra
        else:
            atual = f"{atual} {palavra}".strip()
    if atual:
        envoltas.append(atual)
    return "\n".join(indent + l for l in envoltas)


def limpar(diretorio):
    if diretorio.exists():
        shutil.rmtree(diretorio)
    diretorio.mkdir(parents=True)


def render_claude(personas, aliases):
    limpar(CLAUDE_AGENTS)
    limpar(CLAUDE_COMMANDS)

    for p in personas:
        cabecalho = [f"name: {p['name']}", "description: >", bloco_yaml(p["description"])]
        if p["tools"]:
            cabecalho.append(f"tools: {p['tools']}")
        (CLAUDE_AGENTS / f"{p['name']}.md").write_text(
            "---\n" + "\n".join(cabecalho) + "\n---\n\n" + p["body"] + "\n",
            encoding="utf-8")

        if p["mode"] != "primary":
            continue
        (CLAUDE_COMMANDS / f"{p['name']}.md").write_text(
            "---\n"
            f"description: {p['summary']}\n"
            "argument-hint: [pedido em linguagem natural]\n"
            "---\n\n"
            + p["body"]
            + "\n\nDemanda: $ARGUMENTS\n",
            encoding="utf-8")

    for alias, alvo, texto in aliases:
        (CLAUDE_COMMANDS / f"{alias}.md").write_text(
            "---\n"
            f"description: {texto}\n"
            "argument-hint: [pedido em linguagem natural]\n"
            "---\n\n"
            f"`{alias}` é alias de **`{alvo}`**. Siga `/{alvo}` com a mesma demanda.\n\n"
            "Demanda: $ARGUMENTS\n",
            encoding="utf-8")


def render_codex(personas, modelo_default):
    limpar(CODEX_AGENTS)
    for p in personas:
        modelo = p["model"] or modelo_default
        instrucoes = (
            p["body"]
            + f"\n\nFonte de verdade do comportamento: `{SKILLS_REF}/"
            + f"{p['name']}/SKILL.md`. Não duplique regra aqui."
        )
        (CODEX_AGENTS / f"{p['name']}.toml").write_text(
            f'name = "{p["name"]}"\n'
            f'description = "{p["summary"]}"\n'
            f'model = "{modelo}"\n'
            'developer_instructions = """\n'
            + instrucoes.replace('"""', '\\"\\"\\"')
            + '\n"""\n',
            encoding="utf-8")


def render_opencode(personas):
    base = json.loads((ADAPTERS / "opencode.base.json").read_text(encoding="utf-8"))
    permissao = {"bash": "allow", "read": "allow", "edit": "allow", "skill": {"*": "allow"}}
    base["agent"] = {
        p["name"]: {
            "description": p["summary"],
            "mode": p["mode"],
            "prompt": f"{{file:../{SKILLS_REF}/{p['name']}/SKILL.md}}",
            "permission": permissao,
        }
        for p in personas
    }
    primarias = [p["name"] for p in personas if p["mode"] == "primary"]
    if base.get("default_agent") not in primarias:
        if not primarias:
            base.pop("default_agent", None)
        else:
            base["default_agent"] = primarias[0]
    OPENCODE_JSON.parent.mkdir(parents=True, exist_ok=True)
    OPENCODE_JSON.write_text(json.dumps(base, indent=2, ensure_ascii=False) + "\n",
                             encoding="utf-8")


def main():
    personas = descobrir_personas(SKILLS)
    if not personas:
        print("nenhuma persona encontrada (nenhum PERSONA.md em runtime/skills/).",
              file=sys.stderr)

    aliases = []
    caminho_aliases = ADAPTERS / "aliases.tsv"
    nomes = {p["name"] for p in personas}
    if caminho_aliases.exists():
        for linha in caminho_aliases.read_text(encoding="utf-8").splitlines():
            if not linha.strip() or linha.startswith("#"):
                continue
            partes = linha.split("\t")
            if len(partes) < 3:
                print(f"aviso: linha inválida em aliases.tsv: {linha}", file=sys.stderr)
                continue
            if partes[1] not in nomes:
                print(f"aviso: alias '{partes[0]}' aponta para persona inexistente "
                      f"'{partes[1]}' — ignorado.", file=sys.stderr)
                continue
            aliases.append(partes[:3])

    modelo = "gpt-5.5"
    caminho_defaults = ADAPTERS / "codex.defaults"
    if caminho_defaults.exists():
        for linha in caminho_defaults.read_text(encoding="utf-8").splitlines():
            if linha.startswith("model="):
                modelo = linha.split("=", 1)[1].strip()

    render_claude(personas, aliases)
    render_codex(personas, modelo)
    render_opencode(personas)

    primarias = sum(1 for p in personas if p["mode"] == "primary")
    print(f"{len(personas)} persona(s) ({primarias} primária(s)), "
          f"{len(aliases)} alias(es) — claude, codex e opencode gerados.")


if __name__ == "__main__":
    main()
