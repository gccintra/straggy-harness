---
name: design-brief
description: >
  Analisa uma demanda ANTES de construir a tela: lê a documentação do PM (.md consolidado, HU,
  issue), varre o protótipo existente (rotas, componentes de ui/, tokens, telas irmãs) e devolve
  em conversa o que a demanda vira na interface — onde entra na navegação, o que reusa, o que
  falta no design system, quais estados ninguém previu, o que quebra nas telas que já existem, e
  quais pendências voltam pro produto. Escala com a entrada: ajuste em tela existente não passa
  por aqui; texto simples vira análise leve; imagem vira análise média; documentação/issue vira
  análise completa. Gerar o documento de design ({ID}_design.md) é OPT-IN, no fim. Use quando o
  usuário pedir para analisar, avaliar, sugerir, discutir ou entender uma demanda de tela antes
  de codar — "analisa a #NNN", "lê a doc e me diz o que vira na tela", "o que você sugere?".
  IMPORTANTE: Carregue obrigatoriamente a skill `glab-backlog` antes de qualquer operação no GitLab.
---

**PRÉ-REQUISITO:** Carregar a skill `glab-backlog` antes de qualquer operação no GitLab.

# design-brief

A etapa de **pensar a interface** antes de escrever JSX. Read-only por padrão: você lê a demanda, lê o protótipo, e **conversa**. Nada é escrito até o usuário pedir o documento.

> **O que separa isto do `design-screen`:** `design-screen` responde *"como transcrevo esta referência?"*. `design-brief` responde *"o que esta demanda vira na interface, e o que ela quebra no que já existe?"* — pergunta que exige ler a doc de produto **e** o protótipo inteiro ao mesmo tempo.

**Você não bloqueia ninguém.** A brief é o **grau de análise**, não um pedágio. Ajuste trivial não passa por aqui.

---

## 0. Triagem — quanto de análise esta entrada merece

**Decida ANTES de ler qualquer coisa.** A profundidade sai da entrada, não do seu apetite.

| Entrada do usuário | Nível | O que você faz |
|---|---|---|
| **Ajuste** — a tela/componente já existe ("aumenta a fonte", "esse botão tá fora do padrão", "arruma o espaçamento") | **nenhum** | **Não rode esta skill.** Vá direto ao `design-screen` modo Ajuste. Analisar isto é desperdício. |
| **Texto simples**, tela nova, sem doc ("cria uma listagem de medições") | **leve** | Passos 1(rápido) + 2 + 3 resumido. 5-10 linhas de conversa: onde entra no menu, tela irmã, o que reusa, estados. Sem doc. |
| **Imagem/print de produção** como referência | **média** | Passos 2 + 3. A imagem já resolve o *layout*; você resolve **navegação, reuso e gaps**. Não meça pixel aqui — isso é `design-screen` 3B. |
| **Figma autoral** (o usuário desenhou a tela nova lá) | **média** | Passos 2 + 3. O desenho já resolve o layout **e o visual**; você resolve navegação, reuso de `ui/` e **o que é valor novo que entra no design system** (`design-screen` 3A). |
| **Wireframe / rabisco** (esboço feio, à mão, caixinha e seta) | **média-alta** ⚠ | Passos 2 + 3 + **§0.1 abaixo**. O rabisco dá **intenção, não visual** — e sempre deixa buraco. Esta brief é **obrigatória**: é aqui que você lê o rabisco em voz alta e tira as dúvidas de uma vez. |
| **Documentação / HU / issue `#NNN` / `.md` do PM** | **completa** | Passos 1 → 6. É onde esta skill vale mais. |

Na dúvida entre leve e completa: **olhe se existe doc**. Tem `.md`/HU/issue → completa. Só uma frase do usuário → leve.

Só o nível **completo** gera documento, e só quando pedido. Nunca proponha o `{ID}_design.md` para uma demanda que não tem ID.

### 0.1 Wireframe — a brief é obrigatória, e ela tem um passo a mais

Rabisco não é spec: ele comunica **o que vai onde**, nunca **como parece**. Antes de qualquer JSX, faça a **leitura em voz alta** e devolva pro usuário:

1. **Interprete cada bloco** — diga o que você entendeu que cada caixa é, em termos do design system:
   > "Li 4 seções: (1) header com título + botão 'Nova medição'; (2) faixa de filtros — 3 campos; (3) a caixa grande do meio eu li como a `<Table>` padrão, mesma da `/projetos`; (4) paginação embaixo. Confere?"
2. **Liste o que o rabisco NÃO diz** — e pergunte tudo de uma vez (não pingado):
   - bloco ambíguo ("a caixinha com o X dentro é o quê?")
   - label ilegível ou ausente
   - **estados** — rabisco nunca desenha vazio/erro/loading
   - **comportamento** — essa lista pagina? o filtro é múltiplo? esse botão abre modal ou navega?
   - **o que está fora da folha** — o papel acaba, a tela não
3. **Deixe explícito que o visual vem do sistema** — o usuário precisa saber que a tela **não vai parecer com o rabisco** (e isso é o certo):
   > "O visual todo sai do design system (tokens + `ui/`), seguindo a `/projetos`. O rabisco entra só como estrutura e ordem."

Sem isso, o `design-screen` chuta os buracos e você descobre o erro depois da tela pronta. A conversa aqui é ordens de grandeza mais barata.

---

## 1. Ler a demanda (nível completo)

### Recebeu `#NNN`

Se `GITLAB_ENABLED` no `.env` não for `true`: não dá pra ler a issue. Avise e peça o `.md` em `outputs/{ID}_*/` (branch abaixo) ou a descrição da demanda direto.

```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab issue view NNN -R ${GITLAB_REPO}
```

### Recebeu doc do PM
Procure `outputs/{ID}_*/` — o `.md` consolidado é a fonte de verdade (descrição, Critérios de Aceitação, Regras de Negócio `RN_XX`, Mensagens `MSG_XX`, Referências Globais).

Complemente com `docs/context_docs/ONEPAGE.md` (comportamento esperado do produto).

### O que extrair — **superfície de tela**
Só o que **aparece ou acontece na interface**. Ignore o resto.

| Da doc | Vira na interface |
|---|---|
| Critério de Aceitação | um comportamento observável — campo, ação, transição, validação |
| Regra de Negócio (`RN_XX`) | um estado, uma habilitação/desabilitação, uma máscara, um cálculo exibido |
| Mensagem (`MSG_XX`) | **um lugar concreto** na tela — toast, inline sob o campo, modal, banner. Toda MSG precisa de lugar. |
| Escopo | quais telas entram, quais ficam de fora |

Anote o que **não tem** superfície de tela (regra de backend pura) — não invente UI pra isso.

---

## 2. Inventariar o protótipo — OBRIGATÓRIO em todo nível ≥ leve

**Este é o passo que ninguém faz hoje.** Você não pode sugerir nada sem saber o que o app já tem.

```bash
ls prototype/src/routes/**/*.tsx                      # telas que existem
ls prototype/src/components/ui/                       # componentes do design system
sed -n '/theme:/,/}/p' prototype/tailwind.config.js   # tokens (cor/fonte/espaço)
grep -rn "to=\"" prototype/src/components/ui/AppHeader.tsx   # o menu real do produto
ls prototype/src/mock/                                # dados de exemplo já existentes
```

Levante, sem ler arquivo inteiro à toa:

1. **Telas que a demanda toca** — já existem? quais?
2. **Tela irmã** — qual tela do mesmo tipo (outra listagem, outro formulário) essa demanda deve seguir?
3. **Cobertura do design system** — quais componentes de `ui/` já resolvem o que a doc pede?
4. **Gap real** — o que a demanda pede que **não existe** em `ui/` nem em token. Antes de chamar de gap, confira se não existe com outro nome (`MetricFilterCard` ≠ "card de filtro"?).
5. **Mock disponível** — os dados já existem em `src/mock/` ou precisam ser criados?

> Gap falso é o erro mais caro daqui: você declara "precisa de componente novo", o `design-screen` cria, e o app fica com dois componentes que fazem a mesma coisa. **Na dúvida, `grep` antes de declarar gap.**

---

## 3. Analisar e divergir — aqui é design, não transcrição

Este é o núcleo. Cinco perguntas, nesta ordem:

### 3.1 Onde a funcionalidade entra na navegação
O produto navega pelo **menu real do topbar** (`AppHeader`), não por hub. Então: item de menu existente? tela nova sob um módulo? aba dentro de uma tela? modal sobre a listagem? rota-filha com breadcrumb?

Não é detalhe: **essa decisão define a arquitetura de informação** e é a mais cara de reverter depois.

### 3.2 Direções possíveis — 2 ou 3, com trade-off, e **recomende uma**
Não apresente catálogo. Apresente o que muda entre elas e qual você escolheria.

```
A) Modal sobre a listagem  — fluxo curto, não perde contexto; ruim se o form tem 8+ campos
B) Rota própria + breadcrumb — cabe form longo, linkável; custa uma navegação
→ Recomendo B: a doc pede 11 campos + upload de anexo. Modal fica apertado.
```

### 3.3 Estados que a doc não previu
Doc de produto quase nunca lista: vazio, loading, erro de rede, sem permissão, resultado único, lista longa (paginação), campo em conflito. **Levante os que fazem sentido para esta tela** e diga quais você vai construir.

### 3.4 Impacto no que já existe
A demanda **quebra ou muda** alguma tela existente? Coluna nova numa tabela que já está cheia? Item de menu novo? Componente de `ui/` que precisa ganhar variante (e aí muda em todas as telas que o usam)?

Diga explicitamente **quais telas existentes serão tocadas** — isso é escopo que a doc do PM normalmente não enxerga.

### 3.5 Pendências de produto — reporte, **não resolva**
Conflitos entre a doc e a realidade da tela:
- CA que não tem como ser observado na interface
- `MSG_XX` sem lugar concreto pra aparecer
- `RN_XX` que exige um campo que a descrição não menciona
- Ação sem estado de retorno definido (o que o usuário vê depois de salvar?)

**Você lista. O usuário decide se leva pro `@product-manager`.** Não comente na issue, não edite o `.md` do PM, não invente a resposta. Fronteira de persona (§`.agents/ENGAGEMENT.md`).

---

## 4. Conversar — o entregável padrão

Devolva em texto, direto, na thread. Formato (nível completo):

```
## Superfície de tela
<o que da doc vira interface>

## O protótipo já tem
Telas tocadas: /projetos (existe), /medicoes (não existe)
Irmã: /projetos — mesma estrutura de listagem
Reusa: Table, Badge, Button, Select, PageHeader (ui/)
Gap real: nenhum · ou: <componente> não existe (conferi ui/, não é o <X> com outro nome)

## Navegação
<onde entra + direções + recomendação>

## Estados
<os que vou construir, incl. os que a doc não previu>

## Impacto no que existe
<telas tocadas / componente que ganha variante>

## Pendências de produto (pra você levar ao PM, se quiser)
- MSG_03 não tem lugar na tela — a doc não diz onde aparece
- RN_07 exige "responsável pela obra"; a descrição não lista esse campo
```

Nível leve: os mesmos blocos, mas em 5-10 linhas, sem cabeçalho.

**PARE aqui.** Itere na conversa. Iterar aqui é ordens de grandeza mais barato que iterar em JSX.

---

## 5. Documento de design — OPT-IN (write-gate)

Só grave quando o usuário pedir ("gera o doc de design", "salva isso"). **Só faz sentido para demanda com ID** (issue/HU). Demanda de texto solto não gera documento.

Arquivo: `outputs/{ID}_{NomeCurto}/{ID}_design.md` — o mesmo diretório que o PM já usa para a issue.

```markdown
# [DESIGN] {ID} — <Nome da funcionalidade>
Data: YYYY-MM-DD · Agente: product-designer
Fonte: issue #NNN · doc: outputs/{ID}_{NomeCurto}/{ID}.md

## 1. O que a demanda vira na interface
<superfície de tela — CA/RN/MSG que têm reflexo visual>

## 2. Navegação e arquitetura de informação
- Entrada: <item de menu / rota / modal / aba>
- Direções avaliadas: <A, B> · **Decisão: <B>** — <por quê>

## 3. Telas
### /<rota> (nova | existente)
- Irmã: /<rota>
- Seções (ordem vertical): <topbar → filtros → tabela → paginação>
- Componentes reusados: <de ui/>
- Novo (gap real do design system): <lista, ou "nenhum">
- Estados: default · empty · loading · error
- Dados: <de src/mock/...>

## 4. Impacto no que já existe
<telas tocadas · componente que ganha variante · token novo>

## 5. Pendências de produto
<conflitos achados — o PM decide; o designer não resolve>

## 6. Fora de escopo
<o que esta demanda NÃO faz na interface>
```

Escrita externa: mostre o caminho e o conteúdo, espere o "pode" (write-gate, `.agents/ENGAGEMENT.md` §2).

---

## 6. Handoff pro `design-screen`

O `{ID}_design.md` **é** o plano do `design-screen` — ele substitui o alinhamento em bullets do §3.5-ALIGN. Não realinhe do zero: o `design-screen` lê o doc e constrói.

Sem doc gerado (nível leve/média, ou usuário não pediu): a **conversa** vale como plano. O `design-screen` segue com o alinhamento curto de sempre.

Fluxo:

```
demanda ──► design-brief (analisa, conversa)  ──► [doc opt-in]  ──► design-screen (constrói)
   │                                                                        │
   └── ajuste em tela existente ───────────────────────────────────────────►┘  (pula a brief)
```

---

## Fronteira

- **Faz:** ler a doc/issue/imagem, varrer o protótipo, decidir onde a funcionalidade entra na navegação, propor direções, achar gaps do design system, levantar estados e impacto, listar pendências de produto, gravar o `{ID}_design.md` (opt-in).
- **Não faz:** escrever JSX (é `design-screen`), medir pixel de print (é `design-screen` 3B), transcrever node do Figma (é `design-screen` 3.2/3A), comentar na issue, editar o `.md` do PM, decidir requisito de negócio.

> **Nunca meça um wireframe.** Medir rabisco é medir a mão trêmula de quem desenhou. Pillow é para print de produção, não para esboço.
