---
name: hu-generator
description: >
  Passo FINAL da documentação: transcreve um `.md` consolidado JÁ REVISADO (gerado pela skill doc-consolidator) para um `.docx` de História de Usuário — 7 seções (Entendendo o Problema, História de Usuário, Escopo, Critérios de Aceitação, Regras de Negócio, Descrição de Interface, Complemento de Documentação). Use SOMENTE quando o usuário pedir EXPLICITAMENTE o docx/HU formal — "gera o docx", "agora o docx", "transforma o md em docx", "cria a HU formal" — E o `.md` da issue já existir. NÃO use para pedido genérico de documentação ("documenta a #NNN", "gera a documentação"): isso gera o `.md` primeiro via doc-consolidator, com parada para revisão humana antes do docx. Só transcreve o `.md`; não relê o discovery. Output é SEMPRE um `.docx`.
---

# HU Generator

> **Valores de projeto** (Cliente, Projeto, Responsável, token de arquivo, logo, URL de issues)
> vêm de **`project-config.md`**. Campo em branco lá → placeholder `[ASSIM]`.


Gera documentação de Histórias de Usuário no formato oficial do projeto, entregando um arquivo `.docx` fiel ao template de referência.

**SEMPRE gere um `.docx`. Nunca apenas Markdown.**

---

## 0. Input primário — o `.md` consolidado ⚠️

Antes de qualquer coisa, procure o `.md` consolidado da issue:

```bash
ls outputs/${ID}_*/HU*${ID}* 2>/dev/null
```

- **Se existir:** ele é a **única fonte de conteúdo**. Não releia o discovery. Esta etapa é
  **mecânica/modelo leve**: cada seção do `.md` vira a seção correspondente do `.docx`,
  aplicando a formatação da Seção 3. Pule o Passo 1 (coleta) — os dados já estão no `.md`.
- **Se NÃO existir:** **PARE** e avise que falta o `.md` consolidado — o usuário deve gerá-lo antes
  com a skill `doc-consolidator` e revisá-lo. **Não** gere o `.md` automaticamente daqui.

A seção 5 do `.docx` leva **apenas os rótulos** das regras (`RN_XXXX — Título`), extraídos do
`.md`. A descrição completa fica no `.md` e em `{ID}_regras.md` — não vai para o `.docx`.

> ⚠️ **Formato do `.md`:** o `generate_doc.py` faz parsing por padrão de linha. O `.md` deve seguir o
> **Contrato de formato** do `doc-consolidator` (seções `## N. Título`; metadados `- **Campo:** valor`;
> CAs `- **CANN:** …`; regras `- **CODE — Título:** …`, nunca `### RN_`; apêndice de discovery é
> cortado automaticamente). Se o `.docx` sair errado, **conserte o `.md`** (não o `.docx`) e regere.

---

## 1. Fluxo de execução

### Passo 1 — Coletar informações obrigatórias

| Campo | Obrigatório? | Padrão |
|---|---|---|
| Projeto | Sim | — |
| Identificação da HU | Sim | — |
| Épico/Tema | Sim | — |
| Ordem de Serviço | Sim | — |
| Persona (perfil do usuário) | Sim | — |
| Descrição da funcionalidade | Sim | — |
| Responsável | Não | project-config → Responsável padrão (vazio → `[RESPONSÁVEL]`) |
| Data de Emissão | Não | data de hoje |

### Passo 2 — Confirmar divisão em HUs

**Nunca decida sozinho como dividir.** Pergunte ao usuário quantas HUs quer e o que cada uma cobre. Só avance após confirmação explícita.

### Passo 3 — Gerar o .docx

A formatação está toda em `generate_doc.py` (lib **python-docx**, leve). **Não reescreva o
layout** — gere/edite o `.md` consolidado e rode o script:

```bash
pip install python-docx   # se necessário
python3 generate_doc.py <md_path> outputs/{ID}_{NomeCurto}/HU{ID}_{TOKEN}_{NomeCurto}.docx
```

O rótulo do header (`HISTÓRIA DE USUÁRIO`) é inferido do frontmatter `tipo: HU` do `.md`.
Validar: `python3 -c "from docx import Document; Document('<arquivo>')"`.

Nome: `HU{ID}_{TOKEN}_{NomeCurto}.docx` (TOKEN = project-config) → `outputs/{ID}_{NomeCurto}/` (mesma pasta do `.md` e das regras)

---

## 2. Regras de escrita

### Seção 1 — Entendendo o Problema

* **Persona:** perfil exato (ex: `Engenheiro (GEENG)`)
* **Cenário do Usuário (Dor):** 2–4 frases focando na frustração, sem mencionar a solução

### Seção 2 — História de Usuário

Tabela obrigatória com três linhas: `Como` / `Quero` / `Para`

### Seção 3 — Escopo

**1 parágrafo curto (~3 frases), nível resumo concreto.** Descreva o que a HU entrega: a funcionalidade, o ponto de acesso e os principais comportamentos/blocos (como nos exemplos). Pode citar os componentes principais de forma compacta; NÃO faça lista exaustiva campo-a-campo nem repita verbatim os CAs/regras — o detalhe vai nas seções 4, 5 e 6. **Apenas o que está dentro do escopo** (não descreva o que fica de fora). Use **bold** em 1–2 termos-chave.

### Seção 4 — Critérios de Aceitação

* Formato: **Dado que... Quando... Então...**
* Numeração: CA01, CA02... Mínimo 3, máximo recomendado 7.
* **Organizar obrigatoriamente em subseções temáticas** (H3/Heading3). Exemplos de subseções:
  * 4.1. Carregamento e Exibição da Listagem
  * 4.2. Alertas Visuais de Vencimento
  * 4.3. Filtros e Pesquisa
  * 4.4. Ações da Listagem
* Adapte os nomes das subseções ao contexto da HU gerada. Os CAs ficam dentro de cada subseção correspondente.

### Seção 5 — Rótulos das regras (do `.md` consolidado)

Quatro blocos (RN / RA / MSG criadas/editadas + Regras existentes referenciadas). Cada um: título
**bold** + um bullet por regra contendo **apenas o rótulo** (`RN_XXXX — Título`) extraído da seção 5
do `.md` consolidado — **sem a descrição completa**, que fica no `.md` e em `{ID}_regras.md`. Bloco
sem item → um único bullet "N/A".

```
Regras de Negócio (RN) criadas ou editadas nesta HU:
• RN_0033 — Bloqueio de turma incompleta

Regras de Apresentação (RA) criadas ou editadas nesta HU:
• RA_0016 — Ocultar botão Salvar após consolidação

Mensagens do Sistema (MSG) criadas ou editadas nesta HU:
• N/A

Regras existentes referenciadas (aplicáveis a esta HU, não alteradas):
• RN_0015 — Vínculo turma-curso
```

> O script `generate_doc.py` já renderiza esse bloco: rótulo em **bold** + um bullet por
> regra (ou `N/A`), lendo direto a seção 5 do `.md` consolidado.

### Seção 6

* **Deixar SEMPRE vazia** — apenas o heading, sem conteúdo. O usuário preencherá manualmente.

### Seção 7

* **Deixar com os seguintes placeholders em negrito, fonte normal (não heading):**
  * `Documento de Regras de Negócio:`
  * `Link do Protótipo de Telas Impactadas:`
* Nenhum outro conteúdo.

**Tom:** português formal, sem jargão de implementação, voz ativa.

---

## 3. Especificações de formatação .docx

> ⚠️ Toda a formatação vive em `generate_doc.py` (python-docx). **Não reescreva o layout em
> código aqui** — o script é a fonte de verdade. O mesmo script gera HU e HT (layout idêntico);
> o rótulo do header (`HISTÓRIA DE USUÁRIO`) é inferido de `tipo: HU` no frontmatter do `.md`.

Resumo do que o script aplica (para conferência visual):

- **Página:** A4 (210×297 mm), margens 0,5\" (720 twips), header/footer a ~708 twips.
- **Header:** logo flutuante à esquerda (atrás do texto) + label à direita, Calibri 18pt bold.
- **Footer:** número de página centralizado, Aptos, small-caps, cor `156082`.
- **Fonte padrão:** Arial 12pt, entrelinha 1,5. Headings Arial bold: H1 18pt, H2 15pt, H3 13pt.
- **Metadados:** Arial 17pt, rótulo em bold (sem tabela de revisões).
- **Sumário:** campo TOC real (`TOC \o "1-3" \h \z \u`) — atualiza com F9 no Word.
- **Tabela "2. História de Usuário":** 1 tabela por linha (Como/Quero/Para), bordas single, label 2220 / valor 8246 twips.
- **CAs:** bullet ●, organizados em subseções (Heading), `CA01:` verde `38761d` bold, `Dado que/Quando/Então` bold cor `1b1c1d`.
- **Bullets:** ● com recuo pendente (left 465 / hanging 360 twips).
- **Seção 5:** rótulos das regras (RN/RA/MSG) vindos do `.md`. **Seção 6:** vazia. **Seção 7:** placeholders em bold.

O conteúdo (texto das seções) vem do `.md` consolidado; o script só aplica formatação.
Mudou o template? Edite `generate_doc.py`, não este arquivo.

## 4. Referências

* `references/template.md` — template de conteúdo das seções
* `references/exemplos.md` — exemplos de HUs (tom e nível de detalhe)
* `assets/header_logo.png` — logo do header (substitua pelo logo do projeto; 730×61 px). Ausente → header sem logo.
