# Provider: database — implementação CLI genérica

Implementação da interface sobre qualquer cliente CLI (`sqlcmd`, `psql`, `mysql`,
`sqlite3`…) e qualquer autenticação (senha, NTLM, Kerberos, `.pgpass`) — sem MCP.
Gate `DB_ENABLED` e regras read-only: `INTERFACE.md`.

## 2. Como executar uma consulta

O mecanismo é simples: substitua `$DB_QUERY` no `DB_CONNECT_CMD` pela query SQL e execute via bash.

```bash
# A variável DB_QUERY contém a query a executar
DB_QUERY="SELECT TOP 5 * FROM registros ORDER BY created_at DESC"

# Avalie DB_CONNECT_CMD com DB_QUERY substituído
eval "$DB_CONNECT_CMD"
```

O `eval` expande `$DB_QUERY` dentro de `DB_CONNECT_CMD`. O agente monta a query, substitui e executa — sem precisar saber qual cliente ou autenticação está sendo usada.

### Exemplos de como fica na prática

**SQL Server + NTLM** (exemplo com domínio Windows):
```bash
# .env: DB_CONNECT_CMD=sqlcmd -S db-homologacao -U "DOMINIO\usuario" -C -Q "$DB_QUERY"
DB_QUERY="SELECT TOP 10 id, status, referencia_id FROM registros"
eval "$DB_CONNECT_CMD"
# Executa: sqlcmd -S db-homologacao -U "DOMINIO\usuario" -C -Q "SELECT TOP 10 ..."
```

**PostgreSQL com senha**:
```bash
# .env: DB_CONNECT_CMD=psql "postgresql://user:pass@host:5432/dbname" -c "$DB_QUERY"
DB_QUERY="SELECT id, status FROM registros LIMIT 10"
eval "$DB_CONNECT_CMD"
```

**MySQL**:
```bash
# .env: DB_CONNECT_CMD=mysql -h host -u user -pmypassword dbname -e "$DB_QUERY"
DB_QUERY="SELECT id, status FROM registros LIMIT 10"
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
FROM registros
GROUP BY status
ORDER BY total DESC

-- Registro específico
SELECT * FROM registros WHERE referencia_id = 12345
```

