# PM — Gatilhos de julgamento

Coleção de gatilhos: *situação com cara de X → considere a lente Y, pergunte Z*.
**Forma, não fluxo** — nada aqui é sequência obrigatória; aponta a lente, o caminho é seu.

- **Pedido chega só com o resultado** ("quero reduzir o retrabalho da vistoria") → é o modo
  normal. Escolha a lente, produza o artefato e entregue com as suposições declaradas —
  devolver uma lista de perguntas é transferir seu trabalho para quem pediu.
- **Pedido chega como solução pronta** ("quero exportar em PDF assíncrono") → descole o
  problema por trás: "que problema isso resolve?", "o que acontece hoje sem isso?". A
  solução proposta vira nota para o discovery; o que se documenta é o problema. Formato,
  mecanismo e tecnologia são decisão de discovery, não de intake.
- **Feature pedida sem problema validado** → antes de priorizar, verifique se existe
  evidência (quem pediu, quantas vezes, o que acontece sem). Não existe → ofereça
  discovery, não score.
- **Stakeholder pressiona por prazo** → separe custo do atraso real (o que quebra, quem
  perde, quando) de ansiedade. Custo real muda MoSCoW; ansiedade não.
- **Demanda grande/vaga** → procure a decomposição antes do score: um score para um
  guarda-chuva não prioriza nada. Proponha o corte e pergunte como dividir.
- **Duas demandas parecidas no backlog** → suspeite de duplicata antes de criar a terceira.
  Título parecido não basta: compare o problema, não a solução.
- **Priorização "no feeling"** → exija o funil declarado do projeto (criticidade →
  quadrante → score). Score sem os thresholds escritos é opinião com número.
- **Meta de sprint que lista entregas** → é output. Pergunte "o que o usuário/negócio ganha
  quando isso tudo estiver no ar?" — a resposta é a meta.
- **Documento que descreve telas e botões nas seções de problema/escopo** → solução vazou.
  Problema e escopo falam do porquê e do o quê; o como mora em CA, regra e protótipo.
- **Cliente pede a solução que o concorrente tem** → a pergunta não é "eles têm?", é "que
  critério de compra isso atende?" (`competitive-analysis.md`). Paridade de feature não é
  estratégia.
- **Feedback chegando por muitos canais, sem padrão** → antes de virar demanda, agrupe por
  problema com frequência, severidade e segmento (`voice-of-customer.md`). Cliente que
  grita mais alto não é maioria.
- **Número de mercado ou de impacto pedido na hora** → dê a faixa e as premissas, ou diga
  que não há base. Número único sem premissa vira argumento de autoridade e ninguém audita
  depois.
- **Métrica proposta é contagem acumulada** (cadastros, acessos) → falta contrapeso e
  ligação com valor entregue (`product-metrics.md`). Pergunte o que não pode piorar
  enquanto esse número sobe.
- **"Vamos testar" sem critério** → experimento sem critério de sucesso e de parada
  definido antes vira justificativa retroativa (`experiment-design.md`).
- **Escopo grande com pressão de prazo** → fatie pela jornada, não pela camada técnica
  (`story-mapping.md`, `story-splitting.md`). Entregar só o back não entrega nada.
- **Mudança que afeta outra área e ninguém foi avisado** → mapeie quem sofre o impacto e
  quem pode travar antes de seguir (`stakeholder-mapping.md`); surpresa cara é a que chega
  na véspera.
- **Ideia nova disputando espaço com o roadmap** → escreva o resultado como se já tivesse
  lançado (`prfaq.md`); se não convence sem adjetivo, a ideia é fraca — e isso é a
  informação.
- **Pergunta sem workflow que a cubra** → volte aos princípios: qual é o problema, qual a
  evidência, qual o menor passo reversível que gera aprendizado. Diga qual lente está
  usando e siga.
- **Conflito entre fontes** (issue diz X, doc diz Y) → não escolha em silêncio. Aponte a
  divergência e pergunte qual vale.

## Lente de PO — fila, ciclo e aceite

- **Time pede estimativa antes de o item estar refinado** → estimar o que ninguém entendeu
  produz número que vira promessa. Refine ou proponha investigação com tempo fixo
  (`backlog-refinement.md`, `estimation.md`).
- **Item entra no ciclo sem critério de aceite** → não entra. Sem critério não há como
  dizer que terminou, e a discussão volta na revisão (`acceptance-criteria.md`).
- **Ciclo planejado como lista de tarefas** → falta meta. Sem meta não dá para negociar
  escopo no meio sem parecer fracasso (`sprint-planning.md`, `sprint-goal.md`).
- **Pedido de escopo no meio do ciclo** → a pergunta não é "cabe?", é "o que sai no lugar?".
  Troca explícita, com o custo dito a quem pediu.
- **"Estamos aguardando outro time"** → isso não é status, é dependência sem dono e sem
  data. Nomeie contraparte, data acordada e plano B (`dependency-management.md`).
- **Time pede refatoração e o negócio ouve "capricho"** → traduza em consequência
  (incidente, tempo de entrega, roadmap bloqueado) e compare com o custo de conviver
  (`technical-debt.md`).
- **Velocidade caiu e a reação é cobrar mais itens** → olhe fila e tempo de ciclo antes:
  trabalho em andamento demais desacelera (`flow-metrics.md`).
- **PO virando repassador de demanda** → se todo item chega pronto de fora, o papel virou
  fila. Volte ao problema e ao critério de decisão: quem prioriza, prioriza com quê.
- **Aceite virando revisão de gosto** → aceite compara entrega com critério acordado;
  ideia nova que aparece no aceite é demanda nova, não correção.
- **Data externa real (contrato, evento, obrigação legal)** → escopo é a variável de ajuste;
  combine isso antes, não na véspera (`release-planning.md`).

## Lente de dado — analytics

- **Número apresentado sem janela, filtro ou fonte** → não é dado, é afirmação. Peça (ou
  declare) os três antes de concluir (`data-quality-check.md`).
- **Métrica pedida para algo que não é medido hoje** → o trabalho é instrumentar, não
  estimar. Diga que não existe e o que precisa existir (`instrumentation.md`).
- **Total acumulado usado como sinal de saúde** → cresce mesmo com produto morrendo. A
  pergunta é retenção por safra (`cohort-retention.md`).
- **Agregado bonito, decisão grande** → segmente antes de agir; média que junta grupos
  opostos leva a decidir contra o próprio cliente (`segmentation.md`).
- **Teste "deu positivo"** → confira efeito absoluto, contrapeso e se pararam de olhar
  quando ficou bom (`ab-test-reading.md`).

## Lente de crescimento e mercado

- **Pedido de "mais usuários" com retenção furada** → aquisição em cima de balde furado
  queima caixa. Ordem: reter, ativar, depois adquirir (`growth-model.md`).
- **Lançamento tratado como data de deploy** → quem atende precisa saber antes do cliente;
  sem isso o lançamento vira fila de suporte (`gtm-plan.md`).
- **Preço discutido a partir do custo interno** → o cliente compara com a alternativa dele,
  não com sua planilha (`pricing-packaging.md`).

## Lente de liderança

- **Mesma decisão sendo tomada pela terceira vez** → falta registro do contexto e da
  consequência aceita (`decision-record.md`).
- **Pedido que não entra e ninguém foi avisado** → silêncio vira escalada. Recuse com
  critério e alternativa, e registre (`saying-no.md`).
- **Atualização virando lista de atividades** → comece pela conclusão e peça uma decisão só
  (`written-update.md`).
- **Risco conhecido guardado para "quando tiver solução"** → má notícia adiada custa mais
  que má notícia dada cedo.
- **Escalar antes de tentar direto** → queima relação com o par e resolve pior; leve fato,
  impacto e opções quando for (`escalation.md`).

