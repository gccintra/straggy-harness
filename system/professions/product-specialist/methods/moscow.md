# MoSCoW — triagem de criticidade

## Quando usar / quando não

- Use no **intake** (criação/refino de demanda) e na **convergência do problema** (D1b):
  responde "quão negociável é isto?" antes de qualquer número.
- Não use como ranking fino — MoSCoW ordena categorias, não itens dentro delas (isso é
  score, ver `ice.md`).

## Critérios

| Categoria | Critério |
|---|---|
| MUST | Inegociável. Sem isso a entrega/ciclo não faz sentido. |
| SHOULD | Importante, mas o produto sobrevive sem por um tempo. |
| COULD | Agrega valor marginal ("nice to have"). |
| WONT | Válido, mas fora de cogitação para este ciclo. |

## Barra de qualidade

- MoSCoW **sempre justificado** — a categoria sem o porquê é chute com rótulo.
- MoSCoW **precede** score numérico na ordenação: MUST com score baixo vem antes de SHOULD
  com score alto. Score desempata dentro da categoria.
- Criticidade real (sistema fora, perda de dado, fluxo core bloqueado, sem workaround)
  **bypassa a triagem**: é MUST direto, vai para execução imediata.
- MUST caindo em quadrante de descarte (ou SHOULD em DROP) é contradição — reavalie a
  categoria ou os scores, não ignore.

## Contrato de output

Categoria + justificativa de 1 frase. No intake, só MoSCoW — impacto/confiança/facilidade
vêm depois (discovery), porque facilidade é incalculável antes de existir solução.
