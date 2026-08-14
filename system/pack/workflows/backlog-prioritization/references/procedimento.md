# Procedimento padrão — priorizar backlog (pack)

As etapas do funil não moram aqui: elas são o encaixe `funil` (`references/funil.yaml`).
Este arquivo cobre o que o funil **não calcula** — o julgamento que depende de contexto.

## Via expressa

Criticidade real — sistema indisponível, risco de perda ou vazamento de dado, fluxo core
bloqueado, sem contorno — **não passa pelo funil**. Vai para execução imediata, e a
priorização registra o desvio em vez de tentar ranqueá-lo.

## Item que o funil não sabe pontuar

Obrigação legal, aposta estratégica, manutenção sem alcance mensurável: sai da fila e é
decidido no explícito, com o motivo registrado. Forçar uma nota inventada para caber no
score é pior que declarar que o item não é comparável.

## Fila separada

Tipo de demanda com esteira própria não disputa posição com os demais — aparece como
anomalia de fila, não como item mal ranqueado.

## Desempate final

Empate após toda a ordenação declarada: a demanda mais antiga na fila vem primeiro.

## A análise só identifica

Anomalia encontrada vira linha no relatório com a ação sugerida. Corrigir rótulo, nota ou
descrição é passo separado, e cada correção é aprovada pelo usuário antes de qualquer
escrita no backlog.
