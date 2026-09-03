# 03 — Lean Canvas

> **Método:** `lean-canvas` (L1). **Contrato:** blocos com nível de confiança · as três
> hipóteses mais arriscadas · teste mais barato para a mais arriscada.
> **Estado:** canvas é conjunto de hipóteses. A saída válida daqui é a fila de teste (09),
> não um plano.

---

## 1. Problema

`[I]` As três dores, em ordem de intensidade observada (02, v3):

1. **Ciclo lento e serial** — entre "alguém pediu" e "o time pode começar" há horas de
   trabalho manual que só uma pessoa por vez consegue fazer.
2. **Contexto espalhado** por 5+ ferramentas; ninguém, nem a IA, tem a visão inteira.
3. **Procedimento não executável** — vive em template e na cabeça, então é refeito à mão em
   toda demanda, e diferente por cada pessoa.

**Alternativas em uso hoje** `[F]`: template + revisão manual · ChatGPT/Claude avulso com
prompt colado à mão · ChatPRD (US$ 15/mês, PRD específico, [chatprd.ai](https://www.chatprd.ai/learn/best-ai-tools-for-product-managers))
· Productboard/Jira Product Discovery para feedback e priorização · **não fazer nada** — que
é o concorrente mais forte.

**O que não é alternativa** `[F]`: Jira, Linear, Azure Boards, GitHub/GitLab Issues. Elas
guardam o backlog e continuam guardando — o produto **opera** essas ferramentas por
integração, não compete com elas (01). Trocar o cliente de ferramenta de backlog não está no
escopo, e nenhuma hipótese deste canvas depende disso acontecer.

## 2. Segmento de clientes

`[S]` **Alvo do produto:** qualquer PM/PO. **Hipótese de entrada:** time com padrão
existente que sofre para replicá-lo quando entra gente nova (S1 em
[04](04-icp-proto-persona.md)) — recorte por comportamento, não por modelo de negócio.

**Early adopter:** o PM/PO sênior ou líder de produto que já mantém um "jeito certo" e sofre
para replicá-lo no time.

## 3. Proposta de valor única

`[S]` **A empresa configura como trabalha — e as entregas passam a sair na velocidade da
conversa, várias ao mesmo tempo, já no jeito da casa.**

Frase de teste ("high concept"): *seu workflow, executado.*

**A distinção que a mensagem não pode perder:** velocidade sozinha é a alegação mais comum
do mercado e compete de frente com chat genérico. O que se vende aqui é **velocidade cujo
resultado é aproveitável** — sai pronto, não sai rascunho. Se a comunicação escorregar para
"mais rápido", o produto vira commodity (06).

## 4. Solução

`[F]` para o que já existe, `[S]` para o resto:

| | |
|---|---|
| `[F]` | catálogo de ações de produto executáveis (documentar, explorar, priorizar, projetar, publicar) |
| `[F]` | as ações que tocam backlog e sprint executam **na ferramenta do time**, pela interface de provider (`system/providers/backlog/INTERFACE.md`) — sem backlog próprio |
| `[F]` | customização por encaixe — a empresa preenche campos, nunca alcança portão nem formato de entrega |
| `[F]` | esteira de artefatos com portão humano obrigatório |
| `[S]` | espaço compartilhado, conversa como interface, estado visível para o time |

## 5. Canais

`[S]` Ordem proposta, do mais barato ao mais caro:

1. **Conteúdo técnico de produto** — a tese ("padrão como sistema") é o conteúdo; público de
   PM lê e compartilha.
2. **Venda direta consultiva** na hipótese de entrada — poucas contas, ticket alto; o ciclo
   depende de a dor de replicação já ter dono declarado dentro do time.
3. **Indicação dentro de comunidades de produto** — mercado conversado, onde padrão de
   trabalho já é assunto.
4. `[S]` Autosserviço só depois que o produto sobreviver sem acompanhamento.

## 6. Fluxo de receita

`[S]` Hipótese inicial: **por espaço ativo + por volume de trabalho executado**, não por
assento. Justificativa: paralelismo faz o custo crescer por demanda, não por pessoa — e
cobrar por assento pune exatamente o comportamento que o produto quer criar.

> **Correção de 2026-08-29 — o MVP muda a premissa desta hipótese.** Com o cliente trazendo
> a própria chave de IA (`../MVP.md`), **a inferência sai da nossa conta**: o custo deixa de
> crescer com o volume executado, e cobrar por volume perde a justificativa que a tinha
> escolhido. O que o cliente paga passa a ser explicitamente **o workflow declarado, o
> repositório de contexto e o portão** — não a geração. A faixa a testar continua `[S]`, mas
> a *unidade* de cobrança volta a ser pergunta aberta (D2b em 08), e o cenário 4 do
> pré-mortem (margem invertida) deixa de valer enquanto a chave for do cliente.

Âncoras de mercado `[F]`: Jira Product Discovery US$ 10–25 por criador/mês, contribuidor
grátis ([UserJot, 2026](https://userjot.com/blog/jira-product-discovery-pricing)) · ChatPRD
US$ 15/mês · Featurebase US$ 29/usuário/mês. **O Hub não compete nessa faixa**: substitui
horas de trabalho de produto, não um editor. Faixa a testar: `[S]` US$ 200–800 por espaço/mês.

## 7. Estrutura de custos

`[S]` Dominada por **inferência**, não por infraestrutura. Consequência direta: a economia
unitária depende de quantas execuções uma conta faz por mês, e o preço precisa acompanhar
volume ou a margem inverte com o cliente mais engajado — exatamente o pior incentivo
possível. Ver [16](16-pre-mortem.md), cenário 4.

## 8. Métricas-chave

`[S]` Ligadas ao modelo, não à vaidade:

| Métrica | Por que ela e não outra |
|---|---|
| **Tempo de ciclo da demanda** (farol) | é a promessa central da v3: de "chegou" a "pronta para o time começar" |
| **Demandas concluídas por pessoa/semana** | mede throughput, que é o que o comprador sente |
| **Ações executadas por espaço/semana** | unidade de valor e de custo ao mesmo tempo |
| **Contrapeso: % aprovado sem reescrita** | se cair enquanto o ciclo encurta, a velocidade é ilusória — o trabalho migrou para a revisão |
| **% de espaços com ≥ 1 encaixe preenchido** | mede se a tese de "padrão da empresa" é real |
| **Contrapeso: portões aprovados sem leitura** | aprovação em massa significa que o portão virou clique — o produto estaria mentindo sobre a garantia |

## 9. Vantagem competitiva

`[I]` **Honestamente: ainda não temos fosso duradouro.** O que temos:

- **Real hoje:** a arquitetura de camadas em que a customização **não consegue** degradar
  portão, formato de entrega e método (`../ARCHITECTURE.md` §7). Concorrente que começou por
  template de prompt não chega nisso sem reescrever o produto.
- **Real hoje:** repertório de 86 métodos e 22 ações já em operação, com procedimento
  testado em uso real.
- **Potencial, não realizado:** o acúmulo do padrão declarado por cada empresa. Quanto mais
  a empresa configura, mais caro fica sair. Hoje isso é hipótese — nenhuma empresa
  configurou nada.
- **Não temos:** marca, distribuição, dado proprietário, efeito de rede.

## As três hipóteses mais arriscadas

| # | Hipótese | Se for falsa |
|---|---|---|
| **H1** | Existe empresa disposta a **pagar** para ter o padrão dela executado por IA — o problema é caro o bastante para virar orçamento | não há negócio; há projeto interno |
| **H2** | A empresa **realmente configura**. Preenche encaixe, declara funil, ajusta formato | o produto vira mais um gerador de artefato genérico, sem fosso |
| **H3** | O artefato gerado é **aceito sem reescrita** com frequência alta o bastante para o portão não virar teatro | o usuário reescreve tudo e o Hub só adicionou uma etapa |

**A quarta, que entra com o recorte de escopo de 2026-08-29** — menor risco de negócio, alto
risco de produto: **H4 — operar o backlog do time por integração é bom o bastante para o PM
não voltar a abrir a ferramenta na mão.** Se for falsa, ou o produto perde as ações de
backlog e sprint, ou reabre a construção de backlog próprio, que é justamente o que este
recorte tirou da mesa. Testada como A14 (09), vigiada no cenário 8 (16).

## Teste mais barato para a mais arriscada (H1)

**Não é protótipo. É oferta.**

Levar a 8 empresas do beachhead uma proposta concreta — "declaramos o padrão de vocês e
entregamos os requisitos das próximas 10 demandas nele; US$ X por mês" — usando o motor que
**já roda hoje** por linha de comando, operado por nós. Sem construir uma tela.

- **Métrica de decisão:** contratos assinados / propostas apresentadas.
- **Sucesso:** ≥ 3 de 8 pagam. **Parada:** 0 de 8 após a quinta conversa — o problema não é
  orçamentável e a tese muda antes de qualquer código.
- **O que isso não decide:** H2 e H3 (nós operando não prova que o cliente configura nem que
  o artefato passa sem nós).
