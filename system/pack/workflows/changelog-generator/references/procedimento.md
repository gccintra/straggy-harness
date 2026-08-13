# Procedimento padrão — manter changelog (pack)

Passo a passo default da ação `manter-changelog`. A organização sobrescreve este arquivo em
`org/workflows/changelog-generator/references/procedimento.md`.

## Quando uma mudança entra

Quando ela **chega a quem usa o produto** — a liberação, não o fim da implementação. Mudança
pronta e não liberada ainda não tem entrada.

## O que entra

- Uma entrada por mudança percebível por quem usa: comportamento novo, comportamento
  alterado, defeito corrigido, coisa removida.
- Mudança sem efeito visível (reestruturação interna, ambiente, dependência) não entra — o
  changelog é lido por quem usa, não por quem mantém.
- Demandas que só fazem sentido juntas viram uma entrada, com a referência de cada uma.

## De onde sai o texto

Da documentação aprovada da demanda, no vocabulário do produto: nome de tela, de campo e de
ação como aparecem para quem usa.

## Ordem e correção

Mais recente primeiro. Entrada já publicada não é reescrita para "ficar melhor" — conteúdo
que se provou falso vira entrada nova apontando a anterior.
