# 09 — Assumption mapping

> **Método:** `assumption-mapping` (L1). **Contrato:** premissas nos dois eixos (impacto se
> falsa × evidência atual) · a mais arriscada · teste mínimo e o que a refutaria · premissas
> aceitas conscientemente, declaradas.
> **Estado:** entrada vem de 08. Só o canto "alto impacto, baixa evidência" merece teste.

---

## O mapa

```
  ALTO IMPACTO SE FALSA
        │
        │   ┌─────────────────────────────┬─────────────────────────────┐
        │   │  TESTAR AGORA               │  MONITORAR                  │
        │   │  (alto impacto, sem prova)  │  (alto impacto, com indício)│
        │   │                             │                             │
        │   │  A1 problema vira orçamento │  A6 padrão documental é dor │
        │   │  A2 empresa configura       │     real em S1              │
        │   │  A3 artefato aceito sem     │  A7 portão é percebido como │
        │   │     reescrita               │     valor, não como fricção │
        │   │  A4 P2 adota, não sabota    │  A8 capital/mercado existe  │
        │   │  A5 empresa aceita nuvem    │     para a categoria        │
        │   │  A14 operar o backlog do    │                             │
        │   │      time por integração    │                             │
        │   │      é bom o bastante       │                             │
        │   └─────────────────────────────┼─────────────────────────────┤
        │   │  DECIDIR E SEGUIR           │  IGNORAR                    │
        │   │  (baixo impacto, sem prova) │  (baixo impacto, com prova) │
        │   │                             │                             │
        │   │  A9  voz importa            │  A12 integração com GitHub  │
        │   │  A11 paralelismo é o ganho  │      e GitLab é viável      │
        │   │                             │  A13 .docx é gerável        │
        │   └─────────────────────────────┴─────────────────────────────┘
        │
  BAIXO IMPACTO ────────────────────────────────────────────── ALTA EVIDÊNCIA
```

## Premissas por categoria de risco

Desejabilidade, viabilidade e exequibilidade têm riscos diferentes e não se misturam:

| Categoria | Premissa | Impacto se falsa | Evidência hoje |
|---|---|---|---|
| **Desejabilidade** | A1 — o problema é caro o bastante para virar orçamento | fatal: não há negócio | nenhuma `[S]` |
| **Desejabilidade** | A3 — o artefato é aceito sem reescrita | fatal: o Hub só adiciona etapa | nenhuma `[S]` |
| **Desejabilidade** | A4 — o PM de execução adota | alto: compra sem uso, churn no 2º mês | nenhuma `[S]` |
| **Desejabilidade** | A6 — replicar o padrão é dor real em S1 | alto: erra o beachhead | **nenhuma** `[S]` — o sinal do repositório era amostra 1 e foi rebaixado (04) |
| **Desejabilidade** | A7 — portão é valor, não fricção | alto: o diferencial vira reclamação | nenhuma `[S]` |
| **Viabilidade (negócio)** | A2 — a empresa configura o próprio padrão | alto: sem fosso, vira commodity | amostra 1, viesada `[I]` |
| **Viabilidade (negócio)** | A5 — a empresa aceita dado de produto em nuvem de terceiro | alto: muda o produto inteiro (D2) | nenhuma `[S]` |
| **Viabilidade (negócio)** | A8 — existe mercado e capital para a categoria | médio | pública `[F]` |
| **Desejabilidade** | A15 — o repositório de contexto (documentos, arquivos, estruturas de produto no mesmo lugar) é o que **atrai** gente para o sistema, mais que a execução | alto: justificou promover o ramo mais caro do discovery à primeira versão. Se falsa, a construção mais pesada do MVP foi feita pela razão errada — o valor continua existindo (O1 é `[F]`), mas o gancho de entrada é outro e a ordem de construção estava errada | **nenhuma** `[S]` — é convicção do dono do produto, 2026-08-29, e não é testável com um usuário que é o próprio autor |
| **Desejabilidade** | A14 — operar o backlog do time por integração é bom o bastante para o PM não voltar a abrir a ferramenta na mão | alto: as ações de backlog e sprint viram etapa a mais, ou o produto precisa construir o backlog que o recorte de escopo tirou da mesa | **nenhuma** `[S]` — a aposta é de 2026-08-29 e nunca foi testada fora do fluxo do autor |
| **Exequibilidade** | A12/A13 — integrações e geração de documento funcionam | baixo: já funcionam | `[F]` — rodando, mas só GitHub e GitLab (C10 em 08) |

**A10 saiu do mapa.** "Kanban próprio importa" deixou de ser premissa a mapear e virou
**decisão de escopo**: o produto não constrói backlog (00, v4). No lugar dela ficou A14 — a
aposta que a decisão embute. Se A14 cair, kanban próprio volta como decisão nova, com dado.

## A premissa mais arriscada: A1

**Por que ela e não A3:** se A1 é falsa, A3 não importa. Sem orçamento não há produto, por
melhor que o artefato saia.

### Teste mínimo — o mais barato que refuta

**Oferta de serviço operado, com o motor que já existe.** Zero código novo.

| | |
|---|---|
| **Desenho** | 8 times de S1/S2 (04), variando modelo de negócio de propósito · proposta escrita: "declaramos o padrão de vocês e entregamos os requisitos das próximas 10 demandas nele" · preço na mesa desde a primeira conversa |
| **Métrica de decisão** | contratos assinados ÷ propostas apresentadas |
| **Sucesso** | ≥ 3 de 8 assinam |
| **Parada** | 0 assinados após a 5ª conversa |
| **O que refuta A1** | "adoraria, mas não tenho orçamento para isso" repetido — elogio sem dinheiro é refutação, não empate |
| **Prazo** | 4 semanas |
| **Custo** | tempo do fundador; nenhuma construção |

### Ação combinada, antes de rodar

- **Positivo (≥3):** A1 confirmada. Passa a testar A3 medindo reescrita nas 10 demandas de
  cada contrato, e A2 tentando fazer o cliente preencher os encaixes ele mesmo.
- **Negativo (0):** A tese muda. As duas alternativas na mesa: (a) o comprador é outro —
  testar segmento B; (b) o job é outro — reabrir 05 com o que apareceu nas recusas.
- **Inconclusivo (1–2):** amostra pequena, sinal fraco. Mais 6 conversas antes de decidir —
  e nenhuma linha de código enquanto isso.

## Sequência de teste — uma por vez, na ordem

| Ordem | Premissa | Teste | Depende de |
|---|---|---|---|
| 1 | A1 | oferta paga (acima) | — |
| 2 | A3 | medir % de artefatos aceitos sem reescrita nas demandas contratadas | A1 |
| 3 | A2 | pedir ao cliente que preencha 1 encaixe sozinho; medir se consegue e se o resultado presta | A1 |
| 4 | A5 | objeção de nuvem levantada em toda proposta; contar quantas travam | paralelo a A1 |
| 5 | A4 | observar quem realmente opera na conta contratada: líder ou PM | A1 |
| 6 | A7 | contar quantas aprovações passam sem leitura (contrapeso do 03) | A3 |
| 8 | **A15** | pergunta de 07 sem sugerir a resposta ("onde vive o roadmap de vocês? e as personas? quando foi a última vez que alguém abriu?"); no uso próprio, contar quantas vezes uma estrutura é **consultada**, não preenchida (`../MVP.md`, Parte 4) | independente — a parte de entrevista roda junto com A1 |
| 7 | **A14** | 07 bloco 4 nas 14 conversas (ver a configuração real, não perguntar); depois, no alpha, contar quantas vezes o usuário abre a ferramenta na mão para consertar o que a ação escreveu (19, S9) | paralelo a A1 — a parte de entrevista não custa nada |

### O que refutaria A14

Escrito antes de olhar o resultado, para não ser racionalizado depois:

- **Nas entrevistas:** 3 ou mais times cuja configuração não cabe nas operações da interface
  de provider — sprint que não é sprint, etapas obrigatórias, campo próprio que trava a
  criação. Ou concentração em ferramenta que não temos (Jira, Linear, Azure Boards — C10).
- **No alpha:** o usuário abre a ferramenta de backlog na mão depois da ação, em mais de 30%
  das demandas, para consertar o que foi escrito.

Refutada, a decisão volta para a mesa com dois caminhos — e nenhum deles é "fazer um kanban
simples de qualquer jeito": tirar as ações de backlog do escopo, ou construir a manipulação
dentro do produto assumindo o custo (16, cenário 8).

## Premissas aceitas conscientemente — com quem aceitou

Registradas para não sumirem do radar:

| Premissa | Quem aceitou | Quando | Consequência aceita |
|---|---|---|---|
| A9 (voz) — aceita como **não relevante** agora | Gustavo | 2026-08-18 | voz sai do alpha; se um cliente exigir, reabrir |
| A11 (paralelismo é o ganho) — aceita como **não testável** ainda | Gustavo | 2026-08-18 | não é argumento de venda até existir produto |
| S9 (modelos futuros não dispensam a estrutura) | Gustavo | 2026-08-18 | risco de tese; sem mitigação possível, só monitoramento (16) |
| S11 (3 profissões bastam) | Gustavo | 2026-08-18 | pedido de dev/QA/dados é recusado no alpha, com resposta pronta |
| **A15 (o repositório atrai)** — aceita como **não testável agora**, e mesmo assim usada para decidir | Gustavo | 2026-08-29 | o escopo da primeira versão cresceu com base nela. Consequência aceita: risco maior de cenário 1 (16), mitigado por ondas que terminam em uso (`../MVP.md`), não por evidência |
