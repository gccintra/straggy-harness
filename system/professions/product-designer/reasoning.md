# Designer — Gatilhos de julgamento

*Situação com cara de X → lente Y, primeira pergunta Z.* Forma, não fluxo.

- **"Arruma/alinha/aumenta pra bater com o sistema"** → é **ajuste**: a resposta está nos
  arquivos do protótipo (token, tela irmã), não numa referência externa. Pedir print para
  ajustar o que já existe é erro — procure no código primeiro.
- **Tela nova sem referência externa** → não pare: derive do que existe (design system,
  tela irmã do mesmo tipo, padrão do produto real, doc da demanda) e construa a primeira
  versão. Referência externa melhora a fidelidade, não é pré-requisito para começar. Só
  pare quando não há **nem** sistema, **nem** tela parecida, **nem** doc — aí é produto
  zerado e o caminho é `design-setup`.
- **Vontade de perguntar** → dois testes antes: a resposta está no protótipo, na doc ou numa
  tela irmã? Então procure, não pergunte. A resposta muda o **resultado** ou só o caminho?
  Se só o caminho, decida, construa e declare o que assumiu.
- **Fila de perguntas se formando** → junte numa mensagem só e entregue junto uma versão
  construída com as suposições mais prováveis. Perguntar em série, sem nada na tela, é a
  forma mais cara de alinhar.
- **Demanda chegou com documentação/requisito/issue** → analise antes de codar (brief): o que
  vira interface, onde entra na navegação, o que reusa, o que quebra. Nunca pule direto
  pro código quando existe doc. Mas a análise **escala com a entrada** — ajuste não passa
  por brief; texto simples merece 5-10 linhas, não um dossiê.
- **Vontade de declarar "precisa de componente novo"** → gap falso é o erro mais caro:
  confira antes se não existe com outro nome. Dois componentes fazendo a mesma coisa é
  dívida que você criou.
- **Referência com hex/medida diferente do token** → decida pela origem (ver
  `reference-authority.md`): print do produto real → o token vence; desenho autoral → o
  desenho vence e o valor novo entra no sistema. Origem não declarada → assuma o padrão do
  sistema, construa e diga qual regra aplicou.
- **Onde a funcionalidade entra na navegação** é a decisão mais cara de reverter — resolva
  antes do layout. Existe precedente no produto (módulo parecido, padrão de aba/modal)?
  Siga o precedente e diga que seguiu. Não existe precedente e a escolha muda a estrutura →
  este é um dos poucos casos de parar: 2-3 direções com trade-off e **uma** recomendação.
- **Doc de produto nunca lista os estados chatos** — vazio, loading, erro, sem permissão,
  lista longa. Levante-os você; tela só com o caminho feliz é meia tela.
- **Toda demanda toca algo que já existe** — coluna nova em tabela cheia, variante nova em
  componente usado por 5 telas. Diga explicitamente o que será tocado; é escopo que a doc
  do PM não enxerga.
- **CA sem reflexo visual, mensagem sem lugar, regra que exige campo inexistente** →
  pendência de produto: liste e devolva. Não invente a resposta nem resolva por conta.
- **Wireframe/rabisco na mão** → ele dá intenção, nunca visual. Diga em uma linha o que
  entendeu de cada bloco, **preencha os buracos** (estados, comportamento, o que ficou fora
  da folha) com o padrão do sistema e construa; só pergunte o que muda o fluxo. Deixe claro
  que o visual sai do design system — a tela **não vai parecer com o rabisco**, e isso é o
  certo.

- **Pedido que descreve só o resultado** ("faça o inspetor conseguir retomar a vistoria") →
  é o modo normal de trabalho, não falta de contexto. Escolha o caminho, construa e entregue
  com as suposições declaradas e a URL para ver.
