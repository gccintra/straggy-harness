# Regras de contagem

Base: IFPUG CPM 4.3.1. Estimativa: NESMA (aceita pelo IFPUG e pelo Roteiro SISP). Deflatores:
Roteiro de Métricas SISP, conforme a aba `Deflatores` do template (fonte única — não copiar
valores para cá).

## Tipo de contagem (IFPUG)

| Situação | Tipo | Manutenção das funções |
|---|---|---|
| Aplicação que ainda não existe | Projeto de Desenvolvimento | todas `I` |
| Inclui, altera ou exclui funções de aplicação em produção | Projeto de Melhoria | `I`, `A*`, `E` por função |
| Medir o que a aplicação já tem (baseline) | Aplicação | todas `I` |

Módulo novo dentro de aplicação existente é **Melhoria**, não Desenvolvimento.

## Funções

- **Processo elementar:** menor unidade de atividade com sentido para o usuário, completa e
  que deixa o negócio consistente. Mesma lógica, mesmos dados e mesmos arquivos = uma função só.
- **EE:** intenção primária é manter ALI ou alterar comportamento do sistema.
- **SE:** intenção primária é apresentar dado **com** cálculo, dado derivado, totalizador,
  atualização de ALI ou mudança de comportamento.
- **CE:** só recupera e apresenta, sem nada do item acima.
- **ALI:** grupo lógico reconhecido pelo usuário, mantido dentro da fronteira. **AIE:**
  referenciado, mantido por outra aplicação.
- Em Melhoria, ALI só conta se o grupo lógico é novo ou teve DER/RLR incluído/alterado.
- Não conta: requisito não funcional, tela sem processo elementar próprio, filtro/ordenação
  da mesma consulta, navegação, validação dentro de uma EE, mensagem.
- Listagem e detalhe da mesma entidade contam separado quando o usuário os vê como
  consultas distintas (padrão do contador).
- Dados de código (tabelas de domínio) → `DC`, contribuição 0.

## Complexidade

- **Estimativa (NESMA):** TD e AR/TR em branco. Transação = Média, dado = Baixa. É regra do
  método; a planilha aplica sozinha.
- **Detalhada:** informar TD e AR/TR por função; a planilha aplica a matriz IFPUG.

## Deflator (coluna Manutenção)

| Sigla | Quando |
|---|---|
| `I` | função não existe hoje |
| `A50` | altera função desenvolvida ou já alterada pela Websis — padrão no Obrasim |
| `A75` | altera função não desenvolvida nem alterada pela Websis |
| `A90` | `A75` + redocumentar a função |
| `A` | altera sem saber quem desenvolveu (evitar; perguntar antes) |
| `E` | exclusão da função |
| `COR*`, `GAR` | manutenção corretiva (defeito), por garantia e autoria |
| `COS` / `COSNF` | só cosmético (texto, layout) sem mudar lógica — contribuição fixa |
| demais | ver aba `Deflatores` |

Função nova × existente se decide olhando o sistema (código-fonte, docs de contexto), não o
texto da HU. Não achou → pergunta.

## Nomes

Verbo no infinitivo + objeto, como o usuário diz: "Listar contratos", "Cadastrar/Editar
Medição", "Excluir Medição". Cadastrar e editar podem ser uma linha só quando o contador
as trata como a mesma EE (mesma lógica e mesmos dados).
