# Template de documentação de milestone — contrato de formato

A descrição de uma milestone segue **exatamente** este template, derivado das sprints recentes do projeto (Sprint 45–50):

```
**Meta da Sprint**

* [Sprint Goal — uma frase de outcome, não lista de entregas]

**Prazos**

DD/MM/YYYY - DD/MM/YYYY

## Escopo da Sprint

**Concluídos:**

#NNN+

#NNN+

**Não Concluídos:**

#NNN+

#NNN+
```

### Regras de preenchimento

| Campo | Regra |
|---|---|
| **Meta da Sprint** | `**Meta da Sprint**` em bold (não heading `##`). Uma linha em branco depois, depois `* [goal]`. |
| **Prazos** | `**Prazos**` em bold (não heading). Uma linha em branco depois, depois `DD/MM/YYYY - DD/MM/YYYY` (sem bullet). |
| **Escopo da Sprint** | `## Escopo da Sprint` como heading `##` (não bold). |
| **Concluídos** | Issues com `state: closed`. Formato: **somente `#NNN+`** — apenas o número da issue seguido de `+`. Sem título, sem OS, sem descrição, sem responsável, sem status, sem bullet, sem travessão. Uma issue por linha, **linha em branco entre cada issue**. |
| **Não Concluídos** | Issues com `state: opened`. Mesmo formato: **somente `#NNN+`**. Nenhuma informação adicional. |

**Proibições absolutas no Escopo da Sprint:**
- ❌ Nunca incluir o título da issue (`OS2026XXX | HU...`)
- ❌ Nunca incluir descrição, resumo ou bullets sobre o que a issue faz
- ❌ Nunca incluir responsável, assignee ou status da issue
- ❌ Nunca usar `* #NNN+` (bullet) nem `- #NNN+` (travessão) — só `#NNN+` puro
- ❌ Nunca omitir `**Não Concluídos:**` mesmo que a seção esteja vazia
- ❌ Não incluir `## Cerimônias` — abandonado no projeto a partir da Sprint 45

---

