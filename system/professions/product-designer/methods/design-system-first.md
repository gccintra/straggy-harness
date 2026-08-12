# Design system primeiro — precedência de reúso

A causa nº 1 de tela inconsistente: transcrever valores crus da referência em vez de reusar
o que o sistema já tem. Antes de desenhar qualquer tela, **inventarie o protótipo**:
componentes existentes, tokens, e **uma tela irmã** do mesmo tipo (outra listagem, outro
formulário) — a tela nova tem que parecer irmã das que existem.

## Precedência — ordem fixa (o de cima vence)

1. **Componente já existente** no design system → use.
2. **Token** → use a classe/variável, nunca o valor cru da referência.
3. **Padrão de tela irmã** → siga (mesmo header, mesma tabela, mesma paginação).
4. **Lib pronta** reestilizada pros tokens → para comportamento que falta (tabela,
   modal, dropdown, tabs, date picker, gráfico). A lib dá estrutura, acessibilidade e
   estado; os tokens dão a aparência. Envolva a lib num componente do sistema — as telas
   importam do sistema, nunca da lib direto.
5. **Só então** crie do zero — e **adicione ao sistema** (token/componente), não hardcode
   na tela.

## Barra de qualidade

- Nenhum hex solto onde existe token equivalente. Diferença de 2-3 pontos entre o token e
  o pixel da produção é ruído de captura — o token vence, é ele que mantém a tela irmã
  das outras.
- Valor genuinamente novo do sistema → entra no config/tokens com nome de papel, e a tela
  usa a classe.
- One-off de layout (largura de container, gap pontual) pode ser inline.
- Reinventar comportamento que uma lib resolve é último recurso, não primeiro.
- Componente que a tela precisa e não existe → confirme que é gap **real** (não existe com
  outro nome) antes de criar.
- **Toda tela entra na navegação real** — rota registrada e alcançável pelo menu do
  produto. Tela que nenhum menu alcança não existe. Sem hub/galeria de telas.
