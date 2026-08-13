# Procedimento padrão — registrar demanda (pack)

Passo a passo default da ação `registrar-demanda`. A organização sobrescreve este arquivo em
`org/workflows/backlog-issue-creator/references/procedimento.md`.

## Uma demanda, um problema

Pedido que carrega três problemas vira três demandas. Empacotar é o que torna a fila
impossível de ordenar: a demanda não pode ser aceita nem descartada por inteiro.

## O que a demanda precisa ter para ser trabalhável

- **Quem sentiu** — perfil ou área, não "os usuários".
- **O que acontece hoje** e o efeito no trabalho de quem sentiu.
- **Como se sabe que resolveu** — o resultado observável.
- **Classificação de entrada**: tipo e criticidade. Valor, esforço e sprint são de outra
  etapa e ficam vazios.

Falta o efeito → é o único buraco que vale interromper o registro: sem ele não há como
comparar esta demanda com nenhuma outra.

## Título

O título nomeia o problema, não a tela nem a solução imaginada. Título que descreve
mecanismo trava a demanda na primeira solução que alguém pensou.

## Refino

Refino acrescenta ao que já está escrito. Informação que ficou falsa é corrigida com o
registro do que mudou; texto apenas incompleto não é reescrito por inteiro.
