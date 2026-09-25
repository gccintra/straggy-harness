# HRN-020 — Prints do protótipo mostram a tela, não o componente solto

| | |
|---|---|
| **Estado** | verde |
| **Camada** | L2 pack (moldura da `prototype-prints` + padrão do encaixe `procedimento`) |
| **Arquivos** | `system/pack/workflows/prototype-prints/references/captura.md` · `capture.template.mjs` · `references/procedimento.md` · `SKILL.md` |
| **Data** | 2026-09-25 |

## História

Como **quem lê o documento da demanda**, quero **que cada print mostre em que tela estou**,
para **entender onde o trecho documentado vive no sistema**.

Hoje a mecânica manda recortar modal, card e tabela no limite do elemento. O resultado é um
componente solto, sem cabeçalho, título nem posição na tela — o usuário relata prints
"confusas" de forma recorrente. Além disso, `full()` do template falha em telas longas
(`Clipped area is either empty or outside the resulting image`) por não passar `fullPage`.

## Regras de negócio

- **RN-01.** O padrão da captura é **tela em contexto**: largura total, do topo da página
  (cabeçalho, título) até o fim do trecho que a demanda declara.
- **RN-02.** Modal é capturado aberto sobre a tela, com o fundo escurecido visível e o modal
  inteiro dentro da imagem.
- **RN-03.** Recorte só do componente é exceção, usada somente com pedido explícito.
- **RN-04.** As medidas do DOCX (partes de `largura × 1,10`, borda de 1 px, sem reamostragem)
  continuam valendo.
- **RN-05.** Portões, write-gate e contrato de saída da skill não mudam.

## Impacto

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | Nenhuma referência a `captura.md`, ao template ou à regra de recorte fora da pasta do workflow. `docs/WORKFLOWS.md` cita só a ação e os encaixes. | — |
| Esteira | `produz: prints-capturadas` e `requer` inalterados. | — |
| Evals | `evals/captura-prints` é de roteamento; frase e ação inalteradas. O estilo da imagem não é verificável por eval de roteamento. | manter |
| Organização | `org/workflows/prototype-prints/` não existe; nenhum encaixe preenchido. Caminhos de encaixe inalterados. | — |
| Camada | Mecânica de imagem é contrato de saída da moldura (`captura.md`); critério de recorte é procedimento (encaixe). | mantém |

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | Frontmatter, ações, encaixes e fichas seguem íntegros | `./build.sh --strict` |
| CA-02 | Runtime gerado igual à fonte | `./build.sh --check` |
| CA-03 | Organização vazia continua com padrão para todo encaixe | `./build.sh --org <vazio> --out <tmp>` |
| CA-04 | O roteamento da ação não mudou | eval `prototype-prints/captura-prints` |

## Fora de escopo

- Recapturar prints já entregues de outras demandas.
- Caso de eval de comportamento sobre o formato da imagem (não há runner que avalie PNG).
- Destaque visual (moldura colorida) do trecho dentro da tela em contexto.

## Registro

- `captura.md`: a seção "Modal, card, tabela — recorte no limite do elemento" deu lugar a
  "Tela em contexto — o padrão", "Modal — aberto sobre a tela" e "Componente recortado — só
  com pedido explícito". A nota do dropdown passou a valer só para o recorte de exceção.
- `capture.template.mjs`: `fullPage: true` no clip; `fatiar()` extraída de `full()`; novas
  `contexto()` e `modalEmContexto()`; `modal()` e `element()` marcadas como exceção; exemplo
  do fluxo usa o padrão novo. Validado na #1022 (prints 14 e 22) antes da edição.
- `SKILL.md` §2 e §3: descrição da mecânica e verificação de contexto. `procedimento.md`:
  critério de início e fim da captura.
- Provas: `--strict` 0 · `--check` 0 · `--org <vazio>` sem aviso de "sem padrão no pack". Esse
  modo reprova por `WORKFLOWS.md divergiu`, e reprova igual com as mudanças revertidas
  (pré-existente, fora desta mudança).
- Na recaptura da #1022, seções fundas do detalhamento (a 1,4–1,8 × a largura do topo) viravam 2 partes. `contexto()` passou a entregar uma janela única que termina no alvo e começa no topo de um bloco irmão do alvo (ou de um ancestral), com as seções vizinhas acima; só alvo maior que a janela vira partes. `captura.md` descreve isso.
- CA-04: eval de roteamento não rodado — frase, ação e description inalteradas.

