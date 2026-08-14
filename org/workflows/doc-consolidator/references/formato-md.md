# Contrato de formato do .md consolidado

O `generate_doc.py` (provider docs-output) faz parsing por padrão de linha — fugir do
formato = `.docx` errado. Estruturas completas de HU (9 seções) e HT (6 seções) abaixo.

## ⚠️ Contrato de formato do `.md` — OBRIGATÓRIO (o gerador do `.docx` depende disto)

O `generate_doc.py` faz parsing **por padrão de linha**. Se a autoria fugir destes formatos, o
`.docx` sai errado. Siga **exatamente**:

| Bloco | Formato EXATO | Erro comum (não faça) |
|---|---|---|
| **Frontmatter** | 1ª linha `---`, com `tipo: HU` ou `tipo: HT`, fecha com `---` | Omitir `tipo:` → header do `.docx` com rótulo errado |
| **Metadados** | `## Metadados` e abaixo `- **Campo:** valor` (rótulo em negrito + `:`) | `Campo: valor` sem `- **…:**` → linha ignorada |
| **Cabeçalho de seção** | `## N. Título` (número + ponto) ou `## Apêndice — …` | `## Regras` (sem número) → seção não reconhecida |
| **Subseção** | `### Título` | — |
| **Tabela 2 colunas** | `\| **Rótulo** \| valor \|` (1ª célula em negrito) | célula sem `**…**` → linha não vira tabela |
| **Critério de aceite** | `- **CANN:** **Dado que** … **Quando** … **Então** … [RN_0X] [MSG_0X]` | `- **CA 01 -**` / `- CA01:` → perde o estilo de CA |
| **Regra de Negócio** | `- **RN_0X** — <frase SBVR>` (sem título; texto completo) | escrever título repetindo a frase |
| **Mensagem** | `- **MSG_0X** (Tipo) — "texto"` | — |
| **Ref. Global** | `- **GL_0X — Título** — usado em CA_NN.` | — |
| **Bullet comum** | `- texto` | — |
| **Parágrafo** | linha normal (não começa com `#`, `\|`, `-`) | — |

**Referências nos CAs** (`[RN_01]`, `[MSG_02]`, `[GL_03]`): texto normal, entre colchetes, **sem
crase**, no fim da linha do CA. O gerador as renderiza como texto literal.

**Apêndices** (`## Apêndice — …`, incluindo "Novas Referências Globais — copiar para o Drive")
são cortados do `.docx` automaticamente.

### Auto-checagem antes de salvar o `.md`

1. Toda seção numerada é `## N. …`? (nenhuma `## Título` sem número)
2. Metadados em `- **Campo:** valor`?
3. CAs em `- **CANN:** **Dado que** … **Quando** … **Então** …`, **coesos** (agrupam o relacionado, separam o não-relacionado)?
4. Nenhuma mensagem/fórmula escrita dentro de um CA — só `[RN_0X]`/`[MSG_0X]`/`[GL_0X]`?
5. RN em SBVR, sem vocabulário de tela (`campo/botão/tela/exibir/tempo real`)?
6. RN e MSG com numeração local reiniciando em `01`?
7. Apêndices como `## Apêndice — …`?
8. **Todo o texto em PT-BR acentuado** (acentos + ç), sem ASCII chapado ("Medicao"→"Medição", "e necessario"→"é necessário")? Ver `org/ORG.md` §1.

Se algo falhar, **reescreva no formato** antes de fechar o `.md`.

---

## Princípio editorial da HU — foco no PROBLEMA, não na solução

A HU descreve **o problema, a necessidade e o valor** — não a implementação:

- **Seções 1–3** (Problema, História, Escopo) falam do **porquê** e do **o quê** na ótica do
  usuário. **Nunca** prescrevem o **como** (telas, campos, fluxos, lógica, passos, tecnologia).
- O **como** mora nos **Critérios de Aceitação** (comportamento verificável), nas **Regras**
  (lógica) e no **protótipo** (visual).
- **Enxuto:** seções 1–3 curtas (poucas frases cada). Prosa longa descrevendo solução = erro →
  mova para CA/regra ou protótipo.

- ✅ Problema: *"o gestor não sabe se um cronograma ficou inconsistente após uma alteração, e
  hoje revisa tudo manualmente."*
- ❌ Solução vazando: *"adicionar um ícone ⚠ que ao clicar abre um modal listando os aditivos…"*
  → isso é CA/protótipo.

---

## 2. Estrutura do `.md` — HU (9 seções + apêndices)

````markdown
---
tipo: HU
issue: NNN
issue_url: [URL]
modulo: [módulo]
data: YYYY-MM-DD
---

# [HU_ID] - [HU_NOME]

## Metadados
- **Cliente:** [CLIENTE]
- **Projeto:** [PROJETO]
- **Ordem de Serviço:** [OS]
- **Épico/Tema:** [EPICO_ID] - [EPICO_NOME]
- **Identificação da HU:** [HU_ID] - [HU_NOME]
- **Responsável:** [RESPONSÁVEL]
- **Data de Emissão:** DD/MM/AAAA

## 1. Problema

**Persona:** [perfil exato, ex: Engenheiro (GEENG)]

**Cenário do Usuário (Dor):** [2–4 frases, foco na dor, sem mencionar solução]

## 2. História de Usuário

| | |
|---|---|
| **Como** | [papel/persona] |
| **Quero** | [funcionalidade desejada] |
| **Para** | [benefício de negócio] |

## 3. Escopo

[1 parágrafo curto (~3 frases), nível resumo concreto: o que a entrega cobre, o ponto de
acesso e os principais comportamentos/blocos. SEM lista exaustiva campo-a-campo, SEM repetir
verbatim os CAs/regras. **Apenas o que está DENTRO do escopo.** **bold** em 1–2 termos-chave.]

## 4. Critérios de Aceitação

### 4.1. [Subseção temática]
- **CA01:** **Dado que** [contexto], **Quando** [ação], **Então** [resultado observável]. [RN_01]
- **CA02:** **Dado que** [contexto], **Quando** [ação], **Então** [resultado]. [MSG_01] [RN_01]

### 4.2. [Subseção temática]
- **CA03:** **Dado que** [contexto], **Quando** [ação], **Então** [resultado]. [GL_01]

## 5. Regras de Negócio

- **RN_01** — [Frase SBVR: É necessário/proibido/obrigatório que… / … é calculado como…]
- **RN_02** — [Frase SBVR]

## 6. Mensagens

- **MSG_01** (Erro) — "[texto exato]"
- **MSG_02** (Sucesso) — "[texto exato com <Placeholder> se dinâmico]"

## 7. Referências Globais
<!-- GLs reusados/promovidos, um por bullet. NENHUMA → um único bullet `- N/A` (sem prosa
     explicando catálogo ausente). -->

- **GL_01 — [Título]** — usado em CA03. (ver Referencias-Globais.md — Drive)

## 8. Protótipo
<!-- SEMPRE `N/A` na geração inicial. Títulos e links das rotas por fluxo são preenchidos depois
     pela skill prototype-prints; as imagens são inseridas no DOCX pela ação `gerar-documento-final`.
     Nunca auto-preencher com notas do discovery. -->

N/A

## 9. Complemento de Documentação
<!-- Regras Global: valor literal de `recursos.url_documento_regras_global` do project-config.yaml;
     campo vazio no config → `N/A`. Link do Protótipo: SEMPRE `N/A` na geração inicial — a skill
     prototype-prints substitui pelos bullets por fluxo (mesmos links da seção 8, duplicados aqui
     porque no .md a seção 8 não tem imagem). Nunca auto-preencher nenhum dos dois. -->

**Documento de Regras Global:** {recursos.url_documento_regras_global | N/A}

**Link do Protótipo de Telas Impactadas:** N/A

---

## Apêndice — Trilha de Discovery

### D1a · Exploração do Problema
[resumo: afetados, contexto, hipóteses, perguntas em aberto]

### D1b · Definição do Problema
[problem statement, causa raiz, critérios de sucesso, non-goals, MoSCoW+I+C]

### D2a · Exploração das Soluções
[soluções candidatas com trade-offs]

### D2b · Definição da Solução
[solução escolhida, fluxo do sistema, telas/campos, ICE completo]

### Priorização final
MoSCoW: [...] | ICE: I[..] × C[..] × F[..] | Quadrante: [...]

## Apêndice — Novas Referências Globais (copiar para o Drive)

[Conteúdo completo de cada GL novo promovido nesta issue, no formato do doc do Drive, pronto
para colar. Se nenhum GL novo: "Nenhuma."]
````

---

## 3. Estrutura do `.md` — HT (6 seções + apêndices)

````markdown
---
tipo: HT
issue: NNN
issue_url: [URL]
modulo: [módulo]
data: YYYY-MM-DD
---

# [HT_ID] - [HT_NOME]

## Metadados
- **Cliente:** [CLIENTE]
- **Projeto:** [PROJETO]
- **Ordem de Serviço:** [OS]
- **Épico/Tema:** [EPICO_ID] - [EPICO_NOME]
- **Identificação da HT:** [HT_ID] - [HT_NOME]
- **Responsável:** [RESPONSÁVEL]
- **Data de Emissão:** DD/MM/AAAA

## 1. Por que precisamos disso
[2–4 frases, foco no problema/necessidade, impacto de não fazer]

## 2. O que deve ser feito

| | |
|---|---|
| **Sistema/Área** | [parte do sistema afetada] |
| **O que fazer** | [ação principal] |
| **Por quê** | [benefício para sistema/time] |

## 3. Escopo
[1 parágrafo curto (~3 frases), nível resumo concreto. **Apenas o que está DENTRO do escopo.**]

## 4. Critérios de Aceite
- **CA01:** **Dado que** [...], **Quando** [...], **Então** [...]. [RN_01]
- **CA02:** **Dado que** [...], **Quando** [...], **Então** [...].

## 5. Dependências e restrições
[pré-requisitos / limitações; "N/A" se não houver]

## 6. O que será afetado?
[sistemas/telas/serviços impactados; "N/A" se não houver]

---

## Apêndice — Trilha de Discovery
[D1a / D1b / D2a / D2b resumidos + priorização final]

## Apêndice — Regras de Negócio (se houver)
<!-- HT normalmente não tem regras. Se gerar, mesmo formato/rigor da HU (SBVR, local RN_01…),
     texto completo aqui — não vai pro .docx. Senão: "Nenhuma." -->
- **RN_01** — [Frase SBVR]

## Apêndice — Novas Referências Globais (copiar para o Drive)
[GLs novos, ou "Nenhuma."]
````

---

