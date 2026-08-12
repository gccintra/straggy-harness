---
name: design-screen
description: >
  Cria E ajusta telas como rotas React no app de protótipo do projeto (prototype/) a partir
  de uma demanda do backlog, documento de requisito, descrição livre ou número da demanda. Dois modos: AJUSTE (tela já
  existe → referência é o próprio protótipo, tokens e telas irmãs; NÃO pede print) e NOVO
  (tela inexistente → pede node do Figma, imagem ou wireframe). Reusa src/components/ui/,
  liga a rota ao menu real do produto e verifica por diff visual. Export de telas escolhidas
  pro Figma é opt-in. Use sempre que o usuário pedir criar OU ajustar uma tela, protótipo,
  componente ou fluxo. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de
  qualquer operação no backlog.
---

# design-screen — workflow L2

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` §3 (caminho é seu; suposição declarada) + autonomia local da profissão |
| Métodos | `system/professions/product-designer/methods/` — **`reference-authority.md`** (quem manda no visual; valor design vs medido; imagem se mede, wireframe nunca) · **`design-system-first.md`** (inventário + precedência de reúso) · **`visual-verification.md`** (diff obrigatório antes de entregar) · **`accessibility.md`** (checklist AA antes de entregar) |
| Providers | `canvas/` (ler node Figma, conversão pro padrão do app; node que estoura → subagente `figma-node-reader`) · `backlog/` — **com fallback local** (contexto de issue) |

Pré-requisito: `prototype/` existe (senão rode `design-setup`). Tela nova **sem** referência
externa não trava o trabalho: derive de tela irmã, design system e doc da demanda, construa
e declare o que assumiu.
**Transcrever, não re-autorar**: todo elemento da referência aparece, mesma ordem, nada
omitido nem "melhorado"; visual conforme a autoridade da referência.

## 1. Modo — decida ANTES de pedir qualquer coisa

Olhe o protótipo primeiro: a tela/componente já existe em `prototype/src/`?

- **AJUSTE** (existe): a referência é o próprio protótipo — ache o componente (`grep`),
  compare com tela irmã e tokens, edite pro padrão do sistema, verifique no Vite.
  **Sem pedir print/node, sem gate** — alinhamento prévio só se o "certo" for ambíguo.
- **NOVO** (não existe): carregue o contexto (demanda pelo provider / `outputs/{ID}_*/` /
  descrição). Existe node/imagem disponível? Peça **uma vez**, junto de tudo mais que
  precisar. Não existe? Derive de tela irmã + design system e siga — a fidelidade sobe
  depois, com a referência em mãos:
  > "Quais nodes do Figma eu uso? 1) Tela de referência (link ou nodeId); 2) componentes
  > específicos; 3) design system (opcional, já temos em `ui/`)."
  Nunca invente nodeId. Leitura e conversão do node: provider `canvas/figma-mcp.md`.
  Imagem → **meça com Pillow** (cor por pixel, medida por transição; retina ÷2; pergunte
  estados e fonte). Wireframe → passe pela `design-brief` antes (obrigatória).

## 2. Plano — proporcional, não obrigatório

- Já existe `outputs/{ID}_*/{ID}_design.md`? **Ele é o plano** — confirme em 2-3 linhas e
  construa. Demanda com documentação sem design doc → rode a `design-brief` antes.
- **Vai direto ao código** (sem gate): ajuste, tela com irmã óbvia, componente pequeno,
  estado faltando.
- **Alinha 3-5 linhas antes**: tela nova sem precedente, mudança de fluxo ou de navegação,
  algo que conflita com a doc. Rota, tela irmã, seções em ordem, componentes reusados,
  estados, dados de mock — e siga sem esperar aprovação item a item.
- Construa de ponta a ponta. Decisão pequena é sua; só pare se descobrir que o **resultado**
  pedido era outro.

## 3. Construir — regras de arquivo (contrato)

```
prototype/src/routes/<modulo>/<tela>.tsx   ← 1 arquivo por tela
prototype/src/router.tsx                   ← registre a rota
components/layout/AppHeader                ← ligue o item de menu (navegação real)
components/ui/                             ← componente novo REUTILIZÁVEL
mock/<dominio>.ts                          ← dados de exemplo
```

1. **Arquivo por tela — critério de coexistência**: coisas que nunca aparecem juntas são
   rotas/arquivos diferentes.
2. **Estados via `?state=`** (`useSearchParams`): default/empty/loading/error no mesmo
   arquivo.
3. **Rota registrada + menu ligado** — tela que nenhum menu alcança não existe; sem
   hub/galeria; `/` redireciona pra tela default.
4. **Modal é rota-filha ou estado**, nunca "página de modal".
5. HTML semântico; ícones `lucide-react`; `aria-label` nos blocos (vira nome do node no
   export); largura desktop 1280 via `ExportFrame`.

Precedência de reúso e tokens: `design-system-first.md`. Acessibilidade: checklist AA
antes de entregar.

## 4. Verificar e entregar (PARE aqui por padrão)

`cd prototype && npm run dev` → dê a URL direta da tela + estados, confirme alcançável
pelo menu. **Rode a verificação visual** (`visual-verification.md`): diff contra a
referência com visual; wireframe → estrutura contra o rabisco + visual contra a irmã.
Reporte o que restou divergente.

Entregue junto a lista curta do que **assumiu** (dado, regra, estado, rótulo) — é isso que
substitui as perguntas do início.

**Custo de token:** ao iterar, `Edit` cirúrgico, nunca `Write` (17k vs 0.3k); nunca releia
arquivo que acabou de escrever — verificação é visual, não textual.

## 5. Export pro Figma — opt-in, por tela (write-gate)

Só sob pedido explícito, só as telas escolhidas. Motor: skill `html-to-figma`
(`?export=1`, uma captura por tela/estado, nunca o chrome do app). Reporte a URL de cada
node.

## 6. Registro

`history/YYYY-MM-DD_design_<nome>.md`: rota + estados, referência usada, componentes
reusados/criados, nodes exportados (se houver), decisões de design.
