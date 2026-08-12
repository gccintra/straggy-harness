# Estados de interface

## Quando usar / quando não

- Use em toda tela entregue — é checagem obrigatória, não etapa opcional.
- Não use como desculpa para desenhar dez variações antes de validar o fluxo principal.

## Barra de qualidade

- Estados cobertos: **vazio** (primeira vez e sem resultado, que são diferentes),
  **carregando**, **erro** (com o que fazer a seguir), **sem permissão**, **muito conteúdo**
  e **conteúdo longo** (nome que não cabe, lista de 500 itens).
- Estado vazio orienta a próxima ação; ilustração bonita sem caminho é decoração.
- Mensagem de erro diz o que aconteceu e o que fazer, em linguagem de negócio, sem código.
- Ação destrutiva com confirmação proporcional e, quando possível, desfazer em vez de
  diálogo.
- Estado de carregamento preserva a estrutura da tela para não deslocar conteúdo.

## Contrato de output

Cada estado desenhado ou descrito, com o texto real · o que dispara cada um · o que fica
fora da entrega e por quê.
