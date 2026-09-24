# HRN-017 — Build pelo Git: runtime regenerado quando a fonte muda de versão

| | |
|---|---|
| **Estado** | verde |
| **Camada** | adapter (`.githooks/`, `install.sh`) · meta (`harness-change`) |
| **Arquivos** | `.githooks/_runtime.sh` (novo) · `.githooks/post-merge` · `.githooks/post-checkout` · `.githooks/post-rewrite` · `.githooks/pre-commit` (novos) · `install.sh` · `runtime/adapters/README.md` · `system/workflows/harness-change/SKILL.md` |
| **Data** | 2026-09-24 |
| **Depende de** | [HRN-015](HRN-015_runtime-sempre-em-dia.md) |

## História

Como **quem mantém o harness em vários projetos**, quero **que o runtime se regenere sozinho
quando a fonte do harness muda de versão**, sem depender de abrir um agente, para **não ficar
refém do gancho de sessão — que no Codex exige aprovar o hook e no Cursor headless não roda**.

A HRN-015 regenera ao abrir a sessão. Funciona sem configuração só em Claude e OpenCode. O
Git é comum a todos: o harness chega e muda por `git pull`, troca de branch, rebase e commit.

## Regras de negócio

- **RN-01.** `.githooks/` versionado no repositório do harness; `install.sh` liga com
  `git config core.hooksPath .githooks` no `.agents/`. Não pede aprovação de runtime.
- **RN-02.** `post-merge`, `post-checkout`, `post-rewrite`: `build.sh --check`; desatualizado →
  `build.sh`. Nunca falham o comando Git (saem 0) e avisam em uma linha.
- **RN-03.** `pre-commit`: roda o build sempre (~2 s — valida o contrato, não só o frescor); bloqueia o commit só se o build reprovar o
  contrato com **erro** (código 3 sem `--strict`) — aviso não bloqueia. `--no-verify` segue
  valendo.
- **RN-04.** Substitui os ganchos de sessão da HRN-015, removidos: `runtime/sessao.sh` e os
  arquivos de gancho de cada runtime. Edição ainda não commitada → `./build.sh` à mão.
- **RN-05.** Respeita `HARNESS_ORG_DIR`, como o build.

## Impacto

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | `install.sh:181` (build na instalação) · `harness-change` §6 (aceite com `--check`) · `runtime/adapters/README.md` (gancho de sessão) | install liga o hooksPath; §6 e README citam os hooks |
| Esteira | nenhuma | — (vazio) |
| Evals | nenhum | — (vazio) |
| Organização | `org/` dentro do `.agents/`: hooks cobrem commit/pull dela também | — |
| Camada | motor do build, fora de skill | mantém |

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | Contrato íntegro | `./build.sh --strict --env /dev/null` sai 0 |
| CA-02 | Checkout de versão com fonte diferente regenera | `git checkout` de commit/branch com fonte alterada → `--check` = 0 depois |
| CA-03 | Commit regenera antes de gravar | fonte editada + `git commit` → `--check` = 0 |
| CA-04 | Commit bloqueado só por erro de contrato | frontmatter quebrado → commit recusado; aviso → commit passa |

## Fora de escopo

- Vigia em segundo plano (descartado pelo usuário).
- Git do projeto consumidor: o harness muda no repositório do `.agents/`, não no do projeto.

## Registro

Provas num clone descartável do harness (nenhum commit no repositório real):

- CA-01: `build.sh --strict --env /dev/null` → exit 0.
- CA-02: `git checkout HEAD~1` e volta → `post-checkout` avisou "fonte mudou — runtime
  regenerado"; `--check` = 0 nas duas direções.
- CA-03: fonte editada + `git commit` → `--check` = 0 depois.
- CA-04: `acao:` quebrado no frontmatter → commit recusado ("commit bloqueado: contrato do
  harness reprovado"); alias apontando para persona inexistente (aviso) → commit passou.
- Não previsto: a primeira versão do `pre-commit` só rodava o build quando a fonte estava
  desatualizada — build manual antes do commit deixava o erro de contrato passar. O
  `pre-commit` agora roda o build sempre (~2 s).
- `core.hooksPath` ligado neste `.agents/` à mão (o mesmo comando que o `install.sh` passa a
  rodar). Outros projetos ganham os hooks no próximo `install.sh`.
- Ganchos de sessão removidos a pedido do usuário depois do aceite: `runtime/sessao.sh`,
  `render_ganchos()` no `render.py`, plantio do `hooks.json` do Cursor no `build.sh`, entradas
  do `.gitignore` e os arquivos já gerados. `build.sh --check` fica (usado pelos hooks).
