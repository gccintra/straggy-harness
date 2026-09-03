# Discovery de produto como capacidade do harness

Registro do processo que produziu [`discovery/`](discovery/00-INDEX.md), [`PRD.md`](PRD.md) e
a cadeia do MVP — e a proposta de trazê-lo para dentro da ferramenta como trabalho nomeado.

> **Estado.** Proposta, **fora do MVP** (Parte 6). Escrito agora porque o processo acabou de
> ser executado inteiro e está documentado; esperar significa reconstruí-lo de memória, que é
> como um método vira folclore. Nada aqui altera `ARCHITECTURE.md` ou `MODOS.md` — a proposta
> cabe nos mecanismos que eles já definem.

---

## Parte 1 — O que aconteceu, e por que é reaproveitável

Entre 2026-08-18 e 2026-08-29 foi conduzido um discovery de produto completo: **20
documentos numerados**, seis revisões declaradas (v2 a v6), e quatro documentos de recorte
derivados dele — [`MVP.md`](MVP.md), [`MVP-BACKLOG.md`](MVP-BACKLOG.md),
[`MVP-TECNICO.md`](MVP-TECNICO.md) e [`MVP-RELEASES.md`](MVP-RELEASES.md).

**Ele foi conduzido com o repertório que o harness já tem** `[F]`. Cada documento declara no
cabeçalho o método L1 que o produziu, e **os 21 estão em
`system/professions/product-specialist/methods/`**:

| Documento | Método L1 |
|---|---|
| 01 Visão do produto | `product-vision` |
| 02 Árvore de problemas | `problem-framing` |
| 03 Lean Canvas | `lean-canvas` |
| 04 ICP + proto-personas | `segmentation` |
| 05 JTBD + switch interviews | `jtbd` |
| 06 Value Proposition Canvas | `positioning` · `jtbd` |
| 07 Entrevistas Mom Test | `continuous-interview` |
| 08 Matriz CSD | `csd-matrix` |
| 09 Assumption mapping | `assumption-mapping` |
| 10 Árvore de oportunidades | `opportunity-solution-tree` |
| 11 Quatro riscos de Cagan | `opportunity-assessment` |
| 12 Impact mapping | `impact-mapping` |
| 13 Brainstorm de funcionalidades | `opportunity-solution-tree` |
| 14 RICE / ICE | `ice` · `prioritization-selection` |
| 15 Kano | `kano` |
| 16 Pré-mortem | `experiment-design` · `decision-record` |
| 17 User Story Mapping | `story-mapping` |
| 18 MoSCoW | `moscow` |
| 19 Pronto para alpha | `definition-of-ready-done` · `launch-tiers` |

**O achado, em uma frase:** o motor sabia fazer cada peça, e ninguém podia **pedir a
cadeia**. É exatamente o F32 do discovery — *"86 estruturas existem como método com contrato
de saída declarado; nenhuma tem ação no catálogo nem vira artefato do espaço"* — só que
recortado numa sequência específica e já executada de ponta a ponta.

---

## Parte 2 — Isto não é o `discovery` que já existe

O pack tem um workflow chamado `discovery`, e a colisão de nome é armadilha:

| | `discovery` do pack | O que este documento propõe |
|---|---|---|
| **Ação** | `explorar-solucao` | não existe |
| **Objeto** | uma **demanda** | um **produto** |
| **Método** | `double-diamond` (D1→D2) | 21 métodos encadeados |
| **Produz** | `solucao-definida` | uma cadeia de artefatos |
| **Duração** | uma sessão | semanas |
| **O que decide** | como resolver o que já foi decidido fazer | **se o produto deve existir**, para quem, e o que fica de fora |

São escalas diferentes com a mesma palavra. Declarar a ação nova com nome parecido faz os
dois gatilhos competirem no roteamento — e roteamento ambíguo é o modo de falha mais caro do
harness, porque falha em silêncio e entrega o trabalho errado com cara de certo.

---

## Parte 3 — O que este processo inventou, e que não estava em método nenhum

Esta é a parte com valor real. Os métodos são conhecidos e públicos; **os mecanismos abaixo
nasceram da execução** e são o que separou este discovery de uma pilha de canvases
preenchidos. Nenhum deles é específico de produto — todos servem a qualquer artefato de
decisão.

### 1. Grau de evidência por bloco, não por documento
Toda afirmação carrega `[F]` fato com fonte citada · `[I]` indício · `[S]` suposição. O efeito
não é decorativo: torna **impossível** escrever um documento que pareça mais certo do que é.
Metade do trabalho de revisão do discovery foi rebaixar `[F]` que era `[S]`.

### 2. Rebaixamento explícito, com o porquê
Uma seção que registra o que **deixou** de ser certeza e por quê. Em 08: *"empresas querem
configurar o próprio padrão — uma empresa fez isso, e é a de casa. Amostra 1, com viés total."*
Sem isso, certeza rebaixada some e ninguém percebe que a base mudou.

### 3. Nota de revisão versionada
Cada revisão (v2 a v6) declara **o que mudou, por que, e quais documentos foram atingidos**.
É o que permite ler a v6 sabendo o que a v1 dizia — e é o que impediu, seis vezes, que uma
mudança de tese ficasse aplicada em três documentos e esquecida em dez.

### 4. Matriz de cobertura — trava de completude
Criada em 13 depois que um ramo inteiro (protótipo/design) foi **omitido em silêncio**: os
documentos registravam só o que tinha oportunidade evidenciada e descartavam o resto sem
dizer. A trava: **todo item da lista original aparece com veredito, inclusive o que fica de
fora.** Item sem lastro não some — recebe "sem lastro" e a pergunta que lhe falta.

### 5. Sobreposição declarada, em vez de repontuação
Quando a decisão contrariou o score (o ramo O1 promovido contra a banda do ICE), o registro
foi **"a decisão sobrepôs o score"**, com a tabela do que ficou contrariado. Repontuar depois
de decidir é maquiar o método — e é o que quase todo time faz.

### 6. Condição de retorno em todo `WONT`
Nenhum "não" fica sem a frase que o reabre. É o que impede `WONT` de virar "nunca" por
inércia, e o que impede a mesma discussão de voltar toda semana.

### 7. Premissa aceita conscientemente, com dono e data
Premissa que não vai ser testada não some do radar: vira linha com quem aceitou, quando, e a
consequência aceita.

### 8. A seção "contra a minha tese", obrigatória
No formato de nota de entrevista: *"entrevista que não produziu nenhuma evidência contrária
provavelmente foi conduzida errado."*

**Onde estes oito pertencem, na arquitetura:** são **contrato de saída** e **barra de
qualidade** — L1 —, não procedimento. É a diferença entre "como conduzir um discovery" (que
varia por empresa e é encaixe) e "o que um artefato de decisão precisa conter para ser
aceitável" (que é do sistema e não se configura).

---

## Parte 4 — Como isso vira ação declarada

### A regra que decide o desenho: uma ação por decisão, não por documento

Dezenove documentos não viram dezenove ações. Viraria dezenove portões, e ninguém termina —
o portão vira clique, que é o cenário 2 do pré-mortem. **A unidade é o bloco que fecha uma
decisão.** Sete ações, sete artefatos, uma esteira:

| Ação | Cobre | Produz |
|---|---|---|
| `enquadrar-problema` | 01, 02 | `problema-enquadrado` |
| `definir-segmento-e-proposta` | 03, 04, 05, 06 | `segmento-definido` |
| `montar-fila-de-evidencia` | 07, 08, 09 | `fila-de-teste` |
| `explorar-oportunidades` | 10, 11, 12, 13 | `oportunidades-mapeadas` |
| `priorizar-escopo` | 14, 15, 16, 17, 18 | `escopo-priorizado` |
| `definir-corte-inicial` | 19 + o recorte do MVP | `corte-de-lancamento` |
| `derivar-backlog` | épicos e issues por release | `backlog-derivado` |

Declarado com os mecanismos que `ARCHITECTURE.md` §7 já define — nada de extensão nova:

```yaml
acao:
  id:        priorizar-escopo
  rotulo:    Priorizar escopo
  descricao: ordena o repertório de soluções e declara o que fica de fora, com condição de retorno
produz:
  id:     escopo-priorizado
  rotulo: Escopo priorizado
requer:
  - oportunidades-mapeadas
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo:  Como fazer
    ajuda:   Como sua empresa prioriza — quem pontua, com que modelo, e quem desempata.
    tipo:    texto-longo
  escala-evidencia:
    caminho: references/evidencia.yaml
    rotulo:  Escala de evidência
    ajuda:   Os graus que sua empresa usa para marcar cada afirmação, e o que cada um exige.
    tipo:    estrutura
    schema:  escala-evidencia
```

### Por que a escala de evidência é encaixe **estruturado**, e não texto

`ARCHITECTURE.md` §7 reserva `tipo: estrutura` para o conteúdo da organização que alimenta
**cálculo determinístico**, porque aí texto livre não é flexibilidade, é fragilidade.

A escala de evidência é exatamente isso: se `[F]` **exige fonte citada**, isso é verificável
— um documento com `[F]` sem fonte é reprovável por máquina, não por gosto do revisor. Texto
livre não valida, não pré-visualiza e não versiona. Estrutura valida.

### A matriz de cobertura vira eval, não prosa

O mecanismo 3.4 é uma trava de completude, e trava de completude é **contraprova
verificável**: dada a lista de itens declarada na entrada, todo item aparece na saída com
veredito. Isso pertence à camada de evals (`ARCHITECTURE.md` §9), não a um parágrafo pedindo
boa fé. É o tipo de coisa que o harness sabe checar e que humano esquece.

---

## Parte 5 — O que isso exige que ainda não existe

| O que | Custo |
|---|---|
| Sete ações novas no catálogo público | ação é contrato: nome errado hoje é migração amanhã (`ARCHITECTURE.md` §7) |
| Sete artefatos no vocabulário de `produz` | barato — o vocabulário é o conjunto dos `produz` declarados, e o build reprova nome órfão |
| Schema `escala-evidencia` em `system/schemas/` | pequeno, e é o primeiro schema que não é o funil |
| Os 21 métodos L1 | **zero** — já existem |
| Onde os artefatos moram | **depende do repositório de contexto** (M15–M18 do MVP). Sem ele, os documentos voltam a ser arquivos soltos e o discovery não é contexto de nada |
| Uma esteira de sete portões | é o desenho mais longo do harness. Precisa ser testado contra fadiga de portão antes de virar padrão |

---

## Parte 6 — Por que não entra no MVP, e o que o faria entrar

**A razão principal não é esforço — é que um caso não vira workflow.**

`ARCHITECTURE.md` §3 tem um teste para isso: conteúdo preso a uma instância não pertence ao
pack. Este discovery foi executado **uma vez**, para **um produto**, por **uma pessoa**.
Declarar sete ações a partir daí corre o risco preciso que o discovery deste produto já
cometeu e teve que corrigir em 04: *"esses sinais não descrevem um mercado — descrevem o
fluxo de trabalho da pessoa que construiu o harness. Amostra 1, com viés total de origem."*

Repetir o erro no próprio harness seria irônico e caro: procedimento vem de repetição, e
ainda não houve repetição.

As outras três razões, mais simples:

- **Ninguém vai rodar isto no MVP.** O discovery deste produto está feito; o usuário do MVP
  é quem o fez.
- **Depende do repositório de contexto**, que é a onda 1 do MVP e ainda não existe.
- **É a segunda onda de F32**, que o discovery já classificou assim por sequência.

### O que o faria entrar

| Gatilho | O que ele prova |
|---|---|
| **Um segundo discovery de produto acontecer** — outro produto, ou um cliente pedindo | que existe procedimento, e não uma instância. É o gatilho principal |
| Um cliente do beachhead pedir "conduza nosso discovery" | vira demanda paga, e aí a prioridade se decide sozinha |
| As estruturas de produto (M21) já estarem no ar | metade da mecânica — tipo com forma declarada e artefato no espaço — já existiria |

---

## Parte 7 — O que dá para colher agora, e é barato

Nada disto é a ação. É o que o processo produziu de aproveitável **antes** de haver
repetição, e o que se perde se ficar só neste documento:

1. **Os oito mecanismos da Parte 3 não são exclusivos de discovery de produto.** Grau de
   evidência, condição de retorno em toda recusa, sobreposição declarada e premissa com dono
   servem a qualquer artefato de decisão que o harness produza hoje — e são contrato de
   saída, que é camada L1 e não espera ação nenhuma.

2. **O schema `escala-evidencia` vale sozinho.** É pequeno, é verificável e resolve um
   problema que já existe: artefato de decisão que soa mais certo do que é.

3. **A trava de completude vale como eval hoje**, para qualquer workflow que receba uma lista
   e devolva um recorte — que é o caso de metade do pack.

4. **Este documento é o registro.** Quando o segundo caso aparecer, a diferença entre os dois
   é o que revela o que é procedimento e o que era instância. Sem o registro do primeiro, o
   segundo vira "vamos fazer do jeito que a gente lembra".
