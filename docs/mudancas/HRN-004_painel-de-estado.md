# HRN-004 — Painel: o estado do harness numa página

| | |
|---|---|
| **Estado** | proposto |
| **Camada** | motor (`runtime/adapters/`, `runtime/*.sh`) |
| **Arquivos** | `runtime/adapters/painel.py` (novo) · `runtime/painel.sh` (novo) · `README.md` · `docs/HARNESS.md` · `docs/MANUTENCAO.md` · `system/workflows/harness-change/SKILL.md` (checklist) |
| **Data** | 2026-09-01 |
| **Depende de** | nada. Convive com a [HRN-003](HRN-003_robustez-medicao-e-ci.md) e fica melhor conforme ela avança |

## História

Como **quem opera o harness**, quero **uma página que me diga como ele está agora — contrato,
prova, configuração e mudanças em aberto**, para **saber se posso confiar nele hoje sem
abrir cinco arquivos e cruzar número na cabeça**.

Hoje o estado existe, mas espalhado em quatro lugares que ninguém lê junto:

| Onde | O que responde | Formato |
|---|---|---|
| `build.sh --strict` | o contrato passa? | linhas no terminal, some ao fechar |
| `build.sh --list` | o que existe, encaixes preenchidos | tabela no terminal |
| `runtime/manifest.json` | ações, providers, esteira | JSON, para máquina |
| `runtime/evals/*/resultado.json` | a assertividade | só existe se alguém rodou |

Nenhum deles responde **"o harness está bem?"**. E o mais importante — a assertividade — é
justamente o que hoje não existe, porque a suíte nunca rodou inteira (HRN-003). Um painel que
mostrasse 100% verde ignorando isso seria pior que nenhum painel.

## Regras de negócio

- **RN-01.** **Ausência de medida nunca vira verde.** Suíte não rodada aparece como "não
  medido", com o motivo — nunca como 0%, nunca como aprovado, nunca omitida.
- **RN-02.** Tudo na página é **derivado** de fonte existente. O painel é uma vista, nunca
  uma segunda fonte — mesma regra do manifesto (`ARCHITECTURE.md` §8). Nada é digitado à mão.
- **RN-03.** Determinístico: mesma entrada, mesma página. Timestamp aparece como dado do que
  foi lido, nunca dentro dos números.
- **RN-04.** Cada número diz **de onde saiu**. Painel sem procedência é opinião com CSS.
- **RN-05.** Gerar o painel **não custa modelo**. A corrida de eval é opt-in explícito, e a
  página se vira com a última corrida gravada — ou declara que não há nenhuma.
- **RN-06.** Sem `.env` (o repositório do harness é assim) a seção de configuração **degrada
  declarada**, nunca quebra e nunca inventa provider ativo.
- **RN-07.** O painel **reprova** quando há achado crítico — é o que permite usá-lo como
  porta de CI, e não só como decoração.
- **RN-08.** CSS, paleta de status e helpers vêm de `report.py` por importação. Duplicar a
  folha seria a cópia que a arquitetura proíbe.
- **RN-09.** Página única, sem rede: abre offline, de qualquer lugar, sem servidor.

## O que a página mostra

Uma figura-herói, uma faixa de indicadores e cinco seções. A ordem é deliberada: o que
reprova primeiro, o inventário depois.

| Bloco | Responde | Fonte |
|---|---|---|
| **Herói** — assertividade | o roteamento acerta? | última corrida com `resultado.json`, ou "não medido" |
| **Indicadores** | contrato · achados críticos · ações · frases positivas e mediana · cobertura dos dois lados · encaixes preenchidos | saída do build + manifesto + fontes de eval |
| **O que está abaixo da barra** | o que consertar, com o porquê e onde | diagnóstico cruzado |
| **Prova por ação** | por ação: quantas frases positivas, contraprovas, casos de modo degradado, e como foi na última corrida | fontes de eval + `resultado.json` |
| **Providers** | qual implementação está ativa e com que capacidades | manifesto + `.env` |
| **Esteira** | quem produz e quem exige cada artefato, e quem está fora | manifesto |
| **Mudanças** | as HRNs e o estado de cada uma | `docs/mudancas/HRN-*.md` |

**A seção que dá o valor é "o que está abaixo da barra"** — não a que lista o que existe.
Inventário `docs/WORKFLOWS.md` já dá. O painel serve para dizer o que está errado agora.

Achados que ele precisa detectar: ação com menos de 3 frases positivas · ação sem
contraprova · ação com provider e sem caso de modo degradado · ação indisponível por encaixe
essencial vazio · erro ou aviso de contrato · suíte nunca rodada · última corrida parcial.

## Impacto

Os cinco raios de `system/workflows/harness-guide/references/impacto.md`.

| Raio | Achados | O que fazer |
|---|---|---|
| **Cita o alvo** | nada cita `painel.*` — é arquivo novo. Ele **passa a citar** `build.sh`, `eval.sh`, `report.py`, `manifest.json`, as fontes de eval e `docs/mudancas/` | as menções novas vão no `README.md`, `docs/HARNESS.md` §7 e no checklist de propagação da `harness-change` |
| **Esteira** | vazio — mudança de motor não declara `acao`, `produz` nem `requer` | — |
| **Evals** | nenhuma fonte muda e nenhuma ação é renomeada. **Mas cria acoplamento novo**: o painel lê `tipo`, `atende` e `confunde_com` do `caso.yaml` | mudança futura no vocabulário de caso passa a ter dois consumidores — `report.py` e o painel. Registrar no checklist |
| **Organização** | nenhum encaixe muda de caminho. O painel **lê** `org/` pela visão resolvida e lê o `.env` do projeto | RN-06 cobre a ausência dos dois. Cuidado com dado de instância na página: **`.env` nunca é impresso** — só o nome da variável e a implementação escolhida |
| **Camada** | correta: motor em `runtime/adapters/`. Nenhuma regra de comportamento desce para o pack; nenhum portão é tocado | — |

**Risco declarado.** Painel bonito com números rasos é pior que terminal honesto: dá
sensação de controle. A RN-01 e a seção de achados existem contra isso, e o número que
importa (assertividade) fica **em branco declarado** até a HRN-003 Onda 1 rodar.

**Segundo risco.** Imprimir valor de `.env` na página vaza segredo para qualquer lugar onde
o HTML for parar. Só nome de variável e id de implementação.

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | `./runtime/painel.sh` gera a página sem rodar modelo nenhum | tempo de execução na ordem do `build.sh`; nenhuma chamada a runner |
| CA-02 | Sem corrida de eval, o herói diz **"assertividade não medida"** e o motivo | rodar num repositório sem `resultado.json` |
| CA-03 | Com corrida, o herói mostra a taxa, o runner, os não-rodados e a data da leitura | rodar após `eval.sh` |
| CA-04 | Corrida parcial (`--skill`, `--tipo`) aparece como achado, não como resultado do harness | rodar `eval.sh --skill X` e conferir a seção de achados |
| CA-05 | Achado crítico faz o comando sair **1** | `echo $?` após uma execução com achado |
| CA-06 | Sem `.env`, a seção de providers explica a ausência e não quebra | é o estado do próprio repositório do harness |
| CA-07 | Nenhum valor de `.env` aparece na página | grep por valor de variável no HTML gerado |
| CA-08 | Os números batem com `build.sh --list` e com o manifesto | conferência cruzada das duas saídas |
| CA-09 | CSS e paleta importados de `report.py`, zero duplicação | `grep -c "^CSS" runtime/adapters/painel.py` = 0 |
| CA-10 | A página abre offline, sem servidor e sem rede | abrir o arquivo direto no navegador |
| CA-11 | `--com-eval` roda a suíte antes de gerar, e é a única forma de custar modelo | inspeção da flag |
| CA-12 | O painel entra no checklist de propagação da `harness-change` | o checklist cita o comando de regeneração |

## Fora de escopo

- **Série temporal.** Como o harness evoluiu ao longo do tempo exige histórico versionado de
  corridas, e hoje não há nem a primeira corrida. Entra depois da HRN-003 Onda 1, quando o
  baseline existir e houver o que comparar.
- **Matriz de confusão, estabilidade e mutação.** São métricas da HRN-003 (CA-06 a CA-09).
  O painel **as exibe quando existirem**; não é ele quem as calcula.
- **Painel servido, com atualização automática.** Arquivo estático resolve; servidor
  adiciona processo para manter e uma porta para configurar.
- **Qualidade do artefato produzido.** Mesma fronteira da HRN-003: o painel mede roteamento e
  contrato, não se o documento gerado ficou bom.

## Estado atual que o painel revelaria

Levantado para dimensionar a spec — e é a razão dela existir:

| Indicador | Hoje |
|---|---|
| Contrato | aprovado, 0 erro, 0 aviso |
| Assertividade | **não medida** — a suíte nunca rodou inteira |
| Ações de trabalho | 21 |
| Frases positivas | 21 — **mediana 1 por ação**, alvo 3 |
| Cobertura dos dois lados | 21/21 |
| Encaixes preenchidos | 18 de 35 |
| Ações fora da esteira | 15 de 21 |
| Achados críticos | 2 — profundidade rasa e suíte não medida |

## Registro

Preenchido ao fim da execução.
