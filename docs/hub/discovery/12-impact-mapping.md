# 12 — Impact mapping

> **Método:** `impact-mapping` (L1). **Contrato:** objetivo com métrica · atores nomeáveis ·
> impactos como **mudança de comportamento** · entregas candidatas (hipótese, não
> compromisso) · o que fica de fora.
> **Estado:** entregas aqui são candidatas. O corte acontece em 14/18.

---

## Objetivo

**3 contratos pagos e tempo de ciclo por demanda −40%, sem queda na aceitação, até
2026-12-31.**

Três números porque cada um sozinho engana: contrato sem ganho de ciclo é piloto que morre
na renovação; ciclo menor com aceitação caindo é trabalho empurrado para a revisão; ganho
sem contrato é elogio.

## O mapa

```
META  3 contratos pagos + ciclo −40% + aceitação estável — até 31/12/2026
 │
 ├─ ATOR  Líder de produto (P1) — comprador
 │   ├─ IMPACTO  para de revisar formato documento por documento
 │   │     └─ entrega: contrato de saída garantido por estrutura (existe)
 │   │     └─ entrega: medição de ciclo e aceitação por espaço (novo, barato)
 │   ├─ IMPACTO  passa a declarar o padrão em vez de ensiná-lo pessoa a pessoa
 │   │     └─ entrega: tela de encaixes por ação, com preset (desenhado)
 │   │     └─ entrega: configuração assistida na implantação (serviço, não produto)
 │   └─ IMPACTO  coloca o PM novo para produzir na primeira semana
 │         └─ entrega: espaço com padrão já valendo (desenhado)
 │
 ├─ ATOR  PM de execução (P2) — usuário diário
 │   ├─ IMPACTO  para de reescrever o que a IA entregou
 │   │     └─ entrega: ação executando o procedimento declarado (existe)
 │   │     └─ entrega: contexto do produto disponível na execução (existe)
 │   ├─ IMPACTO  passa a trabalhar pela conversa em vez de pelo template
 │   │     └─ entrega: conversa como interface (desenhado)
 │   ├─ IMPACTO  aprova em vez de escrever
 │   │     └─ entrega: esteira com estado e portão (desenhado)
 │   └─ IMPACTO  deixa mais de uma demanda correndo ao mesmo tempo
 │         └─ entrega: paralelismo entre demandas (novo — segunda onda, 14)
 │
 ├─ ATOR  Quem recebe o trabalho — time de engenharia, área de negócio ou cliente externo
 │   ├─ IMPACTO  para de devolver por falta de informação ou de forma
 │   │     └─ entrega: saída no destino que o time usa (backlog, wiki ou documento)
 │   │     └─ entrega: registro e refino acontecendo na ferramenta que ele já abre
 │   │                (integração, não quadro novo — existe)
 │   └─ IMPACTO  reconhece o mesmo padrão em qualquer entrega daquele time
 │         └─ entrega: encaixe de estrutura (existe)
 │
 └─ ATOR  Nós (equipe Straggy) — durante a validação
     ├─ IMPACTO  operamos as contas manualmente e medimos aceitação
     │     └─ entrega: medição de retrabalho por demanda (planilha, não produto)
     └─ IMPACTO  aprendemos o que o cliente configura sozinho
           └─ entrega: teste de configuração assistida (roteiro, não produto)
```

## Impactos como comportamento — a diferença que o método exige

| Errado (feature disfarçada de impacto) | Certo (mudança de comportamento) |
|---|---|
| "P1 tem um painel de ciclo" | P1 **para de revisar** formato documento por documento |
| "P2 usa o chat do produto" | P2 **para de reescrever** a saída |
| "cliente recebe .docx" | cliente **para de devolver** por forma |

Se o comportamento não muda, a entrega não serviu — independentemente de ter sido
construída.

## O que fica de fora — e por quê

Ramos sem impacto claro na meta são o motivo do mapa existir:

| Fora | Por quê |
|---|---|
| **Backlog, quadro e sprint próprios** | **fora por escopo, não por prioridade** (00, v4). Ninguém muda de comportamento por trocar de quadro; o comportamento muda quando o registro deixa de ser digitado à mão — e isso a integração já entrega |
| **Tarefas, workshops, métricas de delivery, automação, voz** | nenhum deles muda o comportamento de P1 ou P2 dentro desta meta. São produto novo (PRD §8.3) |
| **Paralelismo** | é o mecanismo mais direto da meta de ciclo, e o mais caro (facilidade 1 em 14). Fica na **segunda onda**, não cortado — entra assim que a medição mostrar que a espera entre demandas é a maior fatia do ciclo |
| **Autosserviço / cadastro aberto** | traz o segmento errado (C e D de 04) e derruba a métrica de aceitação |
| **Permissões finas** | nenhum time de 6 PMs trava por causa disso no primeiro contrato |

## O comportamento que o recorte de escopo assume

O mapa acima depende de um comportamento que **ninguém observou ainda**: o PM aceitar que o
registro e o refino aconteçam pela conversa, e parar de abrir a ferramenta de backlog para
conferir e refazer. Se ele continuar abrindo, a entrega não mudou comportamento nenhum — só
acrescentou um passo. É a premissa A14 (09), e é o que o critério S9 do alpha mede (19).

## Ator deliberadamente não incluído

**Desenvolvedor do cliente.** Ele ganha com requisito melhor, mas não decide, não compra e
não opera. Incluí-lo agora abriria ramo (integração com fluxo de dev) que não serve à meta.
