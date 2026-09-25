/**
 * Template de captura de prints do protótipo.
 *
 * Copie para o scratchpad da sessão, ajuste BASE/OUT e a lista de shots, rode com:
 *   cd "$SCRATCHPAD" && npm init -y && npm i playwright && node capture.mjs
 *
 * Usa o Chrome do sistema (channel: 'chrome') — não baixa browser.
 * Nunca instale playwright dentro de prototype/.
 */
import { chromium } from 'playwright'
import fs from 'node:fs'

const BASE = 'http://localhost:5199'
const OUT = '/caminho/do/projeto/outputs/{ID}_{Nome}/prototipo-prints'
const DEVICE_SCALE_FACTOR = 2
const DOCX_HEIGHT_RATIO = 1.10
const BORDER_CSS_PX = 1 / DEVICE_SCALE_FACTOR

/** O card branco do modal, não o overlay. Confira em src/components/ui/Modal.tsx. */
const MODAL = 'div.fixed.inset-0.z-50 > div'

fs.mkdirSync(OUT, { recursive: true })

const browser = await chromium.launch({ channel: 'chrome' })
const page = await browser.newPage({
  viewport: { width: 1440, height: 900 },
  deviceScaleFactor: DEVICE_SCALE_FACTOR, // o docx amplia a imagem; 1x sai borrado
})

const file = (name) => `${OUT}/${name}.png`

function partName(name, index) {
  const match = name.match(/^(\d+)(_.+)$/)
  const suffix = String.fromCharCode('a'.charCodeAt(0) + index)
  return match ? `${match[1]}${suffix}${match[2]}` : `${name}-parte-${index + 1}`
}

async function goto(path) {
  await page.goto(BASE + path, { waitUntil: 'networkidle' })
  await page.waitForTimeout(400)
}

async function screenshotClipWithBorder(clip, path) {
  const overlayId = `print-border-${Date.now()}-${Math.random().toString(16).slice(2)}`
  await page.evaluate(({ id, box, border }) => {
    const overlay = document.createElement('div')
    overlay.id = id
    Object.assign(overlay.style, {
      position: 'absolute',
      left: `${box.x}px`,
      top: `${box.y}px`,
      width: `${box.width}px`,
      height: `${box.height}px`,
      boxSizing: 'border-box',
      boxShadow: `inset 0 0 0 ${border}px #000`,
      pointerEvents: 'none',
      zIndex: '2147483647',
    })
    document.body.appendChild(overlay)
  }, { id: overlayId, box: clip, border: BORDER_CSS_PX })

  try {
    // fullPage: sem ele, clip abaixo do viewport falha ("Clipped area is either empty…")
    await page.screenshot({ path, clip, fullPage: true })
  } finally {
    await page.evaluate((id) => document.getElementById(id)?.remove(), overlayId)
  }
}

async function screenshotElementWithBorder(target, path) {
  const previous = await target.evaluate((el) => ({ boxShadow: el.style.boxShadow }))
  await target.evaluate((el, border) => {
    const current = getComputedStyle(el).boxShadow
    const frame = `inset 0 0 0 ${border}px #000`
    el.style.boxShadow = current === 'none' ? frame : `${current}, ${frame}`
  }, BORDER_CSS_PX)

  try {
    await target.screenshot({ path })
  } finally {
    await target.evaluate((el, styles) => {
      el.style.boxShadow = styles.boxShadow
    }, previous)
  }
}

/** Corta [0, altura) da página em partes de largura × 1,10, sem lacuna nem sobreposição. */
async function fatiar(name, altura) {
  const width = await page.evaluate(() => Math.max(document.documentElement.scrollWidth, document.body.scrollWidth))
  const sliceHeight = Math.floor(width * DOCX_HEIGHT_RATIO)
  const total = Math.ceil(altura / sliceHeight)

  for (let index = 0; index < total; index += 1) {
    const y = index * sliceHeight
    const height = Math.min(sliceHeight, altura - y)
    const outputName = total === 1 ? name : partName(name, index)
    await screenshotClipWithBorder({ x: 0, y, width, height }, file(outputName))
  }
}

/** Tela inteira pronta para DOCX. */
async function full(name) {
  const altura = await page.evaluate(() => Math.max(document.documentElement.scrollHeight, document.body.scrollHeight))
  await fatiar(name, altura)
}

/**
 * PADRÃO — tela em contexto, sempre numa imagem só quando o alvo cabe nela.
 * Cabe do topo (cabeçalho, título) até o fim do alvo → corta ali.
 * Não cabe → janela de largura × 1,10 que termina no alvo e começa na borda de um bloco,
 * mostrando as seções vizinhas acima. Alvo maior que a janela → partes a partir do alvo.
 * `alvo` é seletor CSS ou Locator do último trecho que a demanda declara.
 */
async function contexto(alvo, name, folga = 24) {
  const target = typeof alvo === 'string' ? page.locator(alvo).first() : alvo
  await target.waitFor()
  const { topo, fim, largura, altura } = await target.evaluate((el, f) => {
    const b = el.getBoundingClientRect()
    return {
      topo: Math.floor(b.top + window.scrollY),
      fim: Math.ceil(b.bottom + window.scrollY + f),
      largura: Math.max(document.documentElement.scrollWidth, document.body.scrollWidth),
      altura: Math.max(document.documentElement.scrollHeight, document.body.scrollHeight),
    }
  }, folga)
  const limite = Math.floor(largura * DOCX_HEIGHT_RATIO)
  const final = Math.min(fim, altura)
  if (final <= limite) return fatiar(name, final)

  if (final - topo + folga > limite) {
    // alvo sozinho já passa da janela: partes contíguas a partir do alvo
    const inicio = Math.max(0, topo - folga)
    const sliceHeight = limite
    const total = Math.ceil((final - inicio) / sliceHeight)
    for (let index = 0; index < total; index += 1) {
      const y = inicio + index * sliceHeight
      const height = Math.min(sliceHeight, final - y)
      await screenshotClipWithBorder({ x: 0, y, width: largura, height }, file(total === 1 ? name : partName(name, index)))
    }
    return
  }

  const minimo = final - limite
  // janela única: começa no topo de um bloco irmão do alvo (ou de um ancestral dele),
  // nunca no meio de um card
  const inicio = await target.evaluate((el, { minimo, largura }) => {
    const tops = []
    for (let node = el; node && node !== document.body; node = node.parentElement) {
      for (let irmao = node; irmao; irmao = irmao.previousElementSibling) {
        const r = irmao.getBoundingClientRect()
        if (r.width > largura * 0.5) tops.push(Math.floor(r.top + window.scrollY))
      }
    }
    const cabem = tops.filter((t) => t >= minimo)
    return cabem.length ? Math.min(...cabem) : Math.floor(el.getBoundingClientRect().top + window.scrollY)
  }, { minimo, largura })
  await screenshotClipWithBorder({ x: 0, y: Math.max(0, inicio - 16), width: largura, height: final - Math.max(0, inicio - 16) }, file(name))
}

/**
 * PADRÃO para modal — aberto sobre a tela, fundo escurecido visível.
 * O viewport cresce até caber o modal inteiro e volta ao tamanho original depois.
 */
async function modalEmContexto(name) {
  await page.waitForSelector(MODAL)
  await page.waitForTimeout(350)
  const original = page.viewportSize()
  const alturaModal = await page.locator(MODAL).first().evaluate((el) => Math.ceil(el.scrollHeight))
  const altura = Math.max(original.height, alturaModal + 120)
  await page.setViewportSize({ width: original.width, height: altura })
  await page.waitForTimeout(250)
  try {
    await screenshotClipWithBorder({ x: 0, y: 0, width: original.width, height: altura }, file(name))
  } finally {
    await page.setViewportSize(original)
  }
}

/** EXCEÇÃO (só com pedido explícito) — modal recortado no limite do card, sem a tela. */
async function modal(name) {
  await page.waitForSelector(MODAL)
  await page.waitForTimeout(350)
  await screenshotElementWithBorder(page.locator(MODAL).first(), file(name))
}

/** EXCEÇÃO (só com pedido explícito) — componente isolado, sem a tela em volta. */
async function element(selector, name) {
  const target = page.locator(selector).first()
  await target.scrollIntoViewIfNeeded()
  await page.waitForTimeout(300)
  await screenshotElementWithBorder(target, file(name))
}

/**
 * Dropdown que renderiza em portal (MUI Autocomplete, Radix, Headless UI):
 * as opções ficam FORA do modal na árvore — recorte pela união dos retângulos.
 *
 * Não serve para <select> nativo: o popup é do sistema operacional e não
 * aparece em screenshot algum. Nesse caso capture o campo fechado.
 */
async function modalComPopper(name, popperSelector = '.MuiAutocomplete-popper') {
  const boxes = await page.evaluate(([modalSelector, popper]) => {
    const r = (el) => {
      const b = el.getBoundingClientRect()
      return { x: b.x, y: b.y, w: b.width, h: b.height }
    }
    const modalEl = document.querySelector(modalSelector)
    const popperEl = document.querySelector(popper)
    return popperEl ? [r(modalEl), r(popperEl)] : [r(modalEl)]
  }, [MODAL, popperSelector])

  const pad = 4
  const x = Math.min(...boxes.map((b) => b.x)) - pad
  const y = Math.min(...boxes.map((b) => b.y)) - pad
  const width = Math.max(...boxes.map((b) => b.x + b.w)) + pad - x
  const height = Math.max(...boxes.map((b) => b.y + b.h)) + pad - y
  await screenshotClipWithBorder({ x, y, width, height }, file(name))
}

async function closeModal() {
  const button = page.locator('[aria-label="Fechar modal"]').first()
  if (await button.count()) await button.click()
  await page.waitForTimeout(250)
}

// ---------------------------------------------------------------------------
// Fluxo 1 — <nome do fluxo, na ordem da seção Escopo da documentação>
// ---------------------------------------------------------------------------

await goto('/rota')
await contexto('[aria-label="<último trecho que a demanda declara>"]', '01_nome-do-trecho')
await full('02_nome-da-tela')

await page.getByRole('button', { name: 'Abrir Modal' }).click()
await modalEmContexto('03_nome-do-modal')
await closeModal()

// Prefira aria-label a texto quando houver várias linhas com a mesma ação:
// await page.locator('[aria-label="<label da linha alvo>"]').click()

await browser.close()
console.log('prints salvos em', OUT)
