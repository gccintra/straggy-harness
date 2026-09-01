#!/usr/bin/env python3
"""Relatório HTML da corrida de evals, a partir do JSONL que `runtime/eval.sh` grava.

O relatório é uma VISÃO do `resultado.json`, nunca uma segunda fonte — mesma regra do
manifesto (docs/ARCHITECTURE.md §8): derivado, determinístico, sem timestamp dentro dos
números. Página única, sem rede: abre de qualquer lugar, inclusive offline.

Sobre a forma: pass/fail/não-rodou é **status**, não série. Por isso a página não tem
gráfico de série nenhum — tem figura-herói, stat tiles, um medidor de taxa e tabelas.
Barra de "3 passou / 1 falhou" seria ruído com aparência de rigor.
"""
import collections
import datetime
import html
import json
import os
import pathlib
import sys

from harness import carregar_yaml

# Paleta de status (fixa, nunca tematizada). Cor NUNCA sozinha: todo estado sai com
# ícone + rótulo, porque warning/serious ficam abaixo de 3:1 na superfície clara.
STATUS = {
    "passou":    ("good",     "#0ca30c", "●", "Passou"),
    "falhou":    ("critical", "#d03b3b", "▲", "Falhou"),
    "nao-rodou": ("warning",  "#fab219", "◍", "Não rodou"),
}

CSS = """
:root{
  --surface-0:#f4f4f1; --surface-1:#fcfcfb; --line:#e2e1dc;
  --text-primary:#0b0b0b; --text-secondary:#52514e; --text-muted:#84837d;
  --good:#0ca30c; --warning:#fab219; --serious:#ec835a; --critical:#d03b3b;
  --track:#e8e7e2;
}
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){
  --surface-0:#111110; --surface-1:#1a1a19; --line:#2f2e2b;
  --text-primary:#ffffff; --text-secondary:#c3c2b7; --text-muted:#8d8c84;
  --track:#2a2926;
}}
:root[data-theme="dark"]{
  --surface-0:#111110; --surface-1:#1a1a19; --line:#2f2e2b;
  --text-primary:#ffffff; --text-secondary:#c3c2b7; --text-muted:#8d8c84;
  --track:#2a2926;
}
*{box-sizing:border-box}
body{
  margin:0; padding:40px 24px 72px; background:var(--surface-0); color:var(--text-primary);
  font:15px/1.55 ui-sans-serif,-apple-system,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;
}
.wrap{max-width:1080px;margin:0 auto}
h1{font-size:19px;font-weight:600;margin:0 0 4px;letter-spacing:-.01em}
.sub{color:var(--text-secondary);font-size:13px;margin:0 0 28px}
.sub code{background:var(--surface-1);border:1px solid var(--line);border-radius:4px;padding:1px 5px;font-size:12px}
h2{font-size:13px;font-weight:600;margin:34px 0 12px;color:var(--text-secondary);
   text-transform:uppercase;letter-spacing:.07em}
.card{background:var(--surface-1);border:1px solid var(--line);border-radius:10px}

/* Figura-herói: exatamente uma por vista, proporcional (nunca tabular em display) */
.hero{padding:22px 24px;display:flex;align-items:baseline;gap:16px;flex-wrap:wrap}
.hero .n{font-size:52px;font-weight:600;line-height:1;letter-spacing:-.03em}
.hero .of{color:var(--text-secondary);font-size:14px}
.meter{height:8px;border-radius:4px;background:var(--track);overflow:hidden;display:flex;gap:2px;margin:16px 24px 22px}
.meter i{display:block;height:100%}
.meter i:first-child{border-radius:4px 0 0 4px}
.meter i:last-child{border-radius:0 4px 4px 0}

.tiles{display:grid;grid-template-columns:repeat(auto-fit,minmax(168px,1fr));gap:12px;margin-top:12px}
.tile{padding:14px 16px}
.tile .lab{font-size:12px;color:var(--text-secondary);display:flex;align-items:center;gap:6px}
.tile .val{font-size:28px;font-weight:600;line-height:1.15;margin-top:6px;letter-spacing:-.02em}
.tile .note{font-size:12px;color:var(--text-muted);margin-top:2px}
.dot{font-size:11px;line-height:1}

.scroll{overflow-x:auto}
table{border-collapse:collapse;width:100%;font-size:13.5px}
th,td{text-align:left;padding:9px 14px;border-bottom:1px solid var(--line);vertical-align:top}
th{font-size:11.5px;text-transform:uppercase;letter-spacing:.06em;color:var(--text-muted);font-weight:600;white-space:nowrap}
tbody tr:last-child td{border-bottom:0}
td.num{font-variant-numeric:tabular-nums;text-align:right;color:var(--text-secondary);white-space:nowrap}
.st{display:inline-flex;align-items:center;gap:6px;white-space:nowrap;font-weight:500}
.mono{font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:12.5px}
.mut{color:var(--text-muted)}
.sec{color:var(--text-secondary)}
.tag{display:inline-block;font-size:11px;padding:1px 7px;border:1px solid var(--line);
     border-radius:999px;color:var(--text-secondary);white-space:nowrap}
.empty{padding:18px 24px;color:var(--text-secondary);font-size:13.5px}
footer{margin-top:34px;color:var(--text-muted);font-size:12px}
"""


def esc(t):
    return html.escape(str(t or ""))


def selo(status):
    _, cor, icone, rotulo = STATUS.get(status, ("", "var(--text-muted)", "·", status))
    return (f'<span class="st" style="color:{cor}">'
            f'<span class="dot">{icone}</span>{esc(rotulo)}</span>')


def tile(rotulo, valor, nota="", cor=None, icone=None):
    marca = (f'<span class="dot" style="color:{cor}">{icone}</span>'
             if cor and icone else "")
    return (f'<div class="card tile"><div class="lab">{marca}{esc(rotulo)}</div>'
            f'<div class="val">{esc(valor)}</div>'
            f'<div class="note">{esc(nota)}</div></div>')


def cobertura(dir_skills):
    """Lados do gatilho que cada ação tem declarados.

    As ações saem do **manifesto**, não de reparsear SKILL.md: ele existe justamente para
    isso (§8), e reparsear inventa contagem — id de encaixe entra no lugar de ação.
    As fontes saem do mesmo parser do build, pelo mesmo motivo.

    Entra no relatório porque suíte verde com cobertura parcial é o resultado mais enganoso
    possível: tudo passa, e metade do risco nunca foi testada.
    """
    raiz = pathlib.Path(dir_skills)
    manifesto = raiz.parent / "manifest.json"
    if not manifesto.is_file():
        return set(), set(), set()
    catalogo = json.loads(manifesto.read_text(encoding="utf-8"))
    # Persona é roteada pelo adapter, não pela tool de skill — não tem caso de gatilho.
    total = {a["id"] for a in catalogo["acoes"] if a.get("tipo") != "persona"}

    atendidas, contraprovadas = set(), set()
    for fonte in sorted(raiz.glob("*/evals/*/caso.yaml")):
        campos = carregar_yaml(fonte)
        if str(campos.get("tipo", "")).strip() != "roteamento":
            continue
        atende = str(campos.get("atende", "")).strip()
        if atende and atende != "nenhuma":
            atendidas.add(atende)
        rivais = campos.get("confunde_com") or []
        for rival in (rivais if isinstance(rivais, list) else [rivais]):
            if str(rival).strip():
                contraprovadas.add(str(rival).strip())
    return total, atendidas & total, contraprovadas & total


def main():
    jsonl, saida = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
    casos = [json.loads(l) for l in jsonl.read_text(encoding="utf-8").splitlines() if l.strip()]

    runner = os.environ.get("RUNNER", "—")
    capacidades = os.environ.get("CAPACIDADES", "")
    dir_skills = os.environ.get("SKILLS_DIR", "")
    escopo_skill = os.environ.get("FILTRO_SKILL", "*")
    escopo_tipo = os.environ.get("FILTRO_TIPO", "")

    contagem = collections.Counter(c["status"] for c in casos)
    p, f, n = contagem["passou"], contagem["falhou"], contagem["nao-rodou"]
    rodados = p + f
    taxa = round(100 * p / rodados) if rodados else 0
    segundos = sum(c.get("segundos", 0) for c in casos)

    total_acoes, atendidas, contraprovadas = cobertura(dir_skills) if dir_skills else (set(), set(), set())
    dois_lados = len(atendidas & contraprovadas)

    resultado = {
        "runner": runner,
        "capacidades": [c.strip() for c in capacidades.split(",") if c.strip()],
        "escopo": {"skill": escopo_skill, "tipo": escopo_tipo or "todos"},
        "agregados": {"passou": p, "falhou": f, "nao_rodou": n,
                      "rodados": rodados, "taxa_pct": taxa,
                      "segundos": round(segundos, 1)},
        "cobertura": {"acoes": len(total_acoes), "com_disparo": len(atendidas),
                      "com_contraprova": len(contraprovadas), "dois_lados": dois_lados},
        "casos": casos,
    }
    (saida / "resultado.json").write_text(
        json.dumps(resultado, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    # ── Página ────────────────────────────────────────────────────────────────
    partes = [f"<style>{CSS}</style>", '<div class="wrap">']
    escopo = ("todo o harness" if escopo_skill == "*" else f"skill <code>{esc(escopo_skill)}</code>")
    if escopo_tipo:
        escopo += f", tipo <code>{esc(escopo_tipo)}</code>"
    quando = datetime.datetime.now().strftime("%d/%m/%Y %H:%M")
    partes.append(
        f"<h1>Evals do harness</h1>"
        f'<p class="sub">{escopo} · runner <code>{esc(runner)}</code>'
        f' · capacidades <code>{esc(capacidades or "—")}</code> · {esc(quando)}</p>')

    # Figura-herói + medidor: uma por vista, e o medidor carrega a severidade.
    if rodados:
        partes.append(
            f'<div class="card"><div class="hero">'
            f'<span class="n" style="color:{"#0ca30c" if f == 0 else "#d03b3b"}">{taxa}%</span>'
            f'<span class="of">dos {rodados} casos executados passaram'
            + (f" · {n} não rodaram" if n else "") + "</span></div>"
            f'<div class="meter">'
            + (f'<i style="flex:{p};background:var(--good)"></i>' if p else "")
            + (f'<i style="flex:{f};background:var(--critical)"></i>' if f else "")
            + (f'<i style="flex:{n};background:var(--warning)"></i>' if n else "")
            + "</div></div>")
    else:
        partes.append('<div class="card"><div class="empty">Nenhum caso executado — '
                      'a implementação ativa não tem a capacidade exigida por nenhum '
                      'caso do escopo.</div></div>')

    partes.append('<div class="tiles">')
    for chave, rotulo in (("passou", "Passou"), ("falhou", "Falhou"), ("nao-rodou", "Não rodou")):
        _, cor, icone, _ = STATUS[chave]
        nota = {"passou": "contrato honrado",
                "falhou": "gatilho ou regime quebrado",
                "nao-rodou": f"capacidade ausente em {runner}"}[chave]
        partes.append(tile(rotulo, contagem[chave], nota if contagem[chave] else "—", cor, icone))
    partes.append(tile("Tempo de agente", f"{segundos:.0f}s",
                       f"{segundos / rodados:.0f}s por caso" if rodados else "—"))
    partes.append("</div>")

    if total_acoes:
        partes.append("<h2>Cobertura do gatilho</h2>")
        partes.append('<div class="tiles">')
        partes.append(tile("Ações declaradas", len(total_acoes), "no manifesto"))
        partes.append(tile("Com caso de disparo", len(atendidas), "alguma frase as aciona"))
        partes.append(tile("Com contraprova", len(contraprovadas),
                           "alguma frase vizinha não pode sequestrá-las"))
        completo = dois_lados == len(atendidas | contraprovadas)
        partes.append(tile("Dois lados", dois_lados,
                           "cobertura completa" if completo else "faltam lados",
                           "#0ca30c" if completo else "#fab219", "●" if completo else "◍"))
        partes.append("</div>")

    partes.append("<h2>Casos</h2>")
    if casos:
        ordem = {"falhou": 0, "nao-rodou": 1, "passou": 2}
        linhas = []
        for c in sorted(casos, key=lambda c: (ordem.get(c["status"], 3), c["workflow"], c["caso"])):
            engajadas = ", ".join(c.get("engajadas") or []) or "—"
            linhas.append(
                f"<tr><td>{selo(c['status'])}</td>"
                f'<td class="mono">{esc(c["workflow"])}</td>'
                f'<td class="mono sec">{esc(c["caso"])}</td>'
                f'<td><span class="tag">{esc(c["tipo"])}</span></td>'
                f'<td class="mono mut">{esc(engajadas)}</td>'
                f'<td class="sec">{esc(c.get("motivo") or "—")}</td>'
                f'<td class="num">{c.get("segundos", 0):.1f}s</td></tr>')
        partes.append(
            '<div class="card scroll"><table><thead><tr>'
            "<th>Estado</th><th>Workflow</th><th>Caso</th><th>Tipo</th>"
            "<th>Skill engajada</th><th>Detalhe</th><th>Duração</th>"
            "</tr></thead><tbody>" + "".join(linhas) + "</tbody></table></div>")
    else:
        partes.append('<div class="card"><div class="empty">Nenhum caso no escopo.</div></div>')

    # Rollup por workflow: onde olhar primeiro quando a suíte inteira roda.
    por_wf = collections.defaultdict(collections.Counter)
    for c in casos:
        por_wf[c["workflow"]][c["status"]] += 1
    if len(por_wf) > 1:
        partes.append("<h2>Por workflow</h2>")
        linhas = []
        for wf in sorted(por_wf, key=lambda w: (-por_wf[w]["falhou"], w)):
            cont = por_wf[wf]
            pior = ("falhou" if cont["falhou"] else
                    "nao-rodou" if cont["nao-rodou"] and not cont["passou"] else "passou")
            linhas.append(
                f"<tr><td>{selo(pior)}</td>"
                f'<td class="mono">{esc(wf)}</td>'
                f'<td class="num">{cont["passou"]}</td>'
                f'<td class="num">{cont["falhou"]}</td>'
                f'<td class="num">{cont["nao-rodou"]}</td></tr>')
        partes.append(
            '<div class="card scroll"><table><thead><tr>'
            "<th>Estado</th><th>Workflow</th><th>Passou</th><th>Falhou</th><th>Não rodou</th>"
            "</tr></thead><tbody>" + "".join(linhas) + "</tbody></table></div>")

    partes.append(
        '<footer>Gerado por <code>runtime/eval.sh</code>. Os números vêm de '
        "<code>resultado.json</code>, ao lado deste arquivo — esta página é uma visão dele, "
        "não uma segunda fonte. Caso <strong>não rodado</strong> nunca conta como passado: "
        "é capacidade que a implementação ativa não tem "
        "(<code>system/providers/eval-runner/INTERFACE.md</code>).</footer>")
    partes.append("</div>")

    (saida / "report.html").write_text(
        "<!doctype html><html lang=\"pt-BR\"><head><meta charset=\"utf-8\">"
        "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">"
        "<title>Evals do harness</title></head><body>"
        + "".join(partes) + "</body></html>\n", encoding="utf-8")


if __name__ == "__main__":
    main()
