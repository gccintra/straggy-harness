# HRN-002 — Manutenção do harness com spec e análise de impacto

| | |
|---|---|
| **Estado** | verde |
| **Camada** | system (máquina do harness) + docs |
| **Arquivos** | `system/workflows/harness-guide/` (novo) · `system/workflows/skill-creator/` → `harness-change/` · `docs/MANUTENCAO.md` · `docs/mudancas/TEMPLATE.md` · `docs/README.md` · `README.md` · 8 × README de scaffold e `org/` |
| **Data** | 2026-09-01 |

## História

Como **quem mantém o harness**, quero **especificar uma mudança com o impacto levantado antes
de editar**, para **que a edição que conserta uma skill não apodreça outras três**.

A HRN-001 entregou o inventário — o que existe e onde mora. Faltavam as duas pontas: quem
responde a pergunta antes da edição, e quem garante que a edição foi pensada. A
`skill-creator` só disparava em "cria" e "edita": pergunta de entendimento não acionava
nada, e o registro da mudança era uma frase solta no processo, sem análise de impacto
nenhuma.

O nome também mentia sobre o escopo — ela edita constituição, providers, profissões e
adapters, não só skill.

## Regras de negócio

- **RN-01.** Ler e escrever são skills diferentes. Pergunta que termina sem edição nunca
  carrega a skill que sabe escrever.
- **RN-02.** Mudança que altera comportamento, contrato ou camada tem spec aprovada antes de
  qualquer arquivo ser tocado. Ajuste que não altera nenhum dos três pode pular, declarando
  o motivo.
- **RN-03.** Toda spec traz os cinco raios de impacto. Raio sem achado se declara vazio;
  omitir não é o mesmo que verificar.
- **RN-04.** Todo critério de aceite aponta uma prova executável — `build.sh --strict`, um
  caso de eval, ou o teste da organização recém-criada. Critério sem prova sai da spec.
- **RN-05.** A análise de impacto mora em um lugar só e as duas skills a referenciam.
  Duplicá-la seria a cópia que a própria arquitetura proíbe.
- **RN-06.** Nenhum portão foi afrouxado. A spec **adiciona** um portão antes da edição.

## Impacto

| Raio | Achados | O que fizemos |
|---|---|---|
| Cita o alvo | 17 referências a `skill-creator` em `README.md`, `docs/ARCHITECTURE.md`, `docs/MODOS.md` (5), `docs/MANUTENCAO.md`, 4 × `org/*/README.md` e 4 × `system/pack/org-scaffold/*/README.md` | todas renomeadas; a 18ª estava em `docs/WORKFLOWS.md`, que é gerado e se regenerou sozinho |
| Esteira | vazio — workflow de máquina não declara `acao`, `produz` nem `requer` | — |
| Evals | vazio — e não por acaso: ver *Limitação* abaixo | — |
| Organização | vazio — `system/workflows/` é não-forkável, a organização não sobrescreve máquina | — |
| Camada | mantém: as duas são máquina do harness (`system/workflows/`), não pack | — |

**Limitação encontrada, não contornada.** Workflow de máquina **não pode ter eval**: o
vocabulário de um caso é `atende: <ação>`, e máquina não declara ação — `_validar_evals()`
pula esses workflows inteiros. Então o gatilho da `harness-guide` e o da `harness-change` não
têm contraprova mecânica hoje. É defeito conhecido do modelo de eval, não desta mudança;
resolvê-lo exige um tipo de caso que enderece workflow em vez de ação, e isso é HRN próprio.

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | As duas skills resolvem e aparecem no build | `build.sh --strict` — 28 workflows, contrato ok |
| CA-02 | Nenhuma referência ao nome antigo sobrou, salvo o registro histórico | `grep -rn skill-creator` fora de `docs/hub/` só acerta este arquivo |
| CA-03 | `docs/WORKFLOWS.md` lista as duas na seção de máquina | bloco gerado, após `--fix` |
| CA-04 | Nenhum link relativo quebrado nos docs | varredura de links — 0 |
| CA-05 | A `harness-guide` não escreve nada | contrato de saída da própria skill: a conversa é o entregável |

## Fora de escopo

- **Eval das duas skills** — bloqueado pela limitação acima, não por decisão.
- **`build.sh --impacto <alvo>`** — o cálculo mecânico do raio foi avaliado e adiado: os
  raios 2, 3 e 4 o `--strict` já denuncia, e os raios 1 e 5 são leitura, não cálculo.
  Vira HRN se a varredura à mão se mostrar cara na prática.
- **Quebrar a `harness-change` em spec e edição separadas** — avaliado; a spec sem edição
  não tem consumidor próprio, e dois gatilhos vizinhos ("spec pra mudar X" × "muda X")
  sequestram um ao outro. Fica como duas fases com portão dentro da mesma skill.

## Registro

`harness-guide` nasceu com as fontes em ordem de custo (ficha derivada antes de `SKILL.md`
bruto) e o contrato de parar no ponto de edição sem atravessá-lo.
`system/workflows/harness-guide/references/impacto.md` traz os cinco raios com os comandos
prontos, e separa explicitamente o que o build já pega do que só a varredura pega — é o que
evita a análise virar ritual.

A `harness-change` ganhou o §5 em duas fases com portão entre elas, e a tabela que amarra
tipo de critério a tipo de prova.

O que a execução mostrou e a proposta não previa: a limitação de eval para workflow de
máquina (acima). Foi encontrada tentando escrever o caso de gatilho das duas skills novas.
