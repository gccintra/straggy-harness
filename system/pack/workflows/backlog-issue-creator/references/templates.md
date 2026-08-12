# Template de demanda (padrão do pack)

Formato default da descrição. A organização sobrescreve em
`org/workflows/backlog-issue-creator/references/templates.md`.

### Demanda de produto (feature / melhoria)

```markdown
## Problema
**O que:** o que acontece hoje (ou falta) e o efeito no trabalho de quem usa.
**Por que importa:** impacto no usuário, no negócio ou no sistema.

## Resultado esperado
O ganho verificável quando isso estiver resolvido — não a tela, não o mecanismo.

## Evidência
Quem pediu, quantas vezes, o que acontece sem isso.

## Priorização
- **Criticidade (MoSCoW):** MUST | SHOULD | COULD | WONT
- **Impacto / Confiança / Facilidade:** — (preenchidos no discovery)

## Notas do solicitante
Solução proposta por quem pediu, se houver — insumo para o discovery, não requisito.
```

### Bug

```markdown
## O que acontece
Comportamento observado, com passos para reproduzir.

## O que deveria acontecer
Comportamento esperado e a fonte (regra, documento de requisito, especificação).

## Onde e quando
Ambiente, tela/módulo, frequência, desde quando.

## Impacto
Quem é afetado e o que fica bloqueado.
```
