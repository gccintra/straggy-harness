# MVP técnico — decisões e eixos de construção

O que precisa estar **decidido** para começar a desenvolver, e o que precisa ser
**construído** para continuar. Companheiro de [`MVP.md`](MVP.md) (o quê e por quê) e
[`MVP-BACKLOG.md`](MVP-BACKLOG.md) (épicos de produto). **Os eixos daqui e os épicos de lá
consolidados numa fila só, por release:** [`MVP-RELEASES.md`](MVP-RELEASES.md).

Referência normativa continua sendo [`ARCHITECTURE.md`](../ARCHITECTURE.md) (camadas, providers,
manifesto) e [`MODOS.md`](../MODOS.md) (a costura repositório ↔ aplicativo). **Onde este
documento divergir deles, eles vencem** — arquitetura não se dobra a plano de execução.

> **Estado.** Proposta. A Parte 1 é levantamento do repositório e é fato verificável. As
> Partes 2 e 3 são decisões **a tomar** — cada uma vem com recomendação, não com escolha
> feita. Da Parte 4 em diante é backlog, no mesmo grão de `MVP-BACKLOG.md`.

---

## Parte 1 — O que o motor é hoje, tecnicamente

Levantado em 2026-08-29, direto do repositório `[F]`:

| Dimensão | Estado |
|---|---|
| **Conteúdo do harness** | Markdown em camadas: `system/CONSTITUTION.md` (L0), `system/professions/` (L1), `system/pack/workflows/` + `org/workflows/` (L2), `project-config.yaml` + `.env` (L3) |
| **Máquina** | `runtime/build.sh` (bash) resolve o sistema de arquivos; `runtime/adapters/harness.py` valida contrato e emite `manifest.json`. Bash + Python, sem serviço |
| **Execução** | um runtime de agente com acesso a shell e disco: Claude Code, Codex ou OpenCode. Os adapters são **gerados** a partir de `PERSONA.md`, nunca mantidos à mão |
| **Providers** | contrato em Markdown + implementação que **executa binário de CLI**: `gh`, `glab`, `rclone`, `pandoc`, `python-docx`, cliente de banco. O harness declaradamente **não usa MCP** |
| **Segredos** | `.env` em disco, no projeto |
| **Contexto do projeto** | `docs/context_docs/`, populado por `sync-context.sh` (rclone + service account do Drive) |
| **Artefatos de trabalho** | `outputs/`, `history/`, `data/` — pastas do projeto |
| **Ponto de troca já existente** | `build.sh --org DIR --out DIR` decide de onde vem a camada da organização e para onde vai a visão resolvida |

**A consequência técnica mais importante desta lista:** provider é **comando**, não SDK. O
ambiente de execução precisa ser um sistema de arquivos com os binários instalados e as
credenciais no ambiente. No servidor, isso significa construir e manter uma imagem por
release. **Na máquina de quem trabalha, esses binários já estão lá** — e é um dos argumentos
que levaram a execução para o cliente (Parte 2).

### As duas peças que faltam, e uma delas o MVP força

`MODOS.md` §6 declara a costura entre os modos e deixa em aberto:

1. **O materializador.** `build.sh` sabe consumir um `org/`; ninguém sabe **produzir** um a
   partir do dado do produto. Sem isso, o modo aplicativo não existe. É bloqueante.

2. **Os artefatos de trabalho.** `MODOS.md` §6 encerra dizendo: *"artefatos de trabalho
   (`outputs/`, `history/`, `data/`) têm escrita dos dois lados e são um problema diferente —
   não resolva junto."*

   **O MVP acabou de forçar esse problema.** O repositório de contexto (M15–M20) é
   exatamente escrita dos dois lados: a pessoa edita documento na interface, e a ação escreve
   artefato no mesmo lugar. Não dá mais para adiar — vira a decisão **DT-05**.

---

## Parte 2 — A decisão de forma: onde roda o quê

**Decidido em 2026-08-29 pelo dono do produto. Híbrido, com a divisão explícita:**

| Onde | O que fica | Por quê |
|---|---|---|
| **Servidor** | repositório de documentos, espaço, autenticação, estado do artefato e trilha do portão, **histórico das sessões** | é o que precisa ser compartilhado. Documento, decisão e sessão existem para o time, não para uma máquina |
| **Máquina do usuário** | execução do agente **com a chave de IA do próprio usuário**, materialização do `org/`, chamada dos binários de provider | é onde o harness já roda hoje, e é o item mais caro do plano inteiro se for para o servidor |

### Por que a execução vai para o cliente

1. **O motor já roda no cliente.** É o modo repositório (`MODOS.md`). Execução local não é
   construção nova — é o que existe.
2. **Provider é binário de CLI, não SDK.** Na máquina de quem trabalha, `gh`, `glab`,
   `pandoc` e `rclone` já estão instalados. No servidor, cada um vira imagem para construir,
   fixar e manter.
3. **Escala.** Servidor exige sandbox por execução, fila, limite de concorrência — e a
   inferência paga por nós. Construir isso para um usuário, depois alguns colegas de equipe,
   é o cenário 1 do pré-mortem com outro nome.

**É decisão de MVP, declarada como tal.** Começa pequeno: eu, depois o time. Quando o
tamanho justificar, a execução gerenciada entra como **implementação nova atrás da mesma
interface** — nunca como reescrita (DT-02).

### Por que o repositório continua no servidor

Não é contradição: é a divisão. Execução é efêmera e individual; **documento, artefato e
sessão são compartilhados**. Repositório local reproduz o problema que o discovery descreve —
contexto que mora na máquina de quem rodou. E o histórico de sessão no servidor é o que
permite abrir de outra máquina e mostrar para outra pessoa o que foi feito.

### O que isso resolve de graça

| Ganho | Consequência |
|---|---|
| Custo de inferência sai da nossa conta | o cenário 4 do pré-mortem (margem invertida) deixa de existir no MVP |
| Dado de trabalho não passa pela nossa infra durante a execução | a objeção de nuvem (A5/D3 no discovery) enfraquece muito |
| Nenhuma plataforma de sandbox para construir | o eixo mais caro do plano encolhe para "processo filho" |
| Os binários de provider já estão na máquina | zero imagem para manter |

### O que isso custa, dito sem eufemismo

| Custo | Gravidade |
|---|---|
| **O pack em texto puro no disco de quem usa.** `MODOS.md` §6 exige que a visão resolvida nunca chegue à organização — ela contém o pack inteiro, e é requisito de propriedade intelectual | irrelevante agora (eu e o time); **decisão obrigatória antes de vender** — DT-19 |
| O portão é interceptado na máquina do usuário | a trilha continua no servidor, mas a garantia passa a ser cumprida no cliente. Para time que confia em si mesmo, suficiente; para auditoria de terceiro, não |
| Nada roda sem alguém com a máquina ligada | automação agendada e trabalho assíncrono ficam impossíveis enquanto a execução for local |
| Instalação e atualização por SO | some se um dia a execução hospedada existir |
| **Se o cliente traz a chave, o que ele paga?** | não é inferência: é o workflow, o repositório e o portão. Contradiz a hipótese de preço do discovery (`03` §6, por volume executado) e precisa ser corrigida lá |

### A forma do cliente: um frontend, dois alvos

Requisito declarado: **um código só que rode nativo e na web**, e que no nativo não tenha
limitação nenhuma de acesso a processo e disco.

O padrão que atende isso é: **um frontend web único + uma camada de capacidade com duas
implementações.**

```
        frontend (um só)
              │
     camada de capacidade  ← interface: executar, ler arquivo, chamar provider
        ╱              ╲
  local (hoje)      hospedada (depois)
  processo filho    chamada HTTP para o executor no servidor
```

A mesma abstração que DT-02 exige. Trocar o alvo é trocar a implementação, não o frontend.

**Recomendação: Electron + TypeScript.** O argumento não é maturidade nem ecossistema — é
migração:

> O processo principal do Electron **é Node**. O executor escrito para ele é um módulo Node
> comum: `spawn` do runtime de agente, `fs`, `build.sh`. **Esse mesmo módulo roda num
> servidor Node depois, praticamente sem alteração.** É a diferença entre trocar de alvo e
> reescrever.

E atende "sem limitação" por construção: processo principal em Node não tem fronteira de
plugin.

**Alternativa: Tauri v2.** Binário muito menor, consumo de memória menor, atualizador
embutido, frontend igualmente agnóstico. O custo é o oposto do ganho acima: o núcleo é Rust,
e tudo que passar dos plugins de `shell` e `fs` vira comando em Rust — que depois não
aproveita nada no servidor Node. **Escolha Tauri se o peso do binário importar mais que o
caminho de migração; escolha Electron se importar menos.**

Descartados e por quê: Wails (mesmo custo do Tauri, em Go) · Capacitor (feito para móvel,
desktop fraco) · aplicativo web puro (não spawna processo nem lê disco) · nativo por SO
(dois clientes para manter, e o requisito era um código só).

---

## Parte 3 — As decisões que travam o começo

Cada uma vem com recomendação. **Nenhuma está tomada**, salvo DT-01, que a Parte 2 registra.
As marcadas **bloqueante** precisam estar fechadas antes da primeira linha do eixo que
dependem delas.

### DT-01 · Forma do cliente — **decidida em 2026-08-29**
Híbrido: repositório e histórico no servidor, execução na máquina do usuário, um frontend
para os dois alvos. Ver Parte 2. Fecha: plataforma de sandbox no MVP, inferência por nossa
conta. Abre: distribuição por SO, e o pack no disco do cliente (DT-19).

### DT-02 · A camada de capacidade — **bloqueante**
**Recomendação:** uma interface só — executar ação, ler contexto, chamar provider — com
implementação **local** agora e **hospedada** depois. O frontend nunca sabe qual está ativa.

É o item que torna a decisão da Parte 2 reversível a um custo baixo. Sem ele, "migrar quando
crescer" vira reescrita, e a decisão de hoje passa a ser definitiva sem ninguém ter escolhido
isso.

### DT-03 · Runtime de agente e interceptação de ferramenta — **bloqueante**
O write-gate precisa deixar de ser instrução em texto e virar mecanismo — `MODOS.md` §7 chama
o contrário de *portão colapsado*.

**Recomendação: Claude Agent SDK no processo principal**, interceptando chamada de ferramenta
e devolvendo a decisão para a interface. O harness não sabe disso: o adapter é do produto, e
entra ao lado dos três que já existem (`ARCHITECTURE.md` §5 — nada de API de runtime dentro
de skill, método ou provider).

Com BYOK, o runtime precisa aceitar chave de mais de um fornecedor — ver DT-17.

### DT-04 · O materializador do `org/` — **bloqueante**
A peça que `MODOS.md` §6 declara faltando. **Recomendação:** o cliente busca do servidor o
dado da organização (encaixes, project-config, providers conectados), escreve um `org/` em
diretório de trabalho local, roda `build.sh --org --out` e só então inicia o agente. **Uma
via, sempre:** o materializado nunca volta para a fonte.

Executando local, ele fica no cliente. Escrito como módulo Node, migra junto com o executor.

### DT-05 · Onde vivem os artefatos de trabalho — **bloqueante**
O problema que `MODOS.md` §6 adiou e o MVP forçou. **Recomendação:** o repositório no
servidor é a fonte; o diretório de trabalho local recebe uma cópia materializada na entrada e
devolve o resultado por **um caminho de escrita único e explícito** na saída — nunca por
leitura de volta do sistema de arquivos. Documento vindo do Drive entra somente leitura e não
participa desse caminho.

### DT-06 · Armazenamento de documento e de arquivo
**Recomendação:** documento (`.md` + frontmatter) em banco relacional — corpo em texto,
frontmatter em coluna JSONB. Arquivo enviado em armazenamento de objeto. O JSONB dá o índice
de busca sem subir infraestrutura nova.

### DT-07 · Como funciona a busca por metadado
**Recomendação:** só o banco. Índice GIN sobre o JSONB para filtro, busca textual nativa para
o corpo. **Sem banco vetorial e sem busca semântica** — o discovery deixa isso para depois do
alpha (17).

### DT-08 · Schema do frontmatter
**Recomendação:** poucos campos obrigatórios (`tipo`, `titulo`, `status`, `atualizado_em`),
`demanda` e `tags` opcionais, `tipo` de lista fechada — a mesma lista que define as estruturas
de produto. Declarado **uma vez** em `system/schemas/`: o produto valida na escrita, o harness
lê na execução.

### DT-09 · Onde ficam as credenciais — **bloqueante**
Muda com a execução local, e é o ponto mais sensível do desenho.

**Recomendação:**

| Credencial | Onde |
|---|---|
| **Chave de IA do usuário** | só na máquina dele, no cofre do sistema operacional. **Nunca no nosso servidor** — nem cifrada. É argumento de venda, não só higiene |
| Credencial de provider (backlog, Drive) | mesma regra: local, no cofre do SO, injetada no ambiente da execução |
| Sessão do usuário no produto | servidor, normal |

Nada de credencial dentro do `org/`, que é prosa versionada e multiusuário (`MODOS.md` §7).

### DT-10 · Autenticação
**Recomendação:** provedor gerenciado, sessão, um espaço. Não construir autenticação própria.
Papel e permissão fina ficam fora do MVP; controle de acesso, não.

### DT-11 · Transmissão da execução para a tela
Muda com a execução local: **não é mais rede.** O executor roda no mesmo processo principal
que serve a interface, e o fluxo chega por IPC. **Recomendação:** desenhar o fluxo como
evento — a implementação hospedada depois entrega o mesmo evento por SSE, e o frontend não
muda.

### DT-12 · Linguagem e stack
**Recomendação: TypeScript de ponta a ponta** — frontend, processo principal, executor e a
API do servidor. O harness fica como está, em bash e Python, invocado como processo.

O executor precisa ser **um módulo Node sem dependência de Electron**, chamado pelo processo
principal hoje e por um servidor amanhã. Se ele importar coisa de Electron, a migração
prometida em DT-02 já nasceu quebrada.

### DT-13 · Hospedagem
Encolheu muito: sem execução no servidor, o que resta é aplicação, banco e armazenamento.
**Recomendação:** o mais simples que sirva os três, sem acoplar o código ao fornecedor.

### DT-14 · Sincronização com Drive
Hoje é `sync-context.sh` com rclone e service account. **Recomendação:** OAuth do próprio
usuário e API do Drive, importando para o repositório como documento somente leitura. Com
execução local, o rclone continua sendo uma opção viável no cliente.

### DT-15 · Versão do harness por espaço
**Recomendação:** a versão do harness vem embutida na versão do aplicativo, e o espaço
registra contra qual release a camada dele foi validada — lacuna que `MODOS.md` §6 lista.
Consequência da execução local: **atualização do harness passa a ser atualização do
aplicativo**, e clientes desatualizados executam versões diferentes do pack. Precisa de aviso
de incompatibilidade, não só de atualizador.

### DT-16 · Custo de inferência por execução
Com BYOK, o custo é do usuário — mas medir continua importando: é o que dimensiona o preço
da execução hospedada no dia em que ela existir, e é o que diz se o produto é caro de usar.
**Recomendação:** contabilizar tokens por execução desde a primeira, e mostrar para o próprio
usuário.

### DT-17 · Escolha do modelo e chave do usuário (BYOK) — **bloqueante**
Decidido em 2026-08-29: **o usuário escolhe a IA e usa a conta dele.**

A decidir: quais fornecedores no MVP (recomendação: **um só, bem feito** — o que o harness
já usa —, com a interface preparada para mais), o que acontece sem chave configurada
(recomendação: o produto funciona como repositório, e só a execução fica indisponível, com
aviso explícito — é exatamente o regime de degradação que os providers já usam), e se um dia
existe opção de usar a nossa chave.

### DT-18 · Histórico de sessão no servidor — **bloqueante**
Requisito declarado: **poder abrir de outra máquina e compartilhar com outra pessoa.**

A decidir, e é decisão de privacidade tanto quanto de produto: **o que sobe.** Recomendação:
sobem o pedido, os artefatos gerados, as decisões de portão e a trilha de execução (qual ação,
qual provider, quanto tempo). **Não sobem** credenciais, conteúdo de arquivo local fora do
espaço, nem a visão resolvida do pack. Sem essa lista escrita, o histórico vira o canal por
onde vaza o que a execução local existia para proteger.

### DT-19 · Proteção do pack no cliente — **decidir antes de vender, não antes de codar**
Execução local coloca a visão resolvida — o pack inteiro em texto — no disco de quem usa,
contra o requisito de `MODOS.md` §6. Para mim e para o time, irrelevante. Para cliente
pagante, é decisão real, e as saídas conhecidas são: aceitar conscientemente, ofuscar (o que
não resolve, só atrasa), ou mover a execução para o servidor para quem paga.

**Registrado agora para não ser descoberto na primeira venda.**

---

## Parte 4 — Eixos técnicos

Mesmo grão de [`MVP-BACKLOG.md`](MVP-BACKLOG.md): título e uma frase. Épico = Project,
issue = Issue, onda = label. Estes eixos são **paralelos** aos épicos de produto (E1–E9), não
substitutos: um épico de produto costuma precisar de um eixo técnico para existir.

### T1 · Decisões de arquitetura
**Entrega:** as decisões bloqueantes registradas, com data e dono. **Onda:** antes da 1.

| Issue | Onda |
|---|---|
| DT-02 camada de capacidade: local agora, hospedada depois, mesma interface | pré |
| DT-03 runtime de agente e interceptação de chamada de ferramenta | pré |
| DT-04 contrato do materializador do `org/` | pré |
| DT-05 onde vivem os artefatos de trabalho | pré |
| DT-09 onde ficam as credenciais — chave de IA só na máquina do usuário | pré |
| DT-17 quais fornecedores de IA, e o que acontece sem chave configurada | pré |
| DT-18 o que sobe e o que não sobe no histórico de sessão | pré |
| DT-19 proteção do pack no cliente | antes da 1ª venda |
| Registrar cada decisão em `docs/decisions/` com data, dono e o que ela fecha | pré |

### T2 · Plataforma e infraestrutura
**Entrega:** existe um lugar onde a aplicação roda, com banco, armazenamento e implantação
repetível. **Onda:** 1.

| Issue | Onda |
|---|---|
| Ambiente hospedado para a aplicação, com implantação repetível | 1 |
| Banco relacional gerenciado | 1 |
| Armazenamento de objeto para arquivo enviado | 1 |
| Empacotamento do aplicativo por SO, assinado, com atualizador | 1 |
| Pipeline de CI: `build.sh --strict` e os evals de contrato | 1 |
| Registro estruturado e rastreamento de erro | 1 |

### T3 · Núcleo da aplicação
**Entrega:** um espaço com login e um modelo de dados que sustenta o resto. **Onda:** 1.

| Issue | Onda |
|---|---|
| Autenticação por provedor gerenciado | 1 |
| Modelo de dados: espaço, projeto, demanda, artefato, documento | 1 |
| Formulário de dados do projeto e de encaixes | 2 |
| Casca da aplicação: navegação, sessão, estados de erro | 1 |

### T4 · Repositório de documentos
**Entrega:** documentos e arquivos com metadado, acháveis por filtro. **Onda:** 1.

| Issue | Onda |
|---|---|
| Modelo de documento: corpo Markdown + frontmatter em JSONB | 1 |
| Schema de frontmatter validado, com `tipo` de lista fechada | 1 |
| Editor de Markdown com pré-visualização | 1 |
| Índice e filtro por metadado | 1 |
| Busca textual no corpo | 1 |
| Upload e exclusão de arquivo | 1 |
| **API de contexto: dado o filtro, devolver os documentos que a ação vai ler** | 2 |
| Importador do Drive por OAuth, gravando somente leitura | 3 |
| Reconciliação de mudança na origem | 3 |

### T5 · Motor de execução
**Entrega:** uma ação do harness executa a partir da interface, na máquina do usuário, com o
contexto vindo do repositório. **É o eixo mais arriscado do MVP.** **Onda:** 2.

| Issue | Onda |
|---|---|
| **Camada de capacidade: interface única, implementação local** | 2 |
| Executor como módulo Node puro, sem dependência do shell desktop | 2 |
| Diretório de trabalho local por execução: criar, materializar, limpar | 2 |
| **Materializador: dado do servidor → `org/` → `build.sh` → visão resolvida** | 2 |
| Adapter de produto para o runtime de agente, gerado como os outros três | 2 |
| Configurar fornecedor de IA e guardar a chave no cofre do SO | 2 |
| Verificar pré-requisitos na máquina: runtime de agente e binários de provider | 2 |
| Fluxo da execução para a tela, desenhado como evento | 2 |
| Caminho de escrita único para o resultado voltar ao repositório | 2 |
| Histórico de sessão enviado ao servidor, pela lista do DT-18 | 2 |
| Comportamento de falha: chave inválida, binário ausente, processo morto, timeout | 2 |

### T6 · Os mecanismos da garantia
**Entrega:** o portão deixa de ser instrução em texto e vira mecanismo. **Onda:** 2.

| Issue | Onda |
|---|---|
| **Interceptação de chamada de ferramenta com aprovação humana** | 2 |
| Tela de preview: o que vai ser escrito, e onde | 2 |
| Máquina de estados do artefato, imposta no servidor | 2 |
| Bloqueio do passo seguinte enquanto o anterior não é aprovado | 2 |
| Trilha de quem aprovou o quê e quando | 2 |

### T7 · Alterações no harness
**Entrega:** o motor pronto para o que os eixos acima exigem. **Atravessa todas as ondas** —
detalhe na Parte 5.

| Issue | Onda |
|---|---|
| Generalizar `project-config`: `cliente` e `ordem_servico_padrao` opcionais | contínuo |
| Tipos de artefato e convenção de nome declarados pela organização | contínuo |
| Tirar `.docx` de destino assumido em `doc-final-generator` e `prototype-prints` | contínuo |
| Scaffold de organização neutro, sem identidade de cliente presumida | contínuo |
| Declarar o schema de frontmatter em `system/schemas/` | 1 |
| Declarar ação para as estruturas de produto (roadmap, personas, OKR) | 3 |
| Ações lerem contexto pela API do repositório, não por caminho de disco | 2 |
| Fechar lacunas nas operações do provider de backlog | contínuo |
| Evals de contrato rodando em CI a cada mudança de workflow | 1 |

### T8 · Integrações
**Entrega:** o trabalho entra e aterrissa na ferramenta do time. **Onda:** 2 e 3.

| Issue | Onda |
|---|---|
| Conectar backlog: credencial por espaço, teste de conexão | 2 |
| Ler demanda e comentários como contexto | 2 |
| Criar e atualizar demanda, passando pelo preview | 2 |
| Superfície de conexão: capacidades declaradas e degradação com aviso | 3 |
| Conexão do Drive por OAuth | 3 |

### T9 · Observabilidade, custo e medição
**Entrega:** dá para saber o que aconteceu e quanto custou. **Onda:** 2.

| Issue | Onda |
|---|---|
| Contabilizar tokens e custo por execução, e mostrar ao próprio usuário | 2 |
| Registro por demanda: ciclo, aceite, tipo de reescrita | 2 |
| Contador de retorno à ferramenta de backlog na mão | 2 |
| Contador de contexto achado sem apontar arquivo | 2 |
| Trilha de execução: qual ação, qual workflow, qual provider, quanto tempo | 2 |

---

## Parte 5 — As alterações no harness, em detalhe

Duas naturezas diferentes, e misturá-las é como uma delas nunca acontece.

### 5.1 · Generalização — tirar o fluxo de origem do caminho

Levantado no discovery `[F]` (04) e listado como **pré-requisito do alpha** (19). Não é
feature: é vazamento de instância na camada errada, pelo próprio teste do pack
(`ARCHITECTURE.md` §3).

| Onde | O que está preso |
|---|---|
| `project-config.template.yaml` | `cliente` e `ordem_servico_padrao` como campos de primeira classe |
| `project-config.template.yaml` | `label_header_hu` / `label_header_ht` fixos em "HISTÓRIA DE USUÁRIO/TÉCNICA" |
| `project-config.template.yaml` | `token_arquivo` no padrão `{HU\|HT}{ID}_{TOKEN}_{Nome}` |
| `doc-final-generator`, `prototype-prints` | `.docx` como destino assumido |
| `prototype-prints/SKILL.md` | subpasta por "HU" no procedimento |
| `system/pack/org-scaffold/ORG.md` | identidade assumindo cliente, sigla e logo |

### 5.2 · Habilitação — o que o produto exige e o harness ainda não tem

| O que | Por quê |
|---|---|
| **Schema de frontmatter declarado** | o produto valida na escrita, o harness lê na execução. Um schema só, em `system/schemas/` — dois seria a definição de divergência |
| **Ações lendo contexto por consulta, não por caminho** | hoje as skills leem `docs/context_docs/` e `outputs/`. No produto o contexto vem de um filtro. A skill não pode saber qual dos dois é — o materializador entrega o mesmo formato |
| **Ação declarada para estruturas de produto** | 86 estruturas existem como método e nenhuma como artefato do espaço. É declarar ação sobre repertório existente, que é o mecanismo de extensão que a arquitetura já suporta |
| **Adapter de produto** | quarto adapter, gerado dos `PERSONA.md` como os outros três. Nada de API de runtime dentro de skill ou provider |
| **Lacunas do provider de backlog** | o produto depende inteiramente delas — é a contrapartida de não ter backlog próprio |
| **Evals em CI** | hoje `build.sh --strict` e `eval.sh` rodam à mão. Com o produto consumindo o pack, contrato quebrado deixa de ser problema local |

### 5.3 · A regra que não pode ser quebrada no caminho

`ARCHITECTURE.md` §5 e §6 são explícitos: **nada de API de runtime dentro de skill, método ou
provider**, e camada de cima referencia a de baixo, nunca copia. A tentação de resolver algo
do produto escrevendo no workflow vai aparecer — e é assim que o harness apodrece.

---

## Parte 6 — O que NÃO decidir agora

Decisão prematura aqui custa mais que decisão adiada:

| Não decidir | Por quê | Quando |
|---|---|---|
| Execução hospedada | a camada de capacidade (DT-02) já reserva o lugar dela. Construir agora é o cenário 1 | automação agendada virar necessidade, ou um cliente recusar instalar |
| Multi-tenancy de verdade (isolamento por organização, cota, cobrança) | um espaço, poucas pessoas. Desenhar para escala inexistente é o cenário 1 | segundo cliente pagante |
| Suporte a vários fornecedores de IA | um só, bem feito, com a interface preparada | alguém do time usar outro de fato |
| Busca semântica e banco vetorial | o filtro por metadado ainda não foi medido; pode bastar | filtro por metadado se provar insuficiente, com número |
| Estratégia de cache de contexto e otimização de custo | não há baseline de custo | depois de DT-16 dar o primeiro número |
| Edição colaborativa e resolução de conflito | fora do escopo do MVP | duas pessoas editando o mesmo documento no mesmo dia |
| Migração para outro fornecedor de infraestrutura | a interface de sandbox já protege | o custo doer |
| Versionamento de documento dentro do produto | Git resolve no modo repositório | mais de uma pessoa editando |

---

## Ordem, em uma frase

**Decidir DT-02 a DT-05, DT-09, DT-17 e DT-18 → T2 e T3 (o lugar existe) → T4 (o repositório
existe e é útil sozinho) → T5 e T6 juntos (o motor sai do terminal, na máquina do usuário,
com a garantia mecânica) → T8 e o resto de T4 (conexões e Drive).** T7 e T9 atravessam tudo.
DT-19 é a única que não bloqueia código: bloqueia a primeira venda.

O único item fora dessa ordem, e que não depende de nada: **medir o baseline de ciclo antes
de a primeira linha existir.** Sem ele, nada do que vier depois é comparável.
