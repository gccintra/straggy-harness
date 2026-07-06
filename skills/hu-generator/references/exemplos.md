# Exemplos de Referência — HUs

Estes exemplos representam o padrão oficial de documentação de HU do projeto.
Use-os como referência de tom, estrutura e nível de detalhe esperado.

---

## Exemplo 1 — HU com Interface Mobile (HU003.17)

**Contexto:** Funcionalidade de melhoria de usabilidade em dispositivo móvel.
**Característica:** Tem múltiplos CAs cobrindo mobile vs desktop, organizados em subseções.

### 1. Entendendo o Problema

**Persona:** Engenheiro (GEENG)

**Cenário do Usuário (Dor):**
Atualmente, ao tentar realizar uma vistoria pelo celular, o usuário depara-se com a mesma interface complexa do computador. A tela traz excesso de informações, botões pequenos e exibe visitas de todos os técnicos, o que atrasa a execução do trabalho em campo e prejudica a usabilidade durante a vistoria.

### 2. História de Usuário

| | |
|---|---|
| **Como** | um Técnico/Engenheiro em campo, |
| **Quero** | acessar uma interface de visitas otimizada e exclusiva para dispositivos móveis, focada apenas nas minhas demandas, |
| **Para** | conseguir iniciar e registrar a minha vistoria com agilidade, sem me perder em menus complexos ou dados de outros técnicos. |

### 3. Escopo

Esta entrega contempla a criação de uma experiência responsiva dedicada (**Mobile First**) para a tela de **Visitas**. O escopo inclui a reformulação do layout exclusivo para telas de celular, focando nas ações de execução de vistoria.

### 4. Critérios de Aceitação

#### 4.1. Layout e Carregamento Mobile

- **CA01:** **Dado que** acesso o sistema, **Quando** o acesso for realizado através de um dispositivo móvel (celular), **Então** o sistema deve carregar o novo layout de visitas, com botões e cards otimizados para toque (touch) e leitura vertical.

#### 4.2. Filtro de Técnico Logado

- **CA02:** **Dado que** estou na listagem de visitas pelo celular, **Quando** a tela for carregada, **Então** o sistema deve exibir exclusivamente as visitas onde o meu usuário logado está vinculado como técnico.
- **CA03:** **Dado que** estou no layout mobile de visitas, **Quando** tento alterar as opções de filtragem de técnicos, **Então** o sistema não deve permitir a visualização de visitas de terceiros (o filtro do técnico logado deve ser fixo/bloqueado na interface mobile).

#### 4.3. Comportamento Desktop

- **CA04:** **Dado que** acesso o sistema, **Quando** o acesso for realizado através de um computador (Desktop), **Então** o sistema deve carregar o layout padrão já existente da tela de Visitas, mantendo todos os filtros e listagens no comportamento atual.

### 5. Regras

**Regras de Negócio (RN) criadas ou editadas nesta HU:**

- N/A

**Regras de Apresentação (RA) criadas ou editadas nesta HU:**

- N/A

**Mensagens do Sistema (MSG) criadas ou editadas nesta HU:**

- N/A

### 6. Descrição de Interface

[preencher manualmente]

### 7. Complemento de Documentação

**Documento de Regras de Negócio:**

**Link do Protótipo de Telas Impactadas:**

---

## Exemplo 2 — HU de Permissão/Roles (HU002.6)

**Contexto:** Alteração de matriz de permissões — sem nova interface, apenas liberação de acesso.
**Característica:** Escopo enxuto e objetivo. CAs focados em comportamento por perfil.

### 1. Entendendo o Problema

**Persona:** Gestor de Unidade (Perfil UNIDADE)

**Cenário do Usuário (Dor):**
O usuário com perfil de Unidade acompanha a obra de perto, mas não possui permissão no sistema para atualizar ou editar as "Fases do Projeto". Isso cria um gargalo operacional, pois ele precisa solicitar a outro perfil que faça as atualizações em seu lugar.

### 2. História de Usuário

| | |
|---|---|
| **Como** | um usuário com perfil de Unidade, |
| **Quero** | ter permissão para editar os dados da funcionalidade de Fases do Projeto, |
| **Para** | conseguir manter o andamento e o cronograma da obra atualizados de forma autônoma, refletindo a realidade local sem depender da equipe central. |

### 3. Escopo

Esta entrega contempla exclusivamente a alteração na **matriz de permissões de acesso** do sistema (Roles). O perfil **"Unidade"** passará a ter privilégios de edição na tela de **Fases do Projeto**, com a liberação de componentes já existentes (botões de salvar/editar) para este perfil específico.

### 4. Critérios de Aceitação

#### 4.1. Acesso e Edição pelo Perfil Unidade

- **CA01:** **Dado que** estou logado com o perfil "Unidade" e acesso a aba de Dados do Projeto, **Quando** a tela for carregada, **Então** os botões de edição de fase devem estar visíveis e habilitados para clique.
- **CA02:** **Dado que** altero informações de uma fase de projeto utilizando o perfil "Unidade", **Quando** clico no botão de Salvar, **Então** o sistema deve gravar as alterações com sucesso e exibir a mensagem de sucesso padrão.

#### 4.2. Restrição de Outros Perfis

- **CA04:** **Dado que** um usuário com perfil estritamente de Leitura acessa a tela de Fases do Projeto, **Quando** a tela carregar, **Então** os campos e botões de edição devem permanecer bloqueados, garantindo que a permissão foi concedida apenas à Unidade.

### 5. Regras

**Regras de Negócio (RN) criadas ou editadas nesta HU:**

- N/A

**Regras de Apresentação (RA) criadas ou editadas nesta HU:**

- N/A

**Mensagens do Sistema (MSG) criadas ou editadas nesta HU:**

- N/A

### 6. Descrição de Interface

[preencher manualmente]

### 7. Complemento de Documentação

**Documento de Regras de Negócio:**

**Link do Protótipo de Telas Impactadas:**

---

## Exemplo 3 — HU de Componente de Navegação (HU004.01)

**Contexto:** Novo elemento no cabeçalho global, restrito por perfil, com redirecionamentos externos.
**Característica:** CAs cobrem visibilidade por perfil, comportamento do dropdown e URLs de destino.

### 1. Entendendo o Problema

**Persona:** Engenheiro (GEENG)

**Cenário do Usuário (Dor):**
Atualmente, o Engenheiro precisa sair do seu fluxo de trabalho no sistema ou buscar links perdidos em e-mails para consultar os painéis gerenciais do Power BI (Orçamentário e Contratos). Falta um atalho rápido e restrito na própria plataforma para facilitar o acompanhamento dessas métricas sem perder o contexto da navegação.

### 2. História de Usuário

| | |
|---|---|
| **Como** | um usuário com perfil de GEENG |
| **Quero** | ter acesso a um menu restrito no cabeçalho do sistema com links rápidos para os dashboards de Orçamento e Contratos, |
| **Para** | conseguir consultar essas informações financeiras do Power BI a qualquer momento e de qualquer tela, com segurança e sem perder a minha navegação atual. |

### 3. Escopo

Esta entrega contempla a inclusão de um novo **ícone no cabeçalho global (Header)** do sistema, exclusivo para usuários com o perfil **GEENG**. O ícone abrirá um dropdown com dois atalhos de redirecionamento para o **Power BI**: Painel de Execução Orçamentária e Painel Gestão de Contratos. Nenhum outro perfil terá acesso a este componente.

### 4. Critérios de Aceitação

#### 4.1. Visibilidade por Perfil

- **CA01:** **Dado que** estou logado no sistema com o perfil "GEENG", **Quando** visualizo o cabeçalho superior (Header), **Então** devo visualizar o novo ícone de acesso aos Dashboards de BI.
- **CA02:** **Dado que** estou logado com qualquer outro perfil que não seja o GEENG (ex: Unidade, Alta Gestão, Auditor), **Quando** visualizo o cabeçalho superior, **Então** o ícone de Dashboards de BI **não** deve ser exibido.

#### 4.2. Comportamento do Dropdown

- **CA03:** **Dado que** clico no ícone de Dashboards (como GEENG), **Então** o sistema deve abrir um menu suspenso (dropdown) listando exatamente duas opções: "Painel de Execução Orçamentária" e "Painel Gestão de Contratos".

#### 4.3. Redirecionamentos

- **CA04:** **Dado que** clico na opção "Painel de Execução Orçamentária", **Então** o sistema deve me redirecionar para a URL do painel orçamentário em uma nova aba do navegador.
- **CA05:** **Dado que** clico na opção "Painel Gestão de Contratos", **Então** o sistema deve me redirecionar para a URL do painel de contratos em uma nova aba do navegador.

### 5. Regras

**Regras de Negócio (RN) criadas ou editadas nesta HU:**

- N/A

**Regras de Apresentação (RA) criadas ou editadas nesta HU:**

- N/A

**Mensagens do Sistema (MSG) criadas ou editadas nesta HU:**

- N/A

### 6. Descrição de Interface

[preencher manualmente]

### 7. Complemento de Documentação

**Documento de Regras de Negócio:**

**Link do Protótipo de Telas Impactadas:**

---

## Padrões Observados nos Exemplos

### Tom dos CAs
- Sempre em primeira pessoa do ponto de vista do usuário ou terceira pessoa do sistema.
- "Então o sistema deve..." para comportamentos do sistema.
- "Então devo visualizar..." quando o sujeito é o próprio usuário.

### Subseções dos Critérios de Aceitação
- Os CAs são sempre agrupados em subseções temáticas (Heading 3), ex: "4.1. Visibilidade por Perfil".
- Os nomes das subseções devem refletir o agrupamento lógico dos cenários daquela HU.
- Cada subseção contém os CAs relacionados ao seu tema.

### Seção 3 — Escopo
- **1 parágrafo curto (~3 frases), resumo concreto.** O que a entrega cobre — funcionalidade, ponto de acesso e principais comportamentos, de forma compacta. Apenas o que está dentro do escopo (não descreva o que fica de fora).
- Pode citar os componentes principais de forma compacta; **não** faz lista exaustiva campo-a-campo nem repete verbatim os CAs/regras (o detalhe vai nas seções 4 e 5).
- Usa **bold** em 1–2 termos-chave (nome da tela, perfil, funcionalidade).

**Exemplos de estilo (calibração — é exatamente este nível):**

> Tela de visualização detalhada, em modo leitura, acessível via botão **"Detalhar"** no Hub de Aditivos. Exibe dados contratuais, naturezas detalhadas, cronograma físico-financeiro e resumo de impactos. Interface 100% **readonly** com seções colapsáveis.

> Esta entrega implementa a **exclusão lógica** de termos aditivos via modal de confirmação. O processo garante atomicidade, recálculo em cascata dos aditivos subsequentes, rastreabilidade via histórico e sinalização de inconsistências.

> Esta entrega permite a **edição de qualquer aditivo** contratual, reaproveitando o wizard de criação com validações em tempo real. Ao salvar, o sistema gera automaticamente um registro de histórico com snapshot e diff das alterações. Caso o aditivo não seja o último da fila, o sistema sinaliza inconsistência nos registros subsequentes e atualiza o histórico de impacto.

### Seção 5 — Regras de Negócio
- Sempre gerada com os três placeholders fixos (RN, RA, MSG), cada um seguido de bullet "N/A".
- O usuário substitui "N/A" pelas regras reais quando aplicável.

### Seção 6 — Descrição de Interface
- Gerada vazia. O usuário preenche manualmente.

### Seção 7 — Complemento de Documentação
- Sempre gerada com os dois placeholders em negrito: "Documento de Regras de Negócio:" e "Link do Protótipo de Telas Impactadas:".

### Numeração de CAs
- Numere sequencialmente a partir de CA01.
- Se um CA foi removido durante o refinamento, pode haver lacuna na numeração (ex: CA01, CA02, CA04 — sem CA03). Isso é aceitável e deve ser respeitado.

### Escopo: o que sempre mencionar
- O que está **incluído** na entrega.
- O que está **excluído** (principalmente quando outra parte do sistema poderia ser afetada mas não será).
- Se há ou não criação de novas telas.
