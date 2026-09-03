# 07 — Entrevistas Mom Test

> **Método:** `continuous-interview` (L1). **Contrato:** objetivo de aprendizado · roteiro de
> passado · sinais que confirmam e que refutam · notas separando fato de interpretação ·
> veredito.
> **Estado:** **não executado.** Este documento é o instrumento. Enquanto ele não rodar,
> 05, 06, 08 e 09 continuam apoiados em indício.

---

## As três regras (Mom Test)

1. **Fale do passado da pessoa, nunca do futuro dela.** "Como você fez da última vez?" —
   nunca "você usaria?".
2. **Não fale da sua ideia.** Pitch antes da resposta contamina tudo que vem depois.
3. **Procure custo já pago** — tempo, dinheiro, gambiarra mantida. É o que separa incômodo
   de problema.

Sinal de que a conversa foi ruim: a pessoa elogiou. Elogio não é dado.

## Objetivo de aprendizado

Três hipóteses, na ordem de risco (03):

| | Hipótese | O que a entrevista precisa capturar |
|---|---|---|
| **H1** | o problema é caro o bastante para virar orçamento | custo já pago: horas, retrabalho, contrato afetado, ferramenta comprada |
| **H2** | a empresa configura o próprio padrão | existe padrão escrito? quem o mantém? o que já tentaram? |
| **H3** | artefato de IA é aceito sem reescrita | o que já geraram com IA e o que fizeram com a saída |
| **H4** | operar o backlog do time por integração é bom o bastante | qual ferramenta, **quanto ela foi customizada** (sprint, etapas, campos obrigatórios) e quanto trabalho manual existe entre decidir e estar registrado lá dentro |

## Amostra

| | |
|---|---|
| **Quem** | 10–14 pessoas dos segmentos S1 e S2 (04): 5–7 P1 (líder), 5–7 P2 (PM/PO de execução). Sem filtro por modelo de negócio — in-house, agência e consultoria na mesma amostra |
| **Como recrutar** | rede direta · comunidades de produto · quem publica sobre processo e padrão de produto |
| **Viés reconhecido** | rede pessoal do fundador tende a concordar; contrapeso é buscar ≥ 40% fora da rede e registrar de onde veio cada pessoa |
| **Descarte** | quem não documenta requisito formal — está fora do segmento, não é dado contrário |

## Roteiro — 45 a 50 minutos

**Abertura (2 min).** "Estou estudando como times de produto documentam demanda. Não vou
apresentar nada — quero entender como vocês fazem hoje."

**Bloco 1 — o trabalho real (10 min)**
- Me conta a última demanda que você documentou. Começa do começo.
- Quanto tempo levou? Quanto disso foi escrever e quanto foi formatar/ajustar?
- Onde você foi buscar o contexto? Quantos lugares?
- O que você fez quando faltou informação?

**Bloco 2 — o padrão (10 min)**
- Existe um jeito certo de documentar aí? Onde ele está escrito?
- Quando foi a última vez que você abriu esse documento?
- Quem revisa? O que costuma voltar na revisão?
- Me conta a última vez que um documento voltou. O que aconteceu depois?
- Como foi quando entrou alguém novo? Quanto tempo até produzir no padrão?

**Bloco 3 — IA (8 min)**
- Você usou IA nisso? Me mostra o que saiu (pedir para abrir, se possível).
- O que você fez com a saída? Usou como estava?
- O que te fez parar de usar, se parou?
- Alguém no time proibiu ou desencorajou?

**Bloco 4 — o backlog e como ele é operado (7 min)** — acrescentado em 2026-08-29, com o
recorte de escopo. Nunca perguntar se trocariam de ferramenta: a resposta é sempre não e não
é isso que está em jogo.
- Onde o backlog de vocês vive? Me mostra a última demanda registrada.
- Vocês mexeram muito na configuração? Como está o fluxo — quais etapas existem?
- Como vocês trabalham sprint? (ou: vocês usam sprint?)
- Tem campo que vocês inventaram e que é obrigatório preencher?
- Me conta o caminho da última demanda: de "alguém pediu" até estar registrada e refinada
  lá. Quanto disso foi digitar coisa que já estava decidida?
- Quem faz esse registro? Sempre a mesma pessoa?
- Já usaram alguma automação ou bot escrevendo no backlog? O que aconteceu?

**Bloco 5 — custo já pago (7 min)**
- Vocês já compraram alguma ferramenta para isso? Qual, quanto, ainda usam?
- Já tentaram resolver internamente? O que foi feito? O que aconteceu com aquilo?
- Se isso continuar como está pelos próximos 12 meses, o que acontece?

**Fechamento (3 min)**
- Quem mais eu deveria ouvir?
- Posso voltar se aparecer dúvida?

## Sinais

| Confirmam | Refutam |
|---|---|
| cita horas gastas com **formato**, não com conteúdo | a dor citada é priorização ou stakeholder, não documento |
| documento já voltou do cliente por forma | "nunca voltou nada por formato" |
| existe padrão escrito **e** ninguém abre | não existe padrão e ninguém sente falta |
| já pagou por ferramenta ou pessoa para isso | nunca gastou nada, nunca tentou nada |
| gerou com IA e **reescreveu** a saída | usa a saída da IA como está, sem incômodo |
| revisão do líder é gargalo reconhecido | quem revisa quer revisar — controle é o valor |
| digita no backlog o que já estava decidido em outro lugar | o registro no backlog é rápido e não incomoda ninguém |
| ferramenta de backlog razoavelmente padrão, ou customização que cabe nas operações da interface de provider | fluxo tão customizado que nenhuma integração cobre — sinal contra H4, e insumo direto de A14 (09) |
| já deixou automação escrever no backlog e deu certo | proibição explícita de escrita automatizada na ferramenta |

## Formato de nota — fato separado de interpretação

Uma nota por entrevista, em `docs/hub/discovery/notas/AAAA-MM-DD_<segmento>_<papel>.md`:

```markdown
## Entrevista — AAAA-MM-DD · P1 · S1, 6 PMs, produto próprio · origem: fora da rede

### Fatos (o que a pessoa disse ou mostrou)
- "a última HU levou 3 horas, 1 hora foi mexer no template"
- mostrou template no Confluence, última edição há 8 meses
- comprou ChatGPT Team para o time em jan/2026, 6 assentos

### Interpretação (minha, não dela)
- o custo de formato parece maior que o de conteúdo — checar nas próximas 3

### Contra a minha tese
- disse que revisar é a parte que ele não quer terceirizar

### Veredito por hipótese
H1: indício a favor · H2: em aberto · H3: indício contra
```

**A seção "Contra a minha tese" é obrigatória.** Entrevista que não produziu nenhuma
evidência contrária provavelmente foi conduzida errado.

## Critério de parada e veredito

- **Parar** quando 3 entrevistas seguidas não trouxerem informação nova (saturação), ou aos 14.
- **Veredito por hipótese:** confirmada / refutada / em aberto, com contagem de quantas
  entrevistas sustentam cada lado.
- **H1 refutada** → a tese muda antes de qualquer construção; 03 e 04 são reescritos.
- **H2 refutada** → o produto pode ser bom, mas o fosso não existe: revisar 06 e 11.
- **H3 refutada** → o portão vira teatro; revisar 19 antes de qualquer alpha.
- **H4 refutada** → as ferramentas reais são customizadas além do que a integração cobre.
  Duas saídas, e a escolha é de produto, não de pesquisa: (a) as ações de backlog e sprint
  saem do escopo e o produto fica só em estratégia, documento e contexto; (b) reabre-se a
  construção de backlog próprio — que é exatamente o que o recorte de 2026-08-29 tirou da
  mesa. Revisar 01, 06 e 18 antes de qualquer decisão.
