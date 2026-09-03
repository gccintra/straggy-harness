# 05 — JTBD + switch interviews

> **Método:** `jtbd` (L1). **Contrato:** situação/gatilho · job principal + jobs sociais e
> emocionais · dores com evidência e frequência · ganhos · alternativas em uso · o que muda
> na solução.
> **Estado:** **roteiro pronto, não executado.** Todo job abaixo é `[S]` ou `[I]`. A coluna
> "frequência" está vazia de propósito — inventá-la seria mentir.

---

## O job principal

> **Quando** chega uma demanda e eu preciso entregá-la documentada no padrão que o cliente
> aceita, **eu quero** que o trabalho saia pronto no formato certo sem depender da minha
> memória nem da minha noite, **para que** o dev comece sem voltar perguntando e o cliente
> não devolva.

Job é progresso numa situação — não é "usar uma ferramenta de PM".

## Jobs, por dimensão

| Dimensão | Job | Grau |
|---|---|---|
| **Funcional** | transformar um pedido difuso em requisito que o time consegue executar | `[I]` |
| **Funcional** | manter várias demandas avançando ao mesmo tempo sem perder o fio de nenhuma | `[I]` |
| **Funcional** | achar o contexto (regra antiga, decisão, documento) sem perguntar a quatro pessoas | `[I]` |
| **Social** | ser visto como o PM cujo documento não volta | `[S]` |
| **Social** | não ser o gargalo que trava o time inteiro | `[S]` |
| **Emocional** | parar de sentir que a qualidade depende de quanto sono eu perdi | `[S]` |
| **Emocional** | confiar no que a IA entregou sem reler linha a linha | `[S]` |

## Dores — descritas como consequência observável

| Dor | Consequência (como se observa) | Grau |
|---|---|---|
| Formatação manual | reescreve o mesmo documento no template pela enésima vez | `[I]` |
| Padrão esquecido | seção faltando descoberta na revisão do cliente | `[I]` |
| Contexto espalhado | abre 5 ferramentas para escrever 1 documento | `[F]` — 5 famílias de provider foram necessárias (`system/providers/`) |
| IA genérica | cola prompt gigante e reescreve metade da resposta | `[I]` |
| Serialização | demanda parada porque a pessoa está em outra | `[I]` |
| Onboarding | PM novo produz fora do padrão por meses | `[I]` |

## Ganhos esperados

Ordenados por quanto o cliente provavelmente paga por eles `[S]`:

1. Documento aceito **de primeira**, sem rodada de formato.
2. Qualquer pessoa do time produzindo no mesmo nível — inclusive a que entrou ontem.
3. Tempo de PM devolvido para conversa com cliente e decisão.
4. Rastro de aprovação: quem aprovou o quê, quando.

## Alternativas em uso hoje — o concorrente real

| Alternativa | Por que ainda ganha | Grau |
|---|---|---|
| **Não fazer nada** (documento na mão, no template) | funciona, é conhecida, custo é invisível porque é hora de gente | `[F]` |
| **ChatGPT/Claude avulso** + prompt colado | grátis ou barato, sem implantação; ruim para padrão, ótimo para rascunho | `[F]` |
| **ChatPRD** (US$ 15/mês) | escreve PRD bem, e só; não sabe do padrão da empresa nem do resto do fluxo | `[F]` [chatprd.ai](https://www.chatprd.ai/learn/best-ai-tools-for-product-managers) |
| **Productboard / Jira Product Discovery** | resolvem feedback e priorização de ideia, não documentação no padrão | `[F]` [Telos, 2026](https://www.telos-ai.org/blog/ai-product-management-tools-compared) |
| **Jira / Linear / Azure Boards** (o backlog em si) | **não é alternativa e não vai ser demitida.** É onde o backlog vive, e o produto opera essa ferramenta por integração (01) | `[F]` `system/providers/backlog/INTERFACE.md` |
| **Wiki + template + revisão do líder** | é o padrão da casa hoje; falha por depender de disciplina | `[I]` |

**Consequência estratégica:** a briga não é com Productboard, e muito menos com o Jira. É
com **o hábito** e com o **chat genérico**. Um produto que só é melhor que o Productboard
perde para os dois — e um produto que tenta substituir o Jira gasta a construção inteira numa
briga que não é a dele.

**O que a entrevista precisa capturar por causa disso:** não "você trocaria de ferramenta de
backlog?" (ninguém troca), e sim **quanto trabalho manual acontece entre a demanda chegar e
ela estar registrada e refinada lá dentro** — é essa fatia que o produto reivindica.

---

## Roteiro — switch interview

Objetivo: reconstruir a **linha do tempo da troca** — o que a pessoa demitiu, o que
contratou e o que a fez mudar. Nunca perguntar o que ela acha do Straggy.

Recrutamento: quem **mudou de jeito de documentar nos últimos 6 meses** (adotou IA, mudou
template, trocou ferramenta). 8–12 conversas de 40 min, dos segmentos S1 e S2 (04) — sem
filtrar por modelo de negócio.

**As quatro forças, na ordem:**

| Força | Perguntas |
|---|---|
| **1. Empurra** (dor do velho) | "Me conta a última vez que um documento seu voltou. O que aconteceu?" · "O que você fazia antes disso?" · "Por que aquilo parou de servir?" |
| **2. Puxa** (atração do novo) | "Quando você percebeu que precisava mudar?" · "O que você imaginou que ia melhorar?" · "Como você achou a alternativa que usa hoje?" |
| **3. Ansiedade** (medo do novo) | "O que te deixou com pé atrás antes de adotar?" · "O que quase te fez desistir?" · "Quem no time reclamou?" |
| **4. Hábito** (apego ao velho) | "O que do jeito antigo você **ainda** faz?" · "Por quê?" |

**Linha do tempo a reconstruir:** primeiro pensamento → evento que passou a régua → busca
ativa → decisão → primeiro uso → o que mudou de fato.

**Sinais que confirmam a tese** (padrão como sistema é o job):
- descreve o gasto de tempo com **formato**, não com conteúdo;
- cita revisão do líder como gargalo;
- já tentou template/wiki e desistiu;
- adotou IA e **abandonou** porque a saída não servia sem reescrita.

**Sinais que refutam:**
- a dor real é priorização ou stakeholder, não documento — atenção: com o recorte de escopo,
  priorização **continua** sendo trabalho nosso; o que refuta a tese é a dor estar em
  *decidir* prioridade, não em *executar e registrar* o que foi decidido;
- "não temos padrão e está tudo bem";
- reescrever a saída da IA é considerado normal e barato;
- quem revisa **gosta** de revisar — controle é o valor, não custo.

**Erros que invalidam a conversa:** apresentar o Straggy antes; perguntar "você usaria?";
aceitar generalização ("normalmente eu faço...") sem puxar o último caso concreto.
