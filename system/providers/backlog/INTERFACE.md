# Provider: backlog — interface

Operações abstratas de gestão de demandas. Workflows (L2) referenciam **estas operações**,
nunca a ferramenta: nada de comando, endpoint ou variável de fornecedor em workflow.

## Seleção da implementação

`BACKLOG_PROVIDER` no `.env` decide quem atende: `github` · `gitlab` · `linear` · `none`
(`jira`, `azure`: quando as implementações existirem).

O backlog é **sempre** de uma ferramenta externa. O produto não tem backlog próprio — é
decisão de escopo, não pendência (`docs/discovery/18-moscow.md`, "Recusa de escopo").

- Não definido → **compatibilidade**: `GITLAB_ENABLED=true` equivale a
  `BACKLOG_PROVIDER=gitlab`; qualquer outro valor equivale a `none`.
- Implementações do sistema: **`github-gh.md`** (`gh` CLI) · **`gitlab-glab.md`** (`glab`
  CLI) · **`linear-mcp.md`** (servidor MCP do Linear). Receitas de export em lote em
  `recipes/`, uma por implementação; o cálculo que roda sobre o CSV é agnóstico de
  ferramenta (`recipes/analise-funil.md`, `recipes/burndown-local.md`) e não se duplica por
  provider.
- Implementação própria da organização: `org/providers/backlog/<nome>.md`, sob esta mesma
  interface (`docs/ARCHITECTURE.md` §3).

## Operações

| Operação | Leitura/Escrita | Capacidade exigida |
|---|---|---|
| listar demandas (filtro: estado, label, sprint, autor, busca) | L | `core` |
| ver demanda (com comentários) | L | `core` |
| exportar demandas em lote (uma chamada paginada → arquivo local) | L | `bulk-export` |
| criar demanda (título, descrição, labels, sprint) | **E** | `core` |
| atualizar demanda (descrição, labels, sprint, responsável) | **E** | `core` |
| comentar demanda | **E** | `comments` |
| fechar/reabrir demanda | **E** | `core` |
| atualizar bloco estruturado dentro da descrição | **E** | `description-block` |
| listar sprint, mover demanda entre sprints, documentar sprint | L / **E** | `sprints` |
| criar/editar/fechar sprint | **E** | `sprints-write` |
| listar/criar labels | L / **E** | `labels` |
| listar/criar/atualizar página de wiki | L / **E** | `wiki` |

**Toda operação de Escrita passa pelo write-gate** (`system/CONSTITUTION.md` §2): mostrar o
conteúdo/alvo, esperar aprovação. Sem exceção, por operação.

## Capacidades

Cada implementação declara, no frontmatter do seu arquivo, quais capacidades suporta e de
que precisa para rodar (`docs/ARCHITECTURE.md` §4). O workflow declara a que exige. Capacidade ausente = **indisponibilidade explícita**, informada ao
usuário — nunca tentativa de comando que vai falhar, nunca contorno silencioso.

**Falha da ferramenta**: reporte o erro **verbatim**, aponte o passo de autenticação da
implementação ativa e ofereça repetir. Nunca contorne autenticação, nunca resuma o erro a
"deu problema".

| Capacidade | `github-gh` | `gitlab-glab` | `linear-mcp` |
|---|---|---|---|
| `core` · `comments` · `description-block` · `sprints` · `labels` · `bulk-export` | sim | sim | sim |
| `sprints-write` | sim (milestone) | sim (milestone) | **não** (ciclo é gerado pela cadência do time; a API não cria nem fecha) |
| `wiki` | **não** (wiki do GitHub é repo Git separado, sem API no `gh`) | sim | sim (documents) |

> "Este backlog (`<provider>`) não tem wiki. Publique o conteúdo noutro destino ou
> registre localmente."

Capacidade que falta a **uma operação** de um workflow que declara a capacidade mínima
(sprint-ops declara `sprints` e faz operações de `sprints-write`) segue a mesma regra: a
operação indisponível é informada e as outras seguem — nunca comando que vai falhar.

## Gate e modo degradado — definido AQUI, uma vez

Antes da primeira operação, resolva o provider ativo (`echo $BACKLOG_PROVIDER`, ou o
fallback de compatibilidade acima). Provider `none` (ou nenhum configurado) → o
comportamento depende do regime que o workflow declarou:

**Workflows SEM fallback local** (dependem do estado real do backlog: priorização,
análise, saúde, sprint-ops, wiki, criação de demanda) → **pare** e responda:

> "Nenhum backlog está configurado neste projeto (`BACKLOG_PROVIDER` no `.env`). Esta
> operação depende do backlog e não tem equivalente local. Para ativar, defina
> `BACKLOG_PROVIDER` e as credenciais da ferramenta escolhida."

Não contorne com dados de `{caminhos.entregaveis}`/`docs/context_docs/` — não substituem o estado real.

**Workflows COM fallback local** (usam a demanda só como contexto: discovery,
doc-consolidator, sprint-goal, design-brief, design-screen) → **modo local**:

- Entrada: pule leitura de demanda/comentários; peça a demanda por descrição livre do
  usuário ou busque `{caminhos.pasta_por_demanda}` e `{caminhos.historico}`.
- Detecção de estado: releia o registro local (`{caminhos.historico}`) em vez de comentários.
- Toda operação de Escrita é pulada — o registro local (`{caminhos.historico}`, `{caminhos.entregaveis}`) basta;
  nada se perde, só não é publicado.
- Avise uma vez: "Sem backlog configurado — registro fica só no repositório local."

Cada workflow L2 declara qual dos dois regimes usa; o texto acima não se repete lá.
