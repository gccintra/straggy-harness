---
name: db-query
description: >
  Consulta SQL no banco de homologação pelo cliente do .env: tabelas, registros,
  contagens, "quantos X estão com status Y", dado real que diverge do esperado.
  Estado de issue é backlog-query.
acao:
  id: consultar-dados
  rotulo: Consultar dados
  descricao: consulta o banco de homologação do projeto
objetivo: Responder o que os dados realmente dizem, quando a documentação só diz o comportamento esperado.
entrega:
  - resultado da consulta na conversa, formatado conforme a INTERFACE do provider `database`
portoes:
  - somente leitura — nenhuma escrita no banco, sob nenhum pedido
  - gate `DB_ENABLED` — desligado, a ação não roda e diz por quê
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo: Como fazer
    ajuda: Cuidados que sua empresa exige ao consultar o banco — o que nunca rodar e como apresentar o resultado.
    tipo: texto-longo
---

# db-query — shim do provider

O conteúdo desta skill mudou de camada. Leia, nesta ordem:

1. **`.agents/system/providers/database/INTERFACE.md`** — gate `DB_ENABLED`, contrato
   **somente leitura**, limites (`TOP`/`LIMIT`), sigilo do `DB_CONNECT_CMD`, formatação
   do resultado.
2. **`.agents/system/providers/database/cli.md`** — mecânica de execução (`eval` com
   `$DB_QUERY`) e queries úteis por tipo de pergunta (estrutura, listagem, amostra,
   contagem) por dialeto.

Julgamento sobre quando consultar dado vs doc, e o que fazer com divergência:
`system/professions/tech-lead/reasoning.md`.

**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.
