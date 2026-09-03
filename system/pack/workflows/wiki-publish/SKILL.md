---
name: wiki-publish
description: >
  Publica e atualiza páginas na wiki do projeto (GitLab, documents do Linear, Jira ou o
  backlog configurado).
  Use sempre que precisar publicar, criar ou atualizar documentação de produto na wiki —
  fluxo novo, módulo documentado, decisão técnica, ou entrada de changelog. Gatilhos:
  "publica na wiki", "cria a página", "atualiza a wiki", "documenta o módulo na wiki".
  Verifica se a página já existe antes de criar, e oferece append ou replace quando existe
  conteúdo anterior. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de
  qualquer operação no backlog.
acao:
  id: publicar-na-wiki
  rotulo: Publicar na wiki
  descricao: publica e atualiza páginas na wiki do projeto
objetivo: Publicar e atualizar a documentação de produto na wiki sem sobrescrever em silêncio o que já estava lá.
entrega:
  - página criada, atualizada em replace ou acrescida em append, e a URL devolvida
  - registro em `{caminhos.historico}YYYY-MM-DD_wiki_<slug>.md`
portoes:
  - publicar e sobrescrever são escrita com preview e aprovação — a wiki normalmente não tem lixeira
  - em replace, mostra o conteúdo atual antes
  - em append, mostra só a entrada nova e nunca lê a página inteira
provider:
  dominio: backlog
  selecao: BACKLOG_PROVIDER
  capacidade: wiki
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo: Como fazer
    ajuda: O que sua empresa publica na wiki, quem aprova antes e como conteúdo antigo é tratado.
    tipo: texto-longo
  nomenclatura-pagina:
    caminho: references/nomenclatura.md
    rotulo: Nome e lugar da página
    ajuda: Como as páginas da wiki da sua empresa são nomeadas e organizadas em hierarquia.
    tipo: texto-longo
---

# wiki-publish — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` (publicar/sobrescrever = escrita → preview + aprovação; wiki normalmente não tem lixeira) |
| Provider | `system/providers/backlog/` — **sem fallback local**. Capacidade exigida: `wiki` |
| Formatos | `references/nomenclatura.md` — convenção de título das páginas (a organização sobrescreve) |


**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.

## Fluxo de decisão

```
conteúdo para publicar → listar páginas existentes (só títulos/slugs, barato)
  ├── página existe?
  │     ├── append (changelog/histórico) → use o append barato do provider: NUNCA leia a
  │     │     página inteira no contexto; escreva só a entrada nova.
  │     │     Write-gate: mostre ao usuário só a entrada nova.
  │     └── replace (atualização de módulo) → leia o conteúdo atual, confirme com o
  │           usuário, publique o conteúdo completo.
  └── não existe → criar (o slug é derivado do título pelo provider)
→ devolver a URL da página publicada
```

## Registro

`{caminhos.historico}YYYY-MM-DD_wiki_<slug>.md`: operação (criada / append / replace), URL, resumo do
publicado.
