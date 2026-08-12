---
name: design-setup
description: >
  Configura o design system do projeto E faz o scaffold do app de protótipo navegável
  (prototype/) na primeira vez que o designer é acionado. Extrai tokens de cor, tipografia,
  espaçamento e padrões de componentes de prints/screenshots do sistema atual; grava os
  tokens na configuração de estilo e cria os componentes base transcritos das evidências.
  Push dos guidelines para a ferramenta de canvas é opt-in. Use na primeira vez que o
  designer for acionado — antes de criar qualquer tela — e para atualizar o design system
  quando ele evoluir.
---

# design-setup — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` |
| Métodos | `reference-authority.md` (**meça, não estime**; valores raw verbatim — não aproxime nem "melhore"; faltou evidência → pergunte) · `design-system-first.md` (libs prontas reestilizadas, nunca reinventar) |
| Providers | `canvas/` (só para export opt-in dos guidelines) |
| Stack | `references/stack-react-vite.md` — comandos, estrutura de pastas e convenções (a organização sobrescreve para usar outra stack) |

Uma vez por projeto. Re-execução **não recria** o protótipo — edita tokens e componentes.
Fonte de verdade do design system = **o código**, não a ferramenta de desenho.

## 1. Fontes de input (peça ao menos uma)

Screenshots do sistema atual · URL de protótipo · PDF de spec visual · descrição textual.
Mais evidência = design system mais preciso.

## 2. Extrair tokens

Cores (primária, surface, border, textos, status/badges) · tipografia (família, escala
xs→3xl, pesos) · espaçamento (grid 4/8, padding, radius, sombra) · componentes recorrentes
(botões, inputs, tabela, modal, badge, stepper, card, toast, navegação).

## 3. Scaffold do protótipo — contrato

A stack concreta está em `references/stack-react-vite.md`. Independente dela, o resultado
tem que cumprir:

- **Tokens em arquivo de configuração único**, e **nenhum valor solto na tela** — cor,
  fonte e espaçamento saem sempre do token.
- **Componentes base próprios** envolvendo libs prontas, transcritos das evidências; as
  telas importam desses componentes, nunca da lib direto.
- **Uma tela por rota**, registrada no roteador, alcançável pelo **menu real do produto**
  (transcrito da evidência) — sem página-índice, sem galeria de telas.
- **Rota raiz redireciona à tela default** do produto.
- **Wrapper de export** (largura desktop fixa, sem chrome do app) ativado por parâmetro na
  URL, para o export opt-in ao canvas.
- Projeto real usa outra stack de front → **alinhe antes** e sobrescreva a referência.

Verifique no browser: a raiz abre a tela default, o menu navega.

## 4. Guidelines no canvas — OPT-IN

Só com pedido explícito: rota de showcase do design system + captura via `html-to-figma`;
registre o id do node gerado no `.env`.

## 5. Registro

`history/YYYY-MM-DD_design-setup.md`: fontes usadas, tokens extraídos, componentes
criados, guidelines publicados (ou não). Deploy compartilhável → `prototype-deploy`
(passo separado).
