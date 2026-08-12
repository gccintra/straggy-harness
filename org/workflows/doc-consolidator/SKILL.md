---
name: doc-consolidator
description: >
  Gera o documento .md consolidado de uma issue, fonte de verdade única que reúne a descrição
  da funcionalidade + Critérios de Aceitação coesos + Regras de Negócio (SBVR) + Mensagens +
  Referências Globais + trilha de discovery. Use para pedidos genéricos como "documenta a #NNN",
  "gera a documentação", "consolida", "gera o md", "monta o documento base", "cria as regras da
  #NNN" ou "centraliza discovery e regras". Escreve as regras direto no .md (não há arquivo de
  regras separado). Gera somente o `.md` em `outputs/{ID}_{NomeCurto}/` e PARA para revisão
  humana. Nunca segue para `.docx` — passo separado com hu-generator/ht-generator, só após
  revisão e pedido explícito.
---

# doc-consolidator — workflow L2

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` §5 (portões humanos: **gera o `.md` e PARA** — nunca o `.docx` daqui) |
| Métodos | `system/professions/product-specialist/methods/user-story.md` (CA coeso, problema vs solução) · `sbvr-rules.md` (forma e promoção de regra) |
| Providers | `backlog/` — **com fallback local** · `knowledge/` (Referências Globais, contexto) |
| Formatos | `references/formato-md.md` — contrato de formato por linha + estruturas HU (9 seções) e HT (6) + princípio editorial. `references/regras.md` — rigor de classificação CA/RN/MSG/GL. **Siga os dois à risca.** |
| L3 | metadados de `project-config.yaml` (campo vazio → placeholder `[ASSIM]`) |

Divisão de trabalho: **este workflow pensa o conteúdo** (modelo pesado); o
`hu-generator`/`ht-generator` só transcreve para `.docx` (mecânico). O `.md` é
autocontido — RN e MSG com texto completo aqui.

## Fluxo

1. **Carregar o material**: issue + comentários de discovery (`[D1|D2]`) pelo provider —
   ou, no modo local, `history/discoveries/*issue-NNN*` — + Referências Globais e contexto
   do knowledge. **Sem D2b em lugar nenhum → pare e pergunte** como prosseguir; não decida
   sozinho.
2. **HU ou HT**: persona de usuário final impactada → HU (9 seções); demanda técnica sem
   persona → HT (6 seções). Em dúvida → pergunte.
3. **Metadados** de `project-config.yaml` (`identidade.cliente`, `identidade.projeto`,
   `identidade.ordem_servico_padrao`, `identidade.responsavel_padrao`), Épico e data.
4. **Ler o catálogo global UMA vez, só para REUSAR**: conceito da issue já é GL →
   referencie `[GL_0X]`. Catálogo ausente → tudo nasce local; **proibido** usar exemplo de
   `outputs/` como catálogo.
5. **Escrever CA/RN/MSG (seções 4/5/6), tudo LOCAL**: CA em Dado/Quando/Então coesos
   referenciando `[RN_0X]`/`[MSG_0X]`/`[GL_0X]` por código; RN em SBVR com numeração local
   (`RN_01…`, reinicia por issue); MSG com texto literal. Não existe RA nem "Descrição de
   Interface" — comportamento de tela é CA.
6. **Revisão de promoção a GL (depois do doc pronto)**: promove só com **prova** — 2+
   consumidores reais documentados ou natureza estrutural. 1º consumidor → fica local,
   marcado "candidato a GL". Promoveu → **não escreva no Drive**: referencie `[GL_0X]` e
   traga o conteúdo no apêndice "Novas Referências Globais — copiar para o Drive".
7. **Auto-checagem** (lista no `references/formato-md.md`) → salvar em
   `outputs/{ID}_{NomeCurto}/{HU|HT}{ID}_{TOKEN}_{NomeCurto}.md`.
8. **Apresentar e PARAR**: resumo (seções, nº de RN/MSG, GLs reusados/promovidos,
   caminho; GL novo → avisar do apêndice a colar no Drive). O `.docx` é outro pedido,
   depois da revisão humana.

## Regras de ouro

- Seções 8 (Protótipo) e 9 (Complemento) ficam **vazias** com placeholders — quem
  preenche títulos/links é a `prototype-prints`; o doc de regras, o usuário.
- Apêndice de trilha de discovery é obrigatório.
- `.docx` saiu errado → o defeito está no `.md`: corrija o `.md` e regere.
