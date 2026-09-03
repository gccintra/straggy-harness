# Como o harness funciona — uma página

O que o harness é, o que ele roda e como uma conversa vira artefato. Detalhe de cada
workflow: [`WORKFLOWS.md`](WORKFLOWS.md). Regra normativa das camadas:
[`ARCHITECTURE.md`](ARCHITECTURE.md). Como editar: [`MANUTENCAO.md`](MANUTENCAO.md).

## 1. O que é

Um conjunto de instruções versionadas que transforma um agente genérico numa equipe de
produto — product specialist, tech lead, product designer — que trabalha do jeito de uma
empresa específica, com portão humano em cada ponto onde a qualidade se decide.

Não é aplicação, não tem servidor, não tem banco. É **arquivo de texto que o runtime lê**:
Claude Code, Codex, opencode e Cursor leem os mesmos workflows a partir de adapters
gerados. Trocar de runtime não reescreve nada.

## 2. O ciclo — do pedido ao artefato

```
você fala em linguagem natural
   ↓  o runtime casa o pedido com a `description` de uma skill  ← não há tabela de roteamento
workflow resolvido carrega
   ↓  L0 (constituição) + L1 (profissão e método) + L2 (procedimento) + L3 (valores do projeto)
executa, lendo provider quando precisa de ferramenta externa
   ↓
PORTÃO — apresenta e espera aprovação                          ← nunca pulado
   ↓
artefato gravado (documento, demanda, tela, página de wiki)
```

Três coisas nunca acontecem sozinhas: escrita externa sem aprovação, dois artefatos no mesmo
turno, e portão colapsado para "adiantar". Estão em `../system/CONSTITUTION.md`, a camada que
vence todas as outras.

## 3. As camadas

| | Camada | Onde | Quem manda nela |
|---|---|---|---|
| L0 | comportamento invariante | `system/CONSTITUTION.md` | sistema |
| L1 | como a profissão pensa, métodos | `system/professions/` | sistema (+ `org/professions/`) |
| L2 | procedimento padrão | `system/pack/workflows/` | sistema |
| L2 | procedimento desta empresa | `org/workflows/` (encaixes) + `org/ORG.md` | organização |
| — | sintaxe de ferramenta | `system/providers/<domínio>/` | sistema (+ `org/providers/`) |
| L3 | valores do projeto | `project-config.yaml` · `.env` | projeto |

Duas regras que sustentam o resto: **a camada de cima referencia a de baixo, nunca copia**;
**em conflito, a de baixo vence.** A mesma explicação em dois arquivos significa que um está
na camada errada.

## 4. Encaixe — o único ponto de customização

A organização não substitui workflow. Ela **preenche encaixes**: pedaços de conteúdo que a
moldura do sistema declara e concatena. Formato de documento, template de demanda,
nomenclatura de página, funil de priorização e o próprio `procedimento` são encaixes.

Portão, contrato de saída, método e L0 **não são encaixe**. É por isso que configurar errado
degrada o formato, nunca a qualidade da decisão. Quem precisa de algo que o pack não faz
declara uma **ação nova** em `org/workflows/<nome>/SKILL.md`.

## 5. Provider — a ferramenta fica atrás de uma interface

O workflow diz "listar demandas"; quem sabe se isso é `gh`, `glab` ou Linear é o provider
ativo, escolhido por variável no `.env`. Domínios hoje: `backlog`, `database`,
`docs-output`, `knowledge`, `canvas`, `eval-runner`.

Cada `INTERFACE.md` declara as operações, as capacidades e o **modo degradado**: o que
acontece quando a ferramenta não está configurada. Sem backlog o harness continua rodando,
lendo material local — declarado por workflow, nunca silencioso.

## 6. Esteira — o que precisa existir antes

Ações declaram `requer` e `produz`. Isso forma um grafo que o build valida (todo requisito
tem produtor, sem ciclo):

```
registrar-demanda    → demanda-registrada
explorar-solucao     → solucao-definida
construir-tela       → prototipo-validado      (só demanda com interface)
documentar-requisito → documento-consolidado   ⏸ revisão humana
gerar-documento-final→ documento-final
capturar-prints      → prints-capturadas
```

Demanda com interface documenta **depois** do protótipo validado — é ali que a solução
converge, e documentar antes gera retrabalho.

## 7. O build — de fonte a runtime

```bash
./runtime/build.sh          # resolve camadas, valida contrato, gera skills e adapters
./runtime/build.sh --list   # origem, ação e encaixes preenchidos por workflow
./runtime/build.sh --fix    # regenera os blocos derivados (ACOES.md, WORKFLOWS.md)
./runtime/build.sh --strict # aviso vira reprovação — modo de CI
```

Entra `system/` + `org/`; sai `runtime/skills/` (a visão resolvida que os runtimes leem),
`runtime/manifest.json` (o catálogo como dado) e os adapters de cada runtime. Tudo em
`runtime/` é **gerado** — editar lá é trabalho que o próximo build apaga.

O build é a camada determinística: pega encaixe apontando para provider sem a capacidade,
ação com dois donos, esteira quebrada, eval citando ação renomeada, workflow sem `objetivo`,
`entrega` ou `portoes` declarados.

## 8. Evals — o que o build não consegue provar

Que o gatilho dispara no pedido certo, e **não** no do vizinho, só um runtime executando
responde. Cada workflow tem casos em `evals/<caso>/caso.yaml`, em fonte neutra, traduzidos
para cada runner.

```bash
./runtime/eval.sh                        # tudo
./runtime/eval.sh --skill doc-consolidator
```

Todo caso positivo tem contraprova (`--nao`): a frase que **não** pode acionar aquela ação.
Suíte verde por si não prova nada — quebre um gatilho de propósito e confira que o caso fica
vermelho.

## 9. Onde as coisas ficam

| Pasta | O que é | Gerado? |
|---|---|---|
| `system/` | L0, profissões, providers, pack padrão, máquina | não — imutável pela organização |
| `org/` | ORG.md, encaixes, workflows e providers próprios | não — fora do Git do harness |
| `runtime/skills/` | visão resolvida que os runtimes leem | sim |
| `runtime/claude\|codex\|opencode\|cursor/` | adapters por runtime | sim |
| `runtime/manifest.json` | catálogo como dado | sim |
| `docs/` | esta documentação | `WORKFLOWS.md` sim; o resto não |
| `docs/hub/` | produto com interface — **nada implementado** | não |
