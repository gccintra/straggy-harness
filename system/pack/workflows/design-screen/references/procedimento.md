# Procedimento padrão — construir tela (pack)

Passo a passo default da ação `construir-tela`. A organização sobrescreve este arquivo em
`org/workflows/design-screen/references/procedimento.md`.

As regras de arquivo, a verificação visual, o registro do protótipo e o export são da
moldura e valem junto com o que estiver aqui.

## 1. Modo — decida ANTES de pedir qualquer coisa

Olhe o protótipo primeiro: a tela/componente já existe em `prototype/src/`?

- **AJUSTE** (existe): a referência é o próprio protótipo — ache o componente (`grep`),
  compare com tela irmã e tokens, edite pro padrão do sistema, verifique no Vite.
  **Sem pedir print/node, sem gate** — alinhamento prévio só se o "certo" for ambíguo.
- **NOVO** (não existe): carregue o contexto (demanda pelo provider / `{caminhos.pasta_por_demanda}` /
  descrição). Existe node/imagem disponível? Peça **uma vez**, junto de tudo mais que
  precisar. Não existe? Derive de tela irmã + design system e siga — a fidelidade sobe
  depois, com a referência em mãos:
  > "Quais nodes do Figma eu uso? 1) Tela de referência (link ou nodeId); 2) componentes
  > específicos; 3) design system (opcional, já temos em `ui/`)."
  Nunca invente nodeId. Leitura e conversão do node: provider `canvas/figma-mcp.md`.
  Imagem → **meça com Pillow** (cor por pixel, medida por transição; retina ÷2; pergunte
  estados e fonte). Wireframe → passe pela `design-brief` antes (obrigatória).

## 2. Plano — proporcional, não obrigatório

- Já existe `{caminhos.pasta_por_demanda}{ID}_design.md`? **Ele é o plano** — confirme em 2-3 linhas e
  construa. Demanda com documentação sem design doc → rode a `design-brief` antes.
- **Vai direto ao código** (sem gate): ajuste, tela com irmã óbvia, componente pequeno,
  estado faltando.
- **Alinha 3-5 linhas antes**: tela nova sem precedente, mudança de fluxo ou de navegação,
  algo que conflita com a doc. Rota, tela irmã, seções em ordem, componentes reusados,
  estados, dados de mock — e siga sem esperar aprovação item a item.
- Construa de ponta a ponta. Decisão pequena é sua; só pare se descobrir que o **resultado**
  pedido era outro.
