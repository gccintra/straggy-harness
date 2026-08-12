---
name: hu-narrative-generator
description: >
  Gera uma descrição narrativa em Markdown a partir de documentação existente de História de
  Usuário, preservando requisitos, regras, estados, permissões, exceções e efeitos operacionais
  em texto corrido e coeso. Use quando o usuário pedir "descrição narrativa", "narrativa da HU",
  "transformar a HU em texto corrido", "explicar o comportamento da HU" ou um documento no padrão
  `HU{ID}_Descricao_Narrativa.md`. Não cria requisitos nem substitui o documento consolidado.
---

# Descrição narrativa de HU

Transformar uma HU já documentada em uma narrativa funcional autocontida, compreensível para
produto, design, desenvolvimento, QA e negócio.

> Seguir `system/CONSTITUTION.md`: ser breve; pedir contexto quando uma lacuna mudar o
> resultado; aprovação explícita antes de salvar (write-gate). Base de escrita de requisito:
> `system/professions/product-specialist/methods/user-story.md`.

## Contrato

- **Entrada:** documentação de uma HU em arquivo, conteúdo fornecido pelo usuário ou conjunto de
  fontes explicitamente indicado.
- **Saída:** somente Markdown narrativo; não gerar `.docx`.
- **Caminho padrão:** `outputs/{ID}_{NomeCurto}/HU{ID}_Descricao_Narrativa.md`.
- **Fonte de verdade:** a documentação recebida. Não transformar inferências em requisitos.
- **Padrão editorial:** ler integralmente `references/padrao-narrativo.md` antes de redigir.

Se houver mais de uma fonte, definir a precedência nesta ordem, salvo orientação diferente:

1. Documento consolidado revisado da HU.
2. Critérios de aceitação e regras de negócio aprovados.
3. Discovery e descrição da issue.
4. Materiais auxiliares.

Conflito que altere o comportamento esperado: parar e fazer uma pergunta objetiva. Não escolher
silenciosamente uma versão.

## Fluxo

### 1. Localizar e ler as fontes

- Se o usuário fornecer um caminho, ler o arquivo integralmente.
- Se fornecer apenas o ID, procurar primeiro em `outputs/{ID}_*/` e depois em
  `history/` e `docs/context_docs/`.
- Se a documentação essencial não existir, pedir o arquivo ou conteúdo da HU.
- Ler somente fontes relevantes e documentos referenciados por elas.

### 2. Montar um inventário interno

Antes de redigir, identificar sem expor uma seção técnica no documento final:

- objetivo e benefício;
- atores e permissões;
- entidades, vínculos e propriedade dos dados;
- fluxo principal e estados;
- condições, validações e bloqueios;
- exceções e concorrência;
- efeitos posteriores e histórico;
- consultas, filtros, relatórios e integrações;
- termos oficiais da interface.

Mapear cada critério de aceitação e regra de negócio para ao menos um trecho da narrativa. O
inventário serve para cobertura e não deve aparecer na saída.

### 3. Redigir

- Usar o futuro do presente para o comportamento que será implementado.
- Abrir com o que muda, para quem e por quê.
- Organizar os parágrafos na ordem operacional da funcionalidade.
- Manter uma ideia central por parágrafo e criar transições explícitas entre etapas relacionadas.
- Preservar nomes de ações, telas, campos e status exatamente como documentados.
- Explicar exceções junto da regra a que pertencem.
- Diferenciar claramente registros específicos, gerais, históricos e compartilhados quando houver.
- Remover repetição sem eliminar condições ou consequências.
- Não usar listas, tabelas, IDs de CA/RN, linguagem Gherkin ou subtítulos no corpo narrativo.
- Não incluir implementação técnica, justificativas inventadas ou comportamento não confirmado.

### 4. Verificar

Confirmar antes de apresentar:

- todos os critérios e regras aplicáveis estão representados;
- atores, permissões, estados, bloqueios e exceções não se contradizem;
- condições temporais e efeitos de concorrência permanecem explícitos;
- nenhum termo oficial foi renomeado;
- nenhuma regra nova foi criada;
- o texto pode ser entendido sem consultar a fonte;
- o título segue `# HU{ID} — Descrição narrativa`.

Se faltar apenas detalhe não essencial, não inventar: omitir o detalhe. Se a omissão tornar a
narrativa ambígua, pedir contexto.

### 5. Aprovar e salvar

Antes de escrever, mostrar:

- resumo curto do conteúdo que será produzido;
- fontes utilizadas;
- caminho exato do arquivo de saída.

Esperar aprovação explícita. Depois, salvar em UTF-8 e devolver o caminho do arquivo.

## Limites

- Pedido para consolidar a documentação da HU: usar `doc-consolidator`.
- Pedido explícito de HU formal em `.docx`, após revisão do consolidado: usar `hu-generator`.
- Pedido para alterar requisitos: voltar à documentação fonte; não corrigir somente a narrativa.
