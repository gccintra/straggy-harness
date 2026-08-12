# Estrutura do `.md` consolidado (padrão do pack)

Estrutura default de uma demanda documentada. A organização que precisa de outra
**sobrescreve este arquivo** em `org/workflows/doc-consolidator/references/formato-md.md`.

```markdown
---
tipo: <tipo de documento da organização>
---

## Metadados
- **Demanda:** #NNN
- **Autor:** ...
- **Data:** DD/MM/AAAA

## 1. Contexto e problema
Por que existe. Nunca descreve tela ou mecanismo.

## 2. Objetivo
O ganho esperado, verificável.

## 3. Escopo
O que entra. Subseção `### Fora de escopo` com o que fica de fora, explícito.

## 4. Comportamento esperado
Fluxo principal e alternativos, em linguagem de negócio.

## 5. Critérios de aceite
- **CA01:** **Dado que** … **Quando** … **Então** … [RN01]

## 6. Regras de negócio
- **RN01** — <frase única, invariante, sem "o sistema deve" ambíguo>

## 7. Mensagens ao usuário
- **MSG01** (erro|aviso|sucesso) — "texto exato"

## 8. Pendências
- [ ] <o que ficou em aberto, com quem decide>
```

Seções opcionais, acrescentadas depois por outras skills — nunca criadas vazias aqui:
**9. Protótipo** (`prototype-prints`, formato em
`prototype-prints/references/secao-prototipo.md`) e o bloco de complemento que ela
descreve.

### Regras

| Item | Regra |
|---|---|
| Numeração | `CA`, `RN`, `MSG` sequenciais, sem lacuna; referência entre colchetes no fim da linha |
| Critério de aceite | Verificável por quem não participou da conversa; um comportamento por critério |
| Regra de negócio | Invariante (`methods/sbvr-rules.md`), não passo a passo de implementação |
| Pendência | Nunca vira suposição silenciosa — fica na seção 8 até alguém decidir |
| Idioma e acentuação | `org/ORG.md` |
