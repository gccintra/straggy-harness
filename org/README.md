# Camada da organização — overlay de um harness de agentes

> ## ⚠️ Este repositório não funciona sozinho
>
> Aqui não há agente, skill executável nem programa. É a **camada L2** de um harness de
> agentes: um conjunto de arquivos que **sobrescreve** o comportamento padrão do harness
> para esta organização. Sem o harness montado por cima, é só texto.

## Como usar

```bash
cd <raiz-do-projeto>
git clone <url-do-harness>  .agents          # o harness (sistema + pack padrão)
git clone <url-deste-repo>  .agents/org      # esta camada, aqui dentro
./.agents/install.sh                         # semeia o que faltar e resolve tudo
```

Depois de qualquer mudança aqui: **`./.agents/runtime/build.sh`** — é ele que mescla pack +
organização e gera a visão que os agentes leem. `--list` mostra a origem resolvida de cada
workflow (`pack`, `org`, `org+pack`, `sistema`).

Sem esse passo, o que você editou aqui não existe para nenhum agente.

## Como a sobrescrita funciona

A resolução é **por arquivo**, não por pasta. Você sobrescreve o menor arquivo que resolve
e herda todo o resto do pack:

| Você quer | Crie |
|---|---|
| Trocar só o formato de um documento | `workflows/<nome>/references/<arquivo>.md` |
| Trocar o procedimento inteiro de um workflow | `workflows/<nome>/SKILL.md` |
| Um workflow que só existe aqui | `workflows/<nome>/SKILL.md` |
| Desligar um workflow do pack | `workflows/<nome>/DISABLED` (arquivo vazio) |
| Método ou profissão própria | `professions/<profissão>/…` |
| Implementação de ferramenta interna | `providers/<domínio>/<nome>.md` |
| Convenção que vale para tudo | `ORG.md` |

Copiar um `SKILL.md` inteiro **congela esta organização na versão antiga do pack** — o
workflow para de receber melhorias. Faça só quando o procedimento em si for outro.

## O que NUNCA mora aqui

- **Segredo** — token, senha, chave. Isto é conteúdo compartilhado e versionado. Credencial
  vive no `.env` do projeto, fora do Git.
- **Valor de projeto** — domínio, host, repositório, caminho, nome de tabela. Isso é `L3`:
  `project-config.yaml` na raiz do projeto.
- **Arquivo de sistema** — constituição, profissões, providers oficiais, workflows do pack.
  São imutáveis e chegam pelo release do harness. Editar aqui não sobrescreve o que é
  não-forkável; sobrescrever o resto por cópia quebra a atualização.

## Como alterar

Peça em linguagem natural ao agente ("cria um workflow de X", "muda o formato do documento
consolidado"): a skill `skill-creator` classifica a camada, propõe antes de escrever e
propaga as referências. Editar na mão sem passar por ela funciona às vezes — e é assim que
a arquitetura apodrece.

Mudança aqui altera o comportamento dos agentes **de toda a organização**. Trate como
código: branch, revisão, merge.

## Referência

Tudo que descreve o harness vive no repositório dele, não neste:

| Assunto | Onde |
|---|---|
| Uso, instalação, configuração | `.agents/README.md` |
| Camadas, precedência, o que pode ser prescrito | `.agents/docs/ARCHITECTURE.md` |
| Modos de operação e fluxos de manipulação | `.agents/docs/MODOS.md` |
| Comportamento invariante dos agentes | `.agents/system/CONSTITUTION.md` |

Anote no `ORG.md` contra qual release do harness esta camada foi revisada pela última vez —
é o que permite descobrir overlay que ficou para trás.
