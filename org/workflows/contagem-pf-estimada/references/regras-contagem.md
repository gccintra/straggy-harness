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

## Como olhar a demanda

A contagem mede o que o negócio passa a guardar e a fazer, não o que a tela mostra. Tela é
arranjo de apresentação: um painel reúne dados de vários grupos lógicos e dispara vários
processos, e uma coluna nova pode esconder um dado que vive por conta própria.

- **Dados primeiro.** Antes das transações, reconstrua o modelo lógico que o requisito
  implica: o que passa a ser guardado, com que identidade, quantas ocorrências por
  registro-pai, por quanto tempo, e quem cria, invalida ou remove. As transações se leem
  melhor depois disso.
- **Grupo novo × atributo novo.** O que tem identidade, ciclo de vida ou multiplicidade
  próprios é candidato a grupo lógico próprio. O que só qualifica um registro existente,
  com um valor por registro que muda junto com ele, é atributo. Decida pelo comportamento
  do dado descrito nas regras, não por onde ele aparece.
- **Uma função por intenção do usuário.** O efeito que uma transação produz como parte do
  próprio trabalho pertence a ela. Função separada é o que o usuário pede como capacidade
  distinta.
- **Conte como o contador que vai auditar.** Entre duas classificações defensáveis,
  escolha a que um contador independente defenderia pelo manual e registre a outra leitura
  na justificativa. Se a escolha muda o total, vale o portão de pergunta.

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
