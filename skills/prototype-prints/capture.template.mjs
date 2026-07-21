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
    await page.screenshot({ path, clip })
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

/**
 * Tela inteira pronta para DOCX: divide por tamanho, sem lacuna ou sobreposição.
 * Cada parte completa tem altura = largura × 1,10; a última usa o restante.
 */
async function full(name) {
  const dimensions = await page.evaluate(() => ({
    width: Math.max(document.documentElement.scrollWidth, document.body.scrollWidth),
    height: Math.max(document.documentElement.scrollHeight, document.body.scrollHeight),
  }))
  const sliceHeight = Math.floor(dimensions.width * DOCX_HEIGHT_RATIO)
  const total = Math.ceil(dimensions.height / sliceHeight)

  for (let index = 0; index < total; index += 1) {
    const y = index * sliceHeight
    const height = Math.min(sliceHeight, dimensions.height - y)
    const outputName = total === 1 ? name : partName(name, index)
    await screenshotClipWithBorder(
      { x: 0, y, width: dimensions.width, height },
      file(outputName),
    )
  }
}

/** Modal recortado no limite do elemento — nunca o viewport com o fundo atrás. */
async function modal(name) {
  await page.waitForSelector(MODAL)
  await page.waitForTimeout(350)
  await screenshotElementWithBorder(page.locator(MODAL).first(), file(name))
}

/** Componente isolado (tabela, card, painel) pelo aria-label ou seletor. */
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
await full('01_nome-da-tela')

await page.getByRole('button', { name: 'Abrir Modal' }).click()
await modal('02_nome-do-modal')
await closeModal()

// Prefira aria-label a texto quando houver várias linhas com a mesma ação:
// await page.locator('[aria-label="<label da linha alvo>"]').click()

await browser.close()
console.log('prints salvos em', OUT)
