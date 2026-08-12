# Modos de operação — repositório × aplicativo

Referência normativa: define **quem manipula o quê, por onde, com que portão**, nos dois
modos de entrega do mesmo harness. Camadas e precedência: [`ARCHITECTURE.md`](ARCHITECTURE.md).
Uso e instalação no dia a dia: [`../README.md`](../README.md).

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
│   │   ├── workflows/              override por arquivo + workflows próprios
│   │   ├── professions/            método/profissão próprios
│   │   └── providers/              implementação de ferramenta interna
│   ├── skills →                ⚙ symlink p/ runtime/skills — descoberta de skills
│   ├── runtime/
│   │   ├── adapters/               ▣ fonte dos adapters (base, aliases, render)
│   │   ├── build.sh                ▣ resolvedor
│   │   ├── skills/                 ⚙ GERADO — visão resolvida que os runtimes leem
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

1. **Resolução idêntica.** Máquina vence sempre; a organização sobrescreve o pack **arquivo
   a arquivo**; `DISABLED` desliga um workflow do pack. Igual nos dois modos.
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
| Formato de documento desta empresa | L2 org | `org/workflows/<n>/references/<arq>.md` | revisão | override do menor arquivo | editor do produto |
| Workflow só desta empresa | L2 org | `org/workflows/<n>/SKILL.md` | revisão | `skill-creator` | editor do produto |
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

Hoje o `build.sh` lê `org/` do disco. Para o modo aplicativo existir sem tocar em nenhuma
skill, **"de onde vem a camada da organização" precisa virar um ponto de troca** — hoje
disco, amanhã também o dado do produto. Quem consome esse ponto é o `build.sh`, não uma
skill: é máquina do harness, não provider de agente.

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

### Decisões em aberto

- Como o conteúdo é guardado do lado do produto, e com que granularidade de versão.
- Se a organização pode escolher manter a camada fora do produto (repositório próprio), e
  como o produto exibe uma camada que ele não controla.
- Contrato do materializador: atomicidade, integridade, o que acontece sem rede, o que
  acontece quando o usuário edita o que foi materializado.
- Como rastrear contra qual release do harness uma camada foi validada.
- Se existe saída para Git (auditoria, exportação) e em que direção.
- **Fora de escopo desta costura:** artefatos de trabalho (`outputs/`, `history/`, `data/`)
  têm escrita dos dois lados e são um problema diferente — não resolva junto.

---

## 7. Riscos conhecidos

| Risco | Sintoma | Mitigação |
|---|---|---|
| **Overlay órfão** | organização sobrescreveu `references/x.md`; o pack evoluiu; ninguém percebeu que a empresa congelou | build avisa quando o arquivo do pack sobrescrito mudou desde o override |
| **Duas fontes de verdade** | alguém edita o arquivo materializado no modo aplicativo e o backend lê de volta | arquivo renderizado é efêmero e read-only; toda escrita passa pela UI |
| **Fork do harness inteiro** | cada release vira merge | overlay por arquivo; fork de `SKILL.md` só quando o **procedimento** é outro |
| **Vazamento de camada** | valor de projeto (domínio, repo, tabela) dentro do pack ou do `ORG.md` | teste do pack (`ARCHITECTURE.md` §3); valor vem de `project-config.yaml` |
| **Segredo na camada compartilhada** | token no `ORG.md`, que é multiusuário e versionado | `org/` é prosa; credencial só em `.env`/cofre |
| **Portão colapsado no app** | UI "adianta" etapas para parecer fluida | portão do pipeline vira estado do artefato — não pode ser pulado, só aprovado |
