---
name: changelog-generator
description: >
  Gera ou atualiza o changelog do projeto (Histórico de Evolução; nome do projeto em project-config.md) a partir de documentos de entrada como HUs, ordens de serviço, descrições de funcionalidade ou qualquer documentação de requisito. Use esta skill sempre que o usuário mencionar "changelog", "histórico de evolução", "adicionar ao changelog", "gerar entrada de changelog", "registrar mudança", "atualizar o histórico" ou enviar um documento de HU/OS pedindo para registrá-lo. A saída é sempre uma tabela Markdown no padrão oficial do projeto, com as colunas: Data Criação, OS Contratual, Épico / HU, Descrição da Mudança (Delta) e Telas Impactadas.
---

# Changelog Generator

> Nome do projeto vem de **`project-config.md`** (campo Projeto). Vazio → `[PROJETO]`.

Gera entradas para o Histórico de Evolução do projeto a partir de documentos de HU, OS ou descrições livres de funcionalidade.

---

## 1. Fluxo de execução

### Passo 1 — Extrair informações do documento recebido

Leia o documento fornecido (HU, OS, descrição livre ou qualquer combinação) e extraia automaticamente os seguintes campos:

| Campo | Onde encontrar | Fallback se não encontrado |
|---|---|---|
| **Data Criação** | Campo "Data de Emissão" da HU ou data do documento | Perguntar ao usuário |
| **OS Contratual** | Campo "Ordem de Serviço" da HU | Perguntar ao usuário |
| **Épico / HU** | Número da HU no formato `XXX.YY` extraído do campo "Identificação da HU" | Perguntar ao usuário |
| **Descrição da Mudança (Delta)** | Sintetizar a partir do Escopo, da História de Usuário e dos Critérios de Aceitação | — ver regras abaixo — |
| **Telas Impactadas** | Extrair da seção "Protótipo", dos Critérios de Aceitação ou do Escopo | Inferir pelo contexto |

### Passo 2 — Perguntar apenas o que não foi possível extrair

Não faça perguntas desnecessárias. Somente pergunte ao usuário os campos que **não puderam ser extraídos** do documento. Se todos os campos foram encontrados, pule direto para o Passo 3.

Se precisar perguntar, agrupe tudo em uma única mensagem com as lacunas identificadas.

### Passo 3 — Gerar a entrada do changelog

Monte a linha da tabela seguindo rigorosamente o formato em `references/formato.md`.

Gere a linha completa pronta para ser copiada e colada no documento de changelog existente.

---

## 2. Regras para a coluna "Descrição da Mudança (Delta)"

Esta é a coluna mais importante e exige atenção especial. Siga estas regras:

### Estrutura obrigatória

```
**[TIPO] Título curto e direto:** Descrição em prosa do que foi entregue, no passado, focando no impacto para o sistema e para o usuário. Uma ou duas frases.
```

### Tipo da mudança

Escolha **um** dos tipos abaixo com base no conteúdo da HU:

| Tipo | Quando usar |
|---|---|
| `[NOVO]` | Funcionalidade, tela, campo ou integração que não existia antes |
| `[ALTERADO]` | Modificação de comportamento, interface ou regra já existente |
| `[CORRIGIDO]` | Correção de bug ou comportamento incorreto |
| `[REMOVIDO]` | Remoção de funcionalidade, campo ou acesso |

### Regras de escrita do Delta

- **Seja objetivo e denso:** em 1–2 frases, transmita o máximo de informação sobre o que mudou.
- **Use linguagem de produto**, não de implementação. Diga "inclusão de menu de atalho no cabeçalho" e não "adição de componente dropdown no header component".
- **Inclua os pontos principais da entrega** separados por vírgula quando forem múltiplos (ex: "pesquisa livre, clonagem para múltiplos blocos, obrigatoriedade e alertas").
- **Escreva no passado** (contempla, inclui, concede — presente do indicativo de caráter descritivo também é aceito).
- **Não repita o título** na descrição.
- Não use bullet points — tudo em prosa corrida.

### Exemplos de Delta bem escritos

> **[ALTERADO] Melhoria UX Mobile:** Adaptação e otimização do fluxo de vistoria para dispositivos móveis, contemplando a nova visualização da listagem de visitas e a implementação de filtros avançados otimizados para telas menores.

> **[NOVO] Integração Power BI:** Inclusão de um novo menu de atalho no cabeçalho superior (visível apenas para o perfil Engenheiro/GEENG) contendo links de redirecionamento direto para os Dashboards externos de Execução Orçamentária e Gestão de Contratos.

> **[ALTERADO] Permissões de Projeto:** Alteração na matriz de acessos (Roles) do sistema, concedendo privilégios de edição na seção de Fases do Projeto especificamente para usuários com o perfil de "Unidade".

---

## 3. Regras para a coluna "Telas Impactadas"

- Liste os nomes das telas ou módulos afetados, separados por vírgula.
- Use os nomes exatos como aparecem na documentação (ex: "Listar Visitas (Mobile)", "Cabeçalho Global (Header)").
- Se não estiver explícito no documento, infira pelo contexto da HU.
- Se não for possível inferir, deixe `[a preencher]`.

---

## 4. Comportamento com múltiplos documentos

Se o usuário fornecer mais de um documento (ex: várias HUs de uma vez), gere **uma linha por HU/documento**, na ordem em que foram recebidos, do mais recente para o mais antigo (ordem decrescente de data).

---

## 5. Output

A saída deve ser **sempre a tabela Markdown completa** do changelog, incluindo o cabeçalho, pronta para uso.

Se o usuário já tiver um changelog existente e estiver adicionando novas linhas, exiba:
1. Primeiro as **novas linhas geradas** em destaque (com nota "Nova(s) entrada(s):").
2. Depois a **tabela completa atualizada**, com as novas linhas inseridas no topo (mais recentes primeiro).

Se for a primeira entrada, gere a tabela do zero com cabeçalho e a linha gerada.

Leia `references/formato.md` para a estrutura exata da tabela antes de gerar.
