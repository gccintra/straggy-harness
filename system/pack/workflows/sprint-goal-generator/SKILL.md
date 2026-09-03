---
name: sprint-goal-generator
description: >
  Gera a Meta da Sprint (Sprint Goal) no padrao do Guia do Scrum 2020, com foco em OUTCOME
  (ganho de valor para o usuario/negocio) e nao em output (funcionalidades entregues). Use
  sempre que o usuario pedir para criar, escrever, montar ou sugerir uma Meta da Sprint,
  Sprint Goal, objetivo da sprint, ou enviar HUs/backlog pedindo para definir a meta.
  Tambem quando perguntar qual seria a meta mesmo sem usar o termo exato. Trigger
  agressivo: qualquer combinacao de meta + sprint + contexto de desenvolvimento de software.
acao:
  id: definir-meta-de-sprint
  rotulo: Definir meta da sprint
  descricao: escreve a meta da sprint orientada a resultado
objetivo: Escrever a meta da sprint como ganho para o usuário ou o negócio, não como lista de entregas.
entrega:
  - 2 a 3 opções de meta na conversa, cada uma com por que é outcome e como verificar
  - recomendação e alertas
portoes:
  - input vago demais → uma pergunta antes de gerar
  - só propõe — quem grava a meta na sprint é a ação `gerenciar-sprint`, com aprovação
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo: Como fazer
    ajuda: Como sua empresa escreve a meta da sprint — quem participa, que evidência sustenta a meta e como ela é validada.
    tipo: texto-longo
---

# sprint-goal-generator — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` |
| Método | `system/professions/product-specialist/methods/sprint-goal.md` — **é ele que define o que é meta boa, os anti-padrões e o contrato de saída.** Leia antes de gerar. |
| Provider | `system/providers/backlog/` — **com fallback local** (regime "modo local" da INTERFACE) |


**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.

## Bindings

- **Contexto**: use o conteúdo recebido (HUs/backlog). Recebeu só o número/nome da
  sprint → liste as demandas da sprint pelo provider + docs relevantes do projeto.
  Sem backlog configurado → peça HUs/backlog direto ou busque `{caminhos.historico}*sprint*`/`{caminhos.entregaveis}`.
- **Input vago demais** ("metas pra sprint de login") → UMA pergunta antes de gerar:
  "qual é o principal ganho que o usuário ou negócio terá ao final desta Sprint?"
- **Saída**: o contrato do método (2-3 opções com por-que-é-outcome + como verificar +
  recomendação + alertas), apresentado com o contexto identificado e o tema central de
  valor.
- Quem grava a meta na sprint é o `sprint-ops` (com aprovação) — esta skill só propõe.
