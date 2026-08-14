# Convenções da Organização — L2 (transversal)

Semeado pelo `install.sh` a partir de `system/pack/org-scaffold/ORG.md`. Edite: é a camada
que a organização possui. Não altera `system/CONSTITUTION.md` (L0) nem as profissões (L1):
a organização escreve encaixes; workflow próprio só para ação nova; nunca
afrouxa portão (`docs/ARCHITECTURE.md` §3 e §7, catálogo em `system/ACOES.md`).

Campo `[definir]` não preenchido = o pack decide sozinho pelo default dele. Nada quebra;
só não há convenção da casa.

> **Esta camada não roda sozinha** — ela sobrescreve um harness. Como montar, o que pode e
> o que não pode morar aqui: [`README.md`](README.md).

**Revisado contra o release do harness:** `[definir]` — atualize ao revisar esta camada
depois de um `git pull` do harness. É o que denuncia overlay que ficou para trás.

## 1. Língua e escrita dos artefatos

- Idioma dos documentos, comentários e páginas publicadas: `[definir]`.
  Sem definição → o pack escreve em **PT-BR acentuado** (é a língua do pack).
- Regras de acentuação/ortografia obrigatórias: `[definir]`.
- Exceção: identificadores técnicos (código, chave de config, slug).

## 2. Nomenclatura e destinos de arquivo

| Artefato | Padrão de nome | Onde |
|---|---|---|
| Documento consolidado de demanda | `[definir]` (default do pack: `{ID}_{NomeCurto}.md`) | `{caminhos.pasta_por_demanda}` |
| Documento em formato final | mesmo nome, outra extensão | mesma pasta |
| Registro de discovery | `YYYY-MM-DD_discovery_<ref>.md` | `{caminhos.historico}discoveries/` |
| Análise/priorização | `YYYY-MM-DD_<tipo>_<escopo>.md` | `{caminhos.historico}analyses/` |
| Export de dados | `<tipo>_YYYY-MM-DD.csv` (nunca sobrescrever) | `{caminhos.dados}` |

Valores de identidade (cliente, sigla, logo) vêm de `project-config.yaml`; campo vazio lá →
placeholder no documento, a skill não inventa valor.

## 3. Versionamento

- O que entra no Git e o que é regenerável: `[definir]`.
- Commit é sempre manual, via `@committer`.

## 4. Papéis e fronteiras

- Profissões ativas e qual é a entrada padrão: `[definir]`
  (default do pack: `product-specialist` como entrada, mais `tech-lead` e
  `product-designer`).
- Uma profissão não aciona outra por baixo dos panos — responde e aponta.
- A esteira de documentação e seus portões humanos são **do sistema**, não desta camada:
  cada ação declara o artefato que produz e o que exige antes (`docs/ARCHITECTURE.md` §7).
  Demanda sem interface pula o protótipo — é a condição `demanda-tem-interface`, avaliada
  pela natureza da demanda, nunca por configuração.

## 5. Funil de priorização

O funil **não é declarado neste arquivo**: é o encaixe estruturado `funil` da ação
`priorizar-backlog` — escreva
`org/workflows/backlog-prioritization/references/funil.yaml` seguindo o schema
`system/schemas/funil-priorizacao.yaml`. Etapas, escalas e rubricas, fórmula do score,
cortes e ordenação saem de lá, e é de lá que todas as skills leem.

Sem esse arquivo vale o funil padrão do pack — nenhuma skill decora valor, e nenhuma para
por falta de configuração.

Existindo um documento humano do funil, aponte-o em `caminhos.documento_priorizacao`
(`project-config.yaml`) e declare-o em `fonte:` dentro do `funil.yaml`: o documento passa a
ser a autoridade, e o arquivo é a leitura de máquina dele.

O julgamento que o funil não calcula — bypass de emergência, itens incomparáveis, caixas de
capacidade — vai no encaixe `procedimento` do mesmo workflow.

## 6. Vocabulário próprio

Termos que só existem nesta organização (tipos de documento, catálogos, siglas) e o que
cada um significa. Skill do pack nunca assume vocabulário daqui — quem o usa é o overlay
em `org/workflows/`.
