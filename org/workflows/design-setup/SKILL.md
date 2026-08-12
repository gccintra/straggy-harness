---
name: design-setup
description: >
  Configura o design system do projeto E faz o scaffold do app de protótipo React
  (prototype/) na primeira vez que o designer é acionado. Extrai tokens de cor,
  tipografia, espaçamento e padrões de componentes de prints/screenshots do sistema
  atual; grava os tokens no tailwind.config.js e cria os componentes base em
  src/components/ui/ transcritos das evidências. Push dos guidelines pro Figma é
  opt-in. Use na primeira vez que o designer for acionado — antes de criar qualquer
  tela — e para atualizar o design system quando ele evoluir.
---

# design-setup

Estabelece a base de design do projeto: **um app React (`prototype/`) com o design system embutido**, extraído de evidências visuais do sistema atual (prints, screenshots, protótipos).

Depois deste setup, o `@product-designer` cria telas como rotas nesse app (`design-screen`), reusando os componentes de `src/components/ui/` e os tokens do `tailwind.config.js`.

**Executado uma vez por projeto** (re-execute só quando o design system evoluir). Push dos guidelines pro Figma é **opt-in** — a fonte de verdade do design system passa a ser o código (`tailwind.config.js` + `components/ui/`), não o Figma.

---

## 1. Configuração

Leia do ambiente:
```
FIGMA_FILE_KEY:      ${FIGMA_FILE_KEY}       ← arquivo Figma do projeto (opcional; só p/ export)
FIGMA_CLIENT_ID:     ${FIGMA_CLIENT_ID}
FIGMA_CLIENT_SECRET: ${FIGMA_CLIENT_SECRET}
```

Figma não é obrigatório no setup — é só destino de export opt-in. Se o usuário pedir push dos guidelines pro Figma e `FIGMA_FILE_KEY` faltar, peça o link e extraia o fileKey de `figma.com/design/:fileKey/...`.

---

## 2. Fontes de input

Peça ao menos uma antes de iniciar:

| Fonte | Como fornecer |
|---|---|
| Screenshots do sistema atual | Arrastar imagens pro terminal ou caminhos locais |
| URL do protótipo (Axure, Figma, etc.) | Link direto |
| PDF de especificação visual | Caminho local |
| Descrição textual do estilo | "azul escuro primário, sans-serif, tabelas de borda fina..." |

Mais evidência visual = design system mais preciso. Nenhuma fonte → avise e pergunte qual usar. **Meça cor de print com Pillow, não estime no olho** (`design-screen` 3B.1).

---

## 3. Extração de tokens

Das fontes, extraia:

### 3.1 Cores
Primária · secundária · background · surface · border · texto primário · texto secundário · erro/sucesso/aviso · cores de status (workflow, badges).

### 3.2 Tipografia
Família(s) · tamanhos px → escala `xs`/`sm`/`base`/`lg`/`xl`/`2xl`/`3xl` · pesos · line-heights.

### 3.3 Espaçamento
Grid base (4/8px) · padding de componentes · gap de listas/tabelas · radius · sombras.

### 3.4 Componentes recorrentes
Botões (primário/secundário/ghost/link/destrutivo) · inputs (texto/select/date/search) · tabelas (cabeçalho/linha/paginação/ordenação) · modais · badges/chips de status · steppers · cards · toasts/alertas · navegação (sidebar/topbar/breadcrumb).

**Valores raw, verbatim.** Hex e px como medidos — não aproxime pro token "mais próximo". Faltou e não há evidência → pergunte.

---

## 4. Scaffold do app `prototype/`

**A saída primária deste setup é o app React.** Grave no repositório, na raiz do projeto, em `prototype/`.

### 4.1 Criar o projeto (só se `prototype/` não existir)

```bash
npm create vite@latest prototype -- --template react-ts
cd prototype
npm install
npm install react-router-dom lucide-react
npm install -D tailwindcss @tailwindcss/vite
```

Tailwind v4 via plugin do Vite. Em `vite.config.ts`, adicione o plugin `@tailwindcss/vite`. Em `src/index.css`, `@import "tailwindcss";`.

> Se o projeto real usa outra versão de Tailwind/React, alinhe com o usuário antes. O default é Vite + React + TS + Tailwind v4 + react-router.

### 4.2 Estrutura obrigatória

```
prototype/
├── tailwind.config.js         ← tokens da Etapa 3 (cor/fonte/espaco/radius/shadow)
├── vite.config.ts
├── index.html                 ← <div id="root">; script capture.js NÃO fica fixo aqui
├── src/
│   ├── main.tsx               ← monta o Router
│   ├── App.tsx                ← <AppLayout> + <Outlet/> (chrome global)
│   ├── router.tsx             ← tabela de rotas; `/` redireciona à tela default
│   ├── index.css              ← @import tailwindcss + base
│   ├── routes/
│   │   └── <modulo>/<tela>.tsx ← telas (sem página-índice/hub)
│   ├── components/
│   │   ├── ui/                ← Button, Input, Table, Modal, Badge, Field... (Etapa 4.4)
│   │   └── layout/            ← AppLayout, AppHeader (topbar + menu de navegação)
│   ├── lib/
│   │   └── ExportFrame.tsx    ← wrapper 1280 sem chrome, p/ export Figma (Etapa 4.5)
│   └── mock/                  ← dados de exemplo por dominio
```

### 4.3 Tokens no `tailwind.config.js`

Os tokens da Etapa 3 viram o `theme.extend` — cores nomeadas pelo papel, escala de fonte, espaçamento, radius, shadow. Este arquivo é a **fonte de verdade dos tokens**; nenhum hex solto no JSX (use as classes Tailwind geradas).

```js
// exemplo de forma — valores REAIS saem da Etapa 3, nunca placeholder
export default {
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        navy: "#003770",       // <- valor medido/extraido, verbatim
        // primary, surface, border, text, status...
      },
      fontFamily: { sans: ["Roboto", "system-ui", "sans-serif"] },
      // spacing, borderRadius, boxShadow do sistema
    },
  },
};
```

### 4.4 Componentes base em `src/components/ui/`

Os componentes da Etapa 3.4 viram componentes React tipados — **fiéis à evidência, verbatim** (mesma altura, radius, cor, estados). Um arquivo por componente. Props pros estados (`variant`, `disabled`, `loading`, `error`).

**Construa sobre libs prontas — não reinvente do zero.** Comportamento/acessibilidade/estado vêm da lib; a aparência sai dos tokens. Ordem: lib pronta reestilizada pros tokens > mão própria. Cada `ui/<Nome>.tsx` envolve o primitivo da lib já estilizado (as telas importam de `ui/`, nunca da lib direto). Libs recomendadas: `design-screen` 3.6 (shadcn/ui, Radix, TanStack Table, Recharts, react-day-picker). Instale o que o design system precisa (`npm i`) já no setup.

Regra dura (mesma da `design-screen`): **a aparência copia a evidência, não inventa.** Um botão que existe no sistema entra com os valores medidos; não "melhore". A lib dá o esqueleto, os tokens dão o visual. Componente/valor sem evidência → pergunte antes de criar.

Ícones: `lucide-react` (`import { Check } from "lucide-react"`) — SVG inline, compatível com a captura Figma.

### 4.5 Layout e navegação

- `components/layout/AppLayout` + `AppHeader` — o chrome do produto (topbar com o **menu de navegação real**). `App.tsx` renderiza `<AppLayout><Outlet/></AppLayout>`. Transcreva a barra de menu da evidência (mesmos itens do sistema atual).
- **Navegação é pelo menu do topbar**, como no sistema real. **Não existe hub/galeria de telas.** Cada item de menu (`AppHeader` NAV) aponta `to` para a rota da tela; item sem tela ainda construída fica inerte.
- `router.tsx` — a rota `/` **redireciona pra tela default** do produto (ex: `/projetos`), nunca uma página-índice.
- `lib/ExportFrame.tsx` — envolve uma tela em um container `w-[1280px]` **sem** o chrome (topbar/menu), ativado por `?export=1`. É o que a captura pro Figma mira (`html-to-figma`).

### 4.6 Rodar

```bash
cd prototype && npm run dev   # http://localhost:5173
```

`/` deve abrir a tela default e os itens do menu do topbar devem navegar entre as telas. Verifique no Chrome antes de encerrar o setup.

---

## 5. Guidelines no Figma (OPT-IN)

Fonte de verdade do design system = código. Só publique uma página de guidelines no Figma se o usuário pedir explicitamente ("manda o design system pro Figma"). Se pedir: renderize uma rota `/design-system` (showcase dos tokens e componentes) e capture via `html-to-figma`. Registre `FIGMA_GUIDELINES_NODE_ID` no `.env` só nesse caso.

---

## 6. Registrar em history/

Crie `history/YYYY-MM-DD_design-setup.md`:

```markdown
# [DESIGN SETUP] Design system + app prototype
Data: YYYY-MM-DD
Agente: designer

## Fontes utilizadas
- [prints/protótipos/descrições fornecidas]

## Tokens extraídos
- Cores: [N nomeadas] · Tipografia: [N estilos] · Componentes: [lista]

## App
- prototype/ criado (Vite + React + TS + Tailwind + react-router)
- Componentes base: [lista de src/components/ui/]

## Figma (se aplicável)
- Guidelines publicados: [URL ou "não"]
```

---

## 7. Publicar o protótipo

Scaffold e telas rodam local (`npm run dev`). Para o protótipo virar **URL compartilhável** — cliente ou time revisando fora da sua máquina — use a skill `prototype-deploy`: ela hospeda o `prototype/` como site estático numa VPS, com basic auth e HTTPS.

Não é passo do setup; chame quando houver o que mostrar.

---

## 8. Quando re-executar

- Design system evoluiu (novos componentes, rebrand)
- Usuário pediu atualização
- Refinar após feedback

Re-execução **não recria** `prototype/` — edita `tailwind.config.js` e `components/ui/` existentes. Só crie do zero se a pasta não existir.
