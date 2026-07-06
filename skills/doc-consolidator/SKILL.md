---
name: doc-consolidator
description: >
  Gera o documento .md consolidado de uma issue, fonte de verdade que reúne discovery
  D1a→D2b, regras RN/RA/MSG por rótulo e o padrão de `project-config.md`. Use para pedidos
  genéricos como "documenta a #NNN", "gera a documentação", "consolida", "gera o md",
  "monta o documento base" ou "centraliza discovery e regras". Gera somente o `.md` em
  `outputs/{ID}_{NomeCurto}/` e PARA para revisão humana. Nunca segue para `.docx`, que é um
  passo separado com `hu-generator` ou `ht-generator`, somente após revisão e pedido explícito.
  O `.md` espelha as seções HU/HT, contém os rótulos das regras e o apêndice de discovery; as
  descrições completas permanecem em `{ID}_regras.md`.
---

# Doc Consolidado (.md)

> **Valores de projeto** (Cliente, Projeto, Responsável, token de arquivo, URL de issues,
> caminhos) vêm de **`project-config.md`**. Campo em branco lá → use o placeholder
> indicado (`[ASSIM]`) no `.md` gerado.

Gera o **documento de verdade** de uma issue: um único `.md` que centraliza descrição completa
da funcionalidade + regras (só rótulo/título) + trilha de discovery. É a **base** do `.docx`.
A descrição completa de cada regra mora só em `{ID}_regras.md`.

**Divisão de trabalho (motivo desta skill existir):**
- **Modelo pesado** → escreve este `.md` (pensa o conteúdo, consolida discovery + regras).
- **Modelo leve** → roda `hu-generator`/`ht-generator`, que só **transcreve** este `.md` para `.docx` (trabalho mecânico de formatação/script).

**SEMPRE gere `.md`. Nunca `.docx` aqui.**

---

## 1. Fluxo

### Passo 1 — Carregar todo o material da issue

```bash
# Issue
glab issue view NNN -R ${GITLAB_REPO}

# Comentários do discovery (D1a, D1b, D2a, D2b)
glab api "projects/${GITLAB_REPO//\//%2F}/issues/NNN/notes" --paginate \
  | jq -r '.[] | select(.body | test("\\[D1|\\[D2")) | .body'
```

Também ler, se existirem:
- `history/discoveries/*issue-NNN*` — registro consolidado do discovery
- `outputs/{ID}_*/{ID}_regras.md` — regras já formalizadas (RN/RA/MSG) na pasta da issue
- `docs/context_docs/` — ONEPAGE, metadados de projeto/cliente/OS

**Se não houver D2b** (nem na issue, nem em `history/discoveries/`): pare e avise
"Discovery não concluído até D2b — não há material para consolidar. Rode o discovery primeiro."

### Passo 2 — Determinar HU ou HT

- Tem persona / usuário final impactado por uma tela ou ação → **HU** (7 seções).
- Demanda técnica, sem persona (infra, refactor, migração, débito) → **HT** (6 seções).
- Em dúvida, pergunte ao usuário.

### Passo 3 — Coletar metadados do cabeçalho

Leia os valores em `project-config.md`. **Campo em branco no config → use o placeholder.**

| Campo | Origem | Se vazio |
|---|---|---|
| Cliente | project-config → Cliente | `[CLIENTE]` |
| Projeto | project-config → Projeto (ou context_docs) | `[PROJETO]` |
| Ordem de Serviço | issue / project-config | `[OS]` |
| Épico/Tema | issue / perguntar | `[EPICO]` |
| Identificação (HU/HT ID + nome) | usuário | — |
| Responsável | project-config → Responsável padrão | `[RESPONSÁVEL]` |
| Data de Emissão | hoje | data de hoje |

### Passo 4 — Consolidar as regras (só rótulo/título na Seção 5)

Na Seção 5 do `.md` entra **só o rótulo** de cada regra (`RN_XXXX — Título curto`), igual ao `.docx`.
A descrição completa (invariantes, consequências, texto integral) fica **exclusivamente** em
`{ID}_regras.md` — não repita a descrição na Seção 5.

1. Se já houver `outputs/{ID}_*/{ID}_regras.md`, use-o como fonte das regras.
2. Se não houver, **carregue a skill `gerar-regras`** e proponha as regras a partir do D2b,
   itere com o usuário, e **salve** em `outputs/{ID}_{NomeCurto}/{ID}_regras.md` antes de fechar o `.md`.
3. Numeração oficial = última de `docs/context_docs/md/Regras/` + 1 (md/Regras, sincronizado do Drive, é a fonte da verdade).
4. **Regras existentes referenciadas (obrigatório):** leia o documento de regras `docs/context_docs/md/Regras/`
   e identifique as RN/RA/MSG **já existentes** que se aplicam à demanda (mesmo módulo/fluxo), mas que
   **não** estão sendo criadas/editadas nesta HU. Liste-as no 4º bloco da Seção 5 ("Regras existentes
   referenciadas"), só o rótulo (`- **RN_XXXX — Título curto**`), sem explicação de como se aplica.
   Objetivo: rastreabilidade — o leitor vê quais regras governam a demanda sem reescrevê-las. Nenhuma
   aplicável → bullet `- N/A`.

Ver o **Contrato de formato do `.md`** abaixo — o gerador do `.docx` depende dele.

---

## ⚠️ Contrato de formato do `.md` — OBRIGATÓRIO (o gerador do `.docx` depende disto)

O `generate_doc.py` faz parsing **por padrão de linha**. Se a autoria fugir destes formatos, o `.docx`
sai errado (perde blocos, vaza conteúdo ou ignora a seção). Siga **exatamente**:

| Bloco | Formato EXATO | Erro comum (não faça) |
|---|---|---|
| **Frontmatter** | 1ª linha `---`, com `tipo: HU` ou `tipo: HT`, fecha com `---` | Omitir `tipo:` → header do `.docx` sai com rótulo errado |
| **Metadados** | `## Metadados` e abaixo `- **Campo:** valor` (rótulo em negrito + `:`) | `Campo: valor` sem `- **…:**` → linha ignorada |
| **Cabeçalho de seção** | `## N. Título` (número + ponto) ou `## Apêndice — …` | `## Regras` (sem número) → **seção não é reconhecida**, conteúdo gruda na seção anterior |
| **Subseção** | `### Título` | — |
| **Tabela 2 colunas** | `\| **Rótulo** \| valor \|` (1ª célula em negrito) | célula sem `**…**` → linha não vira tabela |
| **Critério de aceite** | `- **CANN:** texto` (colado: `CA` + número + `:` dentro do negrito) | `- **CA 01 -**` / `- CA01:` → perde o estilo de CA |
| **Regra (RN/RA/MSG)** | `- **CODE — Título**` (só rótulo, sem descrição) | ver bloco abaixo |
| **Bullet comum** | `- texto` | — |
| **Parágrafo** | linha normal (não começa com `#`, `\|`, `-`) | — |

### Seção 5 (Regras) — o ponto mais sensível

Aqui entra **só o rótulo** de cada regra — sem descrição, sem invariantes, sem consequências. A
descrição completa mora em `{ID}_regras.md`; a Seção 5 é um **índice**. Os **4 cabeçalhos de grupo
são fixos** (texto exato) e cada regra é **um único bullet**:

```
**Regras de Negócio (RN) criadas ou editadas nesta HU:**
- **RN_XXXX — Título curto**
- **RN_YYYY — Outro título**

**Regras de Apresentação (RA) criadas ou editadas nesta HU:**
- N/A

**Mensagens do Sistema (MSG) criadas ou editadas nesta HU:**
- **MSG_XX — Título curto**

**Regras existentes referenciadas (aplicáveis a esta HU, não alteradas):**
- **RN_ZZZZ — Título curto**
```

- ✅ Os **4 cabeçalhos** aparecem SEMPRE, com o texto exato: `**Regras de Negócio (RN) criadas ou editadas nesta HU:**`, `**Regras de Apresentação (RA) criadas ou editadas nesta HU:**`, `**Mensagens do Sistema (MSG) criadas ou editadas nesta HU:**`, `**Regras existentes referenciadas (aplicáveis a esta HU, não alteradas):**`. Em negrito, nunca `###`.
- ✅ O 4º bloco vem das regras já existentes em `docs/context_docs/md/Regras/` que se aplicam à demanda (ver Passo 4.4) — referência, não recriação.
- ✅ Cada regra = **um bullet** `- **CODE — Título**` (CODE = `RN_`/`RA_`/`MSG_`); rótulo inteiro em `**negrito**`, sem `:` nem texto depois.
- ✅ Grupo sem item → um único bullet `- N/A` (mantém a divisão).
- 🚫 **NUNCA** regra como subtítulo `### RN_XXXX …`.
- 🚫 **NUNCA** incluir descrição, invariantes ou consequências após o rótulo — nem inline, nem em sub-bullet, nem em parágrafo abaixo. Só o rótulo.

### Auto-checagem antes de salvar o `.md`

1. Toda seção numerada é `## N. …`? (nenhuma `## Título` sem número)
2. Metadados em `- **Campo:** valor`?
3. CAs em `- **CANN:** …`?
4. Seção 5: nenhuma linha `### RN_/RA_/MSG_`, toda citação de código começa com `- **` e termina no rótulo (sem `:` nem descrição depois)?
5. Apêndice de discovery presente como `## Apêndice — …` (o gerador o exclui do `.docx` sozinho)?

Se algo falhar, **reescreva no formato** antes de fechar o `.md`.

### Passo 5 — Escrever o `.md`

Salvar em `outputs/{ID}_{NomeCurto}/{HU|HT}{ID}_{TOKEN}_{NomeCurto}.md` (TOKEN = `Token de arquivo` do project-config; mesma pasta da issue onde ficam `{ID}_regras.md` e o `.docx`).
Estrutura exata na Seção 2 (HU) ou Seção 3 (HT).

### Passo 6 — Apresentar e confirmar

Resumir ao usuário: seções preenchidas, nº de regras, caminho do arquivo. Só então o `.md` está
pronto para virar `.docx` (modelo leve).

---

## Princípio editorial da HU — foco no PROBLEMA, não na solução

A HU descreve **o problema, a necessidade e o valor** — não a implementação. As HUs estão saindo
longas e centradas na solução; corrija isso na origem:

- **Seções 1–3** (Entendendo o Problema, História de Usuário, Escopo) falam do **porquê** e do **o quê**
  na ótica do usuário. **Nunca** prescrevem o **como** (telas, campos, fluxos, lógica, passos, tecnologia).
- O **como** mora nos **Critérios de Aceite** (comportamento verificável), nas **Regras** (lógica) e no
  **protótipo** (visual). Não antecipe nada disso nas seções de problema.
- **Enxuto:** seções 1–3 são curtas (poucas frases cada). Prosa longa descrevendo a solução = sinal de
  erro → corte e mova o conteúdo para CA/regra, ou deixe para o protótipo.

- ✅ Problema (seção 1): *"o gestor não tem como saber se um cronograma ficou inconsistente após uma alteração, e hoje revisa tudo manualmente."*
- ❌ Solução vazando na descrição: *"adicionar um ícone ⚠ no cabeçalho que ao clicar abre um modal listando os aditivos afetados com…"* → isso é CA/protótipo, não vai na seção de problema.

Regra prática: se um parágrafo das seções 1–3 responde "como o sistema faz", ele está no lugar errado.

## 2. Estrutura do `.md` — HU (7 seções + apêndice)

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

## 1. Entendendo o Problema

**Persona:** [perfil exato, ex: Engenheiro (GEENG)]

**Cenário do Usuário (Dor):** [2–4 frases, foco na dor, sem mencionar solução]

## 2. História de Usuário

| | |
|---|---|
| **Como** | [papel/persona] |
| **Quero** | [funcionalidade desejada] |
| **Para** | [benefício de negócio] |

## 3. Escopo

[1 parágrafo curto (~3 frases), nível RESUMO concreto (ver exemplos). Descreva o que a entrega cobre: a funcionalidade, o ponto de acesso e os principais comportamentos/blocos. Pode citar os componentes principais de forma compacta (ex: "dados contratuais, cronograma, resumo de impactos"), mas SEM lista exaustiva campo-a-campo e SEM repetir verbatim os CAs/regras. **Apenas o que está DENTRO do escopo** — não descreva o que fica de fora. **bold** em 1–2 termos-chave.]

## 4. Critérios de Aceitação

### 4.1. [Subseção temática]
- **CA01:** **Dado que** [...], **Quando** [...], **Então** [...].
- **CA02:** **Dado que** [...], **Quando** [...], **Então** [...].

### 4.2. [Subseção temática]
- **CA03:** **Dado que** [...], **Quando** [...], **Então** [...].

## 5. Regras
<!-- FORMATO OBRIGATÓRIO (ver Contrato no Passo 4): os 4 cabeçalhos de grupo SEMPRE presentes, com o
     texto EXATO abaixo (em **negrito**, nunca `###`). Cada regra = 1 bullet `- **CODE — Título**`,
     SÓ o rótulo, sem descrição. Descrição completa fica em {ID}_regras.md. Grupo sem item → um único
     bullet `- N/A`. -->

**Regras de Negócio (RN) criadas ou editadas nesta HU:**
- **RN_XXXX — [Título curto]**

**Regras de Apresentação (RA) criadas ou editadas nesta HU:**
- **RA_XXXX — [Título curto]**

**Mensagens do Sistema (MSG) criadas ou editadas nesta HU:**
- **MSG_XX — [Título curto]**

**Regras existentes referenciadas (aplicáveis a esta HU, não alteradas):**
- **RN_XXXX — [Título curto]**

## 6. Descrição de Interface

[Vazio — preenchido manualmente pelo usuário. Manter o heading.]

## 7. Complemento de Documentação

- **Documento de Regras de Negócio:** [Vazio — preenchido manualmente pelo usuário.]
- **Link do Protótipo de Telas Impactadas:** [Vazio — preenchido manualmente pelo usuário.]

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
````

---

## 3. Estrutura do `.md` — HT (6 seções + apêndice)

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
[1 parágrafo curto (~3 frases), nível RESUMO concreto. Descreva o que a entrega cobre — o que muda e os principais comportamentos. Compacto; SEM lista exaustiva nem repetir verbatim os CAs/seções seguintes. **Apenas o que está DENTRO do escopo** — não descreva o que fica de fora. **bold** em 1–2 termos-chave.]

## 4. Critérios de Aceite
- **CA01:** **Dado que** [...], **Quando** [...], **Então** [...].
- **CA02:** **Dado que** [...], **Quando** [...], **Então** [...].

## 5. Dependências e restrições
[pré-requisitos / limitações; "N/A" se não houver]

## 6. O que será afetado?
[sistemas/telas/serviços impactados; "N/A" se não houver]

---

## Apêndice — Trilha de Discovery
[D1a / D1b / D2a / D2b resumidos + priorização final]
````

> HT normalmente não tem seção de regras. Se a demanda técnica gerar RN/RA/MSG, liste-as no
> apêndice só por rótulo (mesmo formato da HU) — descrição completa fica em `{ID}_regras.md`.

---

## 4. Regras de ouro

1. **Este `.md` é a fonte de verdade.** O `.docx` é derivado dele — nunca o contrário.
2. **Seção 5 do `.md` leva só o rótulo** (`RN_XXXX — Título`), igual ao `.docx`. Descrição completa
   (invariantes, consequências, texto integral) fica exclusivamente em `{ID}_regras.md`.
3. **Seção 5 tem sempre os 4 cabeçalhos de grupo** (RN/RA/MSG criadas/editadas + Regras existentes referenciadas, texto exato). Grupo sem item → bullet `- N/A`. Nunca omita um grupo. O 4º bloco sai da leitura de `docs/context_docs/md/Regras/` (regras aplicáveis à demanda).
4. **Apêndice de discovery é obrigatório** — é o registro do processo (decisão do usuário).
5. **Não pule o salvamento das regras** em `outputs/{ID}_{NomeCurto}/{ID}_regras.md` quando criadas do zero.
6. **Seção 7 (Complemento de Documentação) sempre em branco** — os dois campos (Documento de Regras
   de Negócio, Link do Protótipo) levam `[Vazio — preenchido manualmente pelo usuário.]`, mesmo que o
   caminho de `{ID}_regras.md` já seja conhecido. Nunca auto-preencher.
