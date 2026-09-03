# MVP — o backlog, no formato do Linear

**O documento para montar o backlog.** Consolida os itens de produto
([`MVP-BACKLOG.md`](MVP-BACKLOG.md)) e os técnicos ([`MVP-TECNICO.md`](MVP-TECNICO.md)) numa
fila só, já mapeada nos objetos nativos do Linear. Os dois continuam valendo como raciocínio —
o porquê de cada item está lá, e em [`MVP.md`](MVP.md).

**Grão alto, de propósito.** Cada issue aqui é uma história inteira — algo que, quando fecha,
alguém usa ou algo passa a funcionar. A quebra em tarefa, critério de aceite e estimativa
acontece no refinamento, dentro do Linear. **45 issues**, não 94: item que só existia por ser
mais uma linha de tabela foi absorvido pela história que o carrega.

> **Revisão de 2026-08-29.** A execução saiu do servidor e foi para a máquina do usuário,
> com a chave de IA dele; o servidor guarda repositório, artefatos e **histórico das sessões**.
> Isso reescreveu a R0 e o eixo de execução da R2 — sai plataforma de sandbox, entra executor
> local e camada de capacidade. Motivo e custo em [`MVP-TECNICO.md`](MVP-TECNICO.md), Parte 2.

> **Estado.** Proposta. As decisões `DEC-*` da R0 **não estão tomadas** — estão listadas como
> issue justamente para serem decididas com data e dono. Tudo que vem depois delas assume a
> recomendação de [`MVP-TECNICO.md`](MVP-TECNICO.md); se a decisão sair diferente, a fila
> muda. O rastro de cada `DT-*` do documento técnico está na seção 8.

---

## 1. O modelo

| Objeto do Linear | O que é aqui | Quantos |
|---|---|---|
| **Iniciativa** | `Hub — do terminal ao time`: o MVP inteiro, e o lugar de responder "isto ainda é o MVP?" | 1 |
| **Projeto** | uma release: R0 a R3, cada uma com data-alvo e critério de pronto | 4 |
| **Marco do projeto** | fase interna, **só onde a ordem muda decisão** — hoje, só na R2 | 4 |
| **Issue** | uma história inteira: código, título e uma frase | 45 |
| **Label `area:*`** | a área permanente do produto, que atravessa releases e não termina | 12 |
| **Label `tipo:*`, `trilha:*`, `Bloqueante`** | história de usuário, técnica ou decisão · produto ou plataforma · segura outras | 6 |

**Por que projeto é release e área é label.** Projeto no Linear é objeto finito: tem barra de
progresso, data-alvo e estado de concluído. Release termina por definição; área do produto
(motor, portão, repositório) não termina nunca — sempre vai ter mais coisa de motor. Área como
projeto vira barra de progresso que nunca enche e obriga a inventar "v2" para tudo. Como label,
ela atravessa releases sem precisar acabar: `area:Motor` tem issue na R2 do MVP e vai ter em
qualquer coisa que venha depois.

**Depois do MVP isto muda de forma, e tudo bem.** Release como projeto faz sentido enquanto o
trabalho precisa pousar junto — R1 sem R0 não roda, R2 sem R1 não tem contexto. Quando der para
subir uma frente sozinha, os projetos passam a ser resultado (`Execução hospedada`,
`Papéis e permissões`), e release como projeto volta a aparecer só quando várias frentes
precisam pousar na mesma data — um GA, uma migração. **A regra:** precisa de várias frentes
numa data? Projeto de release. É uma frente com um resultado? Projeto de resultado. Não termina
nunca? Não é projeto — é `area:*`.

> **Estado no Linear — 2026-08-30.** Workspace `straggy-hub`, time `STR`. Existem: os 4
> projetos de release, os 4 marcos da R2, as 46 issues (`STR-14` a `STR-59`, sendo `STR-20`
> fora de release por decisão), os grupos de label `area`, `tipo` e `trilha` mais o
> `Bloqueante`, e as 25 relações de bloqueio da seção 7.
> **Faltam:** a iniciativa — a API do Linear não cria iniciativa, tem que ser à mão — e as
> datas-alvo dos 4 projetos. **Sobraram para apagar:** os 12 projetos `P01`…`P12`, agora
> vazios, e o grupo de label `release`, que virou redundante.

### As 4 releases

| Projeto | Issues | Pronta quando |
|---|---|---|
| **R0 · Fundação** | 11 | as decisões bloqueantes estão registradas com data e dono, e existe um lugar onde a aplicação roda com banco, armazenamento e CI |
| **R1 · Um lugar só para o contexto** | 5 | é **útil sozinho, sem nenhuma IA** — todo o contexto achável num lugar — e foi usado assim por duas semanas |
| **R2 · Do pedido ao publicado** | 21 | uma demanda entra por conversa e sai documentada e publicada, **na máquina de quem usa, com a chave de IA dele**, com o portão funcionando como mecanismo |
| **R3 · Contexto completo e conexões** | 8 | roadmap, persona e OKR vivem no mesmo índice que alimenta a execução |

**A R2 é quase metade do MVP.** Não é erro de distribuição: é onde o motor sai do terminal e
onde o portão vira mecanismo. É também a única com ordem interna que muda decisão — por isso é
a única com marcos. **A regra que vale entre todas:** release que não termina em uso não
termina. E o teste comercial (oferta paga com o motor atual, por linha de comando) roda em
paralelo desde a R0 — não espera nenhuma delas.

### As 12 áreas

| Label | O que agrupa |
|---|---|
| `area:Arquitetura` | as decisões `DEC-*` e o registro delas |
| `area:Infra` | hospedagem, banco, CI, empacotamento, observabilidade |
| `area:Espaço` | login, espaço, dados do projeto, encaixes, histórico |
| `area:Contexto` | documento, metadado, busca, API de contexto |
| `area:Motor` | executor local, materializador, chave, falhas, sessão |
| `area:Ações` | conversa e as ações que ela dispara |
| `area:Portão` | interceptação, estado, preview, aprovação, trilha |
| `area:Conexões` | GitHub, GitLab e a superfície de conexão |
| `area:Estruturas` | roadmap, persona, OKR como documento |
| `area:Drive` | importar o contexto que já existe |
| `area:Harness` | contrato, providers, generalização do motor de workflows |
| `area:Medição` | baseline, ciclo, reescrita, custo, trilha |

### Códigos

| Prefixo | O que é | Labels |
|---|---|---|
| **HU-nn** | história de usuário — alguém usa e o trabalho dessa pessoa anda | `tipo:HU` · `trilha:Produto` |
| **HT-nn** | história técnica — ninguém usa direto, mas nada anda sem | `tipo:HT` · `trilha:Plataforma` |
| **DEC-nn** | decisão de arquitetura a tomar, com data e dono | `tipo:Decisão` |

**`!`** na primeira coluna = label `Bloqueante`: segura outras issues até fechar.

---

## 2. R0 · Fundação

Não entrega uso a ninguém — é a única release com essa licença, e por isso a que mais merece
prazo curto. **Toda decisão fecha com um arquivo em `docs/decisions/`**, com data, dono e o
que ela fecha; sem o arquivo, a issue não está pronta.

| ! | Código | Linear | Área | História | Descrição |
|---|---|---|---|---|---|
| ! | DEC-01 | STR-14 | Arquitetura | Onde a execução roda, e em cima de quê | Interface única de execução (local agora, hospedada depois), runtime de agente com interceptação de ferramenta, e a stack do executor. |
| ! | DEC-02 | STR-15 | Arquitetura | Como o dado do servidor vira harness executável | Contrato do materializador do `org/` — atomicidade, integridade, falha — e onde vivem `outputs/`, `history/` e `data/` com escrita dos dois lados. |
| ! | DEC-03 | STR-16 | Arquitetura | Como o repositório guarda e acha documento | Documento em banco relacional, arquivo em armazenamento de objeto, busca por metadado sem banco vetorial, e o schema do frontmatter. |
| ! | DEC-04 | STR-17 | Arquitetura | Identidade, credencial e chave de IA | Autenticação por provedor gerenciado, chave do usuário só no cofre do sistema operacional, e quais fornecedores de IA entram no MVP. |
| ! | DEC-05 | STR-18 | Arquitetura | O que sobe para o servidor | Lista fechada do que vai no histórico de sessão, e o que nunca sai da máquina. |
| ! | DEC-06 | STR-19 | Arquitetura | Onde a aplicação é hospedada | Aplicação, banco e armazenamento — fornecedor e forma de implantação. |
| ! | HT-01 | STR-21 | Infra | Ambiente hospedado de ponta a ponta | Aplicação, banco e armazenamento provisionados, com implantação repetível e migração versionada. |
| | HT-02 | STR-22 | Infra | Aplicativo instalável na máquina de quem usa | Pacote assinado por sistema operacional, com atualizador e versão do harness presa à versão do aplicativo. |
| | HT-03 | STR-23 | Infra | CI e observabilidade desde o primeiro dia | `build.sh --strict` e evals barrando merge; log e erro com contexto para diagnosticar sem acesso à máquina. |
| ! | HT-11 | STR-53 | Harness | Contrato do harness declarado e verificado | `system/schemas/` como fonte única, lida pelo produto na escrita e pelo harness na execução, com evals a cada mudança de workflow. |
| ! | HU-23 | STR-58 | Medição | Saber quanto o ciclo demora hoje | Como líder de produto, quero o ciclo medido antes da primeira linha de código, para depois existir com o que comparar. |

> **Fora de release, de propósito** (`STR-20`)**:** a proteção do pack no disco do cliente
> (antigo DT-19) é decisão **antes da primeira venda**, não antes de codar. Fica no backlog
> sem projeto até existir venda no horizonte.

---

## 3. R1 · Um lugar só para o contexto

A metade nova do MVP. Tem que valer a pena **sem nenhuma IA em cima** — e a HU-04 sozinha é o
teste disso.

| ! | Código | Linear | Área | História | Descrição |
|---|---|---|---|---|---|
| ! | HU-01 | STR-24 | Espaço | Entrar e trabalhar dentro de um espaço | Como PM, quero entrar pelo provedor que a empresa já usa e cair num espaço hospedado navegável, para o contexto não viver na máquina de uma pessoa. |
| ! | HT-04 | STR-25 | Espaço | Modelo de dados do espaço | Espaço, projeto, demanda, artefato e documento com relação declarada. |
| ! | HT-05 | STR-28 | Contexto | Documento como corpo Markdown mais metadado consultável | Corpo em Markdown, frontmatter em coluna estruturada — a base de tudo que vem depois. |
| ! | HU-04 | STR-29 | Contexto | Guardar o contexto do produto num lugar só | Como PM, quero criar, editar, organizar em pastas, anexar arquivo e apagar o que não vale mais, para o contexto ter um endereço. |
| ! | HU-05 | STR-30 | Contexto | Achar o documento certo pelo metadado | Como PM, quero metadado validado ao salvar e filtro por tipo, demanda, status e tag — mais busca no texto —, para chegar no contexto certo sem vasculhar pasta. |

---

## 4. R2 · Do pedido ao publicado

A release mais pesada e a mais arriscada: é onde o motor sai do terminal e onde o portão
precisa deixar de ser texto. **Tem ordem interna, e ela está nos marcos** — antes de ligar
todas as ações, uma atravessa a jornada inteira.

### Marco `1 · O motor na máquina de quem usa`

Uma execução vai do servidor à máquina e volta com resultado. Feia, sem tela bonita, sem
histórico — mas anda.

| ! | Código | Linear | Área | História | Descrição |
|---|---|---|---|---|---|
| ! | HT-07 | STR-32 | Motor | Executor local atrás da camada de capacidade | Módulo puro, sem dependência do shell desktop, com diretório de trabalho isolado por execução. |
| ! | HT-08 | STR-33 | Motor | Do dado do servidor ao resultado de volta | Materializador do `org/`, adapter gerado do `PERSONA.md` e caminho único de escrita de volta. |
| ! | HU-06 | STR-34 | Motor | Executar com a minha própria chave | Como PM, quero o fornecedor configurado com a chave no cofre do meu sistema, e aviso claro quando falta binário ou a chave é inválida. |

### Marco `2 · O portão como mecanismo`

Nenhuma escrita externa acontece sem clique de gente. **Anda junto com o marco 1, nunca
depois** — motor sem portão é escrita sem freio.

| ! | Código | Linear | Área | História | Descrição |
|---|---|---|---|---|---|
| ! | HT-10 | STR-43 | Portão | O portão como mecanismo | Interceptação de chamada de ferramenta com aprovação humana e máquina de estados do artefato imposta no servidor. |
| ! | HU-14 | STR-44 | Portão | Ver exatamente o que vai ser escrito | Como PM, quero o preview do conteúdo e do destino antes de qualquer escrita externa, para nada sair sem eu olhar. |

### Marco `3 · Uma jornada inteira`

Uma ação atravessa tudo: conversa, requisito no padrão, artefato com estado, portão, preview,
escrita no backlog. **Só depois que este marco fecha é que as outras ações entram.**

| ! | Código | Linear | Área | História | Descrição |
|---|---|---|---|---|---|
| ! | HU-02 | STR-26 | Espaço | Declarar como o trabalho é feito aqui | Como mantenedor do padrão, quero preencher dados do projeto e os encaixes de cada ação, para a saída sair do nosso jeito. |
| ! | HT-06 | STR-31 | Contexto | API de contexto | Dado o filtro, devolver os documentos que a ação vai ler — a ação consulta, não varre disco. |
| ! | HT-12 | STR-54 | Harness | Ações lendo contexto pela API | Consulta ao repositório no lugar de caminho de disco, em todos os workflows. |
| ! | HU-08 | STR-37 | Ações | Pedir trabalho conversando | Como PM, quero pedir em texto corrido e ter a ação reconhecida pelo pedido, para não aprender comando nem caçar menu. |
| ! | HU-09 | STR-38 | Ações | Documentar requisito no padrão da casa | Como PM, quero o requisito escrito no procedimento e na estrutura declarados, para sair no padrão sem eu reescrever. |
| ! | HU-15 | STR-45 | Portão | Revisar, aprovar ou pedir ajuste | Como PM, quero a esteira com estado, o passo seguinte travado até aprovação, e a trilha de quem aprovou o quê. |
| ! | HU-16 | STR-46 | Conexões | Trazer a demanda de onde o time já trabalha | Como PM, quero conectar GitHub ou GitLab e ler demanda e comentários de lá, para não colar contexto na conversa. |

### Marco `4 · As demais ações e a medição`

| ! | Código | Linear | Área | História | Descrição |
|---|---|---|---|---|---|
| | HU-07 | STR-35 | Motor | Ver a execução acontecendo | Como PM, quero acompanhar o passo a passo na tela, para saber que está andando e onde parou. |
| | HT-09 | STR-36 | Motor | Histórico de sessão no servidor | Envio pela lista fechada da DEC-05, nada além dela. |
| | HU-10 | STR-39 | Ações | Ser conduzido no discovery da demanda | Como PM, quero um discovery guiado antes do requisito, para o que falta ser perguntado na hora certa. |
| | HU-11 | STR-40 | Ações | Levar a demanda com tela até o protótipo | Como PM, quero brief da tela, protótipo navegável e prints, para a documentação sair com a interface junto. |
| | HU-12 | STR-41 | Ações | Gerar o entregável final onde ele precisa cair | Como PM, quero o entregável montado e publicado no destino escolhido, para não remontar à mão no fim. |
| | HU-17 | STR-47 | Conexões | Publicar no backlog sem sair do Hub | Como PM, quero criar e atualizar demanda passando pelo preview, para não copiar e colar no fim do trabalho. |
| | HT-13 | STR-55 | Harness | Harness sem identidade de cliente presumida | `cliente` e `ordem_servico_padrao` opcionais, tipo e nome de artefato declarados, `.docx` fora do destino assumido, scaffold neutro. |
| | HT-14 | STR-56 | Harness | Lacunas do provider de backlog fechadas | As operações que os workflows já assumem e o provider ainda não cobre. |
| | HU-24 | STR-59 | Medição | Ter uma área de medição no espaço | Como líder de produto, quero ciclo, reescrita, retorno manual, contexto achado, custo e trilha num lugar só, para comparar com o baseline. |

---

## 5. R3 · Contexto completo e conexões

O que atrai — e é a release inteira apoiada na premissa com menos evidência do discovery
(A15). Vale construir; não vale tratar como validada por gostar do resultado.

| ! | Código | Linear | Área | História | Descrição |
|---|---|---|---|---|---|
| ! | HU-19 | STR-49 | Estruturas | Começar do formato, nunca da tela em branco | Como mantenedor do padrão, quero os tipos essenciais com seções e campos fixos — um por necessidade, não o catálogo. |
| | HU-20 | STR-50 | Estruturas | Ter roadmap e persona achável como qualquer documento | Como PM, quero as estruturas no mesmo índice de contexto, para elas alimentarem a execução também. |
| ! | HT-15 | STR-57 | Harness | Ação declarada para as estruturas de produto | Roadmap, personas e OKR ganham procedimento no motor. |
| ! | HU-21 | STR-51 | Drive | Trazer o que já vive no Drive | Como PM, quero conectar pasta por link e ler como documento somente leitura, para consultar sem migrar nada. Inclui a troca para OAuth do usuário. |
| | HU-22 | STR-52 | Drive | Não trabalhar em cima de versão velha | Como PM, quero reconciliação quando o original muda, para o Hub não me mostrar o que já foi corrigido lá. |
| | HU-13 | STR-42 | Ações | Priorizar pelo funil da casa | Como PM, quero priorizar pelo funil declarado no espaço, para o critério ser o nosso e não o do modelo. |
| | HU-18 | STR-48 | Conexões | Saber o que cada conexão consegue fazer | Como PM, quero ver as capacidades declaradas e ser avisado quando alguma degrada, para não descobrir na hora da escrita. |
| | HU-03 | STR-27 | Espaço | Consultar e compartilhar o que já foi feito | Como PM, quero o histórico de execuções, decisões e aprovações legível e compartilhável, para o passado virar contexto. |

---

## 6. O mesmo backlog, visto por área

O que a visão filtrada por `area:*` mostra — é aqui que você enxerga um tema atravessando
releases, sem precisar que ele termine:

| Área | R0 | R1 | R2 | R3 |
|---|---|---|---|---|
| Arquitetura | `DEC-01`…`DEC-06` | | | |
| Infra | `HT-01`, `HT-02`, `HT-03` | | | |
| Espaço | | `HU-01`, `HT-04` | `HU-02` | `HU-03` |
| Contexto | | `HT-05`, `HU-04`, `HU-05` | `HT-06` | |
| Motor | | | `HT-07`, `HT-08`, `HU-06`, `HU-07`, `HT-09` | |
| Ações | | | `HU-08`…`HU-12` | `HU-13` |
| Portão | | | `HT-10`, `HU-14`, `HU-15` | |
| Conexões | | | `HU-16`, `HU-17` | `HU-18` |
| Estruturas | | | | `HU-19`, `HU-20` |
| Drive | | | | `HU-21`, `HU-22` |
| Harness | `HT-11` | | `HT-12`, `HT-13`, `HT-14` | `HT-15` |
| Medição | `HU-23` | | `HU-24` | |

---

## 7. Dependências — `blocked by` no Linear

Poucas, e só as que mudam ordem de verdade:

| Issue | Bloqueada por |
|---|---|
| Tudo da R1 | DEC-03, DEC-04 |
| Tudo da R2 | DEC-01, DEC-02, DEC-04, DEC-05 |
| HU-05 · metadado validado e filtrável | HT-11 · schema em `system/schemas/` |
| HT-06 · API de contexto | HU-05 · filtro por metadado |
| HT-12 · ações lendo por consulta | HT-06 · API de contexto |
| HU-09, HU-10, HU-11, HU-12 · as ações | HU-02 · encaixes preenchíveis |
| HU-12 · entregável final | HU-15 · bloqueio do passo seguinte — não é ordem de trabalho, é impedimento estrutural |
| HU-17 · publicar no backlog | HU-14 · preview de escrita externa |
| HU-20 · estruturas no índice | HU-19 · tipo com forma declarada |
| HU-23 · baseline de ciclo | **nada** |

---

## 8. Rastro das decisões técnicas

Onde cada `DT-*` de [`MVP-TECNICO.md`](MVP-TECNICO.md) foi parar. Nenhuma sumiu; várias
viraram parte de uma decisão maior, e quatro viraram critério dentro da história que as usa.

| DT | Onde está agora |
|---|---|
| DT-01 · forma do cliente | decidida em 2026-08-29 — não vira issue |
| DT-02 · camada de capacidade · DT-03 · runtime e interceptação · DT-12 · stack | **DEC-01** |
| DT-04 · materializador · DT-05 · artefatos de trabalho | **DEC-02** |
| DT-06 · armazenamento · DT-07 · busca por metadado · DT-08 · schema | **DEC-03** |
| DT-09 · credenciais · DT-10 · autenticação · DT-17 · fornecedores de IA | **DEC-04** |
| DT-18 · histórico de sessão | **DEC-05** |
| DT-13 · hospedagem | **DEC-06** |
| DT-11 · execução na tela | critério de **HU-07** |
| DT-14 · Drive por OAuth | critério de **HU-21** |
| DT-15 · versão do harness | critério de **HT-02** |
| DT-16 · tokens por execução | critério de **HU-24** |
| DT-19 · proteção do pack | `STR-20`, backlog sem projeto — antes da primeira venda |

---

## 9. O que não vira issue

Já foi decidido que fica fora. Se algum voltar, volta pela revisão do escopo em
[`MVP.md`](MVP.md) e [`discovery/18`](discovery/18-moscow.md) — não por issue nova:

backlog, quadro, issue ou sprint próprios · papéis, permissões finas, auditoria · projetos
dentro de espaços · conversas em paralelo · voz · automações agendadas · edição colaborativa
em tempo real · comentário em documento · versionamento por documento · quadro branco livre ·
escrita de volta no Drive · providers além de GitHub e GitLab · métricas e gráficos de
delivery · catálogo completo das 86 estruturas · espaço acessível por MCP/API · aplicativo
móvel · sincronização offline.

E, do lado técnico, o que é decisão prematura e não item de fila: **execução hospedada na
nossa infra** (a camada de capacidade já reserva o lugar dela) · multi-tenancy de verdade ·
vários fornecedores de IA · busca semântica e banco vetorial · estratégia de cache e
otimização de custo · migração de fornecedor de infraestrutura.
