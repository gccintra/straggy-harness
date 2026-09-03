# 19 — Definição de "pronto para alpha"

> **Métodos:** `definition-of-ready-done` + `launch-tiers` (L1). **Contrato:** critérios de
> entrada · critérios de saída · nível de lançamento com justificativa · critério para
> avançar **e para recuar** · quem participa · data de revisão.
> **Estado:** proposta. Curto o bastante para ser lembrado sem consultar — lista longa vira
> burocracia e é contornada.

---

## Nível escolhido: alpha fechado, operado com acompanhamento

| | |
|---|---|
| **Quem participa** | 3 times de S1 (04), **pagantes**, com ≤ 4 pessoas cada. **Ao menos um sem cliente externo** — é o que testa se o produto saiu do fluxo de origem |
| **Por que fechado** | a incerteza dominante é de valor, não de escala (11). Grupo pequeno com acompanhamento próximo aprende mais rápido e falha barato |
| **Por que pagante** | validar A1 (o problema vira orçamento) é o objetivo. Piloto grátis prova que a ferramenta é aceitável, nunca que é comprável |
| **Propósito de aprendizado declarado** | A2 (a empresa configura), A3 (artefato aceito sem reescrita), A4 (P2 adota), **A14 (operar o backlog do time por integração é bom o bastante)** |
| **Pré-requisito de amostra** | os 3 times precisam usar ferramenta de backlog **já implementada** — hoje GitHub ou GitLab (C10 em 08). Cliente em Jira ou Linear exige construir o provider antes, e isso é decisão de contrato (11) |
| **Data de revisão** | 6 semanas após o terceiro cliente ativo — decisão de avançar, recuar ou parar |

Beta eterno é entrega que ninguém assume: este alpha tem data de revisão marcada e critério
de saída escrito antes de começar.

## Critérios de ENTRADA — o que precisa ser verdade para começar

**Negócio** — o que 16 (cenário 1) existe para impedir:

1. **≥ 3 contratos assinados** com times de S1/S2 `[A1 testada]`.
2. **Padrão declarado de cada cliente** já preenchido nos dois encaixes, por nós, na
   implantação assistida.
3. **Decisão D2 tomada** (onde o trabalho roda) e comunicada por escrito ao cliente — é
   objeção jurídica em boa parte das empresas, não detalhe técnico.
4. **Escopo comunicado por escrito antes de assinar:** o produto **não** substitui a
   ferramenta de backlog do cliente e não terá quadro próprio (00, v4). Vendido como
   substituto de Jira, o alpha mede a coisa errada e a decepção aparece na renovação.
5. **Harness generalizado** — nenhum campo ou vocabulário do fluxo de origem exposto a quem
   não trabalha assim: `cliente` e `ordem de serviço` opcionais, tipos de artefato e
   convenção de nome declarados pela organização, destino da saída configurável (lista em
   04). Sem isto, um time de produto próprio esbarra em campo sem sentido, conclui que a
   ferramenta não é para ele, e o alpha mede a coisa errada.

**Produto** — a fatia MUST de 18, inteira. Fatia parcial não é alpha, é demonstração:

6. Espaço criado **e hospedado, com autenticação**, com a integração de backlog do cliente
   conectada, lendo e escrevendo.
6b. **Repositório de contexto do cliente populado antes da primeira demanda** — documentos em
    Markdown com frontmatter, arquivos enviados, e ao menos uma estrutura de produto
    (roadmap ou personas) vivendo lá. Repositório vazio mede o produto errado: a tese é que a
    saída melhora **com** contexto, e alpha sem contexto testa a versão sem a metade nova.
7. Ação `documentar-requisito` executando no procedimento declarado do cliente.
8. Ramo de design disponível para demanda com interface: brief da tela e construção do
   protótipo navegável, com o portão `prototipo-validado` antes da documentação.
9. Conversa como interface, reconhecendo a ação sem o usuário escolher nada.
10. Portão como estado: o entregável **não existe** enquanto o documento não é aprovado.
11. Preview antes de toda escrita externa, sem exceção.
12. Saída aterrissando no destino que aquele time usa — backlog, wiki ou documento formal.
13. **Criar e atualizar a demanda na ferramenta do time**, com os campos que aquele time
    exige de fato — mapeados na implantação assistida, não presumidos (F34 em 13).

**Instrumentação** — sem isto o alpha não ensina nada:

14. **Baseline de ciclo medido antes de ligar o produto** — sem ele não há como afirmar
    ganho nenhum. E, por demanda: tempo total · aceito sem reescrita · reescrita de
    **formato** · reescrita de **conteúdo**.
15. Contrapeso ativo: tempo entre "artefato pronto" e "aprovado", por pessoa (16, cenário 2).
16. Uso por papel, nunca agregado (16, cenário 6).
17. **Retorno à ferramenta de backlog na mão**, por demanda: contar quando a pessoa abre o
    Jira/GitLab depois da escrita para consertar algo — é a única medida direta de A14
    (09, 16 cenário 8).

**Operação:**

18. Canal direto com cada cliente e alguém responsável por responder no mesmo dia.
19. Plano de recuo escrito: como o cliente volta ao processo antigo sem perder trabalho.

## Critérios de SAÍDA — quando o alpha terminou bem

Avaliados na data de revisão, com 10 demandas reais por cliente no mínimo:

| # | Critério | Corte |
|---|---|---|
| S1 | **redução do tempo de ciclo** por demanda, medido contra o baseline do próprio time | **≥ 40%** |
| S1b | artefatos aceitos sem retrabalho (contrapeso — não pode cair) | **≥ 70%** e não abaixo do baseline |
| S2 | reescrita concentrada em formato, não em conteúdo | formato > conteúdo |
| S3 | clientes que renovariam (pergunta feita, resposta registrada) | **≥ 2 de 3** |
| S4 | P2 (executor) opera sem P1 no meio | **≥ 2 de 3 contas** |
| S5 | portões com leitura real (tempo de aprovação compatível com ler) | **≥ 80%** das aprovações |
| S6 | cliente preencheu ou editou **ao menos um encaixe sozinho** | **≥ 1 de 3** |
| S7 | nenhuma escrita indevida em ferramenta de cliente | **zero. Sem tolerância** |
| S8 | demandas **com interface** na amostra medida — sem elas o ciclo medido não representa o time | **≥ 40%** das demandas |
| S9 | demandas em que a pessoa **não** precisou abrir a ferramenta de backlog na mão para consertar o que a ação escreveu (teste de A14) | **≥ 70%** |
| S10 | demandas em que a ação montou o contexto **sozinha** pelo repositório, sem alguém apontar arquivo (teste de F36) | **≥ 70%** |
| S11 | documentos de produto do cliente que passaram a viver no espaço, e não fora dele (teste de A15, na parte que dá para medir) | **≥ 60%** aos 60 dias |

## Critério de RECUO — declarado antes, para não ser racionalizado depois

| Sinal | Ação |
|---|---|
| S1 < 15% nas primeiras 5 demandas de um cliente | o gargalo não é o que achamos: parar e medir onde o tempo está indo antes de continuar |
| Ciclo cai e **aceitação cai junto** | não houve velocidade, houve transferência de trabalho para a revisão — corrigir o procedimento declarado antes de seguir |
| Reescrita concentrada em **conteúdo** | a oportunidade não é O1 — voltar a 10 antes de construir mais |
| S7 violado uma vez | parar o alpha inteiro até a causa estar corrigida |
| Nenhum cliente toca em encaixe (S6 = 0) | A2 refutada: revisar 06 e 11 antes de vender mais |
| Repositório usado só como depósito — ninguém **consulta**, e a ação não acha contexto sozinha (S10 < 50%) | **A15 em risco.** O ramo O1 foi promovido contra o score (14) com base nela; sem sinal de uso, a sobreposição estava errada. Parar de expandir o repositório e voltar a 10 antes de construir mais |
| Uso concentrado em 1 pessoa por conta após 30 dias | A4 em risco: conversar com P2 separado, antes de renovar |
| S9 < 70%, ou a configuração de um cliente não couber nas operações do provider | **A14 em risco.** Parar de vender a operação de backlog como parte da promessa, medir onde a integração falha, e reabrir a decisão de escopo com dado (16, cenário 8). Construir kanban por reflexo, antes dessa medição, é o cenário 1 |

## O que **não** é critério

Registrado porque é o que costuma sequestrar a discussão perto do lançamento:

- número de features entregues;
- cobertura de ações além de `documentar-requisito`;
- desempenho/latência, salvo se travar o uso;
- polimento visual;
- disponibilidade de kanban ou quadro próprio — está **fora de escopo**, não pendente (18);
- disponibilidade de métricas, workshops ou voz — todos `WONT` (18);
- número de ferramentas de backlog suportadas: uma que funcione de verdade basta para o
  alpha; a lista vem do contrato, não da vontade (11).

## Exceções

Vão acontecer. Quando acontecerem: registradas com motivo e quem aceitou, no mesmo lugar,
nunca normalizadas em silêncio. Critério que se dobra sem registro deixa de ser critério na
terceira vez.
