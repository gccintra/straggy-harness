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
---

# doc-consolidator — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` (**portão humano**: entrega o `.md` e para; um artefato por turno) |
| Métodos | `system/professions/product-specialist/methods/user-story.md` (história e critérios verificáveis) · `sbvr-rules.md` (regra como invariante) |
| Provider | `backlog/` — **com fallback local** (modo local da INTERFACE) · `knowledge/` |
| Formatos | `references/formato-md.md` — estrutura do documento (a organização sobrescreve) |

## Bindings padrão

- **Entrada**: demanda do backlog (descrição + comentários de discovery) e/ou documentação
  de contexto. Sem backlog configurado → material local (`history/discoveries/`,
  `outputs/`) ou descrição do usuário.
- **Saída única**: um `.md` por demanda em `outputs/`, no nome e destino de `org/ORG.md`.
  Nada é publicado no backlog por esta skill.
- **Critérios de aceite verificáveis** e **regras de negócio como invariante** — o que não
  foi confirmado entra como pendência explícita, nunca como fato (`CONSTITUTION.md` §4).
- **Rastreabilidade**: cada regra/critério mantém a origem que veio do discovery.
- **PARA no fim**: apresente o `.md` e aguarde revisão humana. Formato final é passo
  separado (`doc-final-generator`), só sob pedido explícito, e sempre regerado a partir do
  `.md` corrigido — nunca editado à mão no formato final.
