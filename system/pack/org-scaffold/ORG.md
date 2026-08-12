# Convenções da Organização — L2 (transversal)

Semeado pelo `install.sh` a partir de `system/pack/org-scaffold/ORG.md`. Edite: é a camada
que a organização possui. Não altera `system/CONSTITUTION.md` (L0) nem as profissões (L1):
overlay adiciona e substitui procedimento, nunca afrouxa portão (`docs/ARCHITECTURE.md` §3).

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
| Documento consolidado de demanda | `[definir]` (default do pack: `{ID}_{NomeCurto}.md`) | `outputs/{ID}_{NomeCurto}/` |
| Documento em formato final | mesmo nome, outra extensão | mesma pasta |
| Registro de discovery | `YYYY-MM-DD_discovery_<ref>.md` | `history/discoveries/` |
| Análise/priorização | `YYYY-MM-DD_<tipo>_<escopo>.md` | `history/analyses/` |
| Export de dados | `<tipo>_YYYY-MM-DD.csv` (nunca sobrescrever) | `data/` |

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
- Pipeline de documentação com portão humano: discovery → consolidado `.md` (**para para
  revisão**) → formato final só sob pedido explícito.

## 5. Funil de priorização

`caminhos.documento_priorizacao` (`project-config.yaml`) preenchido → o funil sai de lá e
esta seção não é lida. Vazio → **declare o funil aqui**; as skills de priorização leem
deste arquivo e nunca decoram valores.

- Criticidade (MoSCoW) na entrada da demanda: `[definir hierarquia e labels]`.
- Score pós-solução (ICE ou equivalente): `[definir fórmula e escalas]`.
- Quadrantes e thresholds: `[definir]`.
- Ordenação final: `[definir]`.

Nada declarado aqui nem no documento do projeto → as skills **param e perguntam**.

## 6. Vocabulário próprio

Termos que só existem nesta organização (tipos de documento, catálogos, siglas) e o que
cada um significa. Skill do pack nunca assume vocabulário daqui — quem o usa é o overlay
em `org/workflows/`.
