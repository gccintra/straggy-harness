#!/usr/bin/env python3
"""O contrato do harness como dado: parse do frontmatter, validação e manifesto.

Duas entradas:

* **importado** por `render.py` — `frontmatter()` e `descobrir_personas()`;
* **executado** por `runtime/build.sh` — recebe a tabela de resolução por stdin
  (`nome<TAB>origem<TAB>pack<TAB>org<TAB>resolvido`, uma linha por workflow), valida o
  contrato e escreve `manifest.json`.

Não é executado à mão. A regra que este módulo faz valer está em `docs/ARCHITECTURE.md`
§7 (ações e encaixes) e §8 (manifesto); a superfície pública, em `system/ACOES.md`.
"""
from __future__ import annotations

import json
import os
import pathlib
import re
import sys

# Versão do formato do manifesto. Consumidor externo (API do Hub) pina este número:
# mudança incompatível incrementa, campo aditivo não.
SCHEMA = 1

# Tipos de campo que uma interface precisa saber renderizar. Fechado de propósito —
# tipo novo exige a interface saber desenhá-lo (docs/ARCHITECTURE.md §7).
TIPOS_ENCAIXE = ("texto-longo", "arquivo", "imagem", "script")

ERRO, AVISO = "erro", "aviso"


# ── Frontmatter ───────────────────────────────────────────────────────────────
# Subconjunto de YAML deliberadamente pequeno: escalar, bloco '>' e '|', mapa
# aninhado e sequência (de escalar ou de mapa). Sem âncora, sem fluxo inline, sem
# multi-documento. Linha vazia não é significativa; comentário só em linha própria.

def _tokenizar(texto):
    return [(len(l) - len(l.lstrip()), l.strip()) for l in texto.split("\n")]


def _pular_vazias(tokens, i):
    while i < len(tokens) and (not tokens[i][1] or tokens[i][1].startswith("#")):
        i += 1
    return i


def _escalar(bruto):
    valor = bruto.strip()
    if len(valor) >= 2 and valor[0] == valor[-1] and valor[0] in "\"'":
        return valor[1:-1]
    if valor in ("true", "false"):
        return valor == "true"
    # Lista em linha: aceita porque escrever `[a, b]` é natural e o silêncio do
    # contrário seria pior — a lista viraria string sem ninguém perceber.
    if valor.startswith("[") and valor.endswith("]"):
        return [_escalar(p) for p in valor[1:-1].split(",") if p.strip()]
    return valor


def _escalar_bloco(tokens, i, indent, dobrar):
    """Consome as linhas mais indentadas que `indent` como bloco '>' (dobrar) ou '|'."""
    partes = []
    while i < len(tokens):
        ind, conteudo = tokens[i]
        if conteudo and ind <= indent:
            break
        partes.append(conteudo)
        i += 1
    while partes and not partes[-1]:
        partes.pop()
    texto = " ".join(p for p in partes if p) if dobrar else "\n".join(partes)
    return texto, i


_CHAVE = re.compile(r"^([A-Za-z_][\w.-]*):\s*(.*)$")


def _bloco(tokens, i, indent_minimo):
    """Mapa ou sequência começando em `i`, exigindo indentação >= `indent_minimo`."""
    j = _pular_vazias(tokens, i)
    if j >= len(tokens) or tokens[j][0] < indent_minimo:
        return None, i
    if tokens[j][1].startswith("- "):
        return _sequencia(tokens, j, tokens[j][0])
    return _mapa(tokens, j, tokens[j][0])


def _mapa(tokens, i, nivel):
    campos = {}
    while True:
        i = _pular_vazias(tokens, i)
        if i >= len(tokens):
            break
        ind, conteudo = tokens[i]
        if ind != nivel:
            break
        m = _CHAVE.match(conteudo)
        if not m:
            break
        chave, valor = m.group(1), m.group(2).strip()
        if valor in (">", ">-"):
            campos[chave], i = _escalar_bloco(tokens, i + 1, ind, True)
        elif valor in ("|", "|-"):
            campos[chave], i = _escalar_bloco(tokens, i + 1, ind, False)
        elif valor == "":
            filho, i = _bloco(tokens, i + 1, ind + 1)
            campos[chave] = filho if filho is not None else ""
        else:
            campos[chave] = _escalar(valor)
            i += 1
    return campos, i


def _sequencia(tokens, i, nivel):
    itens = []
    while True:
        i = _pular_vazias(tokens, i)
        if i >= len(tokens):
            break
        ind, conteudo = tokens[i]
        if ind != nivel or not conteudo.startswith("- "):
            break
        corpo = conteudo[2:].strip()
        m = _CHAVE.match(corpo)
        if not m:
            itens.append(_escalar(corpo))
            i += 1
            continue
        # Item que é mapa: a primeira entrada vem na própria linha do '- ', as
        # demais vêm indentadas na coluna logo após ele.
        item, chave, valor = {}, m.group(1), m.group(2).strip()
        if valor == "":
            filho, i = _bloco(tokens, i + 1, ind + 3)
            item[chave] = filho if filho is not None else ""
        else:
            item[chave] = _escalar(valor)
            i += 1
        resto, i = _mapa(tokens, _pular_vazias(tokens, i), ind + 2)
        item.update(resto)
        itens.append(item)
    return itens, i


def frontmatter(path):
    """Devolve (campos, corpo). Arquivo sem frontmatter → ({}, texto inteiro)."""
    texto = pathlib.Path(path).read_text(encoding="utf-8")
    m = re.match(r"^---\n(.*?)\n---\n?(.*)$", texto, re.S)
    if not m:
        return {}, texto.strip()
    campos, _ = _mapa(_tokenizar(m.group(1)), 0, 0)
    return campos, m.group(2).strip()


# ── Normalização das declarações ──────────────────────────────────────────────
# Toda declaração aceita forma curta (string) e forma longa (mapa). A curta serve o
# modo repositório, onde ninguém precisa de rótulo; a longa alimenta a interface.

def _rotulo_de(ident):
    return ident.replace("-", " ").replace("_", " ").capitalize() if ident else ""


def normalizar_acao(valor):
    if isinstance(valor, dict):
        ident = str(valor.get("id", "")).strip()
        return {
            "id": ident,
            "rotulo": str(valor.get("rotulo", "")).strip() or _rotulo_de(ident),
            "descricao": str(valor.get("descricao", "")).strip(),
            "rotulo_declarado": bool(str(valor.get("rotulo", "")).strip()),
        }
    if isinstance(valor, str) and valor.strip():
        ident = valor.strip()
        return {"id": ident, "rotulo": _rotulo_de(ident), "descricao": "",
                "rotulo_declarado": False}
    return None


def normalizar_encaixes(valor):
    """{nome: caminho} ou {nome: {caminho, rotulo, ajuda, tipo, essencial}} → lista."""
    if not isinstance(valor, dict):
        return []
    encaixes = []
    for nome, corpo in valor.items():
        if isinstance(corpo, dict):
            encaixes.append({
                "id": nome,
                "caminho": str(corpo.get("caminho", "")).strip(),
                "rotulo": str(corpo.get("rotulo", "")).strip() or _rotulo_de(nome),
                "ajuda": str(corpo.get("ajuda", "")).strip(),
                "tipo": str(corpo.get("tipo", "")).strip() or "texto-longo",
                "essencial": corpo.get("essencial") is True,
                "completo": bool(str(corpo.get("rotulo", "")).strip()
                                 and str(corpo.get("ajuda", "")).strip()
                                 and str(corpo.get("tipo", "")).strip()),
            })
        else:
            encaixes.append({
                "id": nome, "caminho": str(corpo).strip(), "rotulo": _rotulo_de(nome),
                "ajuda": "", "tipo": "texto-longo", "essencial": False, "completo": False,
            })
    return sorted(encaixes, key=lambda e: e["id"])


def normalizar_artefato(valor):
    if isinstance(valor, dict):
        ident = str(valor.get("id", "")).strip()
        return {"id": ident, "rotulo": str(valor.get("rotulo", "")).strip()
                or _rotulo_de(ident)} if ident else None
    if isinstance(valor, str) and valor.strip():
        return {"id": valor.strip(), "rotulo": _rotulo_de(valor.strip())}
    return None


def _lista(valor):
    if isinstance(valor, list):
        return valor
    if isinstance(valor, str) and valor.strip():
        return [valor.strip()]
    return []


# O que um sandbox precisa provisionar para uma implementação rodar. Cada bucket é uma
# ação diferente de quem prepara o ambiente — por isso são separados (ARCHITECTURE §4).
BUCKETS_REQUISITO = ("binarios", "pacotes", "variaveis", "servicos", "hosts")


def normalizar_requisitos(valor):
    """Requisitos de execução de uma implementação de provider (ARCHITECTURE §4)."""
    if not isinstance(valor, dict):
        return {}
    return {chave: sorted(str(v) for v in _lista(valor.get(chave)))
            for chave in BUCKETS_REQUISITO if valor.get(chave)}


# ── Descoberta ────────────────────────────────────────────────────────────────

def carregar_resolucao(texto):
    """Tabela emitida por build.sh: nome, origem, pack, org, resolvido (TAB)."""
    linhas = []
    for linha in texto.splitlines():
        if not linha.strip():
            continue
        partes = (linha.split("\t") + [""] * 5)[:5]
        linhas.append({"nome": partes[0], "origem": partes[1], "pack": partes[2],
                       "org": partes[3], "resolvido": partes[4]})
    return sorted(linhas, key=lambda w: w["nome"])


def carregar_workflows(resolucao):
    for wf in resolucao:
        skill = pathlib.Path(wf["resolvido"]) / "SKILL.md"
        wf["skill_existe"] = skill.exists()
        campos = frontmatter(skill)[0] if skill.exists() else {}
        wf["campos"] = campos
        wf["acao"] = normalizar_acao(campos.get("acao"))
        wf["encaixes"] = normalizar_encaixes(campos.get("encaixes"))
        wf["produz"] = normalizar_artefato(campos.get("produz"))
        wf["requer"] = [a for a in (normalizar_artefato(v)
                                    for v in _lista(campos.get("requer"))) if a]
        wf["requer_condicional"] = [
            {"artefato": str(item.get("artefato", "")).strip(),
             "quando": str(item.get("quando", "")).strip()}
            for item in _lista(campos.get("requer_condicional"))
            if isinstance(item, dict) and item.get("artefato") and item.get("quando")
        ]
        wf["persona"] = (pathlib.Path(wf["resolvido"]) / "PERSONA.md").exists()
    return resolucao


def descobrir_personas(dir_skills):
    """Personas resolvidas: PERSONA.md (identidade) + SKILL.md (gatilho). Usado por render.py."""
    personas = []
    for caminho in sorted(pathlib.Path(dir_skills).glob("*/PERSONA.md")):
        nome = caminho.parent.name
        skill = caminho.parent / "SKILL.md"
        if not skill.exists():
            print(f"aviso: '{nome}' tem PERSONA.md sem SKILL.md — ignorado.", file=sys.stderr)
            continue
        meta, corpo = frontmatter(caminho)
        descricao = str(frontmatter(skill)[0].get("description", "")).strip()
        if not descricao:
            print(f"aviso: '{nome}' sem description no SKILL.md.", file=sys.stderr)
        personas.append({
            "name": nome,
            "description": descricao,
            "summary": meta.get("summary") or descricao.split(".")[0],
            "mode": meta.get("mode", "primary"),
            "tools": meta.get("tools", ""),
            "model": meta.get("model", ""),
            "body": corpo,
        })
    return personas


def descobrir_providers(*diretorios):
    """Domínios de provider e requisitos de execução declarados por implementação.

    Varre as raízes na ordem dada (sistema, depois organização): implementação própria da
    organização entra no mesmo domínio, sob a mesma interface (ARCHITECTURE §4).
    """
    dominios = {}
    for indice, dir_raiz in enumerate(diretorios):
        raiz = pathlib.Path(dir_raiz) if dir_raiz else None
        if not raiz or not raiz.is_dir():
            continue
        posse = "sistema" if indice == 0 else "organizacao"
        for pasta in sorted(p for p in raiz.iterdir() if p.is_dir()):
            for arquivo in sorted(pasta.glob("*.md")):
                if arquivo.name == "INTERFACE.md":
                    continue
                campos = frontmatter(arquivo)[0]
                dominios.setdefault(pasta.name, []).append({
                    "id": arquivo.stem,
                    "posse": posse,
                    "capacidades": sorted(str(c)
                                          for c in _lista(campos.get("capacidades"))),
                    "requisitos": normalizar_requisitos(campos.get("requisitos")),
                    "declarado": bool(campos.get("requisitos")),
                })
    return [{"id": nome, "implementacoes": dominios[nome]} for nome in sorted(dominios)]


# ── Validação ─────────────────────────────────────────────────────────────────

def validar(workflows, dir_pack):
    """Devolve lista de (severidade, mensagem). Erro reprova o build sempre."""
    problemas = []
    pack = pathlib.Path(dir_pack)

    def erro(msg):
        problemas.append((ERRO, msg))

    def aviso(msg):
        problemas.append((AVISO, msg))

    vistas = {}
    for wf in workflows:
        nome, origem = wf["nome"], wf["origem"]
        do_pack = origem in ("pack", "pack+encaixes")

        if not wf["skill_existe"]:
            erro(f"'{nome}' não tem SKILL.md.")
            continue

        if not str(wf["campos"].get("description", "")).strip():
            erro(f"'{nome}' não tem 'description' — sem gatilho, a ação é inalcançável.")

        acao = wf["acao"]
        if origem == "sistema":
            pass
        elif not acao or not acao["id"]:
            aviso(f"'{nome}' não declara 'acao' no frontmatter (ARCHITECTURE §7).")
        else:
            if acao["id"] in vistas:
                erro(f"ação '{acao['id']}' declarada por '{vistas[acao['id']]}' e por "
                     f"'{nome}' — ação é contrato público e não pode ter dois donos.")
            vistas[acao["id"]] = nome
            if do_pack and not acao["descricao"]:
                aviso(f"'{nome}': ação '{acao['id']}' sem 'descricao' — o catálogo "
                      f"público fica sem o que a ação faz.")
            if do_pack and not acao["rotulo_declarado"]:
                aviso(f"'{nome}': ação '{acao['id']}' sem 'rotulo' — a interface cai no "
                      f"rótulo derivado do identificador.")

        for encaixe in wf["encaixes"]:
            alvo = f"'{nome}/{encaixe['id']}'"
            if not encaixe["caminho"]:
                erro(f"{alvo}: encaixe sem 'caminho'.")
                continue
            if encaixe["tipo"] not in TIPOS_ENCAIXE:
                erro(f"{alvo}: tipo '{encaixe['tipo']}' desconhecido "
                     f"(use {' | '.join(TIPOS_ENCAIXE)}).")
            if do_pack and not encaixe["completo"]:
                aviso(f"{alvo}: sem 'rotulo'/'ajuda'/'tipo' — a interface não tem "
                      f"como desenhar o campo (HUB §7.1).")
            # 'padrao' é derivado: existe no pack ou não existe em lugar nenhum.
            tem_padrao = (pack / nome / encaixe["caminho"]).exists() if do_pack else False
            encaixe["padrao"] = "pack" if tem_padrao else "nenhum"
            preenchido = (pathlib.Path(wf["org"]) / encaixe["caminho"]).exists() \
                if wf["org"] else False
            encaixe["preenchido"] = preenchido
            # Encaixe essencial vazio é ESTADO (ação indisponível, e o manifesto diz
            # isso), não defeito de build — organização nova não pode ser reprovada por
            # ainda não ter configurado. Encaixe comum sem padrão é defeito DO PACK.
            if do_pack and not tem_padrao and not preenchido and not encaixe["essencial"]:
                aviso(f"{alvo}: sem padrão no pack e sem conteúdo da organização — "
                      f"a ação roda só com a moldura do sistema.")

        # Só faz sentido onde a organização preenche encaixes de um workflow do pack.
        # Workflow próprio dela (ação nova) é dela inteiro — nada fica "fora de encaixe".
        if wf["origem"] == "pack+encaixes":
            declarados = {e["caminho"] for e in wf["encaixes"]}
            raiz = pathlib.Path(wf["org"])
            for arquivo in sorted(raiz.rglob("*")):
                if not arquivo.is_file():
                    continue
                rel = str(arquivo.relative_to(raiz))
                if rel == "DISABLED" or rel.startswith("evals/"):
                    continue
                if rel == "SKILL.md":
                    aviso(f"'{nome}/SKILL.md' — a organização não escreve workflow para "
                          f"ação já atendida pelo pack; isso é encaixe (ARCHITECTURE §7).")
                elif rel not in declarados:
                    aviso(f"'{nome}/{rel}' não corresponde a nenhum encaixe declarado "
                          f"pelo pack (ARCHITECTURE §7).")

    problemas += _validar_esteira(workflows)
    return problemas


def _validar_esteira(workflows):
    """Grafo produz/requer: todo requisito tem produtor, e não há ciclo (HUB §7.4)."""
    problemas = []
    produtores = {}
    for wf in workflows:
        if wf["produz"]:
            ident = wf["produz"]["id"]
            if ident in produtores:
                problemas.append((ERRO, f"artefato '{ident}' é produzido por "
                                        f"'{produtores[ident]}' e por '{wf['nome']}' — "
                                        f"a esteira fica ambígua."))
            produtores[ident] = wf["nome"]

    exigencias = {}
    for wf in workflows:
        alvos = [a["id"] for a in wf["requer"]]
        alvos += [c["artefato"] for c in wf["requer_condicional"]]
        for alvo in alvos:
            if alvo not in produtores:
                problemas.append((ERRO, f"'{wf['nome']}' exige o artefato '{alvo}', que "
                                        f"nenhum workflow produz."))
        if wf["produz"]:
            exigencias[wf["produz"]["id"]] = [a for a in alvos if a in produtores]

    estado = {}

    def ciclo(no, caminho):
        if estado.get(no) == "fechado":
            return None
        if estado.get(no) == "aberto":
            return caminho[caminho.index(no):] + [no]
        estado[no] = "aberto"
        for vizinho in exigencias.get(no, []):
            achado = ciclo(vizinho, caminho + [no])
            if achado:
                return achado
        estado[no] = "fechado"
        return None

    for no in sorted(exigencias):
        achado = ciclo(no, [])
        if achado:
            problemas.append((ERRO, "ciclo na esteira: " + " → ".join(achado)))
            break
    return problemas


# ── Manifesto ─────────────────────────────────────────────────────────────────

def manifesto(workflows, personas, providers, release):
    """Catálogo como dado. Determinístico: sem timestamp, chaves e listas ordenadas.

    O bloco `interno` de cada ação é o que a API do Hub corta antes de servir — nome de
    workflow e origem são implementação, não contrato (MODOS §7, "core exposto").
    """
    acoes, artefatos, condicoes = [], {}, set()
    for wf in workflows:
        if wf["origem"] == "sistema" or not wf["acao"] or not wf["acao"]["id"]:
            continue
        if wf["produz"]:
            artefatos[wf["produz"]["id"]] = wf["produz"]["rotulo"]
        condicoes.update(c["quando"] for c in wf["requer_condicional"])
        encaixes = [{
            "id": e["id"], "rotulo": e["rotulo"], "ajuda": e["ajuda"], "tipo": e["tipo"],
            "essencial": e["essencial"], "padrao": e.get("padrao", "nenhum"),
            "preenchido": e.get("preenchido", False),
        } for e in wf["encaixes"]]
        indisponivel = [e["id"] for e in encaixes
                        if e["essencial"] and e["padrao"] == "nenhum"
                        and not e["preenchido"]]
        acoes.append({
            "id": wf["acao"]["id"],
            "rotulo": wf["acao"]["rotulo"],
            "descricao": wf["acao"]["descricao"],
            "gatilho": str(wf["campos"].get("description", "")).strip(),
            "tipo": "persona" if wf["persona"] else "trabalho",
            "encaixes": encaixes,
            "produz": wf["produz"]["id"] if wf["produz"] else None,
            "requer": sorted(a["id"] for a in wf["requer"]),
            "requer_condicional": sorted(wf["requer_condicional"],
                                         key=lambda c: (c["artefato"], c["quando"])),
            "indisponivel_por": sorted(indisponivel),
            "interno": {
                "workflow": wf["nome"],
                "origem": wf["origem"],
                "caminhos": {e["id"]: e["caminho"] for e in wf["encaixes"]},
            },
        })

    return {
        "schema": SCHEMA,
        "harness": {"release": release or None},
        "acoes": sorted(acoes, key=lambda a: a["id"]),
        "artefatos": [{"id": i, "rotulo": artefatos[i]} for i in sorted(artefatos)],
        "condicoes": sorted(condicoes),
        "personas": sorted(({
            "id": p["name"],
            "rotulo": p["summary"],
            "gatilho": p["description"],
            "modo": p["mode"],
        } for p in personas), key=lambda p: p["id"]),
        "providers": providers,
    }


# ── Catálogo público derivado (system/ACOES.md) ───────────────────────────────

MARCA_INICIO = "<!-- gerado: catálogo — regenerado por runtime/build.sh --fix -->"
MARCA_FIM = "<!-- /gerado -->"


def tabela_acoes(man):
    """Tabela de ações do ACOES.md, derivada do manifesto (HUB §7.2).

    Só ação do sistema entra: o catálogo é o contrato do pack. Ação criada pela
    organização vive na camada dela e não é catalogada aqui.
    """
    linhas = ["| Ação | O que faz | Outros encaixes |", "|---|---|---|"]
    for acao in man["acoes"]:
        if acao["interno"]["origem"] not in ("pack", "pack+encaixes"):
            continue
        extras = [f"`{e['id']}`" for e in acao["encaixes"] if e["id"] != "procedimento"]
        linhas.append(f"| `{acao['id']}` | {acao['descricao'] or '—'} | "
                      f"{' · '.join(extras) if extras else '—'} |")
    if man["artefatos"]:
        linhas += ["", "| Artefato da esteira | Produzido por |", "|---|---|"]
        for art in man["artefatos"]:
            dono = next((a["id"] for a in man["acoes"] if a["produz"] == art["id"]), "—")
            linhas.append(f"| `{art['id']}` | `{dono}` |")
    return "\n".join(linhas)


def sincronizar_acoes(caminho, man, corrigir):
    """Compara (ou reescreve) o bloco gerado do ACOES.md. Devolve lista de problemas.

    Por padrão só **verifica**: no sandbox do produto `system/` chega read-only por
    release, e o build não pode escrever lá. `--fix` reescreve, no modo repositório.
    """
    arquivo = pathlib.Path(caminho)
    if not arquivo.exists():
        return [(AVISO, f"{arquivo.name} não encontrado — catálogo não verificado.")]
    texto = arquivo.read_text(encoding="utf-8")
    if MARCA_INICIO not in texto or MARCA_FIM not in texto:
        return [(AVISO, f"{arquivo.name} sem os marcadores do bloco gerado — catálogo "
                        f"segue mantido à mão e pode divergir do frontmatter.")]
    antes, resto = texto.split(MARCA_INICIO, 1)
    atual, depois = resto.split(MARCA_FIM, 1)
    novo = f"\n\n{tabela_acoes(man)}\n\n"
    if atual == novo:
        return []
    if not corrigir:
        return [(ERRO, f"{arquivo.name} divergiu do frontmatter das skills — "
                       f"rode ./runtime/build.sh --fix.")]
    arquivo.write_text(antes + MARCA_INICIO + novo + MARCA_FIM + depois, encoding="utf-8")
    return []


# ── CLI (chamado por build.sh) ────────────────────────────────────────────────

def main():
    dir_pack = os.environ["PACK_DIR"]
    dir_skills = os.environ["OUT_DIR"]
    destino = pathlib.Path(os.environ["MANIFEST"])
    estrito = os.environ.get("HARNESS_STRICT") == "1"
    corrigir = os.environ.get("HARNESS_FIX") == "1"

    workflows = carregar_workflows(carregar_resolucao(sys.stdin.read()))
    personas = descobrir_personas(dir_skills)
    providers = descobrir_providers(os.environ.get("PROVIDERS_DIR", ""),
                                    os.environ.get("ORG_PROVIDERS_DIR", ""))

    problemas = [(AVISO, linha) for linha
                 in os.environ.get("RESOLUCAO_AVISOS", "").splitlines() if linha.strip()]
    problemas += validar(workflows, dir_pack)

    if os.environ.get("HARNESS_LIST") == "1":
        print(f"{'WORKFLOW':<26} {'ORIGEM':<14} {'AÇÃO':<26} ENCAIXES PREENCHIDOS")
        for wf in workflows:
            acao = wf["acao"]["id"] if wf["acao"] else "—"
            cheios = sum(1 for e in wf["encaixes"] if e.get("preenchido"))
            marca = f"{cheios}/{len(wf['encaixes'])}" if wf["encaixes"] else "—"
            print(f"{wf['nome']:<26} {wf['origem']:<14} {acao:<26} {marca}")
        print()
    man = manifesto(workflows, personas, providers,
                    os.environ.get("HARNESS_RELEASE", ""))
    problemas += sincronizar_acoes(os.environ.get("ACOES", ""), man, corrigir)

    destino.parent.mkdir(parents=True, exist_ok=True)
    destino.write_text(json.dumps(man, indent=2, ensure_ascii=False, sort_keys=False)
                       + "\n", encoding="utf-8")

    erros = [m for s, m in problemas if s == ERRO]
    avisos = [m for s, m in problemas if s == AVISO]
    for mensagem in erros:
        print(f"ERRO: {mensagem}", file=sys.stderr)
    for mensagem in avisos:
        print(f"aviso: {mensagem}", file=sys.stderr)

    indisponiveis = [a["id"] for a in man["acoes"] if a["indisponivel_por"]]
    print(f"manifesto: {len(man['acoes'])} ação(ões), {len(man['personas'])} persona(s), "
          f"{len(man['artefatos'])} artefato(s) — schema {SCHEMA}")
    if indisponiveis:
        print(f"indisponíveis até a organização preencher o encaixe essencial: "
              + ", ".join(sorted(indisponiveis)))
    if erros or (estrito and avisos):
        print(f"contrato reprovado: {len(erros)} erro(s), {len(avisos)} aviso(s)"
              + (" (--strict)" if estrito and not erros else ""), file=sys.stderr)
        sys.exit(3)
    print(f"contrato: ok ({len(avisos)} aviso(s))")


if __name__ == "__main__":
    main()
