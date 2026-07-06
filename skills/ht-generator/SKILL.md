---
name: ht-generator
description: >
  Passo FINAL da documentação técnica: transcreve um `.md` consolidado JÁ REVISADO (gerado pela skill doc-consolidator) para um `.docx` de História Técnica — 6 seções (Por que precisamos disso, O que deve ser feito, Escopo, Critérios de Aceite, Dependências e restrições, O que será afetado). Demanda técnica sem persona de usuário final (débito técnico, refatoração, infra, CI/CD, migração, ambiente). Use SOMENTE quando o usuário pedir EXPLICITAMENTE o docx/HT formal — "gera o docx", "agora o docx", "cria a HT formal" — E o `.md` da issue já existir. NÃO use para pedido genérico ("documenta a #NNN"): isso gera o `.md` primeiro via doc-consolidator, com parada para revisão. Nunca use para HU. Output é SEMPRE um `.docx`.
---

# HT Generator

> **Valores de projeto** (Cliente, Projeto, Responsável, token de arquivo, logo, URL de issues)
> vêm de **`project-config.md`**. Campo em branco lá → placeholder `[ASSIM]`.


O P.O. descreve a demanda em linguagem livre. O Claude estrutura, interpreta e gera o documento `.docx` completo no padrão do projeto.

**SEMPRE gere um `.docx`. Nunca apenas Markdown.**

---

## 0. Input primário — o `.md` consolidado ⚠️

Procure o `.md` consolidado da issue antes de tudo:

```bash
ls outputs/${ID}_*/HT*${ID}* 2>/dev/null
```

- **Se existir:** é a **única fonte de conteúdo**. Esta etapa é **mecânica/modelo leve** — cada
  seção do `.md` vira a seção do `.docx` com a formatação da Seção 5. Pule a coleta (Passo 1-3).
- **Se NÃO existir:** **PARE** e avise que falta o `.md` consolidado — o usuário deve gerá-lo antes
  com a skill `doc-consolidator` e revisá-lo. **Não** gere o `.md` automaticamente daqui.

> ⚠️ **Formato do `.md`:** o `generate_doc.py` faz parsing por padrão de linha. O `.md` deve seguir o
> **Contrato de formato** do `doc-consolidator` (seções `## N. Título`; metadados `- **Campo:** valor`;
> CAs `- **CANN:** …`; regras `- **CODE — Título:** …`, nunca `### RN_`; apêndice de discovery é
> cortado automaticamente). Se o `.docx` sair errado, **conserte o `.md`** (não o `.docx`) e regere.

---

## 1. Quando usar HT (em vez de HU)

Use HT quando a demanda **não tem um usuário final sendo impactado diretamente** — ou seja, o benefício é para o sistema, para a plataforma ou para o time de desenvolvimento.

Exemplos comuns que P.O.s pedem como HT:
- "Precisamos migrar o banco de dados para a nova versão"
- "O time pediu para configurar o ambiente de homologação"
- "Tem uma lentidão no sistema que precisa ser investigada e corrigida"
- "Precisamos atualizar as bibliotecas que estão desatualizadas"
- "O time precisa de um pipeline automático de deploy"
- "Precisamos de logs melhores para rastrear erros"

Se houver uma tela ou uma ação que o usuário faz → use HU. Se for algo que acontece "por baixo dos panos" → use HT.

---

## 2. Como funciona

O P.O. envia uma descrição livre da demanda (pode ser informal, como uma mensagem de texto ou e-mail). O Claude faz as perguntas mínimas necessárias e monta o documento completo.

### Passo 1 — Receber a descrição

O P.O. descreve a demanda livremente. Não há formulário. Aceite qualquer formato: texto corrido, tópicos, e-mail copiado, mensagem de reunião.

### Passo 2 — Perguntar só o essencial

Pergunte **apenas** o que não conseguir inferir da descrição:

| Campo | Perguntar se... |
|---|---|
| Número da HT (ex: HT005.1) | Não foi mencionado |
| Épico/Tema | Não foi mencionado |
| Ordem de Serviço | Não foi mencionada |
| Responsável | project-config → Responsável padrão (vazio → **[RESPONSÁVEL]**) |
| Data de Emissão | Sempre usar a data de hoje |

> Nunca peça informações técnicas ao P.O. (nomes de tabelas, endpoints, variáveis). Infira ou deixe em aberto para o time de desenvolvimento preencher.

### Passo 3 — Confirmar divisão em HTs

Se a demanda puder virar mais de uma HT, pergunte ao P.O. como quer dividir. **Nunca decida sozinho.** Só avance após confirmação.

### Passo 4 — Gerar o .docx

A formatação está toda implementada em `generate_doc.py` (lib **python-docx**, leve). **Não
reescreva o layout** — gere/edite o `.md` consolidado e rode o script:

```bash
pip install python-docx   # se necessário
python3 generate_doc.py <md_path> outputs/{ID}_{NomeCurto}/HT{ID}_{TOKEN}_{NomeCurto}.docx
```

O rótulo do header (`HISTÓRIA TÉCNICA`) é inferido do frontmatter `tipo: HT` do `.md`.
Para validar: `python3 -c "from docx import Document; Document('<arquivo>')"`.

Nome do arquivo: `HT{ID}_{TOKEN}_{NomeCurto}.docx` (TOKEN = project-config) → salvar em `outputs/{ID}_{NomeCurto}/` (mesma pasta do `.md` e das regras)

---

## 3. Seções do documento e como preenchê-las

> Consulte `references/template.md` para o template exato de cada seção e `references/exemplos.md` para exemplos reais de HTs já escritas.

### Seção 1 — Por que precisamos disso

Explique o problema ou a necessidade que motivou essa demanda. Escreva em linguagem clara, sem jargão técnico excessivo. O leitor deve entender o impacto de **não fazer** isso.

- 2 a 4 frases
- Foco no problema, não na solução
- Exemplo: *"O ambiente de homologação está sendo configurado manualmente a cada deploy, o que gera erros frequentes e atrasa as entregas do time."*

### Seção 2 — O que deve ser feito

Tabela com três linhas descrevendo a demanda de forma objetiva:

| Campo | O que colocar |
|---|---|
| **Sistema/Área** | Qual parte do sistema ou infraestrutura é afetada |
| **O que fazer** | A ação principal em uma frase clara |
| **Por quê** | O benefício esperado para o sistema ou time |

> Equivale ao "Como / Quero / Para" da HU, mas sem persona de usuário.

### Seção 3 — Escopo

**1 parágrafo curto (~3 frases), nível resumo concreto.** Descreva o que a HT entrega — o que muda e os principais comportamentos. Compacto, sem lista exaustiva nem repetir os CAs. **Apenas o que está dentro do escopo** (não descreva o que fica de fora).

- NÃO enumere tabelas, campos, classes ou itens já detalhados nos CAs e demais seções
- Use **negrito** em 1–2 termos-chave
- Sempre termine com uma frase dizendo o que *não* será feito

### Seção 4 — Critérios de Aceite

Lista de critérios de aceite no formato **Dado que... Quando... Então...**

- Numeração: CA01, CA02... Mínimo 3, máximo 7
- Cada critério deve ser algo verificável (pode ser testado, observado ou medido)
- Escreva pensando no que o time de desenvolvimento precisará demonstrar para fechar a tarefa

### Seção 5 — Dependências e restrições

O que precisa existir ou estar pronto **antes** de começar essa HT? Há alguma limitação conhecida?

- Se não houver: escreva "N/A"
- Exemplos: depende de outra HT ser concluída, requer acesso a um ambiente específico, não pode ser feito em produção enquanto X estiver em uso

### Seção 6 — O que será afetado?

Liste os sistemas, funcionalidades, telas ou serviços que podem ser impactados por essa mudança — mesmo que indiretamente.

- Se não houver: escreva "N/A"
- Não precisa ser uma lista técnica detalhada; use os nomes que o P.O. conhece (ex: "Módulo de Relatórios", "Tela de Login", "Integração com TOTVS")

---

## 4. Tom e linguagem

- Português formal, mas acessível
- Evite siglas técnicas sem explicação (ex: em vez de "refatorar o auth-service", escreva "reestruturar o serviço de autenticação")
- Se precisar usar um termo técnico, explique brevemente entre parênteses
- Voz ativa: "O sistema irá registrar..." em vez de "Será registrado pelo sistema..."

---

## 5. Especificações de formatação .docx

> ⚠️ Toda a formatação vive em `generate_doc.py` (python-docx). **Não reescreva o layout
> em código aqui** — o script é a fonte de verdade e produz layout idêntico ao da skill
> `hu-generator`. Só muda o rótulo do header (`HISTÓRIA TÉCNICA`, inferido de `tipo: HT`).

Resumo do que o script aplica (para conferência visual):

- **Página:** A4 (210×297 mm), margens 0,5\" (720 twips), header/footer a ~708 twips.
- **Header:** logo flutuante à esquerda (atrás do texto) + label à direita, Calibri 18pt bold.
- **Footer:** número de página centralizado, Aptos, small-caps, cor `156082`.
- **Fonte padrão:** Arial 12pt, entrelinha 1,5. Headings Arial bold: H1 18pt, H2 15pt, H3 13pt.
- **Metadados:** Arial 17pt, rótulo em bold.
- **Sumário:** campo TOC real (`TOC \o "1-3" \h \z \u`) — atualiza com F9 no Word.
- **Tabela "2. O que deve ser feito":** 1 tabela por linha, bordas single, label 2220 / valor 8246 twips.
- **CAs:** bullet ●, `CA01:` verde `38761d` bold, `Dado que/Quando/Então` bold cor `1b1c1d`.
- **Bullets:** ● com recuo pendente (left 465 / hanging 360 twips).

Mudou o template? Edite `generate_doc.py`, não este arquivo.

## 6. Referências

* `references/template.md` — template com estrutura exata de cada seção
* `references/exemplos.md` — exemplos reais de HTs escritas no padrão
* `assets/header_logo.png` — logo do header (substitua pelo logo do projeto; 730×61 px). Ausente → header sem logo.
