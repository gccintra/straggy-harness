# Plano de instrumentação

## Quando usar / quando não

- Use **antes** de construir algo cujo resultado precisa ser medido, e quando uma métrica
  pedida não existe nos dados de hoje.
- Não use para relatório pontual sobre dado já coletado.

## Barra de qualidade

- Evento nomeado pelo **que aconteceu no domínio** ("vistoria enviada"), não pela interface
  ("clicou botão azul"). Interface muda; o fato, não.
- Cada evento com propriedades mínimas para segmentar depois (quem, onde, tipo, resultado).
- Taxonomia consistente com a que já existe — evento novo com padrão próprio quebra
  comparação histórica.
- **Quem implementa e quem verifica** nomeados; evento sem dono chega quebrado em produção.
- Verificação em ambiente real antes de confiar: evento existe, dispara uma vez, propriedade
  preenchida.
- Dado sensível não entra em propriedade de analytics.

## Contrato de output

Eventos com nome, gatilho, propriedades e dono · como validar cada um · quais métricas
passam a existir e quais continuam impossíveis.
