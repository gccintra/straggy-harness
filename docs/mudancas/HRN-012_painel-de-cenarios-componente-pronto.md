# HRN-012 — Painel de cenários: componente pronto, mesmo visual em todo protótipo

| | |
|---|---|
| **Estado** | verde |
| **Camada** | L2 pack |
| **Arquivos** | `system/pack/workflows/design-setup/assets/scenarios.tsx` (novo) · `system/pack/workflows/design-setup/assets/README-apresentacao.md` (novo) · `system/pack/workflows/design-setup/SKILL.md` · `system/pack/workflows/design-setup/references/stack-react-vite.md` |
| **Data** | 2026-09-24 |
| **Depende de** | [HRN-011](HRN-011_painel-de-cenarios.md) |

## História

Como **quem apresenta protótipos de vários projetos**, quero **que o painel de cenários tenha
sempre o mesmo visual e o mesmo código**, para **o cliente reconhecê-lo como ferramenta de
apresentação e o agente não reinventá-lo a cada projeto**.

A HRN-011 padronizou comportamento, não aparência: cada agente montaria o painel com os
tokens do projeto, e o painel ficaria diferente por projeto — e parecido com o produto.

## Regras de negócio

- **RN-01.** O painel é um arquivo pronto do pack (`assets/scenarios.tsx`), copiado verbatim
  para `prototype/src/lib/scenarios.tsx`. O agente não o reescreve. Padrão de origem: o painel
  construído no protótipo do OBRASIM.
- **RN-02.** Visual fixo em classes da paleta `neutral` padrão do Tailwind, sem tokens do
  produto: botão-pílula "Cenários" + `kbd` P, ícone `Layers`. É moldura de apresentação; a
  regra "nenhum valor solto" segue valendo para as telas.
- **RN-03.** API: `ScenarioProvider`, `ScenarioPanel`, `useScenarios` (registro por contexto,
  várias chamadas por tela). Montagem uma vez no `RootLayout` do roteador. Painel **visível
  por padrão**; `P` oculta/mostra (a HRN-011 não fixava o padrão). Oculto com `?export=1`, sob
  `navigator.webdriver` e na impressão.
- **RN-04.** Dimensões globais entram por prop do `ScenarioProvider` (`dimensoes`) — o asset
  nunca é editado para ativar perfil. Helper de cenário do projeto (ex.: troca de contrato)
  vive no projeto, fora do asset.
- **RN-05.** O texto "Apresentando ao cliente" é asset (`README-apresentacao.md`), copiado
  para `prototype/README.md`.

## Impacto

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | `stack-react-vite.md` (seção do painel) e `design-setup/SKILL.md` descreviam o painel para ser escrito | passam a mandar copiar o asset; `mock/dimensoes.ts` agora entra por prop |
| Esteira | nenhuma ação produz/exige artefato novo | — (vazio) |
| Evals | nenhuma ação muda | — (vazio) |
| Organização | sem override de `design-setup`. Organização que trocar a stack (encaixe `stack-prototipo`) não usa o asset React — esperado | — |
| Camada | pack; `assets/` é pasta prevista da skill e é copiada pelo build | mantém |

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | Contrato íntegro | `./build.sh --strict` sai 0 |
| CA-02 | O asset chega à visão resolvida | `runtime/skills/design-setup/assets/scenarios.tsx` existe após o build |
| CA-03 | O asset compila na stack padrão | `tsc --noEmit` do `prototype/` com o asset copiado, sem erro no arquivo |

## Fora de escopo

- Tema claro/escuro do painel ou personalização por projeto — contraria a RN-02.
- Adequar o `prototype/` deste projeto (passo da `design-screen`).

## Registro

- Primeira execução (2026-09-23) pulou o portão: arquivos escritos antes da spec aprovada.
  Refeita a partir do painel do protótipo OBRASIM, com proposta aprovada antes de editar.
- Desvios do padrão de origem, aprovados: sai o helper `cenarioContrato` (específico do
  projeto); dimensões por prop do `ScenarioProvider`; `Opcao`/`Grupo` fora do render (evita
  remontagem e perda de foco); `sessionStorage` com `try/catch`.
- CA-01: `build.sh --strict` → `contrato: ok (0 aviso(s))`.
- CA-02: `runtime/skills/design-setup/assets/` com `scenarios.tsx` e `README-apresentacao.md`.
- CA-03: asset copiado temporariamente para `prototype/src/lib/`, `tsc --noEmit` sem erro
  nele; cópia removida.
