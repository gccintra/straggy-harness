---
name: html-to-figma
description: Motor de captura HTML → Figma (injeta script, sobe dev server, insere no arquivo via generate_figma_design). NÃO é gatilho direto do usuário — é invocada pelas skills `design-screen` (telas) e `design-setup` (guidelines) apenas no passo de push pro Figma, que é opt-in. Para criar uma tela nova use `design-screen`; para configurar o design system use `design-setup`.
---

# Skill: html-to-figma

## Visão Geral

Esta skill define o fluxo obrigatório para criar telas/componentes UI e publicá-los diretamente no Figma.
O fluxo é: **HTML bem estruturado → dev server local → script de captura Figma → insert no arquivo Figma alvo**.

> **Skill inversa:** `figma-implement-design` faz o caminho contrário (Figma → código).

---

## Quando Usar Esta Skill

Ativar SEMPRE que a tarefa envolver:
- Criar uma nova tela (login, dashboard, landing page, modal, etc.)
- Criar um componente visual para revisão/validação no Figma
- O usuário pedir "criar no Figma", "inserir no Figma", "tela para o Figma"
- O plano da task (orchestrator) listar escopo `frontend` com destino Figma

---

## Pré-requisitos

- Figma MCP server conectado (`figma_*` tools disponíveis)
- `fileKey` do arquivo Figma alvo (extraído da URL: `figma.com/design/:fileKey/...`)
- Dev server local disponível (Python, Node http-server, Vite, etc.)

---

## Fluxo Obrigatório (seguir em ordem)

### Etapa 1 — Planejar o Design

Antes de escrever uma linha de HTML, defina:

1. **Leia `PROJECT_CONTEXT.md`** — identifique design system existente, paleta, tipografia, componentes já estabelecidos
2. **Defina a hierarquia visual** seguindo os princípios da skill `frontend-design`:
   - Layout: qual estrutura (split, centered, grid, sidebar)?
   - Tipografia: escala clara (display, heading, body, caption)
   - Paleta: tokens de cor (primary, surface, text, border, etc.)
   - Espaçamento: sistema consistente (4px base grid)
3. **Liste os componentes da tela** em ordem hierárquica (Atomic Design):
   - Átomos: botões, inputs, labels, badges
   - Moléculas: form fields, cards, nav items
   - Organismos: header, form, sidebar, footer

---

### Etapa 2 — Criar o HTML com Padrão de Mercado

Crie o arquivo HTML seguindo OBRIGATORIAMENTE estas regras de qualidade:

#### Estrutura do arquivo
```
<project-root>/
  <screen-name>.html   ← arquivo da tela (ex: login.html, dashboard.html)
```

#### Regras de HTML/CSS obrigatórias

**1. CSS Custom Properties (design tokens)**
```css
:root {
  /* Cores */
  --color-bg: #fff;
  --color-surface: #f8f8f8;
  --color-border: #e5e5e5;
  --color-text-primary: #111;
  --color-text-secondary: #666;
  --color-accent: #000;
  --color-accent-hover: #333;

  /* Tipografia */
  --font-sans: 'Inter', system-ui, -apple-system, sans-serif;
  --text-xs: 0.75rem;    /* 12px */
  --text-sm: 0.875rem;   /* 14px */
  --text-base: 1rem;     /* 16px */
  --text-lg: 1.125rem;   /* 18px */
  --text-xl: 1.25rem;    /* 20px */
  --text-2xl: 1.5rem;    /* 24px */
  --text-3xl: 1.875rem;  /* 30px */
  --text-4xl: 2.25rem;   /* 36px */

  /* Espaçamento (4px base grid) */
  --space-1: 0.25rem;   /* 4px  */
  --space-2: 0.5rem;    /* 8px  */
  --space-3: 0.75rem;   /* 12px */
  --space-4: 1rem;      /* 16px */
  --space-5: 1.25rem;   /* 20px */
  --space-6: 1.5rem;    /* 24px */
  --space-8: 2rem;      /* 32px */
  --space-10: 2.5rem;   /* 40px */
  --space-12: 3rem;     /* 48px */
  --space-16: 4rem;     /* 64px */

  /* Bordas */
  --radius-sm: 4px;
  --radius-md: 6px;
  --radius-lg: 8px;
  --radius-xl: 12px;
  --radius-full: 9999px;

  /* Sombras */
  --shadow-sm: 0 1px 2px rgba(0,0,0,0.06);
  --shadow-md: 0 4px 8px rgba(0,0,0,0.08);
  --shadow-lg: 0 8px 24px rgba(0,0,0,0.10);

  /* Transições */
  --transition: 150ms ease;
}
```

**2. Auto Layout via Flexbox/Grid (equivalente ao Auto Layout do Figma)**

Todo container deve usar flex ou grid — NUNCA posicionamento absoluto para layout:
```css
/* Equivalente ao Auto Layout Horizontal */
.row    { display: flex; align-items: center; gap: var(--space-N); }
/* Equivalente ao Auto Layout Vertical */
.col    { display: flex; flex-direction: column; gap: var(--space-N); }
/* Equivalente ao Frame com Fill container */
.fill   { flex: 1; min-width: 0; }
/* Equivalente ao Frame com Hug contents */
.hug    { display: inline-flex; }
```

**3. Semântica HTML5**
```html
<main>, <section>, <article>, <aside>, <header>, <footer>, <nav>
<form>, <fieldset>, <label for="...">, <input id="...">
<button type="submit|button|reset">
<h1>→<h2>→<h3> (hierarquia correta, sem pular níveis)
```

**4. Acessibilidade mínima**
```html
<!-- Inputs sempre com label associada -->
<label for="email">E-mail</label>
<input id="email" type="email" aria-required="true" />

<!-- Botões com texto descritivo ou aria-label -->
<button aria-label="Fechar modal">×</button>

<!-- Imagens com alt -->
<img src="..." alt="Descrição significativa" />

<!-- Foco visível -->
:focus-visible { outline: 2px solid var(--color-accent); outline-offset: 2px; }
```

**5. Padrões de componentes obrigatórios**

Input field:
```html
<div class="field">
  <label class="field__label" for="input-id">Label</label>
  <input class="field__input" id="input-id" type="text" placeholder="Placeholder" />
</div>
```

Button primário:
```html
<button class="btn btn--primary" type="submit">Texto do Botão</button>
```

Card:
```html
<div class="card">
  <div class="card__header">...</div>
  <div class="card__body">...</div>
  <div class="card__footer">...</div>
</div>
```

**6. Reset e base obrigatórios**
```css
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: var(--font-sans); color: var(--color-text-primary); background: var(--color-bg); line-height: 1.5; -webkit-font-smoothing: antialiased; }
```

---

### Etapa 3 — Injetar o Script de Captura Figma

Após criar o HTML, adicionar o script de captura no `<head>`:

```html
<script src="https://mcp.figma.com/mcp/html-to-design/capture.js" async></script>
```

**IMPORTANTE:** Deixar o script no arquivo após a captura (não remover), conforme documentação do Figma MCP.

---

### Etapa 4 — Subir o Dev Server Local

Verificar se já existe um servidor rodando antes de iniciar um novo:

```bash
# Verificar se porta está em uso
lsof -i :4321

# Se não estiver em uso, iniciar servidor Python (mais universal):
python3 -m http.server 4321 --directory <project-root> &
sleep 2

# Verificar se está respondendo:
curl -s -o /dev/null -w "%{http_code}" http://localhost:4321/<screen-name>.html
```

Portas recomendadas (em ordem de preferência): `4321`, `3000`, `8080`, `5173`.

Se o projeto já possui um dev server (Vite, Next.js, etc.), usar o URL do projeto existente.

---

### Etapa 5 — Gerar o Capture ID e Inserir no Figma

```
1. Chamar generate_figma_design com outputMode="existingFile" e fileKey=<fileKey>
   → Retorna um captureId

2. Abrir a URL de captura no browser (macOS):
   open "http://localhost:<port>/<screen>.html#figmacapture=<captureId>&figmaendpoint=https%3A%2F%2Fmcp.figma.com%2Fmcp%2Fcapture%2F<captureId>%2Fsubmit&figmadelay=1000"

3. Aguardar 5 segundos

4. Iniciar polling: chamar generate_figma_design com captureId=<captureId> e fileKey=<fileKey>
   → Repetir a cada 5s até status="completed" (máximo 10 tentativas)

5. Quando completed: retornar a URL do node criado no Figma
```

---

### Etapa 6 — Validar o Resultado

Após a inserção no Figma:

- [ ] A tela foi inserida no arquivo correto
- [ ] O layout visual condiz com o HTML criado
- [ ] Tipografia e espaçamento estão corretos
- [ ] A URL do node Figma foi retornada ao usuário

---

## Checklist de Qualidade do HTML

Antes de abrir o browser para captura, verificar:

- [ ] CSS custom properties definidas no `:root`
- [ ] Auto layout via flexbox/grid (sem `position: absolute` para layout)
- [ ] Semântica HTML5 correta
- [ ] Labels associadas a inputs (`for` + `id`)
- [ ] Hierarquia de headings correta (h1→h2→h3)
- [ ] `focus-visible` estilizado
- [ ] Reset CSS aplicado
- [ ] Script de captura Figma no `<head>`
- [ ] Responsive (viewport meta tag presente)

---

## Checklist de Design de Mercado

- [ ] Tipografia com escala clara e consistente
- [ ] Espaçamento baseado em grid de 4px/8px
- [ ] Paleta de cores com tokens nomeados (não hardcoded)
- [ ] Hierarquia visual clara (o que chama atenção primeiro?)
- [ ] Estados interativos definidos (hover, focus, disabled)
- [ ] Contraste WCAG AA: texto normal ≥ 4.5:1, texto grande ≥ 3:1

---

## Exemplo de Estrutura Completa

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Nome da Tela | Produto</title>
  <script src="https://mcp.figma.com/mcp/html-to-design/capture.js" async></script>
  <style>
    /* 1. Design Tokens */
    :root { /* ... tokens ... */ }

    /* 2. Reset */
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: var(--font-sans); ... }

    /* 3. Layout (Auto Layout equivalents) */
    .page    { display: flex; min-height: 100vh; }
    .sidebar { display: flex; flex-direction: column; width: 320px; }
    .main    { flex: 1; display: flex; flex-direction: column; }

    /* 4. Componentes (Atoms → Organisms) */
    .btn { ... }
    .btn--primary { ... }
    .field { ... }
    .card { ... }
  </style>
</head>
<body>
  <!-- Semantic HTML5 structure -->
  <div class="page">
    <aside class="sidebar">...</aside>
    <main class="main">
      <header>...</header>
      <section>...</section>
    </main>
  </div>
</body>
</html>
```

---

## Output Format

Ao concluir, reportar:

```
## html-to-figma: Concluído

### Arquivo criado
- `<path>/<screen>.html`

### Design aplicado
- Layout: <split|centered|grid|sidebar>
- Paleta: <tokens utilizados>
- Tipografia: <fonte e escala>
- Componentes: <lista>

### Figma
- Arquivo: <fileKey>
- Node inserido: <URL do node>

### Checklist de qualidade
- [x] CSS tokens definidos
- [x] Auto layout via flexbox/grid
- [x] Semântica HTML5
- [x] Acessibilidade básica
- [x] Script de captura injetado
- [x] Captura executada e inserida no Figma
```
