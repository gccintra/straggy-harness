# org/workflows — camada L2 da organização

Duas coisas moram aqui:

1. **Override de workflow do pack** — `<nome-do-pack>/<arquivo>`. A resolução é **por
   arquivo**: sobrescreva o menor arquivo que resolve (quase sempre
   `references/<formato>.md`) e herde o resto do pack. Copiar o `SKILL.md` inteiro congela
   a organização na versão antiga do pack — só faça quando o **procedimento** for outro.
2. **Workflow que só existe nesta organização** — `<nome>/SKILL.md`, mesmo contrato de
   qualquer skill do pack.

`<nome>/DISABLED` (arquivo vazio) desliga um workflow do pack nesta organização.

Criou, renomeou, sobrescreveu ou desabilitou → **rode `./.agents/runtime/build.sh`**
(`--list` mostra a origem de cada workflow resolvido).

Contrato e anti-padrões: `docs/ARCHITECTURE.md` §1–§3. Criar pela skill `skill-creator`.
