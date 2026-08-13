# Procedimento padrão — auditar backlog (pack)

Passo a passo default da ação `auditar-backlog`. A organização sobrescreve este arquivo em
`org/workflows/backlog-health/references/procedimento.md`.

## O que conta como demanda malformada

| Sintoma | Por que é defeito |
|---|---|
| Não dá para retomar | quem não escreveu a demanda não consegue dizer qual é o problema nem o que resolveria |
| Sem classificação | falta o que a fila usa para ordenar: tipo e criticidade |
| Sem dono da decisão | ninguém responde por ela quando chegar a vez |
| Parada | aberta há muito tempo, sem nenhuma movimentação |
| Repetida | outra demanda já descreve o mesmo problema |
| Defeito sem reprodução | não há como confirmar se ainda acontece |

Uma demanda pode ter vários sintomas — aparece em cada grupo.

## Encaminhamento por grupo

Grupo detectado sem encaminhamento proposto é inventário, não auditoria. Para cada grupo, o
relatório diz qual destino cabe: completar, reclassificar, fundir com a demanda que já
existe, ou encerrar.

Demanda parada nem sempre é lixo — pode estar esperando algo externo. O sintoma é o mesmo, o
destino não.
