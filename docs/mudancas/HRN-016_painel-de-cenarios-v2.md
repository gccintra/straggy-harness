# HRN-016 — Painel de cenários v2: cabeçalho da tela, dicas e "Ir para outra tela"

| | |
|---|---|
| **Estado** | verde |
| **Camada** | L2 pack |
| **Arquivos** | `system/pack/workflows/design-setup/assets/scenarios.tsx` · `system/pack/workflows/design-setup/assets/README-apresentacao.md` · `system/pack/workflows/design-setup/references/stack-react-vite.md` |
| **Data** | 2026-09-24 |
| **Depende de** | [HRN-012](HRN-012_painel-de-cenarios-componente-pronto.md) · [HRN-015](HRN-015_runtime-sempre-em-dia.md) |

## História

Como **quem apresenta o protótipo**, quero **ver no painel qual tela e qual estado estou
mostrando, com uma frase do que cada estado significa, e pular para qualquer outra tela
dali**, para **conduzir a demo sem navegar pelo menu nem decorar rota**.

Padrão de origem: o seletor construído no protótipo do CRT em 2026-09-24 (aprovado pelo
usuário no layout — cabeçalho escuro com o nome da tela, estados separados por grupo,
seção de todas as telas), no visual `neutral` do asset — não no visual do produto.

## Regras de negócio

- **RN-01.** API da HRN-012 compatível: `ScenarioProvider`, `ScenarioPanel`, `useScenarios`,
  `dimensoes`, tecla `P`, oculto em `?export=1`, automação e impressão. Protótipo com a v1
  recopia o asset sem editar tela.
- **RN-02.** Cabeçalho claro (`neutral-50` com borda): rótulo "Protótipo · cenários", nome da tela atual,
  `kbd` P e fechar. Nome vem da prop `telas`; tela fora da lista → "Cenários".
- **RN-03.** Opção em lista com rádio (linha ativa em `neutral-100`), com `dica` opcional
  abaixo do rótulo.
- **RN-04.** Botão flutuante mostra o rótulo da opção ativa do primeiro grupo que casa com a URL e um ponto
  quando algum parâmetro declarado está na URL; o painel oferece "Voltar ao padrão", que
  remove esses parâmetros.
- **RN-05.** Seção "Ir para outra tela", agrupada por `grupo`, a partir da prop `telas`
  (`{ grupo, titulo, rota, para? }`); cada grupo expande e recolhe, com contagem; abre só o
  grupo da tela atual; tela atual destacada. Sem `telas` → seção omitida.
- **RN-06.** `ScenarioOutlet` (novo, opcional no lugar do `<Outlet />`) remonta a tela quando
  o cenário muda pelo painel — estado lido só no `useState` inicial passa a responder. Troca
  de rota comum não remonta.
- **RN-07.** Esc e clique fora fecham; ao abrir, o foco vai para a opção ativa.

## Impacto

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | `stack-react-vite.md:29,41-84` (montagem e API) · `design-setup/SKILL.md:63` (contrato do painel) · `design-screen/SKILL.md:65` (`useScenarios`) · `html-to-figma/SKILL.md:48` (oculto no export) · `README-apresentacao.md` | stack ganha `ScenarioOutlet`, `telas`, `dica`; README ganha as duas seções novas; demais seguem válidos (API compatível) |
| Esteira | nenhuma | — (vazio) |
| Evals | nenhum caso cita comportamento do painel | — (vazio) |
| Organização | nenhum override de `design-setup` | — (vazio) |
| Camada | asset do pack, igual em todo projeto | mantém |

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | Contrato íntegro | `./build.sh --strict` sai 0 |
| CA-02 | Asset compila numa instância real | cópia verbatim em `prototype/src/lib/scenarios.tsx` do CRT + `npx tsc -b` limpo |

## Fora de escopo

- Carregar cenário entre abas da tela (componente de abas é do projeto).
- Tema escuro do painel.

## Registro

- CA-01: `build.sh --strict --env /dev/null` → exit 0.
- CA-02: asset copiado verbatim para o protótipo do CRT (`cmp` igual); `npx tsc -b` limpo;
  verificado no browser (remonta ao trocar cenário, "Ir para outra tela", `P`, `?export=1`).
- Não previsto: 1) o efeito do filho registra antes do pai, então os grupos da aba apareciam
  antes do grupo "Estado" do layout — o painel agora inverte a ordem (de fora para dentro);
  2) o botão mostra a opção ativa do **primeiro grupo que casa** com a URL, não do primeiro
  grupo — senão um grupo da aba sem opção ativa escondia o estado da tela.
- Revisão do usuário (mesmo dia): cabeçalho preto saiu (claro, com borda); seletor em
  segmentos trocado por lista com rádio, como no seletor original do CRT; grupos de "Ir para
  outra tela" passaram a expandir e recolher. Painel ganhou fonte do sistema e links imunes
  ao CSS global do produto (o `a { font-weight: bolder }` do CRT vazava).
- Cor de destaque única, `blue-600` (5,2:1 sobre branco — AA), só onde há seleção: rádio
  marcado e linha em `blue-50`, tela atual, ícone do cabeçalho e do botão, ponto de "fora do
  padrão", "Voltar ao padrão" e anel de foco. Resto segue `neutral`. Azul é o sinal
  universal de seleção e não compete com a paleta de produto nenhum.
