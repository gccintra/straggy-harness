# 17 — User Story Mapping

> **Método:** `story-mapping` (L1). **Contrato:** espinha dorsal em passos do usuário ·
> atividades por passo · **fatia horizontal** da próxima entrega · o que ficou fora e por quê.
> **Estado:** a fatia proposta é a do alpha (19). Fatia vertical (uma etapa completa) não
> permite ninguém terminar o trabalho — por isso a fatia atravessa a jornada inteira, rasa.

---

## Espinha dorsal — a jornada real de P2, na ordem em que ele faz

```
1. ENTRAR     2. DECLARAR   3. TRAZER     4. PEDIR      5. DESENHAR      6. REVISAR   7. PUBLICAR   8. ACOMPANHAR
   no espaço     o padrão      a demanda     o trabalho    (só se tem       e aprovar     a saída       o que saiu
                                                            interface)
```

O passo 5 é **condicional e já modelado pelo sistema**: `documentar-requisito` exige
`prototipo-validado` quando a demanda tem interface (`system/ACOES.md`). Demanda sem tela
pula direto para o 6.

Passo 2 é feito por P3 (administrador), uma vez. Os demais são de P2, toda semana.

## O mapa

| | 1. Entrar | 2. Declarar padrão | 3. Trazer demanda | 4. Pedir trabalho | 5. Revisar | 6. Publicar | 7. Acompanhar |
|---|---|---|---|---|---|---|---|
| **A** | criar espaço | escolher a ação a customizar | colar/descrever a demanda | pedir em linguagem natural | ver o artefato | gerar o entregável final | ver o estado das demandas |
| **B** | convidar time | preencher "como fazer" | puxar demanda do backlog do time | sistema reconhece a ação | pedir ajuste | publicar no backlog/wiki do time | ver o que aguarda revisão |
| **C** | conectar integrações | preencher estrutura do documento | trazer contexto do Drive | executar | aprovar | anexar prints | ver quem aprovou o quê |
| **D** | preencher dados do projeto | montar o funil (preset) | consultar histórico do espaço | acompanhar execução | comparar com o padrão | refinar, priorizar e mexer em sprint na ferramenta do time | relatório de aceitação |
| **E** | definir papéis e permissões | versionar o padrão | busca semântica no contexto | várias demandas em paralelo | ver diferença proposto × editado | agendar publicação | métricas de delivery |

**Todo passo que toca backlog acontece na ferramenta do time, por integração** — não existe
quadro, issue nem sprint dentro do produto (00, v4). Nas linhas B e D, "backlog" quer dizer
Jira, Linear, Azure Boards ou GitHub/GitLab do cliente, com preview e aprovação antes de
qualquer escrita.

## A fatia do alpha — horizontal, rasa, atravessando tudo

**Linha A inteira + o mínimo de B onde a linha A não fecha o trabalho.**

| Passo | Entra no alpha | Como |
|---|---|---|
| 1. Entrar | criar espaço · conectar **1** integração de backlog · dados do projeto | sem convite de time, sem permissões |
| 5. Desenhar | brief da tela · construção do protótipo navegável · prints para a documentação | só para demanda com interface; publicação do protótipo usa a infra que o cliente já tem |
| 2. Declarar padrão | 2 encaixes: **como fazer** e **estrutura do documento**, na ação `documentar-requisito` | por nós, na implantação assistida — não por autosserviço |
| 3. Trazer demanda | colar a demanda **ou** puxar do backlog conectado | um caminho basta; os dois é conforto |
| 4. Pedir trabalho | conversa em texto; o sistema reconhece a ação | uma demanda por vez |
| 5. Revisar | ver o artefato · aprovar · pedir ajuste | portão como estado, com trilha |
| 6. Publicar | gerar o entregável final e publicar no backlog do time | com preview antes de escrever; a escrita é na ferramenta do cliente, nunca num quadro nosso |
| 7. Acompanhar | lista de demandas com estado | sem gráfico, sem métrica |

**Por que esta fatia e não outra:** é a menor jornada em que **o trabalho de alguém termina**
— entra uma demanda, sai um requisito aprovado e publicado no padrão da empresa. Qualquer
fatia menor devolve trabalho pela metade, e nenhum cliente do beachhead consegue usar.

## O que ficou de fora — registrado, não apagado

| Fora | Passo | Por quê | Quando volta |
|---|---|---|---|
| Convite de time e permissões | 1E | time de até 6 pessoas opera com um espaço e confiança mútua | quando entrar time maior |
| Autosserviço de configuração | 2 | A2 não testada; implantação assistida ensina mais e falha menos (16, cenário 3) | depois de A2 confirmada |
| Construtor de funil e versionamento do padrão | 2D, 2E | priorização **continua no escopo do produto** (00, v4) — o que fica fora do alpha é a tela de montar o funil: no alpha o funil é declarado por nós na implantação assistida | quando a implantação deixar de ser assistida, ou quando priorização aparecer como dor de entrada em 07 |
| Refino, sprint e demais operações de backlog (3B, 6D) além de puxar e publicar | 3B, 6D | são trabalho real de PM/PO e existem no motor, mas cada uma é mais uma escrita externa a validar; o alpha precisa medir ciclo com o mínimo de superfície | logo após o alpha, junto com a medição de A14 (09) |
| Busca semântica no contexto | 3E | dor real (O3), solução cara (14) | pós-alpha |
| Paralelismo | 4E | impacto de segunda ordem (12) | quando o volume por conta justificar |
| Diferença proposto × editado | 5E | insumo do relatório de aceitação, não item próprio | junto com F24 |
| Agendamento e automação | 6E | sem problema associado (13) | não previsto |
| Hospedagem do protótipo gerenciada pelo produto | 5 | é produto de infraestrutura (build, domínio, certificado, storage) e não encurta ciclo | não previsto |
| Comentário de stakeholder no protótipo | 5 | encurtaria o laço de validação, mas é construção nova sem evidência | pós-alpha |
| Métricas de delivery | 7E | nenhuma decisão de P1 muda com isso hoje | não previsto |

## Dependências que o score de 14 não mostra

O ranking sugere paralelismo que a jornada não permite:

```
F17 espaço  →  F02 encaixes  →  F01 ação no padrão  →  F08 portão/estado  →  F03 entregável  →  F21 preview
   (2)            (2)               (já existe)            (5)                  (já existe)        (6)
```

**F01 e F03 já existem, mas não são alcançáveis sem F17 e F02 na interface.** É a razão de
F17 (score 40, "planejar") ser, na prática, o primeiro item a construir: score baixo por
esforço alto não muda o fato de que nada funciona sem ele.
