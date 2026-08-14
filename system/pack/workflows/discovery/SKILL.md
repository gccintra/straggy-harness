---
name: discovery
description: >
  Conduz o discovery de uma demanda seguindo o Double Diamond: explora e define o problema
  (D1), depois explora e define a solução (D2). Cada fase vira um registro aprovado — no
  backlog e no histórico local. Detecta em que fase a demanda está e propõe a próxima
  pendente. Use quando o usuário pedir para explorar soluções, fazer discovery, discutir
  alternativas ou aprofundar o entendimento de um problema — referenciando ou não uma
  demanda. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer
  operação no backlog.
acao:
  id: explorar-solucao
  rotulo: Explorar solução
  descricao: conduz o discovery de uma demanda até a solução definida
produz:
  id: solucao-definida
  rotulo: Solução definida
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo: Como fazer
    ajuda: Como sua empresa conduz um discovery — quantas fases, quem participa e o que precisa estar fechado para avançar.
    tipo: texto-longo
  formato-fase:
    caminho: references/fases.md
    rotulo: Registro de cada fase
    ajuda: O que fica registrado ao fim de cada fase do discovery, e onde esse registro é guardado.
    tipo: texto-longo
---

# discovery — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` (write-gate por fase; suposição declarada; pendência não some) |
| Método | `system/professions/product-specialist/methods/double-diamond.md` — barra de qualidade e contrato de cada fase. **Leia antes de conduzir.** `moscow.md` + `ice.md` para a priorização negociada |
| Provider | `backlog/` — **com fallback local** (modo local da INTERFACE) · `knowledge/` (contexto) · `database/` (incógnita de dado, só a pedido do usuário) |


**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.

## Bindings padrão

- **Uma fase = um registro**: comentário na demanda (marcador `[D1a]`/`[D1b]`/`[D2a]`/
  `[D2b]`) + bloco append em `{caminhos.historico}discoveries/YYYY-MM-DD_discovery_<ref>.md`. A
  descrição da demanda não é reescrita; priorização acordada entra pela operação de
  **atualizar bloco estruturado** e pela label correspondente.
- **Detecção de fase**: leia os registros existentes (comentários, ou o history no modo
  local), resuma o estado e proponha a próxima fase. **Uma fase de cada vez**; pular fase
  só com justificativa e aprovação.
- **Ancoragem antes de propor solução**: releia pelo provider `knowledge/` o que o produto
  já faz na área e monte a lista de incógnitas; **pare** — o usuário decide como resolver
  cada uma (responder, consultar dados, ou seguir com suposição declarada).
- **Origem e destino** de cada regra/comportamento capturado: origem
  (`EXISTENTE`/`CONFIRMADO`/`SUPOSIÇÃO`) e destino (critério de aceite, regra de negócio,
  mensagem) — é o que alimenta a documentação sem refazer o trabalho.
- **Fronteira**: discovery é material bruto em linguagem de negócio. Não numera regra
  final, não formata documento, não cria demanda. Quem estrutura é o `doc-consolidator`.
- **Escalas, rubrica de cada nota, fórmula do score e cortes** saem da instância do encaixe
  `funil` (ação `priorizar-backlog`), nunca de memória (`methods/ice.md`).

## Encerramento

D2b completo → aponte o próximo passo **pela superfície da demanda**: tem interface → a
profissão de design (protótipo antes da documentação, `double-diamond.md`); não tem →
`doc-consolidator` direto. Sessão encerrada no meio → rodapé no history com a última fase e
as pendências abertas.
