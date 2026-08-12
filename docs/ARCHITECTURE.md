# Arquitetura do harness

Referência normativa: decide **onde cada coisa mora** e **o que pode ser escrito** em cada
camada. Consultada pela skill `skill-creator` antes de qualquer alteração no harness. Uso
no dia a dia e instalação: `../README.md`. Quem manipula o quê em cada modo de entrega
(repositório × aplicativo), e o contrato de portabilidade entre eles: [`MODOS.md`](MODOS.md).

---

## 1. Camadas

| Camada | O que é | Onde | Quem edita |
|---|---|---|---|
| **L0** Constituição | restrição de comportamento invariante (gate, portão, honestidade, delegação) | `system/CONSTITUTION.md` | ninguém (sistema) |
| **L1** Profissão | como a profissão pensa: seleção de método, barra de qualidade, contrato de output | `system/professions/<profissão>/` | sistema (+ overlay em `org/professions/`) |
| **L2** Workflow | procedimento: gatilho, binding, portão, formato de entrega | `system/pack/workflows/` (padrão) + `org/workflows/` (organização) | organização |
| **Provider** | contrato de ferramenta + implementação | `system/providers/<domínio>/` (+ `org/providers/`) | sistema (+ implementação da organização) |
| **Adapter** | como um runtime monta tudo | `runtime/<runtime>/` | sistema |
| **L3** Instância | valores deste projeto | `project-config.yaml` + `.env` | projeto |

**Precedência:** em conflito, a camada de baixo vence. **L0 vence tudo** — inclusive
instrução de workflow editado pela organização. É isso que torna seguro deixar a L2
editável: customiza-se o *procedimento*, nunca o *comportamento*.

**Regra anti-erosão:** camada de cima **referencia** a de baixo, nunca copia. Mesma
explicação em dois arquivos = um deles está na camada errada.

**Método é default, não camisa de força:** o agente pode desviar do método (L1) ou do
caminho do workflow (L2) declarando o desvio e o porquê, desde que cumpra o contrato de
saída e não pule portão. Contrato e portão são invioláveis; método, não.

---

## 2. Teste de linha — o que pode ser prescrito

Modelo generalista escolhe sozinho a melhor forma de resolver. **Dizer "como pensar"
degrada o resultado** — e degrada mais a cada geração de modelo. Três tipos de instrução:

| Tipo | O que é | Veredito |
|---|---|---|
| **Contrato** | o que o resultado deve conter/formato/destino | **prescrever** — é requisito da empresa, o modelo não adivinha |
| **Restrição** | limite para controle humano (write-gate, um artefato por turno, parar para revisão) | **prescrever** — existe para o usuário manter controle |
| **Script cognitivo** | como raciocinar, em que ordem analisar | **cortar** |

Teste por linha: *"se o modelo ignorar isto e ainda entregar resultado que cumpre contrato
e portões, houve dano?"* Não → script, corte. Sim → contrato ou restrição, fica.

Cuidado com a **restrição disfarçada de script**: "uma fase por vez" existe para a cadência
de aprovação do usuário — é restrição, fica. A ordem interna dos sub-passos dentro da fase é
script — sai.

**Gradiente por camada:** L0 restrição pura · L1 seleção + barra + contrato (zero passo a
passo) · L2 spec de entregável + portões · **providers e motores: procedural à vontade** —
sintaxe de ferramenta é fato, não raciocínio.

Consequência: conteúdo declarativo continua valioso conforme os modelos melhoram; conteúdo
procedural vira teto. Escrever declarativo é o que faz o harness melhorar de graça a cada
upgrade de modelo.

---

## 3. Física: posse, pack e overlay

A divisão física é por **POSSE**, espelhando a fronteira sistema × cliente do produto:

```
system/          imutável pela organização (no produto: shipped read-only)
├── CONSTITUTION.md          L0
├── professions/             L1
├── providers/               contrato + implementações oficiais
├── pack/                    L2 PADRÃO — workflows genéricos + org-scaffold/
└── workflows/               máquina do harness (não-forkável)
org/             POSSE da organização — FORA do Git do harness, semeada pelo install.sh
├── ORG.md · workflows/ · professions/ · providers/
runtime/skills/  GERADO — a visão resolvida que os runtimes leem
runtime/claude|codex|opencode/  GERADO — adapters, a partir dos PERSONA.md resolvidos
```

O **pack padrão** é o que faz o harness funcionar sem nenhuma customização. A organização
não parte do zero: ela sobrepõe.

**`org/` nunca é versionada pelo harness.** O que o harness ships é o **scaffold**
(`system/pack/org-scaffold/`), copiado para `org/` pelo `install.sh` — arquivo a arquivo,
nunca sobrescrevendo o que já existe. Consequência: quem clona o harness recebe a camada
padrão, nunca a convenção de outra empresa; e cada organização versiona a própria camada
onde quiser. Overlay pré-existente é preservado na atualização do harness.

**Resolução por nome de workflow:**

1. `system/workflows/<nome>` existe → vence sempre (máquina não é forkável; override é
   ignorado com aviso).
2. Pack **e** org têm o nome → **overlay por arquivo**: cada arquivo da org substitui o
   homônimo do pack; o que a org não tocou vem do pack.
3. Só um dos dois → usa o que existe.
4. `org/workflows/<nome>/DISABLED` → workflow do pack desligado nesta organização.

**Build.** A visão mesclada é gerada, nunca mantida à mão: `runtime/build.sh` produz
`runtime/skills/`, fora do Git — é o que todos os runtimes leem (`--list` imprime a origem
de cada workflow). Assim `org/` significa exatamente "propriedade da organização": nenhum
arquivo de sistema mora lá dentro.

**Fork barato.** Trocar o formato de um documento não copia a skill inteira: a organização
sobrescreve `references/<arquivo>.md` e herda o resto. Fork de SKILL.md inteiro congela a
organização na versão antiga do pack — só se o procedimento em si for outro.

**Teste do pack:** *"outra empresa usaria isto sem editar?"* Sim → `system/pack/`. Não →
`org/`. Três vazamentos que reprovam no teste e são fáceis de deixar passar: **vocabulário
de documento** da organização (siglas de tipo de HU/HT, nome de catálogo), **taxonomia
literal** (nome de label, título de página) e **valor de instância** (domínio, host, repo,
tabela). Nos três, o pack descreve o papel e lê o valor de `project-config.yaml`,
`org/ORG.md` ou do provider — nunca o decora.

**Pontos de extensão da organização:** `org/professions/` (profissão ou método próprio) e
`org/providers/` (implementação de ferramenta interna, sob a mesma INTERFACE). Overlay
adiciona e substitui procedimento/método; nunca reescreve L0 nem afrouxa portão.

---

## 4. Providers — abstração de ferramenta

Cada domínio (`backlog`, `canvas`, `knowledge`, `database`, `docs-output`) tem uma
`INTERFACE.md` com operações abstratas e N implementações.

1. **Workflow só usa operações da interface.** Nunca cita comando, endpoint ou variável de
   fornecedor. Nome de workflow também não carrega fornecedor (`wiki-publish`, não
   `gitlab-wiki`) — trocar de ferramenta não pode renomear skill.
2. **Implementação carrega a sintaxe concreta** — procedural, com receitas em `recipes/`
   quando forem longas.
3. **Gate e modo degradado moram na INTERFACE, uma vez.** O workflow só declara o regime
   ("com" ou "sem" fallback local); o texto não se repete.
4. **Seleção e capacidades são declaradas.** A instância diz qual provider está ativo
   (ex.: `BACKLOG_PROVIDER`); cada implementação declara as capacidades que suporta; o
   workflow declara a que exige. Capacidade ausente = indisponibilidade explícita, nunca
   erro de comando nem contorno silencioso.
5. **Contrato é do sistema, implementação é plugável** (`org/providers/`). Ferramenta
   interna nunca deve exigir fork do core.

Toda operação de escrita da interface é mutação → write-gate (L0) antes de executar.

---

## 5. Montagem por runtime

```
montagem = L0 (sempre, primeiro, imutável)
         + PROFESSION.md + reasoning.md da profissão ativa      (L1 + overlay org)
         + methods/ carregados SOB DEMANDA                      (L1 + overlay org)
         + workflows resolvidos, carregados por gatilho         (L2: pack ∪ org)
         + providers ativos conforme a configuração             (L3 decide quais)
         + project-config + contexto do projeto                 (L3)
```

| Runtime | Como monta |
|---|---|
| **Claude Code** | L0 + persona via `runtime/claude/agents\|commands`; workflows descobertos em `runtime/skills/` |
| **Codex** | idem via `runtime/codex/agents/*.toml`, apontando para `runtime/skills/` |
| **OpenCode** | idem via `runtime/opencode/opencode.json` |
| **Produto (Hub)** | L0+L1 no system prompt (usuário não vê nem edita); pack servido como base e overlay da organização editável na UI; providers = integrações conectadas; L3 = formulário do projeto |

**Adapter é gerado, nunca mantido à mão.** A fonte única de uma persona é
`<workflow>/PERSONA.md` (modo, resumo, ferramentas, corpo agnóstico de runtime) mais a
`description` do `SKILL.md` do mesmo workflow — que continua sendo o único lugar do
gatilho de roteamento. `runtime/build.sh` renderiza os três runtimes a partir disso
(contrato do `PERSONA.md`: `runtime/adapters/README.md`). Persona nova = um arquivo, não
três; e o `PERSONA.md` é sobrescrevível pela organização como qualquer outro arquivo do
overlay.

Princípios de portabilidade: **física única** (cada arquivo num lugar só, runtimes
referenciam) · **carregamento progressivo** (L0 e profissão são pequenos e sempre
presentes; método e workflow entram por gatilho) · **nada de API de runtime dentro de
skill, método ou provider**.

No produto, o que hoje é texto vira mecanismo: write-gate → UI de aprovação com preview;
portão do pipeline → estado do artefato com trilha de quem aprovou; roteamento → contexto
de tela + intenção. L0 e L1 permanecem read-only, versionados por release.

---

## 6. Anti-padrões (o que faz a arquitetura apodrecer)

- **L1 virar enciclopédia.** Se o modelo já sabe a teoria, não escreva. Método carrega
  seleção, barra de qualidade e contrato — nada mais.
- **Sobre-prescrição.** Script cognitivo degrada hoje e vira teto amanhã (§2). Na dúvida,
  confie no modelo e endureça o contrato de saída.
- **L2 reabsorver método.** Sinal: workflow passando de ~100 linhas ou repetindo conteúdo
  de `methods/`.
- **Interface anêmica ou vazando.** Se a interface só espelha os comandos de uma
  ferramenta, não abstraiu; se o workflow cita endpoint, vazou. Teste: *"este workflow
  funciona igual com outra ferramenta?"*
- **Roteamento mantido à mão.** Tabela de gatilhos dentro da persona quebra a cada skill
  instalada. Gatilho mora na `description` da skill; a persona guarda escopo, fronteira
  entre profissões e desempates.
- **Pack virar depósito da empresa.** Workflow que só faz sentido com o formato de um
  cliente é overlay, não pack.
- **Override maior que o necessário.** Sobrescreva o menor arquivo que resolve.
