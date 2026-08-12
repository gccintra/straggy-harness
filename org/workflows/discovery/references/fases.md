# Fases do discovery — templates de comentário e history

Contrato de formato por fase. Rascunho → aprovação → postar (write-gate por fase).

## 3. Diamond 1 — Problema

### D1a — Exploração (diverge)

1. Ler a base de contexto (provider `knowledge/`) — varra e leia o que toca o módulo.
2. Buscar demandas relacionadas pelo provider (operação **listar demandas**, filtro de busca).
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

> Publicação: **comentar demanda** — operações do provider
> (`system/providers/backlog/`).

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

> Publicação: **comentar demanda** + **atualizar bloco estruturado** (só o bloco
> `PRIORIZACAO`, nunca o resto da descrição) + **rotular** com a prioridade MoSCoW —
> operações do provider (`system/providers/backlog/`).

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
   - regras de negócio existentes que tocam a área (provider `knowledge/`).
   - requisitos de referência do mesmo módulo (padrões de tela, fluxo, campos já usados).
   - catálogo de Referências Globais (GL), **se existir** (`org/ORG.md` §6). Se
     a demanda mexe em numeração sequencial, histórico de ações, valor atual do contrato,
     status/estados, papéis ou catálogos → marque `[→GL candidato]`. Já existe no catálogo →
     aponte o GL (reúso). Não existe (ou catálogo ausente) → segue como candidato; o consolidator
     decide promoção depois, com prova. Só não trate o conceito como novidade exclusiva da issue.
   - ONEPAGE.md e discoveries anteriores do módulo em `history/discoveries/`.
   - contexto diverso do produto (persona, glossário, decisões), **se existir**.
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

> Publicação: operação **comentar demanda** do provider.

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

> Publicação: **comentar demanda** + **atualizar bloco estruturado** (só o bloco `PRIORIZACAO`) + **rotular** com a prioridade — operações do provider
> (`system/providers/backlog/`).

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

