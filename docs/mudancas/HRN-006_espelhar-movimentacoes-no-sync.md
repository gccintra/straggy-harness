# HRN-006 — Espelhar movimentações no cache sincronizado

| | |
|---|---|
| **Estado** | verde |
| **Camada** | provider |
| **Arquivos** | `sync-context.sh` · `system/providers/knowledge/drive-rclone.md` · `system/providers/knowledge/tests/sync-context-move.sh` |
| **Data** | 2026-09-12 |

## História

Como **pessoa que consulta o contexto sincronizado**, quero **que o cache convertido
reproduza a árvore atual do Drive**, para **não encontrar o mesmo arquivo na pasta nova e
na pasta anterior depois de uma movimentação**.

O `rclone sync` remove o caminho antigo de `_raw/`, mas a conversão atual apenas grava em
`md/`. O arquivo convertido na pasta anterior permanece e passa a duplicar o contexto.

## Regras de negócio

- **RN-01.** Após uma conversão bem-sucedida, cada árvore de `md/` contém somente os
  resultados derivados da árvore correspondente em `_raw/`.
- **RN-02.** Mover, renomear ou excluir um arquivo na origem remove seu resultado do caminho
  anterior no cache convertido.
- **RN-03.** A árvore anterior de `md/` permanece disponível se alguma conversão falhar.
- **RN-04.** `SKIP_RCLONE=1` aplica a mesma reconciliação usando o `_raw/` já existente.

## Impacto

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | `install.sh:40` e `README.md:48,193` apontam para o script; `system/providers/knowledge/drive-rclone.md:20-28` descreve o pipeline | manter instalação e README; atualizar o contrato operacional do provider |
| Esteira | nenhum workflow produz ou requer o cache como artefato da esteira | nenhuma propagação |
| Evals | nenhuma fonte de eval cita `sync-context.sh` ou a sincronização do provider | adicionar teste determinístico do script, sem eval de modelo |
| Organização | nenhum encaixe governa o script; `org/` apenas consome o caminho sincronizado | preservar sem migração |
| Camada | conversão e reconciliação são mecânica do provider `knowledge` | manter no script e na implementação do provider |

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | mover um `.docx` entre subpastas deixa somente o `.md` no caminho novo | `./.agents/system/providers/knowledge/tests/sync-context-move.sh` |
| CA-02 | excluir o arquivo de `_raw/` remove o resultado de `md/` | `./.agents/system/providers/knowledge/tests/sync-context-move.sh` |
| CA-03 | falha de conversão preserva a última árvore convertida com sucesso | `./.agents/system/providers/knowledge/tests/sync-context-move.sh` |
| CA-04 | os contratos estruturais do harness continuam válidos | `./.agents/build.sh --strict` |

## Plano de arquivos

| Arquivo | Mudança |
|---|---|
| `sync-context.sh` | converter em staging e substituir a árvore de destino só após sucesso |
| `system/providers/knowledge/drive-rclone.md` | declarar que o cache convertido espelha movimentações e exclusões |
| `system/providers/knowledge/tests/sync-context-move.sh` | cobrir movimentação, exclusão e falha de conversão |
| `docs/mudancas/HRN-006_espelhar-movimentacoes-no-sync.md` | registrar decisão, impacto e provas |

## Fora de escopo

- Alterar configuração, autenticação ou comportamento do `rclone`.
- Adicionar formatos de conversão.
- Alterar o tratamento do documento único `Referencias-Globais.md`.
- Alterar arquivos em `org/`.

## Registro

- O teste reproduziu movimentação, falha de conversão e exclusão; os três cenários passaram.
- `bash -n` passou para o script e para o teste. `shellcheck` não está instalado no ambiente.
- `./.agents/build.sh --strict` saiu com código zero e nenhum aviso.
- Uma cópia descartável do harness passou em `--strict` com organização vazia após regenerar
  seus documentos derivados; `system/ACOES.md` permaneceu byte a byte inalterado.
- Eval de modelo não se aplica: a mudança não cria nem altera ação ou gatilho de workflow.
