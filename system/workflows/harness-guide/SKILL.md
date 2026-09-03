---
name: harness-guide
description: >
  Responde perguntas sobre o próprio harness sem editar nada: o que ele já sabe fazer, onde
  cada coisa mora, como um workflow funciona, o que ele entrega, onde ele para, e o que
  quebra se você mudar alguma coisa. Use SEMPRE que o usuário perguntar "o que o harness
  faz", "isso já existe?", "já tem skill pra X?", "como funciona a discovery/o build/os
  encaixes", "onde eu edito X", "onde mora essa regra", "quem usa esse arquivo", "o que
  quebra se eu mudar/renomear/apagar X", "qual o raio de impacto", "que skills existem",
  "por que isso está assim" — e antes de qualquer edição, para levantar o impacto. É
  SOMENTE LEITURA: não cria, não edita, não roda build. Quem escreve é a `harness-change`.
objetivo: Responder o que o harness já faz, onde cada coisa mora e o que quebra ao mudá-la — sem tocar em arquivo nenhum.
---

# harness-guide — entender o harness

Leitura. Esta skill **nunca escreve**. Pedido que termina em edição sai daqui e vai para a
`harness-change` — inclusive quando a resposta torna a edição óbvia.

Restrições: `system/CONSTITUTION.md`. Em especial §4 — afirmação sobre o sistema sai de
fonte lida, com a fonte citada. Não achou nas fontes, diga que não achou; nunca preencha
com o que "deveria" estar lá.

## 1. As fontes, nesta ordem

Responda da fonte mais barata que resolve. Ler 27 `SKILL.md` para dizer o que o harness faz
é trabalho que já foi feito e está derivado.

| Pergunta | Fonte | Por quê |
|---|---|---|
| o que existe, o que entrega, onde para, que arquivo editar | `docs/WORKFLOWS.md` | ficha por workflow, derivada do frontmatter — não envelhece |
| o mesmo, como dado | `runtime/manifest.json` | quando precisa filtrar ou cruzar, não ler |
| como o mecanismo funciona (camadas, encaixe, provider, esteira, build, eval) | `docs/HARNESS.md` | uma página |
| a regra normativa, quando a de cima não basta | `docs/ARCHITECTURE.md` | é o texto que decide |
| onde a mudança mora, e o que faz estar pronta | `docs/MANUTENCAO.md` | tabela por camada |
| por que uma coisa está assim | `docs/mudancas/HRN-*.md` | história, regras e critérios de cada mudança |
| o que a organização contrata | `system/ACOES.md` | catálogo público |
| convenção desta empresa | `org/ORG.md` | — |
| o que roda de verdade agora | `./runtime/build.sh --list` | origem e encaixes preenchidos por workflow |

Estado dos documentos: `docs/` descreve **o que roda hoje**. `docs/hub/` é o produto com
interface e **nada dele está implementado** — nunca responda a partir de lá sem dizer que
aquilo é desenho.

## 2. Os quatro tipos de pergunta

**"O harness já faz X?"** — tabela de `docs/WORKFLOWS.md`. Achou a ação: dê o objetivo, o que
entrega e onde para, e aponte a ficha. Não achou: diga que não existe e qual ação vizinha
chega mais perto. Nunca responda "dá para fazer" sobre o que não está declarado.

**"Como funciona X?"** — a ficha responde o contrato (entrega, portões, esteira, provider).
O *procedimento* está no `SKILL.md` do workflow e no encaixe `procedimento` da organização,
quando preenchido — a ficha diz o caminho dos dois. Diga qual dos dois você leu.

**"Onde eu edito X?"** — `docs/MANUTENCAO.md` §1 dá a camada; a ficha do workflow dá o
arquivo exato e se aquele encaixe está preenchido pela organização ou rodando no padrão do
pack. Responda os dois, nessa ordem: a camada explica, o caminho executa.

**"O que quebra se eu mudar X?"** — `references/impacto.md`. É a pergunta que mais custa
errar, e a única desta skill que exige varredura, não leitura.

## 3. Contrato de saída

A conversa é o entregável. Nenhum arquivo é escrito, nem relatório, nem rascunho.

- **Cite o arquivo** de onde saiu cada afirmação. Resposta sem fonte é chute com formatação.
- **Separe o que está declarado do que você inferiu.** "A ficha diz X" e "pelo que li do
  procedimento, provavelmente Y" são frases diferentes e o usuário precisa da diferença.
- **Divergência entre fontes é a informação valiosa** — a ficha diz uma coisa e o corpo do
  `SKILL.md` diz outra, o `README` cita um caminho que não existe. Aponte, não concilie em
  silêncio: é defeito a corrigir, e o conserto é `harness-change`.
- **Termine no ponto de edição, sem atravessá-lo.** Ao fim de uma resposta que leva a uma
  mudança, diga qual é a camada e qual seria o próximo passo — e pare. Escrever é da
  `harness-change`, com spec e portão próprios.
