# Stack do protótipo — receita Vite + React + TS + Tailwind (padrão do pack)

Receita default. Projeto com outra stack de front **sobrescreve este arquivo** em
`org/workflows/design-setup/references/stack-react-vite.md` (ou
`design-screen/references/`) — o contrato do `SKILL.md` continua valendo, só a
implementação muda.

## Scaffold (só se `prototype/` não existir)

```bash
npm create vite@latest prototype -- --template react-ts
cd prototype
npm i react-router-dom lucide-react
npm i -D tailwindcss @tailwindcss/vite
```

## Estrutura

```
prototype/
├── tailwind.config.js      ← tokens extraídos (fonte de verdade; nenhum hex solto no JSX)
├── src/
│   ├── main.tsx / App.tsx  ← <AppLayout><Outlet/></AppLayout>
│   ├── router.tsx          ← `/` redireciona à tela default (sem página-índice/hub)
│   ├── routes/<modulo>/<tela>.tsx
│   ├── components/ui/      ← componentes base sobre libs prontas, verbatim das evidências
│   ├── components/layout/  ← AppLayout + AppHeader (menu de navegação REAL do produto)
│   ├── lib/ExportFrame.tsx ← wrapper 1280 sem chrome, ativado por ?export=1 (export canvas)
│   ├── lib/scenarios.tsx   ← painel de cenários — cópia VERBATIM de `assets/scenarios.tsx`
│   └── mock/
```

## Convenções da stack

- Tailwind v4 via plugin do Vite (`@tailwindcss/vite`), não PostCSS.
- Componentes de `ui/` envolvem o primitivo da lib já estilizado pros tokens; as telas
  importam de `ui/`, **nunca da lib direto**. Instale no setup as libs que o design system
  precisa.
- Ícones: `lucide-react`. Rotas: `react-router-dom` (`createBrowserRouter`).
- Estados de tela via query (`?state=` e afins, `useSearchParams`), no mesmo arquivo da
  tela, **declarados ao painel** com `useScenarios`.

## Painel de cenários (`lib/scenarios.tsx`)

- **Não se escreve: copia-se** `assets/scenarios.tsx` (desta skill) para
  `prototype/src/lib/scenarios.tsx`, sem editar. Comportamento e visual já estão nele —
  paleta `neutral` padrão do Tailwind, fora dos tokens do produto por desenho (é moldura de
  apresentação, não tela; a regra "nenhum valor solto" continua valendo para as telas).
  Versão nova do asset → recopiar por cima.
- Montagem uma vez, num `RootLayout` que envolve todas as rotas no `router.tsx`:

  ```tsx
  function RootLayout() {
    return (
      <ScenarioProvider dimensoes={dimensoes /* opcional */} telas={telas}>
        <ScenarioOutlet />
        <ScenarioPanel />
      </ScenarioProvider>
    )
  }
  ```

- `ScenarioOutlet` no lugar do `<Outlet />`: trocar de cenário pelo painel remonta a tela,
  então estado lido só no `useState` inicial também responde.
- `telas`: `TelaPrototipo[]` em `mock/telas.ts` — `{ grupo, titulo, rota, para? }`, uma por
  rota registrada. Dá o nome da tela no cabeçalho e a seção "Ir para outra tela" (agrupada
  por `grupo`, ex.: perfil de quem usa). `rota` é o padrão do roteador; rota com parâmetro
  precisa de `para` (instância de exemplo) para virar atalho. Rota nova → linha nova aqui.
- Painel visível por padrão; `P` oculta/mostra (lembrado em `sessionStorage`).
- A tela declara seus cenários no próprio arquivo (pode chamar mais de uma vez):

  ```tsx
  useScenarios([
    { grupo: 'Estado', opcoes: [
      { rotulo: 'Padrão', query: { state: null } },
      { rotulo: 'Vazio', dica: 'Nenhum registro no filtro', query: { state: 'empty' } },
    ]},
    { grupo: 'Contrato', opcoes: [
      { rotulo: 'Exclusivo', para: '/contratos/contrato-002' },
    ]},
  ])
  ```

  `query` mescla na URL (`null` remove o parâmetro); `para` navega; `dica` é uma linha do
  que o cenário mostra. Opção ativa = a mais específica que casa com a URL atual; o botão
  flutuante exibe a do primeiro grupo que casa com a URL. "Voltar ao padrão" limpa os parâmetros declarados.
  Nenhuma declaração → "sem cenários".
- Grupo repetido em várias telas (ex.: troca de contrato) vira helper do projeto, fora de
  `lib/scenarios.tsx`.
- Dimensões globais (ex.: perfil): `DimensaoGlobal[]` em `mock/dimensoes.ts`, passado ao
  `ScenarioProvider` pela prop `dimensoes`; gravadas em query (`?perfil=`) e preservadas ao
  trocar de cenário. A tela lê o valor com `useSearchParams`. Sem dimensões → prop omitida.
- `prototype/README.md` recebe o texto de `assets/README-apresentacao.md`.

## Servir e verificar

```bash
cd prototype && npm run dev
```

`/` abre a tela default; o menu navega. Build de validação: `npm run build` (roda `tsc -b`).
