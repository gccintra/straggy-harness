---
name: html-to-figma
description: >
  Motor de captura DOM → Figma (injeta capture.js, sobe/usa o dev server, insere no
  arquivo via generate_figma_design). Captura a ROTA RENDERIZADA do app prototype/ (Vite)
  em modo export (?export=1). NÃO é gatilho direto do usuário — é invocada por
  `design-screen` (telas) e `design-setup` (guidelines opt-in) apenas no passo de export
  pro Figma, que é opt-in. Para criar uma tela use `design-screen`; para o design system,
  `design-setup`.
---

# Skill: html-to-figma

> **Camada:** implementação de escrita do provider `canvas/` (código → Figma). Procedural
> por natureza. Write-gate e opt-in: `system/providers/canvas/INTERFACE.md`.

## Visão Geral

Motor de export do protótipo pro Figma. O protótipo é o app React (`prototype/`); esta skill captura uma **rota renderizada** dele e insere o node no arquivo Figma alvo.

Fluxo: **rota React renderizada no Vite (`?export=1`) → capture.js espelha o DOM → insert no Figma**.

> **Caminho inverso:** Figma → código é a `design-screen` (§3.2 node de produção, §3A Figma autoral).

---

## Quando usar

Só no passo de **export opt-in** de `design-screen`/`design-setup`, quando o usuário pediu explicitamente "manda a tela X pro Figma". Nunca por reflexo — a fonte de verdade do design é o app, não o Figma.

---

## Pré-requisitos

- Figma MCP conectado (`figma_*` tools)
- `fileKey` do arquivo alvo (`${FIGMA_FILE_KEY}` ou link do usuário → `figma.com/design/:fileKey/...`)
- App `prototype/` rodando no Vite (`npm run dev`, `http://localhost:5173`)
- A tela deve ter modo export: rota renderizável com `?export=1` que ativa o `ExportFrame` (§ abaixo)

---

## O modo export do app (`?export=1`)

A captura precisa da tela **sem o chrome** (sidebar/topbar) e em largura fixa 1280 — senão o node sai com o app inteiro dentro.

`prototype/src/lib/ExportFrame.tsx` (criado no `design-setup`) envolve a tela quando `?export=1`:
- Remove `AppShell` (sidebar/topbar) — só a tela.
- Container `w-[1280px]`, fundo neutro.
- `id="export-frame"` no wrapper de topo → é o `figmaselector` da captura.
- Aplica `aria-label` de topo (nome do frame no Figma) e um `<title>` curto via `document.title`.

Se a rota ainda não respeita `?export=1`, ajuste a rota/`ExportFrame` antes de capturar.

---

## Regras de fidelidade da captura (o que garante node limpo)

**1. Largura desktop = `1280px`** no `ExportFrame`. Não 1440, não 1920.

**2. Ícones = `lucide-react`, inline.** Renderiza `<svg>` inline no DOM — o capture.js espelha. Nunca `<use href>`/`<symbol>` (sai vazio). `lucide-react` já faz certo; não use sprite.

**3. Uma captura por tela/estado.** Cada `?export=1` (e cada `?state=`) é uma captura separada → nodes irmãos no Figma. Nunca capture `body` com o app inteiro.

**4. Nomear nodes via `aria-label` — validado empiricamente.**
- **`aria-label="Nome do Node"` no elemento → o node vira exatamente esse nome.** Único hook confiável.
- `<div aria-label="...">` = nome limpo, sem prefixo. `<section>`/`<nav>` + `aria-label` prefixam "Section - "/"Navigation - ".
- **NÃO funcionam** (ignorados): `title`, `data-figma-name`, `data-name`, `data-fg-name`.
- Sem `aria-label`: `<div>`→"Container", `<button>`→"Button" (fallback pela tag). Text node = nomeado pelo texto.
- **Top frame** ganha sufixo `(<document.title>)`. `ExportFrame` seta um `document.title` curto e `aria-label` limpo no wrapper.

**5. DOM raso.** React tende a aninhar wrappers. No JSX da tela, evite `<div>` de embrulho que só existe pra CSS — Tailwind vai direto no elemento semântico. `::before`/`::after` decorativos → `data-h2d-suppress-before` / `data-h2d-suppress-after`.

> Regra prática: todo container que deve virar node identificável no Figma leva `aria-label`. Bônus: é acessibilidade real.

---

## Injetar o capture.js

O script **não fica fixo** no `index.html` do app (atrapalha o dev normal). Injete só no momento do export, por um destes caminhos:

- **Query flag no app**: `ExportFrame`, quando `?export=1`, injeta dinamicamente
  `<script src="https://mcp.figma.com/mcp/html-to-design/capture.js" async>` no `<head>`.
- Ou injeção manual via `claude-in-chrome` `javascript_tool` na aba aberta.

O importante: o capture.js precisa estar presente na página no momento em que a URL de captura (`#figmacapture=...`) é aberta.

---

## Fluxo de captura (por tela/estado)

Verifique o Vite antes:
```bash
lsof -i :5173 || (cd prototype && npm run dev &)   # espere subir
curl -s -o /dev/null -w "%{http_code}" "http://localhost:5173/<rota>?export=1"
```

Repita para cada tela/estado:

```
1. generate_figma_design com outputMode="existingFile" e fileKey=<fileKey>
   → retorna captureId

2. Abrir a URL de captura no browser (macOS), mirando o ExportFrame:
   open "http://localhost:5173/<rota>?export=1&figmacapture=<captureId>&figmaselector=%23export-frame&figmaendpoint=https%3A%2F%2Fmcp.figma.com%2Fmcp%2Fcapture%2F<captureId>%2Fsubmit&figmadelay=1000"
   (%23export-frame = #export-frame; figmadelay dá tempo do React montar)

3. Aguardar ~5s (React monta + capture.js roda)

4. Polling: generate_figma_design com captureId=<captureId> e fileKey=<fileKey>
   → repetir a cada 5s até status="completed" (máx 10 tentativas)

5. completed → guardar a URL do node

6. Próximo estado: troque ?state= e refaça 1–5. Ao final, retorne todas as URLs.
```

> `figmadelay=1000` é mais importante aqui que no HTML estático: o React precisa montar a rota antes da captura. Se o node sair vazio, aumente o delay.

---

## Checklist antes de capturar

- [ ] Vite rodando; `/<rota>?export=1` responde 200
- [ ] `ExportFrame` ativo: sem sidebar/topbar, `w-[1280px]`, `id="export-frame"`
- [ ] capture.js injetado na página (via `?export=1` ou manual)
- [ ] Ícones `lucide-react` (SVG inline no DOM)
- [ ] Blocos relevantes com `aria-label` = nome do node
- [ ] `document.title` curto (controla o sufixo do frame)
- [ ] Um `?state=` por captura; nunca `body` inteiro
- [ ] NÃO capturar o chrome do app (topbar/menu) — só a tela via `ExportFrame`

---

## Output Format

```
## html-to-figma: export concluído

### Tela
- Rota: /<modulo>/<tela>  (estados exportados: default, empty, ...)

### Figma
- Arquivo: <fileKey>
- Nodes: <URL por estado>

### Checklist
- [x] ExportFrame 1280 sem chrome
- [x] aria-label nomeando nodes
- [x] lucide-react inline
- [x] captura por estado
```
