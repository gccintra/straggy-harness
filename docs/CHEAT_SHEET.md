# Cheat Sheet — Harness de Produto

Referência rápida. Para o funcionamento completo: [`FLUXO.md`](FLUXO.md). Para as regras
invariantes: [`../ENGAGEMENT.md`](../ENGAGEMENT.md).

---

## Qual persona chamar

São **3 personas**. Cada uma executa direto na thread principal, carregando as skills que
precisa — não "passam a bola" entre si sozinhas.

| Intenção | Persona |
|---|---|
| Não sei / qualquer coisa de produto | `@product-manager` |
| Reportar bug, propor melhoria, criar/refinar issue | `@product-manager` |
| Discovery de uma demanda (`#NNN`) | `@product-manager` |
| Gerar `.md` de HU/HT, depois `.docx` | `@product-manager` (HT também via `@tech-lead`) |
| Métricas de sprint / saúde do backlog / priorização (ICE) | `@product-manager` |
| Sprint ops, Meta da Sprint, wiki, changelog | `@product-manager` |
| "Como isso funciona de verdade?", dado real do banco | `@tech-lead` |
| Impacto técnico de uma mudança, HT | `@tech-lead` |
| Criar/ajustar tela, protótipo, design system, export Figma | `@product-designer` |

Fora do escopo da persona aberta → ela responde e aponta pra outra, não troca sozinha.

---

## Mapa rápido: persona → skills

| Persona | Carrega |
|---|---|
| `@product-manager` | `backlog-issue-creator`, `discovery`, `doc-consolidator`, `hu-generator`/`ht-generator`, `backlog-analysis`, `backlog-health`, `backlog-prioritization`, `gitlab-sprint-ops`, `sprint-goal-generator`, `gitlab-wiki`, `changelog-generator` (+ `glab-backlog` sempre que fala com GitLab) |
| `@tech-lead` | `db-query`, `discovery`, `doc-consolidator`, `ht-generator`, `backlog-analysis`, `backlog-health` |
| `@product-designer` | `design-brief` → `design-setup` ou `design-screen` (+ `html-to-figma`/`figma-node-reader` no export opt-in) |
| Manual (`@committer`) | `committer` — nunca automático |

Catálogo completo com 1 linha por skill: [`FLUXO.md` §8](FLUXO.md#8-catálogo-completo-de-skills).

---

## Fluxo de produto (issue → documento)

```
issue GitLab → backlog-issue-creator → discovery (D1→D2) → doc-consolidator (.md, PARA)
                                                              → hu-generator / ht-generator (.docx)
```

- **`.md` é fonte de verdade, `.docx` é transcrição.** "Documenta a #NNN" gera só o `.md` e
  para. `.docx` é passo separado, só sob pedido explícito, só depois de revisão humana.
- **HU** tem persona de usuário final. **HT** não — débito técnico, infra, migração, CI/CD.

### Double Diamond — fases do `discovery`

| Fase | Marcador | Conteúdo |
|---|---|---|
| D1a | `[D1a]` | Exploração do problema — fontes, hipóteses, perguntas abertas |
| D1b | `[D1b]` | Definição — Problem Statement, causa raiz, MoSCoW + Impacto + Confiança |
| D2a | `[D2a]` | Exploração de soluções — 2-4 alternativas, trade-offs |
| D2b | `[D2b]` | Definição da solução — fluxo, campos, RN/CA, Facilidade + ICE final |

Uma fase de cada vez. Skip de fase exige pergunta + aprovação explícita.

### ICE e MoSCoW

`ICE = Impacto × Confiança × Facilidade` (1-10 cada → 1-1000)

| Quadrante | Condição |
|---|---|
| QUICK WIN | Impacto ≥ 7 e Facilidade ≥ 5 |
| PLAN | Impacto ≥ 7 e Facilidade ≤ 4 |
| LATER | Impacto ≤ 6 e Facilidade ≥ 5 |
| DROP | Impacto ≤ 6 e Facilidade ≤ 4 |

MoSCoW: `MUST` (inegociável) · `SHOULD` (importante) · `COULD` (desejável) · `WONT` (fora do escopo agora).

---

## Fluxo de design

```
design-setup (1x/projeto) → design-brief (antes de codar) → design-screen (rota React)
                                                              → prototype-deploy (opt-in)
```

Fonte de verdade do design é o **código** (`tailwind.config.js` + `components/ui/`), não o
Figma. Export pro Figma sempre opt-in.

---

## Regras de engajamento (resumo)

- **Brevidade** — direto ao resultado, sem preâmbulo, sem recapitular o pedido.
- **Write-gate** — antes de escrever em issue/comentário/label/wiki/changelog/entregável/
  arquivo do harness: mostra o que vai fazer, espera aprovação explícita. Vale por passo, não
  acumula.
- **Context-gate** — falta dado que muda o resultado → uma pergunta focada. Leitura segue
  direto; escrita, não.
- **Delegação** — thread principal por padrão; subagente só quando compensa (varredura ampla,
  análise isolável, paralelo) e com aprovação.
- **Ortografia** — todo artefato gerado em PT-BR correto e acentuado. Nunca ASCII chapado.

Detalhe completo: [`ENGAGEMENT.md`](../ENGAGEMENT.md).

---

## Config — onde preencher

| Arquivo | Local | Git? | Contém |
|---|---|---|---|
| `project-config.md` | raiz do projeto | sim | cliente, projeto, URL das issues, caminhos, deploy do protótipo |
| `.env` | raiz do projeto | não | tokens/IDs: GitLab, Drive, Figma, banco |

Campo vazio → skill usa placeholder (`[CLIENTE]`) no documento, nunca inventa valor.
Ferramenta externa ausente (`glab`, `pandoc`, `rclone`, cliente de banco) → a skill avisa e
para, nunca falha em silêncio.

---

## Onde é gravado

| Pasta | Conteúdo | Git? |
|---|---|---|
| `outputs/{ID}_{Nome}/` | `.md` consolidado + `.docx` | só o `.md` |
| `history/` | discoveries, análises, priorizações | sim |
| `docs/context_docs/md/` | Drive convertido (via `./sync-context.sh`) | cache, não |
| `prototype/` | app de protótipo React | sim, menos `dist/` |
