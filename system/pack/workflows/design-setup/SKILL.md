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
acao:
  id: configurar-design-system
  rotulo: Configurar design system
  descricao: extrai tokens e faz o scaffold do protótipo
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo: Como fazer
    ajuda: De onde sua empresa tira os tokens (prints, sistema no ar, biblioteca existente) e o que o design system precisa cobrir.
    tipo: texto-longo
  stack-prototipo:
    caminho: references/stack-react-vite.md
    rotulo: Stack do protótipo
    ajuda: A tecnologia em que o app de protótipo da sua empresa é construído. Vazio → React + Tailwind + Vite.
    tipo: texto-longo
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


**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.

## 1. Scaffold do protótipo — contrato

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

## 2. Guidelines no canvas — OPT-IN

Só com pedido explícito: rota de showcase do design system + captura via `html-to-figma`;
registre o id do node gerado no `.env`.

## 3. Registro

`{caminhos.historico}YYYY-MM-DD_design-setup.md`: fontes usadas, tokens extraídos, componentes
criados, guidelines publicados (ou não). Deploy compartilhável → `prototype-deploy`
(passo separado).
