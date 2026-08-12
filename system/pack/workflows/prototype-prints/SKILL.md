---
name: prototype-prints
description: >
  Captura as prints do protótipo (prototype/) que entram na seção Protótipo do documento
  de uma demanda — o .md consolidado em outputs/{ID}_{Nome}/ e o .docx gerado a partir dele.
  Define o recorte a partir da documentação da demanda (não do git diff), organiza as prints
  por fluxo, e captura com Playwright em dimensões adequadas para página A4: telas longas em
  partes contínuas, componentes no próprio limite e todas as imagens com borda fina. Use
  quando o usuário pedir prints, screenshots ou imagens do protótipo para
  documentação — "tira as prints da #NNN", "preciso das telas pra colocar no docx",
  "salva as imagens do protótipo". Não use para export pro Figma (é html-to-figma) nem
  para criar/ajustar tela (é design-screen).
---

# prototype-prints

> **Camadas:** restrições em `system/CONSTITUTION.md` (write-gate: propor o recorte antes de
> capturar). Estrutura da seção de protótipo no `.md`: `references/secao-prototipo.md`.

Transforma o protótipo em um conjunto de imagens que ilustram **uma demanda específica** dentro do documento dela.

O erro que esta skill existe pra evitar não é técnico. É de recorte: capturar tudo que a tela mostra, ou tudo que o commit mudou, e entregar um álbum onde metade das imagens não diz nada sobre a demanda. Documento com print supérfluo declara de novo o que já estava entregue, e o leitor perde a referência do que mudou.

## 0. Pré-requisitos

- `prototype/` roda (`npm run dev`).
- Existe documentação da demanda em `outputs/{ID}_{NomeCurto}/*.md`. **Sem ela, pare e peça** — sem a doc não há critério de recorte, e o resultado vira álbum.
- Chrome instalado. Playwright usa o Chrome do sistema via `channel: 'chrome'`; **não** baixe browser.

Instale o Playwright fora do repositório, no diretório de scratchpad da sessão:

```bash
cd "$SCRATCHPAD" && npm init -y && npm i playwright
```

Nunca adicione Playwright ao `prototype/package.json` — a captura é ferramenta de sessão, não dependência do protótipo.

## 1. Definir o recorte — a documentação manda, não o `git diff`

Leia o `.md` consolidado da demanda. Ele é o contrato do que foi entregue.

**Por que não o diff:** o commit de uma demanda carrega junto refino de protótipo que ninguém pediu — um formulário reescrito, um componente trocado por lib, espaçamento arrumado. Isso mudou no código e **não** é escopo da demanda. Print desse refino entra no documento afirmando uma entrega que não existe.

**Por que o diff ainda serve:** como *rede*, no fim. Depois de montar a lista pela doc, olhe o diff e pergunte "mudou algo aqui que a doc declara e eu não capturei?". Nunca o contrário.

Critério, um por print:

> Esta imagem mostra algo que a demanda **declara**? Ou mostra a mesma interface que já existia antes dela?

O segundo caso sai. Sempre.

Três armadilhas recorrentes:

- **Formulário de cadastro.** Costuma ter mudado bastante no código e nada na demanda. Se a regra nova é sobre *vínculo, autoria ou visibilidade* do registro, ela não aparece no formulário — aparece no card, na listagem, no badge de origem. Capture onde a regra é visível.
- **Mesmo componente em dois contextos.** Um filtro que abre no painel A e no painel B gera duas imagens idênticas se o estado visível for o mesmo. Fique com uma, a do contexto que a documentação nomeia.
- **Modal de bloqueio já existente.** Mudar o texto de um aviso não é entrega. Mudar a *regra* que dispara o aviso é — e nesse caso o print vale, porque o número/mensagem na tela reflete o novo critério.

## 2. Ordenar por fluxo

Monte a lista na ordem da seção **Escopo** da documentação — é a jornada que o leitor vai percorrer.

**Não organize por critério de aceitação.** Mapear CA → print produz duplicata (o mesmo modal atende três CAs), produz print fragmentado que ninguém entende solto (um card isolado, um modal que existe só para uma regra de cálculo), e ordena a leitura pela numeração dos CAs em vez da jornada.

Mas **use o mapa CA → print como checklist silencioso**, uma vez, antes de fechar a lista. Ele é bom exatamente no que a leitura por fluxo é fraca: achar buraco. CA sem nenhuma imagem correspondente é sinal de print faltando — ou de critério que não tem reflexo em tela, e aí vale mencionar ao usuário.

Agrupe em 4-7 fluxos, cada um com título curto. Prints numerados corridos, `01`..`NN`, atravessando os fluxos.

## 3. Propor antes de capturar

Write-gate. Antes de rodar qualquer coisa, apresente:

- pasta de destino
- lista numerada, agrupada por fluxo, uma linha por print
- quais telas longas serão divididas em partes contínuas para caber no DOCX
- o que ficou **de fora** e por quê — esta parte é a que o usuário revisa de verdade

Espere o "pode". Apagar print já entregue também pede confirmação.

## 4. Capturar

Destino:

- pasta com um único documento formal: `outputs/{ID}_{NomeCurto}/prototipo-prints/`;
- pasta com várias HUs/HTs: `outputs/{ID}_{NomeCurto}/prototipo-prints/{IDENTIFICACAO}/`
  (ex.: `prototipo-prints/HU08.02/`).

Em pastas com várias HUs/HTs, a numeração é local a cada documento (`01..NN`). Uma imagem
reutilizada por mais de uma HU deve existir na subpasta de cada uma, com o número correspondente
ao heading daquela HU. O `hu-generator` escolhe a subpasta pela identificação nos metadados.

Se a demanda tem número de issue diferente do número no nome da pasta (issue guarda-chuva, tarefas filhas), **pergunte** onde salvar antes de criar diretório. Prints longe do documento se perdem.

Nomeie `NN_kebab-descricao.png`. O número é a ordem de leitura, não a ordem de captura.

### Configuração do browser

```js
import { chromium } from 'playwright'

const browser = await chromium.launch({ channel: 'chrome' })
const page = await browser.newPage({
  viewport: { width: 1440, height: 900 },
  deviceScaleFactor: 2,   // 2x: o docx amplia a imagem, 1x sai borrado
})
```

### Padrão de tamanho para o DOCX

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

### Borda obrigatória

Toda imagem entregue recebe uma borda preta interna de **1 pixel no arquivo final**.

- A borda é interna: não aumenta largura ou altura.
- Em captura 2x, use `0.5px` CSS para produzir 1 pixel físico.
- Aplique também em modal, card, tabela e última parte de tela longa.
- Não use sombra, margem, arredondamento ou moldura grossa como substituto.

### Tela inteira longa

```js
await page.goto(url, { waitUntil: 'networkidle' })
await page.waitForTimeout(400)          // fontes e ícones assentam
await full('10_painel-geral-ocorrencias-projeto')
```

Não capture apenas o viewport: a função percorre toda a altura e entrega partes contíguas no
tamanho apropriado para o DOCX.

### Modal, card, tabela — recorte no limite do elemento

Print de modal **nunca** é o viewport com o fundo escurecido atrás. Recorte no elemento:

```js
const MODAL = 'div.fixed.inset-0.z-50 > div'   // o card branco, não o overlay
await page.waitForSelector(MODAL)
await page.waitForTimeout(350)
await page.locator(MODAL).first().screenshot({ path })
```

Vale igual para tabela, card e qualquer componente que o documento cita isoladamente: `locator(seletor).screenshot()`.

Confira o seletor no componente `Modal` do projeto antes de assumir — a classe do overlay muda entre design systems.

### Dropdown aberto — depende do componente

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

### Estado que o mock não alcança

Às vezes o estado documentado é inatingível com os dados mockados — todo registro dispara o bloqueio, então o modal de confirmação nunca abre.

Patch temporário no mock, capture, e **reverta**:

```bash
git checkout prototype/src/mock/<arquivo>.ts
```

Depois **reporte ao usuário**: estado inalcançável na navegação normal costuma ser buraco no mock, não detalhe da captura. Ele decide se corrige.

## 5. Verificar

Abra as prints de estado condicional — bloqueio, contagem, status calculado. É onde a captura silenciosamente pega o estado errado: um seletor que casou com a linha errada da tabela, um modal que abriu na variante oposta.

Confira também que nenhum print de modal saiu com o fundo da página junto.

Para telas divididas, verifique ainda:

- largura idêntica em todas as partes;
- altura `largura × 1,10` nas partes completas;
- continuidade exata entre o último pixel de uma parte e o primeiro da seguinte;
- ausência de margem, sobreposição, reamostragem ou conteúdo perdido;
- borda preta interna de 1 pixel em cada arquivo;
- última parte sem preenchimento artificial.

## 6. Renumerar sem colidir

Cortar prints no meio da lista renumera o resto, e `mv 12 → 07` sobrescreve quando `07` ainda existe. Use diretório de staging:

```bash
mkdir -p .tmp
mv 12_<descricao>.png .tmp/07_<descricao>.png
# ...demais
mv .tmp/* . && rmdir .tmp
```

Não desloque os números das prints seguintes só porque uma tela longa foi dividida. Preserve o
número lógico e acrescente letras às partes (`10a`, `10b`, `10c`).

## 7. Escrever os títulos na seção Protótipo do `.md`

A **estrutura concreta** dessa seção (numeração, onde os links entram, se são duplicados
noutra seção) é formato de documento — vive em `references/secao-prototipo.md`, que a
organização sobrescreve. **Leia esse arquivo antes de escrever.**

O que vale em qualquer formato:

- **Um heading por print lógica.** Partes `10a`, `10b` e `10c` da mesma tela ficam juntas
  sob esse único heading, na ordem, para parecerem uma captura contínua no documento final.
- **Só o título descritivo** no heading. Nada de nome de arquivo, caminho, "Figura NN" ou
  legenda — o título diz o que a tela mostra.
- **Deixe o espaço em branco** sob cada heading: é ali que o `doc-final-generator` insere a
  imagem, quando a implementação ativa do provider `docs-output/` tem a capacidade
  `image-embed`. Sem essa capacidade, os títulos e links continuam válidos e as imagens
  entram à mão — avise o usuário.
- **Link da rota por fluxo**, apontando para a tela do protótipo publicado. A base sai de
  `project-config.yaml`; a rota, do fluxo. Fluxos que acontecem na mesma tela repetem a
  mesma URL — não force rotas diferentes só para variar. Rota com parâmetro
  (`/<recurso>/<id>`, `/<rota>?<param>`) aponta para registro do mock: confira que o id
  existe e que os query params necessários para abrir o estado certo estão na URL.
- **Escreva só títulos e links.** Não insira imagem no `.md` e não gere o documento final —
  é passo separado, do `doc-final-generator`.

## 8. Entregar

Liste o resultado agrupado por fluxo, e declare:

- o que ficou de fora e por quê
- qualquer patch de mock que precisou existir (já revertido)
- limitação que restou na imagem — dropdown fechado, componente cortado, dado mockado que não representa produção

Encerre o servidor Vite que você subiu.

## Fronteira

- **Faz:** escolher o recorte a partir da documentação, capturar e nomear as imagens, entregá-las ao lado do `.md` da demanda, e escrever a seção de protótipo do `.md` (títulos das prints + link da rota por fluxo) conforme `references/secao-prototipo.md`.
- **Não faz:** inserir a imagem no `.md`; gerar o documento final (é `doc-final-generator`);
  ajustar tela do protótipo (é `design-screen`); exportar pro Figma (é `html-to-figma`).

Se durante a captura você notar que a tela está errada em relação à documentação, **reporte** — não corrija de passagem. Corrigir tela é `design-screen`, com plano próprio.
