# 02 — Árvore de problemas

> **Método:** `problem-framing` (L1). **Contrato:** problema em 1-2 frases · causa raiz ·
> evidência · non-goals · critério de sucesso.
> **Estado:** revisado em 2026-08-18 (v3). A v1/v2 enquadravam o problema como *falta de
> padrão*. Padrão é sintoma e consequência; o problema é **ciclo lento e serial**.

---

## Problem statement

**O ciclo de uma demanda de produto é lento e serial: entre "alguém pediu" e "o time pode
começar" existem horas de trabalho manual — caçar contexto, formatar, lembrar do padrão,
repetir o mesmo procedimento — que só uma pessoa por vez consegue fazer, porque o jeito de
fazer mora nela.**

## A árvore

```
                          EFEITOS (o que dói e é visível)
   ┌──────────────┬──────────────┬───────────────┬───────────────┬──────────────┐
  demanda        capacidade     entrega         PM vira        IA usada gera
  parada na      do time =      inconsistente   operador de    rascunho que
  fila do PM     nº de PMs      entre pessoas   ferramenta     alguém reescreve
   └──────────────┴──────┬───────┴───────────────┴───────────────┘
                         │
                  PROBLEMA CENTRAL
   O ciclo é lento e serial: cada demanda depende de trabalho manual
   de uma pessoa que carrega contexto e procedimento na cabeça
                         │
   ┌──────────────┬──────┴───────┬───────────────┬──────────────┐
 CAUSA 1        CAUSA 2         CAUSA 3         CAUSA 4        CAUSA 5
 contexto       procedimento    interface       nada roda      IA genérica
 espalhado      não é           é ferramenta,   sozinho:       não conhece
 por 5+         executável:     não pedido:     tudo espera    contexto nem
 ferramentas    vive em         cada passo é    alguém         procedimento
                template/wiki   clique manual   iniciar
                e na cabeça
                         │
                  CAUSA RAIZ
   Não existe camada onde o workflow da empresa seja configurado uma vez
   e executado sempre. Todo mecanismo disponível hoje é documento
   (depende de disciplina) ou código (depende de engenharia).
```

**A padronização não é a causa nem o efeito principal — é o subproduto.** Quando o
procedimento não é executável (causa 2), duas coisas acontecem juntas: o trabalho fica lento
*e* sai diferente a cada pessoa. Atacar só a segunda produz template novo; atacar a causa
resolve as duas.

## Causas, uma a uma

| # | Causa | Efeito no ciclo | Evidência | Grau |
|---|---|---|---|---|
| 1 | **Contexto espalhado** | minutos a horas por demanda só localizando o que já existe | 5 famílias de provider foram necessárias para juntar contexto — `system/providers/` | `[F]` |
| 2 | **Procedimento não executável** | o mesmo trabalho refeito à mão em toda demanda; e refeito diferente por cada pessoa | o harness inteiro existe para tornar procedimento executável | `[I]` |
| 3 | **Interface é ferramenta, não pedido** | cada passo custa cliques, telas e memória de onde fica o quê | prática corrente | `[I]` |
| 4 | **Nada roda sem alguém iniciar** | trabalho assíncrono (checagem, consolidação, relatório) só acontece quando alguém lembra | motor atual: toda ação é disparada por pedido `[F]` | `[F]` |
| 5 | **IA genérica sem contexto nem procedimento** | acelera o rascunho e devolve o retrabalho | consenso público: agentes entregam artefato, não julgamento — [Product Leadership, 2026](https://www.productleadership.com/blog/will-ai-replace-product-managers/) | `[F]` |

## Sintomas tratados como causa

| Sintoma | Por que não é a causa |
|---|---|
| "falta padronização" | é consequência de 2. Template novo não muda o tempo de ciclo — e é por isso que times trocam de wiki sem melhorar nada |
| "falta uma ferramenta melhor" | trocar de editor não tira trabalho manual do caminho |
| "falta gente" | contratar resolve o sintoma pelo preço mais alto disponível; a serialização continua |
| "a IA ainda não é boa o bastante" | o modelo já é bom; o que falta a ele é contexto e procedimento — 1 e 2 |

## Non-goals

- **Falta de decisão.** O sistema expõe mais rápido; não decide.
- **Time que não quer configurar nada.** Sem workflow declarado, entrega-se metade genérica.
- **Qualidade da execução técnica.** Requisito melhor não conserta entrega ruim.
- **Substituir a ferramenta de backlog.** O backlog do time não é o problema — ele já
  funciona, já é pago e já tem dono. O problema é o trabalho manual **antes** de a demanda
  chegar lá. O sistema opera essa ferramenta por integração; não a reimplementa (01).
- **Velocidade a qualquer custo.** Acelerar tirando o humano dos portões é explicitamente
  fora de escopo — é o modo de falha, não a meta (01).

## Critério de sucesso — verificável por quem não participou

1. **Tempo de ciclo:** o intervalo entre "demanda chegou" e "pronta para o time começar" cai
   de forma medida — baseline antes da meta.
2. **Throughput por pessoa:** a mesma pessoa leva mais demandas ao fim na mesma semana.
3. **Contrapeso obrigatório:** a proporção de entregas aceitas sem retrabalho **não cai**.
   Se cair, não houve velocidade — houve transferência de trabalho para a revisão.
4. **Uniformidade como efeito:** duas pessoas diferentes produzem entregas indistinguíveis
   em estrutura, sem que ninguém tenha consultado um guia.
