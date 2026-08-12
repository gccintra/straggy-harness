# Provider: backlog — interface

Operações abstratas de gestão de demandas. Workflows (L2) referenciam **estas operações**,
nunca a ferramenta: nada de comando, endpoint ou variável de fornecedor em workflow.

## Seleção da implementação

`BACKLOG_PROVIDER` no `.env` decide quem atende: `github` · `gitlab` · `none`
(`jira`, `hub`: quando as implementações existirem).

- Não definido → **compatibilidade**: `GITLAB_ENABLED=true` equivale a
  `BACKLOG_PROVIDER=gitlab`; qualquer outro valor equivale a `none`.
- Implementações do sistema: **`github-gh.md`** (`gh` CLI) · **`gitlab-glab.md`** (`glab`
  CLI, com receitas de export em lote em `recipes/`).
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
| listar/criar/editar/fechar sprint | L / **E** | `sprints` |
| listar/criar labels | L / **E** | `labels` |
| listar/criar/atualizar página de wiki | L / **E** | `wiki` |

**Toda operação de Escrita passa pelo write-gate** (`system/CONSTITUTION.md` §2): mostrar o
conteúdo/alvo, esperar aprovação. Sem exceção, por operação.

## Capacidades

Cada implementação declara, no topo do seu arquivo, quais capacidades suporta. O workflow
declara a que exige. Capacidade ausente = **indisponibilidade explícita**, informada ao
usuário — nunca tentativa de comando que vai falhar, nunca contorno silencioso.

| Capacidade | `github-gh` | `gitlab-glab` |
|---|---|---|
| `core` · `comments` · `description-block` · `sprints` · `labels` · `bulk-export` | sim | sim |
| `wiki` | **não** (wiki do GitHub é repo Git separado, sem API no `gh`) | sim |

> "Este backlog (`<provider>`) não tem wiki. Publique o conteúdo noutro destino ou
> registre localmente."

## Gate e modo degradado — definido AQUI, uma vez

Antes da primeira operação, resolva o provider ativo (`echo $BACKLOG_PROVIDER`, ou o
fallback de compatibilidade acima). Provider `none` (ou nenhum configurado) → o
comportamento depende do regime que o workflow declarou:

**Workflows SEM fallback local** (dependem do estado real do backlog: priorização,
análise, saúde, sprint-ops, wiki, criação de demanda) → **pare** e responda:

> "Nenhum backlog está configurado neste projeto (`BACKLOG_PROVIDER` no `.env`). Esta
> operação depende do backlog e não tem equivalente local. Para ativar, defina
> `BACKLOG_PROVIDER` e as credenciais da ferramenta escolhida."

Não contorne com dados de `outputs/`/`docs/context_docs/` — não substituem o estado real.

**Workflows COM fallback local** (usam a demanda só como contexto: discovery,
doc-consolidator, sprint-goal, design-brief, design-screen) → **modo local**:

- Entrada: pule leitura de demanda/comentários; peça a demanda por descrição livre do
  usuário ou busque `outputs/{ID}_*/` e `history/`.
- Detecção de estado: releia o registro local (`history/`) em vez de comentários.
- Toda operação de Escrita é pulada — o registro local (`history/`, `outputs/`) basta;
  nada se perde, só não é publicado.
- Avise uma vez: "Sem backlog configurado — registro fica só no repositório local."

Cada workflow L2 declara qual dos dois regimes usa; o texto acima não se repete lá.
