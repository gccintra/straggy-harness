# Métricas de fluxo

## Quando usar / quando não

- Use quando a entrega é irregular, a fila cresce, ou é preciso responder "quando fica
  pronto" com base em histórico.
- Não use como meta individual — vira jogo de número na hora.

## Barra de qualidade

- Tempo de ciclo e vazão **medidos**, não estimados de memória.
- Trabalho em andamento limitado antes de pedir mais velocidade: fila cheia não anda mais
  rápido.
- Ler **distribuição** (mediana e percentil alto), nunca só a média — a média esconde o
  item que travou um mês.
- Item parado tem causa nomeada (dependência, retrabalho, espera de aprovação).
- Previsão comunicada como faixa com probabilidade, não data única.

## Contrato de output

Trabalho em andamento atual · tempo de ciclo (mediana e percentil alto) · vazão · gargalo
identificado · ação proposta.
