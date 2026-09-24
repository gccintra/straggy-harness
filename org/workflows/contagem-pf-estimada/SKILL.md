---
name: contagem-pf-estimada
description: >
  Contagem de pontos de função (IFPUG; estimada NESMA ou detalhada) de uma demanda ou HU antes
  do desenvolvimento, na planilha padrão do contador. Use para "conta os pontos de função",
  "contagem estimada", "quantos PF dá a #NNN", "faz a APF da HU". Esforço × valor para
  ranquear o backlog é backlog-prioritization.
acao: estimar-pontos-de-funcao
objetivo: Dimensionar a demanda em pontos de função antes de codificar, para a empresa validar se tem caixa para ela.
entrega:
  - "`{caminhos.pasta_por_demanda}SENAT - {OS} - Estimada-HU{ID}.xlsx` no template do contador, com resumo (funções, PF IFPUG, PF Local da FS) na conversa"
portoes:
  - tipo de contagem, fronteira, função nova × existente ou deflator ambíguo depois de consultar as fontes → PARA e faz uma pergunta
  - mostra a tabela de funções e os totais antes de gerar a planilha; só gera com aprovação
---

# Contagem de pontos de função

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` — gerar o `.xlsx` é escrita → write-gate |
| Regras de contagem | `references/regras-contagem.md` (IFPUG, NESMA, deflatores SISP) — ler inteiro antes de contar |
| Calibração | `references/exemplos.md` — contagens reais do contador; granularidade e nomes de função |
| Formato | `assets/template-contagem-pf.xlsx` + `assets/preencher_planilha.py` |

## Contrato

- **Entrada:** demanda (issue, HU, documento consolidado ou texto do usuário). Número da OS,
  quando existir; ausente → `OS.{ANO}.XXX`, como o contador faz.
- **Fontes, nesta precedência:** documento consolidado da demanda → issue → contexto do produto
  (`{caminhos.contexto}`) → código-fonte (`codigo_fonte.caminho`) para saber se a função já existe.
- **Contagem segue o IFPUG.** Nada é fixo por demanda: tipo de contagem, fronteira, tipo de
  função, complexidade e deflator saem da regra aplicada ao caso, nunca do exemplo anterior.
- **Nível:** Estimativa (NESMA) por padrão. Detalhada só quando pedida e com TD/AR-TR
  identificáveis na fonte.
- **Responsável:** `Gustavo da Costa Cintra`.
- **Toda função leva justificativa** (intenção primária, por que nova/alterada) na tabela
  mostrada ao usuário e a HU de origem na coluna Observações.
- **Planilha:** gerada só pelo `preencher_planilha.py` sobre o template — nunca editar o
  template, nunca montar a planilha à mão. Erro do script → corrigir a entrada, não o template.

## Portões

1. Ambiguidade que muda o total e as fontes não resolvem → uma pergunta objetiva, antes de contar.
2. Mostrar, antes de gerar:
   - cabeçalho: aplicação, fronteira, tipo de contagem, nível;
   - tabela: função · tipo · manutenção · complexidade · PF · PF FS · justificativa · HU;
   - totais PF IFPUG e PF Local da FS;
   - o que ficou fora da contagem e por quê (requisito não funcional, função não alterada).
3. Aprovado → escrever o JSON no scratchpad, rodar
   `python3 assets/preencher_planilha.py <json> <saída>` e reportar o resumo que o script imprimiu.

Número que o script imprimir diferente do mostrado no portão 2 → não entregar; reconciliar e
mostrar de novo.
