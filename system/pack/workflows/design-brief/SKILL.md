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

## Triagem — quanto de análise a entrada merece (decida ANTES de ler)

| Entrada | Nível | Ação |
|---|---|---|
| Ajuste em tela/componente existente | **nenhum** | não rode a brief — direto ao `design-screen` modo Ajuste |
| Texto simples, tela nova, sem doc | leve | inventário + 5-10 linhas de conversa (menu, irmã, reuso, estados) |
| Imagem/print de produção · Figma autoral | média | inventário + análise; layout já resolvido, você resolve navegação/reuso/gaps |
| Wireframe/rabisco | média-alta, **obrigatória** | + leitura em voz alta: interprete cada bloco em termos do design system, pergunte os buracos DE UMA VEZ (bloco ambíguo, estados, comportamento, o que ficou fora da folha) e deixe claro que o visual sai do sistema, não do rabisco |
 Documentação / requisito / issue / `.md` do PM | completa | fluxo inteiro abaixo |

Só o nível completo gera documento, e só quando pedido. Demanda sem ID não gera doc.

## Fluxo (nível completo)

1. **Ler a demanda**: demanda pelo provider (ou `outputs/{ID}_*/` no modo local) + contexto
   do produto pelo provider `knowledge/`.
   Extraia só a **superfície de tela**: CA → comportamento observável; RN → estado/
   habilitação/máscara/cálculo exibido; MSG → **um lugar concreto** na tela; escopo →
   quais telas entram. Regra de backend puro → anote, não invente UI.
2. **Inventariar o protótipo** (obrigatório em todo nível ≥ leve):
   ```bash
   ls prototype/src/routes/**/*.tsx prototype/src/components/ui/ prototype/src/mock/
   sed -n '/theme:/,/}/p' prototype/tailwind.config.js
   grep -rn "to=\"" prototype/src/components/layout/AppHeader.tsx
   ```
   Levante: telas tocadas · tela irmã · cobertura de `ui/` · **gap real** (na dúvida,
   `grep` antes de declarar) · mock disponível.
3. **Analisar**: onde entra na navegação (2-3 direções com trade-off + **recomendação**),
   estados que a doc não previu, impacto no que existe (telas tocadas, variantes),
   pendências de produto (CA sem reflexo, MSG sem lugar, RN que exige campo inexistente)
   — **liste, não resolva**.
4. **Conversar — o entregável padrão.** Blocos: Superfície de tela · O protótipo já tem ·
   Navegação · Estados · Impacto no que existe · Pendências de produto. Nível leve: os
   mesmos blocos em 5-10 linhas. **PARE aqui e itere na conversa** — é ordens de grandeza
   mais barato que iterar em JSX.

## Documento de design — OPT-IN (write-gate)

Só quando o usuário pedir, só para demanda com ID:
`outputs/{ID}_{NomeCurto}/{ID}_design.md`:

```markdown
# [DESIGN] {ID} — <Nome>
Data · Agente: product-designer · Fonte: issue #NNN · doc: outputs/{ID}_*/{ID}.md

## 1. O que a demanda vira na interface
## 2. Navegação e arquitetura de informação   (direções avaliadas + decisão + porquê)
## 3. Telas                                    (por rota: irmã, seções, reusa, novo, estados, dados)
## 4. Impacto no que já existe
## 5. Pendências de produto
## 6. Fora de escopo
```

## Handoff

O `{ID}_design.md` **é** o plano do `design-screen` — ele não realinha do zero. Sem doc
gerado, a conversa vale como plano.

**Não faz:** JSX, medir pixel, transcrever node, comentar em issue, editar `.md` do PM.
**Nunca meça um wireframe.**
