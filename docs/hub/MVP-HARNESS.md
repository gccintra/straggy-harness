# Harness × Hub — o que falta para começar o frontend

**Ler primeiro:** o resumo de uma página — [`MVP-HARNESS-RESUMO.md`](MVP-HARNESS-RESUMO.md).
Este arquivo é o raciocínio; aquele é a fila.

Revisão do harness contra o MVP, feita em **2026-08-31**, lendo o repositório e cruzando com
[`MVP.md`](MVP.md), [`MVP-RELEASES.md`](MVP-RELEASES.md), [`MVP-TECNICO.md`](MVP-TECNICO.md)
e [`HUB.md`](HUB.md).

**Resposta.** Não precisa terminar o harness para começar o frontend. A R1 (repositório de
contexto, **sem IA**) quase não toca o motor. O contrato que a interface consome — manifesto,
encaixes, esteira como grafo — **já existe e passa em `--strict`**. O que falta no harness
é uma fila curta, já no Linear, e um item só dela bloqueia a R1: o schema de frontmatter
(`HT-11` / `STR-53`).

> **Linear nesta sessão.** O MCP do Linear não está conectado aqui e não há `.env` com
> `LINEAR_API_KEY`. A lista de issues abaixo é a do board declarado em
> [`MVP-RELEASES.md`](MVP-RELEASES.md) (estado **2026-08-30**, workspace `straggy-hub`, time
> `STR`). Não dá para afirmar o status atual (Backlog / Started / Done) sem abrir o Linear.
> O repo GitHub `gccintra/straggy-harness` não tem issues — o board é o Linear.

---

## 1. O que isto muda na decisão de começar o frontend

O MVP tem duas metades. Só a segunda precisa do motor:

| Onda / release | O que a pessoa usa | Precisa do harness? |
|---|---|---|
| **R1 · um lugar só para o contexto** | espaço, login, documento `.md`, pasta, upload, filtro por metadado | **quase não.** Precisa do schema de frontmatter (`HT-11`) para o produto e o motor não divergirem. O resto é aplicação |
| **R2 · do pedido ao publicado** | conversa, ação, portão, preview, chave de IA, GitHub/GitLab | **sim.** Motor, adapter, materializador e providers. Ainda assim, o catálogo que a tela lê já está pronto |
| **R3 · estruturas e Drive** | roadmap/persona/OKR, sync Drive, superfície de conexão | **parcial.** Uma ação nova no pack (`HT-15`); o resto é produto |

Regra prática: **feche a R0 (decisões + schema + um lugar onde a app roda) e comece o
frontend da R1.** O restante do harness anda em paralelo, não na frente.

O teste da R1 está escrito no MVP: duas semanas de uso **sem nenhuma IA**. Se essa onda não
for usada sozinha, a tese do contexto único está errada — e a R2 vira o produto inteiro.
Começar o frontend da R2 antes desse sinal é o cenário 1 do pré-mortem.

---

## 2. O que o harness já entrega — não refaça

Verificado em 2026-08-31: `./runtime/build.sh --strict` sai **0**, `0 aviso(s)`.
`HUB.md` §7.1–7.8 está feito. Isto é o contrato que o frontend da R2 vai ler:

| Peça | Onde | O que a interface faz com isso |
|---|---|---|
| Metadado de encaixe (`rotulo`, `ajuda`, `tipo`, `essencial`) | frontmatter das skills | desenha o formulário de `HU-02` sem ler skill |
| Manifesto determinístico | `runtime/manifest.json` (`schema: 1`) | API do catálogo: 23 ações, 4 personas, 6 artefatos da esteira |
| `build.sh --org` / `--out` / `--strict` / `--env` | `runtime/build.sh` | o materializador (produto) aponta o `org/` e a saída; o build não muda |
| Esteira como grafo (`produz` / `requer` / `requer_condicional`) | 6 ações | o backend bloqueia o passo seguinte sem interpretar prosa |
| Provider declara `capacidades` + `requisitos` | frontmatter das implementações | a tela de conexão (`HU-18`) e o provisionamento lêem o manifesto |
| Caminhos via `project-config.yaml`, não literal | `caminhos.*` | artefato migra de pasta para armazenamento do produto sem tocar skill |
| Encaixe `tipo: estrutura` + schema no sistema | `system/schemas/funil-priorizacao.yaml` | o construtor de funil (`HUB.md` §3.4) já tem o primeiro vocabulário |
| Padrão de `procedimento.md` no pack | 19 workflows | “encaixe vazio → padrão do pack” deixou de ser falso. A nota de `HUB.md` §7.1 (14 ações sem padrão) **está velha** |

O manifesto ainda publica `"harness": { "release": null }` — `HARNESS_RELEASE` existe, mas
ninguém preenche. É critério de `HT-02` / `DEC` de versão, não bloqueio de tela.

**O Hub não precisa de um quarto adapter em arquivo.** `HUB.md` §7.7 já absorveu isso: a
persona é registro no manifesto. O adapter de produto que a R2 pede (`MVP-TECNICO.md` DT-03)
é interceptação de ferramenta no processo do app — código do **produto**, gerado a partir
do mesmo `PERSONA.md`, sem API de runtime dentro de skill.

---

## 3. O que ainda é harness — fila real, não manutenção

M24 atravessa as três ondas de propósito. No Linear isso são **cinco issues** (`area:Harness`),
não um épico solto. Estado no repositório hoje:

### 3.1 R0 — o único item de harness que a R1 espera

| Linear | Código | O que é | Estado no repo | Por que a R1 espera |
|---|---|---|---|---|
| **STR-53** | HT-11 | Schema de frontmatter em `system/schemas/`, uma fonte só: o produto valida na escrita, o harness lê na execução | **Não existe.** `system/schemas/` tem só `funil-priorizacao.yaml`. Não há schema de documento | `HU-05` (filtro por metadado) está `blocked by` isto. Sem o schema, a R1 inventa um e o motor inventa outro — é a definição de divergência |

Campos que o MVP já fechou (`MVP.md` M17, `MVP-TECNICO.md` DT-08):

```yaml
# rascunho do contrato — a issue é escrever isto em system/schemas/ e amarrar o eval
obrigatórios: [tipo, titulo, status, atualizado_em]
opcionais:    [demanda, tags, origem]
tipo:         lista fechada (a mesma que define as estruturas da R3)
```

Isto é YAML de vocabulário, não tela. Fecha em um dia e destrava o editor da R1.

Junto, mas **não é harness**: `DEC-03` (STR-16) decide *onde* o documento mora (banco +
objeto). O schema é o *que* ele contém. Os dois se falam; nenhum substitui o outro.

### 3.2 R2 — o motor precisa disto para não regressar ao genérico

| Linear | Código | O que é | Estado no repo | Risco se adiar |
|---|---|---|---|---|
| **STR-54** | HT-12 | Ações leem contexto por **consulta** (filtro), não por caminho de disco | Skills pedem “o contexto do produto” via `knowledge/`. A implementação única é `drive-rclone` → `docs/context_docs/md/`. Overlay `org/` ainda cita caminho literal (`Referencias-Globais.md`, funil em `docs/context_docs/…`) | Sem isto, a R2 executa varrendo pasta. O repositório da R1 vira Drive com outro nome |
| **STR-55** | HT-13 | Tirar identidade de cliente do pack: `cliente` / `ordem_servico_padrao` opcionais; tipo e nome de artefato declarados; `.docx` fora do destino assumido; scaffold neutro | **Parcial.** Scaffold `org-scaffold/ORG.md` já é neutro (`{ID}_{NomeCurto}.md`). `project-config.template.yaml` ainda tem `cliente`, `ordem_servico_padrao`, `label_header_hu` / `_ht` = “HISTÓRIA DE USUÁRIO/TÉCNICA”, `token_arquivo` no padrão `{HU\|HT}…`. `doc-final-generator` e `prototype-prints` ainda lideram com `.docx` e subpasta `HU08.02` | Time in-house esbarra em campo de consultoria e conclui que o produto não é para ele. É pré-requisito do alpha (`discovery/04`), não polish |
| **STR-56** | HT-14 | Lacunas do provider de backlog que os workflows já assumem | Ver §3.4. GitHub e GitLab cobrem o núcleo da R2 (ler / criar / atualizar / comentar). GitHub **não tem wiki**. Linear (este board) **não tem `sprints-write`**. `knowledge/` ainda não tem implementação “base nativa do Hub” | A14: se a pessoa reabre o GitHub na mão em >30% das demandas, a decisão de não ter backlog próprio volta à mesa |

**Restrição que não pode quebrar em HT-12** (`ARCHITECTURE.md` §5, `MODOS.md` §3): skill
**não sabe** se está no app. Não existe `if hub then API`. O materializador (produto, DT-04)
entrega o mesmo formato de arquivo que `caminhos.contexto` já é. A skill continua lendo
arquivo; quem muda é a *origem* da pasta. Implementação nova em `knowledge/` (“base nativa”)
é o encaixe certo — não um `fetch` dentro do workflow.

### 3.3 R3 — uma ação nova sobre repertório que já existe

| Linear | Código | O que é | Estado no repo |
|---|---|---|---|
| **STR-57** | HT-15 | Ação declarada para estruturas de produto (roadmap, personas, OKR, lean canvas, story map) | **86 métodos** em `system/professions/*/methods/` com contrato de saída. **Zero ações** no catálogo. `roadmap.md`, `okr.md`, `lean-canvas.md`, `story-mapping.md` já prescrevem a forma; falta o workflow que grava o artefato no espaço, com portão |

Não é inventar método. É o mecanismo de extensão que a arquitetura já tem: ação nova +
encaixe de estrutura + `tipo` no schema de frontmatter da `HT-11`. Fora do caminho crítico
do frontend da R1.

### 3.4 Lacunas concretas de provider (o conteúdo da STR-56)

O que a interface promete × o que cada implementação faz hoje:

| Operação | GitHub (`gh`) | GitLab (`glab`) | Linear (MCP) | Precisa na R2? |
|---|---|---|---|---|
| Ler demanda + comentários | sim | sim | sim | **sim** (`HU-16`) |
| Criar / atualizar / comentar | sim | sim | sim | **sim** (`HU-17`) |
| Export em lote | sim | sim | sim (GraphQL ou MCP) | não na jornada da demanda; sim em análise |
| Wiki | **não** | sim | sim (documents) | R2 se o destino do entregável for wiki |
| Criar/fechar sprint | sim (milestone) | sim | **não** | não no catálogo reduzido da R2 |
| Bloco na descrição | regex no corpo inteiro | nativo o bastante | `patch` atômico | priorização (`HU-13`, R3) |

O MVP do Hub usa **GitHub ou GitLab**, não Linear, no produto (`M13`). Linear aqui é o
board *deste* harness. Não misturar: fechar lacuna do Linear não é item da R2 do Hub.

Fora da tabela, e mais caro que qualquer linha dela: **não existe implementação `knowledge/`
nativa.** `INTERFACE.md` já reserva “base nativa do Hub”. Sem ela, HT-12 não tem onde
plugar — o materializador até pode copiar documentos do servidor para `caminhos.contexto`,
e isso basta na R2 se o contrato de arquivo for o mesmo. A implementação nomeada pode
esperar; o contrato da pasta, não.

`MVP-TECNICO.md` Parte 1 ainda diz “o harness declaradamente não usa MCP”. Isso **divergiu
do repo**: `linear-mcp.md` existe, `BACKLOG_PROVIDER=linear` está no `.env.example`. A
regra que vale é a interface, não a frase velha. Provider continua sendo *comando no
ambiente de execução*; MCP é transporte de uma implementação, não mudança de arquitetura.
O adapter do Hub intercepta ferramenta — inclusive a que chama `gh`/`glab`.

### 3.5 Trabalho de harness que não tem issue própria — e deve ter critério, não issue nova

| Item | Onde aparece hoje | O que fazer |
|---|---|---|
| CI rodando `build.sh --strict` e `eval.sh` | `HT-03` / **STR-23** (`area:Infra`). Não há `.github/workflows` nem `.gitlab-ci.yml` neste repo | critério da STR-23; não abrir issue de harness paralela |
| `eval.sh` em CI a cada mudança de workflow | `MVP-TECNICO.md` T7; absorvido por HT-11 + HT-03 | o eval de contrato do schema entra na HT-11; o runner de comportamento na STR-23 |
| Adapter de produto / interceptação | DT-03 → **DEC-01** / STR-14 + **HT-10** / STR-43 | produto, não pack. Skill não muda |
| Materializador do `org/` | DT-04 → **DEC-02** / STR-15 + **HT-08** / STR-33 | produto. `build.sh --org/--out` já é o ponto de troca |
| Padrões de `procedimento.md` | `HUB.md` §7.1 dizia pendente | **feito** no pack (19 arquivos). Overlay `org/` deste repo ainda é o fluxo de origem (HU/HT, GL, `.docx`) — isso é camada da organização, não do pack |

---

## 4. O que *não* é harness — para o frontend não esperar o motor

Estas issues são produto. Tratar como “trabalho no harness” é como a R2 nunca começa.

| Área | Issues | Por que não é pack |
|---|---|---|
| Decisões | STR-14…19 (`DEC-01`…`06`) | arquivo em `docs/decisions/`. `docs/decisions/` **ainda não existe** |
| Infra | STR-21, 22, 23 (`HT-01`…`03`) | hospedagem, instalador, CI |
| Espaço | STR-24, 25, 26, 27 | login, modelo, encaixes na tela, histórico |
| Contexto | STR-28, 29, 30, 31 | documento, editor, busca, API de contexto (servidor) |
| Motor | STR-32…36 | executor Node, chave no cofre, sessão |
| Ações (UI) | STR-37…42 | conversa e telas que *disparam* as ações que o pack já tem |
| Portão | STR-43, 44, 45 | interceptação + máquina de estados no servidor |
| Conexões | STR-46, 47, 48 | OAuth e superfície; o CLI `gh`/`glab` já existe |
| Estruturas (UI) | STR-49, 50 | editor da forma; a forma em si é HT-15 |
| Drive | STR-51, 52 | OAuth; hoje é rclone + service account |
| Medição | STR-58, 59 | planilha/área no espaço |
| IP do pack | STR-20 | **fora de release**, antes da 1ª venda, não antes de codar |

A API de contexto (`HT-06` / STR-31) é **servidor**. HT-12 é o pack passar a *consumir o
resultado materializado*. São issues irmãs, donos diferentes: produto materializa; harness
não varre o disco inteiro por hábito.

---

## 5. O board — as 46 issues, para começar por elas

Fonte: [`MVP-RELEASES.md`](MVP-RELEASES.md) §2–5, estado Linear **2026-08-30**.
`!` = label `Bloqueante`. **Harness** = as cinco da §3. O restante é produto, decisão ou infra.

### R0 · Fundação — 11 issues (+ 1 fora de release)

Comece aqui. Sem isto, frontend da R1 escreve em cima de areia.

| ! | Linear | Código | Área | História |
|---|---|---|---|---|
| ! | STR-14 | DEC-01 | Arquitetura | Onde a execução roda, e em cima de quê |
| ! | STR-15 | DEC-02 | Arquitetura | Como o dado do servidor vira harness executável |
| ! | STR-16 | DEC-03 | Arquitetura | Como o repositório guarda e acha documento |
| ! | STR-17 | DEC-04 | Arquitetura | Identidade, credencial e chave de IA |
| ! | STR-18 | DEC-05 | Arquitetura | O que sobe para o servidor |
| ! | STR-19 | DEC-06 | Arquitetura | Onde a aplicação é hospedada |
| ! | STR-21 | HT-01 | Infra | Ambiente hospedado de ponta a ponta |
| | STR-22 | HT-02 | Infra | Aplicativo instalável na máquina de quem usa |
| | STR-23 | HT-03 | Infra | CI e observabilidade desde o primeiro dia |
| ! | **STR-53** | **HT-11** | **Harness** | **Contrato do harness declarado e verificado** |
| ! | STR-58 | HU-23 | Medição | Baseline de ciclo **antes** da primeira linha |

Fora de release, de propósito:

| Linear | O que é |
|---|---|
| STR-20 | Proteção do pack no disco do cliente — antes da 1ª venda, não antes de codar |

`HU-23` não espera ninguém. É a primeira coisa e a mais fácil de deixar para depois.

### R1 · Um lugar só para o contexto — 5 issues

Útil **sem IA**. Frontend começa aqui, depois das DEC da R0 + STR-53.

| ! | Linear | Código | Área | História |
|---|---|---|---|---|
| ! | STR-24 | HU-01 | Espaço | Entrar e trabalhar dentro de um espaço |
| ! | STR-25 | HT-04 | Espaço | Modelo de dados do espaço |
| ! | STR-28 | HT-05 | Contexto | Documento = Markdown + metadado consultável |
| ! | STR-29 | HU-04 | Contexto | Criar, editar, pastas, anexar, apagar |
| ! | STR-30 | HU-05 | Contexto | Achar pelo metadado (bloqueada por STR-53) |

### R2 · Do pedido ao publicado — 21 issues, em 4 marcos

Não ligue o catálogo inteiro. Uma jornada primeiro (`documentar-requisito`).

**Marco 1 — o motor na máquina**

| ! | Linear | Código | Área | História |
|---|---|---|---|---|
| ! | STR-32 | HT-07 | Motor | Executor local atrás da camada de capacidade |
| ! | STR-33 | HT-08 | Motor | Materializador + escrita única de volta |
| ! | STR-34 | HU-06 | Motor | Executar com a minha chave |

**Marco 2 — o portão como mecanismo** (junto com o 1, nunca depois)

| ! | Linear | Código | Área | História |
|---|---|---|---|---|
| ! | STR-43 | HT-10 | Portão | Interceptação + máquina de estados no servidor |
| ! | STR-44 | HU-14 | Portão | Preview do que vai ser escrito, e onde |

**Marco 3 — uma jornada inteira**

| ! | Linear | Código | Área | História |
|---|---|---|---|---|
| ! | STR-26 | HU-02 | Espaço | Dados do projeto e encaixes preenchíveis |
| ! | STR-31 | HT-06 | Contexto | API de contexto (servidor) |
| ! | **STR-54** | **HT-12** | **Harness** | **Ações lendo contexto pela API (materializada)** |
| ! | STR-37 | HU-08 | Ações | Pedir trabalho conversando |
| ! | STR-38 | HU-09 | Ações | Documentar requisito no padrão da casa |
| ! | STR-45 | HU-15 | Portão | Revisar, aprovar ou pedir ajuste |
| ! | STR-46 | HU-16 | Conexões | Conectar GitHub ou GitLab e ler a demanda |

**Marco 4 — demais ações e medição**

| Linear | Código | Área | História |
|---|---|---|---|
| STR-35 | HU-07 | Motor | Ver a execução acontecendo |
| STR-36 | HT-09 | Motor | Histórico de sessão no servidor |
| STR-39 | HU-10 | Ações | Discovery guiado |
| STR-40 | HU-11 | Ações | Brief + protótipo + prints |
| STR-41 | HU-12 | Ações | Entregável final no destino |
| STR-47 | HU-17 | Conexões | Publicar no backlog com preview |
| **STR-55** | **HT-13** | **Harness** | **Pack sem identidade de cliente presumida** |
| **STR-56** | **HT-14** | **Harness** | **Lacunas do provider de backlog** |
| STR-59 | HU-24 | Medição | Área de medição no espaço |

### R3 · Contexto completo e conexões — 8 issues

Não começa antes da R2 ter uma jornada fechada. A15 (o repositório atrai) **não se valida
com n=1**.

| ! | Linear | Código | Área | História |
|---|---|---|---|---|
| ! | STR-49 | HU-19 | Estruturas | Tipos essenciais com forma declarada |
| | STR-50 | HU-20 | Estruturas | Estruturas no mesmo índice |
| ! | **STR-57** | **HT-15** | **Harness** | **Ação declarada para as estruturas** |
| ! | STR-51 | HU-21 | Drive | Trazer pasta do Drive (OAuth) |
| | STR-52 | HU-22 | Drive | Reconciliar quando a origem muda |
| | STR-42 | HU-13 | Ações | Priorizar pelo funil |
| | STR-48 | HU-18 | Conexões | Capacidades e degradação visíveis |
| | STR-27 | HU-03 | Espaço | Histórico compartilhável |

### Dependências que mudam ordem (já no Linear)

| Esta | Espera |
|---|---|
| Toda a R1 | DEC-03, DEC-04 |
| Toda a R2 | DEC-01, DEC-02, DEC-04, DEC-05 |
| HU-05 (STR-30) | HT-11 (STR-53) |
| HT-06 (STR-31) | HU-05 (STR-30) |
| HT-12 (STR-54) | HT-06 (STR-31) |
| HU-09…12 | HU-02 (encaixes) |
| HU-12 | HU-15 (portão) — impedimento estrutural, não ordem de código |
| HU-17 | HU-14 (preview) |
| HU-20 | HU-19 |
| HU-23 | **nada** |

Faltam no Linear, segundo o próprio `MVP-RELEASES.md`: a **iniciativa** (API não cria;
fazer à mão) e as **datas-alvo** dos 4 projetos. Sobram para apagar: projetos `P01`…`P12`
vazios e o grupo de label `release`.

---

## 6. Catálogo reduzido — o que a conversa da R2 dispara

O pack tem 23 ações. O Hub da R2 não expõe as 23. M05: as do **fluxo de uma demanda**.

| Ação no manifesto | Entra no Hub quando | Issue |
|---|---|---|
| `explorar-solucao` | R2 marco 4 | STR-39 |
| `documentar-requisito` | R2 marco 3 — **a jornada piloto** | STR-38 |
| `analisar-demanda-de-tela` · `construir-tela` · `capturar-prints` | R2 marco 4, só demanda com tela | STR-40 |
| `gerar-documento-final` · `publicar-na-wiki` | R2 marco 4 | STR-41 |
| `consultar-backlog` · `registrar-demanda` | R2 marco 3–4 | STR-46, STR-47 |
| `priorizar-backlog` | R3 | STR-42 |
| *(nova)* estruturas de produto | R3 | STR-57 |
| Personas `persona-produto` / `design` / `tecnica` | sempre, por contexto de tela, não por menu | — |

Fora do catálogo do MVP (continuam no pack, para o modo repositório e para depois):
`analisar-backlog`, `auditar-backlog`, `gerenciar-sprint`, `definir-meta-de-sprint`,
`consultar-dados`, `versionar-mudancas`, `configurar-design-system`, `publicar-prototipo`,
`manter-changelog`. Não apagar. Não desenhar tela.

---

## 7. Plano de execução — o mínimo para o frontend sair com o harness casado

Três fatias. A segunda *é* o frontend. A terceira anda **junto**, não antes.

### Fatia A — esta semana, antes de componente de UI (R0)

1. **HU-23 / STR-58** — medir o ciclo de uma demanda hoje, à mão. Sem isso o resto não
   compara.
2. **DEC-01…06** — um arquivo cada em `docs/decisions/`, com data, dono e o que fecha.
   Recomendação já está em `MVP-TECNICO.md`; a issue é *tomar*, não *redescobrir*.
   - Frontend da R1 espera **DEC-03, DEC-04, DEC-06**.
   - Frontend da R2 espera também **DEC-01, DEC-02, DEC-05**.
3. **HT-11 / STR-53** — escrever `system/schemas/<id-do-documento>.yaml` com os campos da
   §3.1, eval de contrato no `build.sh`, e o `tipo` enumerado. É o casamento harness ↔
   editor. Sem isto, o frontend da R1 inventa o cabeçalho.
4. **HT-01 / STR-21** — um lugar onde a app roda (banco + objeto + deploy). Sem isto a R1
   não tem onde gravar documento.

`HT-02` (instalador) **não** bloqueia a R1: a R1 é web. Bloqueia a R2 nativa.

`HT-03` (CI) pode entrar no mesmo PR que a STR-53: `build.sh --strict` no merge. `eval.sh`
de comportamento pode vir depois — custa modelo; o contrato é de graça.

### Fatia B — frontend da R1, em paralelo com o resto do harness

Issues: STR-24, 25, 28, 29, 30. Duas semanas de uso **sem ligar agente**. Critério de
pronto da release, não de issue.

O frontend consome:

- o schema da STR-53 (validar frontmatter);
- nada do manifesto ainda (não há ação nesta onda).

Se a seção de documentos não for aberta sozinha nessas duas semanas, **pare**. Não comece a
R2 para “aproveitar o ímpeto”.

### Fatia C — harness da R2, em paralelo com a Fatia B (não no caminho da R1)

Ordem interna, porque uma bloqueia a outra:

```
STR-55 (generalizar pack)     ── independente, faça cedo
STR-56 (provider GitHub/GitLab) ── o núcleo já cobre a jornada piloto;
                                   feche wiki no GitHub só se o destino for wiki
STR-31 (API de contexto, produto) ──► STR-54 (skills leem a pasta materializada)
STR-14/15 (DEC execução + materializador) ── produto; pack não muda
```

Jornada piloto da R2, quando a R1 tiver sido usada: **STR-38** (`documentar-requisito`)
atravessando conversa → contexto da R1 → portão → preview → GitHub/GitLab. Só depois
STR-39…41.

STR-57 (estruturas) **não entra** nesta fatia.

---

## 8. Documentos que divergem do repo — não planeje em cima deles

| Documento | O que está velho | O que vale |
|---|---|---|
| `HUB.md` §7.1 | “pack não ships `procedimento.md`” | 19 arquivos no pack; build limpo |
| `HUB.md` §8 item 5 | sandbox de execução na infra do produto | MVP 2026-08-29: execução **local**, chave do usuário. Sandbox hospedado é depois |
| `MODOS.md` §1 | modo aplicativo = agente na infra do produto | idem; a costura (§6) ainda é a direção certa para o *materializador* |
| `MVP-TECNICO.md` Parte 1 | “harness não usa MCP” | `linear-mcp.md` existe. Interface > frase |
| `discovery/13` | 28 ações no catálogo | manifesto atual: **23** ações |
| `org/ORG.md` deste repo | nomenclatura `{HU\|HT}…`, `.docx`, GL | overlay **desta** organização. O pack (`org-scaffold`) já é mais neutro. Não copiar o overlay para o produto |

A regra de conflito do próprio MVP: discovery é evidência, `ARCHITECTURE.md` é física.
Onde `MVP-TECNICO.md` divergir da arquitetura, a arquitetura vence — e a arquitetura diz
que skill não chama API de produto.

---

## 9. Como saber que o harness “casa” com o Hub

Não é “todas as 45 issues fechadas”. São quatro checagens, nesta ordem:

| Quando | Checagem | Se falhar |
|---|---|---|
| Fim da Fatia A | Schema de frontmatter no pack = schema que o editor da R1 valida. `build.sh --strict` verde no CI | o editor e o motor vão divergir na primeira demanda |
| Fim da R1 (duas semanas) | Você abre a seção de documentos **sem** executar ação | a R2 não paga o que a R1 custou; replanejar escopo antes de spawnar agente |
| Jornada piloto da R2 | `documentar-requisito` usa documentos achados **pelo filtro**, sem você apontar arquivo; write-gate vira preview clicável; GitHub/GitLab recebe o texto que você viu | HT-12 ou HT-14 ou o portão — medir qual, não construir kanban |
| Antes da 1ª venda | STR-20 (pack em texto no disco) decidida | o modo local coloca o pack inteiro na máquina de quem paga |

O frontend pode começar no dia em que a Fatia A fechar. O harness “terminado” é a Fatia C
mais a STR-57 — e isso é o MVP inteiro, não o ingresso da primeira tela.
