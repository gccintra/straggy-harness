---
capacidades: [render]
requisitos:
  binarios: [pandoc]
---

# Provider: docs-output — implementação pandoc CLI (default do pack)

Conversão direta do `.md` consolidado para o formato final, sem código próprio. É o default
porque funciona em qualquer projeto com `pandoc` instalado e não exige template mantido à
mão.

**Ativa quando** `DOCS_OUTPUT_PROVIDER=pandoc` (ou vazio).
**Capacidades:** `render`. **Não suporta** `layout-custom` nem `image-embed` — quem precisa
disso usa `pandoc-docx.md` ou uma implementação própria.
**Dependência:** `pandoc` no PATH (`pandoc --version`). Ausente → gate da `INTERFACE.md`.

## Uso

```bash
pandoc "{caminhos.pasta_por_demanda}{ID}_{NomeCurto}.md" \
  -o "{caminhos.pasta_por_demanda}{ID}_{NomeCurto}.docx" \
  --toc --toc-depth=2
```

Outros formatos, mesma chamada trocando a extensão de saída: `.pdf` (exige
`--pdf-engine`, ex.: `weasyprint` ou `xelatex`), `.odt`, `.html` (`--standalone`).

### Identidade visual (opcional)

`pandoc` aplica estilos de um documento `.docx` de referência — fontes, cores, espaçamento,
header e footer saem de lá:

```bash
pandoc entrada.md -o saida.docx --reference-doc=<caminho-do-modelo>.docx
```

Gerar o esqueleto do modelo para editar no Word/LibreOffice uma vez:

```bash
pandoc -o modelo.docx --print-default-data-file reference.docx
```

O modelo é da organização — guarde em `org/workflows/<workflow>/assets/` e aponte o
caminho ali. O pack não ships modelo: sem `--reference-doc`, sai o estilo default do
pandoc, legível e neutro.

### Frontmatter

O bloco YAML do `.md` vira metadado do documento: `title`, `author`, `date`, `lang`.
Chave que o pandoc não conhece é ignorada sem erro — frontmatter próprio da organização
(`tipo:`, etc.) não quebra a conversão.

## Validar

```bash
ls -lh "<arquivo gerado>"
python3 -c "from docx import Document; Document('<arquivo>.docx')"   # se python-docx existir
```

## Limites conhecidos

| Sintoma | Causa | Ação |
|---|---|---|
| Imagem não aparece | caminho relativo resolvido a partir do CWD | rode o `pandoc` a partir da pasta do `.md`, ou use `--resource-path` |
| Tabela larga estourando a página | tabela em Markdown não tem largura | reduza colunas no `.md`, ou use `--reference-doc` com página paisagem |
| Sumário vazio | faltou `--toc`, ou o `.md` não tem headings | confira os `##` do consolidado |
| `pdf-engine not found` | saída `.pdf` sem engine instalado | instale `weasyprint`/`xelatex`, ou gere `.docx` |
