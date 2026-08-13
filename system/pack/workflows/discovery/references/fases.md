# Registro de fase do discovery (padrão do pack)

O que fica registrado ao fim de cada fase. A organização sobrescreve este arquivo em
`org/workflows/discovery/references/fases.md`.

## Fases mínimas

| Fase | Fecha com |
|---|---|
| Problema — exploração | quem é afetado, o que acontece hoje, hipóteses e incógnitas |
| Problema — definição | o problema em uma frase, a causa mais provável, o que conta como sucesso, o que fica fora |
| Solução — exploração | as alternativas consideradas, com o que cada uma custa e resolve |
| Solução — definição | a alternativa escolhida, o motivo, e o comportamento que ela implica |

Fase é unidade de registro: cada uma vira um registro próprio, mesmo quando duas acontecem
na mesma conversa.

## O que todo registro carrega

- **Data** e a fase a que se refere.
- **O que foi decidido**, e por quem, quando a decisão não é do agente.
- **A evidência** de cada afirmação: dado, documento, fala de quem usa, ou `suposição`.
- **O que ficou aberto**, e de quem é a decisão.
- **Para onde vai** cada comportamento, regra ou mensagem capturados — é o que a
  documentação consome depois sem refazer o trabalho.

## Retomada

O registro é escrito para quem chega sem a conversa: nomeia a demanda, a fase e o estado
anterior. Sessão interrompida no meio de uma fase fecha com o que já está decidido e o que
falta, em vez de não registrar nada.
