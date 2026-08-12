# Templates de issue

Contrato de formato da descrição. Preencher integralmente; PRIORIZACAO só com MoSCoW na
criação (I/C/F/ICE ficam `—` até o discovery).

### Template A — Feature / Improvement / Enhancement

```markdown
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

---

## EVIDÊNCIAS DA DEMANDA

- **Volume de pedidos:** [ex: "3 tickets de suporte em 2 semanas", "solicitado em 2 sprints consecutivos", "nenhum pedido formal — identificado por observação"]
- **Origem:** [canal — suporte, feedback direto, sprint planning, análise de uso, observação de campo]
- **Quem pediu:** [perfis ou stakeholders — ex: "Engenheiros GEENG", "time de operações", "PO"]
- **Evidências:** [links, prints, tickets, referências — ou "nenhuma evidência formal registrada"]

---

## PRIORIZACAO

| MoSCoW | Impacto | Confiança | Facilidade | ICE | Quadrante |
|--------|---------|-----------|-----------|-----|-----------|
| MUST/SHOULD/COULD/WONT | — | — | — | — | — |

> MoSCoW: [justificativa]. Impacto, Confiança e Facilidade calculados durante o discovery.
```

### Template B — Bug

```markdown
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

## PRIORIZACAO

| MoSCoW | Impacto | Confiança | Facilidade | ICE | Quadrante |
|--------|---------|-----------|-----------|-----|-----------|
| MUST/SHOULD/COULD/WONT | — | — | — | — | — |

> MoSCoW: [justificativa]. Impacto, Confiança e Facilidade calculados durante o discovery.
```

**Para critical bugs:** na seção `PRIORIZACAO`, substituir a tabela por:
```
MoSCoW: MUST
Classificação: CRITICAL — vai direto para a sprint atual.
```

### Nota sobre EVOLUCAO

**Não há seção EVOLUCAO na descrição.** O discovery é documentado em **comentários** na
issue (um por fase do Double Diamond). A descrição congela o problema; os comentários
evoluem o entendimento.
