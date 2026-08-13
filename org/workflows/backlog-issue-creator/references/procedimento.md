# Procedimento desta organização — registrar demanda

Encaixe `procedimento` da ação `registrar-demanda`. Substitui o passo a passo padrão do pack.
A moldura — write-gate antes de criar ou atualizar demanda, regime do provider, triagem
MoSCoW na entrada, registrar problema e não solução — continua sendo do sistema.

Template da descrição: `references/templates.md` (Template A — Feature · Template B — Bug).

## Dois fluxos

**Create** (demanda nova) e **Refine** (enriquecer demanda rasa — "refina a #NNN"). Ambos
documentam **só o problema**. Ambíguo → pergunte qual.

## Bindings desta organização

- **Módulo no título**: `[TITULO] - [MODULO]` — módulo não é label. Infira de docs/issues
  existentes ou pergunte.
- **Labels**: tipo (`TIPO::…`), prioridade (`PRIORIDADE::…`) e a label de workflow de
  entrada (ex.: `PARA DESCOBERTA`), aplicada depois de criar. Labels inferidas sempre
  confirmadas com o usuário.
- **Priorização na criação = só MoSCoW**, com justificativa. ICE nunca — Facilidade é
  incalculável antes de solução escolhida (`moscow.md` / `ice.md`).
- **Bug crítico bypassa MoSCoW**: qualquer SIM em — sistema indisponível para um perfil ·
  risco de perda/vazamento de dado · bloqueia fluxo core · afeta >30% dos usuários · sem
  workaround → Template B, bloco PRIORIZACAO vira
  `MoSCoW: MUST / Classificação: CRITICAL — vai direto para a sprint atual.`, mais a label
  de crítico do projeto.
- **Contexto antes de assumir**: docs do repo (ONEPAGE, `docs/`) + busca de demandas
  similares no vocabulário do projeto. Entreviste só o que falta (o quê / quem / impacto /
  evidências / prazo) — 2 perguntas por vez, pare quando der para documentar.
- Demanda que chega escrita como solução → descole o problema antes de preencher: o "Quero"
  é o QUÊ, nunca o COMO; a solução proposta vira nota para o discovery.

## Depois de criar

Aplique a label de workflow de entrada e devolva URL/ID da demanda.
