---
name: discovery
description: >
  Conduz o discovery de uma demanda seguindo o Double Diamond: explora e define o problema (D1),
  depois explora e define a solução (D2). Cada fase gera um comentário na issue de origem —
  a descrição nunca é alterada, exceto o bloco PRIORIZACAO que é atualizado ao convergir D1 e D2.
  Detecta automaticamente em qual fase a issue está lendo comentários existentes e propõe iniciar
  da próxima fase pendente. Use esta skill quando o usuário pedir para explorar soluções, fazer
  discovery, discutir alternativas, aprofundar o entendimento de um problema, ou explorar soluções
  para uma issue específica — referenciando ou não um número de issue.
  IMPORTANTE: Carregue obrigatoriamente a skill `glab-backlog` antes de qualquer operação no GitLab.
---

# discovery — Double Diamond

**PRÉ-REQUISITO:** Carregar a skill `glab-backlog` antes de qualquer operação no GitLab.

Quatro fases. Cada fase = um comentário na issue + um bloco no arquivo de history. A descrição da issue nunca é alterada, exceto o bloco `PRIORIZACAO`.

**Fronteira:** só discute e documenta. Não gera .docx, RN/RA/MSG numeradas, nem novas issues.

---

## Princípios — invioláveis

1. **O usuário decide tudo.** A IA propõe, o usuário aprova. Nunca avançar sozinha.
2. **Nada postado sem aprovação.** Apresentar rascunho → iterar → postar só com "pode".
3. **Suposição é suposição.** Declarar explicitamente e confirmar antes de usar.
4. **Sem resposta = em aberto.** Nunca preencher com chute. Registrar como "em aberto".
5. **ICE/MoSCoW negociados.** Cada valor: propor + justificar → aguardar aprovação.
6. **Uma fase de cada vez.** Nunca apresentar D1a e D1b juntos.

---

## Configuração

```
GITLAB_HOST / GITLAB_URI / GITLAB_REPO — lidos do .env
docs/context_docs/  — contexto do produto
history/discoveries/ — registro das sessões de discovery
```

---

## 1. Entrada — Detecção de Fase

```bash
# Carregar issue
glab issue view NNN -R ${GITLAB_REPO}

# Ler comentários existentes
glab api "projects/${GITLAB_REPO//\//%2F}/issues/NNN/notes" \
  --paginate | jq '.[] | {id:.id, body:(.body|.[0:80])}'
```

Marcadores de fase nos comentários:

| Marcador | Fase concluída |
|---|---|
| `[D1a]` | Exploração do Problema |
| `[D1b]` | Definição do Problema |
| `[D2a]` | Exploração das Soluções |
| `[D2b]` | Definição da Solução — completo |

Resumir o estado ao usuário e propor a próxima fase. **Aguardar confirmação.**

Skip de fase: só com justificativa + pergunta + aprovação explícita.

---

## 2. Inicializar history

Criar `history/discoveries/YYYY-MM-DD_discovery_issue-NNN.md` se não existir:

```markdown
# DISCOVERY #NNN — [Título]
Issue: [URL] | Iniciado: YYYY-MM-DD | Módulo: [X]
Fontes: [arquivos lidos de docs/context_docs/]

---
```

Se já existir: ler para retomar do ponto correto. Nunca sobrescrever.

---

## 3. Diamond 1 — Problema

### D1a — Exploração (diverge)

1. Ler `docs/context_docs/` — ONEPAGE.md e arquivos relevantes ao módulo.
2. Buscar issues relacionadas: `glab issue list --search "[termo]" -A -P 20`
3. Se houver dúvidas que mudam o entendimento: perguntar antes de redigir.
4. Apresentar rascunho ao usuário. Iterar. Só postar com aprovação.

**Comentário (rascunho → aprovação → postar):**
```markdown
## [D1a] Exploração do Problema — YYYY-MM-DD

**Afetados:** [perfil / escala / frequência]
**Contexto:** [o que o sistema já faz nessa área; issues/HUs relacionadas]
**Hipóteses:**
- [hipótese — evidência]
**Em aberto:** [perguntas sem resposta, ou "nenhuma"]
```

```bash
glab issue note create NNN -R ${GITLAB_REPO} -m "..."
# fallback:
glab api "projects/${GITLAB_REPO//\//%2F}/issues/NNN/notes" -X POST -f body="..."
```

**Salvar no history (append):**
```markdown
## D1a — YYYY-MM-DD
- Afetados: [quem]
- Hipóteses: [lista]
- P/R com usuário: P: [X] → R: [Y] / em aberto: [Z]
- Decisões: [lista]
```

Após postar: perguntar se há algo a complementar ou se pode convergir para D1b.

---

### D1b — Definição (converge)

Avançar só com sinalização explícita do usuário.

1. Propor Problem Statement → aguardar aprovação.
2. Propor MoSCoW → justificar → aguardar aprovação.
3. Propor Impacto → justificar → aguardar aprovação.
4. Propor Confiança → justificar → aguardar aprovação.
5. Facilidade: **não calcular ainda** — depende da solução.
6. Apresentar rascunho completo → aprovar → postar → atualizar issue.

**Comentário (rascunho → aprovação → postar):**
```markdown
## [D1b] Definição do Problema — YYYY-MM-DD

> [Problem Statement — 1-2 frases: quem / qual problema / impacto observável]

**Causa raiz:** [causa ou hipótese mais provável]
**Sucesso quando:** [critérios verificáveis]
**Fora do escopo:** [non-goals explícitos]

### Priorização — D1
| MoSCoW | Impacto | Confiança | Facilidade |
|--------|---------|-----------|------------|
| [valor] | [N] | [N] | TBD (D2) |
```

```bash
glab issue note create NNN -R ${GITLAB_REPO} -m "..."
# Atualizar PRIORIZACAO na descrição (só o bloco <details>):
glab issue update NNN -R ${GITLAB_REPO} -d "[descrição com PRIORIZACAO atualizado]"
# Atualizar label:
glab issue update NNN -R ${GITLAB_REPO} -l "[labels com PRIORIDADE::MUST/SHOULD/COULD/WONT]"
```

**Salvar no history (append):**
```markdown
## D1b — YYYY-MM-DD
> [Problem Statement aprovado]
- Causa raiz: [X]
- MoSCoW=[X] | I=[N] | C=[N]
- Negociação: [proposto X → aprovado Y — motivo do usuário, se ajustou]
- Non-goals: [lista]
```

Após postar: perguntar se pode avançar para D2a.

---

## 4. Diamond 2 — Solução

### D2a — Exploração (diverge)

Sempre ao menos 2 soluções. Uma proposta única não é discovery.

1. Apresentar rascunho com alternativas. Não postar ainda.
2. Discutir: preferências, restrições, refinamentos.
3. Para demandas grandes: propor decomposição em HUs/HTs e perguntar como dividir.
4. Postar só após o usuário indicar quais alternativas registrar.

**Comentário (rascunho → aprovação → postar):**
```markdown
## [D2a] Exploração das Soluções — YYYY-MM-DD

| | Solução | Esforço | Decisão |
|--|---------|---------|---------|
| A | [nome] | Baixo/Médio/Alto | ✅ Candidata / ❌ [motivo] |
| B | [nome] | ... | ... |

**[Solução A]:** [o que é + como funciona em 3-5 linhas] | Prós: [...] | Contras: [...]
**[Solução B]:** [idem]
```

```bash
glab issue note create NNN -R ${GITLAB_REPO} -m "..."
```

**Salvar no history (append):**
```markdown
## D2a — YYYY-MM-DD
- Soluções: A=[nome] ✅ / B=[nome] ❌ [motivo]
- Escolha: [nome] — [razão dada pelo usuário]
- Decomposição: HU NNN.1 [escopo] / HT NNN.1 [escopo]
```

Avançar para D2b só com confirmação explícita da solução escolhida.

---

### D2b — Definição (converge)

1. Apresentar rascunho: fluxo, campos, RN/RA, critérios → iterar até aprovação.
2. Propor Facilidade → justificar → aguardar aprovação.
3. Calcular ICE → apresentar quadrante → aguardar confirmação.
4. Se MoSCoW mudou: explicar e confirmar.
5. Apresentar Comentário 4 completo → aprovar → postar → atualizar issue.

**Comentário (rascunho → aprovação → postar):**
```markdown
## [D2b] Definição da Solução — YYYY-MM-DD

> Base para HU/HT. Alternativas em [D2a].

**Solução:** [nome — motivo da escolha em 1 linha]

### Fluxo
1. [passo]
2. [passo — incluir edge cases relevantes]

### Campos — [Tela]
| Campo | Tipo | Obrigatório | Observação |
|-------|------|-------------|------------|
| [campo] | [tipo] | S/N | [validação / default] |

### Regras
- RN: [regra de domínio]
- RA: [comportamento de UI]

### Critérios de aceite
- [ ] [dado X, quando Y, então Z]

**Escopo:** inclui [X] / não inclui [Y]

### Priorização Final — D2
| MoSCoW | Impacto | Confiança | Facilidade | ICE | Quadrante |
|--------|---------|-----------|------------|-----|-----------|
| [valor] | [N] | [N] | [N] | [resultado] | [QUICK WIN/PLAN/LATER/DROP] |

**Decomposição:** HU NNN.1 (~Xd) → HT NNN.1 (~Xd)
```

Quadrantes: QUICK WIN = I≥7 e F≥5 | PLAN = I≥7 e F≤4 | LATER = I≤6 e F≥5 | DROP = I≤6 e F≤4

```bash
glab issue note create NNN -R ${GITLAB_REPO} -m "..."
# fallback:
glab api "projects/${GITLAB_REPO//\//%2F}/issues/NNN/notes" -X POST -f body="..."
# Atualizar PRIORIZACAO (ICE completo):
glab issue update NNN -R ${GITLAB_REPO} -d "[descrição com PRIORIZACAO final]"
glab issue update NNN -R ${GITLAB_REPO} -l "[labels com PRIORIDADE::QUADRANTE]"
```

**Salvar no history (append):**
```markdown
## D2b — YYYY-MM-DD
- Solução: [nome]
- ICE: I=[N] × C=[N] × F=[N] = [resultado] → [quadrante]
- Negociação F: [proposto X → aprovado Y — motivo, se ajustou]
- MoSCoW=[X] | I=[N] | C=[N] | F=[N] | ICE=[resultado] | Quadrante=[X]
- Critérios: [lista]
- Decomposição: HU NNN.1 (~Xd) → HT NNN.1 (~Xd)

---
Status: completo ✓
Próximos passos: `documenter` — "cria as regras da #NNN" (só regras) ou "gera o docx da #NNN" (regras + .docx)
```

Se sessão encerrar sem D2b completo, adicionar ao final do history:
```markdown
---
Sessão encerrada: YYYY-MM-DD (parcial)
Última fase: [D1a/D1b/D2a] | Próxima: [D1b/D2a/D2b]
Pendências: [decisões abertas / perguntas sem resposta]
```

---

## 5. Exemplo de conversa

**Entrada:** `"faz o discovery da #680"`

**IA:** lê issue + comentários, cria history.
> "Li a #680. Nenhuma fase iniciada. Proponho D1a. Posso avançar?"

**Usuário:** "Pode."

**IA:** lê ONEPAGE.md, encontra #534. Redige rascunho.
> "Rascunho do D1a: [...]. Quer ajustar?"

**Usuário:** "Adiciona que afeta o Operador na tela de candidatos."

**IA:** ajusta. "Feito. Posso postar?"

**Usuário:** "Pode."

**IA:** posta. Salva D1a no history.
> "Postado. Uma dúvida: a ordenação é por sessão ou por usuário?"

**Usuário:** "Por sessão."

**IA:** "Entendido. Prontos para definir o problema? Posso propor o D1b."

**Usuário:** "Pode."

**IA:** "Proponho: 'O Operador perde a ordenação ao paginar — a cada página volta ao padrão, forçando repetição manual.' Está correto?"

**Usuário:** "Está."

**IA:** "Proponho SHOULD — não bloqueia, mas impacto recorrente. Concorda?"
*(... e assim por diante: um valor de cada vez, aprovação, rascunho, aprovação, postar)*
