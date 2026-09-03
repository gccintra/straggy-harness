# org/workflows — camada L2 da organização

A organização customiza o harness por **ação**, não por nome de arquivo do pack. Catálogo
público de ações e encaixes: `system/ACOES.md`. Modelo: `docs/ARCHITECTURE.md` §7.

Um workflow resolvido é **a moldura do pack mais o conteúdo desta pasta nos encaixes
declarados**. A organização não substitui workflow do pack — preenche encaixes.

Duas coisas moram aqui:

1. **Registro num encaixe — é assim que se customiza.** A ação declara os encaixes que
   aceitam conteúdo da organização: formato de documento, template, vocabulário e o
   **procedimento**. Escreva o arquivo no caminho do encaixe, dentro de `<nome-do-pack>/`.
   Ação, métodos, portões humanos e contrato de saída continuam vindo do pack — não são
   alcançáveis daqui, e é isso que garante o piso de qualidade.
2. **Workflow de ação nova.** `<nome>/SKILL.md` com uma `acao:` que o pack não atende. Livre:
   não há padrão para degradar. Entra junto no catálogo `system/ACOES.md`.

`<nome>/DISABLED` (arquivo vazio) desliga um workflow do pack nesta organização.

Encaixe vazio → vale o padrão do pack. Arquivo fora de encaixe declarado, ou `SKILL.md` para
ação que o pack já atende → **o build avisa**: é erro de configuração, não customização.

Criou, renomeou ou preencheu → **rode `./.agents/build.sh`** (`--list` mostra origem
e ação de cada workflow resolvido).

Contrato e anti-padrões: `docs/ARCHITECTURE.md` §1–§3 e §7. Criar pela skill `harness-change`.
