# HRN-010 — Cada skill aparece uma vez por runtime, e a lista cabe no orçamento

| | |
|---|---|
| **Estado** | B aplicada — contrato verde; eval de roteamento não rodou |
| **Camada** | adapter (partes A e C) · L2 pack + máquina (parte B) |
| **Arquivos** | `get.sh` · `AGENTS.template.md` (novo) · índice do Git · `runtime/adapters/render.py` · `runtime/adapters/README.md` · `runtime/build.sh` · `install.sh` · `docs/ARCHITECTURE.md` · `README.md` · `system/workflows/harness-change/SKILL.md` · `system/pack/workflows/*/SKILL.md` e `system/workflows/*/SKILL.md` (só `description`) |
| **Data** | 2026-09-23 |

## História

Como **quem usa o harness em qualquer runtime**, quero **ver cada persona e cada skill uma
vez só, com a descrição inteira**, para **escolher o comando certo sem adivinhar entre cópias
e o roteamento não perder gatilho por corte**.

Hoje o `/` do Claude Code mostra `product-specialist` até 4 vezes. O Codex avisa "Skill
descriptions were shortened to fit the skills context budget". Cursor e OpenCode leem as
mesmas skills por várias pastas. A causa é o próprio adapter: ele planta a mesma árvore em
cada ponto de descoberta sem saber quais pastas cada runtime já lê.

## Pesquisa — o que cada runtime lê (documentação oficial, 2026-09-23)

| Runtime | Pastas de skill do projeto | Duplicata de nome | Orçamento |
|---|---|---|---|
| Claude Code 2.1.280 | só `.claude/skills` (+ pais até a raiz do repo, subpastas sob demanda). **Não lê `.agents/skills`** | skill **sobrepõe** `.claude/commands` de mesmo nome; symlinks para o mesmo alvo carregam uma vez | 1.536 caracteres por descrição |
| Codex 0.155 | `.agents/skills` (cwd, pai, raiz do repo) + `~/.agents/skills`. **Não lê `.codex/skills`** | "não mescla; as duas aparecem" | lista inicial ≈ 2% do contexto ou **8.000 caracteres**; estourou → encurta descrições, depois omite skills |
| Cursor | `.agents/skills`, `.cursor/skills`, `.claude/skills`, `.codex/skills` (+ as quatro no `~`) | não documentado | — |
| OpenCode | `.opencode/skills`, `.claude/skills`, `.agents/skills` (+ `~`) | não documentado ("garanta nomes únicos") | — |

Medido no projeto `websis-pat`:

- As 28 descrições do harness somam **16.422 caracteres** no projeto (27 na fonte, em
  `ded8dd1`: 15.955, todas acima de 350), o dobro do orçamento do Codex sozinho. Maiores: `harness-change` 902, `design-brief` 777, `backlog-prioritization` 774.
  Dez descrições terminam com o mesmo "IMPORTANTE: leia …/INTERFACE.md …" (~90 caracteres
  cada), que só é útil depois que a skill já foi escolhida.
- O log de debug do Claude (`--debug-file`) confirma: `project: 25` skills e
  `legacy commands: 4` (`product-specialist`, `product-designer`, `tech-lead`,
  `product-manager`). As skills não estão em `.agents/skills`, nem em `~/.claude/skills`
  (tem só `orca-cli`, `orchestration` e os sincronizados do claude.ai), nem em outro
  `.claude/` aninhado.

O que cada runtime vê hoje:

| Runtime | Ponteiros que o build planta | Cópias de cada skill que o runtime enxerga |
|---|---|---|
| Claude | `.claude/skills` + `commands/<persona>.md` + `agents/<persona>.md` | skill + comando + subagente por persona |
| Codex | `.agents/skills` + `.codex/skills` (não lido) | 1 (o ponteiro `.codex/skills` é peso morto) |
| Cursor | `.agents/skills`, `.cursor/skills`, `.claude/skills`, `.codex/skills` + `rules/<persona>.mdc` | até **4** por skill + a rule da persona com a mesma descrição |
| OpenCode | `.claude/skills`, `.agents/skills` + `agent` no json | 2 por skill |

**Não reproduzido:** a terceira linha idêntica do `/product-specialist` no Claude (o print
mostra três com a descrição longa). Pela documentação, subagente não entra no `/`. O
critério CA-03 existe para fechar isso olhando o menu depois da parte A, não por
suposição.

## Regras de negócio

- **RN-01.** Toda persona continua invocável em todo runtime pelo mesmo nome
  (`/product-specialist` ou `@product-specialist`). Tirar uma cópia não pode tirar a porta
  de entrada.
- **RN-02.** Cada runtime recebe **no máximo um** ponteiro de descoberta por árvore de
  skills, entre os que ele lê de fato. `.agents/skills` fica (é o do Codex e também serve
  Cursor e OpenCode). `.claude/skills` fica (é o único que o Claude lê).
- **RN-03.** O subagente (`runtime/claude/agents`, `runtime/codex/agents`, `agent` do
  OpenCode) continua sendo gerado. Ele é a porta de delegação, não uma cópia da skill.
- **RN-04.** A `description` continua sendo o **único** lugar do gatilho. Encurtar não
  pode tirar a frase literal que um caso de eval usa para acionar a ação.
- **RN-05.** A soma das descrições do harness fica **abaixo de 8.000 caracteres**, com
  folga para as skills do usuário: alvo de 6.000, nenhuma descrição acima de 350.
- **RN-06.** O aviso de provider ("leia `system/providers/<domínio>/INTERFACE.md` antes de
  qualquer operação") não se perde: ele sai da `description` e passa a morar no corpo, na
  linha `Provider` da tabela de camadas, que toda skill com provider já tem.
- **RN-07.** O build reprova (`--strict`) descrição acima do teto e soma acima do
  orçamento. Sem isso o problema volta na próxima skill.

## Parte A — adapter (sem mudança de conteúdo)

1. **Claude: parar de gerar `commands/<persona>.md`.** A skill de mesmo nome já é o
   `/product-specialist` e, pela documentação, sobrepõe o comando. O alias
   (`product-manager`) continua sendo comando, porque não existe skill com esse nome.
2. **Cursor: parar de gerar `rules/<persona>.mdc` e `rules/<alias>.mdc`.** O Cursor já lê
   as skills. Fica só `harness.mdc` (`alwaysApply`: constituição + persona padrão). O texto
   dele passa a apontar `.agents/skills`.
3. **Ponteiros: tirar `runtime/codex/skills` e `runtime/cursor/skills`.** Continuam
   `.agents/skills` (Codex, Cursor, OpenCode) e `runtime/claude/skills` (Claude).
   Consequência que fica: Cursor e OpenCode leem `.claude/skills` **e** `.agents/skills`,
   que apontam para a mesma árvore (ver CA-05).
4. **Tirar do Git o que é gerado.** `.gitignore` já lista `runtime/claude/{agents,commands}`,
   `runtime/codex/agents`, `runtime/cursor/rules`, `runtime/opencode/opencode.json` e os
   ponteiros `*/skills`, mas 18 desses arquivos continuam versionados (entraram antes da
   regra, em `846fc50`). Resultado: todo `git pull` do harness reescreve adapter no
   projeto, e todo build deixa `.agents/` sujo. Os de `product-specialist` não estão
   versionados e os das outras personas estão: é por isso que o pull de `ded8dd1` mexeu em
   `commands/tech-lead.md`. Correção: `git rm --cached` nos 18, sem apagar do disco.
5. **Limpeza em projeto já instalado:** o build apaga o que ele mesmo gerava e não gera
   mais (`claude/commands/<persona>.md`, `cursor/rules/<persona>.mdc`, os dois ponteiros).
   Nunca apaga arquivo que não gerou.

## Parte C — constituição em toda sessão

Hoje só Cursor (`harness.mdc`) e OpenCode (`instructions`) carregam a L0 sempre. No Claude e
no Codex ela só entra quando uma skill é acionada, e a `harness-change` afirmava "L0 já está
carregada" sem que nada a carregasse. Os quatro runtimes leem `AGENTS.md` da raiz (Claude
desde 2.1.277, se não houver `CLAUDE.md`; o Claude expande `@caminho`).

1. `AGENTS.template.md` na raiz do harness: ponteiros `@.agents/system/CONSTITUTION.md` e
   `@.agents/org/ORG.md`, mais a instrução em prosa para runtime que não expande `@`.
2. `install.sh` semeia `AGENTS.md` só se não existir. Existe sem apontar a constituição →
   aviso com a linha a colar. `CLAUDE.md`/`CLAUDE.local.md` sem `@AGENTS.md` → aviso (o
   Claude lê ele no lugar do `AGENTS.md`). Nunca edita arquivo do projeto.
3. `harness-change` §0: a L0 chega pelo `AGENTS.md`; sem ele, a skill manda ler.

## Parte B — orçamento de descrição (conteúdo; só depois da A estar verde)

1. **Nova regra em `harness-change` §3:** `description` = gatilho, no máximo 350
   caracteres. Frases literais do usuário e desempate com a vizinha; nada de instrução de
   execução. Isso **substitui** a regra atual "a description termina apontando a
   `INTERFACE.md`", que passa para a linha `Provider` do corpo. `docs/ARCHITECTURE.md`
   acompanha no mesmo movimento.
2. **Reescrever as 28 descrições** sob essa regra. Cada uma entra na proposta como antes e
   depois, com a contagem de caracteres, para aprovar em lote.
3. **Workflows internos** (`figma-node-reader`, `html-to-figma`, que só outra skill aciona):
   descrição mínima de uma linha. Marcar como não invocável pelo modelo **só se** o Codex e
   o Cursor respeitarem o campo; senão fica só a linha curta.
4. **Checagem no build:** teto por descrição e soma, com aviso no modo normal e reprovação
   no `--strict`.

## Impacto

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | `runtime/adapters/README.md:14,15,31,34` ("primary também vira slash-command", "slash-command por linha", "Cursor lê `.cursor/skills`") · `harness-change/SKILL.md:533,534,547,695` (mesmo contrato do `PERSONA.md`) · `docs/ARCHITECTURE.md:180-183` (tabela de runtimes) · `README.md:47,239` (`.cursor/rules/*.mdc`, teste do `harness.mdc`) · `render.py:273` (texto do `harness.mdc`) · `install.sh:61,148` e `build.sh:152-190` (plantio dos `.mdc`) | atualizar todos (parte A). `harness.mdc` continua existindo, então o teste do `README.md:239` segue válido |
| Esteira | nenhum. Descrição e adapter não mexem em `produz`/`requer` | — |
| Evals | as fontes `caso.yaml` usam `frase` literal e testam roteamento pela `description`. A parte B pode quebrar gatilho | rodar `runtime/eval.sh` na suíte inteira antes e depois da parte B, e comparar |
| Git | 18 adapters gerados versionados apesar do `.gitignore` (`git ls-files runtime`) | `git rm --cached` (A.4). No `pull` seguinte o Git apaga os arquivos do projeto; o `build.sh` que já roda depois do pull recria |
| Organização | `aliases.tsv` (1 linha: `product-manager`) continua valendo. `PERSONA.md` sobrescrito em `org/` continua valendo: `mode: primary` deixa de gerar comando no Claude, mas a skill cobre. Nenhum encaixe muda de caminho. Projetos instalados com `.cursor/` real (IDE) têm symlinks `.mdc` plantados que viram órfãos | limpar os symlinks `.mdc` que apontam para `runtime/cursor/rules/` e não existem mais (parte A.4) |
| Camada | A: adapter, certo, porque é como o runtime descobre a persona. B.1: regra de arquitetura, mora em `harness-change` + `ARCHITECTURE.md`. B.2: conteúdo L2 do pack e da máquina | mantém |

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | build gera zero `runtime/claude/commands/<persona>.md` e zero `runtime/cursor/rules/<persona>.mdc`; o alias continua em `commands/` | `./build.sh --strict` + `ls runtime/claude/commands runtime/cursor/rules` |
| CA-09 | `git ls-files runtime` só lista `adapters/`, `build.sh` e `eval.sh`; build seguido de `git status` deixa `.agents/` limpo | `git ls-files` + `git status --short` |
| CA-10 | projeto novo ganha `AGENTS.md`; projeto com `AGENTS.md`/`CLAUDE.md` próprios não é editado e recebe aviso | `install.sh` em projeto descartável, dois cenários |
| CA-11 | Claude carrega a constituição sem acionar skill | `claude -p` pergunta o título da §1 sem ferramenta |
| CA-02 | `runtime/codex/skills` e `runtime/cursor/skills` não existem depois do build, inclusive num projeto em que existiam | `./build.sh --strict` rodado duas vezes em cópia do `websis-pat` |
| CA-03 | no Claude, `/product-specialis` lista **um** `product-specialist` (skill) e o `product-manager` | log `--debug-file` com `legacy commands: 1` + olhar o menu (manual, único critério visual) |
| CA-04 | Codex: projeto sem o aviso "Skill descriptions were shortened" com as skills do harness | abrir o Codex no `websis-pat` depois da parte B (manual) |
| CA-05 | Cursor e OpenCode: verificar se deduplicam `.claude/skills` e `.agents/skills` (mesma árvore real). Se não deduplicarem, abrir HRN próprio (hoje não há como servir o Claude sem `.claude/skills`) | observação registrada no `Registro` |
| CA-06 | soma das descrições do harness < 6.000; nenhuma > 350 | `./build.sh --strict` (checagem nova da B.4) |
| CA-07 | nenhum caso de roteamento que passava antes da parte B falha depois | `./runtime/eval.sh` antes e depois, diff dos resultados |
| CA-08 | organização recém-criada sem aviso | `./build.sh --strict --org <vazio> --out <tmp>` |

## Fora de escopo

- **Skills do usuário fora do harness** (`~/.agents/skills` com caveman e orca, a cópia de
  `stop-slop` em `~/.codex/skills`, os plugins do Codex em `~/.codex/config.toml`). Isso é
  configuração local, não harness. Vai como recomendação à parte.
- Juntar subagente e skill numa entrada só. São portas diferentes (delegar × executar na
  thread).
- Parar de plantar `.claude/skills` porque Cursor e OpenCode também leem. O Claude não tem
  alternativa.

## Registro

Parte A e C, 2026-09-23:

- `./build.sh --strict` → 0. `runtime/claude/commands/` só com `product-manager.md`;
  `runtime/cursor/rules/` só com `harness.mdc`; sem `codex/skills` nem `cursor/skills`.
- Decisão do usuário: no Cursor a persona é chamada por `/`, então as rules por persona e a
  do alias saem sem substituto. O alias `product-manager` fica só no Claude.
- `git ls-files runtime` → só `adapters/`, `build.sh`, `eval.sh` (18 gerados saíram do
  índice, continuam no disco).
- Install em projeto limpo: `AGENTS.md` criado, `.cursor/rules` = `harness.mdc`. Em projeto
  antigo (`.cursor/` real com links órfãos, `codex/skills`, `AGENTS.md` e `CLAUDE.md`
  próprios): órfãos removidos, `minha.mdc` do usuário intacta, `codex/skills` removido, os
  dois arquivos do projeto intactos e os dois avisos emitidos.
- Claude 2.1.280 no projeto limpo: `legacy commands: 1` (antes 4), `AGENTS.md loaded`, e o
  modelo respondeu o título da §1 da constituição sem ferramenta (CA-03 pelo log, CA-11).
- `--strict --org <vazio>` reprova com "WORKFLOWS.md divergiu" — **pré-existente**:
  reproduzido com as mudanças guardadas no stash. Não é desta HRN.
- Não verificado: menu `/` do Claude a olho (CA-03 visual), Codex lendo o `AGENTS.md` (não
  expande `@`, depende da instrução em prosa), dedup de Cursor/OpenCode (CA-05).
- Fora do plano, pedido do usuário no meio da execução: `docs/` passa a vir no clone e no
  pull. `get.sh` clona sem sparse-checkout; `install.sh` desliga o sparse antigo
  (`!/docs/`) de instalações existentes. Motivo: as specs de `docs/mudancas/` são
  editadas a partir dos projetos.

Parte B, 2026-09-23:

- 27 descrições do harness: 15.955 → **5.560** caracteres. Maior: `backlog-query`, 266.
  Nenhuma acima de 350. `hu-narrative-generator` (467) é da organização e não entra
  nessa soma.
- Desvio do anexo: a description do `committer` **não** lista "commita isso" como
  gatilho. O caso `commita-sem-chamar` existe para essa frase não acionar
  `versionar-mudancas` (portão: só `@committer` / `$committer`). O texto do anexo
  faria o caso falhar. Ficou em 147 caracteres.
- O aviso de `INTERFACE.md` saiu da description e entrou na linha `Provider` das 11
  skills que o carregavam. Regra nova em `harness-change` §3 e em
  `docs/ARCHITECTURE.md` §5. Teto e soma viram aviso no build e reprovação no
  `--strict` (`TETO_DESCRICAO` 350, `ORCAMENTO_DESCRICOES` 6000).
- `python3 -m unittest discover runtime/tests` → 11 testes, ok. Cobre teto, soma,
  exclusão da organização, âncoras das frases de eval e o desempate com a vizinha.
- `./build.sh --strict --env` ausente → 0. `./build.sh --fix` não alterou
  `system/ACOES.md`. Com o `.env` do projeto, `--strict` reprova por 2 avisos
  pré-existentes de `doc-final-generator` (`layout-custom` × `pandoc`) — não são
  desta parte.
- `--strict --org` vazio → `WORKFLOWS.md divergiu` (23 ações, sem
  `hu-narrative-generator`). O mesmo efeito já estava no registro da parte A.
- `./runtime/eval.sh --tipo roteamento` não mede esta parte: o Claude respondeu
  "session limit" e o runner registrou isso como "não disparou". Codex e OpenCode
  não declaram `roteamento-skill`, então o caso sairia `NÃO-RODOU`. A suíte fica
  para quando a sessão do Claude resetar.
