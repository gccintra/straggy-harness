# Claude Agent SDK — o que é e como usar pra web

> Documento de estudo. Explica o Claude Agent SDK: o que é, como se relaciona com
> o Claude Code, e por que facilita construir uma interface web sobre este harness.
> Complementa [`ARQUITETURA_WEB.md`](ARQUITETURA_WEB.md).

---

## 1. O que é

O **Claude Agent SDK** (`@anthropic-ai/claude-agent-sdk` em Node, `claude-agent-sdk`
em Python) é o **Claude Code empacotado como biblioteca**. Mesmo motor da TUI que você
usa no terminal — só que chamado por código, sem interface interativa.

Traz pronto:

- loop de agente (pensa → chama ferramenta → lê resultado → repete),
- ferramentas embutidas: Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch,
- subagentes, permissões, sessões, gerência de contexto,
- suporte a MCP (conectores de dados: GitLab, banco, wiki).

Você chama `query(prompt, options)` e o SDK dirige tudo.

---

## 2. SDK vs Claude headless (CLI) — mesmo motor

Duas formas de rodar Claude Code sem a TUI. **Mesma engine por baixo.**

| | Claude headless (CLI) | Claude Agent SDK |
|---|---|---|
| Como chama | `claude -p "..." --output-format stream-json` | `import { query }` → `query(prompt, opts)` |
| Mecânica | `spawn` do binário, lê stdout, parseia JSON | biblioteca in-process, eventos tipados |
| Você gerencia | subprocesso, parsing, buffer, erro | nada disso — o SDK cuida |
| Motor | **Claude Code** | **Claude Code** |

Diferença é ergonomia de integração, não capacidade. Pra backend web, o SDK é mais
limpo: eventos tipados, sessão/permissão gerenciadas, sem subprocesso.

**Importante:** "headless" tira só a TUI. O modelo (Opus) continua rodando na
Anthropic via rede — o servidor roda o *harness*, não o *modelo*.

---

## 3. Por que facilita construir o front

O SDK entrega **eventos estruturados e tipados** — cada coisa vem etiquetada. Você não
parseia texto cru nem adivinha o que aconteceu; o evento já diz o tipo.

| Evento | O que a UI mostra |
|---|---|
| `text` / mensagem | balão de resposta no chat |
| `tool_use` (Edit) | "✏️ editando `arquivo.tsx`" |
| `tool_use` (Bash) | "⚙️ rodando `npm test`" |
| `tool_use` (Grep/Read) | "🔍 buscando..." / "📖 lendo arquivo" |
| `tool_result` | resultado da ação (diff, saída do comando) |
| `thinking` | "pensando..." (opcional) |
| permission request | modal "permitir editar X?" |

UI vira um `switch` no tipo do evento → renderiza o componente certo. É a mesma camada
de eventos que a TUI do Claude Code usa — a Anthropic já construiu isso; você só desenha
por cima.

**Limite:** o SDK entrega o *dado estruturado*; os *componentes visuais* (como mostrar
um diff, um card de comando, um modal) são você que faz. Ainda assim, muito mais fácil
que parsear texto cru.

---

## 4. Autenticação e billing

O SDK autentica por **API key** (`ANTHROPIC_API_KEY`) — billing por token no Console
Anthropic. É o modelo certo pra app multiusuário: uma credencial central no servidor,
você paga por uso, controla custo e audita.

Não usar assinatura Pro/Max pra isso: é por pessoa, cota individual, uso interativo —
fora do escopo pra produto servindo o time.

Detalhe: o SDK também aceita login OAuth de assinatura (herdado do Claude Code CLI), mas
**não use** esse caminho pra app da empresa — só pra uso individual local.

---

## 5. Esqueleto mínimo (backend Node)

```javascript
import { query } from "@anthropic-ai/claude-agent-sdk";

// endpoint que o navegador chama
app.post("/chat", async (req, res) => {
  const { message, userId } = req.body;

  for await (const event of query(message, {
    // aqui entram system prompt, skills do .agents/, MCP servers
    mcpServers: [{ type: "url", name: "gitlab", url: "..." }],
    allowedTools: ["Read", "Grep", "Edit", "mcp__gitlab__*"],
  })) {
    // cada event é tipado — front decide como renderizar
    res.write(JSON.stringify(event) + "\n");
  }
  res.end();
});
```

Núcleo do fluxo. Produção adiciona: auth (SSO), isolamento por `userId`, limite de
custo por sessão, controle de permissão de ferramenta.

---

## 6. Relação com o harness deste repo

O harness resolve `system/` + `org/` numa visão única em `runtime/skills/`
(via `runtime/build.sh`), e os adapters de `runtime/{claude,codex,opencode}` leem daí.

- O **conteúdo** — constituição (L0), métodos das profissões (L1), workflows resolvidos —
  o Agent SDK carrega como system prompt / contexto. Porta direto.
- O **mecanismo de skill** (Skill tool, carregamento progressivo) é nativo do Claude Code,
  então o Agent SDK executa esses workflows melhor que Codex/opencode.
- Pra multi-modelo (GPT, GLM, chineses), o Agent SDK **não serve** — é só Claude. Use um
  adapter opencode em paralelo (já multi-modelo). Ver
  [`ARQUITETURA_WEB.md`](ARQUITETURA_WEB.md) §5–6.

---

## 7. Quando NÃO usar o Agent SDK

| Situação | Use |
|---|---|
| Quer multi-modelo (GPT/GLM/chineses) | Gateway (OpenRouter/LiteLLM) ou opencode |
| Não quer hospedar servidor | Managed Agents (Anthropic roda loop + sandbox) |
| Chat simples sem ferramentas agênticas | Messages API crua (`@anthropic-ai/sdk`) |
| Agente Claude completo, controle total | **Agent SDK** (este doc) |

---

## 8. Docs oficiais

- Claude Agent SDK: `code.claude.com/docs/en/agent-sdk`
- É biblioteca separada do `@anthropic-ai/sdk` (esse é a Messages API crua, sem harness).
