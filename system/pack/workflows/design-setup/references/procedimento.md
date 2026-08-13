# Procedimento padrão — configurar design system (pack)

Passo a passo default da ação `configurar-design-system`. A organização sobrescreve este
arquivo em `org/workflows/design-setup/references/procedimento.md`.

O contrato do scaffold, o export opt-in dos guidelines e o registro são da moldura e valem
junto com o que estiver aqui.

## 1. Fontes de input (peça ao menos uma)

Screenshots do sistema atual · URL de protótipo · PDF de spec visual · descrição textual.
Mais evidência = design system mais preciso.

Ordem de confiabilidade quando houver mais de uma: sistema no ar > screenshot de produção >
spec visual > descrição textual. Fonte mais fraca só preenche o que a mais forte não mostra.

## 2. Extrair tokens

Cores (primária, surface, border, textos, status/badges) · tipografia (família, escala
xs→3xl, pesos) · espaçamento (grid 4/8, padding, radius, sombra) · componentes recorrentes
(botões, inputs, tabela, modal, badge, stepper, card, toast, navegação).

Token que nenhuma evidência sustenta fica de fora e é declarado como pendente — inventar
valor aqui contamina todas as telas construídas depois.
