# 18 — MoSCoW

> **Método:** `moscow` (L1). **Contrato:** faixa + justificativa de uma frase. Triagem
> **precede** score: faixa superior com score baixo vem antes de faixa inferior com score
> alto (14 desempata dentro da faixa).
> **Escopo da triagem:** o alpha definido em 17 e 19.

---

## MUST — sem isto não existe alpha

| Item | Justificativa |
|---|---|
| **Espaço com o padrão do sistema valendo** (F17) | é o recipiente; nada funciona fora dele |
| **Encaixe "como fazer" + "estrutura do documento"** (F02) | sem isto o padrão não é da empresa, e o produto vira gerador genérico |
| **Ação documentar requisito no procedimento declarado** (F01) | é o trabalho pelo qual o cliente paga |
| **Conversa como interface** (F18) | é como o trabalho é pedido; sem ela não há produto, só configuração |
| **Portão como estado do artefato** (F08) | é a promessa central; sem ele o alpha não prova nada |
| **Preview antes de qualquer escrita externa** (F21) | escrita indevida no backlog de um cliente encerra a conta |
| **Uma integração de backlog** (F12, parcial) | sem contexto real a saída regride ao genérico — e, como o produto não tem backlog próprio (00, v4), é por ela que o trabalho entra e aterrissa |
| **Saída no destino que o time usa** (F03) | trabalho que não aterrissa onde o time consome não foi entregue. Destino é configuração — backlog, wiki ou documento formal |
| **Escrita da demanda na ferramenta do time, com preview** (F34, parcial) | é a contrapartida de não ter backlog próprio: se o PM precisa digitar de novo no Jira o que o sistema já produziu, o ciclo não encurtou. No alpha basta **criar e atualizar** a demanda — refino, sprint e o resto ficam para depois |
| **Repositório de contexto hospedado** (F15 + F29 + F36) — documento nativo em Markdown, upload de arquivo, frontmatter obrigatório e busca por metadado | promovido em 2026-08-29. É o recipiente do contexto único (O1, a única oportunidade `[F]`): sem ele toda ação executa sobre contexto que mora fora do sistema, e a saída regride ao genérico |
| **Estruturas de produto como artefato editável** (F32) — conjunto essencial, cada tipo com forma declarada | promovido em 2026-08-29 pela premissa A15: é o gancho de entrada, e resolve a lacuna de 86 estruturas existirem como método e nenhuma como artefato do espaço |
| **Espaço hospedado com autenticação** | conteúdo de produto em servidor exige controle de acesso desde a primeira versão. Não é papel nem permissão fina — é a porta |
| **Medição de tempo de ciclo + aceitação** (F24, mínima) | a promessa é velocidade; sem medir ciclo **antes e depois**, o alpha não prova nada. Aceitação entra como contrapeso |
| **Mais de uma ação no fluxo** (registrar → explorar → documentar) | ciclo é o intervalo entre pedido e "pronto para começar". Uma ação só mede uma etapa, não o ciclo |
| **Ramo de design para demanda com interface** (FD1 brief + FD2 construir tela) | sem ele o alpha só atende demanda sem tela, e o ciclo medido não representa o trabalho real do time. A esteira já exige `prototipo-validado` quando a demanda tem interface |

## SHOULD — importante, o alpha sobrevive sem

| Item | Justificativa |
|---|---|
| Puxar demanda direto do backlog (3B) | colar o texto resolve; automatizar é conforto na primeira versão |
| Demais operações de backlog e sprint (F34, resto) | refinar, priorizar pelo funil, abrir e fechar sprint existem no motor e são rotina real de PM/PO; cada uma é mais uma escrita externa a validar, e o alpha mede ciclo melhor com superfície pequena |
| Aviso de encaixe vazio (F09) | evita configuração quebrada em silêncio, mas a implantação é assistida |
| Trilha de quem aprovou (F20) | valor real aparece com time; no alpha há poucas pessoas |
| Citação de fonte exposta na interface (F22) | já existe no comportamento; expor é apresentação |
| Publicar na wiki (além do backlog) | depende do cliente; nem todos usam |
| Sincronização com Drive, somente leitura (F37) | encurta a entrada do contexto que já existe, mas o upload manual resolve na primeira versão |
| Prints do protótipo na documentação (FD3) | melhora o entregável de demanda com tela; a documentação fecha sem elas |
| Publicar o protótipo na infra do cliente (FD4) | encurta a validação com terceiros; no alpha dá para validar na máquina de quem construiu |
| Scaffold do protótipo e tokens (FD5) | uma vez por projeto, feito na implantação assistida |

## COULD — só se sobrar tempo, e não vai sobrar

| Item | Justificativa |
|---|---|
| Presets de estrutura por tipo de cliente (F04) | acelera implantação futura, não a primeira |
| Checklist de saída visível (F10) | conforto; a garantia já é estrutural |
| Notificação de artefato aguardando revisão (F27) | com 2–3 pessoas, o aviso é o WhatsApp |
| Trilha de exemplos (F19) | material de venda, não produto |
| Visão consolidada de discovery e delivery (F30) | a esteira por demanda já mostra o estado; a visão agregada é conforto com 3 clientes |

## WONT — declarado, com o porquê e com a condição de retorno

Não é "depois". É **não nesta versão**. A justificativa fica escrita para não ser
renegociada toda semana — e a condição de retorno fica junto para que `WONT` não vire
"nunca" por inércia.

### Recusa permanente — contradiz o produto

| Item | Por que não | Volta quando |
|---|---|---|
| **Modo sem portão** | uma exceção destrói a promessa inteira; é o que separa este produto de um gerador de texto | **nunca** |

### Recusa de escopo — não é o produto que estamos fazendo

Decidido em 2026-08-29 (00, v4). Não é "depois do alpha" nem "quando der": é outra
categoria de produto. O trabalho continua no catálogo; o que não existe é a superfície nossa
para guardá-lo.

| Item | Por que não | Volta quando |
|---|---|---|
| **Backlog, quadro, issue e sprint próprios** | o mercado de gestão de backlog é bem servido por ferramentas focadas só nisso, e o time-alvo já paga por uma. Construir a nossa vira projeto de migração para o cliente e briga de paridade com Jira para nós — e não encurta ciclo nenhum. As ações de backlog e sprint **ficam**, executadas na ferramenta do time por integração (F34) | **A14 refutada** (09): as ferramentas reais forem customizadas além do que a integração cobre, ou o PM voltar a abrir a ferramenta na mão em >30% das demandas (19, S9). Aí é decisão nova, com dado — e as duas saídas na mesa são "tirar as ações de backlog do escopo" ou "construir", nunca "um kanban simples de qualquer jeito" |
| **Métricas e gráficos de delivery sobre o backlog** | são da ferramenta que já guarda o dado; reimplementar é o mesmo erro em escala menor | junto com a decisão acima, nunca sozinho |

### Fora do alpha, central à tese — volta com evidência

| Item | Por que não | Volta quando |
|---|---|---|
| **Conversas em paralelo** (F25) | é a aposta central da tese de velocidade, e o item mais caro da lista: facilidade 1, confiança 2 | a medição de ciclo do alpha mostrar que a espera entre demandas é a maior fatia do tempo |
| **Automações agendadas** (F26) | mecanismo de velocidade sem problema associado hoje | a medição mostrar ociosidade ou trabalho recorrente como fatia relevante do ciclo |

### Sem problema associado — volta se 07 encontrar a dor

| Item | Por que não | Volta quando |
|---|---|---|

| **Tarefas pessoais e compartilhadas** | nenhuma persona mapeada tem essa dor | aparecer nas entrevistas como perda de tempo concreta, não como conforto |
| **Métricas e metas de produto** (fora do backlog) | nenhuma decisão de P1 muda com elas no tamanho do alvo | houver mais de um time por espaço e o líder precisar do número para decidir |
| **Voz** | nenhuma situação de uso identificada | surgir situação concreta e recorrente em que texto não serve |
| **Comentário de stakeholder no protótipo** (FD7) | construção nova, sem evidência de que a validação seja gargalo | a validação aparecer como etapa mais longa do ciclo de demanda com tela |
| **Quadro visual estilo whiteboard** (F33) | é ferramenta de outra categoria, e **não é o que o PRD pedia** — o pedido era pelas estruturas prontas (F32), que entram como documento de forma declarada, não como canvas livre | não previsto |
| **Edição colaborativa em tempo real** (cursor ao vivo, comentário em documento) | o repositório resolve "onde está o contexto"; edição simultânea é outro produto | duas pessoas editarem o mesmo documento no mesmo dia, de fato |
| **Escrita de volta no Drive** | é a regra que evita duas fontes de verdade: quem é dono lá fora continua dono lá fora | nunca, nesta forma |

### Pré-requisito de escala ou de venda, não de valor

| Item | Por que não | Volta quando |
|---|---|---|
| **Permissões e perfis** | não é valor para o usuário; é condição para vender a time maior | a primeira venda para time acima de ~10 pessoas, ou exigência de auditoria |
| **Providers novos de backlog** (Jira, Linear, Azure Boards — F35) | hoje só GitHub e GitLab existem; construir os outros antes de saber o que o beachhead usa é aposta cara sobre uma lista que 07 ainda vai definir (D8 em 08) | um contrato assinado depender de uma delas — aí é caminho crítico, não backlog de ideia |
| **Projetos dentro de espaços** | hierarquia sem dor no tamanho do alvo | um cliente tiver mais de um produto no mesmo espaço e os contextos se misturarem |
| **Espaço acessível por fora** (MCP/API, F16) | plataforma antes de produto: expõe superfície sem base instalada para justificá-la | um cliente pedir integração própria e existir base instalada |
| **Autosserviço de cadastro** | traria o segmento errado e derrubaria a métrica de aceitação | a implantação assistida virar repetível e documentada |

### Promovidos em 2026-08-29 — saíram do `WONT`

Ficavam fora por **facilidade baixa**, nunca por falta de lastro. A decisão foi bancar o
esforço; a justificativa e o custo estão em 14 ("a decisão sobrepôs o score") e em
[`../MVP.md`](../MVP.md).

| Item | Estava em | Agora |
|---|---|---|
| **Estruturas de produto como artefato** (F32) | fora do alpha por sequência | **MUST** |
| **Edição de documento dentro do sistema** (F29) | coberto por outro caminho | **MUST** — só Markdown |
| **Repositório de arquivos e contexto no espaço** (F15, F13) | fora do MVP | **MUST**, hospedado |


### Coberto por outro caminho no alpha

| Item | Por que não | Volta quando |
|---|---|---|
| **Hospedagem do protótipo gerenciada pelo produto** (FD6) | build, domínio, certificado, autenticação e armazenamento são produto de infraestrutura; não encurtam ciclo, e o motor já publica na infra que o cliente tem | a publicação na infra do cliente travar em pelo menos um terço dos casos |
| **Personalização de personas e agentes** (F28) | as três profissões do pack cobrem produto, técnica e design; personalizar identidade não move o ciclo | um cliente precisar de papel que as três não cobrem |
| **Ação nova criada pela empresa** (F31) | existe no motor, mas exige superfície de autoria que o alpha não tem | a implantação deixar de ser assistida |

## O que bypassa a triagem

O método reserva bypass para criticidade real (sistema fora, perda de dado, fluxo core
bloqueado, sem contorno). No contexto de um alpha, o equivalente:

- **Escrita indevida em ferramenta de cliente** — se acontecer uma vez, para tudo e vira
  prioridade acima de qualquer MUST.
- **Vazamento de dado entre espaços** — idem.

## Contradição a vigiar

**F17 é MUST com score 40** ("planejar" em 14), abaixo de itens que estão em SHOULD. Isso não
é anomalia a corrigir: é a triagem funcionando. Facilidade baixa não rebaixa criticidade — e
o ICE penaliza fundação por construção (14, anomalias). A ordem de execução vem de 17, não
do score.
