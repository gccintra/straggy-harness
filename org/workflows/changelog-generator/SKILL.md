---
name: changelog-generator
description: >
  Gera ou atualiza o changelog do projeto (Histórico de Evolução; nome do projeto em
  project-config.yaml) a partir de HUs, ordens de serviço, descrições de funcionalidade ou
  qualquer documentação de requisito. Use sempre que o usuário mencionar "changelog",
  "histórico de evolução", "adicionar ao changelog", "registrar mudança", "atualizar o
  histórico" ou enviar um documento de HU/OS pedindo para registrá-lo. A saída é sempre
  uma tabela Markdown no padrão oficial do projeto.
---

# changelog-generator — workflow L2

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` |
| Formatos | `references/formato.md` — estrutura exata da tabela; **leia antes de gerar** |
| L3 | `identidade.projeto` em `project-config.yaml` (vazio → `[PROJETO]`) |

Publicação na wiki (quando pedida) → `wiki-publish` (append barato).

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

Sempre a tabela Markdown completa com cabeçalho. Múltiplos documentos → uma linha por
HU, mais recente primeiro. Changelog existente → destaque "Nova(s) entrada(s):" e depois
a tabela completa atualizada (novas no topo).
