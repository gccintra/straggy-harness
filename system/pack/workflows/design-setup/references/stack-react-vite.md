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
│   └── mock/
```

## Convenções da stack

- Tailwind v4 via plugin do Vite (`@tailwindcss/vite`), não PostCSS.
- Componentes de `ui/` envolvem o primitivo da lib já estilizado pros tokens; as telas
  importam de `ui/`, **nunca da lib direto**. Instale no setup as libs que o design system
  precisa.
- Ícones: `lucide-react`. Rotas: `react-router-dom` (`createBrowserRouter`).
- Estados de tela via `?state=` (`useSearchParams`), no mesmo arquivo da tela.

## Servir e verificar

```bash
cd prototype && npm run dev
```

`/` abre a tela default; o menu navega. Build de validação: `npm run build` (roda `tsc -b`).
