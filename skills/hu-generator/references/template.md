# Template — História de Usuário

Estrutura de conteúdo da HU (9 seções + apêndices). O `.md` é a fonte de verdade e é
**autocontido** — RN, MSG e GL levam o texto completo. Substitua os campos entre `[colchetes]`.
Rigor de autoria (CA coeso, RN em SBVR, MSG, GL) em `doc-consolidator/references/regras.md`.

---

## Cabeçalho (Capa) — Metadados

```
Cliente: [CLIENTE]
Projeto: [PROJETO]
Ordem de Serviço: [OS_NUMERO]
Épico/Tema: [EPICO_ID] - [EPICO_NOME]
Identificação da HU: [HU_ID] - [HU_NOME]
Responsável: [RESPONSAVEL]
Data de Emissão: [DATA]
```

---

## Sumário

```
1. Problema
2. História de Usuário
3. Escopo
4. Critérios de Aceitação
5. Regras de Negócio
6. Mensagens
7. Referências Globais
8. Protótipo
9. Complemento de Documentação
```

---

## 1. Problema

**Persona**

[Nome do perfil de usuário, ex: Engenheiro (GEENG)]

**Cenário do Usuário (Dor)**

[2–4 frases. A dor real do usuário, sem mencionar a solução. Foco no impacto negativo no
trabalho diário.]

---

## 2. História de Usuário

| | |
|---|---|
| **Como** | [papel/persona do usuário] |
| **Quero** | [a funcionalidade ou ação desejada] |
| **Para** | [o benefício ou resultado de negócio esperado] |

---

## 3. Escopo

[1 parágrafo curto (~3 frases): o que a entrega cobre concretamente — funcionalidade, acesso e
principais comportamentos, em resumo. Sem lista exaustiva nem repetir CAs/regras. Apenas o que
está dentro do escopo. **bold** em 1–2 termos-chave.]

---

## 4. Critérios de Aceitação

Cenário Dado/Quando/Então, **coesos** (agrupam o relacionado), comportamento de tela embutido,
referenciando regras/mensagens/globais por código.

### 4.1. [Nome da Subseção]

- **CA01:** **Dado que** [contexto], **Quando** [ação], **Então** [resultado observável]. [RN_01]
- **CA02:** **Dado que** [contexto], **Quando** [ação], **Então** [resultado]. [MSG_01] [RN_01]

### 4.2. [Nome da Subseção]

- **CA03:** **Dado que** [contexto], **Quando** [ação], **Então** [resultado]. [GL_01]

---

## 5. Regras de Negócio

Formato SBVR, linguagem de negócio, numeração local à issue (reinicia em `01`). Texto completo,
**sem título** (a frase SBVR já se descreve).

- **RN_01** — [É necessário/proibido/obrigatório que… / … é calculado como…]
- **RN_02** — [frase SBVR]

---

## 6. Mensagens

Numeração local à issue. Tipo + texto literal.

- **MSG_01** (Erro) — "[texto exato]"
- **MSG_02** (Sucesso) — "[texto exato com <Placeholder> se dinâmico]"

---

## 7. Referências Globais

Só o que a issue referencia. O conteúdo do GL vive no doc do Drive (read-only). Nenhuma → `- N/A`.

- **GL_01 — [Título]** — usado em CA03. (ver Referencias-Globais.md — Drive)

---

## 8. Protótipo

Títulos por fluxo e links das rotas vêm da skill `prototype-prints`; as **imagens** o usuário
cola à mão.

### 8.1. [Nome do fluxo]

**Link:** [url da rota do fluxo]

#### 8.1.1. [O que a print mostra]

---

## 9. Complemento de Documentação

Só links. O doc de regras o usuário preenche à mão; os links do protótipo vêm da skill
`prototype-prints` (mesmos links da seção 8 — repetidos aqui porque no `.md` a seção 8 fica só
com títulos, sem imagem).

**Documento de Regras de Negócio:** [Vazio — preenchido manualmente pelo usuário.]

**Link do Protótipo de Telas Impactadas:**

- **[Nome do fluxo]:** [url da rota do fluxo]

---

## Apêndices (não vão para o `.docx`)

- `## Apêndice — Trilha de Discovery` — registro D1a→D2b + priorização.
- `## Apêndice — Novas Referências Globais (copiar para o Drive)` — conteúdo de GLs novos a
  promover manualmente no Drive, ou "Nenhuma."
