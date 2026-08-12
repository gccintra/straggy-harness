# Análise de risco e impacto de mudança

## Quando usar / quando não

- Use antes de mudar comportamento existente, estrutura de dado ou integração em uso.
- Não use para código novo isolado, sem consumidor.

## Barra de qualidade

- Raio de impacto levantado na **fonte** (código, banco, documentação), nunca de memória —
  quem consome, o que quebra, quem é avisado.
- Distingue efeito em comportamento, em dado histórico e em integração externa; os três têm
  correções diferentes.
- Risco descrito como consequência observável e probabilidade, não adjetivo.
- Caminho de volta avaliado: reversível, reversível com custo, ou irreversível — dado
  corrompido raramente volta.
- O que **não** muda também é dito: escopo de impacto sem limite gera medo e paralisa.

## Contrato de output

Mudança · consumidores afetados com fonte · riscos com probabilidade e consequência ·
reversibilidade · verificações antes e depois · o que fica fora do impacto.
