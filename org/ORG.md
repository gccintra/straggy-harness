# Convenções da Organização — L2 (transversal)

Convenções que valem para **todos os workflows desta organização**, independente de skill.
Camada editável: outra empresa troca este arquivo (template em
`system/pack/ORG.template.md`), não a constituição (`system/CONSTITUTION.md`) nem as
profissões (`system/professions/`).

Outros pontos de extensão da organização: `org/workflows/` (registro num encaixe, ou
workflow próprio vinculado a uma ação — `system/ACOES.md`), `org/professions/`,
`org/providers/` — ver `docs/ARCHITECTURE.md` §3 e §7.

> §1 e §4 são identidade da organização (valem em qualquer runtime, inclusive no Hub).
> §2 e §3 são convenções do **repositório** — pasta e Git só existem no uso via CLI.

## 1. Língua dos artefatos — PT-BR correto e acentuado

Todo texto gerado — documento (`.md`/`.docx`), comentário de issue, changelog, página de
wiki, título de seção, nome de arquivo de conteúdo:

- **Acentos e til obrigatórios**: á é í ó ú, â ê ô, ã õ, à. **Cedilha obrigatória**: ç.
- **Proibido ASCII "chapado"**: "Medicao" → **Medição**; "Criterios de Aceitacao" →
  **Critérios de Aceitação**; "e necessario" → **é necessário**.
- Vale para o arquivo salvo (UTF-8) e para o texto na tela.
- Exceção única: identificadores técnicos literalmente sem acento (código, chave de
  config, slug de arquivo).

## 2. Nomenclatura e destinos de arquivo

| Artefato | Padrão | Onde |
|---|---|---|
| Doc consolidado de issue | `{HU\|HT}{ID}_{TOKEN}_{NomeCurto}.md` | `{caminhos.pasta_por_demanda}` |
| Doc de design da issue | `{ID}_design.md` | `{caminhos.pasta_por_demanda}` |
| `.docx` gerado | mesmo nome, `.docx` | mesma pasta (fora do Git) |
| Discovery | `YYYY-MM-DD_discovery_issue-NNN.md` (ou `_{slug}`) | `{caminhos.historico}discoveries/` |
| Análise/priorização | `YYYY-MM-DD_<tipo>_<escopo>.md` | `{caminhos.historico}analyses/` |
| Registro de operação (wiki, sprint doc, design) | `YYYY-MM-DD_<tipo>_<slug>.md` | `{caminhos.historico}` |
| Export de dados | `<tipo>_YYYY-MM-DD.csv` (nunca sobrescrever dia anterior) | `{caminhos.dados}` |

`TOKEN` e demais valores de identidade vêm do bloco `identidade` de `project-config.yaml`;
campo vazio lá →
placeholder `[ASSIM]` no documento (a skill não inventa valor).

## 3. Versionamento

- `{caminhos.entregaveis}`: só `.md` entra no Git; `.docx` e prints são regeneráveis, ficam fora.
- `{caminhos.historico}` e `{caminhos.dados}`: entram no Git (memória do projeto).
- `docs/context_docs/`: cache derivado do Drive — fora do Git, o Drive é a fonte.
- Commit é sempre manual, via `@committer`.

## 4. Papéis e fronteiras

- Três profissões ativas: `product-specialist` (entrada padrão), `tech-lead`,
  `product-designer`. Uma profissão não aciona outra por baixo dos panos — responde e
  aponta ("isso é com o @tech-lead").
- A esteira de documentação e seus portões humanos são **do sistema**, não desta camada:
  cada ação declara o artefato que produz e o que exige antes (`docs/ARCHITECTURE.md` §7).
  Demanda sem interface (HT, dado, backend) pula o protótipo — é a condição
  `demanda-tem-interface`, avaliada pela natureza da demanda, nunca por configuração.

## 5. Funil de priorização

O funil **não mora neste arquivo**: é o encaixe estruturado `funil` da ação
`priorizar-backlog`, declarado em
`org/workflows/backlog-prioritization/references/funil.yaml` (schema
`system/schemas/funil-priorizacao.yaml`). De lá saem etapas, escalas, rubrica de cada faixa
de nota, fórmula do score, cortes das faixas, ordenação e o mapa de rótulos do backlog — e
é de lá que **todas** as skills leem.

Autoridade do conteúdo: `docs/context_docs/sistema_priorizacao_funcionamento.md`
(`caminhos.documento_priorizacao`). O `funil.yaml` é a projeção de máquina desse documento e
carimba a versão dele; mudou o documento, o `funil.yaml` é reescrito.

O julgamento que o funil não calcula — via expressa de bug crítico, caixas de capacidade,
itens incomparáveis — está no encaixe `procedimento` do mesmo workflow.

Vale em qualquer skill: **cada dimensão é negociada com o usuário, uma por vez, com
justificativa** — nunca em bloco.

## 6. Vocabulário próprio

- **Referências Globais (GL)**: comportamentos que valem para todo o produto, catalogados
  fora da HU e referenciados por ela (`[GL_0X]`). Conceito **desta organização** — o
  catálogo vive na base de conhecimento do projeto; GL novo sai como apêndice do documento
  para o usuário levar à fonte.

