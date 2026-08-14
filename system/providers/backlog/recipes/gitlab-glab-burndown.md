# Export e burndown — código de referência

Procedural (jq / HTML do burndown). O contrato do relatório está no SKILL.md.

### Passo 2 — Exportar com glab + jq

> **`DADOS`** é o diretório de export do projeto — `caminhos.dados` do `project-config.yaml`.
> Exporte antes de rodar os blocos abaixo: `export DADOS="$(...)"`. Nunca escreva o caminho literal.

**Para backlog completo (todas as issues, sem limite de paginação):**

```bash
REPO_ENCODED="${GITLAB_REPO//\//\%2F}"

glab api --paginate \
  "projects/${REPO_ENCODED}/issues?per_page=100" \
  --hostname ${GITLAB_HOST} \
  | jq -r '
    ["IID","Título","Estado","Tipo","Labels","Prioridade","Milestone","Assignee","Autor","Criada em","Atualizada em","Fechada em","Weight"],
    (.[] | [
      .iid,
      .title,
      .state,
      (if .issue_type then .issue_type else "issue" end),
      (.labels | join("|")),
      (.labels | map(select(startswith("PRIORIDADE::"))) | if length > 0 then .[0] else "" end),
      (if .milestone then .milestone.title else "" end),
      (if .assignees and (.assignees | length) > 0 then .assignees[0].username else "" end),
      .author.username,
      .created_at,
      .updated_at,
      (if .closed_at then .closed_at else "" end),
      (if .weight then .weight else "" end)
    ]) | @csv
  ' > ${DADOS}issues_$(date +%Y-%m-%d).csv
```

**Para uma sprint específica (filtro de milestone):**

O export de sprint inclui `closed_at` — campo obrigatório para o burndown chart do Passo 3.5.

```bash
MILESTONE_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${MILESTONE_NAME}'))")
REPO_ENCODED="${GITLAB_REPO//\//\%2F}"

glab api --paginate \
  "projects/${REPO_ENCODED}/issues?milestone=${MILESTONE_ENCODED}&per_page=100" \
  --hostname ${GITLAB_HOST} \
  | jq -r '
    ["IID","Título","Estado","Labels","Prioridade","Assignee","Criada em","Atualizada em","Fechada em","Weight"],
    (.[] | [
      .iid,
      .title,
      .state,
      (.labels | join("|")),
      (.labels | map(select(startswith("PRIORIDADE::"))) | if length > 0 then .[0] else "" end),
      (if .assignees and (.assignees | length) > 0 then .assignees[0].username else "" end),
      .created_at,
      .updated_at,
      (if .closed_at then .closed_at else "" end),
      (if .weight then .weight else "" end)
    ]) | @csv
  ' > ${DADOS}sprint_${MILESTONE_NAME// /_}_$(date +%Y-%m-%d).csv
```

> **Nota sobre labels:** o campo `Labels` contém todas as labels separadas por `|`. A coluna `Prioridade` extrai especificamente as labels com prefixo `PRIORIDADE::`. Adapte o prefixo conforme a taxonomia do projeto — identifique os prefixos de tipo e prioridade consultando `glab label list -R ${GITLAB_REPO}` antes de exportar se não souber.

### Passo 3 — Verificar o export

```bash
wc -l ${DADOS}issues_$(date +%Y-%m-%d).csv
head -3 ${DADOS}issues_$(date +%Y-%m-%d).csv
```

Se o arquivo tiver 0 ou 1 linha (só cabeçalho), o export falhou — verificar autenticação e variáveis de ambiente.

---

## 3. Analisar o CSV

Com o arquivo gerado, leia-o e calcule as métricas abaixo. **Toda a análise é feita sobre o arquivo local** — sem novos requests à API.

### 3.1 Métricas de volume

```
Total de issues no escopo
├── Abertas: N
├── Fechadas: N
└── Por estado de workflow: N por label de workflow
```

### 3.2 Distribuição por tipo e prioridade

```
Por tipo (uma linha por rótulo de tipo encontrado + SEM TIPO):
  <TIPO>:       N  (XX%)
  ...

Por faixa de prioridade (as bandas do funil declarado, na ordem, + SEM PRIORIDADE):
  <BANDA>:      N  (XX%)
  ...
```

### 3.3 Métricas de saúde

```
Issues sem sprint alocada:     N  (XX%)
Issues sem assignee:           N  (XX%)
Issues sem tipo definido:      N  (XX%)
Issues sem prioridade:         N  (XX%)
Idade média (dias):            N
Issues "zumbis" (>180 dias):   N
```

### 3.4 Métricas de sprint (quando escopo = sprint específica)

```
Sprint: [nome]
Total de issues:  N
Abertas:          N  (XX%)
Fechadas:         N  (XX%)
Taxa de conclusão: XX%

Por assignee:
  [usuário]:  N abertas / N fechadas
```

### 3.5 Score de saúde do backlog (0–100)

Calcule um score único baseado em penalizações:

| Problema | Penalização por issue |
|---|---|
| Sem tipo | -2 pts |
| Sem prioridade | -2 pts |
| Sem sprint | -1 pt |
| Zumbi (>180 dias sem atualização) | -3 pts |

```
Score = max(0, 100 - total_penalizações)
Classificação:
  80–100: Saudável
  60–79:  Atenção
  40–59:  Problemático
  0–39:   Crítico
```

---

## 3.5 Gerar burndown chart (apenas para sprint específica)

Execute este passo **somente quando o escopo for uma sprint específica** (não para análise geral do backlog).

### O que é o burndown

O burndown mostra quantas issues restam abertas a cada dia da sprint. A linha ideal decresce linearmente do total de issues no dia de início até zero no dia de término. A linha real mostra o progresso efetivo, calculado com base no campo `closed_at` de cada issue (`state=closed`).

### Buscar datas da milestone

O CSV já tem `closed_at`. Falta buscar `start_date` e `due_date` da milestone — uma chamada adicional:

```bash
REPO_ENCODED="${GITLAB_REPO//\//\%2F}"

glab api \
  "projects/${REPO_ENCODED}/milestones?search=${MILESTONE_NAME}&per_page=10" \
  --hostname ${GITLAB_HOST} \
  | jq '.[] | {title, start_date, due_date}'
```

Se `start_date` for nulo, use a data de criação da issue mais antiga da sprint como proxy.

### Gerar o arquivo HTML do burndown

Gere `{caminhos.dados}burndown_${MILESTONE_NAME// /_}_$(date +%Y-%m-%d).html`.

O arquivo deve ser **auto-contido** — funciona com duplo-clique, sem servidor.

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>Burndown — [NOME DA SPRINT]</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4/dist/chart.umd.min.js"></script>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 900px; margin: 40px auto; padding: 0 20px; background: #f9f9f9; color: #111; }
    h1 { font-size: 1.4rem; margin-bottom: 4px; }
    .meta { color: #666; font-size: 0.85rem; margin-bottom: 24px; }
    canvas { background: #fff; border: 1px solid #e0e0e0; border-radius: 8px; padding: 16px; }
    .summary { display: flex; gap: 16px; margin-bottom: 20px; flex-wrap: wrap; }
    .stat { background: #fff; border: 1px solid #e0e0e0; border-radius: 8px; padding: 12px 16px; flex: 1; min-width: 120px; }
    .stat .value { font-size: 1.8rem; font-weight: 700; }
    .stat .label { font-size: 0.78rem; color: #666; margin-top: 2px; }
  </style>
</head>
<body>

<h1>Burndown — [NOME DA SPRINT]</h1>
<p class="meta">
  Período: [START_DATE] → [DUE_DATE] &nbsp;|&nbsp;
  Gerado em: [DATA_GERACAO] &nbsp;|&nbsp;
  Total de issues: [TOTAL]
</p>

<div class="summary">
  <div class="stat"><div class="value">[TOTAL]</div><div class="label">Total de issues</div></div>
  <div class="stat"><div class="value">[DONE]</div><div class="label">Concluídas</div></div>
  <div class="stat"><div class="value">[REMAINING]</div><div class="label">Restantes</div></div>
  <div class="stat"><div class="value">[PROGRESS]%</div><div class="label">Progresso</div></div>
</div>

<canvas id="burndownChart" height="80"></canvas>

<script>
// ── DADOS DA SPRINT (preenchidos pela IA) ────────────────────────────────────
const SPRINT = {
  name:      "[NOME DA SPRINT]",
  startDate: "[START_DATE]",  // "YYYY-MM-DD"
  dueDate:   "[DUE_DATE]",    // "YYYY-MM-DD"
  issues: [
    // { iid: 123, closedAt: "YYYY-MM-DDTHH:MM:SSZ" | null, state: "closed" | "opened" }
    /* [ISSUES_DATA] */
  ]
};
// ─────────────────────────────────────────────────────────────────────────────

function getDates(start, end) {
  const dates = [], cur = new Date(start), last = new Date(end);
  while (cur <= last) {
    dates.push(cur.toISOString().split('T')[0]);
    cur.setDate(cur.getDate() + 1);
  }
  return dates;
}

const dates = getDates(SPRINT.startDate, SPRINT.dueDate);
const total = SPRINT.issues.length;

// Linha ideal: decréscimo linear de total até 0
const ideal = dates.map((_, i) => Math.round(total - (total / (dates.length - 1)) * i));

// Linha real: issues sem closed_at ou com closed_at > data do dia = ainda abertas
const real = dates.map(date =>
  SPRINT.issues.filter(issue => {
    if (issue.state !== 'closed' || !issue.closedAt) return true;
    return issue.closedAt.split('T')[0] > date;
  }).length
);

// Cortar linha real no dia atual (sem projetar futuro)
const today = new Date().toISOString().split('T')[0];
const cutIdx = dates.findIndex(d => d > today);
const realFinal = cutIdx === -1 ? real : [
  ...real.slice(0, cutIdx + 1),
  ...Array(dates.length - cutIdx - 1).fill(null)
];

new Chart(document.getElementById('burndownChart').getContext('2d'), {
  type: 'line',
  data: {
    labels: dates,
    datasets: [
      {
        label: 'Ideal',
        data: ideal,
        borderColor: '#aaa',
        borderDash: [6, 4],
        borderWidth: 2,
        pointRadius: 0,
        tension: 0,
        fill: false,
      },
      {
        label: 'Real',
        data: realFinal,
        borderColor: '#2563eb',
        backgroundColor: 'rgba(37,99,235,0.08)',
        borderWidth: 2.5,
        pointRadius: 3,
        pointBackgroundColor: '#2563eb',
        tension: 0.1,
        fill: true,
        spanGaps: false,
      }
    ]
  },
  options: {
    responsive: true,
    plugins: {
      legend: { position: 'top' },
      tooltip: { callbacks: { label: c => `${c.dataset.label}: ${c.parsed.y} issues restantes` } }
    },
    scales: {
      x: { title: { display: true, text: 'Data' }, ticks: { maxTicksLimit: 14, maxRotation: 45 } },
      y: { title: { display: true, text: 'Issues restantes' }, min: 0, ticks: { stepSize: 1 } }
    }
  }
});
</script>
</body>
</html>
```

### Como preencher os dados no HTML

Substitua `/* [ISSUES_DATA] */` com os dados do CSV:

```javascript
{ iid: 123, closedAt: "2026-05-15T14:32:00Z", state: "closed" },
{ iid: 124, closedAt: null, state: "opened" },
```

Substitua também os placeholders `[TOTAL]`, `[DONE]`, `[REMAINING]`, `[PROGRESS]`, `[START_DATE]`, `[DUE_DATE]`, `[DATA_GERACAO]` e `[NOME DA SPRINT]` com os valores reais.

### Onde salvar

```
{caminhos.dados}burndown_[SPRINT_NAME]_YYYY-MM-DD.html
```

---

