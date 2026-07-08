---
name: design-setup
description: >
  Cria o design system do projeto no Figma a partir de prints/screenshots do sistema
  atual. Extrai tokens de cor, tipografia, espaçamento e padrões de componentes das
  imagens fornecidas, gera uma página de guidelines estruturada no Figma, e registra
  o fileKey e nodeId de referência no .env do projeto. Use esta skill na primeira vez
  que o designer for acionado em um projeto — antes de criar qualquer tela nova.
  Também use para atualizar os guidelines quando o design system evoluir.
---

# design-setup

Cria o design system do projeto no Figma a partir de evidências visuais do sistema atual (prints, screenshots, protótipos). O objetivo é ter uma página de guidelines no Figma que sirva como fonte de verdade para todas as telas geradas a seguir — componentes, tokens e padrões ficam lá, não em arquivos locais.

**Este fluxo é executado uma vez por projeto.** Depois que os guidelines existem no Figma, o `@product-designer` copia os componentes de lá em vez de reinventá-los.

---

## 1. Configuração

Leia do ambiente:
```
FIGMA_CLIENT_ID:     ${FIGMA_CLIENT_ID}
FIGMA_CLIENT_SECRET: ${FIGMA_CLIENT_SECRET}
FIGMA_FILE_KEY:      ${FIGMA_FILE_KEY}       ← arquivo Figma do projeto (preencher no .env)
```

Se `FIGMA_FILE_KEY` não estiver no `.env`, peça ao usuário o link do arquivo Figma e extraia o fileKey da URL: `figma.com/design/:fileKey/...`

---

## 2. Fontes de input

O agente deve solicitar ao usuário pelo menos uma dessas fontes antes de iniciar:

| Fonte | Como fornecer |
|---|---|
| Screenshots do sistema atual | Arrastar imagens para o terminal ou fornecer caminhos locais |
| URL do protótipo (Axure, Figma, etc.) | Link direto para o protótipo funcional |
| PDF de especificação visual | Caminho local para o arquivo |
| Descrição textual do estilo | "O sistema usa azul escuro como cor primária, fonte sans-serif, tabelas com bordas finas..." |

Quanto mais evidências visuais, mais preciso será o design system extraído. Se nenhuma fonte for fornecida, avise o usuário e pergunte qual prefere usar.

---

## 3. Extração de tokens

A partir das fontes fornecidas, extraia:

### 3.1 Cores
Identifique e nomeie:
- **Cor primária** — botões principais, links, destaques ativos
- **Cor secundária** — elementos de apoio, badges, highlights
- **Background** — fundo da página
- **Surface** — cards, modais, painéis
- **Border** — bordas de campos, separadores
- **Texto primário** — corpo de texto principal
- **Texto secundário** — labels, subtítulos, placeholders
- **Erro / Sucesso / Aviso** — feedback de sistema
- **Cores de status** — se houver (ex: cores de workflow, badges coloridos)

### 3.2 Tipografia
- Família(s) de fonte usada(s)
- Tamanhos identificados (px) → mapeados para escala: `xs`, `sm`, `base`, `lg`, `xl`, `2xl`, `3xl`
- Pesos usados (regular, medium, semibold, bold)
- Line-heights e letter-spacings se identificáveis

### 3.3 Espaçamento
- Grid base (4px, 8px, ou outro)
- Padding interno de componentes
- Gap entre elementos em listas/tabelas

### 3.4 Componentes identificados
Liste os componentes recorrentes encontrados nas evidências:
- Botões (tipos: primário, secundário, ghost, link, destrutivo)
- Inputs (texto, select, date, search)
- Tabelas (cabeçalho, linhas, paginação, ordenação)
- Modais
- Badges / chips de status
- Steppers
- Cards
- Toasts / alertas
- Navegação (sidebar, topbar, breadcrumb)

---

## 4. Criar a página de guidelines no Figma

Use a skill `html-to-figma` para construir a página de guidelines como HTML estruturado e inserir no Figma.

**Três regras fixas de captura** (herdam de `html-to-figma`):
1. **Ícones = Lucide, inline** — lib fixa do projeto ([lucide.dev](https://lucide.dev)). Nunca `<use>`/`<symbol>` (ícone sai vazio no Figma); copie o SVG oficial e repita o markup em cada uso.
2. **Largura desktop = `1280px`** nos exemplos de layout/padrões de tela.
3. **Se a página de guidelines tiver múltiplos frames de topo**, dê `id="frame-N"` a cada um e capture um por um com `figmaselector=%23frame-N` — nunca capture `body` inteiro.
4. **HTML raso e semântico** — o `capture.js` espelha o DOM 1:1 e não achata. Sem wrapper `<div>` redundante (máx 1 por bloco), blocos em tag semântica, e `data-h2d-suppress-before/after` nos pseudo-elementos decorativos. `<div>` vira "Container" no Figma; nome custom de node não é suportado.

### Estrutura da página de guidelines

```html
<!-- Organização em seções verticais, cada uma com título e exemplos visuais -->

<!-- Seção 1: Cores -->
<!-- Paleta completa com nome do token, valor hex e exemplo de uso -->

<!-- Seção 2: Tipografia -->
<!-- Cada estilo com fonte, tamanho, peso e exemplo de texto -->

<!-- Seção 3: Espaçamento -->
<!-- Grid visual com os valores do sistema -->

<!-- Seção 4: Componentes -->
<!-- Cada componente em seus estados: default, hover, focus, disabled, error -->

<!-- Seção 5: Padrões de tela -->
<!-- Layout típico do sistema: sidebar + main, header, tabela paginada -->
```

### Requisitos visuais da página de guidelines
- Fundo neutro (branco ou cinza muito claro)
- Cada seção separada visualmente com título em destaque
- Componentes renderizados em todos os estados relevantes
- Tokens de cor mostrados como swatches com nome e valor hex
- Escala tipográfica mostrada com texto de exemplo real (não "Lorem ipsum")

Aplique os princípios da skill `frontend-design` para garantir qualidade visual e acessibilidade.

> A página de guidelines (captura HTML) serve o fluxo **A** (`design-screen` → `html-to-figma`) como referência visual. Para o fluxo **B** (`design-promote`, saída limpa) o design system precisa existir como **variáveis e componentes publicados** — não como captura. É o que a Etapa 4b faz.

---

## 4b. Publicar variáveis e componentes reais (fundação do fluxo B)

O fluxo **B** (skill `design-promote`) monta telas limpas reusando **variáveis e componentes publicados** no Figma — não a captura HTML. Esta etapa publica esses ativos via `use_figma` e cacheia as keys para o promote não re-explorar o design system a cada tela (amortização do custo).

Use a skill oficial `figma-generate-library` como base técnica para criar variáveis e componentes reais no Figma via `use_figma`.

### 4b.1 Publicar variáveis (tokens)

A partir dos tokens extraídos na Etapa 3, crie **variáveis Figma reais** (não swatches capturados):
- Coleção de cor: cada token nomeado (`color/primary`, `color/surface`, `color/text-primary`, ...)
- Coleção de espaçamento: `space/1`..`space/16` (grid base do projeto)
- Coleção de radius: `radius/sm`..`radius/full`

### 4b.2 Publicar componentes

A partir dos componentes identificados na Etapa 3.4, crie **componentes Figma reais** com variantes, vinculando as variáveis acima (não hex/px hardcoded):
- Button (variantes: primary, secondary, ghost, link, destructive)
- Input (texto, select, date, search)
- Table (cabeçalho, linha, paginação)
- Badge/chip de status, Card, Modal, Stepper, Toast, itens de navegação
- Largura de referência desktop: **1280px** (padrão do projeto)

### 4b.3 Cachear as keys

Salve o mapa de keys em arquivos json no repositório (o promote lê daqui, sem re-descobrir):

```
.agents/design-system/figma-variables-map.json   → { "color/primary": "<variableKey>", ... }
.agents/design-system/figma-components-map.json   → { "Button": "<componentSetKey>", ... }
```

> Se por restrição de tempo só publicar variáveis nesta rodada, tudo bem: o promote ainda gera nodes nomeados + Auto Layout + tokens vinculados (só sem instância de componente). Publicar componentes depois é incremental — re-execute esta etapa.

---

## 5. Registrar no .env

Após criar os guidelines e publicar variáveis/componentes, adicione ao `.env` do projeto:

```bash
# Design System (Figma)
FIGMA_FILE_KEY=<fileKey do arquivo>
FIGMA_GUIDELINES_NODE_ID=<nodeId da página de guidelines criada>

# Mapas de keys publicadas (fundação do fluxo B / design-promote)
FIGMA_VARIABLES_MAP=.agents/design-system/figma-variables-map.json
FIGMA_COMPONENTS_MAP=.agents/design-system/figma-components-map.json
```

O `FIGMA_GUIDELINES_NODE_ID` é a referência visual que o `@product-designer` usa no fluxo A. Os mapas `FIGMA_VARIABLES_MAP`/`FIGMA_COMPONENTS_MAP` são a fundação do fluxo B — se estiverem ausentes, `design-promote` degrada para nodes nomeados sem tokens/instâncias e avisa o usuário.

---

## 6. Registrar em history/

Crie `history/YYYY-MM-DD_design-setup.md`:

```markdown
# [DESIGN SETUP] Design System criado no Figma
Data: YYYY-MM-DD
Agente: designer

## Fontes utilizadas
- [lista de prints/protótipos/descrições fornecidas]

## Tokens extraídos
- Cores: [N cores nomeadas]
- Tipografia: [N estilos]
- Componentes: [lista de componentes documentados]

## Figma
- Arquivo: ${FIGMA_FILE_KEY}
- Página de guidelines: [URL do node]

## Publicado para o fluxo B
- Variáveis: [N variáveis] → figma-variables-map.json
- Componentes: [N componentes] → figma-components-map.json (ou "não nesta rodada")

## .env atualizado
- FIGMA_FILE_KEY
- FIGMA_GUIDELINES_NODE_ID
- FIGMA_VARIABLES_MAP
- FIGMA_COMPONENTS_MAP
```

---

## 7. Quando re-executar

Execute este fluxo novamente quando:
- O design system evoluir significativamente (novos componentes, rebrand de cores)
- O usuário pedir para atualizar os guidelines
- Após a primeira versão, para refinar com base em feedback

Ao re-executar, atualize a página existente no Figma (não crie duplicata) e atualize o `FIGMA_GUIDELINES_NODE_ID` se o node mudar.
