# Double Diamond — método de discovery

Quatro fases em dois diamantes: **D1a** explora o problema (diverge), **D1b** define o
problema (converge), **D2a** explora soluções (diverge), **D2b** define a solução (converge).

## Quando usar / quando não

- Use quando a demanda precisa de entendimento antes de virar requisito: problema difuso,
  solução chegou pronta sem validação, alternativas em aberto.
- Não use para bug crítico óbvio (via expressa direto para execução) nem para demanda já
  totalmente especificada e aprovada — aí é documentação, não discovery.

## Barra de qualidade

- **D1 antes de D2**: nenhuma solução é discutida antes de um problem statement aprovado.
- **Problem statement bom**: 1-2 frases — quem / qual problema / impacto observável. Com
  causa raiz (ou hipótese mais provável), critérios de sucesso verificáveis e non-goals
  explícitos.
- **D2 ancorado, não análogo**: solução sai do sistema real (regras, docs, dados
  existentes), não de analogia com outros produtos. Antes de propor, levantar o que já
  existe na área e listar as incógnitas que travam a solução.
- **Sem espantalho**: não inventar "Solução B" fraca para simular comparação. Caminho
  único → declarar único e por quê.
- **Toda afirmação tem origem**: existente (lida em fonte), confirmada (validada em
  dado/dev) ou suposição declarada a confirmar.
- **Pendências não somem**: pergunta aberta em D1 é reaberta e resolvida (ou adiada com
  motivo) antes de fechar D2. Nenhuma fecha em silêncio.
- **Convergência é negociada**: cada valor de priorização proposto com justificativa e
  aprovado pelo usuário — um de cada vez, nunca em bloco.

## Contrato de output

- **D1a** → afetados, contexto, hipóteses com evidência, perguntas em aberto.
- **D1b** → problem statement, causa raiz, critérios de sucesso, non-goals, criticidade
  (MoSCoW) + impacto + confiança. Facilidade fica TBD — depende da solução.
- **D2a** → alternativas reais com prós/contras honestos (ou caminho único justificado) e
  decisão de qual segue.
- **D2b** → solução definida: fluxo (com edge cases), campos, regras/comportamentos em
  material bruto de negócio (cada item com origem + destino), pendências do D1 resolvidas,
  critérios de aceite, priorização final completa (ICE + quadrante), decomposição se
  couber.

O registro de cada fase, onde ele é publicado e em que formato são binding do workflow
(L2), não do método.
