# Procedimento padrão — consultar dados (pack)

Passo a passo default da ação `consultar-dados`. A organização sobrescreve este arquivo em
`org/workflows/db-query/references/procedimento.md`.

## Uma pergunta por consulta

A consulta existe para responder a uma pergunta declarada antes de rodar. Consulta sem
pergunta produz tabela que ninguém sabe ler.

## O que acompanha o resultado

- A consulta que o produziu, literal.
- O recorte: quantas linhas voltaram, de que período, com que filtro.
- O ambiente em que rodou.

## Ambiente que não é produção

Dado de homologação ou de teste pode estar incompleto, antigo ou fabricado. Divergência
entre o dado e o comportamento esperado é **achado** — e o achado diz o que ainda precisa
ser confirmado para virar conclusão.

## Volume

Resposta útil cabe na tela. Pergunta que exigiria varrer a tabela inteira volta como
contagem, agrupamento ou amostra, com o critério da amostra dito.
