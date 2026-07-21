---
name: doc-consolidator
description: >
  Gera o documento .md consolidado de uma issue, fonte de verdade única que reúne a descrição
  da funcionalidade + Critérios de Aceitação coesos + Regras de Negócio (SBVR) + Mensagens +
  Referências Globais + trilha de discovery. Use para pedidos genéricos como "documenta a #NNN",
  "gera a documentação", "consolida", "gera o md", "monta o documento base", "cria as regras da
  #NNN" ou "centraliza discovery e regras". Escreve as regras direto no .md (não há mais arquivo
  de regras separado nem skill gerar-regras). Gera somente o `.md` em `outputs/{ID}_{NomeCurto}/`
  e PARA para revisão humana. Nunca segue para `.docx`, que é passo separado com `hu-generator`
  ou `ht-generator`, só após revisão e pedido explícito.
---

# Doc Consolidado (.md)

> **Valores de projeto** (Cliente, Projeto, Responsável, token de arquivo, URL de issues,
> caminhos) vêm de **`project-config.md`**. Campo em branco lá → use o placeholder
> indicado (`[ASSIM]`) no `.md` gerado.

Gera o **documento de verdade** de uma issue: um único `.md` **autocontido** que centraliza a
descrição da funcionalidade + Critérios de Aceitação + Regras de Negócio + Mensagens +
Referências Globais + trilha de discovery. É a **base** do `.docx`.

**Não existe mais** `{ID}_regras.md` separado nem a skill `gerar-regras`: as regras (RN),
mensagens (MSG) e referências globais (GL) são escritas **direto nas seções 5, 6 e 7 deste `.md`**,
com numeração **local por issue** (RN/MSG) ou **referência ao doc do Drive** (GL). Consulte o
rigor de classificação em **`references/regras.md`**.

**Divisão de trabalho (motivo desta skill existir):**
- **Modelo pesado** → escreve este `.md` (pensa o conteúdo: CA coeso, RN em SBVR, MSG, GL).
- **Modelo leve** → roda `hu-generator`/`ht-generator`, que só **transcreve** este `.md` para
  `.docx` (trabalho mecânico de formatação/script).

**SEMPRE gere `.md`. Nunca `.docx` aqui.**

---

## 1. Fluxo

### Passo 0 — GitLab desabilitado?

Se `GITLAB_ENABLED` no `.env` não for `true`: pule o Passo 1 (`glab issue view`/notes). A fonte vira só `history/discoveries/*` + `docs/context_docs/`. Sem número de issue, peça ao usuário o conteúdo do discovery ou a descrição da demanda direto. O `.md` gerado continua indo para `outputs/{ID}_{NomeCurto}/` normalmente.

### Passo 1 — Carregar todo o material da issue

```bash
# Issue
glab issue view NNN -R ${GITLAB_REPO}

# Comentários do discovery (D1a, D1b, D2a, D2b)
glab api "projects/${GITLAB_REPO//\//%2F}/issues/NNN/notes" --paginate \
  | jq -r '.[] | select(.body | test("\\[D1|\\[D2")) | .body'
```

Também ler, se existirem:
- `history/discoveries/*issue-NNN*` — registro consolidado do discovery (material bruto,
  com marcadores `[→CA]` / `[→RN]` / `[→MSG]` / `[→GL candidato]`).
- `docs/context_docs/md/Referencias-Globais.md` — doc de Referências Globais (Drive, read-only).
- `docs/context_docs/md/Outros/` — contexto diverso do produto (persona, glossário, decisões), **se existir**.
- `docs/context_docs/` — ONEPAGE, metadados de projeto/cliente/OS.

**Se não houver D2b** (nem na issue, nem em `history/discoveries/`): pare e avise
"Discovery não concluído até D2b — não há material para consolidar. Rode o discovery primeiro."

### Passo 2 — Determinar HU ou HT

- Tem persona / usuário final impactado por uma tela ou ação → **HU** (9 seções).
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

### Passo 4a — Ler o catálogo global (só para REUSAR)

Antes de escrever, leia o doc de Referências Globais **uma vez**, com um único objetivo:
**ver se já existe um GL que dá para reutilizar** nesta issue. Nada de decidir promoção aqui.

- Doc: `docs/context_docs/md/Referencias-Globais.md` — **read-only** (sincronizado do Drive;
  escrever lá perde no sync).
- **Se existir e um conceito da issue já é um GL de lá** → nas seções 4/7 referencie `[GL_0X]`
  em vez de escrever regra local.
- **Se o arquivo NÃO existir** → catálogo global **vazio**. Não há GL a reusar; **tudo nasce
  local**. **Proibido** usar qualquer exemplo de `outputs/` (ex.: `EXEMPLO_referencias-globais.md`)
  como se fosse catálogo — exemplo não é fonte de verdade.

### Passo 4b — Escrever CA, Regras, Mensagens (seções 4, 5, 6) — tudo LOCAL

Este é o trabalho de conteúdo. Siga **`references/regras.md`** à risca. **Escreva todas as regras
como LOCAIS (RN/MSG)**, exceto as que reusam um GL existente do Passo 4a. A decisão de *promover*
uma local a global é uma fase **posterior** (Passo 5) — não misture aqui.

- **Seção 4 — Critérios de Aceitação:** cenário Dado/Quando/Então, **coesos** (agrupam o
  relacionado, separam o não-relacionado), comportamento de tela embutido, referenciando
  `[RN_0X]` / `[MSG_0X]` / `[GL_0X]` por número. Nunca escreva a mensagem ou a fórmula dentro do
  CA — só o código.
- **Seção 5 — Regras de Negócio:** só o que carrega fórmula/política/invariante que o CA não
  tem. Formato **SBVR** (*É necessário/proibido/obrigatório que… / é calculado como*),
  linguagem de negócio (entidade+atributo, nunca "campo/botão/tela"). Numeração **local**
  `RN_01…RN_N`, reinicia por issue. Texto completo mora aqui.
- **Seção 6 — Mensagens:** seção própria, numeração **local** `MSG_01…MSG_N`, tipo + texto
  literal. Nunca inline no CA.
- **Não há mais RA.** Comportamento de tela virou CA. Não existe seção "Descrição de
  Interface" nem "Complemento de Documentação".

### Passo 5 — Revisão de promoção a GL (só DEPOIS do doc completo)

Com o documento já escrito com regras locais, **releia as RNs** e pergunte, uma a uma: esta
regra merece virar global? Aqui vale o critério de **prova**, não de suposição:

- **Promove** só com **2+ consumidores REAIS** — issues de fato documentadas que usam o mesmo
  conceito — **ou** por ser enum/fluxo/status estrutural do sistema. Exemplo fictício ou de
  demonstração **não conta como prova**.
- **1º consumidor real** (a issue atual é a primeira que usa o conceito) → **fica LOCAL** e você
  **marca "candidato a GL"** numa nota — não promove sozinho o primeiro. Promove quando o 2º
  consumidor real aparecer.
- **Promoveu (tem prova)** → **não escreva o doc do Drive**. Em vez disso:
  - referencie `[GL_0X]` (número = última do doc + 1, sugerido) nas seções 4/7;
  - traga o **conteúdo completo** do GL no apêndice **"Novas Referências Globais — copiar para o
    Drive"** (o `.docx` ignora esse apêndice; você cola no Drive depois).

Regra nova **nasce local**; promoção é revisão pós-escrita, com prova real. Não globalizar por
suposição nem com base em exemplo.

---

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
8. **Todo o texto em PT-BR acentuado** (acentos + ç), sem ASCII chapado ("Medicao"→"Medição", "e necessario"→"é necessário")? Ver ENGAGEMENT §7.

Se algo falhar, **reescreva no formato** antes de fechar o `.md`.

### Passo 6 — Escrever o `.md`

Salvar em `outputs/{ID}_{NomeCurto}/{HU|HT}{ID}_{TOKEN}_{NomeCurto}.md` (TOKEN = `Token de
arquivo` do project-config). Estrutura exata na Seção 2 (HU) ou Seção 3 (HT).

### Passo 7 — Apresentar e confirmar

Resumir ao usuário: seções preenchidas, nº de RN/MSG, GLs referenciados/promovidos, caminho do
arquivo. Se houve GL novo, avise que o apêndice "Novas Referências Globais" precisa ser colado no
Drive. Só então o `.md` está pronto para virar `.docx` (modelo leve).

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
<!-- SEMPRE vazia — placeholder para as PRINTS das telas do protótipo (imagens) e os links das
     rotas por fluxo. Títulos e links são preenchidos pela skill prototype-prints; as imagens, o
     usuário cola à mão. Nunca auto-preencher com notas do discovery. -->

[Vazio — títulos e links preenchidos pela skill prototype-prints; prints coladas manualmente.]

## 9. Complemento de Documentação
<!-- SEMPRE vazia — só o placeholder, para o usuário preencher. Nunca auto-preencher. -->

**Documento de Regras de Negócio:** [Vazio — preenchido manualmente pelo usuário.]

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

## 4. Regras de ouro

1. **Este `.md` é a fonte de verdade e é autocontido.** O `.docx` é derivado dele. RN e MSG
   têm o texto completo aqui — não há arquivo de regras separado.
2. **Numeração local por issue** para RN e MSG (`RN_01…`, `MSG_01…`, reinicia por issue). GL é
   global e vive no Drive (read-only) — a issue só referencia.
3. **Sem RA, sem "Descrição de Interface", sem "Complemento de Documentação".** Comportamento de
   tela vira CA.
4. **CA coeso e referencia por código** — nunca escreve mensagem/fórmula inline.
5. **Doc de Referências Globais é read-only** — GL novo vai no apêndice "copiar para o Drive",
   nunca escrito direto no arquivo do Drive.
6. **Apêndice de discovery é obrigatório** — registro do processo.
7. **Seção 7 (Referências Globais):** GLs por bullet; nenhuma → um único `- N/A` (sem prosa).
8. **Seções 8 (Protótipo) e 9 (Complemento de Documentação):** SEMPRE vazias, só os placeholders
   — o usuário preenche. Nunca colar notas de protótipo/regras do discovery aqui.
9. Rigor de classificação completo em **`references/regras.md`**.
