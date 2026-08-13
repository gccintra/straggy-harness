# Catálogo de ações — a superfície pública do harness

Contrato entre o sistema e a organização. **Ação** é um trabalho nomeado que o harness sabe
fazer; **encaixe** é um pedaço de conteúdo que a ação consome e que a organização pode
escrever. Modelo, níveis e área fechada: `docs/ARCHITECTURE.md` §7.

Esta é a lista que a organização enxerga — no repositório, ao declarar `acao:` no
frontmatter; no aplicativo, como o seletor da interface. **Nada além desta tabela é
público**: nome de workflow, divisão interna, procedimento e método são do sistema.

Regra de manutenção: ação é contrato. Renomear ou aposentar uma ação quebra as
organizações que a reivindicaram — trate como mudança de API, não como refatoração.

---

## Ações e seus encaixes

**Toda ação abaixo aceita o encaixe `procedimento`** — o passo a passo com que aquele
trabalho é feito nesta empresa. A coluna lista os encaixes **além** dele. Personas não têm
encaixe: são identidade, não procedimento.

A tabela é **derivada do frontmatter das skills** — `runtime/build.sh` reprova quando ela
diverge, e `--fix` a regenera. Editar à mão aqui não muda comportamento nenhum: o lugar de
mudar é a declaração `acao:` do workflow.

<!-- gerado: catálogo — regenerado por runtime/build.sh --fix -->

| Ação | O que faz | Outros encaixes |
|---|---|---|
| `analisar-backlog` | métricas, distribuição e status do backlog | — |
| `analisar-demanda-de-tela` | analisa o que a demanda vira na interface, antes do código | — |
| `auditar-backlog` | saúde do backlog — inconsistências, duplicatas, zumbis | — |
| `capturar-prints` | captura as prints do protótipo para a documentação | `secao-prototipo` |
| `configurar-design-system` | extrai tokens e faz o scaffold do protótipo | `stack-prototipo` |
| `construir-tela` | cria e ajusta telas no app de protótipo | — |
| `consultar-backlog` | consulta e operação pontual numa demanda | — |
| `consultar-dados` | consulta o banco de homologação do projeto | — |
| `definir-meta-de-sprint` | escreve a meta da sprint orientada a resultado | — |
| `documentar-requisito` | gera o documento consolidado da demanda (fonte de verdade) | `estrutura-documento` · `regras-classificacao` |
| `explorar-solucao` | conduz o discovery de uma demanda até a solução definida | `formato-fase` |
| `gerar-documento-final` | transcreve o documento revisado para o formato entregável | `estrutura-final` · `exemplos` · `gerador` · `marca` |
| `gerenciar-sprint` | cria, fecha, move e documenta sprints | `template-sprint` |
| `manter-changelog` | gera e atualiza o histórico de evolução do produto | `formato-changelog` |
| `persona-design` | a persona de design do projeto | — |
| `persona-produto` | a persona de produto (PM/PO) do projeto | — |
| `persona-tecnica` | a persona técnica (tech lead) do projeto | — |
| `priorizar-backlog` | ranqueia o backlog pelo funil de priorização | — |
| `publicar-na-wiki` | publica e atualiza páginas na wiki do projeto | `nomenclatura-pagina` |
| `publicar-prototipo` | publica o protótipo num servidor, com HTTPS e autenticação | `receita-servidor` |
| `registrar-demanda` | registra e refina uma demanda no backlog | `template-demanda` |
| `versionar-mudancas` | commits, push e abertura de PR | — |

| Artefato da esteira | Produzido por |
|---|---|
| `demanda-registrada` | `registrar-demanda` |
| `documento-consolidado` | `documentar-requisito` |
| `documento-final` | `gerar-documento-final` |
| `prints-capturadas` | `capturar-prints` |
| `prototipo-validado` | `construir-tela` |
| `solucao-definida` | `explorar-solucao` |

<!-- /gerado -->

Ação sem encaixe extra hoje pode ganhar um depois — encaixe novo é aditivo e não quebra
ninguém.

**Ação criada pela organização não entra aqui.** Este catálogo é do sistema; a ação própria
é declarada no `SKILL.md` do workflow dela e vive na camada da organização.

---

## Como a organização usa

**Customizar uma ação existente = escrever encaixes.** Só isso. O workflow resolvido é a
moldura do sistema mais o conteúdo dela nos encaixes declarados. Ação, métodos, portões
humanos e contrato de saída continuam sendo do sistema — ela não os alcança, então não
consegue degradá-los. Quando o *procedimento* precisa ser outro, o caminho é o encaixe
`procedimento`, dentro da mesma moldura. **Não existe substituir um workflow do pack.**

No repositório, o encaixe é um caminho: o arquivo declarado em `encaixes:` pelo workflow do
pack, escrito em `org/workflows/<nome>/<caminho>`. No aplicativo, o encaixe é uma escolha na
interface e o caminho é gerado — a organização nunca digita nome de arquivo nem de workflow.

Encaixe vazio → o padrão do pack vale. Arquivo fora de encaixe declarado → o build avisa.

**Criar ação nova é a única exceção.** Quando a organização quer algo que o harness não
faz, ela escreve o workflow inteiro e declara uma ação que não existe neste catálogo. É
livre: não há padrão para degradar, ela está somando.

**Área fechada.** L0, portões, contrato de saída, métodos e `INTERFACE.md` de provider não
são encaixe e não são alcançáveis (`docs/ARCHITECTURE.md` §7).
