---
name: backlog-query
description: >
  Consulta e operação pontual no backlog do projeto — ver uma demanda, buscar por texto,
  listar por sprint/label/responsável, criar/atualizar/comentar/fechar uma demanda
  específica, listar labels e sprints. Use para qualquer pedido pontual de backlog: "vê a
  #NNN", "busca issues sobre X", "quais issues da sprint atual", "comenta na #NNN",
  "fecha a #NNN", "quais labels existem", e também quando o usuário citar a ferramenta
  direto (glab, GitLab, Jira). Para varredura do backlog inteiro use backlog-analysis,
  backlog-health ou backlog-prioritization.
---

# backlog-query — shim do provider (pack padrão)

Esta skill não tem procedimento próprio: ela resolve a ferramenta ativa e executa a
operação da interface. Leia, nesta ordem:

1. **`.agents/system/providers/backlog/INTERFACE.md`** — provider ativo
   (`BACKLOG_PROVIDER`), capacidades, gate e modo degradado. Valem para toda operação.
2. **A implementação ativa** (ex.: `.agents/system/providers/backlog/gitlab-glab.md`, ou a
   da organização em `org/providers/backlog/`) — sintaxe concreta dos comandos.

Toda operação de **escrita** (criar/atualizar/comentar/fechar) passa pelo write-gate —
`system/CONSTITUTION.md` §2: mostre o alvo e o conteúdo, espere aprovação.
