# Schemas — o vocabulário dos encaixes estruturados

Um encaixe `tipo: estrutura` declara `schema: <id>`, e o arquivo `<id>.yaml` desta pasta é o
**vocabulário fechado** daquele encaixe: quais elementos existem e que forma cada um tem. A
organização preenche uma **instância** do schema; nunca o edita.

Modelo e regras: `docs/ARCHITECTURE.md` §7 ("Encaixe estruturado"). Forma da tela e trilhos
de edição no aplicativo: `docs/HUB.md` §3.4.

| Quem | O quê |
|---|---|
| Sistema | o schema (esta pasta) — elemento novo é release |
| Pack | uma instância padrão, em `references/` do workflow |
| Organização | a instância dela, no mesmo caminho, sob `org/workflows/<nome>/` |

**Por que fechado.** Encaixe de texto livre é relido pelo modelo a cada execução; encaixe
estruturado é lido por código — motor de cálculo, validação, pré-visualização de impacto,
construtor de interface. Nada disso funciona sobre vocabulário aberto: expressão livre exige
parser, aceita entrada inválida e não tem como ser desenhada em tela.

**Fronteira.** `estrutura` é para conteúdo que uma máquina precisa **calcular**.
Procedimento, template, formato de documento e vocabulário da empresa continuam texto —
esses o modelo interpreta, e interpretar é onde texto ganha.

| Schema | Encaixe que o usa |
|---|---|
| `funil-priorizacao` | `funil`, da ação `priorizar-backlog` |
