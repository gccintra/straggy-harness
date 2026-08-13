# Procedimento padrão — documentar requisito (pack)

Passo a passo default da ação `documentar-requisito`. A organização sobrescreve este arquivo
em `org/workflows/doc-consolidator/references/procedimento.md`.

## De onde vem cada parte

| Parte do documento | Fonte |
|---|---|
| Problema e objetivo | a definição de problema fechada no discovery |
| Escopo e fora de escopo | a solução escolhida no discovery |
| Comportamento de tela, rótulo e texto de mensagem | o protótipo já validado da demanda |
| Regra e cálculo | o discovery, mais o que o sistema já faz na área |
| Identificação e metadados | a configuração do projeto |

## Checagem antes de entregar

- Todo critério é verificável por quem não participou da conversa.
- Toda regra citada por um critério existe, e nenhuma regra aparece escrita duas vezes.
- Toda mensagem traz o texto literal, não a descrição da mensagem.
- Todo item que veio de suposição está marcado como suposição.
- O documento se sustenta sozinho: quem lê só ele consegue construir e testar a demanda.

## Reúso

Comportamento que vale para o produto inteiro, e não só para esta demanda, é referenciado de
onde já está documentado em vez de recopiado. Não existindo esse lugar, nasce dentro da
demanda e o documento aponta que ele é candidato a virar referência compartilhada.
