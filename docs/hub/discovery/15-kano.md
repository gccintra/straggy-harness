# 15 — Kano

> **Método:** `kano` (L1). **Contrato:** itens classificados (básico, desempenho,
> encantamento, indiferente, reverso) **com origem da classificação** · implicação de
> investimento por categoria.
> **Estado:** **classificação é hipótese.** O método exige que ela venha do cliente, pelo par
> de perguntas funcional/disfuncional — e isso não foi feito. O questionário está no fim;
> sem ele, esta tabela é palpite ordenado, e está marcada como tal.

---

## Classificação hipotética — S1 (time com padrão e rotatividade)

| Item | Categoria `[S]` | Raciocínio |
|---|---|---|
| Documento sai no formato declarado | **básico** | é a razão da compra; se falha, nada mais importa. Não gera satisfação — evita rejeição |
| Contexto do produto acessível (integrações) | **básico** | sem isso a saída é genérica, e o tempo de caçar contexto volta inteiro para a pessoa |
| Trabalho aterrissando na ferramenta de backlog que o time já usa | **básico** | é a contrapartida de não ter backlog próprio: se não aterrissa lá, o PM digita de novo — e aí o produto acrescentou trabalho em vez de tirar |
| Cobertura das operações de backlog e sprint na ferramenta customizada do time | **desempenho** `[S]` | quanto mais da rotina cabe na integração, menos a pessoa abre a ferramenta na mão. Linear e diretamente percebido (A14 em 09) |
| Nada é escrito fora do rascunho sem aprovação | **básico** | uma escrita indevida em backlog de cliente encerra a conta |
| Não perder informação da demanda | **básico** | higiene |
| % de artefatos aceitos sem reescrita | **desempenho** | quanto maior, melhor, de forma linear e percebida |
| Velocidade de execução da ação | **desempenho** | é a promessa da v3; linear e imediatamente percebida |
| Profundidade da customização por encaixe | **desempenho** | mais controle, mais valor — até o ponto em que vira trabalho |
| Cobertura de ações (quantos trabalhos o Hub faz) | **desempenho** | cada ação nova é mais um pedaço do fluxo dentro do produto |
| **Portão como estado, com trilha de aprovação** | **encantamento** `[S]` | ninguém pede; quem entende percebe que resolve a desconfiança de IA. **É a aposta de diferenciação** |
| Padrão declarado uma vez valendo para todo o time | **encantamento** | é o "não sabia que dava para fazer isso" |
| Extrair o padrão dos documentos antigos (F05) | **encantamento** | elimina o maior atrito de entrada |
| Relatório de aceitação por espaço | **encantamento** → vira desempenho rápido | prova o valor; em 12 meses vira expectativa |
| Conversas em paralelo | **desempenho** `[S]` (era indiferente na v2) | sob a tese de velocidade, é o mecanismo que quebra a serialização. Continua `[S]`: ninguém pediu ainda |
| Todo o contexto do produto num lugar só, achável (repositório + frontmatter + busca) | **desempenho** `[S]` | quanto mais do contexto vive lá, mais a saída presta — linear e percebido. Vira **básico** no dia em que o time depender dele |
| Estruturas de produto (roadmap, persona, OKR) editáveis no mesmo lugar do trabalho | **encantamento** `[S]` | é a aposta A15: ninguém pede "quero meu roadmap junto do requisito", e quem vê entende na hora. **É a segunda aposta de diferenciação, e tem menos evidência que a primeira** |
| Sincronizar o Drive em vez de migrar | **básico** `[S]` | não gera satisfação; a ausência dele vira "então eu vou ter que mudar tudo de lugar?" e mata a adoção na entrada |
| Kanban próprio | **indiferente / reverso** | quem já tem backlog vê como duplicação e trabalho a mais. Desde 2026-08-29 é também decisão de escopo (00, v4) — a classificação Kano vira confirmação, não critério |
| Workshops e canvas editáveis | **indiferente** no beachhead | seria desempenho no segmento B (produto próprio) |
| Voz | **indiferente** | nenhuma situação de uso levantada |
| Autonomia total, sem portão | **reverso** | quanto mais, **pior** para P1: é perda de controle sobre entregável contratado |

## As quatro leituras que mudam decisão

1. **Quase tudo que já existe é básico.** Básico não vende — evita perder. Investir mais em
   F01/F03/F12 além do funcional não aumenta satisfação; só protege contra rejeição.
   Consequência: **parar de melhorar o que já passa** e mover esforço para desempenho e
   encantamento.
2. **A aposta de diferenciação (portão como estado) é encantamento não solicitado.** Ninguém
   vai pedir. Isso significa duas coisas: não aparece em pesquisa de feature, e precisa ser
   **demonstrado**, não listado. Se a demonstração não emocionar, não é encantamento — é
   fricção com nome bonito, e a posição de 06 cai.
3. **Agora são duas apostas de encantamento, não uma.** Portão como estado (2026-08-18) e
   estruturas de produto no mesmo lugar do trabalho (2026-08-29). Duas apostas não
   solicitadas na mesma versão dobram a superfície que precisa ser **demonstrada** para
   valer — e nenhuma aparece em pesquisa de feature. Se a demonstração precisar explicar as
   duas, provavelmente nenhuma pega.
4. **Existe item reverso na lista original de features.** "Autonomia total" e "kanban
   próprio" pioram a percepção do cliente-alvo. Feature reversa é a mais cara de todas:
   custa construir e custa cliente.

## Validade da classificação

Encantamento vira expectativa com o tempo. Prazos declarados para revisitar:

| Item | Revisitar em |
|---|---|
| portão como estado | 12 meses — se o mercado copiar, vira básico |
| relatório de aceitação | 6 meses |
| padrão declarado valendo para o time | 18 meses |

## Questionário — para rodar junto com 07

Por item, o par obrigatório (escala: gosto · é o esperado · indiferente · dá para conviver ·
não gosto):

> **Funcional:** "Se o sistema **sempre** entregasse o documento no formato exato da sua
> empresa, como você se sentiria?"
> **Disfuncional:** "E se ele **não** entregasse no seu formato, como você se sentiria?"

Itens a testar, nesta ordem: formato declarado · aceitação sem reescrita · portão com trilha
· padrão valendo para o time · extração do padrão antigo · **trabalho aterrissando na
ferramenta de backlog atual** · kanban próprio · autonomia sem portão.

O par para o item novo, que é o que testa o recorte de escopo:

> **Funcional:** "Se o sistema registrasse e refinasse a demanda **direto no Jira/Linear de
> vocês**, sem você abrir a ferramenta, como você se sentiria?"
> **Disfuncional:** "E se, para isso, você precisasse mover o backlog de vocês para dentro
> dele, como você se sentiria?"

Kanban próprio continua na lista **só como contraprova**: se a resposta disfuncional for
morna, a decisão de escopo perdeu uma de suas justificativas e vale reabrir A14 mais cedo.

**Segmentar sempre por papel** (P1 líder × P2 executor): o que encanta P1 (controle
registrado) pode ser exatamente o que P2 classifica como reverso (fricção). Média entre os
dois esconde o conflito que 04 já apontou como principal risco de adoção.
