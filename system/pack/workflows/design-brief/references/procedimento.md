# Procedimento padrão — analisar demanda de tela (pack)

Passo a passo default da ação `analisar-demanda-de-tela`. A organização sobrescreve este
arquivo em `org/workflows/design-brief/references/procedimento.md`.

## Triagem — quanto de análise a entrada merece (decida ANTES de ler)

| Entrada | Nível | Ação |
|---|---|---|
| Ajuste em tela/componente existente | **nenhum** | não rode a brief — direto ao `design-screen` modo Ajuste |
| Texto simples, tela nova, sem doc | leve | inventário + 5-10 linhas de conversa (menu, irmã, reuso, estados) |
| Imagem/print de produção · Figma autoral | média | inventário + análise; layout já resolvido, você resolve navegação/reuso/gaps |
| Wireframe/rabisco | média-alta, **obrigatória** | + leitura em voz alta: interprete cada bloco em termos do design system, pergunte os buracos DE UMA VEZ (bloco ambíguo, estados, comportamento, o que ficou fora da folha) e deixe claro que o visual sai do sistema, não do rabisco |
| Documentação / requisito / issue / `.md` do PM | completa | fluxo inteiro abaixo |

## Fluxo (nível completo)

1. **Ler a demanda**: demanda pelo provider (ou `{caminhos.pasta_por_demanda}` no modo local) + contexto
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
