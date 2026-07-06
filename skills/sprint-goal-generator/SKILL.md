---
name: sprint-goal-generator
description: >
  Gera a Meta da Sprint (Sprint Goal) no padrao do Guia do Scrum 2020, com foco em OUTCOME
  (ganho de valor para o usuario/negocio) e nao em output (funcionalidades entregues). Use esta
  skill sempre que o usuario pedir para criar, escrever, montar ou sugerir uma Meta da Sprint,
  Sprint Goal, objetivo da sprint, meta do sprint, ou quando enviar HUs, backlog, documentos de
  requisito ou descricoes de funcionalidades pedindo para definir a meta. Tambem use quando o
  usuario perguntar qual seria a meta ou como escrever a meta mesmo sem usar o termo exato Sprint
  Goal. Trigger agressivo: qualquer combinacao de meta, sprint e um contexto de desenvolvimento
  de software deve acionar esta skill.
---

# Sprint Goal Generator

Skill para gerar Metas de Sprint (Sprint Goals) conforme o **Guia do Scrum 2020** e melhores práticas do mercado ágil.

**Antes de gerar — contexto:** use o conteúdo recebido (HUs/backlog). Se receber só o número/nome da sprint, **leia as issues da sprint no GitLab** (carregue `glab-backlog`: `glab issue list -R ${GITLAB_REPO} -m "<Sprint>" -A -P 100`) + docs relevantes do repo (`docs/context_docs/`) antes de propor a meta.

---

## O que é uma boa Meta da Sprint?

Segundo o Guia do Scrum 2020:
> *"A Meta da Sprint é o único objetivo da Sprint. Embora a Meta da Sprint seja um compromisso pelos Desenvolvedores, ela fornece flexibilidade em termos do trabalho exato necessário para atingi-la. A Meta da Sprint também cria coerência e foco, encorajando o Scrum Team a trabalhar junto em vez de em iniciativas separadas."*

### Princípio fundamental: OUTCOME, não OUTPUT

| ❌ Output (o que foi feito) | ✅ Outcome (ganho gerado) |
|---|---|
| "Implementar tela de login com OAuth" | "Usuários conseguem acessar o sistema de forma segura e sem fricção" |
| "Criar CRUD de cadastro de fornecedores" | "Gestores podem cadastrar e gerenciar fornecedores sem depender do TI" |
| "Desenvolver relatório de vendas" | "Líderes comerciais tomam decisões baseadas em dados atualizados" |
| "Corrigir bugs do módulo de pagamento" | "Clientes completam pagamentos sem erros, reduzindo abandono no checkout" |

**Output** = o que o time entrega (funcionalidade, código, tela).  
**Outcome** = a mudança de comportamento ou ganho de valor que o usuário/negócio experimenta.

---

## Características de uma boa Meta da Sprint

1. **Uma única frase** — sem "e", "ou", bullet points
2. **Orientada a outcome** — descreve o valor entregue, não a funcionalidade
3. **Mensurável ou verificável** — dá para saber se foi atingida
4. **Alinhada ao Product Goal** — é um passo em direção ao objetivo maior do produto
5. **Colaborativa** — criada pelo Scrum Team inteiro, não imposta de cima
6. **Realista para a Sprint** — alcançável no timebox

---

## Processo de geração

### Passo 1 — Entender o contexto

Antes de gerar a meta, extraia do input do usuário:

- **Quem** são os usuários/personas afetados?
- **Qual problema** estão enfrentando hoje?
- **Qual ganho** eles terão ao final da Sprint?
- **Qual é o Product Goal** ou objetivo maior do produto (se disponível)?
- **Quais HUs/PBIs** estão no backlog da sprint?

Se o input for vago demais (ex: só "metas para sprint de login"), pergunte UMA coisa antes de gerar:
> "Qual é o principal ganho que o usuário ou negócio terá ao final desta Sprint?"

Se o input for um documento (HU, backlog, descrição), extraia as informações diretamente dele.

### Passo 2 — Identificar o fio condutor

Analise os itens do backlog e encontre o **tema central de valor**:
- O que une as histórias? Qual problema em comum elas resolvem?
- Se não há fio condutor claro, escolha o item de maior impacto e construa a meta em torno dele
- Avise o usuário se os itens forem muito heterogêneos (anti-padrão: meta composta)

### Passo 3 — Gerar as opções de Meta

Gere **3 opções** de Meta da Sprint, variando o nível de ambição e perspectiva:

**Opção A — Perspectiva do Usuário Final**: foco na experiência/comportamento do usuário  
**Opção B — Perspectiva de Negócio**: foco no impacto para a empresa/métricas  
**Opção C — Perspectiva Técnica/Operacional**: para sprints com forte componente técnico (infra, performance, débito técnico)

Para cada opção, entregue:
- A meta em uma frase
- Uma explicação de por que ela é um outcome e não um output
- Um critério de verificação sugerido ("Como saberemos que atingimos?")

### Passo 4 — Recomendar a melhor opção

Indique qual das 3 opções melhor se alinha ao Guia do Scrum e ao contexto fornecido, e por quê.

---

## Anti-padrões a evitar (e alertar o usuário)

| Anti-padrão | Como identificar | O que fazer |
|---|---|---|
| **Meta = lista de tasks** | "Implementar X, Y e Z" | Reescrever focando no ganho unificador |
| **Meta composta** | Contém "e" / "ou" / bullet | Escolher o item de maior valor e focar nele |
| **Meta vaga demais** | "Melhorar o sistema" | Adicionar um verbo de ação + benefício concreto |
| **Meta de output** | Descreve entrega, não ganho | Perguntar "para que serve essa entrega?" e usar a resposta |
| **Meta imposta top-down** | PO definiu sem o time | Alertar que a meta deve ser co-criada no Sprint Planning |

---

## Template de estrutura (opcional, não obrigatório)

Para times que precisam de um ponto de partida estruturado:

```
[Verbo de ação] + [para quem] + [qual ganho/mudança]
para que [impacto no negócio/usuário]
```

Exemplos:
- "Permitir que compradores finalizem pedidos com Pix, reduzindo abandono de carrinho"
- "Capacitar gestores a aprovar férias de forma autônoma, sem depender do RH para cada solicitação"
- "Garantir que o sistema suporte 10x mais usuários simultâneos sem degradação de performance"

---

## Formato de saída esperado

Ao gerar a meta, sempre apresente neste formato:

---

### 🎯 Meta da Sprint — Opções Geradas

**Contexto identificado:** [resumo do que foi entendido do input]  
**Tema central de valor:** [o problema/ganho unificador das HUs]

---

**Opção A — [nome da perspectiva]**  
> "[Meta da Sprint aqui]"

- **Por que é outcome:** [explicação]
- **Como verificar:** [critério de aceite da meta]

---

**Opção B — [nome da perspectiva]**  
> "[Meta da Sprint aqui]"

- **Por que é outcome:** [explicação]
- **Como verificar:** [critério de aceite da meta]

---

**Opção C — [nome da perspectiva]** *(se aplicável)*  
> "[Meta da Sprint aqui]"

- **Por que é outcome:** [explicação]
- **Como verificar:** [critério de aceite da meta]

---

**✅ Recomendação:** Opção [X] — [motivo em 1-2 frases]

**⚠️ Alertas:** [se houver anti-padrões detectados no backlog, liste aqui]

---

## Referências

- [Scrum Guide 2020](https://scrumguides.org/scrum-guide.html) — seções Sprint Goal, Sprint Planning
- [Scrum.org — Getting to Done: Creating Good Sprint Goals](https://www.scrum.org/resources/blog/getting-done-creating-good-sprint-goals)
- [Age of Product — Nine Sprint Goal Principles](https://age-of-product.com/sprint-goal-principles/)
