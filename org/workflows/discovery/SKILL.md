---
name: discovery
description: >
  Conduz o discovery de uma demanda seguindo o Double Diamond: explora e define o problema
  (D1), depois explora e define a solução (D2). Cada fase gera um comentário na issue de
  origem — a descrição nunca é alterada, exceto o bloco PRIORIZACAO atualizado ao convergir.
  Detecta em qual fase a issue está lendo comentários existentes e propõe a próxima fase
  pendente. Use quando o usuário pedir para explorar soluções, fazer discovery, discutir
  alternativas, aprofundar o entendimento de um problema — referenciando ou não um número
  de issue. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de
  qualquer operação no backlog.
---

# discovery — workflow L2

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` (write-gate por fase; suposição declarada; pendência não some) |
| Método | `system/professions/product-specialist/methods/double-diamond.md` — barra de qualidade e contrato por fase. **Leia antes de conduzir.** `moscow.md` + `ice.md` para a priorização negociada. |
| Providers | `backlog/` — **com fallback local** (modo local da INTERFACE) · `knowledge/` (contexto) · `database/` (incógnitas de dado, só a pedido do usuário) |
| Formatos | `references/fases.md` — template de comentário e de history de cada fase |

## Bindings desta organização

- **Uma fase = um comentário na issue** com marcador `[D1a]`/`[D1b]`/`[D2a]`/`[D2b]` + um
  bloco append no history (`history/discoveries/YYYY-MM-DD_discovery_issue-NNN.md`; sem
  issue → `_{slug}`). A **descrição da issue nunca muda**, exceto o bloco `PRIORIZACAO`
  (e a label de prioridade) atualizados nas convergências (D1b e D2b).
- **Detecção de fase**: leia os comentários da issue (marcadores) — ou o history no modo
  local — resuma o estado e proponha a próxima fase. **Uma fase de cada vez**; skip de
  fase só com justificativa + aprovação. No D2b, um sub-passo por vez (cadência de
  aprovação do usuário — fluxo → campos → regras → edge cases → pendências do D1a →
  critérios → ICE).
- **Ancoragem D2.0 (antes de propor solução)**: releia pelo provider knowledge as regras,
  HUs do módulo, Referências Globais (se existir), ONEPAGE e discoveries anteriores; monte
  a lista de incógnitas técnicas e **PARE** — o usuário decide o meio de resolver
  (responder, `db-query`/`@tech-lead`, ou seguir com suposição declarada).
- **Marcadores de origem e destino** em cada regra/comportamento capturado no D2b —
  origem: `[EXISTENTE: fonte]` / `[CONFIRMADO: banco/dev]` / `[SUPOSIÇÃO: confirmar]`;
  destino: `[→CA]` · `[→RN]` · `[→MSG]` · `[→GL candidato]`. É o que alimenta o
  `doc-consolidator` sem duplicar o trabalho dele.
- **Fronteira**: o discovery é rico e narrativo — material bruto em linguagem de negócio.
  **Não** numera RN/CA final, não formata como o `.md` consolidado, não gera `.docx`,
  não cria issues. Quem estrutura é o `doc-consolidator`.
- **Thresholds de quadrante e fórmula ICE**: do documento de priorização do projeto
  (`docs/context_docs/`), nunca decorados.
- Demanda grande no D2a → proponha decomposição em HUs/HTs e pergunte como dividir.
- Sessão encerrada sem D2b completo → rodapé no history com última fase e pendências
  (formato no `references/`).

## Encerramento

D2b completo → aponte o próximo passo: `doc-consolidator` ("documenta a #NNN") gera o
`.md`; `.docx` só depois, sob pedido explícito.
