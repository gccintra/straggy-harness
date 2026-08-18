---
name: design-brief
description: >
  Analisa uma demanda ANTES de construir a tela: lê a documentação do PM (`.md` consolidado,
  documento de requisito, issue), varre o protótipo existente (rotas, componentes de ui/,
  tokens, telas irmãs) e devolve em conversa o que a demanda vira na interface — navegação, reuso, gaps do design
  system, estados não previstos, impacto nas telas existentes, pendências de produto. Escala
  com a entrada: ajuste em tela existente não passa por aqui; texto simples vira análise
  leve; imagem vira média; documentação/issue vira completa. Gerar o {ID}_design.md é
  OPT-IN, no fim. Use quando o usuário pedir para analisar, avaliar, sugerir ou entender uma
  demanda de tela antes de codar. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md
  antes de qualquer operação no backlog.
acao:
  id: analisar-demanda-de-tela
  rotulo: Analisar demanda de tela
  descricao: analisa o que a demanda vira na interface, antes do código
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo: Como fazer
    ajuda: O que sua empresa quer ver numa análise de interface antes de alguém desenhar a tela.
    tipo: texto-longo
---

# design-brief — workflow L2

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` — read-only por padrão: nada é escrito até o usuário pedir o documento |
| Métodos | `system/professions/product-designer/` — `reasoning.md` (navegação é a decisão mais cara; estados chatos; gap falso; pendência se lista, não se resolve) · `design-system-first.md` |
| Providers | `backlog/` — **com fallback local** · `knowledge/` |
| Formatos | template do `{ID}_design.md` abaixo |

Pensar a interface antes do JSX. `design-screen` responde "como transcrevo esta
referência?"; a brief responde "o que esta demanda vira na interface, e o que ela quebra?".

**Contexto carregado em todo nível ≥ leve** (moldura, não depende do procedimento): a
demanda pelo provider `backlog/` — ou `{caminhos.pasta_por_demanda}` no modo local — e o
contexto do produto pelo provider `knowledge/` (regra de negócio, requisito de referência,
glossário). Ausência é contexto vazio declarado, nunca preenchido por chute.


**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.

## Contrato de saída — a conversa é o entregável

Blocos: Superfície de tela · O protótipo já tem · Navegação · Estados · Impacto no que
existe · Pendências de produto. Análise leve entrega os mesmos blocos em 5-10 linhas.

**PARE aqui e itere na conversa** — é ordens de grandeza mais barato que iterar em JSX.

## Documento de design — OPT-IN, salvo quando alimenta a documentação (write-gate)

Só a análise completa gera documento, e só quando pedido. Demanda sem ID não gera doc.

Quando o usuário pedir, e **sempre** que a demanda tem ID e vai virar documento consolidado
— aí ele deixa de ser opcional: é a entrada do `doc-consolidator`, que na demanda com
interface roda depois do protótipo validado.
`{caminhos.pasta_por_demanda}{ID}_design.md`:

```markdown
# [DESIGN] {ID} — <Nome>
Data · Agente: product-designer · Fonte: issue #NNN · doc: {caminhos.pasta_por_demanda}{ID}.md

## 1. O que a demanda vira na interface
## 2. Navegação e arquitetura de informação   (direções avaliadas + decisão + porquê)
## 3. Telas                                    (por rota: irmã, seções, reusa, novo, estados, dados)
## 4. Impacto no que já existe
## 5. Pendências de produto
## 6. Fora de escopo
```

## Handoff

O `{ID}_design.md` **é** o plano do `design-screen` — ele não realinha do zero. Sem doc
gerado, a conversa vale como plano. Depois do protótipo aceito, o próprio `design-screen`
reescreve esse arquivo com o que a tela faz de fato: o mesmo documento nasce plano e termina
registro, e é dele que a documentação sai.

**Não faz:** JSX, medir pixel, transcrever node, comentar em issue, editar `.md` do PM.
**Nunca meça um wireframe.**
