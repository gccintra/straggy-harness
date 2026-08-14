# Export e análise — código de referência

Procedural (jq/python). O contrato do que produzir está no SKILL.md.

**Nada aqui decora funil.** Faixas, dimensões, cortes, ordenação e rótulos do backlog saem
do encaixe `funil` da ação `priorizar-backlog` (schema
`system/schemas/funil-priorizacao.yaml`). Leia a instância e preencha o bloco de constantes
da §1 antes de rodar qualquer coisa.

## 1. Constantes — transcritas do funil

```bash
# --- de `binding` no funil ---
PREFIXO_TIPO="<prefixo do rótulo de tipo, com ::>"
PREFIXO_TRIAGEM="<prefixo do rótulo da etapa de triagem, com ::>"
PREFIXO_FAIXA="<prefixo do rótulo da etapa de faixa, com ::>"
ROTULOS_FILA="<rótulo1>|<rótulo2>"      # binding.fila, separados por |
BLOCO_DIMENSOES="<identificador do bloco na descrição>"   # quando modo = bloco-na-descricao

# --- de `etapas` no funil ---
DIMENSOES='["<Dim1>","<Dim2>","<Dim3>"]'                  # ids/rótulos das escalas, na ordem da tabela
FAIXAS_TRIAGEM="<FAIXA1>|<FAIXA2>|<FAIXA3>|<FAIXA4>"      # ids da triagem, na ordem de precedência

# Linha do bloco de dimensões: célula da triagem, depois uma célula por dimensão e o score.
RE_LINHA="\\|\\s*\\*{0,2}(?<t>${FAIXAS_TRIAGEM})\\*{0,2}\\s*\\|(?<resto>[^\\n]*)"
```

Funil sem etapa de triagem, ou com outro número de dimensões, muda só este bloco — o resto
do código não conhece nome nenhum.

---

## 2. Exportar — uma única chamada à API

> **`DADOS`** é o diretório de export do projeto — `caminhos.dados` do `project-config.yaml`.
> Exporte antes de rodar os blocos abaixo: `export DADOS="$(...)"`. Nunca escreva o caminho literal.

**Princípio:** toda a análise roda sobre o CSV local. Zero chamadas adicionais à API.

```bash
export GITLAB_HOST GITLAB_URI GITLAB_TOKEN GITLAB_REPO
REPO_ENCODED="${GITLAB_REPO//\//\%2F}"

# Montar filtros opcionais
MILESTONE_PARAM=""
if [ -n "$MILESTONE_NAME" ]; then
  MILESTONE_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$MILESTONE_NAME'))")
  MILESTONE_PARAM="&milestone=${MILESTONE_ENCODED}"
fi

glab api --paginate \
  "projects/${REPO_ENCODED}/issues?per_page=100&state=opened${MILESTONE_PARAM}" \
  --hostname "${GITLAB_HOST}" \
  | jq -r \
      --arg   ptipo "$PREFIXO_TIPO" \
      --arg   ptri  "$PREFIXO_TRIAGEM" \
      --arg   pfai  "$PREFIXO_FAIXA" \
      --arg   fila  "$ROTULOS_FILA" \
      --arg   re    "$RE_LINHA" \
      --argjson dims "$DIMENSOES" '
    # Células do bloco de dimensões: triagem na primeira, depois uma por dimensão, score no fim.
    def celulas:
      (if .description then ((.description | capture($re)) // null) else null end)
      | if . == null then null
        else { t: .t,
               v: (.resto | split("|")
                          | map(gsub("\\*"; "") | gsub("^\\s+|\\s+$"; ""))) }
        end;

    def rotulo($p): (.labels | map(select(startswith($p)))
                             | if length > 0 then .[0] else "" end);

    ($fila | split("|")) as $filas
    | (["IID","Titulo","Estado","Tipo","Faixa_Label","Triagem_Label","Triagem_Desc","Score"]
       + $dims
       + ["Workflow","Milestone","Assignee","Autor","Criada","Atualizada","Weight","Labels_Todas"]),
      (.[]
       | celulas as $c
       | [
        .iid,
        .title,
        .state,
        (rotulo($ptipo) | if . == "" then "SEM TIPO" else . end),
        (rotulo($pfai)  | if . == "" then "SEM FAIXA" else . end),
        rotulo($ptri),
        (if $c then $c.t else "" end)
      ]
      + [ (if $c then ($c.v[($dims | length)] // "") else "" end) ]   # score registrado
      + [ range(0; ($dims | length)) as $i
          | (if $c then ($c.v[$i] // "") else "" end) ]
      + [
        # Workflow: rótulos que não são de tipo, faixa, triagem nem de fila
        (.labels | map(select(
          (startswith($ptipo) or startswith($pfai) or startswith($ptri)
           or (. as $l | $filas | index($l) != null)) | not)) | join("|")),
        (if .milestone then .milestone.title else "" end),
        (if .assignees and (.assignees | length) > 0 then .assignees[0].username else "" end),
        .author.username,
        .created_at,
        .updated_at,
        (if .weight then .weight else "" end),
        (.labels | join("|"))
      ] | @csv)
  ' > "${DADOS}issues_$(date +%Y-%m-%d).csv"
```

Verificar antes de prosseguir:
```bash
wc -l "${DADOS}issues_$(date +%Y-%m-%d).csv"   # deve ser > 1
head -2 "${DADOS}issues_$(date +%Y-%m-%d).csv"
```

---

## 3. Filtrar e calcular localmente (Python)

Use Python para ler o CSV — evita quebra por vírgulas em títulos.

`FUNIL` abaixo é a transcrição direta da instância do encaixe: escalas, score, faixas e
ordenação. Nenhum valor é inventado aqui.

```python
import csv, os
from datetime import datetime

DADOS = os.environ["DADOS"]          # caminhos.dados do project-config.yaml
CSV_PATH = f"{DADOS}issues_{datetime.now().strftime('%Y-%m-%d')}.csv"

# --- Transcrito do encaixe `funil` -------------------------------------------
FUNIL = {
    "triagem":   {"id": "<id>", "faixas": ["<FAIXA1>", "<FAIXA2>", "..."]},
    "escalas":   {"<D1>": {"min": 1, "max": 10}, "...": {}},
    "score":     {"id": "<SCORE>", "operador": "produto",
                  "entradas": ["<D1>", "<D2>", "<D3>"]},
    "faixa":     {"id": "<id>", "dimensoes": ["<D1>", "<D3>"],
                  "bandas": [
                      {"id": "<BANDA1>", "cortes": {"<D1>": {"min": 7}, "<D3>": {"min": 5}}},
                      # ... na ordem declarada; a primeira que casar vence
                  ]},
    "ordenacao": [("triagem", "asc"), ("faixa", "asc"), ("score", "desc")],
}
FILA = ["<rótulo1>", "<rótulo2>"]    # binding.fila; ajustar conforme o pedido do usuário

DIMS = FUNIL["score"]["entradas"]


def calcular_score(v):
    """Operador do conjunto fechado do schema. Faltando dimensão → None."""
    op, ent = FUNIL["score"]["operador"], FUNIL["score"]["entradas"]
    vals = [v.get(d) for d in ent]
    if any(x is None for x in vals):
        return None
    if op == "produto":
        r = 1
        for x in vals:
            r *= x
        return r
    if op == "soma":
        return sum(vals)
    if op == "media":
        return round(sum(vals) / len(vals), 2)
    if op == "soma-ponderada":
        pesos = FUNIL["score"].get("pesos", {})
        return round(sum(x * pesos.get(d, 1) for d, x in zip(ent, vals)), 2)
    if op == "razao":
        num = [v.get(d) for d in FUNIL["score"]["numerador"]]
        den = [v.get(d) for d in FUNIL["score"]["denominador"]]
        if any(x is None for x in num + den):
            return None
        p = 1
        for x in num:
            p *= x
        q = 1
        for x in den:
            q *= x
        return round(p / q, 2) if q else None
    raise ValueError(f"operador '{op}' fora do schema")


def calcular_banda(v):
    """Primeira banda cujos cortes todos casam. Sem valor → None."""
    alvo = FUNIL["faixa"]["dimensoes"]
    if any(v.get(d) is None for d in alvo):
        return None
    for banda in FUNIL["faixa"]["bandas"]:
        ok = True
        for dim, corte in banda["cortes"].items():
            x = v.get(dim)
            if "min" in corte and x < corte["min"]:
                ok = False
            if "max" in corte and x > corte["max"]:
                ok = False
        if ok:
            return banda["id"]
    return None


issues = []
with open(CSV_PATH, newline='') as f:
    for row in csv.DictReader(f):
        labels = row.get("Labels_Todas", "")
        if not any(lf in labels for lf in FILA):
            continue

        v = {d: (int(row[d]) if row.get(d) else None) for d in DIMS}
        registrado = int(row["Score"]) if row.get("Score") else None

        issues.append({**row,
            "v": v,
            "score": registrado,
            "score_calc": calcular_score(v),
            "banda_calc": calcular_banda(v),
            "triagem": (row.get("Triagem_Desc")
                        or row.get("Triagem_Label", "").split("::")[-1]),
            "faixa_label": row.get("Faixa_Label", "").split("::")[-1],
            "tipo": row.get("Tipo", "").split("::")[-1],
            "fila": next((f for f in FILA if f in labels), None),
        })
```

---

## 4. Detectar anomalias

Seis categorias **derivam do funil** e valem para qualquer instância — não se declaram. As
regras próprias da organização (`anomalias_extras`) somam-se a elas, nunca as substituem.
A detecção é aberta: aplique também o que o documento-fonte do funil descrever como
inconsistência.

```python
anomalies = []   # {category, iid, title, detail, severity, action}

ORDEM_TRIAGEM = FUNIL["triagem"]["faixas"]
ORDEM_BANDA   = [b["id"] for b in FUNIL["faixa"]["bandas"]]

for i in issues:
    iid = i["IID"]
    v, tri, banda = i["v"], i["triagem"], i["banda_calc"]
    reg, calc = i["score"], i["score_calc"]

    # a) rótulo aplicado != banda calculada
    if banda and i["faixa_label"] and i["faixa_label"] not in ("", "SEM FAIXA") \
            and i["faixa_label"] != banda:
        anomalies.append({"category": "rotulo_diverge", "iid": iid,
            "detail": f"calculada={banda}, rótulo={i['faixa_label']}",
            "severity": "alta", "action": f"Corrigir rótulo para {banda}"})

    # b) score registrado != recalculado
    if reg and calc and reg != calc:
        anomalies.append({"category": "score_inconsistente", "iid": iid,
            "detail": f"registrado={reg}, calculado={calc}",
            "severity": "media", "action": f"Corrigir o score na descrição para {calc}"})

    # c) nota fora do intervalo da escala
    for d, x in v.items():
        faixa_escala = FUNIL["escalas"].get(d, {})
        if x is not None and faixa_escala and not (
                faixa_escala["min"] <= x <= faixa_escala["max"]):
            anomalies.append({"category": "nota_fora_da_escala", "iid": iid,
                "detail": f"{d}={x} fora de [{faixa_escala['min']},{faixa_escala['max']}]",
                "severity": "alta", "action": f"Reavaliar {d}"})

    # d) triagem alta caindo em banda de descarte
    if tri in ORDEM_TRIAGEM and banda in ORDEM_BANDA:
        alto = ORDEM_TRIAGEM.index(tri) == 0
        fundo = ORDEM_BANDA.index(banda) >= len(ORDEM_BANDA) - 1
        if alto and fundo:
            anomalies.append({"category": "triagem_banda_contraditoria", "iid": iid,
                "detail": f"triagem={tri} mas banda={banda}",
                "severity": "alta",
                "action": "Reavaliar as dimensões ou a faixa de triagem"})

    # e) na fila sem alguma dimensão obrigatória
    faltando = [d for d in DIMS if v.get(d) is None]
    if faltando and tri:
        anomalies.append({"category": "dimensao_faltando", "iid": iid,
            "detail": "sem: " + ", ".join(faltando),
            "severity": "media", "action": "Completar a avaliação das dimensões"})

    # f) na fila sem faixa de triagem
    if not tri:
        anomalies.append({"category": "sem_triagem", "iid": iid,
            "detail": "demanda na fila sem faixa de triagem",
            "severity": "alta", "action": "Classificar na triagem"})

# g) regras próprias: uma verificação por item de `anomalias_extras` do funil.
#    Mesma forma de dict; severidade e ação vêm declaradas lá.
```

---

## 5. Ordenar para o ranking

```python
def posicao(lista, valor):
    return lista.index(valor) if valor in lista else len(lista)

def sort_key(i):
    chaves = []
    for etapa, sentido in FUNIL["ordenacao"]:
        if etapa == "triagem":
            chaves.append(posicao(ORDEM_TRIAGEM, i["triagem"]))
        elif etapa == "faixa":
            chaves.append(posicao(ORDEM_BANDA, i["banda_calc"]))
        elif etapa == "score":
            x = i["score"] or i["score_calc"] or 0
            chaves.append(-x if sentido == "desc" else x)
    return tuple(chaves)

ranked = sorted(issues, key=sort_key)
```

Desempate declarado (`antiguidade` / `recencia`) entra como última chave, a partir de
`Criada`.

---

## 6. Gerar o markdown

Salve em `{caminhos.historico}analyses/YYYY-MM-DD_priorizacao_backlog.md`.

### Estrutura obrigatória

```
# Priorização do Backlog

**Data:** DD/MM/YYYY | **Demandas:** N (fila `X` + `Y`) | **Com score:** N | **Sem score:** N
**Funil:** <nome do funil> v<versão> — <etapa> → <etapa> → <etapa>
**Fonte:** `{caminhos.dados}issues_YYYY-MM-DD.csv`
**Ref.:** documento-fonte declarado em `fonte` no funil

---

## Lista Priorizada

> **Como ler:** [as etapas do funil, na ordem declarada]

---

### <FAIXA DE TRIAGEM 1>
#### <FAIXA 1> › <BANDA 1> (<cortes da banda>)
| # | IID | <Score> | <Dim1> | <Dim2> | <Dim3> | Tipo | Rótulo | Título |
...

#### <FAIXA 1> › <BANDA 2> (<cortes>)
...

[repetir para cada faixa de triagem, na ordem de precedência]

### ⚪ SEM SCORE / SEM TRIAGEM — Aguardando classificação
...

---

## Anomalias Identificadas

### 1. [Nome da categoria]
| IID | ... | Ação |
...

[uma seção por categoria de anomalia encontrada]

---

## Resumo de Ações Prioritárias

| Prioridade | Ação | Demandas |
|---|---|---|
| 🔴 Alta | ... | #X, #Y |
| 🟠 Média | ... | #Z |
| 🟡 Baixa | ... | #W |
| ℹ️ Info | ... | #V |

---

> 📊 Dados brutos: `{caminhos.dados}issues_YYYY-MM-DD.csv`
```

Emoji e rótulo de cada seção seguem a análise mais recente em
`{caminhos.historico}analyses/` — é a referência canônica de formato e tom.
