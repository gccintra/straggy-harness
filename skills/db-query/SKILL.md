---
name: db-query
description: >
  Executa consultas SQL no banco de dados de homologação do projeto usando o cliente
  CLI configurado no .env (sqlcmd, psql, mysql, sqlite3 ou qualquer outro). Suporta
  qualquer mecanismo de autenticação — senha, Windows/NTLM, Kerberos, .pgpass — sem
  depender de MCP. Use esta skill sempre que precisar consultar dados reais do banco:
  estrutura de tabelas, valores de registros, contagens, inconsistências entre o
  comportamento esperado e o estado atual dos dados.
---

# db-query

Executa consultas SQL no banco de homologação via CLI, usando o comando configurado no `.env`. Funciona com qualquer banco e qualquer autenticação — a skill não impõe nenhum protocolo específico.

**Esta skill é opcional.** Se `DB_ENABLED` não estiver `true` no `.env`, informe ao usuário que o banco não está configurado e responda apenas com base em `docs/context_docs/`.

---

## 1. Verificar disponibilidade

Antes de qualquer consulta, verifique se o banco está habilitado:

```bash
# DB_ENABLED deve ser "true" (string)
echo $DB_ENABLED
```

Se `DB_ENABLED` não for `true`:
> "O banco de dados de homologação não está configurado neste projeto. Para ativá-lo, preencha `DB_ENABLED=true` e `DB_CONNECT_CMD` no `.env`. Responderei com base na documentação em `docs/context_docs/`."

Se `DB_ENABLED=true` mas `DB_CONNECT_CMD` estiver vazio:
> "DB_ENABLED está ativo mas DB_CONNECT_CMD não foi configurado. Adicione o comando de conexão ao `.env`."

---

## 2. Como executar uma consulta

O mecanismo é simples: substitua `$DB_QUERY` no `DB_CONNECT_CMD` pela query SQL e execute via bash.

```bash
# A variável DB_QUERY contém a query a executar
DB_QUERY="SELECT TOP 5 * FROM inscricoes ORDER BY created_at DESC"

# Avalie DB_CONNECT_CMD com DB_QUERY substituído
eval "$DB_CONNECT_CMD"
```

O `eval` expande `$DB_QUERY` dentro de `DB_CONNECT_CMD`. O agente monta a query, substitui e executa — sem precisar saber qual cliente ou autenticação está sendo usada.

### Exemplos de como fica na prática

**SQL Server + NTLM** (configuração ITL):
```bash
# .env: DB_CONNECT_CMD=sqlcmd -S Hom-052-db -U "SESTSENAT\Gustavo.websis" -C -Q "$DB_QUERY"
DB_QUERY="SELECT TOP 10 id, status, candidato_id FROM inscricoes"
eval "$DB_CONNECT_CMD"
# Executa: sqlcmd -S Hom-052-db -U "SESTSENAT\Gustavo.websis" -C -Q "SELECT TOP 10 ..."
```

**PostgreSQL com senha**:
```bash
# .env: DB_CONNECT_CMD=psql "postgresql://user:pass@host:5432/dbname" -c "$DB_QUERY"
DB_QUERY="SELECT id, status FROM inscricoes LIMIT 10"
eval "$DB_CONNECT_CMD"
```

**MySQL**:
```bash
# .env: DB_CONNECT_CMD=mysql -h host -u user -pmypassword dbname -e "$DB_QUERY"
DB_QUERY="SELECT id, status FROM inscricoes LIMIT 10"
eval "$DB_CONNECT_CMD"
```

---

## 3. Queries úteis por tipo de pergunta

### Estrutura de uma tabela

**SQL Server:**
```sql
SELECT
  COLUMN_NAME,
  DATA_TYPE,
  CHARACTER_MAXIMUM_LENGTH,
  IS_NULLABLE,
  COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'nome_da_tabela'
ORDER BY ORDINAL_POSITION
```

**PostgreSQL:**
```sql
SELECT column_name, data_type, character_maximum_length, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'nome_da_tabela'
ORDER BY ordinal_position
```

**MySQL:**
```sql
DESCRIBE nome_da_tabela
```

### Listar todas as tabelas

**SQL Server:**
```sql
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME
```

**PostgreSQL / MySQL:**
```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name
```

### Amostra de dados

```sql
-- SQL Server
SELECT TOP 10 * FROM nome_da_tabela ORDER BY id DESC

-- PostgreSQL / MySQL
SELECT * FROM nome_da_tabela ORDER BY id DESC LIMIT 10
```

### Contagem e distribuição

```sql
-- Contagem por status
SELECT status, COUNT(*) as total
FROM inscricoes
GROUP BY status
ORDER BY total DESC

-- Registro específico
SELECT * FROM inscricoes WHERE candidato_id = 12345
```

---

## 4. Boas práticas

**Sempre use LIMIT / TOP nas consultas exploratórias** — nunca faça `SELECT *` sem limite em tabelas de produção/homologação que podem ter milhões de registros.

**Prefira consultas de leitura** (`SELECT`, `SHOW`, `DESCRIBE`). Esta skill nunca deve executar `INSERT`, `UPDATE`, `DELETE` ou `DROP` — é somente leitura.

**Se o comando falhar**, reporte o erro exato ao usuário. Causas comuns:
- Cliente não instalado (`sqlcmd not found` → instalar SQL Server tools)
- Autenticação falhou → verificar credenciais no `.env`
- Host inacessível → verificar VPN ou rede

**Nunca exponha `DB_CONNECT_CMD` completo** nas respostas ao usuário — pode conter senha em texto plano dependendo da configuração.

---

## 5. Tratar o resultado

O output do CLI é texto. Formate-o para o usuário:

- Para estrutura de tabela: apresente como tabela Markdown com colunas `Campo | Tipo | Nulo | Padrão`
- Para listagens de registros: apresente as primeiras N linhas como tabela Markdown
- Para contagens: apresente como números diretos com contexto
- Se o resultado for vazio: diga explicitamente "Nenhum registro encontrado" — não assuma que é erro

---

## 6. Quando o banco diverge da documentação

Se o estado real do banco divergir do comportamento esperado pela documentação (`docs/context_docs/`), aponte explicitamente:

> "Conforme o ONEPAGE.md, o status esperado seria X. No banco, o registro está como Y. Isso pode indicar um bug, uma migração pendente ou uma regra não documentada."

Essa divergência é informação valiosa — registre em `history/` quando for relevante.
