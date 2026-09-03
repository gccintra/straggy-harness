# 11 — Os quatro riscos (Cagan)

> **Método:** `opportunity-assessment` (L1). **Contrato:** objetivo de negócio com métrica ·
> problema do usuário · público · como saberemos que deu certo · riscos por categoria ·
> **recomendação**, não relatório neutro.
> **Estado:** avaliação do tema "Straggy Hub" como investimento.

---

## Enquadramento

| | |
|---|---|
| **Objetivo de negócio** | provar que o trabalho de produto padronizado é orçamentável: ≥ 3 contratos pagos em 8 propostas, em 4 semanas |
| **Problema do usuário** | o padrão da empresa não é executável; cada demanda sai no nível de quem pegou (02) |
| **Público** | times de produto de 3–20 pessoas que têm padrão e sofrem para replicá-lo — in-house, agência ou consultoria (S1 em 04) |
| **Sucesso quando** | ≥ 70% dos artefatos aceitos sem retrabalho de formato, medido em 10 demandas reais (10) |

## Risco 1 — Valor: eles querem?

**Nível: ALTO.** É o risco dominante.

| | |
|---|---|
| A favor | dor observada em prática real; o harness foi construído para resolvê-la e é usado `[I]`; capital indo para agentes que substituem função inteira `[F]` ([The Agent Report, 2026](https://the-agent-report.com/2026/07/ai-agent-startup-explosion-2026-yc-ecosystem/)) |
| Contra | ninguém foi cobrado ainda `[F]` — zero validação comercial; o concorrente mais forte é "não fazer nada", que é grátis; ChatGPT genérico já cobre 60–80% do trabalho repetitivo na percepção do usuário `[F]` |
| Como se reduz | oferta paga antes de construir (09) |
| O que o refuta | elogio sem contrato em 8 conversas |

## Risco 2 — Usabilidade: eles conseguem usar?

**Nível: MÉDIO-ALTO**, e mal-avaliado por padrão.

Dois usuários com critérios opostos (04):

| | |
|---|---|
| **P2, PM de execução** | precisa que o primeiro artefato preste. Se reescrever, abandona — e nenhuma feature recupera |
| **P3, administrador** | precisa **conseguir declarar o padrão**. Se configurar for assustador, a tese H2 morre e o produto vira gerador genérico |
| Risco escondido | a interface de configuração é o produto de verdade, e é a parte mais difícil de acertar. Funil em branco é modo de falha conhecido — por isso preset é obrigatório (`../HUB.md` §3.4) `[F]` |
| Como se reduz | teste de configuração assistida: pedir ao cliente que preencha **um** encaixe e observar sem ajudar |

## Risco 3 — Viabilidade: conseguimos construir?

**Nível: BAIXO para o núcleo, MÉDIO para o resto.**

| | |
|---|---|
| Baixo | o motor existe, roda e está em uso `[F]`. A parte difícil (resolução de camadas, esteira, catálogo como dado) está feita |
| Médio | espaço, estado compartilhado, permissões e materialização da camada da organização são construção nova, com decisões de arquitetura em aberto (`../MODOS.md` §6) `[F]` |
| Alto | o bloco PRD §8.3 (workshops, métricas, automação, voz, paralelismo) é **um produto inteiro**, não um incremento |
| Reduzido em 2026-08-29 | a execução foi para a máquina do usuário (`../MVP.md`), o que **retira do MVP a plataforma de sandbox inteira** — o item mais caro do plano técnico. Em troca, entram distribuição por sistema operacional e o pack em texto no disco do cliente |
| Médio, novo em 2026-08-29 | **cobertura de ferramenta de backlog.** O recorte de escopo tirou a construção de backlog próprio e pôs no lugar a dependência de integrar. Hoje existem duas implementações (GitHub e GitLab, ambas por CLI); Jira, Linear e Azure Boards não existem `[F]` (`system/providers/backlog/`). Cada uma é construção, e a customização de cada casa (sprint, etapas, campos) pode não caber nas operações abstratas — A14 em 09 |
| Como se reduz | não construir §8.3 no alpha (18); tratar cada item como decisão de investimento própria |

## Risco 4 — Negócio: funciona para nós?

**Nível: MÉDIO-ALTO**, por três motivos independentes:

| Frente | Risco |
|---|---|
| **Margem** | custo dominado por inferência e proporcional ao uso. Preço por assento inverte a margem no cliente mais engajado (03) `[S]` |
| **Distribuição** | venda consultiva, ticket médio, mercado conversado. Não escala sozinha; e autosserviço prematuro entrega o produto ao segmento errado (04) |
| **Fosso** | o único diferencial real hoje é arquitetural (área fechada) e **invisível na demonstração**. Fosso que não aparece na tela não vira preferência de compra sem narrativa forte |
| **Concorrência** | quem já tem distribuição (Atlassian, Productboard, Notion, Linear) pode contar história parecida com pior produto e ganhar — paridade percebida basta contra um desconhecido |
| **Dependência de plataforma** | as mesmas empresas com quem o produto **não** compete (Atlassian, Linear) são as donas da API de que ele depende para o trabalho aterrissar. Limite de chamada, mudança de contrato ou preço de API é risco fora do nosso controle — e é o preço de não ter backlog próprio (00, v4) |

## Riscos fora das quatro categorias

| Risco | Por que importa |
|---|---|
| **Risco de tese (plataforma)** | se modelos futuros produzirem no padrão certo só com contexto bruto, a camada de garantia vira overhead. Não é mitigável — é monitorável (16) |
| **Escopo confundido com produto pela metade** | não ter backlog próprio é decisão, mas o comprador pode ler como falta. A resposta não é construir: é a integração aterrissando o trabalho onde ele já olha. Se **isso** não convencer na demonstração, o problema é de posição (06), não de feature |
| **Conflito de posse do dado** | requisito, regra de negócio e backlog são dado sensível — em produto próprio pela estratégia, em serviço pelo contrato com o cliente final. Nuvem de terceiro pode ser bloqueio jurídico, não preferência (D3/A5) |

## Recomendação

**Seguir, com uma condição de sequência: testar valor antes de construir interface.**

1. **Agora:** oferta paga a 8 empresas com o motor atual (09). Nenhuma tela.
2. **Em paralelo:** 14 entrevistas (07), com P1 e P2 separados.
3. **Só depois de ≥ 3 contratos:** construir o alpha do bloco PRD §8.2, na fatia de 17/18.
4. **Não construir agora:** nada do bloco PRD §8.3 — e, por decisão de escopo, backlog,
   quadro ou sprint próprios não entram nem depois, salvo A14 refutada (09, 16 cenário 8).
5. **Construir por demanda de cliente:** implementação de provider de backlog (Jira, Linear,
   Azure Boards) só quando um contrato assinado depender dela. Antes disso é construção
   especulativa contra uma lista que 07 ainda vai definir (D8 em 08).

**O que faria descartar:** 0 contratos em 8 propostas **e** nenhuma reclamação de padrão nas
14 entrevistas. Aí o problema não existe no tamanho suposto, e insistir é preferência, não
produto.
