# Mecânica de captura — contrato de imagem (moldura do sistema)

Sintaxe e medidas da captura. **Não é encaixe:** o que está aqui é contrato de saída — a
imagem entregue tem que caber na página do documento final. Arquivo da organização neste
caminho não é customização declarada, e o build avisa.

Recorte, ordem por fluxo e renumeração são procedimento e moram em `references/procedimento.md`.

## Configuração do browser

```js
import { chromium } from 'playwright'

const browser = await chromium.launch({ channel: 'chrome' })
const page = await browser.newPage({
  viewport: { width: 1440, height: 900 },
  deviceScaleFactor: 2,   // 2x: o docx amplia a imagem, 1x sai borrado
})
```

## Padrão de tamanho para o DOCX

O entregável não é uma imagem `fullPage` longa. Uma tela alta deve virar partes contínuas que
ocupem bem a área útil da página A4 sem disputar espaço com cabeçalho, título da print e rodapé.

- Altura máxima de cada parte completa: `largura da imagem × 1,10`.
- Em uma captura de `2880px` de largura: parte completa de aproximadamente `2880 × 3168px`.
- Calcule pela largura real; a largura da aplicação pode variar.
- Divida somente quando a altura ultrapassar esse limite.
- Corte de cima para baixo, sem margem, intervalo ou sobreposição.
- Não redimensione nem reamostre: corte os pixels produzidos em `deviceScaleFactor: 2`.
- Todas as partes completas têm a mesma altura; a última preserva apenas o conteúdo restante.
- Não adicione área vazia para igualar a última parte.
- Nomeie partes da mesma captura com sufixos de letra: `10a_...`, `10b_...`, `10c_...`.
- As partes continuam sendo **uma única print lógica** e são coladas em sequência sob o mesmo
  heading do documento.

Use a função `full()` de `capture.template.mjs`: ela mede a página e gera as partes já no padrão.
`fullPage: true` pode existir como arquivo temporário de trabalho, mas nunca deve ser entregue
quando exceder a proporção acima.

## Borda obrigatória

Toda imagem entregue recebe uma borda preta interna de **1 pixel no arquivo final**.

- A borda é interna: não aumenta largura ou altura.
- Em captura 2x, use `0.5px` CSS para produzir 1 pixel físico.
- Aplique também em modal, card, tabela e última parte de tela longa.
- Não use sombra, margem, arredondamento ou moldura grossa como substituto.

## Tela inteira longa

```js
await page.goto(url, { waitUntil: 'networkidle' })
await page.waitForTimeout(400)          // fontes e ícones assentam
await full('10_painel-geral-ocorrencias-projeto')
```

Não capture apenas o viewport: a função percorre toda a altura e entrega partes contíguas no
tamanho apropriado para o DOCX.

## Modal, card, tabela — recorte no limite do elemento

Print de modal **nunca** é o viewport com o fundo escurecido atrás. Recorte no elemento:

```js
const MODAL = 'div.fixed.inset-0.z-50 > div'   // o card branco, não o overlay
await page.waitForSelector(MODAL)
await page.waitForTimeout(350)
await page.locator(MODAL).first().screenshot({ path })
```

Vale igual para tabela, card e qualquer componente que o documento cita isoladamente: `locator(seletor).screenshot()`.

Confira o seletor no componente `Modal` do projeto antes de assumir — a classe do overlay muda entre design systems.

## Dropdown aberto — depende do componente

Duas situações, e a diferença não é escolha sua:

- **Componente que renderiza em portal DOM** (MUI `Autocomplete`, Radix, Headless UI): as opções são DOM real e entram no screenshot. O popper fica **fora** do modal na árvore, então recorte pela união dos dois retângulos:

```js
const boxes = await page.evaluate(() => {
  const r = (el) => { const b = el.getBoundingClientRect(); return { x: b.x, y: b.y, w: b.width, h: b.height } }
  const modal = document.querySelector('div.fixed.inset-0.z-50 > div')
  const popper = document.querySelector('.MuiAutocomplete-popper')
  return popper ? [r(modal), r(popper)] : [r(modal)]
})
const x = Math.min(...boxes.map((b) => b.x)) - 4
const y = Math.min(...boxes.map((b) => b.y)) - 4
const width = Math.max(...boxes.map((b) => b.x + b.w)) + 4 - x
const height = Math.max(...boxes.map((b) => b.y + b.h)) + 4 - y
await page.screenshot({ path, clip: { x, y, width, height } })
```

- **`<select>` nativo** (MUI `TextField` com `slotProps.select.native: true`): o popup é desenhado pelo sistema operacional, **fora da página**. Nenhuma ferramenta de screenshot de browser captura isso.

Para o `<select>` nativo: **capture fechado**. Não force `size = options.length` para simular a lista aberta — sai com cara de list box, não de dropdown, e o usuário rejeita. Se as opções precisam aparecer no documento, quase sempre o texto de apoio abaixo do campo já as nomeia; confira antes de inventar solução.

Se o usuário insistir no dropdown real, há dois caminhos e **os dois são decisão dele**: capturar a tela do macOS com o popup aberto e recortar (fiel, frágil), ou tirar o `native: true` do componente (vira menu DOM capturável, mas muda o design system inteiro — é tarefa à parte, não ajuste de print).

## Estado que o mock não alcança

Às vezes o estado documentado é inatingível com os dados mockados — todo registro dispara o bloqueio, então o modal de confirmação nunca abre.

Patch temporário no mock, capture, e **reverta**:

```bash
git checkout prototype/src/mock/<arquivo>.ts
```

Depois **reporte ao usuário**: estado inalcançável na navegação normal costuma ser buraco no mock, não detalhe da captura. Ele decide se corrige.
