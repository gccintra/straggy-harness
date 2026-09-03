# Como mudar o harness

O harness documenta demanda com história, regra de negócio e critério de aceite. **Mudança
no próprio harness segue o mesmo fluxo** — a diferença é que aqui o critério de aceite não
para em prosa: ele vira teste executável.

Antes: [`HARNESS.md`](HARNESS.md) (como funciona) · [`WORKFLOWS.md`](WORKFLOWS.md) (o que
existe hoje, ficha por ficha) · [`ARCHITECTURE.md`](ARCHITECTURE.md) (a regra normativa).

## 1. Onde a mudança mora

Primeira pergunta, sempre. Errar a camada aqui é o que apodrece a arquitetura.

| Quero mudar… | Vai em | Camada |
|---|---|---|
| comportamento invariante (write-gate, portão, honestidade, prosa) | `system/CONSTITUTION.md` | L0 |
| como uma profissão pensa, ou um método dela | `system/professions/<profissão>/` | L1 |
| método ou profissão que só a minha empresa tem | `org/professions/` | L1 org |
| convenção transversal da empresa (língua, nomenclatura, papéis) | `org/ORG.md` | L2 org |
| procedimento que serve a **qualquer** empresa | `system/pack/workflows/<nome>/SKILL.md` | L2 pack |
| formato, template ou procedimento **desta** empresa | encaixe em `org/workflows/<nome>/` | L2 org |
| ação que o harness não faz | `org/workflows/<nome>/SKILL.md` com `acao:` nova | L2 org |
| sintaxe ou uso de ferramenta | `system/providers/<domínio>/` ou `org/providers/` | provider |
| como uma persona se apresenta em todos os runtimes | `<workflow>/PERSONA.md` + build | adapter |
| valor do projeto (cliente, URL, credencial) | `project-config.yaml` · `.env` | L3 |

Três testes de desempate:

- **"Outra empresa usaria isto sem editar?"** Sim → `system/pack/`. Não → `org/`.
- **"Isto vale em qualquer empresa?"** Sim → L1 (método). "É como NÓS fazemos?" → L2.
- **Serve a mais de uma skill?** → desce para método ou provider. Nunca copiar.

Duas skills cobrem o harness por dentro, e a fronteira entre elas é escrever ou não:

| Skill | Para | Escreve? |
|---|---|---|
| **`harness-guide`** | "o que ele já faz?", "onde mora isso?", "o que quebra se eu mudar X?" | não — só leitura |
| **`harness-change`** | criar, editar, refatorar qualquer coisa em `.agents/` | sim, com spec e portão antes |

Peça em linguagem natural. A `harness-change` classifica a camada, levanta o impacto,
escreve a spec, propõe antes de tocar em arquivo e propaga as referências.

## 2. O documento de mudança

Uma mudança = um arquivo em [`mudancas/`](mudancas/), nome `HRN-NNN_<slug>.md`, a partir de
[`mudancas/TEMPLATE.md`](mudancas/TEMPLATE.md). Serve para o mesmo que serve num produto:
separar **o que precisa ser verdade** de **como você chegou lá**, e deixar rastro de por que
a coisa é assim seis meses depois.

O documento tem seis partes:

| Parte | O que é | Vira o quê |
|---|---|---|
| **História** | como `<papel>`, quero `<capacidade>`, para `<resultado>` | o porquê, que sobrevive à implementação |
| **Camada** | onde a mudança mora, pela tabela do §1 | a decisão de arquitetura, declarada antes de escrever |
| **Regras de negócio** | invariantes que a mudança não pode quebrar | o que a revisão confere |
| **Impacto** | os cinco raios: quem cita o alvo, quem depende dele na esteira, que eval o cita, o que a organização escreveu ali, a camada está certa | a lista do que muda junto |
| **Critérios de aceite** | um por linha, cada um com a prova que o verifica | eval ou checagem do build |
| **Estado** | proposto · em edição · verde | o que responde "isso já está pronto?" |

Mudança de uma linha (corrigir um caminho, ajustar uma frase de gatilho) não precisa de
documento. O corte é: **mudou comportamento, contrato ou camada?** Então tem documento.

O **impacto** é a parte que responde à pergunta que dói: *o que mais muda junto?* O
procedimento dos cinco raios está em `system/workflows/harness-guide/references/impacto.md`
— e a `harness-guide` responde isso sozinha, antes mesmo de existir spec.

O que o build já pega de graça (esteira sem produtor, eval citando ação inexistente, encaixe
sob provider sem a capacidade, arquivo da organização fora de encaixe) não precisa de
varredura. O que **só** a varredura pega: referência que virou link morto, cópia que passou
a divergir, e conteúdo que a organização escreveu num caminho que você mudou.

## 3. Critério de aceite vira prova

É o ponto que diferencia manutenção de harness de documentação comum. Cada critério de
aceite tem que apontar para uma das duas provas — nunca ficar só na prosa.

**Prova determinística — `./build.sh --strict`.** Cobre estrutura e contrato: ação com
dois donos, encaixe apontando para provider sem a capacidade, esteira sem produtor, workflow
sem `objetivo`/`entrega`/`portoes`, bloco derivado divergindo do frontmatter. É de graça e
roda em segundos.

**Prova de comportamento — `runtime/eval.sh`.** Cobre o que só um runtime executando
responde: a frase certa aciona a ação certa, e a frase do vizinho **não** a aciona. Fonte
neutra em `<workflow>/evals/<caso>/caso.yaml`:

```yaml
tipo: roteamento
frase: "documenta a #142"
atende: documentar-requisito
confunde_com:
  - gerar-documento-final
```

Todo caso positivo pede a contraprova (`<caso>--nao`). Gatilho sem contraprova passa verde
sequestrando o pedido do vizinho, e ninguém descobre.

Formato completo, tipos de caso e os runners disponíveis: `ARCHITECTURE.md` §9.

## 4. Pronto é isto

```bash
cd .agents
./build.sh --strict          # contrato + blocos derivados em dia
./runtime/eval.sh --skill <workflow> # o gatilho dispara onde deve, e só ali
```

Verde nos dois, `WORKFLOWS.md` regenerado (`--fix`) e o `Estado` do documento de mudança
atualizado. Commit é sempre manual, via `@committer`.

Suíte verde não prova sozinha que a prova presta: quebre o gatilho de propósito e confira
que o caso fica vermelho. Prova que nunca falhou não é prova.

## 5. Quando a documentação muda junto

`WORKFLOWS.md` é **gerado** — nunca se edita à mão. Mudou `objetivo`, `entrega`, `portoes`,
`acao`, `produz`, `requer`, `provider` ou `encaixes` de um workflow? Rode `--fix` e o
documento acompanha. Sem `--fix`, o build reprova a divergência, que é como ele impede a
documentação de envelhecer em silêncio.

Escrita à mão só o que descreve mecanismo, e não inventário: `HARNESS.md`, `ARCHITECTURE.md`,
`MODOS.md` e este arquivo.
