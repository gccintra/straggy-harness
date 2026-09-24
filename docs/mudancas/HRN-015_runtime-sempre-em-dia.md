# HRN-015 — Runtime sempre em dia e skill de modo obrigatória no protótipo

| | |
|---|---|
| **Estado** | verde |
| **Camada** | adapter (`runtime/build.sh`, `runtime/sessao.sh`, `runtime/adapters/render.py`) · L1 (`PROFESSION.md`) · L2 pack (persona `product-designer`, `design-screen`, eval de `design-setup`) · meta (`harness-change`) |
| **Arquivos** | `runtime/build.sh` · `runtime/sessao.sh` (novo) · `runtime/adapters/render.py` · `runtime/adapters/README.md` · `.gitignore` · `system/workflows/harness-change/SKILL.md` · `system/pack/workflows/product-designer/SKILL.md` · `system/professions/product-designer/PROFESSION.md` · `system/pack/workflows/design-screen/SKILL.md` · `system/pack/workflows/design-setup/evals/instala-painel/caso.yaml` (novo) |
| **Data** | 2026-09-24 |
| **Depende de** | [HRN-005](HRN-005_skills-materializadas.md) · [HRN-012](HRN-012_painel-de-cenarios-componente-pronto.md) |

## História

Como **quem opera o harness em vários runtimes**, quero **que toda sessão comece com o
runtime gerado igual à fonte e que o designer nunca mexa no protótipo sem a skill de modo**,
para **o agente não trabalhar com instrução velha nem reinventar o que o pack já entrega**.

Incidente de 2026-09-24: a HRN-012 editou `design-setup`/`design-screen` em `system/`, o
build não rodou, e `runtime/skills/` — o que os quatro runtimes leem — seguiu sem o painel
de cenários. Pedido "ícone do canto para selecionar estados" virou componente reinventado,
com visual do produto. Desde a HRN-005 o runtime é cópia; fonte editada sem build = agente
lendo versão velha, em silêncio. Segundo buraco: a persona roteia por tabela, mas não proíbe
editar `prototype/` sem carregar a skill de modo.

## Regras de negócio

- **RN-01.** O build grava a impressão digital das fontes (`system/`, `org/`,
  `runtime/adapters/`, `runtime/build.sh`) em `runtime/.impressao`.
- **RN-02.** `build.sh --check` compara fonte × impressão sem gerar nada: `0` em dia, `4`
  desatualizado (código novo; `3` segue sendo contrato reprovado).
- **RN-03.** Os quatro runtimes rodam `runtime/sessao.sh` ao abrir sessão: Claude
  (`SessionStart` em `settings.json`), Codex (`SessionStart` em `hooks.json` + feature
  ligada no `config.toml`), Cursor (`sessionStart` em `hooks.json`), OpenCode (plugin que
  roda na inicialização). Tudo gerado pelo `render.py` — nunca à mão.
- **RN-04.** `sessao.sh`: em dia → silêncio. Desatualizado → roda o build (com trava contra
  corrida) e avisa no contexto da sessão o resultado; reprovação aponta o log. Nunca bloqueia
  a sessão (sai 0 sempre).
- **RN-05.** Cursor com `.cursor/` real (criado pelo IDE): o build planta `hooks.json` só se
  não existir; arquivo do usuário nunca é tocado.
- **RN-06.** Persona `product-designer`: nenhuma edição em `prototype/` sem a skill de modo
  carregada, ajuste incluso. Painel de cenários / seletor de estados → `design-setup`
  (asset pronto).
- **RN-07.** `design-screen` confere, antes de construir, se `prototype/src/lib/scenarios.tsx`
  existe e é igual ao asset; divergiu → recopia pela `design-setup` antes.
- **RN-08.** Aceite da `harness-change` inclui `build.sh --check` saindo 0.

## Impacto

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | `build.sh` citado em `harness-change/SKILL.md` §6, `runtime/adapters/README.md`, `README.md`; códigos de saída documentados no cabeçalho do `runtime/build.sh` | §6 ganha o `--check`; README de adapters ganha os arquivos de hook; cabeçalho do build documenta `--check` e o código 4 |
| Esteira | nenhuma `produz`/`requer` tocada | — (vazio) |
| Evals | `design-setup/configura-design-system`, `design-screen/cria-tela` — ações intactas | caso novo `instala-painel` (atende `configurar-design-system`, confunde com `construir-tela`) |
| Organização | nenhum override de `product-designer`, `design-*` em `org/` | — (vazio) |
| Camada | frescor é motor (adapter), não regra de comportamento — fica fora da constituição; obrigação de carregar a skill é da persona (L2 pack) + autonomia (L1) | mantém |

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | Contrato íntegro | `./build.sh --strict` sai 0 |
| CA-02 | `--check` detecta fonte editada e zera após build | editar fonte → `--check` = 4 · `build.sh` → `--check` = 0 |
| CA-03 | `sessao.sh` regenera sozinho e avisa em cada formato | fonte editada → `sessao.sh claude|codex|cursor` imprime aviso (cursor em JSON válido) e `--check` volta a 0 |
| CA-04 | Os quatro adapters trazem o gancho | arquivos gerados: `claude/settings.json`, `codex/hooks.json` + `config.toml`, `cursor/hooks.json`, `opencode/plugins/harness-sessao.js` |
| CA-05 | Pedido de seletor de estados cai em `configurar-design-system` | eval `design-setup/instala-painel` |
| CA-06 | Organização vazia sem aviso de "sem padrão" | `--org <vazio> --out <temporário>` |

## Fora de escopo

- Hash na constituição ou regra L0 de "rode o build": é motor, não comportamento.
- Hook de runtime não listado no pack.
- Checagem de frescor em CI (fica com a HRN-003).

## Registro

- CA-01: `build.sh --strict --env /dev/null` → exit 0. Com o `.env` do projeto reprova por
  2 avisos de `doc-final-generator` (capacidade `layout-custom` × `pandoc-cli`) —
  **pré-existentes**, reproduzidos com a mudança em stash.
- CA-02: fonte editada → `--check` = 4; após `build.sh` → 0.
- CA-03: `sessao.sh claude|codex|cursor|texto` com fonte editada regenerou e avisou nos quatro
  formatos (cursor em JSON válido); em dia → silêncio (`{}` no cursor).
- CA-04: arquivos gerados e ignorados pelo Git. Teste real por CLI:
  - **OpenCode** (`opencode run`): plugin regenerou o runtime (a sessão falhou depois por
    região do modelo, sem relação).
  - **Codex** (`codex exec`, 0.156.1): lê o `config.toml` do projeto; o gancho só roda com
    projeto confiável **e hook aprovado** (`hooks.state` no config do usuário). Provado com
    `--dangerously-bypass-hook-trust` numa invocação de teste: regenerou. Uso normal exige
    aprovar o hook uma vez em sessão interativa. Chave `codex_hooks` está obsoleta → `hooks`.
  - **Cursor** (`cursor-agent -p`): nenhum hook de projeto disparou no modo headless, nem um
    `beforeSubmitPrompt` de teste — workspace não confiável ou headless sem hooks. Arquivo
    segue o schema documentado; **não verificado** no IDE.
  - **Claude**: formato padrão de `SessionStart`; roda na próxima sessão.
- CA-05: eval `design-setup/instala-painel` PASSOU; mutação (frase de `construir-tela`)
  FALHOU com "design-screen sequestrou a frase" — o caso testa de fato.
- CA-06: `--org <vazio>` sem aviso de "sem padrão"; erro de `WORKFLOWS.md` divergente é o
  pré-existente registrado na HRN-011.
- Não previsto: no incidente, o runtime foi regenerado por outra pessoa às 09:53, durante o
  diagnóstico. Achado lateral, fora do escopo: `plant_cursor_rules` no caso `.agents/` grava
  links com alvo relativo à raiz do projeto dentro de `.cursor/rules/` — provavelmente
  quebrados quando o `.cursor` é pasta real. Não corrigido aqui.
- **Substituída em parte pela [HRN-017](HRN-017_build-por-git-hook.md):** RN-03/04/05
  (ganchos de sessão e `sessao.sh`) removidas — o gancho exigia aprovação no Codex e não rodou
  no Cursor headless; o build agora roda pelos hooks do Git. Seguem valendo RN-01/02
  (impressão e `--check`) e RN-06/07/08.
