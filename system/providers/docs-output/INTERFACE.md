# Provider: docs-output — interface

Transforma o `.md` consolidado (fonte de verdade) em documento formal entregável.

## Seleção da implementação

`DOCS_OUTPUT_PROVIDER` no `.env`: `pandoc` (default) · `none` · nome de uma implementação
da organização.

- **`pandoc-cli.md`** — default do pack. Converte o `.md` direto, com estilo opcional via
  documento de referência. Sem código próprio para manter.
- **`pandoc-docx.md`** — layout sob medida via script `python-docx`. Implementação de quem
  precisa de header com logo, sumário real, inserção automática de prints.
- Implementação própria da organização: `org/providers/docs-output/<nome>.md`, sob esta
  mesma interface.

## Operações

| Operação | L/E | Capacidade exigida |
|---|---|---|
| gerar documento final a partir do `.md` consolidado | **E** (arquivo entregável → write-gate) | `render` |
| aplicar identidade visual (logo, header, sumário) | **E** | `layout-custom` |
| inserir imagens declaradas no `.md` (prints) | **E** | `image-embed` |
| validar o arquivo gerado | L | `render` |

Capacidade ausente = indisponibilidade explícita, informada ao usuário — nunca contorno
silencioso:

> "A implementação ativa (`<provider>`) não insere prints automaticamente. Os títulos
> ficam no `.md` e as imagens entram à mão, ou troque `DOCS_OUTPUT_PROVIDER`."

## Gate e modo degradado

`DOCS_OUTPUT_PROVIDER=none`, binário ausente ou dependência não instalada → **pare** e
avise. Não existe fallback: o `.md` consolidado já é o entregável válido.

> "Nenhum gerador de documento final configurado (`DOCS_OUTPUT_PROVIDER` no `.env`). O
> `.md` em `outputs/` continua sendo a fonte de verdade e pode ser entregue como está."

## Contrato transversal

- **O `.md` é a fonte; o documento final é transcrição.** O gerador não relê discovery,
  não cria conteúdo, não reinterpreta. Documento final errado → conserta-se o `.md` e
  regera; **nunca editar o arquivo final à mão**.
- O `.md` segue o **contrato de formato por padrão de linha** do workflow
  `doc-consolidator` (as implementações que fazem parsing dependem dele).
- **Layout mora na implementação, nunca em prosa de skill.** Mudou o template → edita-se a
  implementação (documento de referência ou script), não o workflow.
