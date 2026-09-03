# 01 — Visão do produto

> **Método:** `product-vision` (L1). **Contrato:** para quem · que mundo · por que importa ·
> o que a visão exclui · primeiro passo já em curso.
> **Estado:** revisada em 2026-08-29 (v4) — recorte de escopo: gestão de backlog sai do
> produto e vira integração. A v3 (2026-08-18) já havia invertido o destino: a v1 e a v2
> colocavam **padronização** como destino, e padrão é consequência de ter o workflow
> configurado. O destino é **velocidade de entrega com resultado aproveitável**.

---

## A visão

**Para times de produto, o trabalho passa a acontecer na velocidade da conversa: a empresa
configura como trabalha, e as entregas saem — várias ao mesmo tempo, com o contexto todo no
lugar, sem ninguém operar ferramenta.**

Hoje o ciclo de uma demanda é lento por motivos que não têm nada a ver com pensar: caçar
contexto em cinco lugares, formatar, lembrar do padrão, esperar a vez de quem sabe fazer,
repetir o mesmo trabalho manual em cada demanda. A parte difícil — decidir — é minoria do
tempo.

No mundo mudado, a pessoa **pede** e acompanha. O trabalho roda: em paralelo, com o
contexto do produto disponível, no jeito que aquela empresa configurou. O julgamento
continua humano, nos portões. O que desaparece é a operação.

## Por que importa

1. **O gargalo do time de produto deixa de ser a mão de obra.** Quatro demandas avançam com
   a mesma pessoa. Capacidade deixa de ser função de quantos PMs a empresa contratou.
2. **O tempo volta para o que só humano faz.** Conversar com cliente, decidir escopo,
   negociar. O resto é execução.
3. **A padronização vem de graça.** Não porque alguém obedeceu o template — porque o
   trabalho passa pelo workflow que a empresa declarou. Padrão vira efeito colateral da
   configuração, não disciplina cobrada em revisão.

## O que a visão exige que seja verdade

Quatro mecanismos. Nenhum deles é opcional — tirar qualquer um derruba a velocidade e
devolve o trabalho para a pessoa:

| Mecanismo | O que ele resolve |
|---|---|
| **Workflow declarado** | o jeito da casa vira execução, não instrução que alguém precisa seguir |
| **Contexto único** | nada de caçar regra, decisão ou documento em cinco ferramentas |
| **Conversa como interface** | pedir em vez de operar; ninguém aprende ferramenta |
| **Paralelismo e trabalho assíncrono** | várias demandas correndo, e coisas que rodam sem alguém estar olhando |

E duas **consequências** — que são o que separa isto de "IA que escreve rápido":

| Consequência | De onde vem |
|---|---|
| **Padrão uniforme** | do workflow declarado: sai assim porque foi executado assim |
| **Resultado confiável** | dos portões: nada avança sem aprovação, nada é escrito fora do rascunho sem preview |

## O que esta visão exclui

| Caminho excluído | Por quê |
|---|---|
| **Velocidade sem resultado aproveitável** | rascunho rápido que alguém reescreve não acelerou nada — só mudou quem digita. É o modo de falha número um desta visão |
| **Assistente acoplado ao editor** | a pessoa continua operando; o ganho é marginal e o padrão continua fora do sistema |
| **Suíte de gestão de trabalho** | organizar trabalho não é executá-lo |
| **Backlog, quadro, sprint e estado de entrega próprios** | o mercado de gestão de backlog já é bem servido por ferramentas focadas só nisso, e o time já paga por uma. Duplicá-la custa construção, custa migração e não encurta ciclo nenhum |
| **Plataforma de agentes genérica** ("monte seu agente") | devolve ao cliente o trabalho que ele não sabe fazer e transfere a qualidade para quem configurou |
| **Ferramenta de execução técnica** (código, QA, infra) | outra profissão, outro comprador |
| **Autonomia sem portão** | velocidade comprada tirando o humano do caminho é a única que o cliente-alvo recusa |

Cada exclusão custa receita de curto prazo. É o que a torna escolha e não slogan.

## A fronteira: o que é nosso e o que é da ferramenta do time

A exclusão do backlog **não** tira trabalho do catálogo. Priorizar, refinar, registrar
demanda, abrir e fechar sprint continuam sendo rotina de PM/PO, e o sistema continua fazendo
esse trabalho — só que **na ferramenta onde o backlog já vive**, por integração e com portão
antes de qualquer escrita.

| | O produto | A ferramenta do time |
|---|---|---|
| **Onde mora** | estratégia, documento, contexto do projeto, procedimento declarado | issue, sprint, quadro, estado de entrega |
| **Quem é dono do dado** | o espaço | a ferramenta externa; nós lemos e escrevemos, não guardamos |
| **O que o sistema faz** | decide, escreve, consolida, prioriza pelo funil declarado | recebe o resultado por integração, com preview e aprovação |

**A aposta que isso embute** `[S]`: que operar a ferramenta do time por integração seja tão
bom quanto — ou melhor que — abrir a ferramenta na mão. Ferramenta de backlog é heterogênea:
modelo de sprint, etapas de kanban e campos mudam de casa para casa. Se a experiência
integrada não se sustentar, a decisão de manipular backlog dentro do produto **volta para a
mesa** (premissa A14 em 09, cenário 8 em 16, retorno declarado em 18).

## O primeiro passo — já em curso

O motor executa trabalho de produto hoje: 22 ações nomeadas, 86 métodos, esteira de 6
artefatos com portão entre eles, customização por encaixe que não alcança portão nem
contrato de saída `[F]` (`system/ACOES.md`, `../ARCHITECTURE.md` §7).

Dos quatro mecanismos, **um está pronto** (workflow declarado), **um está parcial**
(contexto único — as integrações existem, o espaço compartilhado não), e **dois não
existem** (conversa como interface do produto, paralelismo). Ver PRD §8.

## Sinais de que a visão está errada

- O ciclo **não encurta** na prática: o tempo sai da execução e vai inteiro para a revisão.
  Nesse mundo, o portão é o gargalo e a promessa não se sustenta.
- Times aceleram, e a qualidade cai junto — velocidade era ilusão de throughput.
- Ninguém configura nada e o padrão de fábrica basta: o produto é um agente bom, sem fosso.
- Modelos ficam bons o bastante para entregar no padrão certo só com contexto bruto. Aí a
  camada de configuração vira overhead e o valor migra para portão, estado e colaboração.
