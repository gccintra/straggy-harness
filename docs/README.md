# Documentação do harness

Duas pilhas, e a diferença entre elas importa: **esta pasta descreve o que roda hoje**;
[`hub/`](hub/) especifica o produto com interface, do qual **nada está implementado**.

## O que roda hoje

| Documento | Responde | Escrito ou gerado |
|---|---|---|
| [`HARNESS.md`](HARNESS.md) | o que é, como uma conversa vira artefato, o que o build faz | à mão |
| [`WORKFLOWS.md`](WORKFLOWS.md) | quais workflows existem, o que cada um entrega, onde para, que arquivo editar | **gerado** por `./build.sh --fix` |
| [`MANUTENCAO.md`](MANUTENCAO.md) | como mudar qualquer coisa, e o que faz uma mudança estar pronta | à mão |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | a regra normativa — camadas, precedência, encaixes, manifesto, evals | à mão |
| [`MODOS.md`](MODOS.md) | quem manipula o quê no modo repositório, e o contrato de portabilidade para o modo aplicativo | à mão |
| [`mudancas/`](mudancas/) | uma HRN por mudança — história, regras, critérios de aceite e estado | à mão |
| [`../system/ACOES.md`](../system/ACOES.md) | o catálogo público: o que a organização contrata e onde ela escreve | **gerado** |
| [`../README.md`](../README.md) | instalar, configurar e usar no dia a dia | à mão |

## Por onde começar

- **Nunca vi este harness** → [`HARNESS.md`](HARNESS.md), depois a tabela de
  [`WORKFLOWS.md`](WORKFLOWS.md).
- **Quero saber se ele já faz X** → tabela de [`WORKFLOWS.md`](WORKFLOWS.md); achou a ação,
  leia a ficha dela.
- **Vou editar alguma coisa** → [`MANUTENCAO.md`](MANUTENCAO.md) §1 decide a camada; a ficha
  do workflow em [`WORKFLOWS.md`](WORKFLOWS.md) dá o arquivo exato.
- **Quero a regra, não o resumo** → [`ARCHITECTURE.md`](ARCHITECTURE.md).

Nada disso precisa ser lido à mão: **pergunte à skill `harness-guide`** ("o que o harness já
faz?", "onde mora essa regra?", "o que quebra se eu mudar isso?"). Ela lê estas fontes, é
somente leitura e cita de onde tirou cada resposta. Editar é a `harness-change`, que
especifica antes de escrever.

## O produto com interface

[`hub/`](hub/) — PRD, MVP, telas, estratégia, arquitetura web e o discovery que produziu
tudo isso. É desenho: **nenhuma feature do Hub está implementada.** Fica em pasta separada
justamente para que nada dali seja lido como descrição do que existe.
