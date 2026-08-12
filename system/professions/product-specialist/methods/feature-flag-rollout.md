# Liberação gradual e chave de desligamento

## Quando usar / quando não

- Use quando o risco de errar em produção é alto ou o efeito precisa ser medido antes de
  todos.
- Não use como forma de entregar pela metade indefinidamente: chave que nunca é removida
  vira dívida e caminho de código morto.

## Barra de qualidade

- Critério de avanço por etapa definido antes (métrica, tempo, ausência de erro).
- **Critério de recuo** definido antes e conhecido por quem está de plantão.
- Grupo inicial escolhido por representatividade e tolerância, não por conveniência.
- Estado atual visível: quem está com o quê ligado — suporte precisa saber para atender.
- Data de remoção da chave planejada junto com a criação.

## Contrato de output

Etapas com percentual e critério de avanço · critério e mecanismo de recuo · quem monitora
· data de remoção da chave.
