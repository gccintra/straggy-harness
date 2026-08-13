# Modos de operação — repositório × aplicativo

Referência normativa: define **quem manipula o quê, por onde, com que portão**, nos dois
modos de entrega do mesmo harness. Camadas e precedência: [`ARCHITECTURE.md`](ARCHITECTURE.md).
Uso e instalação no dia a dia: [`../README.md`](../README.md). A **forma das telas** do modo
aplicativo — papéis, fluxos, portão como estado, ordem de construção: [`HUB.md`](HUB.md).

> **Estado.** O **modo repositório existe e é o que roda hoje**. O **modo aplicativo é
> desenho** — nada dele está implementado. Cada seção marca o que vale para cada um; onde
> o modo aplicativo aparece sem marcação de estado, é proposta.

---

## 1. Os dois modos

| | **Modo repositório** (hoje) | **Modo aplicativo** (desenho) |
|---|---|---|
| Quem usa | PM/designer/tech lead com CLI + IDE | mesma pessoa, sem terminal |
| Onde o agente roda | máquina do usuário | infra do produto, sessão por execução |
| Como o harness chega | `git clone` em `<projeto>/.agents` | servido pelo produto, por release |
| O que o usuário enxerga | os arquivos | telas: personas, workflows, camada da organização |
| Camada da organização | pasta local semeada do scaffold, ou repositório próprio montado em `.agents/org` | dado do produto, por organização |
| Portão humano | parada na conversa + revisão da mudança | estado do artefato + trilha de aprovação |
| Segredo | `.env` local | cofre do produto, nunca no conteúdo |

Os dois rodam **as mesmas skills, sem fork**. É isso que a seção 3 protege.

---

## 2. Arquitetura de pastas — classificada por posse

```
<projeto>/
├── .agents/                    o harness
│   ├── system/                 ▣ SISTEMA — imutável pela organização
│   │   ├── CONSTITUTION.md         L0
│   │   ├── professions/            L1 — PROFESSION + reasoning + methods/
│   │   ├── providers/              contrato (INTERFACE.md) + implementações
│   │   ├── pack/                   L2 padrão — workflows/ + org-scaffold/
│   │   └── workflows/              máquina (skill-creator, motores) — não-forkável
│   ├── org/                    ◐ ORGANIZAÇÃO — fora do Git do harness
│   │   ├── ORG.md                  convenções transversais
│   │   ├── workflows/              registros nos encaixes + workflows de ação nova
│   │   ├── professions/            método/profissão próprios
│   │   └── providers/              implementação de ferramenta interna
│   ├── skills →                ⚙ symlink p/ runtime/skills — descoberta de skills
│   ├── runtime/
│   │   ├── adapters/               ▣ fonte dos adapters (base, aliases, render)
│   │   ├── build.sh                ▣ resolvedor
│   │   ├── skills/                 ⚙ GERADO — visão resolvida que os runtimes leem
│   │   ├── manifest.json           ⚙ GERADO — catálogo como dado (ARCHITECTURE §8)
│   │   └── claude|codex|opencode/  ⚙ GERADO — a partir dos PERSONA.md resolvidos
│   └── docs/                   ▣ ARCHITECTURE.md · MODOS.md (este)
├── project-config.yaml         ○ PROJETO — valores da instância (L3), no Git do projeto
├── .env                        ○ PROJETO — segredo e seleção de provider, fora do Git
├── outputs/ history/ data/     ○ PROJETO — artefatos produzidos
└── prototype/                  ○ PROJETO — app de protótipo
```

`▣` sistema · `◐` organização · `⚙` gerado (nunca editado à mão) · `○` projeto

| Pasta | Dono | No Git de quem | Modo repositório | Modo aplicativo |
|---|---|---|---|---|
| `system/` | sistema | repo do harness | clone, read-only | servido por release, read-only |
| `org/` | organização | **fora do repo do harness** | pasta local ou repositório próprio | dado do produto, materializado para execução |
| `runtime/skills` e adapters | ninguém (gerado) | ignorado | `build.sh` | `build.sh` no preparo da sessão |
| `project-config.yaml` | projeto | repo do projeto | arquivo | formulário do projeto |
| `.env` | projeto | fora do Git | arquivo | cofre + integrações conectadas |
| `outputs/`, `history/`, `data/` | projeto | repo do projeto | arquivos | armazenamento do produto |

**Regra de posse:** nenhum arquivo de sistema mora em `org/`, e nenhum conteúdo de
organização mora em `system/`. O teste do pack (`ARCHITECTURE.md` §3) é o que decide.

---

## 3. O contrato de portabilidade — o que NÃO pode variar entre modos

Quebrar qualquer um destes cinco itens obriga a manter duas versões das skills. É o
principal risco arquitetural dos dois modos coexistirem.

1. **Resolução idêntica.** Máquina vence sempre; workflow resolvido = moldura do pack +
   conteúdo da organização nos encaixes declarados (`ARCHITECTURE.md` §7); workflow próprio
   só para ação que o pack não atende; `DISABLED` desliga um workflow do pack. Igual nos
   dois modos. O nome da pasta é endereço físico nos dois, nunca contrato.
2. **Saída é uma visão plana resolvida.** O runtime nunca navega camadas: lê
   `runtime/skills/`, já resolvido.
3. **Skill não sabe de onde veio o conteúdo.** Sem API de runtime, sem caminho de banco,
   sem condicional "se estiver no app". A skill lê arquivo.
4. **L0 e L1 são read-only** em ambos, versionados por release do sistema.
5. **Portão humano não desaparece — muda de forma.** Write-gate vira UI de aprovação com
   preview; parada para revisão vira estado do artefato com trilha de quem aprovou. O
   número de portões nunca diminui.

---

## 4. Fluxos de manipulação — quem muda o quê

| Mudança | Camada | Onde | Portão | Modo repositório | Modo aplicativo |
|---|---|---|---|---|---|
| Comportamento invariante (gate, portão, honestidade) | L0 | `system/CONSTITUTION.md` | — | **ninguém**: muda por release do sistema | idem |
| Como a profissão pensa; método novo universal | L1 | `system/professions/` | — | release do sistema | idem |
| Método/profissão só desta empresa | L1 org | `org/professions/` | revisão | `skill-creator` + revisão | editor do produto + aprovação |
| Convenção da empresa (língua, nomes, papéis, funil) | L2 | `org/ORG.md` | revisão | edição + revisão | formulário + aprovação |
| Workflow que serve a qualquer empresa | L2 pack | `system/pack/workflows/` | — | release do sistema | idem |
| Formato, template, vocabulário, **procedimento** de uma ação existente | L2 org | registro no encaixe `(ação, encaixe)` | revisão | arquivo no encaixe declarado | escreve o texto e escolhe a ação; nunca vê o workflow |
| Ação que o harness **não** faz | L2 org | workflow próprio + ação nova | revisão | `skill-creator` | editor de workflow |
| Portão, contrato de saída, método, L0 | — | área fechada (`ARCHITECTURE.md` §7) | — | **não alcançável** | não exposto |
| Desligar workflow do pack | L2 org | `org/workflows/<n>/DISABLED` | revisão | arquivo vazio | interruptor na UI |
| Implementação de ferramenta interna | provider | `org/providers/<domínio>/` | revisão | sob a mesma `INTERFACE.md` | idem |
| Como a persona se apresenta | persona | `<workflow>/PERSONA.md` + build | revisão (se override) | 1 arquivo, 3 runtimes | 1 registro, N canais |
| Valor do projeto (cliente, URL, caminhos) | L3 | `project-config.yaml` | — | arquivo | formulário do projeto |
| Credencial, token, seleção de provider | L3 | `.env` | — | arquivo local | cofre |

**Toda alteração dentro de `.agents/` passa pela skill `skill-creator`** — ela classifica a
camada, propõe antes de escrever e propaga as referências. No modo aplicativo, o
equivalente é a UI só expor os pontos de extensão da organização; `system/` não é editável
nem por engano.

---

## 5. Ciclo de vida

| Etapa | Modo repositório | Modo aplicativo |
|---|---|---|
| **Entrar** | `git clone <harness> .agents` · montar a camada da organização em `.agents/org` · `./.agents/install.sh` (semeia `org/` do scaffold se vier vazia, cria `project-config.yaml`/`.env`, roda o build) | criar organização → scaffold vira o estado inicial editável; conectar integrações |
| **Usar** | fala em linguagem natural; o runtime escolhe o workflow pela `description` | idem, com contexto de tela somando à intenção |
| **Customizar** | edita `org/` via `skill-creator` → `build.sh` → revisão | edita pelo produto → aprovação antes de valer para todos |
| **Atualizar o harness** | `git -C .agents pull --ff-only && ./.agents/runtime/build.sh`; `org/` intocada (fora do repo) | release do sistema; a camada da organização não é tocada — é de outra posse |
| **Reverter** | histórico do versionamento da camada | versão anterior da camada |
| **Auditar** | histórico do versionamento da camada | trilha de aprovação por artefato |

**Quando rodar o build:** criou, renomeou, sobrescreveu ou desabilitou workflow; mexeu em
`PERSONA.md`. `./.agents/runtime/build.sh --list` imprime a origem resolvida de cada
workflow — é o comando para responder "de onde veio esse comportamento?".

---

## 6. A costura entre os modos — direção, não especificação

> Esta seção dá **direção**. Nada aqui está decidido nem implementado: formato de
> armazenamento, nomes de configuração, contrato do materializador e comportamento de
> falha são projeto a fazer.

**O ponto de troca já existe.** `build.sh --org DIR` (ou `HARNESS_ORG_DIR`) decide de onde
vem a camada da organização, e `--out DIR` decide para onde vai a visão resolvida — no
produto o `system/` chega read-only por release, então a saída não pode cair dentro dele
(`ARCHITECTURE.md` §8). Quem consome esses pontos é o `build.sh`, não uma skill: é máquina
do harness, não provider de agente.

O que falta é do outro lado da troca: **quem materializa** um `org/` a partir do dado do
produto. Daí para frente o pipeline é idêntico nos dois modos.

### O que a direção assume

- **No app, a fonte é o dado do produto.** O arquivo em disco existe só porque é o formato
  que o agente lê — é resultado de uma materialização, não a verdade.
- **Uma via.** O que for materializado em disco não volta para a fonte. Caminho de escrita
  é um só, sempre pelo produto.
- **Uma fonte autoritativa por organização.** Suportar as duas com escrita ao mesmo tempo
  cria merge de prosa sem resolução possível.
- **A resolução não muda** (seção 3): o materializador entrega um `org/` pronto, e daí para
  frente o pipeline é idêntico nos dois modos.
- **O core não é materializado.** `system/` chega por release; Git é como o harness é
  desenvolvido e versionado, não como o app o consome.
- **A visão resolvida é materializada no sandbox de execução, nunca no que a organização
  enxerga ou baixa.** `runtime/skills/` resolvido contém o pack inteiro em texto — se
  chegar à organização, a superfície pública da §7 do `ARCHITECTURE.md` vira decoração.
  Requisito de propriedade intelectual, não de arrumação. No modo repositório essa
  fronteira não existe por construção: o `system/` está no disco de quem usa.

### Decisões em aberto

- Como o conteúdo é guardado do lado do produto, e com que granularidade de versão.
- Se a organização pode escolher manter a camada fora do produto (repositório próprio), e
  como o produto exibe uma camada que ele não controla.
- Contrato do materializador: atomicidade, integridade, o que acontece sem rede, o que
  acontece quando o usuário edita o que foi materializado.
- Como rastrear contra qual release do harness uma camada foi validada.
- Quem mantém a taxonomia de **ações** e **encaixes** (`ARCHITECTURE.md` §7), e o que
  acontece com as organizações quando uma ação é renomeada ou aposentada.
- Até onde o encaixe `procedimento` pode ir sem virar substituição disfarçada — e como o
  produto sinaliza que um procedimento escrito pela organização conflita com a moldura.
- Se existe saída para Git (auditoria, exportação) e em que direção.
- **Fora de escopo desta costura:** artefatos de trabalho (`outputs/`, `history/`, `data/`)
  têm escrita dos dois lados e são um problema diferente — não resolva junto.

---

## 7. Riscos conhecidos

| Risco | Sintoma | Mitigação |
|---|---|---|
| **Overlay órfão** | organização preencheu um encaixe; o pack evoluiu; ninguém percebeu que a empresa congelou | só o conteúdo do encaixe congela — moldura, portões e contrato de saída acompanham o pack por construção |
| **Qualidade terceirizada** | organização configura mal e a resposta piora sem rede | portão, contrato de saída e método ficam fora de qualquer encaixe (`ARCHITECTURE.md` §7); o pior encaixe possível ainda para no portão humano |
| **Core exposto** | organização deduz a estrutura interna do pack pela interface (nomes de workflow, divisão, procedimento) | superfície pública é **ação + encaixe** (`ARCHITECTURE.md` §7); resolvido materializado só no sandbox de execução |
| **Duas fontes de verdade** | alguém edita o arquivo materializado no modo aplicativo e o backend lê de volta | arquivo renderizado é efêmero e read-only; toda escrita passa pela UI |
| **Fork do harness inteiro** | cada release vira merge | não existe substituir workflow do pack: customização é encaixe, e workflow próprio só para ação nova |
| **Vazamento de camada** | valor de projeto (domínio, repo, tabela) dentro do pack ou do `ORG.md` | teste do pack (`ARCHITECTURE.md` §3); valor vem de `project-config.yaml` |
| **Segredo na camada compartilhada** | token no `ORG.md`, que é multiusuário e versionado | `org/` é prosa; credencial só em `.env`/cofre |
| **Portão colapsado no app** | UI "adianta" etapas para parecer fluida | portão do pipeline vira estado do artefato — não pode ser pulado, só aprovado |
