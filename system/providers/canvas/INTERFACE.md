# Provider: canvas — interface

Ponte com a ferramenta de canvas/design (hoje: Figma via MCP). Duas direções:

| Operação | Direção | Implementação |
|---|---|---|
| ler node (árvore de design → código) | canvas → código | `figma-mcp.md` |
| screenshot de node (referência visual) | canvas → código | `figma-mcp.md` |
| ler node que estoura o limite de token | canvas → código | subagente `figma-node-reader` (skill própria — mantém o dump fora do contexto principal) |
| inserir tela renderizada no arquivo | código → canvas | skill `html-to-figma` (motor de captura DOM) |

Futuras implementações: Canvas nativo do Hub via MCP — mesma interface.

## Gate e escrita

- Leitura de node exige `fileKey` + `nodeId` **informados pelo usuário** (link ou id cru).
  Nunca invente nem chute nodeId.
- **Inserir no canvas é escrita externa** → write-gate + **opt-in**: só sob pedido
  explícito do usuário, só as telas que ele escolher. A fonte de verdade do design é o
  código do protótipo; o canvas é referência de entrada e destino de export.
- Sem canvas configurado/na ausência de node: imagem medida e wireframe são referências
  válidas (ver `system/professions/product-designer/methods/reference-authority.md`) — nunca
  recuse por falta de Figma.
