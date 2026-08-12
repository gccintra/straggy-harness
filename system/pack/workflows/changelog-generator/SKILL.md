---
name: changelog-generator
description: >
  Gera ou atualiza o changelog do projeto (histórico de evolução) a partir de documentação
  de requisito, demandas entregues ou descrição de funcionalidade. Use sempre que o usuário
  mencionar "changelog", "histórico de evolução", "adiciona ao changelog", "registra a
  mudança", "atualiza o histórico" ou enviar documentação pedindo para registrá-la. A saída
  é uma tabela Markdown no formato definido pela organização.
---

# changelog-generator — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` (write-gate: mostra a entrada antes de gravar/publicar) |
| Provider | `backlog/` só quando publicar na wiki (via `wiki-publish`); geração é local |
| Formatos | `references/formato.md` — colunas e regras da tabela (a organização sobrescreve) |

## Bindings padrão

- **Entrada**: documentação da demanda (`.md` consolidado, requisito, descrição). Faltou o dado
  de uma coluna → deixe o marcador de campo vazio; não invente valor.
- **Saída**: entrada nova no changelog do projeto, mais recente no topo.
- **Delta, não catálogo**: descreve o que mudou para o usuário, não a lista de arquivos ou
  tarefas técnicas.
- **Publicação** na wiki (quando pedida) → `wiki-publish`, em modo append.
