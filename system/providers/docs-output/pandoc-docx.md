---
selecao: pandoc-docx
capacidades: [render, layout-custom, image-embed]
requisitos:
  binarios: [python3]
  pacotes: [python-docx]
---

# Provider: docs-output — implementação generate_doc.py (python-docx)

Layout sob medida via script. Use quando o documento final precisa de identidade visual
própria — header com logo, sumário navegável, inserção automática de prints. Quem só
precisa converter o `.md` usa `pandoc-cli.md`, o default do pack.

**Ativa quando** `DOCS_OUTPUT_PROVIDER` aponta para esta implementação.
**Capacidades:** `render` · `layout-custom` · `image-embed`.
**Dependência:** `python-docx` (`pip install python-docx`) e o script da organização.

O script vive junto do workflow gerador da organização (`org/workflows/<gerador>/
generate_doc.py`) — é lá que o layout é mantido. O pack não ships script.

## Uso

```bash
python3 .agents/org/workflows/<gerador>/generate_doc.py <md_path> <saida.docx>
```

- O rótulo do header é inferido do frontmatter do `.md` (chave `tipo:`, valores definidos
  pela organização em `org/ORG.md`).
- Logo do header: `org/workflows/<gerador>/assets/header_logo.png` (~730×61 px) —
  substitua pelo logo do projeto; ausente → header só com texto.
- Prints (capacidade `image-embed`): se a seção de protótipo do `.md` tem headings de
  print, o script procura primeiro `prototipo-prints/{IDENTIFICACAO}/` ao lado do `.md`
  (ex.: `prototipo-prints/HU08.02/`, ID extraído do metadado de identificação) e mantém
  `prototipo-prints/` como fallback para pastas legadas com um único documento. Em pastas
  com várias HUs/HTs, cada subpasta usa numeração local contínua (partes `a/b/c` em
  sequência). Divergência heading × arquivo interrompe a geração — é proposital: documento
  com print faltando é pior que geração abortada.
- Apêndices (`## Apêndice — …`) são cortados do documento final automaticamente.
- Validar: `python3 -c "from docx import Document; Document('<arquivo>')"`.

**Mudou o template? Edite o script, não descreva o layout em skill** (`INTERFACE.md`,
contrato transversal).
