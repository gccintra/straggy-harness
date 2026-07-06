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

---

## 5. Registrar no .env

Após criar a página de guidelines no Figma, adicione ao `.env` do projeto:

```bash
# Design System (Figma)
FIGMA_FILE_KEY=<fileKey do arquivo>
FIGMA_GUIDELINES_NODE_ID=<nodeId da página de guidelines criada>
```

O `FIGMA_GUIDELINES_NODE_ID` é o que o `@product-designer` usará como referência ao criar novas telas — ele copia os componentes desta página em vez de criá-los do zero.

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

## .env atualizado
- FIGMA_FILE_KEY
- FIGMA_GUIDELINES_NODE_ID
```

---

## 7. Quando re-executar

Execute este fluxo novamente quando:
- O design system evoluir significativamente (novos componentes, rebrand de cores)
- O usuário pedir para atualizar os guidelines
- Após a primeira versão, para refinar com base em feedback

Ao re-executar, atualize a página existente no Figma (não crie duplicata) e atualize o `FIGMA_GUIDELINES_NODE_ID` se o node mudar.
