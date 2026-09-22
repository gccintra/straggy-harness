# HRN-008 — Fontes de leitura do projeto

| | |
|---|---|
| **Estado** | verde |
| **Camada** | L0 + ponteiros L1/L2 |
| **Arquivos** | `system/CONSTITUTION.md` · `system/professions/tech-lead/reasoning.md` · `system/professions/product-designer/PROFESSION.md` · `system/pack/workflows/{product-specialist,tech-lead,product-designer}/{SKILL,PERSONA}.md` · `tests/fontes-de-leitura.sh` |
| **Data** | 2026-09-22 |

## História

Como **agente do harness**, quero **saber onde estão o código do produto, os documentos de contexto, os outputs, o histórico e o protótipo**, para **abrir a pasta que teria a informação quando ela fizer falta**.

O bloco `codigo_fonte` já existia no `project-config.yaml` (HRN-007) e nenhuma persona o citava. Contexto e histórico apareciam em listas parciais, diferentes em cada persona. Outputs era destino de escrita. O protótipo só existia para o designer. Lista parcial lê como conjunto fechado: o que não está nomeado não é consultado.

## Regras de negócio

- **RN-01.** As cinco fontes e os caminhos ficam uma vez, na constituição §3.
- **RN-02.** O agente abre a fonte que teria a informação. Pasta ausente ou vazia = essa fonte está vazia: declara e segue, sem inventar remoto nem caminho.
- **RN-03.** Leitura segue direto. Alterar output, histórico ou código do produto continua estado externo. Escrever no `prototype/` continua o trabalho do designer.
- **RN-04.** Regra de negócio segue em `caminhos.contexto`. Comportamento esperado segue na documentação. Estado real segue no banco. O código do produto é o que está implementado. Divergência se declara.
- **RN-05.** O código do produto é o implementado. O protótipo é a solução vigente da demanda com tela — fluxo, estado, rótulo e mensagem — até existir o documento oficial. Divergência entre código, documentação e protótipo se declara. O harness não é nenhuma dessas fontes.

## Impacto

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | §3 é citado como write-gate e honestidade; ninguém copia o parágrafo das fontes. `tech-lead/reasoning.md` manda “como funciona” só para a documentação. O designer diz “não faz código do sistema real” | mapa no §3; lente de implementação no tech lead; “não faz” do designer passa a ser escrever |
| Esteira | sem `produz` | vazio |
| Evals | nenhuma ação nova | vazio |
| Organização | `org/professions/` só tem README | preservar |
| Camada | o endereço já é L3. A restrição de qual árvore usar vale para qualquer agente | L0; personas referenciam |

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | §3 nomeia as cinco fontes com a chave de cada uma | `./tests/fontes-de-leitura.sh` |
| CA-02 | as três personas apontam a constituição §3 no `SKILL.md` e no `PERSONA.md` | `./tests/fontes-de-leitura.sh` |
| CA-03 | contratos estruturais do harness seguem válidos | `./build.sh --strict` |
| CA-04 | organização recém-criada não perde padrão de pack | `./build.sh --strict --org <vazio> --out <temporário>` |

Eval de modelo não se aplica: não há ação nem gatilho novo.

## Plano de arquivos

| Arquivo | Mudança |
|---|---|
| `system/CONSTITUTION.md` | mapa das cinco fontes no §3 |
| `system/professions/tech-lead/reasoning.md` | lente “como está implementado” |
| `system/professions/product-designer/PROFESSION.md` | “padrão do produto real” aponta `codigo_fonte`; “não faz” é escrever nesse código |
| `system/pack/workflows/product-specialist/SKILL.md` | contexto L3 aponta §3; varredura da base de contexto permanece |
| `system/pack/workflows/tech-lead/SKILL.md` | contexto L3 aponta §3; desempate ganha o código implementado |
| `system/pack/workflows/product-designer/SKILL.md` | demais fontes apontam §3 |
| `PERSONA.md` dos três | a linha de contexto cita §3 |
| `tests/fontes-de-leitura.sh` | CA-01 e CA-02 |
| `docs/mudancas/HRN-008_fontes-de-leitura.md` | este registro |

## Fora de escopo

- Clonar repositório ou gravar credencial.
- `caminhos.dados`.
- Provider novo: a operação é leitura de arquivo num caminho que o `project-config.yaml` já declara.

## Registro

- `./tests/fontes-de-leitura.sh` passou: as cinco chaves estão no §3 e as três personas apontam a constituição §3 no `SKILL.md` e no `PERSONA.md`.
- `./build.sh --strict` saiu 0, com 0 avisos, na organização real.
- Organização vazia: `./build.sh --strict --fix --org <vazio> --out <temporário>` numa cópia do harness saiu 0, com 0 avisos. Nenhum aviso de “sem padrão no pack”. `gerar-documento-final` segue indisponível até o encaixe essencial — estado esperado, não aviso.
- O mesmo comando na árvore real reprova porque `docs/WORKFLOWS.md` foi gerado com a organização real. A prova da organização vazia tem de rodar numa cópia. A árvore real não foi reescrita por esse comando.
- Eval de modelo não se aplica.
- Seguimento: o §3 passou a dizer o papel do protótipo (solução vigente da demanda com tela até o documento oficial). O desempate do tech lead aponta o mesmo. `./tests/fontes-de-leitura.sh` e `./build.sh --strict` refeitos depois disso.

**Estado:** verde.
