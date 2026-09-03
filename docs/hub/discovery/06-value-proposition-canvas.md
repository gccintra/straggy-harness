# 06 — Value Proposition Canvas

> **Métodos:** `positioning` + `jtbd` (L1). **Contrato:** encaixe entre o lado do cliente
> (jobs, dores, ganhos) e o lado do produto (serviços, analgésicos, criadores de ganho) ·
> declaração de posicionamento · o que a posição obriga a não fazer.
> **Estado:** o lado do cliente vem de 05 e é `[S]`/`[I]`. O encaixe é hipótese até 07.

---

## Lado do cliente — P2, o PM de execução (04)

| Jobs | Dores | Ganhos |
|---|---|---|
| entregar demanda documentada no padrão aceito | reescrever no template, de novo | documento aceito de primeira |
| tocar 3 demandas ao mesmo tempo | demanda parada porque estou em outra | avançar várias sem perder o fio |
| achar contexto que já existe | 5 ferramentas abertas para escrever 1 documento | contexto na mão, sem caçar |
| confiar no que a IA entregou | reler linha a linha e reescrever metade | aceitar sem revisar tudo |
| não ser o gargalo | revisão do líder empilhada | autonomia sem perder qualidade |

## Lado do produto

| Serviço (o que o produto faz) | Analgésico (que dor mata) | Criador de ganho |
|---|---|---|
| **Ações de produto executáveis** — documentar, explorar, priorizar, projetar, publicar | tira o trabalho manual de formatar e classificar | trabalho sai pronto no formato, não em rascunho |
| **Encaixes por ação** — o padrão da casa declarado uma vez | mata a dependência de memória e de revisão pessoal | qualquer pessoa produz no mesmo nível |
| **Portão como estado do artefato** | mata a dúvida "posso confiar nisto?" — o passo seguinte não existe sem aprovação | confiança sem reler tudo |
| **Contexto do produto no espaço** | mata a caça em 5 ferramentas | resposta com o contexto certo, para pessoa e agente |
| **Conversas em paralelo** | mata a serialização | várias demandas avançando de fato |
| **Área fechada** — portão, formato e método fora do alcance de quem configura | mata o medo de "configurar errado e piorar" | segurança para o líder soltar a rédea |
| **Operação do backlog na ferramenta do time** — registrar, refinar, priorizar pelo funil declarado, mexer em sprint, tudo por integração | mata a digitação manual do que já foi decidido, sem pedir migração de ferramenta | o trabalho aterrissa onde o time já olha, sem quadro paralelo para manter |

## Onde o encaixe é forte — e onde não é

| Encaixe | Avaliação |
|---|---|
| padrão declarado × dor de reescrever formato | **forte** — é a razão de existir do produto |
| portão como estado × desconfiança de saída de IA | **forte e raro** — quase ninguém no mercado vende garantia estrutural |
| área fechada × medo do líder de perder controle | **forte** — vira argumento de venda, não só arquitetura |
| paralelismo × serialização | **fraco hoje** — não existe no motor, é produto novo (PRD §8.3) |
| contexto no espaço × caça em 5 ferramentas | **médio** — depende de integração funcionando bem, que é onde produto morre em silêncio |
| operar o backlog do time × ferramenta customizada de casa em casa | **desconhecido e crítico** — é a aposta do recorte de escopo (H4 em 03). Sprint, etapas de kanban e campos obrigatórios variam por time; se a integração não cobrir isso, o PM volta a abrir a ferramenta na mão e a ação vira etapa a mais. Testado em A14 (09) |

## Declaração de posicionamento

> **Para times de produto travados pelo trabalho manual entre "alguém pediu" e "o time pode
> começar"**, o **Straggy Hub** é o **sistema onde a empresa configura o próprio workflow e
> ele passa a ser executado**, que faz várias demandas avançarem ao mesmo tempo, por
> conversa, com o contexto todo no lugar — e, como consequência, sempre no jeito da casa.
>
> Diferente de **um assistente de IA acoplado ao editor** — que gera texto e devolve a
> responsabilidade do padrão para a pessoa — e diferente de **uma plataforma de agentes
> configurável** — em que configurar errado piora a saída —, no Hub **portão, formato de
> entrega e método ficam fora do alcance de quem configura**: a pior configuração possível
> ainda para no portão e ainda entrega no formato declarado.

**Prova, não adjetivo:** `../ARCHITECTURE.md` §7 — a área fechada não é regra escrita pedindo
boa fé, é ausência de campo `[F]`.

## O que esta posição obriga a não fazer

Posição que não custa nada não é escolha:

1. **Não vender "monte seu agente".** É o pedido que mais aparece em venda de IA para
   empresa — e aceitar destrói a garantia que é o diferencial.
2. **Não deixar a empresa editar portão ou formato de entrega**, nem por exceção comercial de
   contrato grande. Uma exceção transforma o produto em plataforma genérica.
3. **Não perseguir paridade de features** com Productboard/Jira Product Discovery. Feedback,
   roadmap visual e votação de ideia são outro job.
4. **Não atender quem não tem padrão nenhum** (S4 em 04): sem nada para declarar, o produto
   entrega só a metade genérica de si mesmo — e a métrica de "artefato aceito sem reescrita"
   despenca com o segmento errado. Isto é sobre comportamento, não sobre tamanho de empresa.
5. **Não prometer autonomia total.** O portão é a promessa; vender "IA que faz tudo sozinha"
   contradiz o produto e atrai o cliente que vai odiá-lo.
6. **Não construir backlog, quadro ou sprint próprios** — nem quando um cliente pedir, nem
   como "só um kanban simples". O produto opera a ferramenta que o time já tem; construir a
   nossa transforma a venda em projeto de migração e a briga em paridade com Jira, que não é
   ganhável nem interessante. **Única condição de retorno:** a integração se provar incapaz
   de cobrir a customização das ferramentas reais (A14 em 09, cenário 8 em 16) — e aí é
   decisão nova, tomada com dado, não concessão comercial.

## Contra-argumento honesto

O mercado consolidado hoje diz que **IA entrega artefato e não julgamento**, e que agentes
tornam o PM 2–3× mais efetivo cuidando dos artefatos `[F]`
([Product Leadership, 2026](https://www.productleadership.com/blog/will-ai-replace-product-managers/)).
Isso é favorável à posição — mas também significa que **quase todo concorrente vai contar a
mesma história**. A diferença defensável não é "fazemos artefato"; é **"a empresa declara o
padrão e o sistema garante que ele valha"**. Se a comunicação escorregar para a primeira, o
produto vira commodity na mesma semana.
