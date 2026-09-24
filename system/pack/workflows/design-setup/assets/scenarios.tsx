/**
 * Painel de cenários do protótipo — componente do harness (HRN-011/HRN-012).
 *
 * Copiado VERBATIM pelo design-setup para `prototype/src/lib/scenarios.tsx`. Não edite por
 * projeto: o painel é moldura de apresentação, com visual fixo na paleta `neutral` padrão do
 * Tailwind, fora dos tokens do produto de propósito.
 *
 * Uso:
 *   <ScenarioProvider dimensoes={dimensoes}>   ← uma vez, no RootLayout do roteador
 *     <Outlet /> <ScenarioPanel />
 *   </ScenarioProvider>
 *   useScenarios([...grupos])                  ← em cada tela que tem estados
 *
 * Helper de cenário específico do projeto (ex.: trocar de contrato) mora no projeto, não aqui.
 */
import { createContext, useCallback, useContext, useEffect, useId, useMemo, useState, type ReactNode } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import { Layers } from 'lucide-react'

export type ScenarioQuery = Record<string, string | null>

export type ScenarioOption = {
  rotulo: string
  /** Parâmetros mesclados na query. `null` remove o parâmetro. */
  query?: ScenarioQuery
  /** Caminho de destino (pode ter query). */
  para?: string
}

export type ScenarioGroup = {
  grupo: string
  opcoes: ScenarioOption[]
}

/** Dimensão global (ex.: perfil): vale para todas as telas e sobrevive à troca de cenário. */
export type DimensaoGlobal = {
  grupo: string
  param: string
  opcoes: { rotulo: string; valor: string | null }[]
}

const VISIBLE_KEY = 'prototype.scenarios.visible'

function lerVisivel() {
  try {
    return sessionStorage.getItem(VISIBLE_KEY) !== '0'
  } catch {
    return true
  }
}

function gravarVisivel(visible: boolean) {
  try {
    sessionStorage.setItem(VISIBLE_KEY, visible ? '1' : '0')
  } catch {
    /* sem storage: o painel só não lembra entre recargas */
  }
}

type Registry = Map<string, ScenarioGroup[]>

const SetterContext = createContext<(id: string, groups: ScenarioGroup[] | null) => void>(() => {})
const RegistryContext = createContext<Registry>(new Map())
const DimensoesContext = createContext<DimensaoGlobal[]>([])

export function ScenarioProvider({ dimensoes = [], children }: { dimensoes?: DimensaoGlobal[]; children: ReactNode }) {
  const [registry, setRegistry] = useState<Registry>(() => new Map())
  const setEntry = useCallback((id: string, groups: ScenarioGroup[] | null) => {
    setRegistry((current) => {
      const next = new Map(current)
      if (groups) next.set(id, groups)
      else next.delete(id)
      return next
    })
  }, [])

  return (
    <SetterContext.Provider value={setEntry}>
      <DimensoesContext.Provider value={dimensoes}>
        <RegistryContext.Provider value={registry}>{children}</RegistryContext.Provider>
      </DimensoesContext.Provider>
    </SetterContext.Provider>
  )
}

export function useScenarios(groups: ScenarioGroup[]) {
  const setEntry = useContext(SetterContext)
  const id = useId()
  const serialized = JSON.stringify(groups)

  useEffect(() => {
    setEntry(id, JSON.parse(serialized) as ScenarioGroup[])
    return () => setEntry(id, null)
  }, [id, serialized, setEntry])
}

function optionMatches(option: ScenarioOption, pathname: string, params: URLSearchParams) {
  if (option.para) {
    const url = new URL(option.para, window.location.origin)
    if (url.pathname !== pathname) return false
    for (const [key, value] of url.searchParams) {
      if (params.get(key) !== value) return false
    }
    return true
  }

  if (!option.query) return false
  return Object.entries(option.query).every(([key, value]) => {
    const current = params.get(key)
    return value === null ? current === null : current === value
  })
}

function especificidade(option: ScenarioOption) {
  return option.para
    ? 100 + new URL(option.para, window.location.origin).searchParams.size
    : Object.values(option.query ?? {}).filter((value) => value !== null).length
}

function activeOption(group: ScenarioGroup, pathname: string, params: URLSearchParams) {
  const matches = group.opcoes.filter((option) => optionMatches(option, pathname, params))
  if (matches.length === 0) return undefined
  return matches.reduce((best, option) => (especificidade(option) > especificidade(best) ? option : best))
}

function applyOption(
  option: ScenarioOption,
  pathname: string,
  params: URLSearchParams,
  navigate: ReturnType<typeof useNavigate>,
  dimensoes: DimensaoGlobal[],
) {
  if (option.para) {
    const url = new URL(option.para, window.location.origin)
    const next = new URLSearchParams(url.search)
    for (const dimensao of dimensoes) {
      if (next.has(dimensao.param)) continue
      const valor = params.get(dimensao.param)
      if (valor) next.set(dimensao.param, valor)
    }
    navigate({ pathname: url.pathname, search: next.toString() })
    return
  }

  const next = new URLSearchParams(params)
  for (const [key, value] of Object.entries(option.query ?? {})) {
    if (value === null) next.delete(key)
    else next.set(key, value)
  }
  navigate({ pathname, search: next.toString() }, { replace: true })
}

function Opcao({ selecionada, onClick, children }: { selecionada: boolean; onClick: () => void; children: string }) {
  return (
    <button
      type="button"
      aria-pressed={selecionada}
      onClick={onClick}
      className={`min-h-11 rounded-lg px-3 text-left text-sm leading-snug focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-neutral-900/25 ${selecionada ? 'bg-white font-medium text-neutral-900 shadow-sm' : 'text-neutral-600 hover:text-neutral-900'}`}
    >
      {children}
    </button>
  )
}

function Grupo({ titulo, children }: { titulo: string; children: ReactNode }) {
  return (
    <section>
      <h3 className="mb-2 text-sm font-semibold text-neutral-900">{titulo}</h3>
      <div className="flex flex-col gap-0.5 rounded-xl bg-neutral-100 p-1">{children}</div>
    </section>
  )
}

export function ScenarioPanel() {
  const location = useLocation()
  const navigate = useNavigate()
  const registry = useContext(RegistryContext)
  const dimensoes = useContext(DimensoesContext)
  const params = useMemo(() => new URLSearchParams(location.search), [location.search])
  const [visible, setVisible] = useState(lerVisivel)
  const [open, setOpen] = useState(false)

  useEffect(() => {
    gravarVisivel(visible)
  }, [visible])

  useEffect(() => {
    function onKey(event: KeyboardEvent) {
      if (event.code !== 'KeyP' || event.metaKey || event.ctrlKey || event.altKey || event.shiftKey) return
      const target = event.target
      if (target instanceof Element && target.closest('input, textarea, select, [contenteditable="true"]')) return
      event.preventDefault()
      setVisible((current) => {
        if (current) setOpen(false)
        return !current
      })
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [])

  if (params.get('export') === '1' || navigator.webdriver || !visible) return null

  const groups = [...registry.values()].flat()

  return (
    <div className="fixed bottom-5 right-5 z-50 flex flex-col items-end gap-2 print:hidden">
      {open && (
        <section
          aria-label="Painel de cenários"
          className="max-h-[min(70vh,32rem)] w-80 overflow-y-auto rounded-2xl border border-neutral-200 bg-white p-4 shadow-[0_12px_40px_rgba(0,0,0,0.14)]"
        >
          <header className="mb-4 flex items-center gap-2">
            <span className="grid size-7 place-items-center rounded-full bg-neutral-900 text-white">
              <Layers size={14} aria-hidden="true" />
            </span>
            <h2 className="text-sm font-semibold text-neutral-900">Cenários</h2>
            <kbd title="P mostra/oculta" className="ml-auto rounded-md border border-neutral-200 bg-neutral-50 px-1.5 py-0.5 text-[11px] font-medium text-neutral-500">P</kbd>
          </header>
          <div className="flex flex-col gap-5">
            {dimensoes.map((dimensao) => (
              <Grupo key={dimensao.param} titulo={dimensao.grupo}>
                {dimensao.opcoes.map((opcao) => {
                  const ativa = opcao.valor === null ? params.get(dimensao.param) === null : params.get(dimensao.param) === opcao.valor
                  return (
                    <Opcao
                      key={opcao.rotulo}
                      selecionada={ativa}
                      onClick={() => applyOption({ rotulo: opcao.rotulo, query: { [dimensao.param]: opcao.valor } }, location.pathname, params, navigate, dimensoes)}
                    >
                      {opcao.rotulo}
                    </Opcao>
                  )
                })}
              </Grupo>
            ))}

            {groups.length === 0 ? (
              <p className="text-sm text-neutral-500">sem cenários</p>
            ) : groups.map((group) => {
              const ativa = activeOption(group, location.pathname, params)
              return (
                <Grupo key={group.grupo} titulo={group.grupo}>
                  {group.opcoes.map((opcao) => {
                    const selecionada = ativa?.rotulo === opcao.rotulo && optionMatches(opcao, location.pathname, params)
                    return (
                      <Opcao
                        key={opcao.rotulo}
                        selecionada={selecionada}
                        onClick={() => applyOption(opcao, location.pathname, params, navigate, dimensoes)}
                      >
                        {opcao.rotulo}
                      </Opcao>
                    )
                  })}
                </Grupo>
              )
            })}
          </div>
        </section>
      )}

      <button
        type="button"
        title="P mostra/oculta"
        aria-label="Cenários. P mostra/oculta"
        aria-expanded={open}
        onClick={() => setOpen((current) => !current)}
        className="flex h-11 items-center gap-2 rounded-full border border-neutral-200 bg-white pl-1.5 pr-2.5 shadow-[0_8px_24px_rgba(0,0,0,0.12)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-neutral-900/30"
      >
        <span className="grid size-8 place-items-center rounded-full bg-neutral-900 text-white">
          <Layers size={15} aria-hidden="true" />
        </span>
        <span className="text-sm font-medium text-neutral-900">Cenários</span>
        <kbd className="rounded border border-neutral-200 bg-neutral-50 px-1.5 py-0.5 text-[11px] font-medium text-neutral-500">P</kbd>
      </button>
    </div>
  )
}
