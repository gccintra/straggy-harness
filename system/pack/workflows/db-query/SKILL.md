---
name: db-query
description: >
  Executa consultas SQL no banco de dados de homologação do projeto usando o cliente CLI
  configurado no .env (sqlcmd, psql, mysql, sqlite3 ou qualquer outro). Suporta qualquer
  autenticação — senha, Windows/NTLM, Kerberos, .pgpass — sem depender de MCP. Use sempre
  que precisar consultar dados reais do banco: estrutura de tabelas, valores de registros,
  contagens, inconsistências entre o comportamento esperado e o estado atual dos dados.
acao:
  id: consultar-dados
  rotulo: Consultar dados
  descricao: consulta o banco de homologação do projeto
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
