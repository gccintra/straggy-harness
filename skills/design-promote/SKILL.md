---
name: design-promote
description: >
  Gera a versão LIMPA de uma tela no Figma (fluxo B) — node com nomes coerentes,
  Auto Layout real, tokens vinculados e componentes reusados — via use_figma, a partir
  de um HTML aprovado (--from-html) ou de um node sujo já capturado pelo fluxo A
  (--from-node). É o passo de "entregável" oposto ao preview rápido do html-to-figma
  (capture.js). Acione quando o usuário pedir para "promover", "limpar", "gerar versão
  limpa", "transformar em componentes" ou "deixar editável na mão" uma tela no Figma.
  Requer design system publicado (variáveis/componentes) pela skill design-setup.
  IMPORTANTE: push pro Figma é escrita externa — pede aprovação antes de rodar o motor.
---

# design-promote

Produz a **versão limpa (fluxo B)** de uma tela no Figma: node com nomes explícitos, Auto Layout real, variáveis vinculadas e componentes reusados — editável na mão, sem árvore "Container".

Contraste com o **fluxo A** (`html-to-figma` / capture.js): A é preview rápido e descartável, espelha o DOM 1:1 e produz árvore poluída sem naming. B é o entregável, montado via `use_figma` (API do Figma), on-demand.

**Motor:** a skill oficial `figma-generate-design`. Esta skill NÃO reimplementa o builder — ela prepara a spec e delega. Ao chamar `use_figma`, inclua `figma-generate-design` (e `resource:figma-generate-design` se carregada via MCP resource) no `skillNames`.

---

## Pré-requisitos

Leia do `.env`:
```
FIGMA_FILE_KEY:       ${FIGMA_FILE_KEY}
FIGMA_VARIABLES_MAP:  ${FIGMA_VARIABLES_MAP}    ← json de keys de variáveis publicadas
FIGMA_COMPONENTS_MAP: ${FIGMA_COMPONENTS_MAP}   ← json de keys de componentes publicados
```

**Se os mapas não existirem ou estiverem vazios:**
> "O design system ainda não foi publicado como variáveis/componentes no Figma. Rode a `design-setup` (Etapa 4b) primeiro. Posso promover mesmo assim, mas a saída sai com nodes nomeados sem tokens vinculados nem instâncias de componente. Prefere assim ou publica o DS antes?"

Não invente keys. Se um componente necessário não está no mapa, use frame nomeado com tokens no lugar da instância — nunca chute uma key.

---

## Modos de entrada

Detecte o modo pelo argumento. Se ambíguo, pergunte qual.

### Modo A — `--from-html <caminho.html>`  (fluxo HTML→B)

Entrada preferida: o HTML aprovado é a fonte de verdade (tem semântica e tokens).

1. Ler o HTML. Mapear a estrutura em seções (header, form, tabela, footer...).
2. Para cada bloco, resolver o token/componente correspondente nos mapas do `.env`.
3. Delegar ao motor (ver "Montagem via motor B").

### Modo B — `--from-node <nodeId>`  (fluxo A→B)

Entrada de recuperação: promove um node sujo que o usuário já ajustou na mão no Figma.

1. `get_metadata(fileKey, nodeId)` para ler a árvore capturada.
2. **Inferir a spec** — agrupar "Container" por geometria/proximidade/texto, detectar repetição (→ componente), inferir hierarquia de seções.
3. Delegar ao motor.

> **AVISO obrigatório ao usuário antes de rodar:** A→B é **best-effort e lossy** — a captura do fluxo A jogou fora a semântica (tudo virou "Container"), então a inferência adivinha o papel de cada bloco e pode errar. Se o HTML de origem ainda existe, **prefira `--from-html`** (fiel à intenção, mais barato). Só use `--from-node` quando os ajustes manuais no Figma são a fonte de verdade e não estão no HTML.

---

## Montagem via motor B (comum aos dois modos)

Siga a skill `figma-generate-design`:

1. **Wrapper primeiro**, nomeado, `width: 1280` (padrão desktop do projeto), Auto Layout vertical. Posicione longe do conteúdo existente.
2. **Seção por seção**, cada uma em sua chamada `use_figma`:
   - Nome explícito por node (`section.name = "Cabeçalho"`, não "Container")
   - Auto Layout real
   - `setBoundVariable` com as variáveis dos mapas (não hex/px hardcoded)
   - Instância de componente publicado quando existir no `FIGMA_COMPONENTS_MAP`; senão, frame nomeado com tokens
   - Override de texto de instância via `setProperties()`
3. **Validar cada seção com `get_screenshot`** antes de seguir — cheque texto cortado e sobreposição.
4. `outputMode="existingFile"`, `fileKey=${FIGMA_FILE_KEY}`.

---

## Write-gate

Push pro Figma é escrita externa (regra do `.agents/ENGAGEMENT.md`). Antes de rodar o motor:
1. Mostre o resumo: modo, origem (arquivo/nodeId), quantas seções, quais componentes/tokens serão usados, arquivo de destino.
2. Se `--from-node`, mostre também o aviso de lossy.
3. Espere "pode" explícito. Só então rode.

---

## Fluxo default (parada segura)

Este é um passo de **entregável** — nunca automático. Só roda sob pedido explícito ("promove", "gera versão limpa"). Para iteração rápida do dia a dia, o caminho é o fluxo A (`design-screen` → preview local). O promote é a conversão final, quando a tela merece.

---

## Registrar em history/

Crie `history/YYYY-MM-DD_promote_<nome-curto>.md`:

```markdown
# [PROMOTE B] <Nome da tela>
Data: YYYY-MM-DD
Agente: designer
Modo: --from-html <arquivo> | --from-node <nodeId>

## Origem
[HTML aprovado / node ajustado na mão]

## Design system usado
- Variáveis: [tokens vinculados]
- Componentes: [instâncias reusadas / frames nomeados quando faltou componente]

## Figma
- Arquivo: ${FIGMA_FILE_KEY}
- Node limpo gerado: [URL]

## Notas
- [se --from-node: onde a inferência foi incerta]
- [componentes que faltavam no mapa e viraram frame]
```

---

## Limites honestos

- **A→B é lossy** — a semântica se perde na captura A; a inferência adivinha. `--from-html` é sempre melhor quando o HTML existe.
- **Custo do B é inerente** — N seções = N chamadas `use_figma`. A amortização (mapas cacheados no design-setup) corta só o discovery, não o build. Por isso B é on-demand, 1x por entregável, não por iteração.
- **Sem componentes publicados** — B ainda gera nomes + Auto Layout + tokens, mas com frames em vez de instâncias. Publique componentes na `design-setup` (Etapa 4b) para ganhar reuso.
