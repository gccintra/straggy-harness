# org/providers — implementação de ferramenta interna

`<domínio>/<nome>.md`, sob a `INTERFACE.md` do mesmo domínio em `system/providers/`.
Declare no topo: quando está ativa (valor da variável de seleção), **capacidades**
suportadas, variáveis do `.env` que consome. Corpo procedural à vontade — comando é fato.

Contrato (`docs/ARCHITECTURE.md` §4): workflow nunca cita esta implementação, só operações
da interface; capacidade não suportada = indisponibilidade explícita.

Nasce vazio. Criar pela skill `harness-change`.
