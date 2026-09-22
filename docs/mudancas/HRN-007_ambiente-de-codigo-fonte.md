# HRN-007 — Ambiente local de código-fonte no install

| | |
|---|---|
| **Estado** | verde |
| **Camada** | máquina do harness (`install.sh`) + chave L3 no template |
| **Arquivos** | `install.sh` · `seed-codigo-fonte.sh` · `codigo-fonte.README.md` · `project-config.template.yaml` · `README.md` · `docs/MODOS.md` · `runtime/eval.sh` · `tests/seed-codigo-fonte.sh` |
| **Data** | 2026-09-21 |

## História

Como **quem instala o harness num repositório de gestão de produto**, quero **uma pasta
local de código criada pelo `install.sh`**, para **ler e alterar o código do produto sem
versionar esse código no repositório de gestão**.

Hoje o instalador semeia config, `.env` e `org/`, e para. O código do produto, quando
existe, mora noutro remoto — Git, em qualquer host. Sem uma pasta convencionada, cada
pessoa inventa um lugar, e a credencial desse remoto acaba no Git global ou no Keychain
da máquina. A lista de remotes não pode viver no README: no modo aplicativo o mesmo dado
é formulário do projeto, e o README não é superfície de edição.

## Regras de negócio

- **RN-01.** O `install.sh` cria `codigo-fonte/repos/` e, se `codigo-fonte/README.md` não
  existir, copia o template. Arquivo já existente não é sobrescrito.
- **RN-02.** O `install.sh` garante no `.gitignore` do projeto as regras que versionam só
  `codigo-fonte/README.md`. Regra já presente não é duplicada.
- **RN-03.** O seed não escreve clone, remoto nem credencial. Não altera `~/.gitconfig`.
- **RN-04.** Template, seed e o exemplo do template não citam host, URL preenchida nem
  segredo. Remoto de cliente só entra no `project-config.yaml` da instância.
- **RN-05.** A lista de repositórios é o bloco `codigo_fonte.repositorios` (`nome`, `url`).
  A `url` é um remoto Git, de qualquer host. O README não lista remoto. No modo
  aplicativo o formulário do projeto grava esse mesmo bloco; a skill continua lendo o
  arquivo e não sabe quem preencheu.
- **RN-06.** `build.sh` não cria `codigo-fonte/`. Quem semeia a pasta do projeto é o
  `install.sh`.
- **RN-07.** `project-config.yaml` já existente no projeto não é reescrito. A chave nova
  entra só no template.

## Impacto

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | `README.md:38,42-51` descreve o que o `install.sh` cria; `docs/MODOS.md:126` resume o mesmo; `runtime/eval.sh:71` diz que o projeto descartável monta o layout do install; `get.sh:54` só executa o install | atualizar a tabela de instalação do README e a célula de MODOS; no `eval.sh`, deixar explícito que o layout de eval é subconjunto e não semeia `codigo-fonte/` |
| Esteira | o install não declara `produz` nem `requer` | nenhuma propagação |
| Evals | nenhuma fonte `caso.yaml` cita o install nem uma ação nova | prova por script de shell, sem eval de modelo |
| Organização | nenhum encaixe em `org/` governa o install | preservar; zero arquivo novo em `org/` |
| Camada | semear pasta é máquina do instalador; a lista de remotes é L3, o mesmo contrato de `project-config.yaml` que no modo aplicativo vira formulário (`docs/MODOS.md` §2 e §4) | seed no `install.sh`; bloco vazio no template; URL concreta só na instância |

Referências que só apontam o install e continuam válidas, sem edição: `get.sh`,
`sync-context.sh`, `system/workflows/harness-change/SKILL.md`, `docs/ARCHITECTURE.md`,
`system/pack/org-scaffold/README.md`, `org/README.md`.

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | primeiro seed cria `codigo-fonte/README.md` e `codigo-fonte/repos/`; segundo seed não altera o README | `./tests/seed-codigo-fonte.sh` |
| CA-02 | segundo seed não duplica o bloco no `.gitignore` | `./tests/seed-codigo-fonte.sh` |
| CA-03 | seed não cria `.git-credentials` nem diretório de clone | `./tests/seed-codigo-fonte.sh` |
| CA-04 | template e seed não contêm host nem URL de cliente | `./tests/seed-codigo-fonte.sh` |
| CA-05 | contratos estruturais do harness seguem válidos | `./build.sh --strict` |
| CA-06 | organização recém-criada não perde padrão de pack | `./build.sh --strict --org <vazio> --out <temporário>` |

Eval de modelo não se aplica: não há ação nem gatilho novo.

## Plano de arquivos

| Arquivo | Mudança |
|---|---|
| `seed-codigo-fonte.sh` | cria `codigo-fonte/repos/`, copia o README só se faltar, anexa o bloco de gitignore só se faltar |
| `install.sh` | chama o seed depois de resolver `PROJECT_DIR` e antes do `build.sh` |
| `codigo-fonte.README.md` | como a pasta funciona e onde a credencial local mora. Aponta o bloco `codigo_fonte` no `project-config.yaml`. Nenhuma URL |
| `project-config.template.yaml` | bloco `codigo_fonte`: `caminho` default `codigo-fonte/repos/`; `repositorios: []` com o formato `{ nome, url }` comentado. Lista vazia: a skill não inventa remoto |
| `README.md` | uma linha na tabela “o instalador cria” |
| `docs/MODOS.md` | uma menção na célula **Entrar** do modo repositório |
| `runtime/eval.sh` | comentário: o projeto descartável não semeia `codigo-fonte/` |
| `tests/seed-codigo-fonte.sh` | CA-01 a CA-04 |
| `docs/mudancas/HRN-007_ambiente-de-codigo-fonte.md` | este registro |

`build.sh` e `runtime/build.sh` não mudam.

## Fora de escopo

- Preencher `codigo_fonte.repositorios` neste projeto e mover os clones já feitos para
  `codigo-fonte/repos/`. É instância, no repositório de gestão, depois deste HRN aprovado.
- Schema formal em `system/schemas/` e a tela do hub. O contrato desta mudança é o bloco
  no YAML; o formulário, quando existir, grava esse bloco.
- Ensinar skill a clonar. Ela lê `project-config.yaml` e não ganha procedimento novo aqui.
- Gravar credencial no `project-config.yaml`, no Keychain, no `~/.gitconfig` ou no Git
  do harness. Segredo continua fora do arquivo versionado: hoje `repos/.git-credentials`;
  no modo aplicativo, o cofre.

## Registro

- `./tests/seed-codigo-fonte.sh` passou: cria README e `repos/`, não sobrescreve o README, não duplica o `.gitignore`, não cria credencial nem clone.
- `./build.sh --strict` saiu 0, com 0 avisos, na organização real.
- Organização vazia: `./build.sh --strict --fix --org <vazio> --out <temporário>` numa cópia do harness saiu 0, com 0 avisos. Nenhum aviso de “sem padrão no pack”. `gerar-documento-final` segue indisponível até o encaixe essencial — estado esperado, não aviso. `system/ACOES.md` do harness real não mudou.
- O mesmo `--fix` com `--org` vazio, rodado na árvore real, reescreve `docs/WORKFLOWS.md` para a resolução sem organização. Foi restaurado. A prova da organização vazia tem de rodar numa cópia.
- Eval de modelo não se aplica.

**Estado:** verde.
