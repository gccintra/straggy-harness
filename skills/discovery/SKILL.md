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

**Fronteira:** só discute e documenta, em **material descritivo/bruto**. Não gera .docx, não
numera RN/MSG/GL nem espelha o formato final do `.md` (CA coeso, RN em SBVR, seções numeradas
— isso é do `doc-consolidator`), nem cria novas issues. O discovery é rico e narrativo; o
consolidator é quem estrutura. Cada regra/comportamento capturado ganha um **marcador de
destino** (`[→CA]` / `[→RN]` / `[→MSG]` / `[→GL candidato]`) para alimentar o consolidator sem
duplicar o trabalho dele.

---

## Princípios — invioláveis

1. **O usuário decide tudo.** A IA propõe, o usuário aprova. Nunca avançar sozinha.
2. **Nada postado sem aprovação.** Apresentar rascunho → iterar → postar só com "pode".
3. **Suposição é suposição.** Declarar explicitamente e confirmar antes de usar.
4. **Sem resposta = em aberto.** Nunca preencher com chute. Registrar como "em aberto".
5. **ICE/MoSCoW negociados.** Cada valor: propor + justificar → aguardar aprovação.
6. **Uma fase de cada vez.** Nunca apresentar D1a e D1b juntos. No D2b, um sub-passo por vez (fluxo → campos → regras → edge cases → critérios → ICE) — não despejar tudo num rascunho só.
7. **Investigar antes de escrever (D2).** Solução sai do sistema real (regras, HUs, dados), não de analogia. Toda regra proposta é marcada `[EXISTENTE]` / `[CONFIRMADO]` / `[SUPOSIÇÃO]`.

---

## Configuração

```
GITLAB_HOST / GITLAB_URI / GITLAB_REPO — lidos do .env
docs/context_docs/  — contexto do produto
history/discoveries/ — registro das sessões de discovery
```

---

## 0. Modo sem GitLab

Verifique `GITLAB_ENABLED` no `.env`. Se não for `true`:

- **Entrada:** pule `glab issue view` / `glab api .../notes`. Peça a demanda por descrição livre do usuário. Sem número de issue, nomeie o history por slug: `history/discoveries/YYYY-MM-DD_discovery_{slug}.md`.
- **Detecção de fase:** em vez de ler comentários da issue, releia o history local — os headers `## D1a —` / `## D1b —` / `## D2a —` / `## D2b —`, ou o marcador `Última fase` no rodapé de uma sessão parcial.
- **Postagem:** pule todo bloco `glab issue note create` / `glab api .../notes -X POST` / `glab issue update` (comentário, PRIORIZACAO, label). O registro **"Salvar no history (append)"** de cada fase já é o suficiente — nada se perde, só não duplica na issue.
- Avise uma vez, na primeira fase: "GitLab desabilitado — registro fica só no history local, não será postado em issue."

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

> **Princípio do D2: investigar antes de escrever.** O D1 tem ritual de leitura; o D2 também precisa. A solução sai do sistema real (regras, HUs, fluxo, dados) — não de analogia ou chute. Onde você inventaria um campo, uma validação ou uma regra, primeiro **ancore** ou **declare suposição**.

### D2.0 — Ancoragem (obrigatória antes de propor solução)

Não avance para D2a sem isto. É leitura + listagem; segue direto (sem postar).

1. **Reler o sistema no escopo da demanda:**
   - `docs/context_docs/md/Regras/` — regras de negócio existentes que tocam a área.
   - `docs/context_docs/md/HUs/` — HUs do mesmo módulo (padrões de tela, fluxo, campos já usados).
   - `docs/context_docs/md/Referencias-Globais.md` — catálogo de globais (GL), **se existir**. Se
     a demanda mexe em numeração sequencial, histórico de ações, valor atual do contrato,
     status/estados, papéis ou catálogos → marque `[→GL candidato]`. Já existe no catálogo →
     aponte o GL (reúso). Não existe (ou catálogo ausente) → segue como candidato; o consolidator
     decide promoção depois, com prova. Só não trate o conceito como novidade exclusiva da issue.
   - ONEPAGE.md e discoveries anteriores do módulo em `history/discoveries/`.
2. **Montar a lista de incógnitas técnicas** — o que trava a solução e você não pode responder sozinho lendo docs:
   - existe tabela/campo para isso? quais colunas?
   - o valor é armazenado ou derivado (ex.: valor atual do contrato vem de aditivos)?
   - há regra/validação já implementada que a solução precisa respeitar?
3. **Apresentar a lista e PARAR.** Não consultar banco sozinha, não delegar sozinha:
   > "Pra fechar a solução preciso confirmar: [lista de incógnitas]. Você resolve como preferir — responde aqui, consulta o banco (`db-query` / `@tech-lead`), ou seguimos marcando como **suposição declarada**. Como quer seguir?"
4. O usuário decide o meio. Registrar cada resposta como `[CONFIRMADO: fonte]` ou, se ele mandar seguir, `[SUPOSIÇÃO: confirmar]`.

**Salvar no history (append):**
```markdown
## D2.0 — YYYY-MM-DD (ancoragem)
- Regras existentes lidas: [RN/arquivo — o que cobre]
- HUs de referência: [NNN — padrão reutilizado]
- Incógnitas técnicas: [pergunta → CONFIRMADO(fonte) / SUPOSIÇÃO]
```

Fallback: se o projeto não tem banco (`DB_ENABLED=false`), incógnita de dado vira `[SUPOSIÇÃO: confirmar com dev]` — não trava o fluxo.

---

### D2a — Exploração (diverge)

Explorar soluções **reais**, ancoradas no que a D2.0 revelou.

1. Apresentar rascunho com alternativas. Não postar ainda.
2. **Proibido espantalho.** Não invente uma "Solução B" fraca só para ter duas. Se há mais de um caminho viável, apresente com prós/contras honestos. Se só há um caminho real, **diga**: "Caminho único porque [X]" — e explique por que as alternativas óbvias não servem. Discovery honesto de uma opção > duas opções teatrais.
3. Discutir: preferências, restrições, refinamentos.
4. Para demandas grandes: propor decomposição em HUs/HTs e perguntar como dividir.
5. Postar só após o usuário indicar quais alternativas registrar.

**Comentário (rascunho → aprovação → postar):**
```markdown
## [D2a] Exploração das Soluções — YYYY-MM-DD

| | Solução | Esforço | Decisão |
|--|---------|---------|---------|
| A | [nome] | Baixo/Médio/Alto | ✅ Candidata / ❌ [motivo] |
| B | [nome] | ... | ... |

**[Solução A]:** [o que é + como funciona em 3-5 linhas] | Prós: [...] | Contras: [...]
**[Solução B]:** [idem]
<!-- Se caminho único: uma linha só, "Caminho único porque X; alternativas Y/Z não servem porque..." -->
```

```bash
glab issue note create NNN -R ${GITLAB_REPO} -m "..."
```

**Salvar no history (append):**
```markdown
## D2a — YYYY-MM-DD
- Soluções: A=[nome] ✅ / B=[nome] ❌ [motivo]  (ou: caminho único — motivo)
- Escolha: [nome] — [razão dada pelo usuário]
- Decomposição: HU NNN.1 [escopo] / HT NNN.1 [escopo]
```

Avançar para D2b só com confirmação explícita da solução escolhida.

---

### D2b — Definição (converge)

Iterativo, **um passo por vez** — não despeje fluxo + campos + regras + ICE num rascunho só. Aprovar cada passo antes do próximo:

1. **Fluxo** → apresentar passo a passo (incluir edge cases) → aprovar.
2. **Campos** → tabela por tela → aprovar.
3. **Regras e comportamentos** → capture o material **bruto e descritivo**, em linguagem de
   negócio. **Não** numere como RN/CA final nem force o formato do `.md` — isso é do
   `doc-consolidator`. Seja mais detalhado aqui do que no `.md` (contexto, porquês, edge cases),
   para o consolidator ter matéria-prima sem redundância. Marque cada item com **origem** e
   **destino**:
   - **Origem:** `[EXISTENTE: RN-xx / arquivo]` (já lida na D2.0) / `[CONFIRMADO: banco/dev]`
     (validado) / `[SUPOSIÇÃO: confirmar]` (proposta nova).
   - **Destino:** `[→CA]` comportamento de tela/fluxo (habilita botão, campo dinâmico, recálculo)
     · `[→RN]` fórmula/política/invariante · `[→MSG]` texto de feedback · `[→GL candidato]`
     dado/estado/fluxo compartilhado por 2+ issues (status, numeração, histórico).
   → aprovar.
4. **Edge cases** → o que acontece nos limites (saldo estourado, vazio, concorrência) → aprovar.
5. **Reabrir a lista "em aberto" do D1a** — item a item: respondido (com a resposta) ou adiado (com motivo). Nenhuma pendência do D1a pode ser fechada em silêncio.
6. **Critérios de aceite** → aprovar.
7. **Facilidade** → propor → justificar → aprovar. **ICE** → calcular → quadrante → confirmar. Se **MoSCoW** mudou: explicar e confirmar.
8. Montar o Comentário 4 completo → aprovar → postar → atualizar issue.

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

### Regras e comportamentos
<!-- Material bruto/descritivo. Cada item: origem + destino. O consolidator estrutura em CA/RN/MSG/GL. -->
- [descrição em linguagem de negócio, com contexto/porquê] — origem `[EXISTENTE/CONFIRMADO/SUPOSIÇÃO]` · destino `[→CA]`/`[→RN]`/`[→MSG]`/`[→GL candidato]`

### Pendências do D1a
- [pergunta em aberto do D1a] → respondido: [resposta] / adiado: [motivo]

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
- Regras/comportamentos: [descrição — origem EXISTENTE(fonte)/CONFIRMADO(banco)/SUPOSIÇÃO · destino →CA/→RN/→MSG/→GL candidato]
- Pendências D1a: [pergunta → respondida / adiada(motivo)]
- ICE: I=[N] × C=[N] × F=[N] = [resultado] → [quadrante]
- Negociação F: [proposto X → aprovado Y — motivo, se ajustou]
- MoSCoW=[X] | I=[N] | C=[N] | F=[N] | ICE=[resultado] | Quadrante=[X]
- Critérios: [lista]
- Decomposição: HU NNN.1 (~Xd) → HT NNN.1 (~Xd)

---
Status: completo ✓
Próximos passos: `doc-consolidator` — "documenta a #NNN" (gera o `.md` autocontido com CA/RN/MSG/GL); depois, só sob pedido explícito, `hu-generator` gera o `.docx`
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
