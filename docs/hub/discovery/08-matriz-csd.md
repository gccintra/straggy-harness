# 08 — Matriz CSD

> **Método:** `csd-matrix` (L1). **Contrato:** certezas **com fonte** · suposições com
> destino · dúvidas com dono e prazo · o que muda no próximo passo.
> **Estado:** a matriz não é o entregável — a fila de teste (09) e a lista de perguntas são.

---

## Certezas — só entra com fonte

| # | Certeza | Fonte |
|---|---|---|
| C1 | O motor executa trabalho de produto hoje: 22 ações, 6 artefatos na esteira, 86 métodos | `system/ACOES.md`, `system/professions/` |
| C2 | A customização por encaixe não alcança portão, contrato de saída nem método | `docs/ARCHITECTURE.md` §7 |
| C3 | Nenhuma feature do Hub está implementada | `docs/MODOS.md` — "modo aplicativo é desenho" |
| C4 | O harness carrega o fluxo de **um** usuário — o autor: cliente externo, ordem de serviço, HU/HT, `.docx`. Fato sobre a origem, **não sobre o mercado** | `project-config.template.yaml`, `doc-final-generator`; correção de viés em 04 |
| C5 | Existe mercado de ferramenta de IA para PM já monetizado, na faixa de US$ 10–29/usuário/mês | [ChatPRD](https://www.chatprd.ai/learn/best-ai-tools-for-product-managers) · [UserJot/JPD](https://userjot.com/blog/jira-product-discovery-pricing) |
| C6 | Capital está indo para "agente que substitui uma função inteira", não para assistente | [The Agent Report, 07/2026](https://the-agent-report.com/2026/07/ai-agent-startup-explosion-2026-yc-ecosystem/) |
| C7 | O consenso público é que IA entrega artefato e não julgamento | [Product Leadership, 2026](https://www.productleadership.com/blog/will-ai-replace-product-managers/) |
| C8 | Existe **ao menos um** time cujo padrão era forte o bastante para virar workflow próprio — o do autor. Amostra 1, viés de origem | `org/workflows/hu-narrative-generator/` |
| C9 | O motor **já opera backlog sem ter um**: as ações falam com uma interface abstrata de operações (listar, criar, atualizar, comentar, fechar, sprint), e a ferramenta real entra como implementação trocável | `system/providers/backlog/INTERFACE.md`, implementações `github-gh` e `gitlab-glab` |
| C10 | Só **duas** implementações de backlog existem hoje (GitHub e GitLab, ambas por CLI). Jira, Linear e Azure Boards estão previstos e **não** foram construídos | `system/providers/backlog/` — `jira` aparece como pendente na própria interface |

**Rebaixadas de certeza para suposição durante este discovery** — o trabalho principal do método:

| Era tratado como certeza | Por que caiu |
|---|---|
| "empresas querem configurar o próprio padrão" | uma empresa fez isso, e é a de casa. Amostra 1, com viés total → S2 |
| "o problema é caro o bastante para virar orçamento" | nenhuma proposta comercial foi feita → S1 |
| "documentação padronizada é a dor mais forte" | nunca comparada com priorização e alinhamento na boca do cliente → S3 |
| "o produto precisa de backlog próprio para fechar o fluxo" | nunca foi testado contra a alternativa mais barata — operar o backlog que o time já tem. Virou **decisão de escopo** em 2026-08-29 (00), e a aposta que sobrou está em S12 |

## Suposições — cada uma sai com destino

Destino ∈ **testar** · **aceitar conscientemente** · **descartar**.

| # | Suposição | Destino | Como |
|---|---|---|---|
| S1 | O problema vira orçamento | **testar** | oferta paga a 8 empresas (03) |
| S2 | A empresa configura o próprio padrão | **testar** | entrevista 07 bloco 2 + teste de configuração assistida |
| S3 | Replicar o padrão é a dor #1 de S1 — acima de volume, priorização e alinhamento | **testar** | 07, sem sugerir a resposta |
| S4 | Artefato é aceito sem reescrita com frequência alta | **testar** | medir em 10 demandas reais operadas por nós |
| S5 | P2 (PM de execução) adota, não sabota | **testar** | 07 com P2 separado de P1 |
| S6 | Preço por espaço + volume é aceitável | **testar** | oferta com 2 faixas na mesma conversa |
| S7 | Voz é diferencial relevante | **descartar** do alpha | nenhum indício; custo alto |
| S8 | Paralelismo é o que gera o ganho de produtividade | **testar depois** | só faz sentido medir com produto de pé |
| S9 | Modelos futuros não tornam a estrutura desnecessária | **aceitar conscientemente** | risco de tese, registrado em 16; ninguém controla |
| S10 | Consultoria aceita dado de cliente em nuvem de terceiro | **testar, com peso menor** | 07 e objeção de contrato. **Enfraquecida em 2026-08-29:** com a execução na máquina do usuário e a chave de IA dele, o dado de trabalho não passa pela nossa infra durante a execução — sobra o repositório, que é o que de fato precisa ser hospedado |
| S11 | 3 profissões bastam (sem dev/QA/dados) | **aceitar conscientemente** | limite declarado do pack; revisitar em 12 meses |
| S12 | Operar o backlog do time **por integração** é bom o bastante para o PM não voltar a abrir a ferramenta na mão | **testar** | 07 bloco 4 + medição no alpha (19, S9). É a aposta embutida no recorte de escopo; vira a premissa A14 em 09 |
| S13 | A customização real das ferramentas (sprint, etapas de kanban, campos obrigatórios) cabe nas operações da interface de provider | **testar** | 07 bloco 4, pedindo para **ver** a configuração, nunca perguntando se "é padrão" |

**Aceitas sem teste, com dono** (não somem do radar): S9 e S11 — aceitas por Gustavo,
2026-08-18, registradas aqui e em 16.

## Dúvidas — cada uma com dono e prazo

Dúvida sem dono não é dúvida, é desejo.

| # | Dúvida | Dono | Prazo | Como se responde |
|---|---|---|---|---|
| D1 | "Espaço" é o mesmo objeto que a organização de hoje? | Gustavo | antes de qualquer tela | decisão de modelo, não pesquisa |
| D2 | ~~O trabalho roda na infra do produto ou na máquina do cliente?~~ **Respondida em 2026-08-29: os dois, em camadas diferentes.** Repositório, artefatos e histórico das sessões no servidor; execução do agente na máquina do usuário, com a chave de IA dele | Gustavo | — | decidida (`../MVP.md`) |
| D2b | Com o cliente trazendo a própria chave de IA, **o que exatamente ele está pagando?** | Gustavo | antes da oferta | não é inferência: é o workflow, o repositório e o portão. Muda a hipótese de preço de 03 §6 |
| D2c | Execução no cliente coloca o pack em texto no disco dele (`../MODOS.md` §6, propriedade intelectual). O que fazer antes da primeira venda? | Gustavo | antes da 1ª venda | decisão, não pesquisa — aceitar, ofuscar ou mover a execução para o servidor de quem paga |
| D3 | Consultoria aceita nuvem? Quantas exigem on-premise? | Gustavo | com 07 | perguntar em todas as 14 |
| D4 | Onde o trabalho precisa aterrissar em cada time (backlog? wiki? documento formal?) | Gustavo | com 07 | pedir para ver o destino real, sem sugerir |
| D5 | Quem tem a verba: líder de produto, tecnologia ou operações? | Gustavo | com 07 | perguntar quem assina |
| D6 | Quanto custa hoje, em horas, formatar/padronizar por demanda? | Gustavo | com 07 | reconstruir a última demanda, não pedir média |
| D7 | Qual o teto de preço antes de virar "melhor contratar um PM júnior"? | Gustavo | na oferta | comparação explícita na conversa de preço |
| D8 | Quais ferramentas de backlog precisam existir para o alpha rodar — e quantas o time-alvo usa de fato? | Gustavo | antes do alpha | contar nas 14 entrevistas; hoje só GitHub e GitLab estão implementados (C10) |
| D9 | Quanto da configuração de cada time cabe nas operações abstratas do provider, e o que sobra de fora? | Gustavo | com 07 | ver a configuração real na tela da pessoa, não perguntar |
| D10 | Quem opera o backlog hoje — o PM, o time inteiro, ou um papel próprio? | Gustavo | com 07 | perguntar quem registrou a última demanda |

## O que muda no próximo passo

1. **Nada de tela antes de S1.** A oferta paga usa o motor que já roda — construir antes é
   apostar em cima de suposição não testada.
2. **07 é o gargalo do discovery inteiro.** Seis suposições (S1–S5, S12–S13) e sete dúvidas
   (D3–D10) dependem dele.
3. **O recorte de escopo trocou uma construção por uma aposta.** Não construir backlog
   próprio economiza um produto inteiro e cria uma dependência: a integração precisa dar
   conta de ferramentas customizadas (S12, S13). Isso é ganho — a aposta é barata de testar
   e a construção não era.
4. **D1 e D2 não são pesquisa, são decisão.** Não terceirize para o cliente uma escolha de
   arquitetura de produto.
