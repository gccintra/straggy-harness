# Provider: database — interface

Consulta **somente leitura** ao banco de homologação do projeto. Workflows referenciam a
operação "consultar dado real"; a implementação resolve cliente e autenticação.

Implementações: **`cli.md`** (qualquer cliente CLI via `DB_CONNECT_CMD` do `.env`).

## Operações

| Operação | Leitura/Escrita |
|---|---|
| estrutura de tabela / listar tabelas | L |
| amostra de dados / registro específico | L |
| contagem / distribuição | L |

**Escrita não existe nesta interface.** `INSERT`/`UPDATE`/`DELETE`/`DROP` são proibidos —
o provider é read-only por contrato.

## Gate e modo degradado

Antes da primeira consulta, verifique `DB_ENABLED` no `.env`:

- `DB_ENABLED` ≠ `true` → avise: "O banco de homologação não está configurado
  (`DB_ENABLED`/`DB_CONNECT_CMD` no `.env`). Respondo com base na documentação
  (`docs/context_docs/`)." Incógnita de dado num discovery vira suposição declarada
  (`[SUPOSIÇÃO: confirmar com dev]`) — não trava o fluxo.
- `DB_ENABLED=true` mas `DB_CONNECT_CMD` vazio → avise que falta o comando de conexão.

## Regras transversais (valem para qualquer implementação)

- Consulta exploratória **sempre limitada** (`TOP`/`LIMIT`) — nunca `SELECT *` sem limite.
- Nunca exponha `DB_CONNECT_CMD` completo na resposta — pode conter senha.
- Resultado vazio = "nenhum registro encontrado", não erro.
- Formate o output para o usuário (tabela Markdown), não despeje texto cru do cliente.
- Dado divergente da documentação → aponte explicitamente (é a informação mais valiosa).
