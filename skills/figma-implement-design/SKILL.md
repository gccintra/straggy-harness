---
name: "figma-implement-design"
description: "Translate Figma nodes into production-ready code with 1:1 visual fidelity using the Figma MCP workflow (design context, screenshots, assets, and project-convention translation). Trigger when the user provides Figma URLs or node IDs, or asks to implement designs or components that must match Figma specs. Requires a working Figma MCP server connection."
---

# Skill: figma-implement-design

## Visão Geral

Esta skill define o fluxo obrigatório para traduzir designs do Figma em código de produção com fidelidade visual 1:1.
O fluxo é: **URL Figma → design context + screenshot → assets → código no padrão do projeto → validação visual**.

> **Skill inversa:** `html-to-figma` faz o caminho contrário (código/HTML → Figma).

---

## Pré-requisitos

- Figma MCP server conectado (`.opencode/opencode.json` no OpenCode,
  `.codex/config.toml` no Codex ou `.mcp.json` no Claude Code)
- URL Figma no formato: `https://figma.com/design/:fileKey/:fileName?node-id=1-2`
- `PROJECT_CONTEXT.md` lido antes de qualquer implementação

### Verificar se o MCP Figma está ativo

Se qualquer chamada `figma_*` falhar com erro de autenticação:

1. Verificar a configuração do cliente:
   - OpenCode: `.opencode/opencode.json`, bloco `mcp.figma` habilitado
   - Codex: `.codex/config.toml`, bloco `mcp_servers.figma` habilitado
   - Claude Code: `.mcp.json`, bloco `mcpServers.figma` presente
2. Fazer o login OAuth no cliente ativo:
   - OpenCode: executar `/connect` e selecionar `figma`
   - Codex: executar `codex mcp login figma`
   - Claude Code: executar `/mcp`, selecionar `figma` e autenticar
3. Após o login, iniciar uma nova sessão no cliente ativo.

---

## Fluxo Obrigatório (seguir em ordem, não pular etapas)

### Etapa 0: Ler o Contexto do Projeto

**OBRIGATÓRIO antes de qualquer implementação.**

```
read("PROJECT_CONTEXT.md")
```

Extrair e absorver:
- Stack de frontend (framework, CSS solution, component library)
- Design system existente (tokens de cor, tipografia, espaçamento)
- Convenções de nomenclatura de componentes e arquivos
- Padrões de state management e data-fetch
- Diretório de componentes UI

Nenhum código gerado pode contradizer `PROJECT_CONTEXT.md`.

---

### Etapa 1: Obter fileKey e nodeId

#### Opção A — A partir de URL Figma

Formato: `https://figma.com/design/:fileKey/:fileName?node-id=X-Y`

- **fileKey:** segmento após `/design/` (ex: `ubx8p2dAGtO3cmhfUEJkCu`)
- **nodeId:** valor do parâmetro `node-id`, com `-` ou `:` como separador (ex: `28:2` ou `28-2`)

Exemplo:
```
URL:     https://figma.com/design/ubx8p2dAGtO3cmhfUEJkCu/ProductOps?node-id=28-2
fileKey: ubx8p2dAGtO3cmhfUEJkCu
nodeId:  28:2
```

#### Opção B — Seleção no Figma Desktop (MCP `figma-desktop` apenas)

Quando usando o MCP local `figma-desktop`, o arquivo aberto no app Figma é usado automaticamente. Apenas `nodeId` é necessário — `fileKey` não é passado.

---

### Etapa 2: Buscar Design Context

```
get_design_context(fileKey="<fileKey>", nodeId="<nodeId>")
```

Retorna:
- Propriedades de layout (Auto Layout, constraints, sizing)
- Especificações tipográficas (font family, size, weight, line-height)
- Valores de cor e design tokens
- Estrutura de componentes e variantes
- Valores de spacing e padding

**Se a resposta for truncada ou muito grande:**

1. Usar `get_metadata` para obter o mapa de nós de alto nível:
   ```
   get_metadata(fileKey="<fileKey>", nodeId="<nodeId>")
   ```
2. Identificar os child nodes relevantes (seções principais, componentes-chave)
3. Buscar cada child individualmente:
   ```
   get_design_context(fileKey="<fileKey>", nodeId="<childNodeId>")
   ```

---

### Etapa 3: Capturar Screenshot de Referência

```
get_screenshot(fileKey="<fileKey>", nodeId="<nodeId>")
```

Este screenshot é a **fonte da verdade visual** — manter acessível durante toda a implementação para comparações.

Para designs complexos, capturar screenshots de seções individuais também.

---

### Etapa 4: Baixar Assets Necessários

O Figma MCP server serve assets (imagens, ícones, SVGs) via URLs `localhost`.

**Regras:**
- Se o MCP retornar uma URL `localhost` para um asset → usar diretamente, sem modificação
- **NÃO** instalar pacotes de ícones externos (ex: `lucide-react`, `heroicons`) — usar apenas os assets do payload Figma
- **NÃO** criar placeholders quando uma URL `localhost` estiver disponível
- Se o asset for um SVG inline, copiá-lo diretamente no código

**Se um asset `localhost` não estiver acessível:**
1. Verificar se o Figma MCP server está rodando
2. Tentar re-fetch via `get_design_context` — o MCP pode re-servir o asset
3. Se persistir, documentar o asset como pendente e usar um placeholder temporário com comentário `// TODO: substituir pelo asset Figma`

---

### Etapa 5: Traduzir para as Convenções do Projeto

**CRÍTICO:** O output do Figma MCP é tipicamente React + Tailwind. Tratar isso como *referência de design*, não como código final.

#### Checklist de adaptação

- [ ] Identificar o framework do projeto (React, Vue, HTML puro, etc.) via `PROJECT_CONTEXT.md`
- [ ] Substituir classes Tailwind pelas soluções CSS do projeto (CSS Modules, styled-components, CSS custom properties, etc.)
- [ ] Verificar se componentes equivalentes já existem no projeto → reutilizar, não duplicar
- [ ] Mapear cores Figma → tokens do projeto (ex: `#0d0d0d` → `var(--color-primary)`)
- [ ] Mapear tipografia Figma → escala tipográfica do projeto
- [ ] Mapear espaçamentos Figma → tokens de spacing do projeto
- [ ] Respeitar padrões de routing, state management e data-fetch existentes
- [ ] Seguir convenções de nomenclatura de arquivos e componentes do projeto

#### Usar a skill `frontend-design` em conjunto

Para garantir qualidade estética e acessibilidade no código gerado, aplicar os princípios da skill `frontend-design`:
- CSS custom properties para design tokens
- Auto layout via flexbox/grid (sem `position: absolute` para layout)
- Todos os estados interativos (hover, focus, disabled, loading, error)
- Acessibilidade WCAG AA (contraste, labels, focus visible, aria)

---

### Etapa 6: Alcançar Paridade Visual 1:1

Objetivo: código renderizado = screenshot do Figma.

**Diretrizes:**
- Priorizar fidelidade ao Figma para spacing, sizing e tipografia exatos
- Evitar valores hardcoded — extrair para tokens sempre que possível
- Quando tokens do projeto divergirem dos valores Figma, preferir os tokens do projeto mas ajustar minimamente para manter a aparência visual
- Implementar todos os estados dos componentes (default, hover, focus, active, disabled, error)
- Garantir que a responsividade siga os constraints definidos no Figma

**Validação incremental:** comparar contra o screenshot a cada seção concluída, não apenas no final.

---

### Etapa 7: Validar Contra o Figma

Antes de marcar a task como concluída:

- [ ] Layout corresponde (spacing, alinhamento, sizing)
- [ ] Tipografia corresponde (fonte, tamanho, peso, line-height, letter-spacing)
- [ ] Cores correspondem exatamente (usando tokens do projeto)
- [ ] Estados interativos funcionam (hover, active, disabled)
- [ ] Comportamento responsivo segue os constraints do Figma
- [ ] Assets renderizam corretamente
- [ ] Padrões de acessibilidade WCAG AA atendidos
- [ ] Código segue as convenções do `PROJECT_CONTEXT.md`

---

## Regras de Implementação

### Organização de Componentes

- Colocar componentes UI no diretório definido em `PROJECT_CONTEXT.md`
- Seguir convenções de nomenclatura do projeto
- Evitar estilos inline exceto para valores verdadeiramente dinâmicos

### Integração com Design System

- SEMPRE verificar se um componente equivalente já existe antes de criar um novo
- Mapear design tokens Figma → tokens do projeto
- Quando um componente existente atende parcialmente → estender, não duplicar
- Documentar novos componentes adicionados ao design system

### Qualidade de Código

- Sem valores hardcoded — extrair para tokens ou constantes
- Componentes composáveis e reutilizáveis
- TypeScript types para props (se o projeto usa TypeScript)
- Comentários JSDoc em componentes exportados

---

## Integração com o Pipeline

Após a implementação:

1. Se existir um registro de tarefa do cliente ativo, marcar os checkboxes concluídos e listar os
   arquivos criados/modificados. Não criar um arquivo de tarefa apenas para cumprir esta etapa.
2. Criar ou atualizar diretamente os testes dos componentes implementados, sem abrir subagentes.
3. Fazer diretamente a verificação de segurança (XSS em inputs e sanitização de dados dinâmicos).
4. Validar implementação, testes e segurança antes do handoff.

---

## Exemplos

### Exemplo 1: Implementar um botão

Usuário: `"Implementar este botão: https://figma.com/design/abc123/DS?node-id=42-15"`

```
1. Ler PROJECT_CONTEXT.md → projeto usa React + CSS Modules
2. get_design_context(fileKey="abc123", nodeId="42:15")
3. get_screenshot(fileKey="abc123", nodeId="42:15")
4. Verificar assets: nenhum ícone necessário
5. Verificar se Button component existe em src/components/Button/
6. Se existe: adicionar nova variante; se não: criar novo componente
7. Mapear cores Figma → tokens CSS do projeto
8. Validar padding, border-radius, tipografia contra screenshot
```

### Exemplo 2: Implementar dashboard completo

Usuário: `"Implementar: https://figma.com/design/abc123/DS?node-id=10-5"`

```
1. Ler PROJECT_CONTEXT.md → projeto usa Next.js + styled-components
2. get_metadata(fileKey="abc123", nodeId="10:5") → mapear estrutura
3. Identificar seções: Header (10:6), Sidebar (10:7), Cards (10:8, 10:9)
4. get_design_context para cada seção individualmente
5. get_screenshot(fileKey="abc123", nodeId="10:5") → referência geral
6. Baixar assets (logo, ícones de sidebar, chart placeholder)
7. Construir layout com primitivos de layout do projeto
8. Implementar cada seção reutilizando componentes existentes
9. Validar responsividade contra constraints do Figma
```

---

## Problemas Comuns e Soluções

### Resposta do `get_design_context` truncada
**Causa:** Design muito complexo ou com muitos layers aninhados.
**Solução:** Usar `get_metadata` para obter a estrutura, depois buscar child nodes individuais.

### Discrepância visual após implementação
**Causa:** Divergências em spacing, cores ou tipografia entre código e design.
**Solução:** Comparar lado a lado com o screenshot da Etapa 3. Verificar valores exatos no design context retornado.

### Assets `localhost` inacessíveis
**Causa:** Figma MCP server não está servindo os assets corretamente.
**Solução:** Verificar se o MCP está rodando. Tentar re-fetch. Se persistir, usar placeholder com `// TODO` e documentar.

### Tokens do projeto divergem do Figma
**Causa:** O design system do código evoluiu separado do Figma.
**Solução:** Preferir tokens do projeto para consistência, ajustar spacing/sizing minimamente para manter aparência visual. Documentar divergência em comentário.

### Stack do projeto não é React + Tailwind
**Causa:** O output do Figma MCP assume React + Tailwind por padrão.
**Solução:** Tratar o output como referência de estrutura e valores — traduzir para o framework real do projeto conforme `PROJECT_CONTEXT.md`.

---

## Output Format

Ao concluir a implementação:

```
## figma-implement-design: Concluído

### Node implementado
- URL: <figma url>
- fileKey: <key>
- nodeId: <id>

### Arquivos criados/modificados
| Arquivo | Ação | Descrição |
|---------|------|-----------|
| src/... | CREATE/MODIFY | ... |

### Mapeamento de tokens
| Valor Figma | Token do projeto |
|-------------|-----------------|
| #0d0d0d     | var(--color-primary) |

### Assets utilizados
- <asset 1>: <fonte>
- <asset 2>: <fonte>

### Checklist de validação
- [x] Layout corresponde ao screenshot
- [x] Tipografia corresponde
- [x] Cores mapeadas para tokens do projeto
- [x] Estados interativos implementados
- [x] Acessibilidade WCAG AA
- [x] Convenções do PROJECT_CONTEXT.md seguidas
```
