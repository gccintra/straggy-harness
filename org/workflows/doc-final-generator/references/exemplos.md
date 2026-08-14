# Exemplo — HU no formato novo (autocontido)

Um exemplo completo demonstrando tom, nível de detalhe e o formato de cada seção. CA coeso
(agrupa o relacionado), RN em SBVR, MSG e GL. Rigor de autoria em `doc-consolidator/references/regras.md`.

---

```markdown
---
tipo: HU
issue: 702
modulo: Aditivos
data: 2026-07-08
---

# HU07.02 - Criar Termo Aditivo

## Metadados
- **Cliente:** [CLIENTE]
- **Projeto:** OBRASIM
- **Ordem de Serviço:** OS2026167
- **Épico/Tema:** EPC-07 - Gerenciar Termos Aditivos
- **Identificação da HU:** HU07.02 - Criar Termo Aditivo
- **Responsável:** [RESPONSÁVEL]
- **Data de Emissão:** 08/07/2026

## 1. Problema

**Persona:** Engenheiro (GEENG)

**Cenário do Usuário (Dor):** Depois de assinado, o contrato fica congelado. Alterações de prazo,
escopo, valor, reajuste ou garantia não têm onde ser registradas formalmente — sem lastro
jurídico, sem rastreabilidade, sem reflexo no planejamento financeiro.

## 2. História de Usuário

| | |
|---|---|
| **Como** | Engenheiro (GEENG) |
| **Quero** | criar um termo aditivo para registrar alterações contratuais |
| **Para** | manter o contrato atualizado, rastreável e com o financeiro fiel à realidade |

## 3. Escopo

Wizard de **2 etapas** no Hub de Aditivos. A Etapa 1 coleta as naturezas da alteração; a Etapa 2
(cronograma) é condicional. Ao salvar, o aditivo é persistido, numerado e registrado no histórico.

## 4. Critérios de Aceitação

### 4.1. Seleção de Naturezas
- **CA01:** **Dado que** o usuário está na Etapa 1, **Quando** nenhuma natureza está selecionada, **Então** o botão "Próximo" fica desabilitado. [RN_01]
- **CA02:** **Dado que** o usuário está na Etapa 1 sem natureza selecionada, **Quando** tenta avançar, **Então** o sistema exibe a mensagem de bloqueio. [MSG_01] [RN_01]

### 4.2. Reajuste e Distribuição
- **CA03:** **Dado que** a natureza Reajuste está selecionada, **Quando** o usuário informa Valor Base e Índice válidos, **Então** o sistema exibe o Saldo de Distribuição. [RN_02]
- **CA04:** **Dado que** a grade está habilitada, **Quando** a soma distribuída é diferente do Saldo, **Então** o sistema exibe a mensagem de divergência. [MSG_02] [RN_03]

### 4.3. Finalização
- **CA05:** **Dado que** as validações passaram, **Quando** o usuário salva, **Então** o aditivo é criado com ID sequencial por contrato. [GL_01]

## 5. Regras de Negócio

- **RN_01** — É obrigatório que um Aditivo tenha ao menos uma natureza selecionada entre Prazo, Escopo, Reajuste, Reequilíbrio e Garantia.
- **RN_02** — O Saldo de Distribuição é calculado como o Valor Base multiplicado pelo Índice dividido por cem. É necessário que o Valor Base e o Índice sejam maiores que zero.
- **RN_03** — É necessário que a soma dos valores distribuídos entre os projetos seja exatamente igual ao Saldo de Distribuição.

## 6. Mensagens

- **MSG_01** (Erro) — "Selecione ao menos uma natureza para criar o aditivo."
- **MSG_02** (Erro) — "A distribuição não fecha com o saldo calculado. Ajuste os valores."

## 7. Referências Globais

- **GL_01 — Numeração Sequencial por Contrato** — usado em CA05. (ver Referencias-Globais.md — Drive)

## 8. Protótipo

### 8.1. Cadastro do contrato

**Link:** https://<base>/contratos/novo

#### 8.1.1. Formulário de cadastro de contrato

### 8.2. Edição do contrato

**Link:** https://<base>/contratos/1/editar

#### 8.2.1. Formulário de edição de contrato

## 9. Complemento de Documentação

**Documento de Regras Global:** https://docs.google.com/document/d/<id>/edit

**Link do Protótipo de Telas Impactadas:**

- **Cadastro do contrato:** https://<base>/contratos/novo
- **Edição do contrato:** https://<base>/contratos/1/editar

---

## Apêndice — Trilha de Discovery

### D1a · Exploração do Problema
[afetados, contexto, hipóteses, perguntas em aberto]

### D2b · Definição da Solução
[solução escolhida, fluxo, campos, ICE completo]

## Apêndice — Novas Referências Globais (copiar para o Drive)

Nenhuma.
```

---

## Notas de tom

- Seções 1–3: curtas, foco no problema/valor, **sem** prescrever telas/campos/fluxos.
- CA: cenário coeso (agrupa condições/efeitos relacionados); mensagem/fórmula nunca escrita inline, só o código `[MSG_0X]`/`[RN_0X]`.
- RN: fala de entidade e atributo, nunca "campo/botão/tela"; SBVR com palavra modal.
- MSG e GL: seções próprias; GL só referencia (conteúdo vive no Drive).
