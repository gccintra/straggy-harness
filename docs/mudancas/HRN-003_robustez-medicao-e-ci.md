# HRN-003 — Robustez: medir a assertividade, e não deixar mudança degradá-la

| | |
|---|---|
| **Estado** | proposto |
| **Camada** | motor (`runtime/adapters/`, `runtime/*.sh`) + fontes de eval (L2 pack e org) + infra de CI |
| **Arquivos** | `runtime/adapters/harness.py` · `report.py` · `runtime/eval.sh` · `runtime/tests/` (novo) · `.github/workflows/` (novo) · `<workflow>/evals/` (todos) · `system/workflows/harness-change/` |
| **Data** | 2026-09-01 |

## História

Como **quem opera e mantém o harness**, quero **que toda mudança seja medida por um número
que eu confie, antes e depois**, para **que evoluir o harness não degrade em silêncio a
qualidade das respostas que ele dá**.

O harness já tem o aparato: `eval.sh` despacha para quatro runners, `report.py` calcula taxa
e cobertura, as fontes de caso são neutras por runtime, e `build.sh --strict` reprova o
contrato de graça. **O aparato nunca produziu um número.**

```
runtime/evals/   4 corridas · 1 caso cada · nenhum resultado.json · nenhum report.html
```

Sem baseline, "a mudança piorou o roteamento?" não tem resposta — só opinião de quem
mexeu. E é exatamente a pergunta que precisa ter resposta antes de cada merge, porque o
modo de falha do harness não é quebrar: é **passar no build e responder pior**.

Três lacunas sustentam isso, e são o escopo desta HRN:

1. **Nada roda sozinho.** Não há CI. A camada determinística custa segundos e depende de
   alguém lembrar.
2. **O motor não tem rede.** `harness.py` (910 linhas), `render.py` (354) e `build.sh`
   validam todo o resto, e nada os valida. O parser YAML caseiro é ponto único de falha —
   e coage tipo em silêncio:

   ```yaml
   portoes:
     - Branch: obrigatória no plano    # vira {'Branch': '...'}, não string. Sem erro.
   ```

3. **A suíte mede raso.** 22 casos positivos para 21 ações: **20 ações têm exatamente uma
   frase**. Uma frase por ação prova que aquela frase funciona, não que o gatilho é robusto.

## Regras de negócio

**Medição**

- **RN-01.** Nenhuma mudança de comportamento entra sem baseline anterior e medida
  posterior. Regressão de assertividade **reprova a mudança, mesmo com o build verde**.
- **RN-02.** Falso negativo (a ação não disparou) e falso positivo (a ação sequestrou o
  pedido do vizinho) são métricas **separadas**. Nunca somadas numa taxa só — o segundo é o
  caro, porque produz trabalho errado com confiança.
- **RN-03.** Roteamento é não-determinístico. Toda medida é de **N corridas**, e o número
  reportado é o **pior**, nunca a média. Gatilho que oscila entre 100% e 60% é gatilho
  quebrado que às vezes acerta.
- **RN-04.** Suíte que não morre sob mutação não conta como prova. Trocar a frase de um caso
  pela do vizinho tem que deixá-lo vermelho.
- **RN-05.** Caso `NÃO-RODADO` por capacidade ausente nunca entra na taxa como passado, e
  nunca some do relatório.

**Motor**

- **RN-06.** Dado ambíguo no frontmatter **reprova**. Nunca é coagido em silêncio para um
  tipo que o campo não espera.
- **RN-07.** O motor tem teste próprio, executável sem modelo e sem rede.

**Processo**

- **RN-08.** CI roda a camada determinística em **todo push**, e a de comportamento **antes
  de todo merge**.
- **RN-09.** Cada ação tem no mínimo **3 frases positivas distintas** — formal, coloquial e
  abreviada — e **contraprova dedicada**, não só o subproduto do gatilho do vizinho.
- **RN-10.** Nenhum portão existente é afrouxado. O CI **adiciona** reprovação; nunca
  remove.

## Impacto

Os cinco raios de `system/workflows/harness-guide/references/impacto.md`.

| Raio | Achados | O que fazer |
|---|---|---|
| **Cita o alvo** | `eval.sh` citado em 12 arquivos vivos — `system/providers/eval-runner/INTERFACE.md` e `criterios/modo-degradado.md`, `harness-change/SKILL.md`, `docs/{ARCHITECTURE,MANUTENCAO,HARNESS,WORKFLOWS}.md`, `README.md`, os 3 adapters. `harness.py` em 2 vivos. `report.py` em nenhum fora do próprio motor | flags novas são **aditivas**: nenhum comando documentado muda de significado. O `INTERFACE.md` do `eval-runner` acompanha se a saída ganhar campo |
| **Esteira** | vazio — mudança de motor não declara `acao`, `produz` nem `requer` | — |
| **Evals** | **todas as 31 fontes são tocadas** pelo aprofundamento (Onda 3). Nenhuma ação é renomeada, então nenhum `atende`/`confunde_com` existente quebra | caso novo é aditivo; o build reprova fonte citando ação inexistente |
| **Organização** | 2 fontes de eval em `org/` (`doc-consolidator`, `hu-narrative-generator`) e **8 workflows com encaixe preenchido** — `doc-final-generator` 5/5, `doc-consolidator` 3/3, mais 6 com 1–2 | o aprofundamento acrescenta caso do **pack**; encaixe da organização não muda de caminho. **Teto de `description` (Onda 4) não pode encolher gatilho de ação que a organização reivindicou** sem medir antes e depois |
| **Camada** | correta: motor em `runtime/adapters/`, fontes de eval na camada do workflow, CI é infra de repositório — nenhuma regra de comportamento desce para o pack | — |

**Risco declarado.** A Onda 3 mexe em 31 fontes de uma vez. Sem o baseline da Onda 1
congelado antes, não há como distinguir "o gatilho melhorou" de "a suíte ficou mais fácil".
**A Onda 1 é pré-requisito duro das demais**, não preferência de ordem.

## Critérios de aceite

### Onda 1 — baseline e rede (medir antes de mexer)

| # | Critério | Prova |
|---|---|---|
| CA-01 | A suíte completa roda de ponta a ponta e grava `resultado.json` + `report.html` | `./runtime/eval.sh` sai 0 ou 1, nunca 2 ou 3 |
| CA-02 | O baseline fica versionado em `runtime/evals/baseline.json` — taxa, cobertura e status por caso | arquivo existe e é lido pelo gate do CA-11 |
| CA-03 | `runtime/tests/` cobre parser, normalização, validação, esteira e os dois geradores derivados | `python3 -m unittest discover runtime/tests` verde, sem modelo e sem rede |
| CA-04 | Item de lista que parseia como mapa onde o campo espera texto **reprova** | teste com `- Branch: x` em `portoes` espera exceção, não `dict` |
| CA-05 | Frontmatter com chave desconhecida em campo declarado gera aviso | `build.sh --strict` reprova |

### Onda 2 — métrica que diagnostica

| # | Critério | Prova |
|---|---|---|
| CA-06 | `resultado.json` traz **matriz de confusão por ação**: acertou · não disparou · sequestrou (e por quem) | o campo `engajadas` do `casos.jsonl` já carrega o dado — é agregação, não coleta nova |
| CA-07 | `eval.sh --repeticoes N` roda a suíte N vezes e o relatório reporta a **taxa mínima** e a variância por caso | `--repeticoes 3` produz 3 blocos e um agregado |
| CA-08 | `eval.sh --mutacao` troca a frase de cada caso pela de um vizinho e espera vermelho | caso que continua verde sob mutação é reportado como **prova morta** |
| CA-09 | O `report.html` separa falso positivo de falso negativo na figura principal | inspeção do relatório gerado |

### Onda 3 — profundidade

| # | Critério | Prova |
|---|---|---|
| CA-10 | Toda ação de trabalho tem ≥3 frases positivas distintas — **41 casos novos** | checagem nova no `build.sh --strict`: ação com menos de 3 positivas reprova |
| CA-11 | Toda ação tem contraprova **dedicada** (`atende: nenhuma` ou de vizinha declarada), não só subproduto | `build.sh --strict` |
| CA-12 | Modo degradado tem um caso **por regime** de cada provider, não um por ação | hoje 8 casos para 8 ações com provider; a `INTERFACE.md` de cada domínio lista os regimes |
| CA-13 | A taxa mínima da suíte aprofundada não fica abaixo do baseline da CA-02 | comparação automática no CI |

### Onda 4 — escala

| # | Critério | Prova |
|---|---|---|
| CA-14 | Teto declarado de tamanho de `description`, e métrica de colisão entre gatilhos no build | hoje ~4.000 tokens de superfície de roteamento para 21 ações (média 87 palavras) |
| CA-15 | `harness-change/SKILL.md` sai de 43KB carregando as fases em `references/` sob demanda | tamanho do `SKILL.md` + a suíte continua verde |
| CA-16 | Revisão de quais das 15 ações fora da esteira deveriam declarar `produz`/`requer` | hoje 6 de 21 na esteira; a decisão de cada uma fica registrada |

### Onda 5 — CI/CD

| # | Critério | Prova |
|---|---|---|
| CA-17 | Pipeline determinístico em todo push | workflow de CI verde num PR de teste |
| CA-18 | Pipeline de comportamento antes de merge, com gate contra o baseline | PR que degrada o roteamento é **barrado**, mesmo com build verde |
| CA-19 | Release recongela o baseline e publica o relatório | tag produz `resultado.json` novo como baseline |

## A esteira de CI/CD

Quatro estágios, separados pelo que custam. O barato roda sempre; o caro roda onde a
decisão acontece.

```
push (qualquer branch)            segundos · sem custo de modelo
  build.sh --strict                 contrato, esteira, cobertura, blocos derivados
  python3 -m unittest ...           motor: parser, validação, geradores
  bash -n · py_compile              sintaxe de tudo que é script
  ↓
pull request                      minutos · custa modelo
  eval.sh --tipo roteamento --repeticoes 3
  GATE: taxa mínima ≥ baseline · nenhuma ação regride individualmente
  ↓
merge em main                     minutos · custa modelo
  eval.sh --tipo modo-degradado --runner claude-headless|codex-exec|opencode-run
  capacidade ausente vira NÃO-RODADO explícito, nunca verde
  ↓
tag de release                    minutos
  eval.sh --mutacao                 a suíte ainda morre quando deve?
  recongela runtime/evals/baseline.json · publica report.html
```

**O gate do PR é a "estrutura de alteração" pedida.** Ele não pergunta se o build passou —
pergunta se a mudança **piorou alguma ação em relação ao baseline**. Regressão por ação
individual reprova mesmo com a taxa agregada estável: uma ação subindo e outra caindo é
exatamente o dano silencioso que a taxa média esconde.

Escolha de plataforma: GitHub Actions, porque o repositório já vive lá e o `gh` já é
provider de backlog. Os quatro estágios são o mesmo shell em qualquer runner — nada da
lógica mora no YAML da plataforma.

**Segredo de modelo no CI.** O estágio de comportamento precisa de credencial do runner.
Enquanto ela não existir no repositório, esse estágio roda **manual, local, antes do
merge**, e o resultado entra no HRN. Não vale marcar o gate como verde por ausência de
credencial.

## As seis métricas

O que passa a existir, e o que cada uma responde:

| Métrica | Responde | Hoje |
|---|---|---|
| **Taxa** = passados / rodados | acerto bruto | calculada, nunca rodada |
| **Cobertura bidirecional** | metade da suíte é inútil sem contraprova | 21/21 nominal |
| **Profundidade** = positivas por ação | uma frase prova só aquela frase | mediana **1** |
| **Matriz de confusão por ação** | separa *não disparou* de *sequestrou o vizinho* | dado coletado, nunca agregado |
| **Estabilidade** = pior de N corridas | gatilho que oscila é gatilho quebrado | não existe |
| **Índice de mutação** | a prova ainda mata? | não existe |

**Assertividade do harness** = taxa mínima de N corridas, com zero sequestro na matriz de
confusão. É esse par que vai no gate — não a taxa sozinha, que sobe encolhendo a suíte.

## Fora de escopo

- **Reescrever o parser com PyYAML.** Traria dependência a um harness que hoje exige só
  `bash` + `python3`, e o `install.sh` deixaria de rodar em ambiente cru. O caminho é
  **testar e endurecer** o parser que existe (CA-03, CA-04), não trocá-lo.
- **Eval para workflow de máquina.** Segue bloqueado pela limitação registrada na HRN-002:
  o vocabulário do caso é `atende: <ação>` e máquina não declara ação. É HRN própria.
- **Avaliar a qualidade do artefato produzido** (o documento ficou bom?). Esta HRN mede
  **roteamento e modo degradado** — se a ação certa foi acionada e se ela parou quando
  devia. Julgar o conteúdo do artefato exige rubrica e juiz, e é outro problema.
- **Otimizar custo de token das personas.** Os ~32KB de L0+L1 carregados por conversa são
  projeto, não defeito. Entra se a métrica de escala (CA-14) mostrar que virou problema.

## Registro

Preenchido ao fim de cada onda: o que a execução mostrou e a proposta não previa.
