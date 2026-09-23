# HRN-009 — Poda de contexto nas camadas L0 e L1

Estado: poda feita. Contrato verde. `--strict` sai 3 por aviso pré-existente. Eval de roteamento não chegou a rodar (limite de sessão).

`docs/mudancas/TEMPLATE.md` não está neste checkout. As seções abaixo são as que a
`harness-change` enumera no §5.3: história, camada, regras, critérios com prova, fora de
escopo, impacto e plano de arquivos.

## História

A persona de produto manda ler, em todo turno, a constituição, a profissão, o
`reasoning.md` e o `ORG.md`: 458 linhas, cerca de 3.900 palavras, antes de qualquer
workflow. Parte desse texto repete a constituição. A regra que isso descumpre está na
própria constituição, §8: camada de cima referencia a de baixo, nunca copia. E no §1:
texto que não muda a decisão se corta.

O que entra sempre no Cursor já é curto: `.cursor/rules/harness.mdc` é um ponteiro. O
peso está no "monte-se" da persona.

Modelo mais capaz não dispensa portão. Write-gate, um pedido = um passo, honestidade com
fonte citada e delegação com aprovação continuam. O que sai é paráfrase e catálogo que
já mora noutro arquivo.

## Camada

| Mudança | Camada | Por quê |
|---|---|---|
| Comprimir a constituição sem renumerar §1–§7 e sem afrouxar portão | L0 | `system/CONSTITUTION.md` |
| Tirar catálogo e paráfrase da identidade; podar gatilho que já está na L0 ou no método | L1 | `system/professions/<profissão>/` |
| Persona volta ao esqueleto do contrato, com o ponteiro do §3 que o teste exige | L2 pack | `system/pack/workflows/{persona}/PERSONA.md` |

Nada desce para workflow. Nada sobe o carve-out do protótipo para a L0: editar tela é
rascunho local só do product-designer. Levar isso para a constituição afrouxaria o
write-gate das outras profissões.

## Regras

1. **Número de seção estável.** §1 a §7 continuam sendo §1 a §7. Dezenas de skills citam
   esses números. Renumerar quebra a referência sem o build perceber.
2. **§8 sai.** É regra de quem edita o harness. A `harness-change` já a carrega, e a
   skill se declara autossuficiente. O preâmbulo da constituição já diz que, em conflito,
   ela vence. O resumo final, que repete o arquivo, sai junto.
3. **Portão não se poda.** §2, §5 e §7 podem perder frase que repete a regra. Não podem
   perder a regra: aprovação antes de estado externo, um pedido = um passo, delegação
   com aprovação e tarefa bounded.
4. **§1 continua sendo o piso de prosa.** O `stop-slop` declara que o §1 vale em toda
   escrita e que o passe fino mora nos `references/` dele. O §1 fica curto (comece pela
   resposta; corte o que não muda a decisão; afirme, sem contraste mecânico; sem
   abertura que anuncia e sem fecho que concede). O catálogo de tells não entra aqui e
   não sai do `stop-slop`.
5. **§3 guarda as fontes de leitura verbatim.** O teste `tests/fontes-de-leitura.sh`
   (CA do HRN-008) exige na constituição: `codigo_fonte.caminho`, `caminhos.contexto`,
   `caminhos.entregaveis`, `caminhos.pasta_por_demanda`, `caminhos.historico`,
   `prototype/`, `solução vigente`. As três condições de pergunta — resultado ambíguo,
   escolha cara sem precedente, ação externa irreversível — ficam.
6. **§4 e §6 ficam.** Citar fonte, lacuna em aberto, suposição declarada. Método desvia
   se o contrato sair inteiro e nenhum portão for pulado.
7. **Profissão não reescreve autonomia.** A seção de autonomia aponta §2, §3 e §5. A
   única frase que não está na constituição e tem de ficar é a do product-designer: editar
   protótipo (tela, componente, token, rota) é rascunho local e não passa pelo write-gate.
   Publicar no canvas ou em servidor passa.
8. **Catálogo de método sai do arquivo que todo turno carrega.** No product-specialist o
   bloco anotado (dezenas de métodos com "para quê") vira uma linha: métodos em
   `methods/`; carregue o arquivo cujo nome casa com a situação; o "quando usar" mora no
   método. As tabelas curtas de tech-lead e product-designer (seleção, menos de dez
   linhas) ficam. O parágrafo do tech-lead que aponta métodos compartilhados do PM fica:
   é o único índice cruzado.
9. **Gatilho sai do `reasoning.md` só com destino.** Cada bullet removido declara um
   destino: já está na constituição §N, ou já está no "Quando usar" de
   `methods/<arquivo>.md`. Bullet sem destino fica. Não é reescrita do zero.
10. **Persona não duplica a constituição.** O corpo segue o esqueleto do contrato da
    `harness-change` §3.2 (carregar a skill, thread principal, delegar com aprovação) mais
    a frase literal `constituição §3`, que o teste exige em `PERSONA.md` e em `SKILL.md`.
    O carve-out do protótipo não se repete na persona: a skill manda carregar a profissão,
    e a frase mora lá.

### Orçamento

Prova: `wc -w` nos arquivos abaixo. O alvo é teto, não cota para preencher.

| Arquivo | Palavras hoje | Teto |
|---|---|---|
| `system/CONSTITUTION.md` | 1180 | 750 |
| `system/professions/product-specialist/PROFESSION.md` | 898 | 450 |
| `system/professions/product-specialist/reasoning.md` | 1173 | 450 |
| `system/professions/product-designer/PROFESSION.md` | 580 | 400 |
| `system/professions/product-designer/reasoning.md` | 619 | 450 |
| `system/professions/tech-lead/PROFESSION.md` | 323 | 323 |
| `system/professions/tech-lead/reasoning.md` | 291 | 291 |

Tech-lead já está no tamanho da seleção. Só perde frase se a conferência achar paráfrase
de L0 com destino; o teto não obriga corte.

As três `PERSONA.md` primárias perdem os itens que reescrevem §2, §5 e §7. Não há teto de
palavra: o teste de fontes é a prova.

## Critérios de aceite

| Critério | Prova |
|---|---|
| §3 e o ponteiro `constituição §3` nas três personas sobrevivem | `bash tests/fontes-de-leitura.sh` sai 0 |
| Personas ainda resolvem; nenhuma declaração diverge | `./build.sh --strict` sai 0 |
| Organização recém-criada não perde padrão de pack | `./build.sh --org <dir vazio> --out <temporário>` sem aviso de "sem padrão no pack" |
| Nenhuma ação nem encaixe mudou | `./build.sh --fix` não altera `system/ACOES.md` |
| Orçamento da tabela acima | `wc -w` em cada arquivo ≤ teto |
| Bullet removido de `reasoning.md` tem destino | tabela de conferência de perda anexada ao Estado na fase 2; linha sem destino não entra no diff |

Persona não ganha `evals/`: o gatilho dela é o adapter, não a skill.

## Fora de escopo

- `org/ORG.md` e o scaffold. Língua, nome de arquivo e funil ganham o lugar que ocupam.
- Corpo de `methods/*.md`. A poda do reasoning aponta para eles; não os reescreve.
- Desempates dentro do `SKILL.md` das personas. São roteamento calibrado, não catálogo.
- `figma-node-reader`. O corpo é contrato de transcrição, não bootstrap de produto.
- Gerar `AGENTS.md`. Continua override local opcional, que a constituição vence.
- `docs/ARCHITECTURE.md` e `docs/MANUTENCAO.md`. Não estão neste checkout. Tirar o §8
  remove o ponteiro morto para `docs/ARCHITECTURE.md` §2. Recriar o ensaio é outra mudança.
- Afrouxar write-gate, portão humano ou o carve-out do protótipo.

## Impacto

Varredura em `system/`, `org/`, `runtime/adapters/`, `README.md`. `runtime/skills/` ficou
de fora: é gerado.

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | `CONSTITUTION.md` e §1–§7 são referência em skills, providers e nas três personas. Cópias que esta mudança resolve: autonomia do product-designer (`PROFESSION.md`), itens 2–6 das `PERSONA.md` primárias, bullets de `reasoning.md` que repetem §3 e §4. `runtime/opencode/opencode.json` aponta o arquivo; o caminho continua válido. | Manter os números §1–§7. Não editar o gerado. |
| Esteira | As três personas declaram só `objetivo`. Sem `produz`. | Vazio. |
| Evals | Nenhum `caso.yaml` cita `persona-produto`, `persona-tecnica` ou `persona-design`. | Vazio. Ações não são renomeadas. |
| Organização | `org/professions/` só tem `README.md` de extensão. Nenhum overlay das três profissões. Encaixes de workflow não são alvo. | Preservar o README. Nada a migrar. |
| Camada | Poda fica em L0 e L1. O carve-out do protótipo permanece L1. | Mantém. |

## Plano de arquivos

Fonte. O build regenera `runtime/skills/` e os adapters. Não editar o gerado.

| Arquivo | O que entra | O que sai |
|---|---|---|
| `system/CONSTITUTION.md` | §1–§7 com as mesmas regras e as mesmas chaves do §3 | §8, resumo final, frase repetida dentro de §1–§7 |
| `.../product-specialist/PROFESSION.md` | Identidade, lentes, escopo, tom, uma linha para `methods/` | Catálogo anotado; autonomia reescrita |
| `.../product-specialist/reasoning.md` | Gatilho cujo destino não existe em outro arquivo | Bullet que já está na L0 ou no método |
| `.../product-designer/PROFESSION.md` | Carve-out do protótipo, em uma frase; tabela curta de métodos | Paráfrase do §3 |
| `.../product-designer/reasoning.md` | Gatilho de design (ajuste, componente, navegação, estados, rabisco) | "Vontade de perguntar", "fila de perguntas", "pedido só com o resultado" — são o §3 |
| `.../tech-lead/PROFESSION.md` e `reasoning.md` | Como estão, salvo paráfrase com destino | Só essa paráfrase, se a conferência achar |
| `system/pack/workflows/{product-specialist,tech-lead,product-designer}/PERSONA.md` | Esqueleto §3.2 + a frase `constituição §3` | Itens que reescrevem §2, §5, §7 e o carve-out já dito na profissão |

`SKILL.md` das personas não muda: a ordem de montagem (constituição → profissão e
reasoning → `ORG.md`) continua, e é ela que faz o arquivo menor valer no turno seguinte.

## Conferência de perda

Bullet que saiu e para onde foi a regra. Linha sem destino não saiu.

| Origem | Saiu | Destino |
|---|---|---|
| constituição | §8 e o resumo final | `harness-change` já carrega a tabela de camadas; o preâmbulo já diz que a L0 vence |
| constituição §1 | catálogo fino de tells | piso curto ficou; o passe continua em `stop-slop` |
| constituição §2 | "mesmo que pareça óbvio…" | a frase seguinte: aprovação de um passo não vale para o próximo |
| constituição §3 | "iterar alinha mais rápido…" | "escolha o caminho, execute e declare a suposição" |
| PM reasoning | pedido só com o resultado | §3 |
| PM reasoning | conflito entre fontes | §3 e §4 |
| PM reasoning | pergunta sem workflow | identidade da profissão; não é portão |
| PM reasoning | prazo vs ansiedade | `cost-of-delay.md`, barra |
| PM reasoning | feedback em muitos canais | `voice-of-customer.md`, quando usar |
| PM reasoning | "vamos testar" sem critério | `experiment-design.md`, barra |
| PM reasoning | mudança que afeta outra área | `stakeholder-mapping.md`, quando usar |
| PM reasoning | ideia nova contra o roadmap | `prfaq.md`, quando usar |
| PM reasoning | agregado bonito | `segmentation.md`, quando usar |
| PM reasoning | atualização como lista | `written-update.md`, quando não |
| PM reasoning | pedido recusado em silêncio | `saying-no.md`, quando não |
| designer reasoning | vontade de perguntar; fila de perguntas; pedido só com o resultado | §3. "Entregue uma versão junto" ficou na autonomia da profissão |
| designer PROFESSION | paráfrase do §3 (a)(b)(c) | §3. Carve-out do protótipo e plano proporcional ficaram |
| tech-lead PROFESSION | "recebeu só o resultado…" | §3. Escrita no banco continua com portão §2 |
| três PERSONA | autoguard, write-gate reescrito, carve-out repetido | §2, §5, §7 e a profissão do designer |

## Provas

| Prova | Resultado |
|---|---|
| `bash tests/poda-de-contexto.sh` | CA-01 a CA-06 ok. Palavras: constituição 750 (era 1180), profissão PM 384 (898), reasoning PM 405 (1173), profissão designer 351 (580), reasoning designer 323 (619), tech-lead 299 (323) e reasoning 291 (igual) |
| `bash tests/fontes-de-leitura.sh` | ok. §3 e `constituição §3` nas três personas |
| `bash tests/seed-codigo-fonte.sh` | ok |
| `system/providers/knowledge/tests/sync-context-move.sh` | ok |
| `./build.sh --fix` | sai 0. `system/ACOES.md` não mudou (hash `6ee7af2b136a52d74600c873e5b4927d88207778`) |
| `./build.sh --strict` | sai 3. 0 erros. 2 avisos pré-existentes: encaixes `gerador` e `marca` de `doc-final-generator` pedem `layout-custom`, e o provider ativo é `pandoc`. Não é desta poda |
| `./build.sh --org <vazio> --out <temp>` | nenhum aviso de "sem padrão no pack". O comando na árvore real ainda esbarra em `WORKFLOWS.md` gerado com a organização real — o mesmo limite já registrado no HRN-008 |
| `./runtime/eval.sh --tipo roteamento` em discovery, design-brief, design-screen, doc-consolidator, committer, db-query, backlog-query, backlog-issue-creator, stop-slop, sprint-goal-generator | não mede a poda. O Claude headless devolveu 429 ("session limit · resets 3:30pm America/Sao_Paulo") antes de chamar skill. O runner marcou "não disparou". O init da sessão listava as skills do harness, inclusive as dez. O caso negativo do committer passou pelo mesmo motivo: nenhuma skill disparou |

O que a execução mostrou e a spec não previa: a constituição encostou no teto de 750, sem sobra. O tech-lead perdeu 24 palavras, a paráfrase do §3, e o reasoning dele não tinha o que cortar.
