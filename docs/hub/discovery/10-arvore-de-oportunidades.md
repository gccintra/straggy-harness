# 10 — Árvore de oportunidades

> **Método:** `opportunity-solution-tree` (L1). **Contrato:** outcome mensurável no topo ·
> oportunidades com evidência · soluções por oportunidade · experimento escolhido, o que ele
> decide e o que faria abandonar.
> **Estado:** revisada em 2026-08-18 (v3). O outcome mudou de *qualidade do artefato* para
> **velocidade do ciclo**, com qualidade como contrapeso. A árvore inteira foi reordenada.

---

## Outcome

**Tempo de ciclo da demanda — de "chegou" a "pronta para o time começar" — e quantas
demandas a mesma pessoa conclui por semana.**

Baseline desconhecido; não instrumentado hoje.

**Contrapeso declarado, obrigatório:** % de entregas aceitas sem retrabalho. Se o ciclo
encurta e a aceitação cai, não houve ganho — houve transferência de trabalho para a revisão.
Um número sem o outro mente (`product-metrics`).

## A árvore

```
OUTCOME  tempo de ciclo ↓  ·  demandas concluídas por pessoa ↑
CONTRAPESO  % aceito sem retrabalho não cai
   │
   ├── O1  "perco tempo procurando o que já existe"                      [F]
   │      ├── S1.1  contexto do produto no espaço, para pessoa e agente  ← desenhado
   │      ├── S1.2  integrações de backlog, conhecimento, banco          ← existe
   │      │         (leitura: a demanda e o histórico entram como contexto)
   │      ├── S1.3  busca no histórico de decisões do espaço             ← novo
   │      ├── S1.4  estruturas de produto viram ação e artefato          ← parcial
   │      │         (roadmap, OKR, personas, lean canvas, story map:
   │      │          86 estruturas existem como método; nenhuma delas
   │      │          tem ação no catálogo nem vira artefato do espaço)
   │      └── S1.5  sincronização com Drive, somente leitura             ← novo
   │
   ├── O2  "refaço o mesmo procedimento manual em toda demanda"          [I]
   │      ├── S2.1  ação executando o procedimento declarado             ← existe
   │      ├── S2.2  encaixes: como fazer, estrutura, classificação       ← existe
   │      ├── S2.3  saída aterrissando no destino que o time usa         ← existe
   │      └── S2.4  backlog e sprint operados na ferramenta do time       ← existe
   │                (registrar, refinar, priorizar pelo funil, mexer em
   │                 sprint — por integração, com portão antes da escrita;
   │                 sem backlog próprio: decisão de escopo, 00 v4)
   │
   ├── O3  "só avança uma demanda por vez, e só quando estou nela"       [I]
   │      ├── S3.1  conversas em paralelo, várias demandas               ← novo
   │      ├── S3.2  trabalho assíncrono agendado                         ← novo
   │      └── S3.3  notificação quando algo entra em espera de revisão   ← novo
   │
   ├── O4  "cada passo é operar ferramenta, não pedir trabalho"          [I]
   │      ├── S4.1  conversa como interface, ação reconhecida pelo pedido ← desenhado
   │      ├── S4.2  cobertura do catálogo de ações                       ← existe (22)
   │      └── S4.3  escrita externa com preview, em um clique            ← desenhado
   │
   ├── O5  "o que a IA entrega volta para eu reescrever"                 [I]
   │      ├── S5.1  procedimento e formato declarados pela empresa       ← existe
   │      ├── S5.2  contrato de saída fora do alcance de quem configura  ← existe
   │      └── S5.3  citação de fonte no que foi afirmado                 ← existe
   │
   ├── O6  "não confio o bastante para deixar rodar sozinho"             [S]
   │      ├── S6.1  portão como estado do artefato                       ← desenhado
   │      ├── S6.2  trilha de quem aprovou o quê                         ← desenhado
   │      └── S6.3  medição de aceitação por espaço                      ← novo
   │
   └── O7  "demanda com tela para até alguém desenhar a solução"         [I]
          ├── S7.1  brief da tela a partir da demanda                    ← existe
          ├── S7.2  construção da tela como protótipo navegável          ← existe
          ├── S7.3  prints do protótipo alimentando a documentação       ← existe
          └── S7.4  publicação do protótipo para validar com terceiros   ← existe
```

`← existe` = capacidade do motor (PRD §8.1) · `← desenhado` = §8.2 · `← novo` = §8.3.

## O que mudou de lugar com o novo outcome

Score e ordem mudam quando o outcome muda — não é inconsistência, é o método funcionando:

| Oportunidade | Antes (outcome = qualidade) | Agora (outcome = velocidade) |
|---|---|---|
| **Contexto único** (O1) | "médio", depois | **primeiro** — é o custo de tempo mais direto e tem a evidência mais forte |
| **Paralelismo e assíncrono** (O3) | cortado do alpha | **candidato central** — é o único mecanismo que quebra a serialização |
| **Conversa como interface** (O4) | meio da fila | sobe: cada clique economizado é ciclo |
| **Padrão/formato** (O2, O5) | era o topo | continua essencial, agora como **mecanismo**, não como fim |
| **Confiança/portão** (O6) | diferencial de venda | vira **pré-requisito da velocidade**: sem confiança, ninguém deixa rodar, e o ganho não se realiza |

## Evidência por oportunidade

| # | Evidência | Grau |
|---|---|---|
| O1 | 5 famílias de provider foram necessárias só para juntar contexto | `[F]` |
| O2 | o harness existe para tornar procedimento executável; ganho não medido | `[I]` |
| O3 | relato próprio; nenhuma medição de quanto a serialização custa | `[I]` |
| O4 | prática corrente; sem medição de quanto tempo vai em operar ferramenta | `[I]` |
| O5 | consenso público de que IA entrega artefato, não julgamento | `[I]` |
| O6 | que desconfiança **trave** a delegação é hipótese não testada | `[S]` |
| S2.4 | a interface de provider já abstrai as operações (listar, criar, atualizar, comentar, fechar, sprint) e roda com GitHub e GitLab; que ela **cubra a customização real** de cada time é aposta não testada (A14 em 09) | `[F]` para a mecânica, `[S]` para a cobertura |
| O7 | a esteira do sistema já declara que demanda com interface documenta **depois** do protótipo validado — o protótipo é caminho crítico do ciclo, não etapa paralela | `[F]` (`system/ACOES.md`, `requer_condicional`) |

## Correção v5 — O1 deixou de ser oportunidade adiada

Este ramo tem a evidência mais forte da árvore (`[F]`) e mesmo assim ficou fora das primeiras
versões em 14, 17 e 18. O motivo era **facilidade**, nunca lastro — e o próprio 14 registra
isso como anomalia do modelo, não como julgamento. Em 2026-08-29 a decisão foi bancar o
esforço: S1.0, S1.1, S1.4 e S1.5 entram na primeira versão (`../MVP.md`, grupos F e G).

Consequência honesta: **o ramo com a melhor evidência é também o mais caro**, e promovê-lo
aumenta o risco de morrer construindo (16, cenário 1). Isso não se resolve por argumento —
resolve-se por ondas que terminam em uso, e por manter o teste de A1 rodando em paralelo.

**A lacuna mais séria:** nenhuma das oportunidades tem **quanto tempo custa hoje**, por
etapa. Sem isso, "acelerar o ciclo" é promessa sem denominador — e a primeira pergunta de
qualquer comprador é "quanto mais rápido?". Instrumentar isso é o item mais barato e mais
urgente do discovery (07, bloco 1).

## Fronteira do paralelismo — restrição de arquitetura, não preferência

A constituição do sistema exige **um pedido = um passo** e proíbe colapsar portão
(`system/CONSTITUTION.md` §5). Logo:

| Paralelizar | Permitido? |
|---|---|
| **entre demandas** — 4 demandas correndo, cada uma no seu estágio | **sim**; é a fonte do ganho |
| **escrever no backlog do time sem aprovação** (registrar, atualizar, fechar item) | **não**. É escrita externa: passa por preview e clique, como qualquer outra (18, F21) |
| **entre ações independentes** da mesma demanda (consultar dados enquanto o discovery corre) | sim, se nenhuma depende da aprovação da outra |
| **dentro da cadeia de portões** de uma demanda (gerar entregável antes de o documento ser aprovado) | **não**. Isto não é lentidão, é a garantia |

Escrever esta fronteira agora evita o cenário 2 do pré-mortem: velocidade comprada às custas
do portão é exatamente o que destrói o produto.

## Caminho escolhido: O1 + O2 juntos, com O4 como interface

Critério: maior evidência × menor construção × mais próximo do dinheiro.

- **O2 já está inteiro no motor.** É o único ramo vendável hoje, sem construir nada.
- **O1 é a evidência mais forte** e a metade dele existe (integrações); falta o espaço.
- **O3 é a maior aposta de velocidade e a mais cara** — e não dá para provar sem produto de
  pé. Fica como segunda onda, não como corte definitivo (mudança em relação à v2).
- **O6 não é feature de venda; é o que permite O3 acontecer.** Sem confiança, ninguém deixa
  quatro demandas rodando.

## Experimento escolhido

| | |
|---|---|
| **Hipótese** | se um time executar as próximas 10 demandas pelo workflow configurado dele, então o tempo de ciclo por demanda cai ≥ 40% **sem** queda na aceitação |
| **Métrica de decisão** | tempo de ciclo por demanda (medido antes e depois, mesmo time) |
| **Contrapeso** | % aceito sem retrabalho — não pode cair |
| **Sucesso** | ciclo −40% ou mais, aceitação estável ou melhor |
| **Parada** | ciclo cai < 15% nas primeiras 5 demandas: o gargalo não é o que achamos, e a árvore muda no topo |
| **Desenho** | operado por nós com o motor atual; medir **antes** é parte do teste, não detalhe |
| **O que abandonaria o caminho** | ciclo cai, mas o tempo migra inteiro para a revisão — o gargalo era decisão humana, não execução, e o produto certo é outro |
