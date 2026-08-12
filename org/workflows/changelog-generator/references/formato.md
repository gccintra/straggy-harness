# Formato — Histórico de Evolução (Changelog)

## Estrutura da tabela

```markdown
# Histórico de Evolução - [PROJETO] (Changelog)
| Data Criação | OS Contratual | Épico / HU | Descrição da Mudança (Delta) | Telas Impactadas |
| :--- | :--- | :--- | :--- | :--- |
| DD/MM/AAAA | OSXXXXXXX | XXX.YY | **[TIPO] Título:** Descrição em prosa. | Tela A, Tela B |
```

### Regras de formatação

- O alinhamento de todas as colunas é à **esquerda** (`:---`).
- **Épico / HU** usa apenas o número no formato `XXX.YY` (sem o prefixo "HU").
- A coluna **Descrição da Mudança (Delta)** sempre começa com o tipo em negrito: `**[TIPO] Título:**`.
- A tabela é ordenada por **Data Criação decrescente** (entradas mais recentes no topo).

---

## Exemplo completo de referência

```markdown
# Histórico de Evolução - [PROJETO] (Changelog)
| Data Criação | OS Contratual | Épico / HU | Descrição da Mudança (Delta) | Telas Impactadas |
| :--- | :--- | :--- | :--- | :--- |
| 13/02/2026 | OS2026082 | 003.17 | **[ALTERADO] Melhoria UX Mobile:** Adaptação e otimização do fluxo de vistoria para dispositivos móveis, contemplando a nova visualização da listagem de visitas e a implementação de filtros avançados otimizados para telas menores. | Listar Visitas (Mobile), Filtros Avançados |
| 12/02/2026 | OS2026085 | 003.16 | **[ALTERADO] Evolução de Ocorrências:** Refatoração do fluxo de ocorrências e encerramento de visitas. Contempla pesquisa livre, clonagem para múltiplos blocos, obrigatoriedade e alertas (Bloco, Foto, Tipo), campo de observações sincronizado, trava de encerramento por dados incompletos e reflexo no Laudo PDF. | Listagem, Incluir/Editar Ocorrência, Encerrar/Editar Visita, Laudo PDF |
| 12/02/2026 | OS2026081 | 004.01 | **[NOVO] Integração Power BI:** Inclusão de um novo menu de atalho no cabeçalho superior (visível apenas para o perfil Engenheiro/GEENG) contendo links de redirecionamento direto para os Dashboards externos de Execução Orçamentária e Gestão de Contratos. | Cabeçalho Global (Header) |
| 12/02/2026 | OS2026081 | 002.6 | **[ALTERADO] Permissões de Projeto:** Alteração na matriz de acessos (Roles) do sistema, concedendo privilégios de edição na seção de Fases do Projeto especificamente para usuários com o perfil de "Unidade". | Dados do Projeto (Aba de Fases) |
```

---

## Mapeamento de campos: documento → changelog

| Campo no documento de HU | Coluna no changelog |
|---|---|
| Data de Emissão | Data Criação |
| Ordem de Serviço | OS Contratual |
| Identificação da HU (ex: HU003.17) | Épico / HU → extrair só `003.17` |
| Escopo + HU + CAs | Descrição da Mudança (Delta) → sintetizar |
| Seção "Protótipo" / CAs / Escopo | Telas Impactadas |

---

## Guia de escolha do tipo

| Situação | Tipo |
|---|---|
| Nova tela, novo menu, novo campo, nova integração, nova permissão que antes não existia | `[NOVO]` |
| Alteração de comportamento existente, mudança de layout, nova regra em funcionalidade já existente, ajuste de permissão | `[ALTERADO]` |
| Correção de erro ou comportamento incorreto | `[CORRIGIDO]` |
| Retirada de funcionalidade, campo ou acesso | `[REMOVIDO]` |
