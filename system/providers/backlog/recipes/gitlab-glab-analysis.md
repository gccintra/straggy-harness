# Export e análise — código de referência

Procedural (jq/python). O contrato do que produzir está no SKILL.md.

## 2. Exportar — uma única chamada à API

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
  | jq -r '
    ["IID","Titulo","Estado","Tipo","Prioridade","MoSCoW_Label","MoSCoW_Desc",
     "ICE_Score","Impacto","Confianca","Facilidade",
     "Workflow","Milestone","Assignee","Autor","Criada","Atualizada","Weight","Labels_Todas"],
    (.[] | [
      .iid,
      .title,
      .state,
      (.labels | map(select(startswith("TIPO::")))
        | if length > 0 then .[0] else "SEM TIPO" end),
      (.labels | map(select(startswith("PRIORIDADE::")))
        | if length > 0 then .[0] else "SEM PRIORIDADE" end),
      (.labels | map(select(startswith("MSCW::")))
        | if length > 0 then .[0] else "" end),
      # MoSCoW extraído da tabela ICE na descrição
      (if .description then
        (.description | capture("\\|\\s*\\*{0,2}(?<m>MUST|SHOULD|COULD|WONT)\\*{0,2}\\s*\\|")
          // {m: ""}) | .m
       else "" end),
      # ICE da descrição
      (if .description then
        (.description | capture("\\|\\s*(?:MUST|SHOULD|COULD|WONT)\\s*\\|\\s*(?<i>[0-9]+)\\s*\\|\\s*(?<c>[0-9]+)\\s*\\|\\s*(?<e>[0-9]+)\\s*\\|\\s*\\*{0,2}(?<ice>[0-9]+)\\*{0,2}")
          // {i:"",c:"",e:"",ice:""}) | .ice
       else "" end),
      (if .description then
        (.description | capture("\\|\\s*(?:MUST|SHOULD|COULD|WONT)\\s*\\|\\s*(?<i>[0-9]+)\\s*\\|\\s*(?<c>[0-9]+)\\s*\\|\\s*(?<e>[0-9]+)\\s*\\|\\s*\\*{0,2}(?<ice>[0-9]+)\\*{0,2}")
          // {i:"",c:"",e:"",ice:""}) | .i
       else "" end),
      (if .description then
        (.description | capture("\\|\\s*(?:MUST|SHOULD|COULD|WONT)\\s*\\|\\s*(?<i>[0-9]+)\\s*\\|\\s*(?<c>[0-9]+)\\s*\\|\\s*(?<e>[0-9]+)\\s*\\|\\s*\\*{0,2}(?<ice>[0-9]+)\\*{0,2}")
          // {i:"",c:"",e:"",ice:""}) | .c
       else "" end),
      (if .description then
        (.description | capture("\\|\\s*(?:MUST|SHOULD|COULD|WONT)\\s*\\|\\s*(?<i>[0-9]+)\\s*\\|\\s*(?<c>[0-9]+)\\s*\\|\\s*(?<e>[0-9]+)\\s*\\|\\s*\\*{0,2}(?<ice>[0-9]+)\\*{0,2}")
          // {i:"",c:"",e:"",ice:""}) | .e
       else "" end),
      # Workflow: labels que não são TIPO/PRIORIDADE/MSCW/BACKLOG
      (.labels | map(select(
        (startswith("TIPO::") or startswith("PRIORIDADE::") or
         startswith("MSCW::") or . == "BACKLOG" or . == "BACKLOG (PRIORIZADO)")
        | not)) | join("|")),
      (if .milestone then .milestone.title else "" end),
      (if .assignees and (.assignees | length) > 0 then .assignees[0].username else "" end),
      .author.username,
      .created_at,
      .updated_at,
      (if .weight then .weight else "" end),
      (.labels | join("|"))
    ]) | @csv
  ' > "data/issues_$(date +%Y-%m-%d).csv"
```

Verificar antes de prosseguir:
```bash
wc -l "data/issues_$(date +%Y-%m-%d).csv"   # deve ser > 1
head -2 "data/issues_$(date +%Y-%m-%d).csv"
```

---

## 3. Filtrar e analisar localmente (Python)

Use Python para ler o CSV — evita quebra por vírgulas em títulos.

```python
import csv, re
from datetime import datetime, timezone

CSV_PATH = f"data/issues_{datetime.now().strftime('%Y-%m-%d')}.csv"

# --- Filtros de escopo (ajustar conforme o pedido do usuário) ---
LABEL_FILTERS = ["BACKLOG", "BACKLOG (PRIORIZADO)"]   # padrão

issues = []
with open(CSV_PATH, newline='') as f:
    for row in csv.DictReader(f):
        labels = row.get("Labels_Todas", "")
        if not any(lf in labels for lf in LABEL_FILTERS):
            continue

        I   = int(row["Impacto"])    if row["Impacto"]    else None
        C   = int(row["Confianca"])  if row["Confianca"]  else None
        E   = int(row["Facilidade"]) if row["Facilidade"] else None
        ice = int(row["ICE_Score"])  if row["ICE_Score"]  else None

        # Quadrante real (lido dos thresholds do documento)
        # Substituir 7 e 5 pelos valores reais do doc se mudarem
        if I is not None and E is not None:
            if   I >= 7 and E >= 5: quad_real = "QUICK WIN"
            elif I >= 7 and E <= 4: quad_real = "PLAN"
            elif I <= 6 and E >= 5: quad_real = "LATER"
            else:                   quad_real = "DROP"
        else:
            quad_real = None

        ice_calc = I * C * E if (I and C and E) else None

        issues.append({**row,
            "I": I, "C": C, "E": E, "ICE": ice,
            "ice_calc": ice_calc,
            "quad_real": quad_real,
            "moscow": row.get("MoSCoW_Desc") or row.get("MoSCoW_Label", "").replace("MSCW::", ""),
            "prio_label": row.get("Prioridade", "").replace("PRIORIDADE::", ""),
            "bl": "PRIORIZADO" if "BACKLOG (PRIORIZADO)" in labels else "BACKLOG",
        })
```

---

## 4. Detectar anomalias

A detecção é **aberta**: releia o documento de priorização e aplique todas as regras
explícitas. As categorias abaixo são ponto de partida — adicione outras que o documento
mencione como inconsistência ou violação.

```python
anomalies = []   # lista de dicts: {category, iid, title, detail, severity, action}

for i in issues:
    iid, title = i["IID"], i["Titulo"]
    I, C, E    = i["I"], i["C"], i["E"]
    ice, ice_c = i["ICE"], i["ice_calc"]
    moscow     = i["moscow"]
    prio       = i["prio_label"]
    quad       = i["quad_real"]
    tipo       = i["Tipo"].replace("TIPO::", "")
    bl         = i["bl"]

    # a) Label PRIORIDADE != quadrante real
    if quad and prio and prio != quad and prio not in ("", "SEM PRIORIDADE"):
        anomalies.append({"category": "label_prio_diverge", "iid": iid,
            "detail": f"real={quad}, label={prio}",
            "severity": "alta", "action": f"Corrigir label para {quad}"})

    # b) ICE definido mas label ainda é BACKLOG (não priorizado)
    if bl == "BACKLOG" and ice:
        anomalies.append({"category": "backlog_sem_promover", "iid": iid,
            "detail": f"ICE={ice} definido, label ainda BACKLOG",
            "severity": "alta", "action": "Mover para BACKLOG (PRIORIZADO)"})

    # c) ICE registrado != I×C×E calculado
    if ice and ice_c and ice != ice_c:
        anomalies.append({"category": "ice_inconsistente", "iid": iid,
            "detail": f"registrado={ice}, calculado={ice_c} ({I}×{C}×{E})",
            "severity": "media", "action": f"Corrigir ICE na descrição para {ice_c}"})

    # d) COULD/WONT em quadrante QUICK WIN — confunde leituras (não é erro, mas sinalizar)
    if moscow in ("COULD", "WONT") and quad == "QUICK WIN":
        anomalies.append({"category": "could_em_quick_win", "iid": iid,
            "detail": f"MoSCoW={moscow}, quadrante={quad}",
            "severity": "info", "action": "Trava MoSCoW garante ordem correta — sinalizar apenas"})

    # e) Tipo que tem fila separada (PRODUCT, REFINAMENTO) na fila de dev
    if tipo in ("PRODUCT", "REFINAMENTO") and bl in ("BACKLOG", "PRIORIZADO"):
        anomalies.append({"category": "product_na_fila_dev", "iid": iid,
            "detail": f"TIPO::{tipo} compete com issues de dev",
            "severity": "media", "action": "Mover para fila separada (PO/PM)"})

    # f) MoSCoW e quadrante semanticamente contraditórios
    #    Ex: SHOULD em DROP (importante mas descartado), MUST em LATER/DROP
    if moscow == "SHOULD" and quad == "DROP":
        anomalies.append({"category": "moscow_quad_contraditorio", "iid": iid,
            "detail": f"MoSCoW=SHOULD mas quadrante={quad}",
            "severity": "media", "action": "Reavaliar MoSCoW ou scores I/E"})
    if moscow == "MUST" and quad in ("LATER", "DROP"):
        anomalies.append({"category": "moscow_quad_contraditorio", "iid": iid,
            "detail": f"MoSCoW=MUST mas quadrante={quad}",
            "severity": "alta", "action": "Reavaliar scores I/E — MUST não deve cair em LATER/DROP"})

    # g) BUG sem MoSCoW, ICE ou prioridade
    if tipo == "BUG" and (not moscow or not ice or prio in ("", "SEM PRIORIDADE")):
        faltando = [x for x, v in [("MoSCoW", moscow), ("ICE", ice),
                                    ("Prioridade", prio if prio not in ("", "SEM PRIORIDADE") else None)] if not v]
        anomalies.append({"category": "bug_sem_classificacao", "iid": iid,
            "detail": f"Sem: {', '.join(faltando)}",
            "severity": "alta", "action": "Aplicar Via Expressa ou funil normal"})

    # h) Issues sem ICE que deveriam ter (MUST/SHOULD com label PRIORIZADO)
    if bl == "PRIORIZADO" and moscow in ("MUST", "SHOULD") and not ice:
        anomalies.append({"category": "priorizado_sem_ice", "iid": iid,
            "detail": f"MoSCoW={moscow}, sem ICE",
            "severity": "media", "action": "Calcular ICE (PO + Tech Lead)"})
```

---

## 5. Ordenar para o ranking

```python
MOSCOW_ORDER = {"MUST": 0, "SHOULD": 1, "COULD": 2, "WONT": 3, "": 4}
QUAD_ORDER   = {"QUICK WIN": 0, "PLAN": 1, "LATER": 2, "DROP": 3, None: 4}

def sort_key(i):
    return (
        MOSCOW_ORDER.get(i["moscow"], 4),
        QUAD_ORDER.get(i["quad_real"], 4),
        -(i["ICE"] or 0),
    )

ranked = sorted(issues, key=sort_key)
```

---

## 6. Gerar o markdown

Salve em `history/analyses/YYYY-MM-DD_priorizacao_backlog.md`.

### Estrutura obrigatória

```
# Priorização do Backlog

**Data:** DD/MM/YYYY | **Issues:** N (labels `X` + `Y`) | **Com ICE:** N | **Sem ICE:** N
**Funil:** MoSCoW → Quadrante (I×E) → ICE Score
**Fonte:** `data/issues_YYYY-MM-DD.csv`
**Ref.:** documento de priorização do projeto (`caminhos.documento_priorizacao`)

---

## Lista Priorizada

> **Como ler:** [descrição do funil de 3 camadas]

---

### 🔴 MUST — Inegociáveis
#### MUST › QUICK WIN (I≥7, E≥5)
| # | IID | ICE | I | C | E | Tipo | Label | Título |
...

#### MUST › PLAN (I≥7, E≤4)
...

[repetir para SHOULD 🟠, COULD 🟡, WONT ⚫]

### ⚪ SEM ICE / SEM MoSCoW — Aguardando classificação
...

---

## Anomalias Identificadas

### 1. [Nome da categoria]
| IID | ... | Ação |
...

[uma seção por categoria de anomalia encontrada]

---

## Resumo de Ações Prioritárias

| Prioridade | Ação | Issues |
|---|---|---|
| 🔴 Alta | ... | #X, #Y |
| 🟠 Média | ... | #Z |
| 🟡 Baixa | ... | #W |
| ℹ️ Info | ... | #V |

---

> 📊 Dados brutos: `data/issues_YYYY-MM-DD.csv`
```

### Regras de formatação

- Omitir seções vazias (ex: "MUST › PLAN" se não houver nenhuma issue nesse quadrante)
- Anomalias sinalizadas inline na tabela principal com `⚠️` na coluna Label
- Notas de anomalia logo abaixo da tabela afetada com `> ⚠️ **#IID** — ...`
- Seção de anomalia só aparece para categorias com ao menos 1 ocorrência
- Severidade → prioridade no resumo: alta=🔴, media=🟠, baixa=🟡, info=ℹ️
- Issues já corrigidas nesta sessão: marcar com `✅` em vez de `⚠️`

### Colunas da tabela principal

```
| # | IID | ICE | I | C | E | Tipo | Label | Título |
```

- `#` — posição global no ranking (1, 2, 3...)
- `IID` — número com `#` (ex: `#38`)
- `ICE` — em negrito (`**576**`); se houver divergência com calculado, usar o calculado
- `Tipo` — sem prefixo `TIPO::` (ex: `FEATURE`)
- `Label` — `PRIORIZADO` ou `BACKLOG`; adicionar `⚠️` quando houver anomalia
- `Título` — título limpo da issue

---

