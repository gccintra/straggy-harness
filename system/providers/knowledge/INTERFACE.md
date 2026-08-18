# Provider: knowledge — interface

Base de conhecimento do produto: regras de negócio, requisitos de referência, glossário,
visão, decisões — o que a organização mantiver. Workflows pedem "o contexto do produto"; a
implementação resolve de onde vem e o que existe.

Implementações: **`drive-rclone.md`** (Google Drive sincronizado para o disco). Futura:
base nativa do Hub.

**Raiz do conhecimento**: `caminhos.contexto` no `project-config.yaml` (padrão
`docs/context_docs/md/`). Workflow não monta caminho à mão: pede o conteúdo por assunto
("as regras do módulo X", "requisitos parecidos com este").

## Operações

| Operação | L/E |
|---|---|
| listar o que existe na base (descobrir a estrutura antes de assumir) | L |
| ler documento de contexto por assunto (regra, requisito de referência, visão, glossário, decisão) | L |
| buscar por termo dentro da base | L |

**Esta interface é somente leitura** quando a base é um cache derivado (ex.: Drive
sincronizado): escrever nele perde no próximo sync. Conteúdo novo destinado à fonte sai
como apêndice no documento gerado; quem leva à fonte é o usuário.

## Como o conteúdo é encontrado

**Toda a base vive sob `caminhos.contexto`** (`project-config.yaml`). Não existe estrutura
garantida: pastas, nomes e vocabulário são convenção da organização e do projeto, e mudam.

- **Duas origens, mesma base**: a base sincronizada (`caminhos.contexto`) e os **documentos
  consolidados já produzidos e ainda não sincronizados** (`caminhos.pasta_por_demanda`).
  Buscar conteúdo por assunto varre as duas — documento entregue é conteúdo de produto desde
  que existe, não a partir do sync. Ao citar um não sincronizado, diga que ele ainda não está
  na base. Divergência entre as duas origens se **declara**, não se resolve em silêncio.
- **Descubra antes de assumir**: liste a raiz, veja o que existe, busque por termo. Nunca
  monte caminho fixo nem conclua que algo não existe sem ter varrido.
- Conteúdo ausente = **contexto vazio, não erro**. Trabalhe com o que existe e declare o
  que faltou (`system/CONSTITUTION.md` §4).
- Documento que a organização trata como fonte de verdade (regra de negócio, catálogo
  próprio, funil de priorização) é declarado em `org/ORG.md` — não aqui.
- **Proibido** derivar **formato, catálogo ou vocabulário** de um documento de
  `{caminhos.entregaveis}` — exemplo não é fonte de verdade de forma. O **conteúdo** dele
  (regra, requisito) vale como contexto, conforme acima.
