---
name: changelog-generator
description: >
  Gera ou atualiza o changelog do projeto (histórico de evolução) a partir de documentação
  de requisito, demandas entregues ou descrição de funcionalidade. Use sempre que o usuário
  mencionar "changelog", "histórico de evolução", "adiciona ao changelog", "registra a
  mudança", "atualiza o histórico" ou enviar documentação pedindo para registrá-la. A saída
  é uma tabela Markdown no formato definido pela organização.
acao:
  id: manter-changelog
  rotulo: Manter changelog
  descricao: gera e atualiza o histórico de evolução do produto
objetivo: Manter o histórico de evolução do produto na linguagem de quem usa, não na de quem commitou.
entrega:
  - entrada nova no changelog do projeto, no formato do encaixe `formato-changelog`, mais recente no topo
portoes:
  - mostra a entrada antes de gravar
  - publicar na wiki é ação separada (`publicar-na-wiki`), com portão próprio
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo: Como fazer
    ajuda: Quando sua empresa registra uma mudança no changelog e de onde tira o texto de cada entrada.
    tipo: texto-longo
  formato-changelog:
    caminho: references/formato.md
    rotulo: Formato do changelog
    ajuda: Como o histórico de evolução da sua empresa é escrito — colunas, ordem e nível de detalhe de cada entrada.
    tipo: texto-longo
---

# changelog-generator — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` (write-gate: mostra a entrada antes de gravar/publicar) |
| Provider | `backlog/` só quando publicar na wiki (via `wiki-publish`); geração é local |
| Formatos | encaixe `formato-changelog` — colunas e regras da tabela |
| L3 | nome do projeto em `project-config.yaml` (`identidade.projeto`; vazio → `[PROJETO]`) |


**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.

## Bindings padrão

- **Entrada**: documentação da demanda (`.md` consolidado, requisito, descrição). Faltou o dado
  de uma coluna → deixe o marcador de campo vazio; não invente valor.
- **Saída**: entrada nova no changelog do projeto, mais recente no topo.
- **Delta, não catálogo**: descreve o que mudou para o usuário, não a lista de arquivos ou
  tarefas técnicas.
- **Publicação** na wiki (quando pedida) → `wiki-publish`, em modo append.
