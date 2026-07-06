---
name: backlog-issue-creator
description: >
  Create and refine backlog issues with structured templates, MoSCoW prioritization, and proper labels.
  Trigger when the user mentions creating an issue, backlog item, demand, feature, bug, improvement,
  or anything that should be tracked — in English or Portuguese (criar issue, demanda, backlog, bug,
  melhoria, feature, nova funcionalidade, erro, tarefa). Also trigger when the user wants to refine
  or enrich an existing issue that has minimal information (refinar issue #NNN, completar, enriquecer,
  a issue só tem título). For detailed glab CLI command reference (list, search, update, auth
  troubleshooting), always also load the glab-backlog skill.
---

# backlog-issue-creator

**PRÉ-REQUISITO:** Carregar a skill `glab-backlog` antes de qualquer operação no GitLab.

Dois fluxos: **Flow 1 — Create** (nova issue a partir do zero) e **Flow 2 — Refine** (enriquecer issue existente com informação rasa). Ambos focam exclusivamente no problema — soluções são responsabilidade do `discovery`.

## 1. Project Configuration

All values are read from environment variables — no hardcoded values.

```
{REPO}:       ${GITLAB_REPO}
{HOST}:       ${GITLAB_HOST}
{HOST_URI}:   ${GITLAB_URI}
{BOARD_URL}:  ${GITLAB_URI}/${GITLAB_REPO}/-/boards
```

## 2. Detecção de Fluxo

Identifique a intenção antes de qualquer ação:

| Sinal | Fluxo |
|---|---|
| "criar issue", "nova demanda", "quero registrar", "bug", "feature" | **Flow 1 — Create** |
| "refinar #NNN", "completar a issue", "enriquecer", "a issue só tem título" | **Flow 2 — Refine** |
| Ambíguo | Perguntar: "Você quer criar uma nova issue ou enriquecer uma já existente?" |

## 3. Discover Project Context

Before creating or refining issues, understand the project structure:

1. **Documentation in the repo:** Look for ONEPAGE.md, README.md, docs/ folder — description of modules, epics, or architecture.
2. **Existing issues:** `glab issue list -R {REPO} --search "[keyword]"` — find similar issues and understand project vocabulary.
3. **Ask the user:** If no documentation is found, ask: "Qual o nome do módulo ou área do sistema?" and "Tem alguma issue relacionada?"

**Module inference:** The module is a **text field** in the template (CONTEXTO & DISCOVERY > Módulo), not a label. Infer from context: docs, existing issue titles, or user input. If cannot infer, ask directly.

## 4. Discover Project Labels

Before suggesting labels, query the available labels:

```bash
glab label list -R {REPO}
```

Analyze the label taxonomy. Look for:
- **Type labels:** pattern for kind of work (e.g. `TIPO::BUG`, `TIPO::MELHORIA`)
- **Priority labels:** pattern for MoSCoW (e.g. `PRIORIDADE::MUST`, `PRIORIDADE::SHOULD`)
- **Workflow labels:** the **entry-point label** — marks a newly created item ready for review (e.g. `PARA DESCOBERTA`)

**Label inference rules:**
- Infer type label from issue classification (bug/feature/improvement)
- For critical bugs: infer the project's critical/urgent label
- Always present inferred labels to the user and confirm before creation
- If taxonomy is ambiguous, ask the user

---

## 5. Flow 1 — Create

### 5a. Interview

> **Descolar solução do problema.** O usuário quase sempre chega com a solução pronta ("quero exportar em PDF assíncrono"). Não documente isso como problema. Extraia o problema por trás: pergunte *"que problema isso resolve?"*, *"o que acontece hoje sem isso?"*. Documente o **problema**; a solução proposta vira uma nota para o `discovery`, não o corpo da issue.

Ask 2-4 targeted questions, 2 at a time:

- **O quê:** O que está quebrado ou faltando? O que exatamente acontece?
- **Quem:** Qual perfil de usuário? Quantos são afetados?
- **Impacto:** Qual a consequência se não for feito?
- **Evidências:** Alguém já pediu isso antes? Quantas vezes? Há links ou registros?
- **Prazo:** Há milestone ou data limite?

Stop asking when you have enough to document. Do not over-interview.

### 5b. Classify

| Keywords | Template |
|---|---|
| "bug", "erro", "quebrado", "nao funciona", "crash", "falha" | **Template B — Bug** |
| "nova funcionalidade", "melhoria", "feature", "quero que", "precisamos de" | **Template A — Feature** |
| Ambiguous | Ask: "Isso é um bug técnico ou uma nova necessidade?" |

### 5c. Critical Bug Check

Checklist (SIM/NÃO):
- Sistema indisponível para algum perfil?
- Risco de perda ou vazamento de dados?
- Impede fluxo core (inscrição, pagamento, certificado)?
- Afeta >30% dos usuários?
- Sem workaround?

**Se qualquer SIM:** critical bug.
- Use Template B
- No bloco `PRIORIZACAO`, substituir tabela por:
  ```
  MoSCoW: MUST
  Classificação: CRITICAL — vai direto para a sprint atual.
  ```
- Label: aplicar o label critical/urgent do projeto (inferido da taxonomia)
- **Pular o fluxo MoSCoW normal**

### 5d. Prioritization — MoSCoW only

**Na criação, calcular apenas MoSCoW.** ICE não é calculável ainda — Facilidade é desconhecida antes de uma solução ser escolhida no discovery.

| MoSCoW | Critério |
|---|---|
| MUST | Inegociável. Sem isso a sprint/entrega não faz sentido. |
| SHOULD | Importante, mas o produto sobrevive sem isso por um tempo. |
| COULD | "Nice to have". Agrega valor marginal. |
| WONT | Válido, mas fora de cogitação para este ciclo. |

Impacto, Confiança e Facilidade são calculados durante o discovery (Fases D1b e D2b).

---

## 6. Issue Templates

### Template A — Feature / Improvement / Enhancement

```markdown
# [TITLE] - [MODULO]

---

## HISTÓRIA DE USUÁRIO

|  |  |
|--|--|
| **Como** | [perfil do usuário ou sistema] |
| **Quero** | [a capacidade ou resultado desejado — o QUÊ, nunca o COMO. Sem mecanismo/formato/tecnologia/UX] |
| **Para** | [objetivo ou benefício esperado] |

---

## PROBLEMA

**O QUE:** [O problema em si: o que acontece hoje que não deveria, ou o que falta, e seu efeito no trabalho. Descreva a situação-problema — NÃO a funcionalidade a construir nem a solução técnica.]

**POR QUE:** [Por que isso importa — impacto no negócio, usuário ou sistema. max 2-3 linhas]

> ⚠️ **Problema, não solução.** Proibido mecanismo, formato, tecnologia ou UX nesta seção e na História de Usuário: nada de "PDF", "em lote", "assíncrono", "barra de progresso", "salvar no banco", "criar tela/botão". Isso é saída do `discovery`. Teste: se a frase responde **como** resolver, ela não pertence aqui — reescreva no nível do **problema**.

---

## EVIDÊNCIAS DA DEMANDA

- **Volume de pedidos:** [ex: "3 tickets de suporte em 2 semanas", "solicitado em 2 sprints consecutivos", "nenhum pedido formal — identificado por observação"]
- **Origem:** [canal — suporte, feedback direto, sprint planning, análise de uso, observação de campo]
- **Quem pediu:** [perfis ou stakeholders — ex: "Engenheiros GEENG", "time de operações", "PO"]
- **Evidências:** [links, prints, tickets, referências — ou "nenhuma evidência formal registrada"]

---

## Outros

<details>
<summary>PRIORIZACAO</summary>

| MoSCoW | Impacto | Confiança | Facilidade | ICE | Quadrante |
|--------|---------|-----------|-----------|-----|-----------|
| MUST/SHOULD/COULD/WONT | — | — | — | — | — |

> MoSCoW: [justificativa]. Impacto, Confiança e Facilidade calculados durante o discovery.

</details>

<details>
<summary>CONTEXTO & DISCOVERY</summary>

**Módulo:** [MODULO]
**Épico / Tema:** [Se identificado]
**Relacionadas:** [issues relacionadas encontradas, ex: #42, #87]
**Dependências:** [bloqueadores identificados, se houver]

</details>
```

### Template B — Bug

```markdown
# [TITLE] - [MODULO]

---

## DESCRICAO

[Resumo claro e conciso do bug — o que está quebrado]

---

## IMPACTO

- **Quem é afetado:** [perfil de usuário e escala]
- **Quantidade de ocorrências:** [ex: "reportado 5 vezes esta semana", "ocorre sempre", "esporádico"]
- **Gravidade:** [Bloqueia fluxo core / Incomoda / Cosmético]
- **Frequência:** [Sempre / Frequentemente / Esporadicamente / Condição específica]
- **Consequências se não corrigido:** [max 2-3 linhas]

---

## COMPORTAMENTO ESPERADO X ATUAL

| Esperado | Atual |
|---|---|
| [O que deveria acontecer] | [O que está acontecendo de errado] |

---

## COMO REPRODUZIR

1. [Passo 1]
2. [Passo 2]
3. [Passo 3]

---

## AMBIENTE

- **Sistema/Módulo:** [qual parte do sistema]
- **Perfil de usuário:** [quem estava logado]
- **Navegador/Dispositivo:** [se aplicável]
- **Quando começou:** [data/hora aproximada]

---

## LOGS / EVIDÊNCIAS

- **Mensagem de erro:** [texto exato ou screenshot]
- **Stack trace:** [se disponível]
- **Logs relevantes:** [referência a logs do sistema]
- **Screenshots / Vídeos:** [anexar se houver]

---

## AÇÕES

- [ ] [Ação imediata para investigar ou mitigar]
- [ ] [Ação de diagnóstico]
- [ ] [Ação de correção]

---

## Outros

<details>
<summary>PRIORIZACAO</summary>

| MoSCoW | Impacto | Confiança | Facilidade | ICE | Quadrante |
|--------|---------|-----------|-----------|-----|-----------|
| MUST/SHOULD/COULD/WONT | — | — | — | — | — |

> MoSCoW: [justificativa]. Impacto, Confiança e Facilidade calculados durante o discovery.

</details>

<details>
<summary>CONTEXTO & DISCOVERY</summary>

**Módulo:** [MODULO]
**Épico / Tema:** [Se identificado]
**Relacionadas:** [issues relacionadas]
**Dependências:** [bloqueadores identificados, se houver]

</details>
```

**Para critical bugs:** dentro de `<details><summary>PRIORIZACAO</summary>`, substituir a tabela por:
```
MoSCoW: MUST
Classificação: CRITICAL — vai direto para a sprint atual.
```

### Nota sobre EVOLUCAO

**Não há seção EVOLUCAO na descrição.** O discovery é inteiramente documentado em **comentários na issue** — 4 comentários estruturados ao longo do Double Diamond. A descrição congela o problema; os comentários evoluem o entendimento.

---

## 7. Approval Workflow (Flow 1)

1. Apresentar a issue documentada
2. Perguntar:
   - "A descrição está correta?"
   - "Concorda com o MoSCoW?"
   - "O módulo está correto?"
   - "As labels sugeridas fazem sentido?"
3. Se mudanças pedidas: atualizar e re-apresentar
4. Quando satisfeito: "Crio a issue no GitLab?"
5. Só prosseguir após "sim" explícito ou equivalente

## 8. Creating the Issue (Flow 1)

Após aprovação:

```bash
GITLAB_HOST={HOST} GITLAB_URI={HOST_URI} \
  glab issue create -R {REPO} \
  -t "[TITLE] - [MODULO]" \
  -d "[FULL DESCRIPTION]" \
  -l "[LABEL1],[LABEL2]" \
  -y
```

Confirmar criação, mostrar URL/ID.

**Aplicar workflow label de entrada:**
```bash
GITLAB_HOST={HOST} GITLAB_URI={HOST_URI} \
  glab issue update <ISSUE_ID> -R {REPO} -l "<WORKFLOW_ENTRY_LABEL>"
```

**Se `glab issue create` falhar:**
- Reportar o erro verbatim
- Causas comuns: `glab` não autenticado (`glab auth status`), rede, labels inválidas
- Auth issue: sugerir `GITLAB_HOST={HOST} GITLAB_URI={HOST_URI} glab auth login`
- Oferecer retry. Nunca tentar workarounds que pulem autenticação.

---

## 9. Flow 2 — Refine

Usar quando o usuário fornece um número de issue existente para enriquecer — tipicamente uma issue criada com informação mínima (só título ou descrição breve).

**Fronteira:** Flow 2 enriquece o **problema** apenas — nunca toca em soluções, critérios de aceite, fluxos técnicos ou qualquer coisa que pertença ao discovery.

### 9a. Ler a issue

```bash
GITLAB_HOST={HOST} GITLAB_URI={HOST_URI} \
  glab issue view NNN -R {REPO}
```

### 9b. Gap analysis

Identificar quais seções estão ausentes ou rasas:
- História de usuário (Como / Quero / Para)
- Problema (O QUE / POR QUE)
- Evidências da demanda (volume, origem, quem pediu, links)
- Módulo em CONTEXTO & DISCOVERY
- Issues relacionadas
- MoSCoW inicial em PRIORIZACAO

### 9c. Entrevista para preencher os gaps

> **Se a issue já vem escrita como solução** (ex: "exportação em lote em PDF, assíncrona"), não copie para O QUE. Descole o problema por trás antes de preencher — ver 5a.

Perguntar apenas o que está faltando. Máximo 2-3 perguntas. Foco em:
- Qual problema isso resolve? Para quem?
- Foi solicitado? Quantas vezes? Há links ou registros?
- O que acontece se não for feito?
- Há prazo ou milestone?

### 9d. Montar a descrição enriquecida

Seguir os templates da Seção 6. Preencher todas as seções — o objetivo é uma descrição que possa entrar no discovery sem precisar de esclarecimentos.

### 9e. Aprovação e atualização

1. Apresentar a descrição enriquecida
2. Perguntar: "A descrição enriquecida está correta?"
3. Após aprovação:
```bash
GITLAB_HOST={HOST} GITLAB_URI={HOST_URI} \
  glab issue update NNN -R {REPO} \
  -d "[descrição enriquecida completa]"
```

---

## 10. Rules

- **Nunca criar sem aprovação explícita**
- **ICE nunca é calculado na criação** — apenas MoSCoW. ICE é responsabilidade do discovery.
- **Critical bug bypassa MoSCoW** — vai direto para MUST + label CRITICAL
- **Flow 2 nunca propõe soluções** — só documenta o problema mais completamente
- **Descole solução do problema** em ambos os fluxos. O input costuma vir como solução; documente o problema por trás.

  | | ❌ Solução (não fazer) | ✅ Problema (fazer) |
  |---|---|---|
  | **Quero** | exportar formulários em PDF único, assíncrono, com barra de progresso | consolidar os formulários da turma para a análise final |
  | **O QUE** | Funcionalidade de exportação em lote que gera um PDF... processamento assíncrono... salvo no banco | Hoje o gestor imprime cada formulário individualmente; entre a impressão e o fechamento da turma os dados mudam e candidatos que cancelam somem da listagem, gerando análise final com dados desatualizados |

  Formato/mecanismo (PDF, lote, assíncrono, progresso) = decisão do `discovery`, não da issue.
- Sempre consultar labels antes de sugerir
- Sempre consultar contexto do projeto antes de assumir estrutura
- Seja direto. Cada frase deve adicionar informação
- AI documenta o problema e aplica triage MoSCoW — soluções, critérios e detalhes técnicos são responsabilidade do `discovery`

---

## 11. Example Workflow

**Flow 1 — Create:**
Usuário: *"A listagem de candidatos perde a ordenação ao paginar"*

1. **Classify:** Feature/Improvement (problema de UX, não crash)
2. **Interview:** "Com que frequência? Alguém reportou antes? Quantos usuários?"
3. **Context:** Busca issues relacionadas. Módulo: "Listagem de Candidatos"
4. **Document:** Preenche Template A com HISTÓRIA, PROBLEMA, EVIDÊNCIAS
5. **MoSCoW:** SHOULD — importante mas não bloqueia operação
6. **Labels:** `backlog`, `TIPO::MELHORIA`, `PRIORIDADE::SHOULD`
7. **Approve → Create → workflow label**

**Flow 2 — Refine:**
Usuário: *"Refina a issue #727 — ela só tem título"*

1. **Read:** `glab issue view 727`
2. **Gap analysis:** Faltam história de usuário, problema detalhado, evidências
3. **Interview:** 2-3 perguntas para preencher os gaps
4. **Build enriched description:** Preencher todas as seções do template
5. **Approve → update description**
