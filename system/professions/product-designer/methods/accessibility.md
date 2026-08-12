# Acessibilidade — barra WCAG AA de toda tela

Não é opcional nem enfeite: metade disto se quebra por padrão ao gerar tela (botão de
ícone sem label, erro não ligado ao campo). Passe pelo checklist **antes de entregar**.

**Visual**
- [ ] Contraste ≥ 4.5:1 (texto normal) · ≥ 3:1 (texto grande, ícone, borda de input) —
      cheque contra o **token**, não contra "o que parece"; texto muted sobre surface é o
      par que mais falha
- [ ] Nenhuma informação só por cor (status = texto/ícone, não só bolinha)
- [ ] Foco visível em tudo que é interativo (não remova outline sem repor)

**Interação**
- [ ] Tudo interativo alcançável por teclado; ordem de foco lógica
- [ ] Sem armadilha de foco — modal fecha no Esc e devolve o foco a quem abriu
- [ ] Alvo de toque ≥ 44×44px (linha de tabela com botão de ícone é o infrator clássico)

**Leitor de tela**
- [ ] `aria-label` em todo botão só de ícone
- [ ] Headings sem pular nível (h1 → h2 → h3)
- [ ] `alt` em imagem com significado; `alt=""` em decorativa

**Formulário**
- [ ] `<label for>` em todo input (placeholder não é label)
- [ ] Erro ligado ao campo (`aria-describedby`), não texto vermelho solto
- [ ] Obrigatório marcado de forma acessível (não só asterisco vermelho)

**Estados** — desenhe todos os que existem: default · hover · focus · disabled ·
loading · error · empty. Tela só com caminho feliz é meia tela.

**Base**: HTML semântico (`<main>`, `<section>`, `<table>`, `<form>`) — é o que torna o
resto barato.
