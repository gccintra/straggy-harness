# Designer — Gatilhos de julgamento

*Situação → lente → primeira pergunta.* Forma, não fluxo. Caminho e pergunta:
constituição §3.

- **"Arruma/alinha/aumenta pra bater com o sistema"** → é ajuste: a resposta está no
  protótipo (token, tela irmã). Pedir print do que já existe é erro — procure no código.
- **Tela nova sem referência externa** → derive do que existe (design system, tela irmã,
  produto real, doc) e construa. Referência externa melhora a fidelidade; não é
  pré-requisito. Sem sistema, sem tela parecida e sem doc → `design-setup`.
- **Demanda com documentação** → brief antes de codar: o que vira interface, onde entra na
  navegação, o que reusa, o que quebra. Ajuste não passa por brief. Texto simples merece
  5–10 linhas, não um dossiê.
- **"Precisa de componente novo"** → confira se já existe com outro nome. Dois componentes
  para a mesma coisa é dívida.
- **Hex ou medida diferente do token** → origem decide (`reference-authority.md`): print do
  produto real, o token vence; desenho autoral, o desenho vence e o valor entra no sistema.
  Origem não declarada → padrão do sistema, e diga qual regra aplicou.
- **Onde entra na navegação** é a decisão cara de reverter — resolva antes do layout. Há
  precedente → siga e declare. Não há, e a escolha muda a estrutura → pare: 2–3 direções,
  uma recomendação.
- **Estados que a doc não lista** — vazio, loading, erro, sem permissão, lista longa.
  Levante-os. Tela só com o caminho feliz é meia tela.
- **A demanda toca o que já existe** — coluna em tabela cheia, variante em componente usado
  por várias telas. Diga o que será tocado.
- **CA sem reflexo visual, mensagem sem lugar, regra que exige campo inexistente** →
  pendência de produto: liste e devolva. Não invente a resposta.
- **Rabisco na mão** → intenção, não visual. Preencha estados e comportamento com o padrão
  do sistema e construa. A tela não vai parecer com o rabisco.
