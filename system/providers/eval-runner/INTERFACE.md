# Provider: eval-runner — interface

Executa a camada de **comportamento** dos evals: manda a frase de um caso para um runtime
em modo headless e verifica o que se prometeu. A camada de contrato não passa por aqui —
ela é determinística e vive no `build.sh` (`docs/ARCHITECTURE.md` §9).

Existe como provider pelo mesmo motivo que `backlog` existe: **o harness serve mais de um
runtime**, e amarrar a suíte ao runner de um deles faz a prova valer só lá. A fonte do caso
já é neutra; esta interface é o outro lado da mesma decisão.

## Seleção da implementação

`EVAL_RUNNER` no `.env`: `claude-headless` (default) · `codex-exec` · `opencode-run` ·
`claude-plugin-eval` · `none`. Implementação própria: `org/providers/eval-runner/<nome>.md`.

## Operações

| Operação | L/E | Capacidade exigida |
|---|---|---|
| montar o projeto descartável onde o caso roda | **E** (fora do repo) | — (toda implementação) |
| rodar caso `roteamento`: que skill o runtime engajou | L | `roteamento-skill` |
| rodar caso `modo-degradado`: julgar a última mensagem | L | `julgamento` |
| braço sem o harness carregado, para delta | L | `ablacao` |
| montar fixture de projeto configurado | **E** | `fixture` |

## Capacidades por implementação

| Capacidade | `claude-headless` | `codex-exec` | `opencode-run` | `claude-plugin-eval` |
|---|---|---|---|---|
| `roteamento-skill` | **sim** | não | não | sim |
| `julgamento` | sim | sim | sim | sim |
| `ablacao` · `fixture` | não | não | não | sim |

`roteamento-skill` exige que o runtime **exponha qual skill engajou**. Não é preferência de
implementação, é o que cada um tem:

- **claude** roteia por skill e emite a chamada no `stream-json` — dá para ler o nome.
- **codex** não tem conceito de skill: o adapter dele ships persona (`.codex/agents/*.toml`),
  invocada explicitamente. Não há roteamento por frase a observar.
- **opencode** roteia por **persona** e imprime qual escolheu — é roteamento, mas de outro
  objeto. Caso de skill não é observável.

Capacidade ausente = **indisponibilidade explícita** por caso, nunca caso pulado em
silêncio: um caso que não rodou tem que aparecer como não-rodado, jamais como verde.

> "`EVAL_RUNNER=codex-exec` não observa qual skill engajou. Os N casos de roteamento não
> rodaram; os de modo degradado rodaram."

## Contrato transversal

- **O caso roda num projeto descartável**, montado como o `install.sh` monta: `.agents/`
  apontando para o harness, mais os symlinks de runtime e o `project-config.yaml`. Rodar na
  raiz do harness não testa nada — lá as skills não estão instaladas.
- **O `.env` do projeto real nunca é copiado.** A ausência de configuração é justamente o
  cenário dos casos `modo-degradado`; herdar credencial os faria passar por engano.
- **Uma execução por frase, não por caso.** A fonte declara `atende` e `confunde_com` da
  mesma frase; um único run responde as duas coisas — a skill certa engajou, e nenhuma das
  vizinhas engajou junto.
- **Escrita fica desabilitada** no run. Roteamento se decide no primeiro turno; deixar o
  agente trabalhar gasta e não mede nada.
- **Toda corrida grava `resultado.json` + `report.html`** em `runtime/evals/<carimbo>/`. O
  HTML é uma **visão** do JSON, nunca uma segunda fonte — mesma regra do manifesto (§8). O
  JSON é o que CI e diff consomem; o HTML é o que gente lê.
- **Critério de julgamento mora em arquivo, não em código**: `criterios/<tipo>.md`, lido
  tanto pelo `eval.sh` quanto pelo renderizador do `claude-plugin-eval`. Duas cópias do
  mesmo critério divergem, e aí o mesmo caso passa num runner e reprova no outro.
