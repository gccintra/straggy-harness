# Procedimento desta organização — explorar solução

Encaixe `procedimento` da ação `explorar-solucao`. Substitui o passo a passo padrão do pack.
A moldura do workflow — método Double Diamond, providers, portões por fase e contrato de
saída — continua sendo do sistema e vale aqui também.

Formato de cada fase (comentário e history): `references/fases.md`.

## Registro de cada fase

- **Uma fase = um comentário na issue** com marcador `[D1a]`/`[D1b]`/`[D2a]`/`[D2b]` + um
  bloco append no history (`{caminhos.historico}discoveries/YYYY-MM-DD_discovery_issue-NNN.md`; sem
  issue → `_{slug}`).
- A **descrição da issue nunca muda**, exceto o bloco `PRIORIZACAO` (e a label de
  prioridade), atualizados nas convergências (D1b e D2b).
- **Detecção de fase**: leia os comentários da issue (marcadores) — ou o history no modo
  local — resuma o estado e proponha a próxima fase.
- No D2b, **um sub-passo por vez**, nesta cadência de aprovação: fluxo → campos → regras →
  edge cases → pendências do D1a → critérios → ICE.

## Ancoragem D2.0 (antes de propor solução)

Releia pelo provider `knowledge/` as regras, HUs do módulo, Referências Globais (se
existir), ONEPAGE e discoveries anteriores; monte a lista de incógnitas técnicas e **pare** —
o usuário decide o meio de resolver cada uma (responder, `db-query`/`@tech-lead`, ou seguir
com suposição declarada).

## Marcadores de origem e destino (D2b)

Cada regra/comportamento capturado leva os dois:

- origem: `[EXISTENTE: fonte]` · `[CONFIRMADO: banco/dev]` · `[SUPOSIÇÃO: confirmar]`
- destino: `[→CA]` · `[→RN]` · `[→MSG]` · `[→GL candidato]`

É o que alimenta a ação `documentar-requisito` sem duplicar o trabalho dela.

## Outros bindings

- **Thresholds de quadrante e fórmula ICE**: do funil em `org/ORG.md` §5, nunca decorados.
- Demanda grande no D2a → proponha decomposição em HUs/HTs e pergunte como dividir.
- Sessão encerrada sem D2b completo → rodapé no history com última fase e pendências
  (formato no `references/fases.md`).

## Encerramento

D2b completo → aponte o próximo passo **pela superfície da demanda**: tem tela → o
`@product-designer` (protótipo validado antes do `.md`, `org/ORG.md` §4); não tem →
documentar direto ("documenta a #NNN"). O formato final só depois do `.md` revisado, sob
pedido explícito.
