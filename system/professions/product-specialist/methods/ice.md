# Score e faixas — ICE, RICE e equivalentes

## Quando usar / quando não

- Use **depois** que existe solução definida: facilidade/esforço só é estimável com solução
  escolhida. As dimensões de valor e evidência podem nascer na definição do problema.
- Não use no intake (ver `moscow.md`) nem como substituto de julgamento — o score informa a
  conversa, não a encerra.

## Estrutura

- **Score** agrega as dimensões declaradas por um operador declarado (produto, soma
  ponderada, razão). ICE = Impacto × Confiança × Facilidade é uma instância; RICE e WSJF são
  outras. Dimensões, escalas, rubrica de cada nota e operador **são do projeto** — leia a
  instância do encaixe `funil` (`system/schemas/funil-priorizacao.yaml`), nunca assuma.
- **Faixas** cruzam uma ou duas dimensões em bandas de ação (fazer já / planejar / depois /
  descartar). Os cortes são do projeto.
- **Funil completo**: triagem → faixa → score. Cada camada refina a anterior; nenhuma
  sozinha decide.

## Barra de qualidade

- **Cada dimensão negociada**: proposta + justificativa + aprovação do usuário, uma por
  vez. Score imposto não é priorização, é decreto.
- **Rubrica antes de nota.** Existindo rubrica por faixa de valor, a nota sai dela e a
  justificativa cita a zona — nota sem critério compartilhado é feeling com número.
- **Consistência é auditável**: score registrado ≠ produto das dimensões, rótulo ≠ banda
  calculada, item priorizado sem score — tudo isso é anomalia a reportar, nunca a corrigir
  em silêncio.
- **Cortes vêm do funil declarado, não de memória**: se o projeto mudou os limites, a
  análise reflete porque leu, não porque decorou.

## Contrato de output

Dimensões + score + banda + justificativa por dimensão. Numa análise de backlog: ranking
(triagem → banda → score decrescente) + lista de anomalias com ação sugerida — a correção é
decisão do usuário.
