# Procedimento desta organização — documentar requisito

Encaixe `procedimento` da ação `documentar-requisito`. Substitui o passo a passo padrão do
pack. A moldura do workflow — providers, métodos, portões humanos e contrato de saída —
continua sendo do sistema e vale aqui também.

Formatos: `references/formato-md.md` (estrutura do documento) e `references/regras.md`
(rigor de classificação CA/RN/MSG/GL). **Siga os dois à risca.**

## Fluxo

1. **Carregar o material**: issue + comentários de discovery (`[D1|D2]`) pelo provider —
   ou, no modo local, `{caminhos.historico}discoveries/*issue-NNN*` — + `{caminhos.pasta_por_demanda}{ID}_design.md`
   quando existir + Referências Globais e contexto do knowledge.
2. **HU ou HT**: persona de usuário final impactada → HU (9 seções); demanda técnica sem
   persona → HT (6 seções). Em dúvida → pergunte.
3. **Metadados** de `project-config.yaml` (`identidade.cliente`, `identidade.projeto`,
   `identidade.ordem_servico_padrao`, `identidade.responsavel_padrao`,
   `recursos.url_documento_regras_global` → seção 9), Épico e data.
4. **Ler o catálogo global UMA vez, só para REUSAR**: conceito da issue já é GL →
   referencie `[GL_0X]`. Catálogo ausente → tudo nasce local; **proibido** usar exemplo de
   `{caminhos.entregaveis}` como catálogo.
5. **Escrever CA/RN/MSG (seções 4/5/6), tudo LOCAL**: CA em Dado/Quando/Então coesos
   referenciando `[RN_0X]`/`[MSG_0X]`/`[GL_0X]` por código; RN em SBVR com numeração local
   (`RN_01…`, reinicia por issue); MSG com texto literal. Não existe RA nem "Descrição de
   Interface" — comportamento de tela é CA.
6. **Revisão de promoção a GL (depois do doc pronto)**: promove só com **prova** — 2+
   consumidores reais documentados ou natureza estrutural. 1º consumidor → fica local,
   marcado "candidato a GL". Promoveu → **não escreva no Drive**: referencie `[GL_0X]` e
   traga o conteúdo no apêndice "Novas Referências Globais — copiar para o Drive".
7. **Auto-checagem** (lista no `references/formato-md.md`) → salvar em
   `{caminhos.pasta_por_demanda}{HU|HT}{ID}_{TOKEN}_{NomeCurto}.md`.
8. **Resumo ao apresentar**: seções, nº de RN/MSG, GLs reusados/promovidos, caminho; GL novo
   → avisar do apêndice a colar no Drive.

## Regras desta organização

- Seção 8 (Protótipo) sai **`N/A`**; na seção 9 (Complemento), "Link do Protótipo" sai **`N/A`**
  — quem substitui por títulos/links é a `prototype-prints`.
- "Documento de Regras Global" (seção 9) sai com a URL literal de
  `recursos.url_documento_regras_global` do `project-config.yaml`; campo vazio → **`N/A`**.
  Nunca inventar nem buscar o link em outro lugar.
- Apêndice de trilha de discovery é obrigatório.
