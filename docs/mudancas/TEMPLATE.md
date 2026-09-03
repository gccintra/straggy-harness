# HRN-NNN — <título curto, em resultado>

| | |
|---|---|
| **Estado** | proposto · em edição · verde |
| **Camada** | L0 · L1 · L2 pack · L2 org · provider · adapter |
| **Arquivos** | `caminho/tocado.md` · `outro.md` |
| **Data** | AAAA-MM-DD |

## História

Como **<papel>**, quero **<capacidade>**, para **<resultado>**.

Contexto de uma a três linhas: o que hoje não funciona, e o que se perde deixando assim.

## Regras de negócio

Invariantes que a mudança não pode quebrar. Escreva como afirmação verificável, não como
intenção.

- **RN-01.** …
- **RN-02.** …

## Impacto

Os cinco raios de `system/workflows/harness-guide/references/impacto.md`. Raio sem achado se
declara vazio — omitir não é o mesmo que verificar.

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | `arquivo:linha` … | atualizar / é cópia, resolver na camada / ignorar |
| Esteira | ação dependente … | — |
| Evals | caso … | — |
| Organização | encaixe preenchido … | migrar / preservar |
| Camada | — | mantém / desce para L1 / sobe para L0 |

## Critérios de aceite

Um por linha, cada um com a prova que o verifica. Critério sem prova é conversa.

| # | Critério | Prova |
|---|---|---|
| CA-01 | … | `build.sh --strict` |
| CA-02 | … | eval `<workflow>/<caso>` |

## Fora de escopo

O que foi discutido e **não** entra — para ninguém reabrir daqui a dois meses achando que
esqueceram.

## Registro

O que foi feito, e o que a execução mostrou que a proposta não previa. Preenchido no fim,
não no começo.
