# HRN-005 — Visão resolvida em arquivo real, descoberta igual nos runtimes

| | |
|---|---|
| **Estado** | verde
| **Camada** | adapter (`runtime/build.sh`, `runtime/adapters/render.py`) · L2 pack (3 YAML) |
| **Arquivos** | `runtime/build.sh` · `runtime/adapters/render.py` · `runtime/adapters/README.md` · `.gitignore` · `system/workflows/harness-change/SKILL.md` · `docs/ARCHITECTURE.md` · `system/pack/workflows/{design-screen,design-setup,doc-final-generator}/SKILL.md` |
| **Data** | 2026-09-03 |

## História

Como **quem instala o harness noutro repositório**, quero **que o Codex descubra as mesmas skills que Claude e Cursor**, para **não ter um runtime cego depois do `install.sh`**.

Os evals obrigaram o overlay a ser por arquivo, para não gravar `prompt.md` na fonte. Cada `SKILL.md` virou symlink de arquivo. O Codex segue symlink de **pasta** e descarta symlink de **arquivo** — a lista fica vazia, sem erro.

## Regras de negócio

- **RN-01.** `runtime/skills/` é artefato gerado em arquivo real. Fonte continua em `system/` e `org/`.
- **RN-02.** Overlay continua por caminho (pack, depois org). Eval continua gravando no gerado, nunca na fonte.
- **RN-03.** Os quatro runtimes leem a mesma árvore. Ponteiro de descoberta é symlink de **pasta** para `runtime/skills`.
- **RN-04.** Frontmatter interno (`acao`, `encaixes`, …) permanece no `SKILL.md` publicado. O build e o `eval.sh` leem esses campos.
- **RN-05.** YAML do frontmatter publicado parseia. Item de lista que começa com `` ` `` vai entre aspas.

## Impacto

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | `runtime/build.sh` overlay; `render.py` só o Cursor plantava `skills`; `.gitignore` (“symlinks absolutos”); `adapters/README.md`; `harness-change` / `ARCHITECTURE.md` | overlay copia; os três adapters ganham o ponteiro; docs acompanham |
| Esteira | vazio | — |
| Evals | `eval.sh` grep de `id:` no `SKILL.md` publicado | não mexer — frontmatter interno fica |
| Organização | encaixes no mesmo `caminho:` | nada a migrar; rebuild já era obrigatório |
| Camada | adapter/build. Aspas nos 3 `SKILL.md` são pack (YAML válido) | mantém |

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | contrato intacto | `./runtime/build.sh --strict` sai 0 |
| CA-02 | nenhum `SKILL.md` em `runtime/skills/` é symlink | `find runtime/skills -name SKILL.md -type l` vazio |
| CA-03 | os 27 frontmatters parseiam | `yaml.safe_load` em cada `SKILL.md` |
| CA-04 | Claude, Codex e Cursor têm `skills → ../skills` | `readlink runtime/{claude,codex,cursor}/skills` |

## Fora de escopo

- Strip de `acao`/`encaixes` no artefato publicado.
- Mudança no `install.sh` ou no `eval.sh`.
- Mover artefato de eval para fora de `runtime/skills/`.

## Registro

`./runtime/build.sh --strict` saiu 0. 28 workflows; zero `SKILL.md` symlink; YAML dos 28 parseia; `runtime/{claude,codex,cursor}/skills` → `../skills`.

A execução achou o mesmo YAML inválido em `org/workflows/hu-narrative-generator/SKILL.md` (item de `entrega` começando com `` ` ``). Aspas no mesmo movimento — senão essa skill org continuaria invisível no Codex.
