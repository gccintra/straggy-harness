# HRN-010 · anexo B — descrições propostas

Soma aplicada: **15.955 → 5.560** caracteres (orçamento do Codex ≈ 8.000; alvo RN-05 < 6.000). Maior: 266 (teto 350). O `committer` ficou 6 caracteres abaixo do rascunho desta página — ver a nota dele.

Critério: frase literal que o usuário diria + desempate com a vizinha que o eval `confunde_com` separa. Sai da descrição: como a skill trabalha por dentro (já está no corpo), o aviso de `INTERFACE.md` (vai para a linha `Provider` do corpo, RN-06) e instrução de execução. Personas passam a citar `/nome` em vez de `@nome`.

## backlog-analysis · 526 → 252

**Antes.** Analisa o backlog do projeto a partir de um único export em lote do backlog, salvando o CSV bruto no repositório e gerando relatórios em Markdown com métricas, scores e gráficos texto. Use esta skill sempre que o usuário pedir análise de sprint, métricas do backlog, status de issues, velocidade do time, distribuição por tipo ou prioridade, burndown, ou qualquer visão quantitativa do backlog — com ou sem filtro de sprint. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

**Depois.** Métricas do backlog por export em lote: status, distribuição por tipo ou prioridade, velocidade do time, burndown, análise de sprint. Use para "métricas do backlog", "velocidade", "burndown". Ranquear é backlog-prioritization; auditar é backlog-health.

## backlog-health · 591 → 241

**Antes.** Audita a saúde do backlog detectando issues sem tipo, sem prioridade, sem sprint, sem assignee, possíveis duplicatas por similaridade de título e issues "zumbis" (abertas há mais de 6 meses sem atualização). Exporta os dados do backlog em uma única chamada, salva o CSV no repositório, e gera um relatório de saúde com recomendações e opção de correções em lote. Use quando o usuário pedir para limpar o backlog, encontrar inconsistências, ver duplicatas ou auditar a qualidade das issues. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

**Depois.** Audita a saúde do backlog: issues sem tipo, prioridade, sprint ou responsável, duplicatas e zumbis, com correção em lote opcional. Use para "limpa o backlog", "acha as duplicatas", "o backlog está uma bagunça". Métricas são backlog-analysis.

## backlog-issue-creator · 628 → 238

**Antes.** Cria e refina demandas do backlog com template estruturado, triagem de criticidade (MoSCoW ou o que o funil declarar) e labels corretas. Acione quando o usuário mencionar criar issue, item de backlog, demanda, feature, bug, melhoria ou qualquer coisa que precise ser rastreada — em português ou inglês (criar issue, demanda, backlog, bug, melhoria, feature, nova funcionalidade, erro, tarefa). Acione também para refinar/enriquecer demanda existente com pouca informação ("refina a #NNN", "completa", "a issue só tem título"). IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

**Depois.** Cria ou refina demanda no backlog com template, criticidade e labels. Use para "cria uma issue", "abre um bug", "registra essa melhoria", "refina a #NNN", "a issue só tem título". Ver, comentar ou fechar demanda existente é backlog-query.

## backlog-prioritization · 774 → 249

**Antes.** Prioriza as demandas do backlog pelo funil declarado da organização — triagem, dimensões, score e faixas. Exporta os dados em lote, extrai as dimensões da demanda, ranqueia pela ordenação declarada, detecta anomalias (rótulo errado, score inconsistente, tipo errado na fila) e gera o markdown da análise no histórico. Acione SEMPRE que o usuário mencionar: priorização, priorizar, ranking, lista ranqueada, ordem de prioridade, backlog priorizado, funil, MoSCoW, ICE score, RICE, WSJF, quadrante, matriz esforço × valor, quais issues entram primeiro, anomalia de prioridade, inconsistência de label, ou qualquer pedido que combine backlog + priorizar + ordenar + analisar. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

**Depois.** Prioriza o backlog pelo funil da organização: score, faixas, lista ranqueada e anomalias de rótulo ou score. Use para "prioriza", "ranking", "o que entra primeiro", MoSCoW, RICE, ICE, WSJF, esforço × valor. Métricas sem ordenar são backlog-analysis.

## backlog-query · 557 → 266

**Antes.** Consulta e operação pontual no backlog do projeto — ver uma demanda, buscar por texto, listar por sprint/label/responsável, criar/atualizar/comentar/fechar uma demanda específica, listar labels e sprints. Use para qualquer pedido pontual de backlog: "vê a #NNN", "busca issues sobre X", "quais issues da sprint atual", "comenta na #NNN", "fecha a #NNN", "quais labels existem", e também quando o usuário citar a ferramenta direto (glab, GitLab, Linear, Jira). Para varredura do backlog inteiro use backlog-analysis, backlog-health ou backlog-prioritization.

**Depois.** Operação pontual no backlog: ver, buscar, listar por sprint/label/responsável, comentar, atualizar, fechar. Use para "vê a #NNN", "busca issues sobre X", "comenta na #NNN", "fecha a #NNN", ou ao citar glab, GitLab, Linear, Jira. Demanda nova é backlog-issue-creator.

## changelog-generator · 413 → 216

**Antes.** Gera ou atualiza o changelog do projeto (histórico de evolução) a partir de documentação de requisito, demandas entregues ou descrição de funcionalidade. Use sempre que o usuário mencionar "changelog", "histórico de evolução", "adiciona ao changelog", "registra a mudança", "atualiza o histórico" ou enviar documentação pedindo para registrá-la. A saída é uma tabela Markdown no formato definido pela organização.

**Depois.** Gera ou atualiza o changelog (histórico de evolução) a partir de requisito, entrega ou funcionalidade. Use para "changelog", "registra essa entrega", "atualiza o histórico de evolução". Página de wiki é wiki-publish.

## committer · 503 → 153

**Antes.** Agente MANUAL de commit — só ativa quando o usuário chama @committer/$committer explicitamente. Cria commits convencionais, faz push e abre PR. Sugere branch nova por padrão (não bloqueia commit em main — bloqueio de branch é responsabilidade do GitHub, não da skill), nunca faz commit único gigante, sempre separa por camada (harness, docs/contexto, protótipo, config), sempre apresenta o plano de commit antes de rodar qualquer comando git. Lê arquivo de tarefa se existir; funciona standalone também.

**Depois (aplicado, 147).** Commit manual: só com @committer ou $committer explícito. Commits convencionais separados por camada, plano mostrado antes de rodar git, push e PR.

O rascunho incluía "commita isso" como gatilho. O caso `commita-sem-chamar` usa essa frase para provar que a ação **não** dispara sem `@committer` / `$committer`. O texto aplicado fica com a chamada explícita e sem essa frase.

## db-query · 436 → 189

**Antes.** Executa consultas SQL no banco de dados de homologação do projeto usando o cliente CLI configurado no .env (sqlcmd, psql, mysql, sqlite3 ou qualquer outro). Suporta qualquer autenticação — senha, Windows/NTLM, Kerberos, .pgpass — sem depender de MCP. Use sempre que precisar consultar dados reais do banco: estrutura de tabelas, valores de registros, contagens, inconsistências entre o comportamento esperado e o estado atual dos dados.

**Depois.** Consulta SQL no banco de homologação pelo cliente do .env: tabelas, registros, contagens, "quantos X estão com status Y", dado real que diverge do esperado. Estado de issue é backlog-query.

## design-brief · 777 → 247

**Antes.** Analisa uma demanda ANTES de construir a tela: lê a documentação do PM (`.md` consolidado, documento de requisito, issue), varre o protótipo existente (rotas, componentes de ui/, tokens, telas irmãs) e devolve em conversa o que a demanda vira na interface — navegação, reuso, gaps do design system, estados não previstos, impacto nas telas existentes, pendências de produto. Escala com a entrada: ajuste em tela existente não passa por aqui; texto simples vira análise leve; imagem vira média; documentação/issue vira completa. Gerar o {ID}_design.md é OPT-IN, no fim. Use quando o usuário pedir para analisar, avaliar, sugerir ou entender uma demanda de tela antes de codar. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

**Depois.** Analisa o que uma demanda vira na interface antes de construir: navegação, reuso, lacunas do design system, estados, impacto em telas. Use para "analisa a tela da #NNN antes de eu construir", "o que reusa e o que falta". Construir é design-screen.

## design-screen · 685 → 217

**Antes.** Cria E ajusta telas como rotas React no app de protótipo do projeto (prototype/) a partir de uma demanda do backlog, documento de requisito, descrição livre ou número da demanda. Dois modos: AJUSTE (tela já existe → referência é o próprio protótipo, tokens e telas irmãs; NÃO pede print) e NOVO (tela inexistente → pede node do Figma, imagem ou wireframe). Reusa src/components/ui/, liga a rota ao menu real do produto e verifica por diff visual. Export de telas escolhidas pro Figma é opt-in. Use sempre que o usuário pedir criar OU ajustar uma tela, protótipo, componente ou fluxo. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

**Depois.** Cria ou ajusta telas como rotas no protótipo (prototype/) a partir de demanda, requisito ou descrição. Use para "cria a tela", "ajusta a tela", protótipo, componente, fluxo. Analisar antes de construir é design-brief.

## design-setup · 539 → 226

**Antes.** Configura o design system do projeto E faz o scaffold do app de protótipo navegável (prototype/) na primeira vez que o designer é acionado. Extrai tokens de cor, tipografia, espaçamento e padrões de componentes de prints/screenshots do sistema atual; grava os tokens na configuração de estilo e cria os componentes base transcritos das evidências. Push dos guidelines para a ferramenta de canvas é opt-in. Use na primeira vez que o designer for acionado — antes de criar qualquer tela — e para atualizar o design system quando ele evoluir.

**Depois.** Primeira configuração do design system e scaffold do protótipo a partir de prints do sistema atual: tokens e componentes base. Use na primeira vez do designer ou para atualizar o design system. Tela específica é design-screen.

## discovery · 541 → 218

**Antes.** Conduz o discovery de uma demanda seguindo o Double Diamond: explora e define o problema (D1), depois explora e define a solução (D2). Cada fase vira um registro aprovado — no backlog e no histórico local. Detecta em que fase a demanda está e propõe a próxima pendente. Use quando o usuário pedir para explorar soluções, fazer discovery, discutir alternativas ou aprofundar o entendimento de um problema — referenciando ou não uma demanda. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

**Depois.** Discovery no Double Diamond: problema (D1), depois solução (D2), cada fase aprovada. Use para "explorar alternativas", "fazer discovery", "não sei qual é o problema de verdade". Escrever o requisito é doc-consolidator.

## doc-consolidator · 602 → 227

**Antes.** Gera o documento .md consolidado de uma demanda — fonte de verdade única que reúne a descrição da funcionalidade, os critérios de aceite, as regras de negócio, as mensagens ao usuário e a trilha do discovery. Use para pedidos genéricos como "documenta a #NNN", "gera a documentação", "consolida", "gera o md", "monta o documento base" ou "cria as regras da #NNN". Gera somente o `.md` e PARA para revisão humana — formato final (`.docx` ou outro) é passo separado, só após revisão e pedido explícito. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

**Depois.** Gera o .md consolidado da demanda (critérios de aceite, regras de negócio, mensagens) e para para revisão. Use para "documenta a #NNN", "consolida", "gera o md", "monta o documento base". O docx/PDF final é doc-final-generator.

## doc-final-generator · 674 → 202

**Antes.** Passo FINAL da documentação: transcreve um `.md` consolidado JÁ REVISADO (gerado pela skill doc-consolidator) para o formato final entregável — `.docx`, `.pdf` ou o que o projeto usar. Acione quando o usuário pedir EXPLICITAMENTE o documento formal: "gera o docx", "agora o documento final", "transforma o md em docx", "exporta o documento", "gera o PDF da demanda", "cria o documento formal". NÃO acione para pedido genérico ("documenta a #NNN") — isso gera o `.md` primeiro, via doc-consolidator, com parada para revisão humana. Só transcreve o `.md`; não relê discovery nem cria conteúdo. IMPORTANTE: leia .agents/system/providers/docs-output/INTERFACE.md antes de gerar.

**Depois.** Transcreve um .md consolidado já revisado para .docx ou .pdf. Só com pedido explícito: "gera o docx", "documento final", "gera o PDF da demanda". Pedido genérico ("documenta a #NNN") é doc-consolidator.

## figma-node-reader · 469 → 107

**Antes.** Transcritor de nodes do Figma para HTML. Lê um ou mais nodes, fatia os que estouram o limite de token, transcreve a árvore elemento por elemento (verbatim, Lucide inline, limpa) e grava FRAGMENTOS HTML em disco. Devolve o caminho de cada fragmento, o índice de seções e os chutes. Existe SÓ para o caso em que o node estoura — mantém o dump (80k+) fora do contexto principal. É invocada como SUBAGENTE pela `design-screen` (caminho B) — não é gatilho direto do usuário.

**Depois.** Uso interno da design-screen: transcreve node grande do Figma para HTML em disco. Não é gatilho do usuário.

## harness-change · 902 → 249

**Antes.** Especifica e executa qualquer mudança no próprio harness — skill, workflow, método, provider, persona, constituição, adapter, regra de engajamento — seguindo a arquitetura de camadas. Use SEMPRE que o usuário pedir para criar uma skill nova, editar ou refatorar uma existente, adicionar workflow, extrair método, mudar a CONSTITUTION/ORG, corrigir um procedimento, mexer na estrutura do harness ou "melhorar o harness" — qualquer alteração em arquivo dentro de .agents/ que não seja config de instância (project-config.yaml, .env). Toda mudança começa por uma spec com análise de impacto, aprovada antes de qualquer edição. Para só ENTENDER o harness sem mudar nada — o que ele já faz, onde algo mora, o que quebra se eu mexer — a skill é a `harness-guide`. Garante que toda mudança respeite: camada certa, prescrever resultado e não raciocínio, referência em vez de cópia, portões humanos preservados.

**Depois.** Especifica e executa mudança no harness (skill, workflow, método, provider, persona, constituição, adapter) com spec e impacto antes. Use para "cria uma skill", "edita a skill X", "melhora o harness", edição em .agents/. Só entender é harness-guide.

## harness-guide · 693 → 217

**Antes.** Responde perguntas sobre o próprio harness sem editar nada: o que ele já sabe fazer, onde cada coisa mora, como um workflow funciona, o que ele entrega, onde ele para, e o que quebra se você mudar alguma coisa. Use SEMPRE que o usuário perguntar "o que o harness faz", "isso já existe?", "já tem skill pra X?", "como funciona a discovery/o build/os encaixes", "onde eu edito X", "onde mora essa regra", "quem usa esse arquivo", "o que quebra se eu mudar/renomear/apagar X", "qual o raio de impacto", "que skills existem", "por que isso está assim" — e antes de qualquer edição, para levantar o impacto. É SOMENTE LEITURA: não cria, não edita, não roda build. Quem escreve é a `harness-change`.

**Depois.** Responde sobre o harness sem editar: o que já faz, onde mora cada coisa, o que quebra se mudar X. Use para "isso já existe?", "já tem skill pra X?", "onde eu edito X", "qual o raio de impacto". Mudar é harness-change.

## html-to-figma · 437 → 129

**Antes.** Motor de captura DOM → Figma (injeta capture.js, sobe/usa o dev server, insere no arquivo via generate_figma_design). Captura a ROTA RENDERIZADA do app prototype/ (Vite) em modo export (?export=1). NÃO é gatilho direto do usuário — é invocada por `design-screen` (telas) e `design-setup` (guidelines opt-in) apenas no passo de export pro Figma, que é opt-in. Para criar uma tela use `design-screen`; para o design system, `design-setup`.

**Depois.** Uso interno da design-screen e design-setup: captura a rota do protótipo para o Figma no export opt-in. Não é gatilho do usuário.

## product-designer · 638 → 161

**Antes.** Product Designer do projeto. Acione para qualquer coisa de design: criar telas como rotas no app de protótipo navegável (prototype/), configurar o design system pela primeira vez (a partir de prints do sistema atual), atualizar tokens/componentes, gerar protótipos de fluxo ou wireframes, e exportar telas escolhidas pro Figma sob demanda. Funciona a partir de uma issue, documento de requisito, número de issue ou descrição livre — busca o contexto sozinho, constrói o front na stack do protótipo (default: React + Tailwind + Vite), serve local para revisão e (sob pedido) exporta telas pro Figma. Use @product-designer para tudo visual.

**Depois.** Persona Product Designer: tudo visual. Telas e fluxos no protótipo, design system, wireframes, export pro Figma sob pedido. Use /product-designer para interface.

## product-specialist · 565 → 196

**Antes.** Product Specialist do projeto — PM, PO, analytics, growth, go-to-market e liderança de produto no mesmo papel. Acione para QUALQUER coisa de produto, backlog ou processo: reportar bug, propor melhoria, discovery, documentar requisito (história de usuário), documentar regra de negócio, changelog, sprint, priorização, análise de backlog, métrica e funil, lançamento, comunicação com stakeholder, ou dúvida de produto. Persona padrão do dia a dia — em dúvida, use o @product-specialist. Executa direto carregando as skills; delega só quando compensa e com aprovação.

**Depois.** Persona padrão (PM/PO): produto, backlog, processo, requisito, discovery, sprint, priorização, métricas, lançamento. Em dúvida, /product-specialist. Técnica é tech-lead; visual é product-designer.

## prototype-deploy · 605 → 183

**Antes.** Publica o app de protótipo (prototype/) num servidor como site estático, atrás de autenticação e HTTPS. Descobre o "porteiro" HTTP do servidor (nginx no host, Traefik, Caddy, nginx-proxy) antes de assumir qualquer coisa, gera o script de publicação e o bloco de configuração a partir dos valores em project-config.yaml, e produz o passo a passo a ser executado no servidor. Use quando o usuário pedir para hospedar, publicar, subir, colocar no ar ou dar deploy do protótipo — ou pedir uma URL compartilhável dele. Não use para deploy do sistema de produção (backend/banco), que não é escopo deste harness.

**Depois.** Publica o protótipo num servidor como site estático, com autenticação e HTTPS. Use para "publica o protótipo", "coloca no ar", "URL compartilhável". Deploy de produção fora do escopo.

## prototype-prints · 715 → 203

**Antes.** Captura as prints do protótipo (prototype/) que entram na seção Protótipo do documento de uma demanda — o .md consolidado da demanda e o .docx gerado a partir dele. Define o recorte a partir da documentação da demanda (não do git diff), organiza as prints por fluxo, e captura com Playwright em dimensões adequadas para página A4: telas longas em partes contínuas, componentes no próprio limite e todas as imagens com borda fina. Use quando o usuário pedir prints, screenshots ou imagens do protótipo para documentação — "tira as prints da #NNN", "preciso das telas pra colocar no docx", "salva as imagens do protótipo". Não use para export pro Figma (é html-to-figma) nem para criar/ajustar tela (é design-screen).

**Depois.** Captura prints do protótipo, por fluxo e em A4, para o documento da demanda. Use para "tira as prints da #NNN", "telas pra colocar no docx". Export pro Figma é html-to-figma; publicar é prototype-deploy.

## sprint-goal-generator · 519 → 174

**Antes.** Gera a Meta da Sprint (Sprint Goal) no padrao do Guia do Scrum 2020, com foco em OUTCOME (ganho de valor para o usuario/negocio) e nao em output (funcionalidades entregues). Use sempre que o usuario pedir para criar, escrever, montar ou sugerir uma Meta da Sprint, Sprint Goal, objetivo da sprint, ou enviar HUs/backlog pedindo para definir a meta. Tambem quando perguntar qual seria a meta mesmo sem usar o termo exato. Trigger agressivo: qualquer combinacao de meta + sprint + contexto de desenvolvimento de software.

**Depois.** Escreve a Meta da Sprint (Guia do Scrum 2020) com foco em outcome. Use para "meta da sprint", "sprint goal", "objetivo da sprint". Criar, fechar ou mover sprint é sprint-ops.

## sprint-ops · 663 → 230

**Antes.** Gerencia sprints (milestones/ciclos) no backlog do projeto — GitLab, Linear, Jira ou o que estiver configurado: criar nova sprint com datas e objetivo, fechar sprint atual e gerar sumário de conclusão, mover issues entre sprints em lote, listar issues de uma sprint com status resumido, e documentar a sprint preenchendo a descrição com Meta da Sprint, Prazos e Escopo. Use para qualquer operação de gestão de sprint — criar, fechar, mover issues, ver o que está numa sprint, ou "documentar a sprint", "preencher a milestone", "atualizar a descrição da sprint". IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

**Depois.** Gestão de sprint no backlog: criar, fechar com sumário, mover issues em lote, listar, documentar a milestone. Use para "fecha a sprint", "cria a sprint", "move pra próxima", "documenta a sprint". Só a meta é sprint-goal-generator.

## stop-slop · 408 → 189

**Antes.** Reescreve prosa para tirar cara de IA. Use sempre que o usuário disser "humaniza", "humaniza esse texto", "cheiro de IA", "cara de IA", "cara de ChatGPT", "parece GPT", "parece LLM", "padrões de LLM", "tira o GPT", "sem parecer máquina", "AI tells", "stop-slop", "stop slop", "slop", ou pedir para revisar um rascunho contra prosa formulaica. Não documenta demanda, não gera entregável, não reescreve código.

**Depois.** Reescreve prosa para tirar cara de IA. Use para "humaniza", "cheiro de IA", "cara de ChatGPT", "parece LLM", "stop-slop", ou rascunho formulaico. Não documenta demanda nem reescreve código.

## tech-lead · 522 → 203

**Antes.** Tech Lead do projeto. Acione para qualquer demanda técnica: entender como um fluxo funciona por baixo dos panos, consultar dados reais do banco de homologação, avaliar riscos e impactos técnicos de uma mudança, documentar demanda técnica ou discutir arquitetura. Enquanto o @product-specialist pensa em valor e requisito, o @tech-lead pensa em viabilidade, dados e implementação — use quando a pergunta for "como isso funciona de verdade?" ou "o que isso impacta no sistema?". Para telas e design, use o @product-designer.

**Depois.** Persona Tech Lead: viabilidade, dados e implementação. Como um fluxo funciona, dado real do banco, risco e impacto técnico, arquitetura. Use /tech-lead para "como isso funciona?" e "o que isso impacta?".

## wiki-publish · 573 → 184

**Antes.** Publica e atualiza páginas na wiki do projeto (GitLab, documents do Linear, Jira ou o backlog configurado). Use sempre que precisar publicar, criar ou atualizar documentação de produto na wiki — fluxo novo, módulo documentado, decisão técnica, ou entrada de changelog. Gatilhos: "publica na wiki", "cria a página", "atualiza a wiki", "documenta o módulo na wiki". Verifica se a página já existe antes de criar, e oferece append ou replace quando existe conteúdo anterior. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.

**Depois.** Publica ou atualiza páginas na wiki do projeto, conferindo antes se existem. Use para "publica na wiki", "cria a página", "atualiza a wiki". Entrada de changelog é changelog-generator.
