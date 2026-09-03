# 04 — ICP + proto-personas

> **Método:** `segmentation` (L1). **Contrato:** segmentos definidos antes de olhar
> resultado · tamanho declarado · onde o comportamento diverge · o que é exploratório.
> **Estado:** revisado em 2026-08-18 (v2). Ver "Correção de viés" abaixo — a versão anterior
> tratava um sinal de amostra 1 como evidência de mercado.

---

## Correção de viés — o que mudou e por quê

A primeira versão deste documento definia o beachhead como *"software house / consultoria
que entrega documentação sob ordem de serviço"*, sustentado por sinais do repositório:
`cliente`, `ordem_servico_padrao`, `.docx` com logo, vocabulário HU/HT.

**Isso estava errado como evidência.** Esses sinais não descrevem um mercado — descrevem o
fluxo de trabalho da pessoa que construiu o harness. Amostra 1, com viés total de origem.
Rebaixados de `[F]` para `[S]`.

| Antes | Agora |
|---|---|
| `[F]` "o harness nasceu num contexto de entrega a cliente sob ordem de serviço" → logo o mercado é esse | `[S]` "o **primeiro usuário** trabalha assim" — informação sobre um usuário, não sobre um segmento |
| segmento definido por **modelo de negócio** (consultoria × produto próprio) | segmento definido por **comportamento** (tem padrão? sofre para replicá-lo?) |
| entregável assumido como documento formal para cliente externo | entregável é o que **aquele** time consome: ticket refinado, página de wiki, documento formal — os três |

**Decisão de produto (do dono do produto, 2026-08-18):** o Hub serve **qualquer PM/PO**, não
um nicho de consultoria. O harness será generalizado para isso — lista de mudanças no fim
deste documento.

**Consequência para o discovery:** o beachhead deixa de ser afirmação e vira **pergunta que
07 responde**. Nenhum documento desta pasta pode voltar a tratá-lo como fato antes disso.

## Os segmentos — definidos por comportamento, antes de olhar resultado

O eixo que importa não é o modelo de negócio da empresa. É este:

```
                    SOFRE PARA REPLICAR O PADRÃO
                             ▲
                             │
        S3  time pequeno,    │    S1  time com padrão e rotatividade
            padrão na cabeça │        (in-house, agência, consultoria —
            de 2 pessoas     │         o modelo de negócio é indiferente)
                             │
   ──────────────────────────┼──────────────────────────►  TEM PADRÃO A DECLARAR
                             │
        S4  time sem padrão  │    S2  PM solo/dupla com método
            e sem intenção   │        próprio forte
            de ter           │
                             │
```

| Seg | Quem é | Dor dominante | Paga? | Veredito |
|---|---|---|---|---|
| **S1** | 3+ pessoas de produto, padrão existe (escrito ou tácito), gente entra e sai | **replicação** — o padrão não sobrevive a quem chega | tem verba de ferramenta `[S]` | **candidato a beachhead** |
| **S2** | PM/PO sozinho ou em dupla, com jeito próprio consolidado | **volume** — quer fazer mais, do mesmo jeito | cartão pessoal ou verba pequena `[S]` | segundo alvo; valida rápido, ticket baixo |
| **S3** | 2–3 pessoas, padrão implícito e funcional | nenhuma aguda — a conversa resolve | pouca | fora |
| **S4** | sem padrão e sem intenção de ter | não existe dor a atender | — | **fora** — não há o que declarar |

**S1 e S2 atravessam modelos de negócio.** Um squad de produto próprio numa fintech de 200
pessoas e uma consultoria de 8 PMs podem estar os dois em S1 — o que os coloca lá é
rotatividade + padrão existente, não para quem entregam.

## Por que S1 é a hipótese de beachhead

Três razões, todas marcadas como hipótese:

1. `[S]` A dor de replicação é a única que **cresce com o tempo** — cada pessoa nova a
   reforça. Dor que cresce vira orçamento; dor estável vira convivência.
2. `[S]` É o único segmento em que existe alguém com o papel de **manter o padrão** (P3
   abaixo) — ou seja, alguém para quem "declarar o padrão uma vez" é o trabalho, não uma
   tarefa extra.
3. `[I]` É onde a promessa "qualquer pessoa produz no mesmo nível" tem valor mensurável —
   nos outros segmentos, "qualquer pessoa" é a mesma pessoa.

**O que derruba S1 como beachhead:** se 07 mostrar que times com padrão já resolveram a
replicação por outros meios (revisão em par, checklist no template, cultura) e a dor real é
**volume**, o beachhead vira S2 — e isso muda preço, canal e a fatia do alpha.

## Critérios de qualificação — comportamentais, verificáveis numa conversa

| Sinal | Qualifica |
|---|---|
| existe um "jeito certo" de documentar **e** alguém reclama que ninguém segue | forte |
| entrou pessoa de produto nova nos últimos 6 meses | forte |
| a revisão de alguém sênior é gargalo reconhecido | forte |
| já tentaram template/wiki/checklist e não pegou | forte |
| usa backlog estruturado e documenta requisito de alguma forma | necessário |
| **tem uma ferramenta de backlog com API** (Jira, Linear, Azure Boards, GitHub/GitLab) | **necessário** — o produto opera a ferramenta do time, não substitui: sem ela conectável, metade das ações não aterrissa (01) |
| **Desqualifica:** não documenta requisito · não tem padrão e não quer ter · exige on-premise no dia 1 | — |

Nenhum critério menciona modelo de negócio, tamanho de empresa ou tipo de entregável — de
propósito. Foi exatamente aí que a v1 errou.

## Proto-personas

Reescritas sem o pressuposto de cliente externo. Continuam `[S]` — proto-persona vira
persona depois de 07.

### P1 — Líder de produto (comprador econômico)

Head de produto, GPM, coordenador, sócio — o cargo muda com a empresa, o papel não.

| | |
|---|---|
| **Situação** | responde pela qualidade do que 3–15 pessoas produzem |
| **Job principal** | garantir que a entrega de qualquer pessoa do time esteja no nível, sem revisar tudo |
| **Dor** `[I]` | virou gargalo de revisão; quando não revisa, a qualidade oscila |
| **Como decide** | custo de retrabalho e risco de erro pesam mais que preço da ferramenta |
| **Diz não quando** | "meu time não vai usar" · "não confio no que a IA escreve" |
| **Frase provável** `[S]` | *"não preciso que escreva mais rápido, preciso que saia igual"* |

### P2 — PM/PO de execução (usuário diário)

| | |
|---|---|
| **Situação** | 2–4 demandas em paralelo, agenda tomada por reunião |
| **Job principal** | tirar a demanda da cabeça de alguém e deixá-la pronta para o time começar |
| **Dor** `[I]` | reescreve no formato o que já sabia escrever; descobre seção faltando na revisão |
| **Como avalia** | o primeiro artefato. Se precisar reescrever, abandona |
| **Diz não quando** | "mais uma ferramenta para alimentar" · perda de controle sobre o texto |
| **Risco** | pode sabotar a adoção que P1 comprou |

### P3 — Mantenedor do padrão (configurador)

Muitas vezes é o P1; em time maior, é o PM mais antigo ou alguém de operações de produto.

| | |
|---|---|
| **Job** | declarar o jeito da casa uma vez e parar de repeti-lo em cada revisão |
| **Dor** `[I]` | escreveu o guia; ninguém abre |
| **Sucesso** | muda o padrão e vê o efeito na próxima entrega |
| **Risco** | se configurar for difícil, a tese do produto (A2) morre na largada |

## Onde o comportamento diverge do agregado

- **P1 compra, P2 usa, e os critérios são opostos.** P1 quer uniformidade; P2 quer
  autonomia. Este continua sendo o principal risco de adoção — mais que preço.
- **S1 e S2 querem produtos diferentes.** S1 quer padrão replicável e trilha de aprovação;
  S2 quer velocidade e não tem com quem compartilhar padrão. Roadmap que serve aos dois
  serve mal aos dois.
- **O destino do trabalho varia por time, não por segmento.** Uns publicam no backlog,
  outros na wiki, outros num documento formal. O produto precisa tratar destino como
  configuração, nunca como pressuposto — foi o que a v1 assumiu errado.
- **A ferramenta de backlog varia, e a configuração dela varia mais ainda.** Dois times na
  mesma ferramenta usam modelos de sprint diferentes, etapas de kanban próprias e campos
  obrigatórios inventados por eles. Isso não separa segmento — atravessa todos, e é o custo
  escondido da decisão de operar o backlog por integração em vez de ter um próprio (A14 em
  09). Qualificar por "tem ferramenta" é fácil; o que precisa ser medido em 07 é **quanto**
  ela foi customizada.

## Tamanho — declarado, sem precisão falsa

População global de PMs: **~1,06 milhão** (LinkedIn, 2023) a **~2,4 milhões** (estimativa
pública, 2024) — divergência de 2× na própria definição do cargo `[I]`
([CPO Club, 2026](https://cpoclub.com/career/statistics-career-product-management/)). Com o
alvo sendo **qualquer PM/PO**, o teto é essa população inteira; o que não existe é número
confiável para S1 e S2 separadamente. Número único aqui viraria argumento de autoridade sem
auditoria.

## Implicações para o harness — o que precisa deixar de ser "o fluxo do autor"

Levantado no repositório em 2026-08-18 `[F]`. Nenhuma destas é feature: são vazamentos de
instância na camada errada, pelo próprio teste do pack (`../ARCHITECTURE.md` §3).

| Onde | O que está preso ao fluxo de origem | Generalização |
|---|---|---|
| `project-config.template.yaml` | `cliente`, `ordem_servico_padrao` como campos de primeira classe | virar campos opcionais de um bloco de contexto, ou encaixe da organização — time in-house não tem cliente nem OS |
| `project-config.template.yaml` | `label_header_hu` / `label_header_ht` fixos em "HISTÓRIA DE USUÁRIO/TÉCNICA" | tipos de artefato declarados pela organização; "HU/HT" é vocabulário de uma casa |
| `project-config.template.yaml` | `token_arquivo` no padrão `{HU\|HT}{ID}_{TOKEN}_{Nome}` | convenção de nome vira encaixe, com padrão simples de fábrica |
| `system/pack/workflows/doc-final-generator` · `prototype-prints` | `.docx` como destino assumido na descrição | destino é escolha da organização: documento, wiki ou só backlog |
| `system/pack/workflows/prototype-prints/SKILL.md` | subpasta por "HU" no procedimento | referir "demanda", nunca o tipo de artefato de uma casa |
| `system/pack/org-scaffold/ORG.md` | identidade assumindo cliente/sigla/logo | scaffold neutro; identidade de cliente é opcional |

**Efeito no discovery:** enquanto isso não mudar, qualquer teste feito com times sem cliente
externo mede o produto errado — o time vai esbarrar em campos que não fazem sentido para
ele e concluir que a ferramenta é de consultoria. Isto é **pré-requisito do alpha**, não
melhoria (19).
