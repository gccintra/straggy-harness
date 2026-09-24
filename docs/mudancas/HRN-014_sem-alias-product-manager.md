# HRN-014 — Só existe /product-specialist

| | |
|---|---|
| **Estado** | verde |
| **Camada** | adapter |
| **Arquivos** | `runtime/adapters/aliases.tsv` |
| **Data** | 2026-09-23 |

## História

Como **quem chama a persona de produto no Claude**, quero **um nome só no menu**, para **não escolher entre product-manager e product-specialist**.

O alias existia desde a troca de nome da persona (12/08/2026): `/product-manager` abria a mesma persona. A HRN-010 manteve o comando porque não há skill com esse nome. A decisão agora é a oposta: o nome vigente é `product-specialist`.

## Regras de negócio

- **RN-01.** `/product-specialist` continua sendo a persona de produto.
- **RN-02.** Não existe comando, skill nem agente chamado `product-manager`.
- **RN-03.** O mecanismo de alias (`aliases.tsv`) continua. A tabela fica vazia.

## Impacto

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | `runtime/adapters/aliases.tsv` é a fonte. `docs/mudancas/HRN-010_runtimes-sem-duplicata.md` registra a decisão anterior. Menções em `docs/hub/discovery/` são URL de artigo, não o alias | apagar a linha. A HRN-010 fica como história |
| Esteira | nenhum. Alias não produz artefato | — |
| Evals | nenhum `caso.yaml` cita `product-manager` | — |
| Organização | `aliases.tsv` não é encaixe. `org/` não tem arquivo nesse nome | — |
| Camada | adapter: é como o Claude ganha um nome extra de invocação | mantém |

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | o build gera zero `runtime/claude/commands/product-manager.md` | `./build.sh` e `ls runtime/claude/commands` |
| CA-02 | `product-specialist` continua persona primária | saída do build: 3 primárias |

## Fora de escopo

- Renomear a persona.
- Apagar o mecanismo de alias.
- Reescrever a HRN-010.

## Registro

- `./build.sh` → 0. `runtime/claude/commands/` vazio. 4 personas, 3 primárias, 0 aliases.
