# MVP — recorte para backlog

Tradução de [`MVP.md`](MVP.md) para itens de backlog, no formato do Linear. **Grão de
entrada, não de execução:** cada issue aqui é um título e uma frase — o refinamento acontece
no Linear, não neste documento.

Escopo, evidência e o porquê de cada funcionalidade: [`MVP.md`](MVP.md) e
[`discovery/`](discovery/00-INDEX.md). Os eixos técnicos que correm em paralelo a estes
épicos — e as decisões de arquitetura que vêm antes deles — estão em
[`MVP-TECNICO.md`](MVP-TECNICO.md). **Os dois consolidados numa fila só, ordenada por
release e pronta para colar no Linear:** [`MVP-RELEASES.md`](MVP-RELEASES.md) — é o documento
de montar o backlog; este aqui e o técnico continuam como raciocínio.

Este documento não decide nada; só organiza.

---

## Os níveis

O Linear tem três níveis nativos — **Initiative → Project → Issue**. O "eixo" que atravessa
os épicos não é um nível: é rótulo. Mapeamento:

| Nível | No Linear | Quantos | O que é |
|---|---|---|---|
| **Iniciativa** | Initiative | 1 | o MVP inteiro. Existe para responder "isto ainda é o MVP?" quando aparecer item novo |
| **Épico** | Project | 9 | um resultado utilizável. Termina, e quando termina dá para usar |
| **Issue** | Issue | ~33 | uma entrega. É onde o refinamento começa |
| **Eixo** | Label `onda-1/2/3` | 3 | corta os épicos: a ordem de construção. Não é hierarquia — é sequência |

**Por que o eixo é label e não nível:** a onda diz *quando*, o épico diz *o quê*. Um mesmo
épico tem issue na onda 1 e na onda 3 (o repositório é o caso claro). Forçar isso numa
hierarquia obriga a quebrar épico por tempo, e aí o épico deixa de descrever um resultado.

### Iniciativa

> **Straggy Hub — MVP**
> Tirar o motor do terminal e pôr o contexto do produto num lugar só, hospedado. Feito
> quando uma demanda entra e sai documentada e publicada, com o contexto do repositório
> alimentando a execução.

### As três ondas

| Label | Onda | Termina quando |
|---|---|---|
| `onda-1` | o recipiente | o repositório é usado sozinho, **sem nenhuma IA**, por duas semanas |
| `onda-2` | a execução | uma demanda entra e sai documentada e publicada |
| `onda-3` | o que atrai e o que conecta | roadmap, persona e OKR vivem no mesmo índice que alimenta a execução |

---

## Épicos

### E1 · Espaço, acesso e configuração
**Entrega:** existe um espaço hospedado, com login, onde o contexto e a configuração vivem.
**Onda:** 1 (M03 na 3)

| Issue | Onda |
|---|---|
| Espaço hospedado como unidade de contexto | 1 |
| Autenticação e controle de acesso ao espaço | 1 |
| Formulário de dados do projeto | 1 |
| Encaixes por ação: `procedimento` e `estrutura do documento` | 2 |
| Histórico do espaço: registro de execuções, decisões e aprovações | 3 |

### E2 · Repositório de contexto
**Entrega:** todo o contexto do produto num lugar só, achável por filtro — e é daqui que a
ação monta o contexto antes de executar.
**Onda:** 1

| Issue | Onda |
|---|---|
| Seção de documentos com pastas | 1 |
| Criar e editar documento em Markdown no sistema | 1 |
| Frontmatter YAML obrigatório, com schema validado | 1 |
| Busca e filtro por metadado (tipo, demanda, status, tag) | 1 |
| **Montagem de contexto da ação a partir do filtro** — a ação consulta, não varre | 2 |
| Upload de arquivo de qualquer tipo | 1 |
| Exclusão de arquivo | 1 |

### E3 · Estruturas de produto como artefato
**Entrega:** roadmap, personas, OKR e afins deixam de ser método usado durante a execução e
viram documento editável do espaço — cada tipo com forma declarada, nunca tela em branco.
**Onda:** 3

| Issue | Onda |
|---|---|
| Definir o conjunto essencial de tipos que entra no MVP | 3 |
| Tipo de documento com forma declarada (seções e campos fixos) | 3 |
| Estruturas entram no mesmo índice de contexto das demais | 3 |

### E4 · Sincronização com Drive
**Entrega:** o contexto que já vive no Drive aparece no espaço sem ninguém migrar nada.
**Onda:** 3

| Issue | Onda |
|---|---|
| Conectar uma pasta ou arquivo do Drive por link | 3 |
| Importar como documento **somente leitura**, em Markdown | 3 |
| Reconciliar quando o conteúdo muda na origem | 3 |

### E5 · Conversa e execução de ações
**Entrega:** o trabalho é pedido por conversa e executado no procedimento declarado. É o
motor saindo do terminal.
**Onda:** 2

| Issue | Onda |
|---|---|
| Conversa como interface, em texto | 2 |
| Reconhecimento da ação pelo que foi pedido | 2 |
| Catálogo reduzido de ações exposto no Hub | 2 |
| Discovery guiado da demanda | 2 |
| Documentar requisito no procedimento e estrutura declarados | 2 |
| Ramo de design: brief da tela, protótipo navegável, prints | 2 |
| Entregável final no destino escolhido | 2 |
| Priorização pelo funil declarado | 3 |

### E6 · Esteira, portão e preview
**Entrega:** a garantia estrutural — o passo seguinte não existe até o anterior ser aprovado,
e nada é escrito fora do rascunho sem clique.
**Onda:** 2

| Issue | Onda |
|---|---|
| Artefato com estado visível | 2 |
| Esteira por demanda | 2 |
| Portão: aprovar e pedir ajuste | 2 |
| Bloqueio estrutural do passo seguinte | 2 |
| Preview antes de toda escrita externa | 2 |

### E7 · Integrações
**Entrega:** o trabalho entra e aterrissa na ferramenta que o time já usa — é a contrapartida
de não ter backlog próprio.
**Onda:** 2 e 3

| Issue | Onda |
|---|---|
| Conectar integração de backlog (GitHub ou GitLab) | 2 |
| Ler demanda e comentários como contexto | 2 |
| Criar e atualizar demanda, com preview | 2 |
| Superfície de conexão: autenticar, ver capacidades, degradar com aviso explícito | 3 |

### E8 · Harness
**Entrega:** o motor pronto para o que os épicos acima exigem dele. **Não é onda: atravessa
as três.** Tratar como manutenção avulsa é o jeito clássico de nunca acontecer.

| Issue | Onda |
|---|---|
| Generalizar campos e vocabulário presos ao fluxo de origem | contínuo |
| Fechar lacunas nas operações de provider de backlog | contínuo |
| Declarar ação para as estruturas de produto | 3 |

### E9 · Medição
**Entrega:** saber se funcionou. Sem baseline, qualquer ganho é impressão.
**Onda:** 2

| Issue | Onda |
|---|---|
| **Baseline de ciclo medido antes de ligar o produto** | 1 |
| Registro por demanda: ciclo, aceite sem reescrita, tipo de reescrita | 2 |
| Contador de retorno à ferramenta de backlog na mão | 2 |
| Contador de contexto achado pela ação sem apontar arquivo | 2 |

---

## Dependências que valem marcar no Linear

Poucas, e só as que mudam ordem de verdade:

| Depende | De |
|---|---|
| Montagem de contexto da ação (E2) | frontmatter + busca por metadado (E2) |
| Estruturas de produto (E3) | tipo de documento com forma declarada (E3) e o repositório (E2) |
| Todas as ações (E5) | encaixes preenchíveis (E1) |
| Entregável final (E5) | portão (E6) — não é ordem de trabalho, é impedimento estrutural |
| Criar/atualizar demanda (E7) | preview de escrita externa (E6) |
| Baseline (E9) | **nada** — é a primeira coisa, e a mais fácil de deixar para depois |

## O que não vira issue

Para o backlog não encher do que já foi decidido que fica fora:

- backlog, quadro, issue ou sprint próprios — fora por escopo, não por prioridade;
- papéis, permissões finas, auditoria;
- conversas em paralelo, voz, automação agendada;
- edição colaborativa em tempo real, comentário em documento, versionamento por documento;
- quadro branco livre;
- escrita de volta no Drive;
- providers além de GitHub e GitLab — entram por demanda real, nunca por especulação;
- métricas e gráficos de delivery.

Cada um tem condição de retorno escrita em [`MVP.md`](MVP.md) e em
[`discovery/18`](discovery/18-moscow.md). Se algum voltar, volta por lá — não por issue nova.
