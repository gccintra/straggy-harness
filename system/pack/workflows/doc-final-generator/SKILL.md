---
name: doc-final-generator
description: >
  Passo FINAL da documentação: transcreve um `.md` consolidado JÁ REVISADO (gerado pela
  skill doc-consolidator) para o formato final entregável — `.docx`, `.pdf` ou o que o
  projeto usar. Acione quando o usuário pedir EXPLICITAMENTE o documento formal: "gera o
  docx", "agora o documento final", "transforma o md em docx", "exporta o documento",
  "gera o PDF da demanda", "cria o documento formal". NÃO acione para pedido genérico
  ("documenta a #NNN") — isso gera o `.md` primeiro, via doc-consolidator, com parada para
  revisão humana. Só transcreve o `.md`; não relê discovery nem cria conteúdo. IMPORTANTE:
  leia .agents/system/providers/docs-output/INTERFACE.md antes de gerar.
acao:
  id: gerar-documento-final
  rotulo: Gerar documento final
  descricao: transcreve o documento revisado para o formato entregável
provider:
  dominio: docs-output
  selecao: DOCS_OUTPUT_PROVIDER
  capacidade: render
produz:
  id: documento-final
  rotulo: Documento final
requer:
  - documento-consolidado
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo: Como fazer
    ajuda: Como sua empresa transcreve o documento revisado para o formato entregável, e o que conferir antes de enviar.
    tipo: texto-longo
  estrutura-final:
    caminho: references/template.md
    rotulo: Modelo do entregável
    ajuda: O leiaute do documento que sua empresa entrega ao cliente — capa, cabeçalho, ordem das seções.
    tipo: texto-longo
  exemplos:
    caminho: references/exemplos.md
    rotulo: Exemplos de referência
    ajuda: Trechos de documentos já entregues que servem de referência de tom e detalhe.
    tipo: texto-longo
  gerador:
    caminho: generate_doc.py
    rotulo: Gerador do entregável
    ajuda: O script que monta o arquivo final no leiaute da sua empresa. Sem ele não há como produzir o entregável.
    tipo: script
    capacidade: layout-custom
    essencial: true
  marca:
    caminho: assets/header_logo.png
    rotulo: Marca no cabeçalho
    ajuda: A imagem que vai no cabeçalho do documento entregue.
    tipo: imagem
    capacidade: layout-custom
    essencial: true
---

# doc-final-generator — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` (arquivo entregável = escrita → write-gate; **um pedido = um passo**: nunca gerar junto com o `.md`) |
| Provider | `docs-output/` — **sem fallback local**. Capacidade exigida: `render` |
| Formatos | nome e destino do arquivo: `org/ORG.md` §2 · identidade: `project-config.yaml`, bloco `documentacao` |

Último passo do pipeline. O `.md` consolidado é a **fonte de verdade**; este workflow só o
transcreve.


**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.

## Bindings padrão

- **Pré-requisito absoluto**: o `.md` existe e foi revisado por humano. Não existe → aponte
  o `doc-consolidator` e **pare**. Existe mas não foi revisado → confirme antes de gerar.
- **Transcrição mecânica**: nada é reinterpretado, resumido, reordenado ou completado. Falta
  conteúdo → é pendência do `.md`, não do gerador.
- **Saída** na mesma pasta do `.md` (`caminhos.pasta_por_demanda`), mesmo nome, extensão do
  formato final.
- **Correção nunca é feita no arquivo final.** Documento errado → conserta-se o `.md` e
  regera. Editar o final à mão quebra a fonte única e a próxima geração desfaz.
- **Capacidade ausente** (identidade visual, inserção de prints) → informe o que a
  implementação ativa não faz, e o que fica manual. Nunca contorne em silêncio.
- **Validação antes de entregar**: o arquivo abre, e as seções do `.md` estão todas lá.
  Reporte o caminho e o que ficou fora.

## Portão

Gerar é escrita: mostre o arquivo de origem, o de destino e a implementação ativa →
aprovação → gere. Regeração após correção do `.md` é um novo portão.
