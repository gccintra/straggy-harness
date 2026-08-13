---
capacidades: [node-read, screenshot, design-write]
requisitos:
  variaveis: [FIGMA_FILE_KEY]
  servicos: [figma-mcp]
---

# Provider: canvas — leitura Figma via MCP

Mecânica de leitura de nodes do Figma. Procedural por natureza — sintaxe de ferramenta.

## Identificar node

Aceite **link** (`figma.com/design/:fileKey/:nome?node-id=1-2`) ou **nodeId cru**
(`1:2`/`1-2`). Extraia `fileKey` e `nodeId`. `FIGMA_FILE_KEY` do `.env` é o default para
export; link do usuário sobrepõe.

## Ler

```
get_design_context(fileKey, nodeId)     # árvore + código React/Tailwind com valores absolutos
get_screenshot(fileKey, nodeId)         # pixels de referência
```

Orçamento de node: ≤150 nodes cabe; 150–400 normalmente cabe; >400 desça um nível e peça
por filho. Tela inteira (~1400 nodes, ~80k chars) **sempre estoura** → delegue ao
subagente `figma-node-reader`. **Nunca** `get_metadata` na página inteira (`0:1`) — 234k
chars.

Quando estoura, o erro salva o conteúdo em arquivo — o caminho vem no erro; parse com
python3 por filho, nunca repita a chamada da tela inteira.

## Converter o retorno para o padrão do protótipo

`get_design_context` devolve React + Tailwind com valores absolutos e ruído de captura:

| Vem do Figma | Vira |
|---|---|
| `bg-[#003770]` (hex cru) | classe de **token** do design system (precedência: `system/professions/product-designer/methods/design-system-first.md`) |
| wrapper duplo (`bg-clip-padding border-0 border-[transparent]`) | achatar em 1 elemento |
| `absolute left-[528px] top-0` | flex/grid |
| componente que já existe no design system | o componente existente, não recriação inline |
| `<img src="figma.com/api/mcp/asset/...">` | ícone `lucide-react` — **a URL do asset expira em 7 dias**, nunca propague |
| `font-['Roboto:Medium']` | classe de fonte do config + peso |
| `data-name="X"` | `aria-label="X"` (nomeia o node na volta pro Figma) |
| `whitespace-nowrap`, `fontVariationSettings`, `shrink-0` sem efeito | descartar (artefato de captura) |

Valor de design vs valor medido: `reference-authority.md` (método do designer).
