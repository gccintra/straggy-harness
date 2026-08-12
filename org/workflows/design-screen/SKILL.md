---
name: design-screen
description: >
  Cria E ajusta telas como rotas React no app de protótipo do projeto (prototype/) a partir
  de uma issue, HU, descrição livre ou número de issue do GitLab. Dois modos: AJUSTE (tela já
  existe → referência é o próprio protótipo, tokens e telas irmãs; NÃO pede print) e NOVO
  (tela inexistente → pede node do Figma ou imagem). Reusa src/components/ui/, liga a rota ao
  menu real do produto e verifica por diff visual. Export de telas escolhidas pro Figma é
  opt-in. Use sempre que o usuário pedir criar OU ajustar uma tela, protótipo, componente ou fluxo.
  IMPORTANTE: Carregue obrigatoriamente a skill `glab-backlog` antes de qualquer operação no GitLab.
---

**PRÉ-REQUISITO:** Carregar a skill `glab-backlog` antes de qualquer operação no GitLab.

# design-screen

Cria novas telas como **rotas React no app `prototype/`** — o protótipo navegável do produto inteiro. Cada tela é uma rota; as telas se ligam pelo **menu real do produto** (topbar `AppHeader`), como no sistema real — não por uma galeria/hub. A fonte de verdade dos componentes e tokens é o próprio app (`tailwind.config.js` + `src/components/ui/`), transcritos das referências.

**Pré-requisito 1 — o app existe.** Se `prototype/` ainda não existe, rode `design-setup` primeiro (scaffold + design system). Não crie telas soltas fora do app.

**Pré-requisito 2 — uma referência.** Node do Figma informado pelo usuário, ou imagem. Sem node nem imagem, pare e peça. Nenhuma variável de ambiente obrigatória — **o usuário informa os nodes** (Etapa 3.1).

> **Transcrever, não re-autorar.** O componente React reproduz a árvore do node de referência elemento por elemento, reusando os componentes de `ui/` — não uma versão reescrita de memória.

---

## 1. Configuração

```
FIGMA_FILE_KEY:  ${FIGMA_FILE_KEY}      ← só p/ export opt-in; link do usuário sobrepõe
GITLAB_HOST:     ${GITLAB_HOST}
GITLAB_URI:      ${GITLAB_URI}
GITLAB_REPO:     ${GITLAB_REPO}
```

App do protótipo: `prototype/` (Vite + React + TS + Tailwind + react-router). Dev server: `npm run dev` → `http://localhost:5173`.

---

## 2. Carregar o contexto da tela

### Recebeu número de issue

Se `GITLAB_ENABLED` no `.env` não for `true`: não dá pra ler a issue. Avise e busque `outputs/{ID}_*/{ID}.md` no repo (mesmo ID); sem isso, peça a descrição direto (trate como "Recebeu descrição livre" abaixo).

```bash
GITLAB_HOST=${GITLAB_HOST} GITLAB_URI=${GITLAB_URI} \
  glab issue view NNN -R ${GITLAB_REPO}
```
Extraia título, problema, solução (seção EVOLUCAO), critérios de aceite. Tem HU? Leia o documento (campos, fluxos, estados).

### Recebeu descrição livre
Use direto. Vaga ("tela de listagem de candidatos") → busque `docs/context_docs/` (ONEPAGE.md descreve o comportamento esperado).

### Perguntas mínimas antes de criar
Se o contexto não deixar claro:
1. **Qual módulo/área** — ADM ou SI? Qual seção? (define a pasta em `routes/`)
2. **Estado principal** — listagem, formulário, modal, detalhe?
3. **Estados específicos** a mostrar — erro, vazio, loading?

---

## 3. Referência — dois modos de entrada

**Decida o modo ANTES de pedir qualquer coisa ao usuário:**

| Modo | Quando | Referência | Peço print/node? |
|---|---|---|---|
| **Ajuste** | a tela/componente **já existe** no protótipo (consertar, alinhar ao sistema, aumentar texto, arrumar espaçamento, trocar por token) | o **próprio protótipo**: o arquivo, os tokens, uma tela irmã | **NÃO** — está nos arquivos |
| **Novo** | tela/componente que **não existe** no protótipo | Figma autoral, node/print de produção, imagem ou wireframe | Sim |

Como decidir: **olhe o protótipo primeiro** (3.0). A tela/componente já está em `prototype/src/`? → **Ajuste**: abra o arquivo, ache o valor, corrija pelo token/tela irmã, sem pedir nada. Não está? → **Novo**: peça a referência (3.1).

### 3.-1 AUTORIDADE DA REFERÊNCIA — quem manda no visual

**Nem toda referência vale a mesma coisa.** Antes de transcrever, saiba **de onde ela veio** — isso decide se o visual segue a referência ou o design system. Pergunte se não estiver claro.

| Referência | O que ela é | Quem manda no **visual** | Onde |
|---|---|---|---|
| **Node/print da produção** | tela do sistema atual, já existe em produção | o **design system do protótipo** — a produção dá só estrutura, campos, colunas, ordem, estados | 3.2 / 3B |
| **Figma autoral** | você **desenhou a tela nova** no Figma; é a intenção de design, não um retrato do que existe | o **seu desenho** — alta fidelidade ao que foi desenhado | 3A |
| **Wireframe / rabisco** | esboço feio, à mão, caixinha e seta; comunica intenção e hierarquia, não aparência | o **design system**, 100% — o rabisco não tem visual a copiar | 3D |
| **Nada** (só texto) | descrição em palavras | o **design system** + tela irmã | 3.5-ALIGN |

Erro clássico dos dois lados: copiar o hex cru de um print de produção quando já existe token (tela sai fora do sistema) **e** tratar um wireframe como se fosse spec visual (tela sai feia, com as caixas cinzas do rabisco). Saiba qual referência você tem.

> Pedir print pra "aumentar o texto pra bater com o sistema" é erro — "bater com o sistema" quer dizer usar o token/tamanho que as outras telas já usam. Isso se acha com `grep`, não com pergunta.

#### Modo Ajuste — fluxo curto (não passa pelo fluxo de tela nova)

1. Ache o componente/rota: `grep -rn "Histórico de ação\|historico" prototype/src`.
2. Ache o valor atual e o padrão do sistema:
   ```bash
   grep -rn "text-xs\|text-sm\|text-base" prototype/src/routes prototype/src/components  # o que as telas usam
   sed -n '/theme:/,/}/p' prototype/tailwind.config.js                                    # escala de fonte
   ```
   Compare com uma **tela irmã** que já esteja no tamanho certo.
3. Edite pro token/tamanho do sistema (`Edit` cirúrgico). Se o valor certo já é usado noutra tela, use o mesmo.
4. Verifique no Vite (renderiza, compara com a irmã). Entregue. **Sem pedir referência externa, sem gate.**

Ajuste não precisa de alinhamento em texto prévio se for óbvio (aumentar fonte pro padrão) — faça e reporte. Só alinhe se o "certo" for ambíguo (existem dois tamanhos no sistema, qual?).

### 3.0 INVENTARIE O PROTÓTIPO PRIMEIRO — antes de olhar a referência

**A causa nº1 de tela inconsistente: transcrever os valores crus da produção em vez de reusar o que o protótipo já tem.** A referência de produção diz **o quê** (estrutura, campos, conteúdo, estados); o **design system do protótipo diz como parece**. O protótipo manda no visual — não a produção.

Antes de ler qualquer node, levante o que o app já tem:

```bash
ls prototype/src/components/ui/                 # componentes existentes
sed -n '/theme:/,/}/p' prototype/tailwind.config.js   # tokens (cor/fonte/espaco)
ls prototype/src/routes/**/*.tsx                # telas irmãs (padrões já resolvidos)
```

Abra **uma tela irmã** do mesmo tipo (outra listagem, outro formulário) e veja como ela monta: quais componentes de `ui/`, quais classes de token, que layout. **A tela nova tem que parecer irmã das que já existem.**

#### Precedência — ORDEM FIXA (o de cima vence)

1. **Componente já em `src/components/ui/`** → use. Já está no design system.
2. **Token no `tailwind.config`** → use a classe (`bg-navy`), nunca o hex cru da produção.
3. **Padrão de uma tela irmã** → siga (mesmo header, mesma tabela, mesma paginação).
4. **Lib pronta** (3.6) reestilizada pros tokens → pra comportamento que falta.
5. **Só então** crie novo — e adicione ao sistema (`ui/`/`config`), não hardcode na tela.

A **referência de produção** entra na camada de **estrutura e conteúdo** (que seções, que campos, que colunas, que ordem, que estados) — **não** como fonte de cor/medida quando o protótipo já tem token equivalente. Reproduzir o hex cru da produção quando existe token = a inconsistência que você quer evitar.

### 3.1 PERGUNTA OBRIGATÓRIA — SÓ no modo Novo

**Pule esta etapa no modo Ajuste** (a tela já existe → a referência é o protótipo, não um node). Só pergunte a referência quando for tela/componente **novo**:

> "Quais nodes do Figma eu uso de contexto?
> 1. **Tela de referência** — alguma tela parecida a seguir? (link ou nodeId)
> 2. **Componentes específicos** — algum node de componente que essa tela precisa?
> 3. **Design system** — algum node de tokens/guidelines? Opcional (já temos em `ui/`)."

Regras:
- Aceite **link** (`figma.com/design/:fileKey/:nome?node-id=1-2`) ou **nodeId cru** (`1:2`/`1-2`). Extraia `fileKey` e `nodeId`.
- **Tela de referência é o que importa.** Sem ela, avise que a fidelidade cai.
- **Nunca invente nem chute nodeId.** Inexistente → pergunte de novo.

### 3.2 Ler os nodes — TRANSCREVER a estrutura, RESTYLE pros tokens

Transcrever ≠ copiar valores crus. Você reproduz **a estrutura da árvore** do node (todo elemento, mesma ordem, nada omitido — regra dura contra re-autorar layout), mas **vestida com o design system do protótipo**: cada elemento vira o componente de `ui/` equivalente, cada cor/medida vira a classe de token (precedência 3.0). Não reescreve a tela de um resumo (isso é re-autorar), e não reproduz o hex cru da produção quando há token (isso é a inconsistência).

Resumindo: **estrutura e conteúdo = da referência; aparência = do protótipo.**

#### Caminho A — node cabe (default)
```
get_design_context(fileKey="<fileKey>", nodeId="<nodeId>")
```
Transcreva **inline**, na thread principal, para JSX (limpeza §3.3). Mesmo agente que vê o dump escreve o componente → fidelidade apertada.

#### Caminho B — node estoura (só então, subagente)
Tela inteira estoura (~1400 nodes, ~80k de dump). **Só nesse caso** delegue ao subagente **`figma-node-reader`**. Ele fatia, transcreve cada chunk (Lucide inline, limpeza §3.3), grava fragmentos em `scratchpad/figma-html/<node>.html`, devolve caminhos + índice + chutes sinalizados (`⚠`). Você **converte os fragmentos pra JSX** — não reescreve de memória. O diff visual (3C) pega o drift.

Leia **só os nodes que o usuário informou**. **Nunca `get_metadata` na página inteira** (`0:1`) — 234k chars, estoura.

### 3.2.1 Valor de design vs valor medido
Separe **valor de design** (copie fixo: cor, radius, padding, gap, altura de **controle** `h-9`) de **valor medido** (`h-[333px]` de seção, `w-[1022px]` de container → vira layout fluido `flex`/`gap`, não altura fixa). Caminho B: o `figma-node-reader` marca o medido; caminho A: aplique o mesmo julgamento.

### 3.3 Converter o retorno do Figma para o padrão do app

`get_design_context` devolve React + Tailwind com valores absolutos. Converta:

| Vem do Figma | Vira no componente |
|---|---|
| `bg-[#003770]` | **classe de token** do `tailwind.config` (ex: `bg-navy`) — ver 3.3.1 |
| wrapper duplo (`bg-clip-padding border-0 border-[transparent]`) | achatar em 1 elemento |
| `absolute left-[528px] top-0` | flex/grid |
| componente que já existe em `ui/` (botão, input, tabela, modal) | **use o componente de `ui/`**, não recrie inline |
| `<img src="figma.com/api/mcp/asset/...">` | ícone `lucide-react` — **a URL expira em 7 dias** |
| `font-['Roboto:Medium']` | classe de fonte do config + `font-medium` |
| `data-name="Button"` | `aria-label="Button"` (nome do node na volta pro Figma) |

#### 3.3.1 Cor e medida: TOKEN DO PROTÓTIPO primeiro, hex cru por último
**O design system do protótipo é a verdade do visual, não o hex cru da produção.** Ordem:
1. Existe token no `tailwind.config` pra esse papel (navy, surface, border, texto)? → use a **classe de token**. Mesmo que o hex da produção esteja 2-3 pontos diferente por antialiasing/compressão, o token vence — é ele que mantém a tela irmã das outras.
2. É um valor **novo do sistema** (cor/escala que o design system não tem ainda)? → **adicione ao `config`** e use a classe. Não hardcode.
3. One-off de **layout** específico da tela (largura de container, gap pontual) → `w-[Npx]` inline, ok.

Nunca reproduza o hex cru da produção quando há token equivalente — é exatamente o que deixa "tudo estranho". Faltou referência e não há token → pergunte.

### 3.4 Transcrever TODO componente — regra dura
Todo componente do node **aparece** no output, mesma estrutura, mesma ordem. Nada omitido, nada "melhorado". Mude **só** o que a demanda pediu. Componente que a tela precisa e não está em `ui/` nem em node informado → **pergunte** onde está antes de criar do zero.

Teste: renderize e compare com `get_screenshot` do node (3C). Componente faltando/fora de posição = re-autorou. Volte ao dump.

### 3.5 Reuso antes de criar — ordem de preferência
Antes de escrever markup novo:
1. **Já existe em `src/components/ui/`?** → use.
2. **Uma lib pronta resolve?** (3.6) → instale, envolva em `ui/` reestilizado pros tokens.
3. **Só então** construa do zero — e se for reutilizável, em `ui/`; se específico da tela, na rota.

Não gaste token reinventando comportamento que uma lib já entrega (tabela, modal, tabs, dropdown, date picker, gráfico).

### 3.6 Usar libs prontas — permitido e preferido
**Reinventar componente do zero é o último recurso, não o primeiro.** Comportamento, acessibilidade e estado (foco, teclado, ARIA, ordenação, paginação) vêm da lib; a **aparência vem dos tokens** (`tailwind.config`) — a fidelidade visual continua verbatim (regra dura 6). Você reestiliza o componente da lib pra bater com a referência, não reconstrói.

Padrão: envolva o componente da lib em `src/components/ui/<Nome>.tsx`, já com as classes de token. As telas importam de `ui/`, não da lib direto — troca de lib fica isolada.

Libs recomendadas (Tailwind-friendly):

| Precisa de | Lib |
|---|---|
| Base de componentes copiáveis e reestilizáveis | **shadcn/ui** (Radix + Tailwind) |
| Primitivos acessíveis crus (dialog, dropdown, tabs, tooltip, popover) | **Radix UI** / **Headless UI** |
| Tabela com ordenação/paginação/filtro | **TanStack Table** |
| Gráficos (Curva S, donut, barras) | **Recharts** (ou visx) |
| Date/range picker | **react-day-picker** |
| Ícones | **lucide-react** (já no projeto) |

Instale no `prototype/` (`npm i <lib>`). Quando a referência do Figma traz um componente que a lib cobre, a lib entra estilizada aos tokens — não uma reconstrução manual do DOM. Componentes de mão própria que já existem no app seguem válidos; a regra vale pra **novo** trabalho e pra qualquer coisa complexa que estaria sendo reinventada.

---

## 3A. Referência é Figma AUTORAL (você desenhou a tela lá)

Caso: o usuário prototipou **à mão no Figma** uma tela que **não existe** no sistema, e quer trazer pro `prototype/`. Isso **não** é referência de produção — é **a intenção de design dele**. A autoridade se inverte.

| | Node da **produção** | Node **autoral** (este caso) |
|---|---|---|
| A referência representa | o que **já existe** no sistema | o que o usuário **quer que exista** |
| Manda no visual | design system do protótipo | **o desenho** — ele é a decisão de design |
| Valor divergente do token | usa o **token** (é ruído de antialiasing/legado) | usa o **desenho** — e o valor novo **entra no sistema** (`tailwind.config` / `ui/`) |

Leitura idêntica à 3.2 (`get_design_context`, caminho A inline; caminho B via `figma-node-reader` se estourar). O que muda é a **conversão**:

1. **Reuse `ui/` mesmo assim.** Um botão desenhado no Figma que é o botão do sistema → `<Button>` de `ui/`. O desenho manda no que é **novo**, não no que já foi resolvido. Precedência da 3.0 continua valendo para tudo que já existe.
2. **Valor genuinamente novo** (cor, escala, espaçamento, componente que o design system não tem) → **adicione ao sistema** (`tailwind.config` / `components/ui/`), não hardcode na tela. Foi você que decidiu que o sistema cresce — cresça direito.
3. **Divergência entre desenho e token existente** → **pergunte**. "Você desenhou o header em `#0A4C8B`, mas o sistema tem `navy #003770`. É cor nova ou era pra ser o navy?" Rabisco de cor no Figma quase sempre é aproximação; mudança deliberada de token, quase nunca.
4. **Verificação visual (3C) roda igual** — aqui o diff **é** contra o seu desenho, e o alvo é fidelidade alta. Diferente do node de produção, onde diferença de cor por usar token é *correta*.

---

## 3B. Referência é imagem (nada no Figma)

Vale quando o usuário manda print/mockup ou a tela não existe no Figma. **Imagem é referência de primeira classe — desde que medida.**

### 3B.1 NÃO estime valores no olho
```python
from PIL import Image
from collections import Counter
im = Image.open(path).convert('RGB')
im.getpixel((x, y))                        # cor exata de um ponto
for rgb, n in Counter(im.getdata()).most_common(15):
    print('#%02x%02x%02x' % rgb, n)        # paleta dominante
```
Medida (altura de controle, radius, padding): recorte a região, ache transições de cor por linha/coluna com `numpy`. Reporte px reais; print @2x (retina) → **divida por 2**.

### 3B.2 O que a imagem NÃO tem — pergunte
Estados além do visível (hover/focus/disabled, vazio/loading/erro) e a **fonte** (imagem não carrega nome). Confirme com o usuário.

### 3B.3 Escala e viewport
Pergunte/meça a largura real. Print de 1440 e projeto 1280 → recalcule proporcionalmente, avise o ajuste. Nunca redimensione no olho.

---

## 3D. Referência é WIREFRAME (rabisco, esboço, papel, caixinha e seta)

Caso: o usuário manda um **wireframe feio de propósito** — rabisco à mão, foto de papel, caixas cinzas, Excalidraw. Ele está comunicando **o que vai onde**, não **como parece**.

> **Regra que governa tudo aqui: o rabisco dá INTENÇÃO; o design system dá TUDO que é visual.** O wireframe não tem cor, não tem tipografia, não tem espaçamento — ele tem hierarquia, ordem e agrupamento. Transcrever um wireframe "fielmente" produz uma tela cinza e feia. **Não faça isso.**

### 3D.1 O que você extrai do rabisco — e só isso

| Extraia | Ignore |
|---|---|
| **Seções** e ordem vertical | cor (não existe) |
| **Hierarquia** — o que é título, o que é secundário | tipografia (letra do usuário ≠ fonte) |
| **Agrupamento** — o que está junto, o que está separado | espaçamento exato do rabisco |
| **Tipo de cada bloco** — "isso é uma tabela", "isso é um filtro", "isso é um card" | proporção/tamanho do desenho (não é medida) |
| **Ações** — que botões existem e onde | qualquer traço de estilo |
| **Anotações** — texto escrito à mão, setas, "aqui vai X" | — |

**NÃO meça com Pillow.** Medir um rabisco é medir a mão trêmula do usuário. Pillow é para print de produção (3B), nunca para wireframe.

### 3D.2 O visual vem 100% do design system
Cada bloco do rabisco vira o componente de `ui/` equivalente, com os tokens do `tailwind.config`, seguindo a **tela irmã** (3.0). Uma "caixa com linhas dentro" no papel é a `<Table>` do sistema, com o header, o padding e a paginação que as outras telas usam. Você não está copiando um desenho — está **realizando** uma intenção no design system que já existe.

### 3D.3 Rabisco é ambíguo — a brief resolve, não o chute
Wireframe **sempre** deixa buraco. Não preencha no escuro:

- Bloco que não dá pra saber o que é ("uma caixa com um X dentro")
- Campo sem label / label ilegível
- Estados (vazio, erro, loading) — rabisco nunca desenha
- Comportamento (essa lista pagina? esse filtro é múltiplo? esse botão abre modal ou navega?)
- O que está fora da folha (o rabisco acaba, a tela não)

**Entrada de wireframe passa pela `design-brief` (nível médio-alto) antes de virar JSX.** É lá que você lê o rabisco, cruza com o protótipo, propõe a leitura ("entendi 4 seções; a caixa do meio eu li como a `<Table>` padrão") e tira as dúvidas **de uma vez**. Chegou wireframe direto no `design-screen` sem brief → rode a brief primeiro.

### 3D.4 Verificação visual — o diff NÃO se aplica
**Não rode diff numérico (3C) contra um wireframe.** O alvo não é parecer com o rabisco — a tela final tem que parecer com **as outras telas do protótipo**. Verificação aqui é:

1. Renderize a rota no Vite.
2. Renderize a **tela irmã** ao lado.
3. Confira: mesma cara de sistema? mesmos componentes? mesma densidade? mesmo header?
4. Confira contra o **rabisco** só a **checklist de estrutura**: toda seção do desenho existe? na mesma ordem? todo botão está lá?

Estrutura confere com o rabisco; visual confere com a tela irmã. São duas verificações diferentes.

---

## 3C. Loop de verificação visual — OBRIGATÓRIO

**Gerar com os valores certos não garante 1:1. Conferir garante.** Nunca diga "está fiel" sem ter rodado a comparação.

Vale quando a referência **tem visual**: node de produção, Figma autoral (3A), imagem/print (3B). **Não vale para wireframe** — rabisco não tem visual pra bater; a verificação de wireframe é a 3D.4 (estrutura contra o rabisco, visual contra a tela irmã).

1. Suba o Vite (Etapa 5), renderize a rota no Chrome (`claude-in-chrome`) no **mesmo viewport da referência**. Use `?export=1` (tela sem chrome) pra comparar só a tela.
2. Screenshot do resultado.
3. Referência: imagem do usuário, ou `get_screenshot(fileKey, nodeId)`.
4. Diff numérico:
```python
import numpy as np
from PIL import Image
ref = Image.open(ref_path).convert('RGB')
got = Image.open(got_path).convert('RGB').resize(ref.size)
d = np.abs(np.asarray(ref, int) - np.asarray(got, int)).mean(axis=2)
print('diff medio:', d.mean())
rows = d.mean(axis=1)
for i in np.argsort(rows)[-5:]:
    print(f'y={i}  erro={rows[i]:.1f}')
```
5. Corrija as faixas de maior erro. Repita.
6. **Máximo 3 iterações.** Diff parou de cair → PARE e mostre o que restou divergente.
7. Reporte o diff final e o que sobrou. Honestidade > "ficou igual".

> Diff alto em faixa de texto = fonte/antialiasing, não persiga. Diff alto em borda/fundo = layout, corrija.
>
> **O diff mede fidelidade de ESTRUTURA/LAYOUT, não obriga o pixel de cor.** O visual vem dos tokens do protótipo (que ≈ produção, pois foram extraídos dela). Pequena diferença de cor por usar o token em vez do hex cru é **correta** — mantém a tela irmã das outras. Não troque um token pelo hex cru só pra baixar o diff; isso reintroduz a inconsistência.

---

## 3.5-ALIGN. Alinhar o protótipo EM TEXTO antes de construir (gate anti-desperdício)

**Não escreva JSX direto.** Descreva o protótipo em texto/chat e alinhe. Só construa depois do "pode".

### 3.5.0 Já existe um documento de design? Ele É o plano.

Antes de alinhar do zero, procure `outputs/{ID}_*/{ID}_design.md` (gerado pela `design-brief`).

- **Existe** → **ele é o plano; não realinhe.** Navegação, telas, seções, componentes reusados, gap real, estados e impacto já foram decididos e aprovados lá. Leia, confirme em 2-3 linhas ("vou construir /medicoes conforme o design doc") e vá pra Etapa 4. Realinhar o que já foi alinhado é desperdício e reabre decisão fechada.
- **Não existe, mas a demanda veio de doc/HU/issue** → a análise não foi feita. Rode a `design-brief` antes (regra dura 9 do `product-designer`), não improvise o plano aqui.
- **Não existe e a demanda é texto simples ou imagem** → siga o alinhamento curto abaixo. É o caminho normal.

Divergiu do doc durante a construção (o doc previu reuso de `<Table>` mas a tela precisa de coluna expansível)? **Decisão pequena → siga e reporte.** Decisão grande que contraria o doc → pare e alinhe.

### 3.5.1 Alinhamento curto (sem design doc)

Proponha, curto (depois de inventariar o protótipo — 3.0):
- **Rota** — caminho (`/projetos/listagem`) e módulo/pasta
- **Tela irmã** — qual tela existente do mesmo tipo essa segue (garante consistência)
- **Layout** — estrutura (dentro do AppLayout: content-only; ou tela cheia) e largura (1280)
- **Seções** — ordem vertical (topbar → filtros → tabela → paginação)
- **Componentes reusados** — quais de `ui/`; qual lib (3.6); **o que é genuinamente novo** (e vai virar `ui/` + token)
- **Estados** — vazio/dados/loading/erro (viram `?state=`)
- **Dados de exemplo** — o que preencher (de `src/mock/`)

```
Rota: /medicoes/listagem (modulo SI)
Irmã: /projetos (mesma estrutura de listagem)
1. Topbar: titulo + <Button> "Nova medição"
2. Filtros: <SearchField> + <Select status> + range de data
3. <Table> colunas [Obra|Medição|%|Status|Ações], ordenável, 10/pág
4. Paginação + contador
Reusa: Button, SearchField, Select, Table, Badge (ui/) — tokens navy/surface/border
Novo: nenhum
Estados: default (5 linhas), ?state=empty, ?state=loading
```

Se aparecer "Novo" na lista, confirme com o usuário que é mesmo um gap do design system — não um componente que já existe com outro nome.

**Este é o único gate de aprovação do trabalho local.** Depois do "pode" no plano, construa a tela inteira de ponta a ponta **sem pedir aprovação a cada ajuste** — nome de variável, ordem de coluna, espaçamento, ícone, refino de mock/estado: decida o razoável e siga. Entregue o preview no Vite e reporte. Só volte a parar se surgir decisão **grande** que o plano não cobria (muda o fluxo, tela extra não combinada, conflito com a doc). Mudancinha não é gate.

Iterar aqui é quase de graça. "Pode"/ajustes → Etapa 4. Pedido já detalhado (issue/HU) → resuma em 3-4 linhas e confirme rápido.

---

## 4. Criar a rota React

**Reuse os componentes de `ui/` e os tokens do `tailwind.config`.** Não invente valores nem recrie componente que já existe. Valor sem referência → PARE e pergunte.

### 4.1 Onde os arquivos moram — OBRIGATÓRIO

```
prototype/src/
├── routes/
│   └── <modulo>/<tela>.tsx      ← 1 arquivo por tela
├── router.tsx                   ← registre a nova rota aqui
├── components/layout/AppHeader  ← ligue o item de menu à rota (navegação real)
├── components/ui/               ← componente novo REUTILIZÁVEL vai aqui
└── mock/<dominio>.ts            ← dados de exemplo da tela
```

**Regra 1 — arquivo por tela, critério de coexistência.** Se duas coisas nunca aparecem juntas na aplicação real, são arquivos/rotas diferentes. Dois modais que nunca abrem juntos → dois arquivos. Uma listagem e um gráfico de larguras diferentes → duas rotas.

**Regra 2 — estados via `?state=`, no mesmo arquivo.** A tela lê `useSearchParams()` e alterna default/empty/loading/error. Alterna pela URL (`?state=empty`), não por um índice de telas.

**Regra 3 — registre a rota + ligue o menu.** Toda tela nova entra em `router.tsx` (path + elemento) E é alcançável pela **navegação real do produto**: aponte o item de menu correspondente no `AppHeader` (NAV `to`) para a rota. **Não existe hub/galeria de telas** — a navegação é pelos menus do topbar, como no sistema real. Tela que nenhum menu alcança = tela que não existe no protótipo.

**Regra 4 — modal é rota-filha ou estado, não app à parte.** Modal abre sobre a tela pai (rota aninhada `/listagem/excluir/:id` ou estado). Nunca uma "página de modal" solta.

**Regra 5 — `/` é uma tela real.** A rota raiz redireciona pra tela default do produto (ex: `/projetos`), nunca uma página-índice de protótipo.

### 4.2 Regras de componente
- **HTML semântico** dentro do JSX (`<main>`, `<section>`, `<table>`, `<form>`, `<label for>`); hierarquia de headings correta.
- **Ícones**: `lucide-react` (`import { Trash2 } from "lucide-react"`).
- **`aria-label` nos blocos** = nome do node no export Figma (§ html-to-figma). Ponha desde já nos containers relevantes.
- **Largura desktop 1280** no `ExportFrame` — o AppShell já dá o container; o `?export=1` fixa 1280 sem chrome.
- **Renderize todos os estados pedidos** — vazio, dados, loading, erro. Mais valioso que uma tela estática perfeita.

### 4.3 Checklist de acessibilidade — WCAG AA, não opcional

Passe por ele **antes de entregar**. Não é enfeite: metade disso o `design-screen` já quebra por padrão (botão de ícone sem label, erro não ligado ao campo).

**Visual**
- [ ] Contraste ≥ **4.5:1** (texto normal) · ≥ **3:1** (texto grande, ícone, borda de input)
- [ ] Nenhuma informação transmitida **só por cor** (status precisa de texto/ícone, não só de bolinha)
- [ ] **Foco visível** em tudo que é interativo (não remova o outline sem repor)

**Interação**
- [ ] Todo elemento interativo é alcançável por **teclado**; ordem de foco lógica
- [ ] Sem armadilha de foco — modal fecha no `Esc` e devolve o foco pra quem abriu
- [ ] Alvo de toque ≥ **44×44px** (linha de tabela com botão de ícone é o infrator clássico)

**Leitor de tela**
- [ ] `aria-label` em **todo botão só de ícone** (lixeira, lápis, três pontinhos)
- [ ] Hierarquia de headings correta (`h1 → h2 → h3`, sem pular)
- [ ] `alt` em imagem com significado; `alt=""` em decorativa

**Formulário**
- [ ] `<label for>` associada a **todo** input (placeholder **não** é label)
- [ ] Mensagem de erro **ligada ao campo** (`aria-describedby`), não só um texto vermelho solto
- [ ] Campo obrigatório marcado de forma acessível (não só com asterisco vermelho)

**Estados — desenhe todos os que existem**
`default` · `hover` · `focus` · `disabled` · `loading` · `error` · `empty`

> Contraste: cheque contra o **token**, não contra o que parece. Texto `text-muted` sobre `surface` é o par que mais falha.

---

## 5. Rodar o Vite e revisar (PARE AQUI por padrão)

```bash
cd prototype && npm run dev   # http://localhost:5173
```

Dê ao usuário a URL direta da tela nova (`http://localhost:5173/medicoes/listagem`) + os estados (`?state=empty`), e confirme que ela é alcançável clicando no menu do topbar. Depois **PARE**. Itere no feedback — o Vite faz HMR no save. Nenhuma chamada ao Figma aqui.

### 5.1 Custo de token — regras duras
1. **`Edit`, NUNCA `Write`, ao iterar.** Depois que o arquivo existe, todo ajuste é `Edit` cirúrgico. `Write` de tela ≈ 17k tokens; `Edit` ≈ 0.3k. Só use `Write` na **primeira** criação ou ao substituir a tela inteira.
2. **NUNCA releia o arquivo que acabou de escrever** — já está no contexto. Trecho de arquivo grande:
```bash
grep -n "Badge\|bg-navy" arquivo.tsx
sed -n '120,160p' arquivo.tsx
```
Verificação é **visual** (3C: renderiza, screenshot, diff), não textual.

> Export pro Figma é escrita externa (write-gate do `.agents/ENGAGEMENT.md`): só avance pra Etapa 6 quando o usuário pedir explicitamente. Execução padrão termina aqui.

---

## 6. Export pro Figma (SÓ sob pedido explícito, por tela)

O usuário escolhe quais telas exportar ("exporta a listagem pro Figma"). Não exporte o app inteiro por reflexo — só as telas pedidas.

Fluxo (detalhe em `html-to-figma`):
1. Vite rodando. Abra a rota em modo export: `http://localhost:5173/<rota>?export=1` — o `ExportFrame` renderiza a tela **sem** sidebar/topbar, em `w-[1280px]`.
2. Uma captura por tela/estado. `figmaselector` aponta o wrapper do `ExportFrame` (dê `id` a ele).
3. Estados lado a lado = capture um `?state=` por vez → nodes irmãos no Figma.
4. `outputMode="existingFile"`, `fileKey=${FIGMA_FILE_KEY}`.
5. Reporte a URL de cada node, agrupada por tela.

`aria-label` no JSX nomeia os nodes; `lucide-react` já é SVG inline (captura ok). Nunca exporte o AppShell/chrome (topbar, menu) — só a tela pelo `ExportFrame`.

---

## 7. Registrar em history/

`history/YYYY-MM-DD_design_<nome-curto>.md`:

```markdown
# [DESIGN] <Nome da tela>
Data: YYYY-MM-DD
Agente: designer
Issue: #NNN (se aplicável)

## Rota
- /<modulo>/<tela>  (+ estados: ?state=empty, ...)

## Referência
- Node(s) Figma: <ids> · ou imagem: <arquivo>

## Componentes de ui/ reusados / criados
- reusou: <lista> · criou: <lista>

## Figma (se exportado)
- Node(s): <URLs>

## Decisões de design
- <ex: reusei <Table> dos guidelines, ajustei só a largura das colunas>
```

---

## Quando não há nada no Figma
Peça **imagem** (print, mockup) e siga a Etapa 3B — imagem medida é referência válida. Nunca recuse por falta de Figma.

**Wireframe rabiscado também serve** (3D) — e é entrada de primeira classe, não plano B. Ele dá intenção; o design system dá o visual. Passa pela `design-brief` antes.

Só pare se não houver **nem node, nem imagem, nem wireframe, nem tela irmã** que sirva de base.
