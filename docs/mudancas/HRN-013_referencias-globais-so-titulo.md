# HRN-013 — Referências Globais com código e título somente

| | |
|---|---|
| **Estado** | verde |
| **Camada** | L2 org |
| **Arquivos** | `org/workflows/doc-consolidator/references/formato-md.md` · `org/workflows/doc-final-generator/references/template.md` · `org/workflows/doc-final-generator/references/exemplos.md` |
| **Data** | 2026-09-24 |

## História

Como autor do documento consolidado, quero que a seção 7 liste cada Referência Global só pelo código e título, para evitar texto operacional sem valor no requisito.

Hoje o contrato de formato e os exemplos mandam acrescentar `usado em CA…` e `(ver Referencias-Globais.md — Drive)` depois do título. Isso aparece nos documentos gerados.

## Regras de negócio

- **RN-01.** Cada GL da seção 7 ocupa um bullet no formato `- **GL_XX — Título**`, sem texto depois do título.
- **RN-02.** O identificador `GL_XX` permanece para corresponder às referências `[GL_XX]` dos critérios de aceite.
- **RN-03.** Quando não houver GL, a seção 7 continua com `- N/A`.
- **RN-04.** O conteúdo de GLs novos permanece no apêndice de promoção; o catálogo do Drive não é alterado.

## Impacto

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | `org/workflows/doc-consolidator/references/procedimento.md` aponta para `formato-md.md`; `org/workflows/doc-final-generator/references/procedimento.md` aponta para `template.md` e `exemplos.md`. `system/ACOES.md`, `docs/WORKFLOWS.md` e os `SKILL.md` do pack apenas apontam para os encaixes. | Preservar caminhos e encaixes. Atualizar as três ocorrências que repetem o sufixo. |
| Esteira | `gerar-documento-final` requer `documento-consolidado`. | Não mudar o nome, as seções nem o contrato de transcrição. |
| Evals | Casos de `documentar-requisito` e `gerar-documento-final` existem; nenhum verifica o texto da seção 7. | Preservar o roteamento; verificar o formato diretamente e rodar o build. |
| Organização | Os três arquivos-alvo são encaixes preenchidos em `org/`. | Editar os arquivos existentes, sem migrar caminhos nem substituir o workflow. |
| Camada | A composição desta seção pertence ao formato documental da organização. | Manter em L2 org. |

## Plano de arquivos e diff conceitual

- `org/workflows/doc-consolidator/references/formato-md.md`: trocar o contrato da linha de GL e o exemplo da seção 7 por `- **GL_01 — [Título]**`. Acrescentar instrução explícita de que nada vem após o título.
- `org/workflows/doc-final-generator/references/template.md`: trocar o exemplo da seção 7 pelo mesmo formato. Ajustar a frase introdutória que diz que GL leva texto completo, pois a seção 7 guarda apenas código e título.
- `org/workflows/doc-final-generator/references/exemplos.md`: remover o sufixo do bullet de exemplo.
- Nenhum caminho, frontmatter, portão, ação, provider ou script será alterado. Nenhuma poda de script cognitivo foi identificada nesses trechos.

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | Os três encaixes mostram a seção 7 apenas com código e título, sem `usado em CA` ou indicação de Drive no bullet. | Busca dirigida nos três arquivos e conferência do diff. |
| CA-02 | O build continua resolvendo os encaixes e ações sem avisos. | `./build.sh --strict` |
| CA-03 | O identificador da GL e o caso sem GL continuam previstos. | Busca dirigida em `formato-md.md` e `template.md`. |

## Fora de escopo

Corrigir documentos de demanda já gerados, alterar o catálogo de Referências Globais no Drive ou mudar o apêndice de novas GLs.

## Registro

Os três encaixes foram atualizados conforme o plano. `./build.sh --strict` e
`./build.sh --fix --strict` saíram com código 0 e zero avisos; o `--fix` não alterou
`system/ACOES.md` nem `docs/WORKFLOWS.md`. A conferência dirigida dos seis arquivos
(fontes e cópias resolvidas em `runtime/skills/`) confirmou bullets de GL terminando no
título, sem o sufixo de CA ou Drive, e preservação de `- N/A` no contrato e no template.
`git diff --check` passou. O eval `documenta-a-demanda` passou (1/1).

O teste de organização vazia passou numa cópia temporária depois de gerar ali as tabelas
derivadas com `--fix`: 23 ações, zero avisos. A primeira execução diretamente nesta cópia
de trabalho saiu com código 3 porque `docs/WORKFLOWS.md` descreve a organização preenchida;
essa divergência não decorre da mudança. O gerador final fica indisponível na organização
vazia por depender de encaixe essencial, conforme o contrato existente.

Não se aplicam a esta edição a mutação da frase de eval (roteamento não foi alterado),
mudanças de persona, catálogo de ações, provider, `.env.example` ou README.
