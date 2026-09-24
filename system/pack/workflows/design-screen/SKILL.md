---
name: design-screen
description: >
  Cria ou ajusta telas como rotas no protótipo (prototype/) a partir de demanda,
  requisito ou descrição. Use para "cria a tela", "ajusta a tela", protótipo,
  componente, fluxo. Analisar antes de construir é design-brief.
acao:
  id: construir-tela
  rotulo: Construir tela
  descricao: cria e ajusta telas no app de protótipo
objetivo: Construir a tela da demanda como rota real do protótipo, transcrevendo a referência em vez de re-autorar.
entrega:
  - "rota em `prototype/src/routes/`, registrada no roteador e alcançável pelo menu real, com estados na query declarados ao painel de cenários"
  - "`{caminhos.pasta_por_demanda}{ID}_design.md` atualizado com o que a tela faz de fato"
  - "registro em `{caminhos.historico}YYYY-MM-DD_design_<nome>.md`"
portoes:
  - PARA após a verificação visual — entrega a URL, os estados e a lista do que assumiu
  - "registrar o protótipo no `{ID}_design.md` é write-gate"
  - export pro Figma é opt-in, tela a tela
produz:
  id: prototipo-validado
  rotulo: Protótipo validado
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo: Como fazer
    ajuda: Como sua empresa constrói uma tela — o que reusar antes de criar componente novo e como a tela é revisada.
    tipo: texto-longo
---

# design-screen — workflow L2

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` §3 (caminho é seu; suposição declarada) + autonomia local da profissão |
| Métodos | `system/professions/product-designer/methods/` — **`reference-authority.md`** (quem manda no visual; valor design vs medido; imagem se mede, wireframe nunca) · **`design-system-first.md`** (inventário + precedência de reúso) · **`visual-verification.md`** (diff obrigatório antes de entregar) · **`accessibility.md`** (checklist AA antes de entregar) |
| Providers | `canvas/` (ler node Figma, conversão pro padrão do app; node que estoura → subagente `figma-node-reader`) · `backlog/` — **com fallback local** (contexto de issue) · `knowledge/` (contexto do produto: regra de negócio, requisito de referência, glossário — de onde saem rótulo, campo, estado e regra exibidos na tela). Leia a `INTERFACE.md` do domínio antes de qualquer operação. |

Pré-requisito: `prototype/` existe e `prototype/src/lib/scenarios.tsx` é cópia exata de
`design-setup/assets/scenarios.tsx` (`cmp`) — ausente ou divergente → `design-setup` recopia
antes de qualquer tela (protótipo anterior ao painel, ou asset que evoluiu). Tela nova **sem** referência
externa não trava o trabalho: derive de tela irmã, design system e doc da demanda, construa
e declare o que assumiu.
**Transcrever, não re-autorar**: todo elemento da referência aparece, mesma ordem, nada
omitido nem "melhorado"; visual conforme a autoridade da referência.
**Rótulo, campo, regra e mensagem exibidos saem de fonte lida** — doc da demanda ou base de
conhecimento do produto. Sem fonte, entram na lista de suposições declaradas, nunca como fato.


**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.

## 1. Construir — regras de arquivo (contrato)

```
prototype/src/routes/<modulo>/<tela>.tsx   ← 1 arquivo por tela
prototype/src/router.tsx                   ← registre a rota
components/layout/AppHeader                ← ligue o item de menu (navegação real)
components/ui/                             ← componente novo REUTILIZÁVEL
mock/<dominio>.ts                          ← dados de exemplo
```

1. **Arquivo por tela — critério de coexistência**: coisas que nunca aparecem juntas são
   rotas/arquivos diferentes.
2. **Estados via query** (`?state=` e afins): default/empty/loading/error no mesmo
   arquivo, **declarados ao painel de cenários** (`useScenarios`) com rótulo legível —
   estado que só existe na URL não é apresentável.
3. **Rota registrada + menu ligado** — tela que nenhum menu alcança não existe; sem
   hub/galeria; `/` redireciona pra tela default.
4. **Modal é rota-filha ou estado**, nunca "página de modal".
5. HTML semântico; ícones `lucide-react`; `aria-label` nos blocos (vira nome do node no
   export); largura desktop 1280 via `ExportFrame`.

Precedência de reúso e tokens: `design-system-first.md`. Acessibilidade: checklist AA
antes de entregar.

## 2. Verificar e entregar (PARE aqui por padrão)

`cd prototype && npm run dev` → dê a URL direta da tela + estados, confirme alcançável
pelo menu e diga que os cenários abrem com a tecla `P`. **Rode a verificação visual** (`visual-verification.md`): diff contra a
referência com visual; wireframe → estrutura contra o rabisco + visual contra a irmã.
Reporte o que restou divergente.

Entregue junto a lista curta do que **assumiu** (dado, regra, estado, rótulo) — é isso que
substitui as perguntas do início.

**Demanda com ID que vai virar documentação — registre o protótipo (write-gate).** Depois
do aceite visual, atualize `{caminhos.pasta_por_demanda}{ID}_design.md` com o que o protótipo
**faz de fato**, no nível de comportamento (nunca pixel): rotas e estados · comportamento
por ação · rótulos e mensagens **literais** · campos e dados exibidos · o que divergiu da
solução definida no discovery e por quê · pendências de produto. É a entrada do
`doc-consolidator` — sem ele, alguém vai reconstruir isso lendo JSX. Ajuste solto, sem ID,
não gera registro.

**Custo de token:** ao iterar, `Edit` cirúrgico, nunca `Write` (17k vs 0.3k); nunca releia
arquivo que acabou de escrever — verificação é visual, não textual.

## 3. Export pro Figma — opt-in, por tela (write-gate)

Só sob pedido explícito, só as telas escolhidas. Motor: skill `html-to-figma`
(`?export=1`, uma captura por tela/estado, nunca o chrome do app). Reporte a URL de cada
node.

## 4. Registro

`{caminhos.historico}YYYY-MM-DD_design_<nome>.md`: rota + estados, referência usada, componentes
reusados/criados, nodes exportados (se houver), decisões de design.
