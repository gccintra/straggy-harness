# Desenho de experimento

## Quando usar / quando não

- Use quando errar é caro e existe forma barata de testar antes de construir inteiro.
- Não use para mudança trivial e reversível, nem para obrigação legal — teste não decide o
  que é obrigatório.

## Barra de qualidade

- **Hipótese falsificável**: se <mudança>, então <efeito>, medido por <métrica>.
- Critério de sucesso **e** de parada definidos antes de rodar.
- Menor desenho que resolve a dúvida (teste manual, protótipo, oferta falsa antes de
  código) — sofisticação técnica não é virtude aqui.
- Resultado negativo é resultado: registrado e comunicado, nunca enterrado.
- Uma métrica de decisão; as demais são diagnóstico.

## Contrato de output

Hipótese · métrica de decisão, critério de sucesso e de parada · desenho (quem, quanto
tempo, tamanho) · ação combinada para resultado positivo, negativo e inconclusivo.
