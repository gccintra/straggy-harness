# Procedimento desta organização — manter changelog

Encaixe `procedimento` da ação `manter-changelog`. Substitui o passo a passo padrão do pack.
A moldura — write-gate antes de gravar, publicação via `wiki-publish` em append — continua
sendo do sistema.

Estrutura exata da tabela: `references/formato.md`. **Leia antes de gerar.**

## Extração (pergunte só o que não conseguir extrair, tudo numa mensagem)

| Coluna | Fonte no documento |
|---|---|
| Data Criação | "Data de Emissão" da HU / data do documento |
| OS Contratual | campo "Ordem de Serviço" |
| Épico / HU | nº da HU (`XXX.YY`) da "Identificação da HU" |
| Descrição da Mudança (Delta) | sintetizar de Escopo + História + CAs |
| Telas Impactadas | seção Protótipo / CAs / Escopo — inferir; impossível → `[a preencher]` |

## Contrato do Delta (a coluna que importa)

`**[TIPO] Título curto:** descrição em prosa, 1-2 frases, no passado, foco no impacto.`

- TIPO ∈ `[NOVO]` (não existia) · `[ALTERADO]` (comportamento/regra existente) ·
  `[CORRIGIDO]` (bug) · `[REMOVIDO]`.
- Linguagem de produto, não de implementação ("menu de atalho no cabeçalho", não
  "dropdown no header component"). Pontos múltiplos separados por vírgula. Sem bullets;
  não repetir o título na descrição.
- Telas Impactadas: nomes exatos da documentação, separados por vírgula.

## Saída

Sempre a tabela Markdown completa com cabeçalho. Múltiplos documentos → uma linha por HU,
mais recente primeiro. Changelog existente → destaque "Nova(s) entrada(s):" e depois a
tabela completa atualizada (novas no topo).
