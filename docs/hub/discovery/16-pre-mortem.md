# 16 — Pré-mortem

> **Métodos:** `experiment-design` + `decision-record` (L1). Exercício: **estamos em agosto
> de 2027 e o Straggy Hub morreu.** Cada cenário responde: como morreu · qual foi o primeiro
> sinal · o que teria evitado · o que fazemos agora.
> **Estado:** cenários ordenados por probabilidade percebida `[S]`.

---

## Cenário 1 — Morreu construindo (o mais provável)

**Como:** passamos 10 meses construindo espaço, permissões, workshops e métricas.
Ficou bonito. Quando fomos vender, descobrimos que ninguém paga por isso — e o caixa acabou
antes da segunda tentativa.

| | |
|---|---|
| **Primeiro sinal** | um mês inteiro sem falar com nenhuma empresa que não seja a nossa |
| **Sinal ignorado** | "vamos validar quando estiver apresentável" |
| **O que teria evitado** | oferta paga com o motor atual antes de qualquer tela (09) |
| **Agora** | regra dura: **nenhuma linha de interface antes de 3 contratos** (11). Ver 19, critério de entrada |

## Cenário 2 — O portão virou clique

**Como:** o produto funcionou, os artefatos passaram, e os usuários começaram a aprovar tudo
sem ler. Um requisito errado passou para um cliente grande. A promessa central ("nada sai
sem aprovação humana") virou piada interna.

| | |
|---|---|
| **Primeiro sinal** | tempo médio entre "artefato pronto" e "aprovado" caindo para segundos |
| **Sinal ignorado** | métrica de aceitação subindo enquanto ninguém reclamava de nada |
| **O que teria evitado** | o contrapeso declarado em 03: **portões aprovados sem leitura** medido desde o dia 1 |
| **Agora** | F24 (relatório de aceitação) inclui o contrapeso, não só a métrica bonita |

## Cenário 3 — Ninguém configurou nada

**Como:** todo mundo usou com o padrão de fábrica. O encaixe ficou vazio em 100% dos
espaços. Sem padrão declarado, o produto virou "mais um gerador de PRD" — e perdeu para o
que custa US$ 15/mês.

| | |
|---|---|
| **Primeiro sinal** | primeiro cliente pagante com zero encaixe preenchido depois de 60 dias |
| **Sinal ignorado** | "eles configuram depois, quando pegarem o jeito" |
| **O que teria evitado** | tratar a configuração como **implantação assistida**, não como autosserviço; e testar A2 cedo (09) |
| **Agora** | F05 (extrair padrão de documentos antigos) sai do fundo da fila se 07 confirmar que declarar o padrão é o atrito principal (14) |

## Cenário 4 — A margem inverteu

**Como:** cobramos por assento. Os clientes que mais usavam custavam mais em inferência do
que pagavam. Crescer aumentou o prejuízo, e o corte de qualidade (modelo menor) derrubou a
aceitação.

| | |
|---|---|
| **Primeiro sinal** | custo de inferência por conta crescendo mais rápido que a receita por conta |
| **Sinal ignorado** | "otimizamos depois" |
| **O que teria evitado** | métrica de cobrança acompanhando volume desde a primeira proposta (03) |
| **Agora** | toda proposta do teste A1 leva duas faixas de preço, uma delas atrelada a volume — o dado de sensibilidade vem junto da validação |

## Cenário 5 — O modelo tornou a estrutura desnecessária

**Como:** a geração seguinte de modelos passou a produzir no padrão certo só com o contexto
bruto da empresa. A camada de garantia virou overhead: mais lenta, mais cara, e sem ganho
perceptível.

| | |
|---|---|
| **Primeiro sinal** | cliente comparando nossa saída com a de um chat genérico **alimentado com os documentos dele** e não vendo diferença |
| **Sinal ignorado** | atribuir o empate a "eles configuraram bem o prompt" |
| **O que teria evitado** | nada. Este é risco de tese, aceito conscientemente (09, S9) |
| **Agora** | monitorar com teste cego trimestral: mesma demanda, nossa saída × chat genérico com o mesmo contexto, avaliada pelo cliente sem saber qual é qual. **Empate repetido = a tese mudou**, e o valor migra para portão, estado e colaboração, não para geração |

## Cenário 6 — O comprador nunca foi o usuário

**Como:** o líder comprou, o time não usou. Renovação não veio. Descobrimos tarde que o PM
de execução via o produto como vigilância do chefe.

| | |
|---|---|
| **Primeiro sinal** | uso concentrado em 1 pessoa por conta, 30 dias após a implantação |
| **Sinal ignorado** | reunião de status positiva com quem comprou |
| **O que teria evitado** | entrevistar P1 e P2 **separadamente** (07), e medir uso por papel |
| **Agora** | 07 tem cota mínima de P2; a métrica de adoção é por papel, nunca agregada (03) |

## Cenário 7 — Um incumbente contou a mesma história

**Como:** Atlassian ou Productboard anunciaram "padrão da empresa aplicado por IA". Pior
produto, distribuição infinitamente maior. Paridade percebida foi suficiente.

| | |
|---|---|
| **Primeiro sinal** | anúncio de "AI templates / company standards" em keynote de um deles |
| **O que teria evitado** | nada impede o anúncio. O que protege é ter **prova** (aceitação medida por cliente) e profundidade que um recurso de plataforma não alcança |
| **Agora** | acumular medição de aceitação desde o primeiro contrato — é a única resposta não retórica a um incumbente |

## Cenário 8 — a integração não deu conta (novo em 2026-08-29)

**Como:** decidimos não construir backlog próprio e operar o do cliente por integração. Na
prática, cada time tinha a ferramenta configurada do seu jeito — sprint que não era sprint,
etapas obrigatórias, campo próprio travando a criação. A ação escrevia quase certo, e o PM
abria o Jira depois para consertar. "Quase certo" custou mais que fazer à mão. As ações de
backlog caíram em desuso, o produto encolheu para geração de documento — e aí o ChatPRD
custava US$ 15.

| | |
|---|---|
| **Primeiro sinal** | usuário abrindo a ferramenta de backlog logo depois de a ação escrever nela |
| **Sinal ignorado** | "é só ajustar o mapeamento desse cliente" — repetido em cada implantação, sem ninguém contar quantas vezes |
| **O que teria evitado** | ver a configuração real na tela de 14 times **antes** de fechar o escopo (07, bloco 4), em vez de assumir que a interface abstrata cobria |
| **Agora** | A14 entra na fila de teste com critério de refutação escrito (09); S9 mede no alpha quantas vezes a pessoa volta à ferramenta na mão (19). Refutada, a decisão de escopo é reaberta com dado — **construir backlog próprio volta a ser opção legítima**, e não vira concessão de última hora |

**O que este cenário não é:** um argumento para construir kanban por precaução. Construir
antes de A14 falhar é o cenário 1 com outro nome.

## O padrão comum destes oito cenários

Cinco dos oito morrem pelo mesmo motivo: **decidimos por otimismo, com sinal disponível e
ignorado.** Nenhum morreu por falta de feature. A defesa é instrumental, não motivacional —
cada sinal acima vira um número acompanhado desde o primeiro cliente, e não uma intuição
para ser revisitada quando der tempo.
