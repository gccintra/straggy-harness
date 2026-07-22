---
name: hu-generator
description: >
  Passo FINAL da documentação: transcreve um `.md` consolidado JÁ REVISADO (gerado pela skill doc-consolidator) para um `.docx` de História de Usuário — 9 seções (Problema, História de Usuário, Escopo, Critérios de Aceitação, Regras de Negócio, Mensagens, Referências Globais, Protótipo, Complemento de Documentação). Use SOMENTE quando o usuário pedir EXPLICITAMENTE o docx/HU formal — "gera o docx", "agora o docx", "transforma o md em docx", "cria a HU formal" — E o `.md` da issue já existir. NÃO use para pedido genérico de documentação ("documenta a #NNN", "gera a documentação"): isso gera o `.md` primeiro via doc-consolidator, com parada para revisão humana antes do docx. Só transcreve o `.md`; não relê o discovery. Output é SEMPRE um `.docx`.
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

O `.md` é **autocontido**: as seções 5 (Regras de Negócio), 6 (Mensagens) e 7 (Referências
Globais) levam o **texto completo** para o `.docx` — não há mais `{ID}_regras.md` separado nem
rótulo-só. RN em SBVR, MSG com texto literal, GL como bullets.

> ⚠️ **Formato do `.md`:** o `generate_doc.py` faz parsing por padrão de linha. O `.md` deve seguir o
> **Contrato de formato** do `doc-consolidator` (seções `## N. Título`; metadados `- **Campo:** valor`;
> CAs `- **CANN:** **Dado que** … **Quando** … **Então** … [RN_0X]`; regras `- **RN_0X** — <frase SBVR>`;
> mensagens `- **MSG_0X** (Tipo) — "…"`; apêndices `## Apêndice — …` cortados automaticamente).
> Se o `.docx` sair errado, **conserte o `.md`** (não o `.docx`) e regere.

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

> Esta etapa **transcreve** o `.md` — não reescreve o conteúdo. As regras de autoria (CA
> coeso, RN em SBVR, MSG, GL) são do `doc-consolidator` (`references/regras.md`). Abaixo, só o
> que cada seção do `.md` vira no `.docx`.

### Seção 1 — Problema
Persona + Cenário do Usuário (Dor). Transcrito como está.

### Seção 2 — História de Usuário
Tabela de três linhas: `Como` / `Quero` / `Para`.

### Seção 3 — Escopo
1 parágrafo curto. Transcrito como está.

### Seção 4 — Critérios de Aceitação
* CAs em subseções temáticas (H3), `Dado que / Quando / Então`, **coesos**.
* Cada CA carrega as referências `[RN_0X]` / `[MSG_0X]` / `[GL_0X]` como texto literal no fim.
* `CA01:` sai em verde bold; palavras-chave `Dado que/Quando/Então` em bold escuro.

### Seção 5 — Regras de Negócio
* **Texto completo** de cada RN (SBVR), um bullet por regra: `RN_0X — <frase>` (sem título).
* Numeração local à issue. Sem rótulo-só, sem grupos RA/existentes.

### Seção 6 — Mensagens
* Um bullet por mensagem: `MSG_0X (Tipo) — "texto literal"`. Texto completo.

### Seção 7 — Referências Globais
* Um bullet por GL referenciado: `GL_0X — Título — usado em CA_NN.`
* Só o que a issue **referencia** (o conteúdo do GL vive no doc do Drive).
* Nenhuma → um único bullet `N/A`.

### Seção 8 — Protótipo
* Transcreva os **títulos por fluxo** e os **links** das rotas que a skill `prototype-prints`
  escreveu no `.md` (subseções de fluxo + link + headings de print). As **imagens** o usuário
  cola à mão no `.docx`. Nunca auto-preencher com notas do discovery.

### Seção 9 — Complemento de Documentação
* Dois blocos em negrito, fonte normal (não heading):
  * `Documento de Regras de Negócio:` — transcreva o link se o usuário já preencheu no `.md`;
    senão deixe o placeholder vazio.
  * `Link do Protótipo de Telas Impactadas:` — transcreva os bullets `<Nome do fluxo>: <url>`
    do `.md` (mesmos links da seção 8, duplicados lá pela `prototype-prints`). Nenhum link no
    `.md` → só o placeholder.
* Nada além de links aqui — nunca prosa, título de print ou imagem.

> **Não existe** seção "Descrição de Interface". O apêndice de discovery e o apêndice "Novas
> Referências Globais — copiar para o Drive" **não vão** para o `.docx` (o script os corta).

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
- **Seções 5/6/7:** texto completo de RN (SBVR), MSG e GL como bullets. **Apêndices** (discovery, GLs a copiar) cortados do `.docx`.

O conteúdo (texto das seções) vem do `.md` consolidado; o script só aplica formatação.
Mudou o template? Edite `generate_doc.py`, não este arquivo.

## 4. Referências

* `references/template.md` — template de conteúdo das seções
* `references/exemplos.md` — exemplos de HUs (tom e nível de detalhe)
* `assets/header_logo.png` — logo do header (substitua pelo logo do projeto; 730×61 px). Ausente → header sem logo.
