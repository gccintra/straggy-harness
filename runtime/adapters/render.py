#!/usr/bin/env python3
"""Renderiza os adapters de runtime a partir dos PERSONA.md resolvidos.

Fonte única por persona: <workflow>/PERSONA.md (mode, summary, tools, model + corpo) e
<workflow>/SKILL.md (name + description — o gatilho de roteamento). Chamado por
runtime/build.sh; não é executado à mão. Runtime novo = função nova aqui, mesma fonte.
"""
import json
import os
import pathlib
import re
import shutil
import sys

from harness import (ACAO_NENHUMA, TIPO_DEGRADADO, TIPO_ROTEAMENTO, carregar_evals,
                     carregar_resolucao, carregar_workflows, descobrir_personas)

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
CURSOR_RULES = RUNTIME / "cursor/rules"

# Persona padrão do pack — a mesma que o opencode.base.json declara. Se a organização
# desligar essa persona, cai na primeira primária descoberta.
PERSONA_PADRAO = "product-specialist"


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


def plant_skills_links():
    """Ponteiro de descoberta: <runtime>/skills → runtime/skills (pasta, não arquivo).

    Codex segue symlink de pasta e descarta SKILL.md que é link de arquivo. Claude e
    Cursor leem o mesmo ponteiro. OpenCode referencia SKILLS_REF no json, não pasta.
    """
    for nome in ("claude", "codex", "cursor"):
        dest = RUNTIME / nome / "skills"
        dest.parent.mkdir(parents=True, exist_ok=True)
        if dest.is_symlink() or dest.exists():
            if dest.is_dir() and not dest.is_symlink():
                shutil.rmtree(dest)
            else:
                dest.unlink()
        dest.symlink_to("../skills")


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


# ── Evals: fonte neutra → artefato de cada runner ─────────────────────────────
# Mesmo contrato dos adapters de persona (ARCHITECTURE §5 e §9): a fonte versionada é
# neutra, o artefato do runtime é gerado e descartável. Runtime sem runner de eval não
# recebe nada — declarar o seam vale mais que emitir arquivo que ninguém lê.

PROMPT_CLAUDE = """---
name: {nome}
tags: [{tags}]
plugins: ["../.."]
runs: 1
max_turns: {turnos}
---

{frase}
"""

GRADER_DISPARA = """---
type: tool_used
tool: Skill
input_match: '"skill"\\s*:\\s*"(?:[\\w-]+:)?{workflow}"'
arm: both
---

Frase que a ação **{acao}** atende. Não disparar aqui significa que o gatilho declarado
na `description` não cobre como o usuário realmente pede este trabalho.
"""

GRADER_NAO_DISPARA = """---
type: tool_used
tool: Skill
input_match: '"skill"\\s*:\\s*"(?:[\\w-]+:)?{workflow}"'
min: 0
max: 0
arm: both
---

Esta frase é atendida por **{dono}**, não por `{workflow}`. {motivo}

Disparar aqui é falso positivo de gatilho: o trabalho errado começa, e o certo não
acontece.
"""

CRITERIO_DEGRADADO = (pathlib.Path(os.environ["PROVIDERS_DIR"]) / "eval-runner"
                      / "criterios" / "modo-degradado.md")


def grader_degradado(dominio):
    """Mesmo critério que o `eval.sh` usa — lido do arquivo, nunca copiado."""
    texto = CRITERIO_DEGRADADO.read_text(encoding="utf-8").split("---\n", 1)[1]
    corpo = "\n".join("  " + l for l in texto.replace("{dominio}", dominio).strip().splitlines())
    return f"---\ntype: llm\nfocus: last_message\ncriteria: |\n{corpo}\n---\n"


def _escrever_caso(destino, nome, tags, frase, turnos, graders):
    destino.mkdir(parents=True, exist_ok=True)
    (destino / "prompt.md").write_text(
        PROMPT_CLAUDE.format(nome=nome, tags=", ".join(tags), turnos=turnos, frase=frase),
        encoding="utf-8")
    dir_graders = destino / "graders"
    dir_graders.mkdir(exist_ok=True)
    for arquivo, conteudo in graders.items():
        (dir_graders / f"{arquivo}.md").write_text(conteudo, encoding="utf-8")


def render_evals_plugin_eval(workflows):
    """Traduz a fonte neutra para o formato do `claude plugin eval`.

    Cada fonte vira um caso positivo no workflow que atende e um negativo em CADA
    workflow que ela declara como confundível — a mesma frase, dos dois lados.

    O pareamento é estrutural, não convenção: negativo e positivo saem do mesmo arquivo,
    então não existe estado em que a frase da contraprova deixou de ser a frase real da
    vizinha. Era o buraco de escrever os dois casos à mão.
    """
    por_acao = {wf["acao"]["id"]: wf["nome"] for wf in workflows
                if wf["acao"] and wf["acao"]["id"]}
    escritos = 0
    for wf in workflows:
        for caso in wf["evals"]:
            if not caso["tem_fonte"] or not caso["frase"]:
                continue
            base = SKILLS / wf["nome"] / "evals"

            if caso["tipo"] == TIPO_DEGRADADO:
                _escrever_caso(
                    base / caso["id"], f"{wf['nome']}-{caso['id']}",
                    ["contrato", "modo-degradado"], caso["frase"], 6,
                    {"para-e-avisa": grader_degradado(caso["provider"])})
                escritos += 1
                continue

            if caso["atende"] != ACAO_NENHUMA:
                _escrever_caso(
                    base / caso["id"], f"{wf['nome']}-{caso['id']}",
                    ["roteamento"], caso["frase"], 3,
                    {"dispara": GRADER_DISPARA.format(workflow=wf["nome"],
                                                      acao=caso["atende"])})
                escritos += 1
                dono = f"`{caso['atende']}`"
            else:
                dono = "nenhuma ação"

            for rival in caso["confunde_com"]:
                alvo = por_acao.get(rival)
                if not alvo:
                    continue
                _escrever_caso(
                    SKILLS / alvo / "evals" / f"{caso['id']}--nao",
                    f"{alvo}-{caso['id']}-nao", ["roteamento"], caso["frase"], 3,
                    {"nao-dispara": GRADER_NAO_DISPARA.format(
                        workflow=alvo, dono=dono, motivo=caso["motivo"])})
                escritos += 1
    return escritos


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


def _persona_padrao(personas):
    """Mesma escolha do opencode: product-specialist se for primária, senão a primeira."""
    primarias = [p for p in personas if p["mode"] == "primary"]
    nomes = {p["name"] for p in primarias}
    if PERSONA_PADRAO in nomes:
        return PERSONA_PADRAO
    return primarias[0]["name"] if primarias else ""


def render_cursor(personas, aliases):
    """Rules `.mdc`. Fonte: o mesmo PERSONA.md / SKILL.md dos outros.

    Cursor: `runtime/cursor/` vira `.cursor` por symlink, como os outros runtimes — salvo
    quando o IDE já criou `.cursor/` (MCP, settings); aí o install planta só as rules.
    O ponteiro `skills → ../skills` é o mesmo dos outros adapters (`plant_skills_links`).
    """
    limpar(CURSOR_RULES)

    padrao = _persona_padrao(personas)
    troca = ", ".join(f"`@{p['name']}`" for p in personas if p["mode"] == "primary")
    (CURSOR_RULES / "harness.mdc").write_text(
        "---\n"
        "description: Constituição e persona padrão do harness de product management\n"
        "alwaysApply: true\n"
        "---\n\n"
        "Você opera pelo harness de PM. Fonte de verdade, nesta ordem:\n\n"
        "1. Constituição — `system/CONSTITUTION.md` (projeto consumidor: "
        "`.agents/system/CONSTITUTION.md`). Em conflito, ela vence.\n"
        "2. Convenções — `org/ORG.md` (ou `.agents/org/ORG.md`).\n"
        f"3. Persona padrão: **{padrao}**. Troca explícita: {troca or '—'}.\n"
        "4. Workflows — skills do projeto (`.agents/skills/` ou `.cursor/skills/`). "
        "Carregue pelo gatilho da `description`; não invente procedimento.\n\n"
        "`AGENTS.md` local complementa, nunca substitui a constituição.\n",
        encoding="utf-8")

    for p in personas:
        cabecalho = ["description: >", bloco_yaml(p["description"]), "alwaysApply: false"]
        (CURSOR_RULES / f"{p['name']}.mdc").write_text(
            "---\n" + "\n".join(cabecalho) + "\n---\n\n" + p["body"] + "\n",
            encoding="utf-8")

    for alias, alvo, texto in aliases:
        (CURSOR_RULES / f"{alias}.mdc").write_text(
            "---\n"
            f"description: {texto}\n"
            "alwaysApply: false\n"
            "---\n\n"
            f"`{alias}` é alias de **`{alvo}`**. Siga `@{alvo}` com a mesma demanda.\n",
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
    render_cursor(personas, aliases)
    plant_skills_links()

    # Só `claude-plugin-eval` consome artefato em disco; as implementações headless leem
    # a fonte neutra direto (system/providers/eval-runner/INTERFACE.md). Implementação nova
    # que precise de arquivo próprio entra aqui como render_evals_<nome>.
    workflows = carregar_workflows(carregar_resolucao(
        pathlib.Path(os.environ["RESOLUCAO"]).read_text(encoding="utf-8")))
    casos = render_evals_plugin_eval(workflows)

    primarias = sum(1 for p in personas if p["mode"] == "primary")
    print(f"{len(personas)} persona(s) ({primarias} primária(s)), "
          f"{len(aliases)} alias(es) — claude, codex, opencode e cursor gerados.")
    print(f"evals: {casos} caso(s) renderizado(s) para a implementação "
          f"claude-plugin-eval (as headless leem caso.yaml direto)")


if __name__ == "__main__":
    main()
