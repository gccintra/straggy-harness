# Harness × Hub — resumo

Uma página. Detalhe em [`MVP-HARNESS.md`](MVP-HARNESS.md). Board em [`MVP-RELEASES.md`](MVP-RELEASES.md).

---

## Em uma frase

O motor **já roda**. Faltam **5 issues** no pack (`area:Harness`). Só **1** delas precisa existir antes do frontend: `STR-53`. O resto do board é o Hub (app), não o harness.

---

## Duas coisas diferentes — não misturar

| | O que é | Quantas issues | Quando |
|---|---|---|---|
| **Harness** (este repo, o pack) | workflows, schemas, providers | **5** | a primeira versão é a `STR-53`; as outras 4 andam depois / em paralelo |
| **Hub** (o produto / SaaS) | espaço, editor, conversa, portão | as outras **41** | frontend da R1 começa **depois** da R0, sem esperar as 5 |

“Primeira versão do harness” = fechar `STR-53`.  
“Primeira versão do Hub” = R0 + R1 (lista 2, abaixo). Não é a mesma fila.

---

## Lista 1 — as 5 issues do harness

Já estão no Linear (time `STR`). Não criar de novo.

| # | Linear | Código | Release | Fazer agora? | O que fecha |
|---|---|---|---|---|---|
| 1 | **STR-53** | HT-11 | R0 | **sim — é a primeira versão** | schema de frontmatter em `system/schemas/` (tipo, título, status, data…). Produto e motor leem o mesmo arquivo |
| 2 | STR-55 | HT-13 | R2 | em seguida, sem bloquear tela | tirar cliente / OS / HU-HT / `.docx` do pack |
| 3 | STR-56 | HT-14 | R2 | junto com a R2 | GitHub/GitLab: o que a jornada piloto ainda não cobre |
| 4 | STR-54 | HT-12 | R2 | depois da API de contexto (`STR-31`) | ação lê contexto por filtro, não varre pasta |
| 5 | STR-57 | HT-15 | R3 | **não agora** | ação para roadmap / persona / OKR |

Ordem: **53 → 55 → 56 → 54 → 57**.

Já está pronto (não tem issue): manifesto, encaixes, esteira, `build.sh --org/--out/--strict`. `./runtime/build.sh --strict` passa.

---

## Lista 2 — o que abrir esta semana para o Hub existir (R0)

Isto **não é harness**. São decisões e infra. Sem elas o frontend da R1 não tem onde gravar.

Comece nesta ordem:

| # | Linear | Código | O que é | Pronto quando |
|---|---|---|---|---|
| 1 | STR-58 | HU-23 | medir o ciclo de uma demanda, hoje, à mão | número no papel |
| 2 | STR-16 | DEC-03 | como o documento é guardado e achado | arquivo em `docs/decisions/` |
| 3 | STR-17 | DEC-04 | login e onde fica a chave de IA | idem |
| 4 | STR-19 | DEC-06 | onde a app é hospedada | idem |
| 5 | STR-14 | DEC-01 | execução local agora, hospedada depois | idem (R2 precisa; R1 aguenta sem) |
| 6 | STR-15 | DEC-02 | materializador do `org/` | idem (R2) |
| 7 | STR-18 | DEC-05 | o que sobe no histórico de sessão | idem (R2) |
| 8 | **STR-53** | HT-11 | **a issue de harness da Lista 1** | schema no pack |
| 9 | STR-21 | HT-01 | app + banco + armazenamento no ar | deploy repetível |
| 10 | STR-23 | HT-03 | CI com `build.sh --strict` | merge barrado se o contrato quebrar |

Pode esperar (não bloqueia a primeira tela web):

| Linear | Código | Por quê |
|---|---|---|
| STR-22 | HT-02 | instalador nativo — só a R2 precisa |
| STR-20 | — | proteção do pack no disco — só antes de **vender** |

---

## Lista 3 — frontend da R1 (depois da Lista 2)

Útil **sem IA**. Cinco issues. Duas semanas de uso sozinho.

| Linear | Código | Tela |
|---|---|---|
| STR-24 | HU-01 | entrar no espaço |
| STR-25 | HT-04 | modelo: espaço, projeto, demanda, documento |
| STR-28 | HT-05 | documento = Markdown + metadado |
| STR-29 | HU-04 | criar, editar, pastas, upload, apagar |
| STR-30 | HU-05 | filtrar por tipo / demanda / status / tag *(espera STR-53)* |

Se nessas duas semanas você **não** abrir a seção de documentos sem executar agente: pare. Não comece a R2.

---

## O que não começar agora

Tudo da **R2** (conversa, portão, chave de IA, GitHub) e da **R3** (roadmap, Drive). São 29 issues. A fila inteira está em [`MVP-RELEASES.md`](MVP-RELEASES.md). Não entram na primeira versão do harness nem na primeira tela.

---

## Checklist — o que tem × o que falta

Marca:

| | Significa |
|---|---|
| ✅ | Tem. Serve assim. |
| 🔧 | Tem no terminal. Vai precisar mudar para o Hub. |
| ❌ | Não tem. Está no plano. |
| — | Fora do plano. Não fazer. |

### Trabalho de PM (o motor)

Isto já roda hoje no terminal.

| Item | Marca | Nota |
|---|---|---|
| Discovery guiado da demanda | ✅ | ação `explorar-solucao` |
| Documentar requisito (`.md` consolidado) | ✅ | ação `documentar-requisito` — o núcleo |
| Brief de tela + protótipo + prints | ✅ | ações de design |
| Entregável final (docx / wiki / backlog) | 🔧 | funciona; assume `.docx` e vocabulário HU/HT — adaptar |
| Priorizar pelo funil | ✅ | ação `priorizar-backlog` |
| Registrar / consultar / atualizar demanda | 🔧 | funciona no CLI; no Hub precisa de tela + preview |
| Analisar / auditar backlog | ✅ | existe; **não entra** no catálogo do Hub no MVP |
| Sprint (criar, mover, documentar) | 🔧 | GitHub/GitLab sim; Linear não cria ciclo |
| Roadmap, persona, OKR, canvas **como documento do espaço** | ❌ | o método existe; a ação e o artefato, não |

### Conexões

O harness fala com ferramenta **por CLI / MCP na sua máquina**. O Hub (tela “conectar”) **não existe**.

| Conexão | No harness hoje | No Hub (tela) | Entra no MVP? |
|---|---|---|---|
| GitHub (ler / criar / atualizar / comentar) | ✅ | ❌ | sim — R2 |
| GitHub wiki | ❌ | ❌ | só se o destino for wiki; `gh` não cobre |
| GitLab (ler / criar / atualizar / comentar / wiki) | ✅ | ❌ | sim — R2 |
| Linear (ler / criar / atualizar / comentar) | ✅ CLI via MCP | ❌ | **não.** Hub usa GitHub ou GitLab. Linear aqui é só o *nosso* board |
| Linear criar/fechar sprint | ❌ | ❌ | a API não deixa; não é item do Hub |
| Jira | ❌ | ❌ | — só se um contrato pedir |
| Azure Boards | ❌ | ❌ | — só se um contrato pedir |
| Google Drive (sync de contexto) | 🔧 rclone + service account | ❌ | sim — R3; vira OAuth da pessoa, só leitura |
| Banco de homologação | ✅ CLI | ❌ | não é tela do Hub no MVP |
| Tela de conexão (autenticar, ver o que cobre, avisar se não cobre) | 🔧 o *contrato* existe (capacidades no manifesto) | ❌ | sim — R3 |

**Ler assim:** pensar em Linear/Jira/Azure no produto é válido como extensão futura. Hoje o harness **não está preparado para o Hub ligar isso**. GitHub e GitLab no terminal **estão**. Falta a superfície no sistema.

### Contrato do harness (o que o Hub vai ler)

| Item | Marca | Nota |
|---|---|---|
| Catálogo de ações em dado (`manifest.json`) | ✅ | 23 ações, a tela lê isto |
| Encaixes com rótulo e tipo (formulário) | ✅ | |
| Esteira (o que a ação produz e o que exige antes) | ✅ | grafo; a tela ainda não mostra |
| `build.sh --org` / `--out` (montar o `org/` do produto) | ✅ | o *ponto* existe; quem materializa é o Hub — ❌ |
| Schema de frontmatter do documento | ❌ | **único item de harness que a 1ª tela espera** (`STR-53`) |
| Pack sem cara de consultoria (cliente, OS, HU/HT, docx) | 🔧 | scaffold já é neutro; template e skills ainda não (`STR-55`) |
| Ação lê contexto por filtro, não varre pasta | 🔧 | hoje lê `docs/context_docs/` (`STR-54`) |
| CI barrando contrato quebrado | ❌ | `build.sh --strict` roda à mão (`STR-23`) |

### O Hub — o que construir (não existe)

Nada disto roda hoje. É o produto.

**Recipiente (R1 — sem IA)**

| Item | Marca |
|---|---|
| Espaço hospedado com login | ❌ |
| Repositório de documentos (pastas) | ❌ |
| Editor Markdown dentro do sistema | ❌ |
| Frontmatter obrigatório + filtro por tipo/demanda/tag | ❌ |
| Upload / exclusão de arquivo | ❌ |

**Execução (R2 — o motor sai do terminal)**

| Item | Marca |
|---|---|
| Conversa em texto que reconhece a ação | ❌ |
| Encaixes preenchíveis **na tela** | 🔧 arquivo sim / tela não |
| Esteira visível por demanda | ❌ |
| Portão: aprovar / pedir ajuste (passo seguinte travado) | 🔧 no chat, como texto / na tela, como estado — não |
| Preview antes de escrever no GitHub/GitLab | 🔧 no chat / tela não |
| Executar na máquina da pessoa, com a chave dela | ❌ |
| Histórico da sessão no servidor | ❌ |
| Medir ciclo / retrabalho / voltar no GitHub na mão | ❌ |

**O que atrai (R3)**

| Item | Marca |
|---|---|
| Roadmap / persona / OKR editáveis no espaço | ❌ |
| Sync Drive por link, só leitura | ❌ |
| Histórico do espaço compartilhável | 🔧 pasta `history/` no Git / no produto, não |

### Fora. Não marcar como falta.

Backlog próprio · quadro · sprint nossos · papéis e permissão fina · execução na nossa nuvem · Jira/Azure · vários modelos de IA · voz · automação agendada · edição simultânea · escrever de volta no Drive.

---

## Ordem para o harness ficar redondo

Fila só do pack. Já está no Linear — não criar de novo. Uma de cada vez.

| Ordem | Linear | Código | Fazer | Pronto quando | Espera |
|---|---|---|---|---|---|
| **1** | STR-53 | HT-11 | Schema de frontmatter em `system/schemas/` | produto e motor validam o mesmo cabeçalho | nada |
| **2** | STR-55 | HT-13 | Tirar cliente, OS, HU/HT e `.docx` assumido do pack | outra empresa instala sem ver consultoria | nada |
| **3** | STR-56 | HT-14 | Fechar o que GitHub/GitLab ainda não cobrem na jornada | criar/ler/atualizar/comentar sem reabrir a ferramenta na mão | nada (wiki do GitHub só se o destino for wiki) |
| **4** | STR-23 | HT-03 | `build.sh --strict` no merge | contrato quebrado não entra | STR-53 ajuda, não bloqueia |
| **5** | STR-54 | HT-12 | Ação lê contexto por filtro, não varre pasta | documentar requisito acha o doc sozinho | **STR-31** (API de contexto — isso é Hub, não pack) |
| **6** | STR-57 | HT-15 | Ação de roadmap / persona / OKR | estrutura vira artefato do espaço | STR-53 (o `tipo` do schema) |

Redondo **para a R1** (frontend de documento): só a **1**.  
Redondo **para a R2** (conversa + GitHub/GitLab): **1 a 5**.  
Redondo **para o MVP inteiro**: as **6**.

Não é harness (não entram nesta fila): materializador, executor, portão na tela, login, editor. Isso é Hub.
