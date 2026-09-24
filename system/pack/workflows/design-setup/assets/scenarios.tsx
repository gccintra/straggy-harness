/**
 * Painel de cenários do protótipo — componente do harness (HRN-011/HRN-012/HRN-016).
 *
 * Copiado VERBATIM pelo design-setup para `prototype/src/lib/scenarios.tsx`. Não edite por
 * projeto: o painel é moldura de apresentação, com visual fixo na paleta `neutral` padrão do
 * Tailwind, fora dos tokens do produto de propósito.
 *
 * Uso:
 *   <ScenarioProvider dimensoes={dimensoes} telas={telas}>   ← uma vez, no RootLayout
 *     <ScenarioOutlet /> <ScenarioPanel />
 *   </ScenarioProvider>
 *   useScenarios([...grupos])                                ← em cada tela que tem estados
 *
 * Helper de cenário específico do projeto (ex.: trocar de contrato) mora no projeto, não aqui.
 */
import {
  Fragment,
  createContext,
  useCallback,
  useContext,
  useEffect,
  useId,
  useMemo,
  useRef,
  useState,
  type ReactNode,
} from 'react'
import { Link, Outlet, matchPath, useLocation, useNavigate } from 'react-router-dom'
import { ChevronRight, Layers, X } from 'lucide-react'

export type ScenarioQuery = Record<string, string | null>

export type ScenarioOption = {
  rotulo: string
  /** Uma linha abaixo do rótulo: o que o cenário mostra. */
  dica?: string
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

/** Tela do protótipo: dá o nome no cabeçalho e o atalho em "Ir para outra tela". */
export type TelaPrototipo = {
  grupo: string
  titulo: string
  /** Padrão do roteador (`/pedidos/:id`) — reconhece a tela atual. */
  rota: string
  /** Destino do atalho. Ausente: `rota`, se não tiver parâmetro; senão a tela não vira atalho. */
  para?: string
}

type NavState = { cenario?: number } | null

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
const TelasContext = createContext<TelaPrototipo[]>([])

export function ScenarioProvider({
  dimensoes = [],
  telas = [],
  children,
}: {
  dimensoes?: DimensaoGlobal[]
  telas?: TelaPrototipo[]
  children: ReactNode
}) {
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
        <TelasContext.Provider value={telas}>
          <RegistryContext.Provider value={registry}>{children}</RegistryContext.Provider>
        </TelasContext.Provider>
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

/** `<Outlet />` que remonta a tela quando o cenário muda pelo painel: estado lido só no
    `useState` inicial passa a responder. Navegação comum não remonta. */
export function ScenarioOutlet() {
  const location = useLocation()
  const chave = useRef(0)
  const cenario = (location.state as NavState)?.cenario
  if (cenario) chave.current = cenario
  return (
    <Fragment key={chave.current}>
      <Outlet />
    </Fragment>
  )
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
  const state: NavState = { cenario: Date.now() }
  if (option.para) {
    const url = new URL(option.para, window.location.origin)
    const next = new URLSearchParams(url.search)
    for (const dimensao of dimensoes) {
      if (next.has(dimensao.param)) continue
      const valor = params.get(dimensao.param)
      if (valor) next.set(dimensao.param, valor)
    }
    navigate({ pathname: url.pathname, search: next.toString() }, { state })
    return
  }

  const next = new URLSearchParams(params)
  for (const [key, value] of Object.entries(option.query ?? {})) {
    if (value === null) next.delete(key)
    else next.set(key, value)
  }
  navigate({ pathname, search: next.toString() }, { replace: true, state })
}

/** Parâmetros que os grupos da tela declaram — o que "Voltar ao padrão" limpa. */
function chavesDeclaradas(groups: ScenarioGroup[]) {
  const chaves = new Set<string>()
  for (const group of groups) {
    for (const opcao of group.opcoes) {
      for (const key of Object.keys(opcao.query ?? {})) chaves.add(key)
    }
  }
  return [...chaves]
}

function destinoDa(tela: TelaPrototipo) {
  return tela.para ?? (tela.rota.includes(':') ? undefined : tela.rota)
}

function Opcao({
  selecionada,
  onClick,
  rotulo,
  dica,
}: {
  selecionada: boolean
  onClick: () => void
  rotulo: string
  dica?: string
}) {
  return (
    <button
      type="button"
      role="radio"
      aria-checked={selecionada}
      onClick={onClick}
      className={`flex w-full items-start gap-2.5 rounded-lg px-2.5 py-2 text-left text-sm leading-snug focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500/40 ${selecionada ? 'bg-blue-50' : 'hover:bg-neutral-50'}`}
    >
      <span
        aria-hidden="true"
        className={`mt-[3px] grid size-3.5 shrink-0 place-items-center rounded-full border ${selecionada ? 'border-blue-600' : 'border-neutral-300 bg-white'}`}
      >
        {selecionada ? <span className="size-1.5 rounded-full bg-blue-600" /> : null}
      </span>
      <span className="min-w-0">
        <span className={`block ${selecionada ? 'font-medium text-neutral-900' : 'text-neutral-700'}`}>{rotulo}</span>
        {dica ? <span className="mt-0.5 block text-xs text-neutral-500">{dica}</span> : null}
      </span>
    </button>
  )
}

function Grupo({ titulo, children }: { titulo: string; children: ReactNode }) {
  return (
    <section>
      <h3 className="mb-1 px-2.5 text-xs font-semibold text-neutral-500">{titulo}</h3>
      <div role="radiogroup" aria-label={titulo} className="flex flex-col gap-0.5">
        {children}
      </div>
    </section>
  )
}

function GrupoTelas({
  grupo,
  telas,
  atual,
  aberto,
  onAlternar,
  onIr,
}: {
  grupo: string
  telas: TelaPrototipo[]
  atual: TelaPrototipo | undefined
  aberto: boolean
  onAlternar: () => void
  onIr: () => void
}) {
  const id = useId()
  return (
    <div>
      <button
        type="button"
        aria-expanded={aberto}
        aria-controls={id}
        onClick={onAlternar}
        className="flex w-full items-center gap-1.5 rounded-lg px-2.5 py-1.5 text-left text-xs font-semibold text-neutral-500 hover:bg-neutral-50 hover:text-neutral-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500/40"
      >
        <ChevronRight size={14} aria-hidden="true" className={`shrink-0 transition-transform ${aberto ? 'rotate-90' : ''}`} />
        <span className="flex-1">{grupo}</span>
        <span className="font-normal text-neutral-400">{telas.length}</span>
      </button>
      {aberto ? (
        <div id={id} className="mt-0.5 flex flex-col gap-0.5 pl-4">
          {telas.map((tela) => {
            const ehAtual = tela === atual
            return (
              <Link
                key={tela.rota}
                to={destinoDa(tela)!}
                state={{ cenario: Date.now() } satisfies NavState}
                onClick={onIr}
                aria-current={ehAtual ? 'page' : undefined}
                className={`rounded-lg px-2.5 py-1.5 text-sm no-underline hover:no-underline focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500/40 ${ehAtual ? 'bg-blue-50 font-medium text-blue-700 hover:text-blue-700' : 'font-normal text-neutral-600 hover:bg-neutral-50 hover:text-neutral-900'}`}
              >
                {tela.titulo}
              </Link>
            )
          })}
        </div>
      ) : null}
    </div>
  )
}

export function ScenarioPanel() {
  const location = useLocation()
  const navigate = useNavigate()
  const registry = useContext(RegistryContext)
  const dimensoes = useContext(DimensoesContext)
  const telas = useContext(TelasContext)
  const params = useMemo(() => new URLSearchParams(location.search), [location.search])
  const [visible, setVisible] = useState(lerVisivel)
  const [open, setOpen] = useState(false)
  const painel = useRef<HTMLElement>(null)
  const botao = useRef<HTMLButtonElement>(null)
  const tituloId = useId()
  const [gruposAbertos, setGruposAbertos] = useState<string[] | null>(null)

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

  useEffect(() => {
    if (!open) return
    painel.current?.querySelector<HTMLElement>('[aria-checked="true"], button')?.focus()
    function onKey(event: KeyboardEvent) {
      if (event.key !== 'Escape') return
      setOpen(false)
      botao.current?.focus()
    }
    function onPointer(event: PointerEvent) {
      const alvo = event.target as Node
      if (painel.current?.contains(alvo) || botao.current?.contains(alvo)) return
      setOpen(false)
    }
    window.addEventListener('keydown', onKey)
    window.addEventListener('pointerdown', onPointer)
    return () => {
      window.removeEventListener('keydown', onKey)
      window.removeEventListener('pointerdown', onPointer)
    }
  }, [open])

  if (params.get('export') === '1' || navigator.webdriver || !visible) return null

  // O efeito do filho registra antes do pai: inverte para o layout vir antes da aba.
  const groups = [...registry.values()].reverse().flat()
  const telaAtual = telas.find((tela) => matchPath({ path: tela.rota, end: true }, location.pathname))
  const chaves = chavesDeclaradas(groups)
  const alterado = chaves.some((key) => params.has(key))
  // Tela com grupo do layout e grupo da aba: o botão mostra o primeiro que casa com a URL.
  const rotuloBotao = groups.map((group) => activeOption(group, location.pathname, params)).find(Boolean)?.rotulo ?? 'Cenários'
  const grupos = [...new Set(telas.filter((tela) => destinoDa(tela)).map((tela) => tela.grupo))]
  // Grupo da tela atual começa aberto; os demais recolhidos até o clique.
  const abertos = gruposAbertos ?? (telaAtual ? [telaAtual.grupo] : [])
  const alternarGrupo = (grupo: string) =>
    setGruposAbertos((atual) => {
      const base = atual ?? (telaAtual ? [telaAtual.grupo] : [])
      return base.includes(grupo) ? base.filter((g) => g !== grupo) : [...base, grupo]
    })

  const fechar = () => {
    setOpen(false)
    botao.current?.focus()
  }

  return (
    <div className="fixed bottom-5 right-5 z-[60] flex flex-col items-end gap-2 font-[system-ui,-apple-system,'Segoe_UI',Roboto,sans-serif] text-neutral-900 antialiased print:hidden">
      {open && (
        <section
          ref={painel}
          role="dialog"
          aria-labelledby={tituloId}
          className="flex max-h-[min(75vh,36rem)] w-80 flex-col overflow-hidden rounded-2xl border border-neutral-200 bg-white shadow-[0_12px_40px_rgba(0,0,0,0.14)]"
        >
          <header className="flex items-start gap-3 border-b border-neutral-200 bg-neutral-50 px-4 py-3">
            <span className="mt-0.5 grid size-7 shrink-0 place-items-center rounded-full bg-white text-blue-600 ring-1 ring-neutral-200">
              <Layers size={14} aria-hidden="true" />
            </span>
            <div className="min-w-0 flex-1">
              <p className="text-[11px] font-medium uppercase tracking-wide text-neutral-500">Protótipo · cenários</p>
              <h2 id={tituloId} className="truncate text-sm font-semibold text-neutral-900">
                {telaAtual?.titulo ?? 'Cenários'}
              </h2>
            </div>
            <kbd title="P mostra/oculta" className="mt-0.5 rounded-md border border-neutral-200 bg-white px-1.5 py-0.5 text-[11px] font-medium text-neutral-500">P</kbd>
            <button
              type="button"
              onClick={fechar}
              aria-label="Fechar painel de cenários"
              className="-mr-1 rounded-md p-1 text-neutral-400 hover:bg-neutral-200/60 hover:text-neutral-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500/40"
            >
              <X size={16} aria-hidden="true" />
            </button>
          </header>

          <div className="flex flex-col gap-4 overflow-y-auto p-3">
            {dimensoes.map((dimensao) => (
              <Grupo key={dimensao.param} titulo={dimensao.grupo}>
                {dimensao.opcoes.map((opcao) => {
                  const ativa = opcao.valor === null ? params.get(dimensao.param) === null : params.get(dimensao.param) === opcao.valor
                  return (
                    <Opcao
                      key={opcao.rotulo}
                      selecionada={ativa}
                      rotulo={opcao.rotulo}
                      onClick={() => applyOption({ rotulo: opcao.rotulo, query: { [dimensao.param]: opcao.valor } }, location.pathname, params, navigate, dimensoes)}
                    />
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
                  {group.opcoes.map((opcao) => (
                    <Opcao
                      key={opcao.rotulo}
                      selecionada={ativa?.rotulo === opcao.rotulo && optionMatches(opcao, location.pathname, params)}
                      rotulo={opcao.rotulo}
                      dica={opcao.dica}
                      onClick={() => applyOption(opcao, location.pathname, params, navigate, dimensoes)}
                    />
                  ))}
                </Grupo>
              )
            })}

            {alterado ? (
              <button
                type="button"
                onClick={() => applyOption({ rotulo: 'Padrão', query: Object.fromEntries(chaves.map((key) => [key, null])) }, location.pathname, params, navigate, dimensoes)}
                className="self-start px-2.5 text-sm font-medium text-blue-600 underline-offset-4 hover:text-blue-700 hover:underline focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500/40"
              >
                Voltar ao padrão
              </button>
            ) : null}

            {telas.length > 0 ? (
              <section className="border-t border-neutral-200 pt-3">
                <h3 className="mb-1 px-2.5 text-xs font-semibold text-neutral-500">Ir para outra tela</h3>
                <div className="flex flex-col gap-0.5">
                  {grupos.map((grupo) => (
                    <GrupoTelas
                      key={grupo}
                      grupo={grupo}
                      telas={telas.filter((tela) => tela.grupo === grupo && destinoDa(tela))}
                      atual={telaAtual}
                      aberto={abertos.includes(grupo)}
                      onAlternar={() => alternarGrupo(grupo)}
                      onIr={() => setOpen(false)}
                    />
                  ))}
                </div>
              </section>
            ) : null}
          </div>
        </section>
      )}

      <button
        ref={botao}
        type="button"
        title="P mostra/oculta"
        aria-label={`Cenários: ${rotuloBotao}. P mostra/oculta`}
        aria-expanded={open}
        aria-haspopup="dialog"
        onClick={() => setOpen((current) => !current)}
        className="flex h-11 items-center gap-2 rounded-full border border-neutral-200 bg-white pl-1.5 pr-2.5 shadow-[0_8px_24px_rgba(0,0,0,0.12)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500/40"
      >
        <span className="relative grid size-8 place-items-center rounded-full bg-blue-50 text-blue-600">
          <Layers size={15} aria-hidden="true" />
          {alterado ? <span className="absolute -right-0.5 -top-0.5 size-2.5 rounded-full border-2 border-white bg-blue-600" aria-hidden="true" /> : null}
        </span>
        <span className="max-w-40 truncate text-sm font-medium text-neutral-900">{rotuloBotao}</span>
        <kbd className="rounded border border-neutral-200 bg-neutral-50 px-1.5 py-0.5 text-[11px] font-medium text-neutral-500">P</kbd>
      </button>
    </div>
  )
}
