---
name: design-screen
description: >
  Cria telas e componentes UI no Figma a partir de uma issue, HU, descrição livre ou
  número de issue do GitLab. Consulta os guidelines de design já configurados no Figma
  (FIGMA_GUIDELINES_NODE_ID) para copiar tokens e componentes existentes, gera o HTML
  fiel ao design system do projeto e insere no Figma. Use sempre que o usuário pedir
  para criar uma tela, protótipo, componente ou wireframe — independente de ter ou não
  uma issue associada.
  IMPORTANTE: Carregue obrigatoriamente a skill `glab-backlog` antes de qualquer operação no GitLab.
---

**PRÉ-REQUISITO:** Carregar a skill `glab-backlog` antes de qualquer operação no GitLab.



# design-screen

Cria novas telas no Figma respeitando o design system do projeto. A fonte de verdade dos componentes e tokens é a página de guidelines no Figma — não arquivos locais. Este fluxo garante consistência visual entre todas as telas geradas.

**Pré-requisito:** a skill `design-setup` já deve ter sido executada e `FIGMA_GUIDELINES_NODE_ID` deve estar no `.env`. Se não estiver, interrompa e oriente o usuário a executar o setup primeiro.

---

## 1. Configuração

```
FIGMA_FILE_KEY:           ${FIGMA_FILE_KEY}
FIGMA_GUIDELINES_NODE_ID: ${FIGMA_GUIDELINES_NODE_ID}
GITLAB_HOST:              ${GITLAB_HOST}
GITLAB_URI:               ${GITLAB_URI}
GITLAB_REPO:              ${GITLAB_REPO}
```

---

## 2. Carregar o contexto da tela

### Se recebeu número de issue

```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab issue view NNN -R ${GITLAB_REPO}
```

Extraia: título, descrição do problema, solução proposta na seção EVOLUCAO, critérios de aceite. Se a issue tiver uma HU gerada, leia também o documento para entender campos, fluxos e estados da tela.

### Se recebeu descrição livre

Use a descrição diretamente. Se estiver vaga (ex: "cria a tela de listagem de candidatos"), busque contexto em `docs/context_docs/` — o ONEPAGE.md provavelmente já descreve o comportamento esperado dessa tela.

### Perguntas mínimas antes de criar

Se o contexto não deixar claro, confirme apenas:
1. **Qual módulo/área** — ADM ou SI? Qual seção?
2. **Qual o estado principal** — listagem, formulário, modal, detalhe?
3. **Há algum estado específico** que precisa ser mostrado (erro, vazio, carregando)?

---

## 3. Consultar o design system no Figma

Antes de criar o HTML, leia os guidelines existentes para copiar tokens e padrões corretos:

```
get_design_context(fileKey="${FIGMA_FILE_KEY}", nodeId="${FIGMA_GUIDELINES_NODE_ID}")
```

Extraia:
- Paleta de cores (tokens nomeados e valores hex)
- Escala tipográfica (família, tamanhos, pesos)
- Grid de espaçamento
- Componentes disponíveis e seus estados

Se o guidelines node for grande, use `get_metadata` para mapear a estrutura e leia seção por seção conforme necessário.

---

## 4. Criar o HTML da tela

Use a skill `html-to-figma` como base técnica para criar o HTML. Aplique também os princípios de qualidade da skill `frontend-design`.

### Regras específicas para este fluxo

**Use os tokens do design system** extraídos no passo anterior — não invente valores novos. Se um componente existe nos guidelines, copie sua estrutura exata.

**Estrutura de layout típica do projeto** (adapte conforme o contexto real extraído dos guidelines):

```html
<!-- Layout com sidebar (padrão de módulo ADM) -->
<div class="app">
  <aside class="sidebar">...</aside>
  <main class="main">
    <header class="topbar">...</header>
    <div class="content">
      <!-- conteúdo da tela -->
    </div>
  </main>
</div>
```

**Componentes obrigatórios conforme o tipo de tela:**

- **Listagem:** tabela com cabeçalho ordenável, seletor de linhas/página, paginação, contador de itens, campo de busca, botões de ação por linha
- **Formulário/Stepper:** etapas numeradas, campos com label, botões Cancelar/Salvar, validações visuais
- **Modal:** overlay com fade, botão de fechar, ações no footer
- **Detalhe:** pares label-valor, collapse de histórico se aplicável

**Renderize todos os estados relevantes** da tela — a listagem vazia, com dados, com loading; o formulário com erro; o modal aberto. Isso é mais valioso do que uma tela estática perfeita.

---

## 5. Servir local e revisar (PARE AQUI por padrão)

Antes de qualquer coisa no Figma, sirva o HTML localmente para revisão:

```bash
python3 -m http.server 4321 --directory <dir>
```

Dê as URLs locais ao usuário e **PARE**. Itere no feedback editando o HTML — o server serve o update no refresh. Nenhuma chamada ao Figma acontece aqui.

> Push pro Figma é escrita externa (write-gate do `.agents/ENGAGEMENT.md`): só avance para a Etapa 6 depois do usuário pedir explicitamente ("manda pro Figma"). Uma execução padrão termina aqui.

## 6. Inserir no Figma (SÓ sob pedido explícito)

Execute o fluxo da skill `html-to-figma` a partir da Etapa 3 (injetar script, subir dev server, capturar e inserir).

Use `outputMode="existingFile"` e `fileKey=${FIGMA_FILE_KEY}` para inserir no arquivo correto do projeto.

---

## 7. Registrar em history/

Crie `history/YYYY-MM-DD_design_<nome-curto>.md`:

```markdown
# [DESIGN] <Nome da tela>
Data: YYYY-MM-DD
Agente: designer
Issue: #NNN (se aplicável)

## Contexto
[O que a tela resolve, módulo, estado principal]

## Estados renderizados
- [estado 1]
- [estado 2]

## Figma
- Arquivo: ${FIGMA_FILE_KEY}
- Node inserido: [URL]

## Decisões de design
- [decisão relevante 1 — ex: "usei o componente de tabela dos guidelines, ajustei apenas a largura das colunas"]
```

---

## Quando o design system ainda não existe

Se `FIGMA_GUIDELINES_NODE_ID` não estiver no `.env` ou estiver vazio:

> "Os guidelines de design ainda não foram configurados para este projeto. Para criar telas com consistência visual, execute o setup primeiro: peça 'setup do design system' ao `@product-designer`. Você precisará fornecer prints ou screenshots do sistema atual."

Não crie a tela sem os guidelines — o resultado seria inconsistente com o restante do projeto.
