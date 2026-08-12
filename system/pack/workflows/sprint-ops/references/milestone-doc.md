# Template de documentação de sprint — contrato de formato (padrão do pack)

Formato default. A organização que precisa de outro **sobrescreve este arquivo** em
`org/workflows/sprint-ops/references/milestone-doc.md` — o resto do workflow continua vindo
do pack (`docs/ARCHITECTURE.md` §3).

```
**Meta da Sprint**

* [Sprint Goal — uma frase de outcome, não lista de entregas]

**Prazos**

DD/MM/YYYY - DD/MM/YYYY

## Escopo da Sprint

**Concluídos:**

#NNN

**Não Concluídos:**

#NNN
```

### Regras de preenchimento

| Campo | Regra |
|---|---|
| **Meta da Sprint** | Uma frase de outcome (`methods/sprint-goal.md`). Nunca lista de entregas. |
| **Prazos** | Data de início e fim, no formato de data da organização (`org/ORG.md`). |
| **Concluídos** | Demandas fechadas — só a referência (`#NNN`), uma por linha. |
| **Não Concluídos** | Demandas ainda abertas, mesmo formato. Seção nunca é omitida, mesmo vazia. |

**Proibições:** sem título, descrição, responsável ou status junto da referência da
demanda — a sprint documenta escopo, não replica o backlog. Seção que a organização não
usa some do template dela, não fica vazia com texto de preenchimento.
