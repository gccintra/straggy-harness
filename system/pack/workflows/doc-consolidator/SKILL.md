---
name: doc-consolidator
description: >
  Gera o documento .md consolidado de uma demanda — fonte de verdade única que reúne a
  descrição da funcionalidade, os critérios de aceite, as regras de negócio, as mensagens
  ao usuário e a trilha do discovery. Use para pedidos genéricos como "documenta a #NNN",
  "gera a documentação", "consolida", "gera o md", "monta o documento base" ou "cria as
  regras da #NNN". Gera somente o `.md` e PARA para revisão humana — formato final
  (`.docx` ou outro) é passo separado, só após revisão e pedido explícito. IMPORTANTE: leia
  .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.
acao:
  id: documentar-requisito
  rotulo: Documentar requisito
  descricao: gera o documento consolidado da demanda (fonte de verdade)
produz:
  id: documento-consolidado
  rotulo: Documento consolidado
requer:
  - solucao-definida
requer_condicional:
  - artefato: prototipo-validado
    quando: demanda-tem-interface
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo: Como fazer
    ajuda: O passo a passo com que sua empresa monta o documento da demanda — de onde vem cada parte e o que checar antes de entregar.
    tipo: texto-longo
  estrutura-documento:
    caminho: references/formato-md.md
    rotulo: Estrutura do documento
    ajuda: As seções e a ordem em que sua empresa escreve o requisito.
    tipo: texto-longo
  regras-classificacao:
    caminho: references/regras.md
    rotulo: Regras de classificação
    ajuda: Como sua empresa nomeia e classifica regra de negócio, critério de aceite e mensagem ao usuário.
    tipo: texto-longo
---

# doc-consolidator — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` (**portão humano**: entrega o `.md` e para; um artefato por turno) |
| Métodos | `system/professions/product-specialist/methods/user-story.md` (história e critérios verificáveis) · `sbvr-rules.md` (regra como invariante) |
| Provider | `backlog/` — **com fallback local** (modo local da INTERFACE) · `knowledge/` |
| Formatos | encaixes `estrutura-documento` e `regras-classificacao` — quando a organização os preenche, valem à risca |
| L3 | metadados de `project-config.yaml` (campo vazio → placeholder `[ASSIM]`) |

Divisão de trabalho: **este workflow pensa o conteúdo** (modelo pesado); a ação
`gerar-documento-final` só transcreve (mecânico). O `.md` é autocontido — regra e mensagem
com texto completo aqui.

**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.

## Bindings padrão

- **Entrada**: demanda do backlog (descrição + comentários de discovery) e/ou documentação
  de contexto. Sem backlog configurado → material local (`{caminhos.historico}discoveries/`,
  `{caminhos.entregaveis}`) ou descrição do usuário.
- **Sem solução definida em lugar nenhum** (nem no backlog, nem no material local) → **pare
  e pergunte** como prosseguir; não decida sozinho e não invente o requisito.
- **Demanda com interface**: o protótipo validado e o registro de design da demanda entram
  como entrada — são a fonte de fluxo, estado, rótulo e mensagem. Demanda com tela sem
  protótipo validado → **pare e pergunte**; documentar antes gera retrabalho previsível.
  Conflito entre registro de design e discovery: o protótipo vence em comportamento de
  tela, o discovery vence em regra e escopo, e divergência que muda regra volta ao
  discovery — não se resolve aqui.
- **Saída única**: um `.md` por demanda em `{caminhos.entregaveis}`, no nome e destino de `org/ORG.md`.
  Nada é publicado no backlog por esta skill.
- **Critérios de aceite verificáveis** e **regras de negócio como invariante** — o que não
  foi confirmado entra como pendência explícita, nunca como fato (`CONSTITUTION.md` §4).
- **Rastreabilidade**: cada regra/critério mantém a origem que veio do discovery.
- **PARA no fim**: apresente o `.md` e aguarde revisão humana. Formato final é passo
  separado (`doc-final-generator`), só sob pedido explícito, e sempre regerado a partir do
  `.md` corrigido — nunca editado à mão no formato final.
