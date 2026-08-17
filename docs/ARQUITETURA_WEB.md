# Arquitetura — Harness `.agents/` como aplicação web multiusuário

> Documento de estudo. Explica como transformar este harness num serviço web
> acessível por vários funcionários da empresa. Não é código de produção — é o mapa
> das decisões e do caminho.
>
> **Escopo: ferramenta interna.** Um time, uma empresa, billing centralizado. O cenário
> de vender o harness como produto multi-cliente tem outras decisões (cobrança por
> assento, ICP, margem) e vive em [`ESTRATEGIA.md`](ESTRATEGIA.md).
>
> Irmãos: [`AGENT_SDK.md`](AGENT_SDK.md) (como o backend fala com o runtime) ·
> [`HUB.md`](HUB.md) (telas do modo aplicativo) · [`MODOS.md`](MODOS.md) (repositório ×
> aplicativo) · [`ARCHITECTURE.md`](ARCHITECTURE.md) (camadas do harness).

---

## 1. O que estamos construindo

Hoje o `.agents/` é config de **CLI local** (Claude Code / Codex / opencode) que roda
na máquina de quem tem o repositório. O objetivo é expor esse mesmo harness como um
**app web**: o funcionário abre o navegador, loga, e usa as skills (discovery,
backlog, design, documentação) sem terminal e sem instalar nada.

---

## 2. Conceitos-chave (não confundir)

| Peça | O que é | Onde roda |
|---|---|---|
| **Harness** | O `.agents/` — constituição, profissões, workflows, providers, adapters | Seu servidor |
| **Runtime / CLI** | Claude Code, Codex, opencode — o loop de agente + ferramentas | Seu servidor (headless) |
| **Modelo** | Opus, GPT, GLM etc. — a inteligência | Provedor (Anthropic/OpenAI/...) via rede |
| **API key** | Credencial de billing por token | Segredo no servidor |
| **MCP** | Conector de dados da empresa (GitLab, banco, wiki) | Servidor / gerenciado |

**Regra mental:** o servidor roda o *harness*, não o *modelo*. O modelo é sempre
chamada de rede pro provedor. O servidor é o intermediário que autentica, carrega
contexto, controla acesso a dados e faz streaming do chat.

---

## 3. Login e billing — modelo central

**Funcionário NÃO tem conta Anthropic/OpenAI.** Ninguém no time precisa de login de
provedor nem de assinatura Pro/Max.

```
Funcionário → login no SEU app (SSO da empresa: Google Workspace / Microsoft)
SEU app     → 1 chave de API por provedor (billing por token, centralizado)
```

- **Uma** credencial de API no servidor por provedor. Você paga tudo, controla custo,
  audita uso.
- Assinatura Pro/Max **não serve**: é por pessoa, cota individual, uso interativo —
  quebra em cota e sai do escopo de licença assim que vira produto multiusuário.
- **Use API key + billing por token.** Escala por uso, não por assento.

> **Cuidado ao ler isto como modelo comercial.** "Por uso, não por assento" é o custo
> **interno** — como a empresa paga a Anthropic. Se o harness virar produto vendido a
> terceiros, o preço ao cliente é por assento com a inferência embutida; o custo por
> token continua sendo por uso, por baixo. São duas camadas, não uma contradição.

---

## 4. Multiusuário (multi-tenancy) — você constrói

O provedor não guarda "o projeto do João". Seu app guarda. Isolamento é
responsabilidade do **seu backend**.

```
Banco de dados (você define):
  usuarios   (id, email, papel)
  projetos   (id, dono_id, nome)
  sessoes    (id, projeto_id, historico)
  arquivos   (id, projeto_id, ...)
  credenciais(id, usuario_id, mcp_ref)   # segredos por usuário, se necessário
```

Cada request carrega `userId` → backend filtra os dados dele → passa só o contexto
dele pro harness. **Se não filtrar, vaza.** Dados da empresa por usuário: use
**vaults** (provedor guarda o segredo, injeta no egress) ou o backend segura a
credencial e filtra por `userId` antes de chamar o MCP.

---

## 5. Arquitetura por adapters (o caminho deste projeto)

Este harness já roda em três runtimes (`runtime/{claude,codex,opencode}`) sobre uma
**visão resolvida única**: `runtime/build.sh` mescla `system/` + `org/` em
`runtime/skills/`, e os três adapters leem daí. A camada compartilhada de verdade é
`system/CONSTITUTION.md` (L0) + `system/professions/` (L1) + os workflows resolvidos —
o `AGENTS.md` da raiz do projeto é só o ponto de entrada por convenção que Codex e
opencode procuram, espelhando as regras de engajamento.

A arquitetura web reaproveita isso: **um serviço wrapper por runtime**, cada um rodando
o CLI em modo headless.

```
Frontend (chat web, escolhe runtime + modelo)
        │  HTTP / WebSocket (streaming)
        ▼
Backend (auth + multi-tenancy)  ── comum a todos ──
        │  roteia por adapter:
        ├─ Adapter Claude   → claude -p --output-format stream-json   (ou Agent SDK)
        ├─ Adapter Codex    → codex exec                              (não-interativo)
        └─ Adapter opencode → opencode serve (HTTP)                   (JÁ multi-modelo)
                 │  todos leem a mesma visão resolvida: runtime/skills/
                 ▼
        Provedores de modelo (Anthropic / OpenAI / GLM / DeepSeek...)
                 │
        MCP servers (GitLab, banco de homologação, wiki)
```

**Ponto que economiza trabalho:** o **opencode já é multi-modelo**. Não precisa de um
adapter por modelo. Dois adapters cobrem quase tudo:

- **opencode** → porta multi-modelo (GPT, Claude, GLM, DeepSeek, Qwen...).
- **Claude Agent SDK** → poder agêntico máximo do Claude (skills nativas, ferramentas).

### Pegadinha (limite real)
O **conteúdo** (constituição, métodos, workflows em markdown) porta entre runtimes — já
provado neste repositório. A **execução** varia: skill como mecanismo de primeira classe é mais forte
no Claude Code; Codex/opencode leem a instrução mas invocam ferramenta/skill de jeito
próprio. Por isso as pastas `runtime/` são separadas. No web app: mesma skill,
resultado ligeiramente diferente conforme o runtime. **Testar cada um.**

---

## 6. Multi-modelo (GPT, Claude, GLM, chineses)

Duas formas:

- **A) Adapter por harness (recomendado aqui):** wrap dos CLIs (opencode cobre vários
  modelos sozinho). Mantém o poder agêntico + as skills.
- **B) Gateway de chat puro:** OpenRouter / LiteLLM / Vercel AI SDK — 1 integração,
  centenas de modelos, mas **chat simples** (sem harness, sem skills, sem ferramentas).

A maioria dos modelos chineses (DeepSeek, Qwen, GLM, Moonshot) é **OpenAI-compatible** —
um adapter cobre vários trocando `base_url`.

Trade-off central:

| Objetivo | Caminho |
|---|---|
| Chat multi-modelo simples | Gateway (OpenRouter/LiteLLM) |
| Agente completo com skills | Adapter de harness (opencode / Claude SDK) |
| Os dois | Backend com dois modos: "chat" (gateway) + "agente" (adapter) |

---

## 7. Alternativa que elimina hospedagem pesada — Managed Agents

Se rodar servidor assusta: **Claude Managed Agents (CMA)**. A Anthropic roda o loop
**e** o sandbox. Você define o agente uma vez (config versionada) e abre sessões via
API. Ainda precisa de um backend leve pra auth + multi-tenancy, mas sem rodar loop nem
sandbox. Troca: menos infra sua, mais dependência do provedor (beta) e menos controle.
Só funciona pra runtime Claude.

---

## 8. Hospedagem — escala por estágio

| Estágio | Onde | Esforço |
|---|---|---|
| Protótipo / MVP | 1 VPS (a mesma do protótipo) + Docker | baixo |
| Time pequeno (~10–30) | VPS maior ou container gerenciado (Railway/Render/Fly.io) | baixo–médio |
| Empresa inteira | Cloud gerenciada (AWS ECS / GCP Cloud Run) + banco gerenciado | médio |

Stack mínima:

```
- Backend Node/Python (adapters headless)  → 1 container
- Banco Postgres                            → 1 instância
- Frontend estático (React)                 → CDN ou mesmo servidor
- SSO                                       → Auth0 / Clerk / Google (não codar do zero)
```

Começa numa VPS. Migra pra cloud gerenciada quando o time crescer. Não precisa AWS
complexo no dia 1.

---

## 9. Automação (rodar sozinho, sem ninguém pedir)

Dois modos:

1. **Sob demanda:** funcionário abre chat, pede, agente age.
2. **Agendado (cron):** agente roda sozinho. Ex.: "toda segunda gera relatório do
   backlog", "toda noite audita issues sem tipo". Skills como `backlog-analysis`,
   `backlog-health`, `gitlab-sprint-ops` viram jobs agendados naturais.

Managed Agents tem **scheduled deployments** nativo. Com adapter próprio, um cron no
servidor dispara o CLI headless.

---

## 10. Segurança (checklist mínimo)

- Segredos (API keys, tokens MCP) **só no servidor** — nunca no frontend, nunca no
  prompt, nunca no histórico de sessão.
- Isolar por `userId` em **toda** query e em todo contexto passado ao harness.
- Rodar CLIs headless em ambiente isolado (container por sessão / usuário) se
  executarem código ou bash.
- Limite de custo por usuário / por sessão (teto de tokens).
- Auditoria: logar quem pediu o quê, qual modelo, quanto custou.
- Modelo mais barato pra tarefa simples (Haiku/Sonnet vs Opus) + prompt caching pra
  cortar custo.

---

## 11. Recomendação / roadmap sugerido

1. **MVP (1 VPS):** backend Node com **1 adapter** (`claude -p` headless lendo
   `.agents/skills`), 1 endpoint de chat com streaming, SSO simples (Google), sem
   multi-tenancy ainda. Prova o fluxo ponta a ponta.
2. **Multiusuário:** adiciona Postgres, isolamento por `userId`, projetos por usuário.
3. **Multi-modelo:** adiciona adapter **opencode** (já multi-modelo) como modo "chat".
4. **Automação:** cron pros jobs agendados (backlog, saúde de sprint).
5. **Escala:** migra pra container gerenciado quando passar de ~dezenas de usuários.

**Decisão que define o resto:** rodar o servidor você mesmo (adapters headless,
controle total, skills portam direto) **ou** deixar a Anthropic rodar (Managed Agents,
menos infra, só Claude, beta).

Recomendação pro momento atual: **começar com adapter Claude headless numa VPS** —
você já tem VPS, controle total, custo previsível, e as skills portam sem reescrita.

---

## 12. Estimativa de custo — feita

Os números foram levantados em **17/08/2026** — detalhe completo em
[`ESTRATEGIA.md`](ESTRATEGIA.md) §5 "Economia". Resumo do que ficou apurado:

| Item | Valor |
|---|---|
| Custo por documento de requisito completo (Opus, com cache) | ~$0,55 |
| Custo por tela de protótipo | ~$1,00 |
| Assento pesado, tudo em Opus | ~$50/mês |
| Assento pesado, com roteamento Haiku/Sonnet/Opus | ~$20–25/mês |

Duas alavancas fazem quase todo o trabalho:

1. **Prompt caching.** L0 + profissão + métodos + overlay da org ≈ 30–40k tokens
   estáveis e idênticos entre todos os usuários da mesma organização. Leitura de cache
   custa 0,1× do input — carregar o harness inteiro cai de ~$0,20 para ~$0,02.
2. **Roteamento por modelo.** Haiku para extração e triagem, Sonnet para escrita, Opus
   só na síntese. Corta o custo pela metade ou mais.

**O que realmente queima dinheiro não é gerar documento — é agente autônomo em loop sem
teto** (§9). Um cron aberto pode consumir 500k+ tokens numa execução. Todo job agendado
nasce com teto: `session budget` (Managed Agents pausa em `budget_reached`),
`task_budget` (o modelo se autorregula) e `effort` calibrado por rota.
