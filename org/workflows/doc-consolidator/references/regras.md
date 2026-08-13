# Referência — Como escrever CA · Regras de Negócio · Mensagens · Referências Globais

Rigor de classificação usado pelo `doc-consolidator` ao escrever as seções 4–7 do `.md`.
Substitui a antiga skill `gerar-regras`. Não existe mais "Regra de Apresentação" (RA):
comportamento de tela mora no Critério de Aceitação.

---

## Princípio central — cada camada só existe se acrescenta

Quatro camadas, quatro perguntas. Só escreve a de baixo se ela acrescenta algo que a de
cima não tem — senão é duplicata.

| Camada | Responde | Acrescenta |
|--------|----------|------------|
| Critério de Aceitação | "funciona? aceito?" | comportamento observável + gatilho + efeito |
| Regra de Negócio | "qual a fórmula/política?" | generalidade, cálculo, invariante |
| Mensagem | "o que o sistema diz?" | texto literal |
| Referência Global | "o que é compartilhado?" | dado/estado usado por várias issues |

**Teste da duplicata:** se a camada de baixo só repete a de cima, sem acrescentar fórmula,
texto ou compartilhamento → não escreve. Fica na de cima.

---

## 1. Critérios de Aceitação (seção 4)

- **Formato cenário:** Dado (contexto) / Quando (ação) / Então (resultado observável).
- **Coeso, não fragmentado.** Um CA cobre um **cenário coerente**. Pode reunir condições,
  validações ou efeitos **relacionados entre si** (mesma ação, mesmo formulário, mesmo bloqueio) —
  agrupar o relacionado é **desejado**, evita boilerplate de documentação. **Separe só quando os
  itens forem independentes**: gatilhos/comportamentos sem relação, ou agrupamento que deixa o
  critério ambíguo. Ex.: validações de obrigatórios do mesmo formulário cabem num CA; "salva a
  medição" e "navega para outra tela" são comportamentos distintos → CAs separados.
- **Comportamento de tela mora aqui** (stepper, campo dinâmico, botão habilita/desabilita,
  recálculo em tempo real, indicador) — não numa seção de apresentação.
- **Referenciam por número, não recopiam:** `[RN_0X]` regra, `[MSG_0X]` mensagem, `[GL_0X]`
  referência global. A mensagem/regra nunca é escrita dentro do CA — só o código.
- **Cobertura consciente:** caminho feliz + cada falha + limites (zero, vazio, igual).
- Agrupar por subtópico funcional (4.1, 4.2…) ajuda a leitura, não é obrigatório.

Formato exato da linha (o gerador de `.docx` depende disto):

```
- **CA01:** **Dado que** [contexto], **Quando** [ação], **Então** [resultado]. [RN_01] [MSG_02]
```

`CA` + número + `:` colados dentro do negrito. `Dado que` / `Quando` / `Então` em negrito.
Referências `[RN_0X]` / `[MSG_0X]` / `[GL_0X]` em texto normal no fim (sem crase).

---

## 2. Regras de Negócio (seção 5)

- Entram **só** regras que carregam **fórmula, política ou invariante** que o CA não tem.
  Se o CA já se basta (comportamento de tela óbvio), **não vira regra**.
- **Formato SBVR**: frase declarativa começando por palavra modal:
  - *É necessário que…* — estrutura/invariante que sempre vale.
  - *É proibido que…* — proibição.
  - *É obrigatório que…* — exigência que pode ser violada.
  - *… é calculado como…* — valor derivado de outros.
- **Coesa, não fragmentada.** Uma RN pode reunir asserções sobre a **mesma regra, entidade ou
  preocupação** — ex.: os dados obrigatórios de uma medição ("data de referência, valor da NF
  maior que zero e descrição do escopo") cabem numa RN só. Agrupar o relacionado evita boilerplate.
  Uma derivação pode carregar seu guard imediato ("O saldo é calculado como X. É necessário que X
  seja maior que zero."). **Separe só** políticas **genuinamente independentes** (regras sobre
  conceitos diferentes).
- **Declara a verdade, não o algoritmo.** SBVR diz *o que sempre é verdade*, não o passo-a-
  passo. Proibido descrever procedimento ("iniciando em 01 e incrementando em uma unidade a
  cada registro" → é algoritmo; declare "é único e sequencial dentro do contrato"). Proibido
  escrever regra **sobre o processo** ("é necessário que a validação considere X") — declare o
  **fato** que a validação checa ("o valor atual do contrato é calculado como…").
- **Reúso de GL existente (checagem no início, não promoção).** Antes de gravar uma RN, veja
  se o conceito **já existe** como GL no catálogo do Drive. Se existe → referencie `[GL_0X]`, não
  reescreva local. Se o catálogo não existe ou não cobre → **escreva local**. *Promover* uma
  regra local nova a global é uma revisão **pós-escrita** (ver seção 4), nunca decisão daqui —
  não invente GL na largada.
- **Linguagem de negócio, não código.** Fala de **entidade e atributo** (Contrato, Valor
  SENAT), nunca de "campo", "botão", "tela". Proibido `>=`, `==`, `snake_case`, "onBlur",
  "exibir", "renderizar", "em tempo real" (comportamento de tela → CA).
- **Sem jargão técnico** — prefira o termo de negócio: "cópia integral dos dados" em vez de
  "snapshot"; "quando salva/registra" em vez de "persistência"; "data e hora" em vez de
  "timestamp"; "comparação entre valores anterior e atual" em vez de "diff".
- **Numeração local à issue**, sequencial `RN_01…RN_N`. **Reinicia a cada issue.**
- Cada RN = um bullet: `- **RN_01** — <frase SBVR>`. **Sem título** — a frase SBVR já se
  descreve; título seria a mesma coisa dita duas vezes. Referência é por número, não por título.
- Referenciável de outros lugares por `[RN_01]` + identificação da issue.

Vocabulário proibido em RN:
- **UI** (é comportamento de tela → CA): `botão, clique, aba, tela, sessão, modal, exibir,
  exibição, ocultar, renderizar, cor, campo, tempo real`.
- **Código/processo** (troque por termo de negócio): `snapshot, persistência, persistir,
  timestamp, diff, payload, endpoint, request`.

---

## 3. Mensagens (seção 6)

- **Seção própria**, numeração local `MSG_01…MSG_N` (reinicia por issue).
- Cada uma: **tipo** (Erro / Aviso / Sucesso) + **texto literal**.
- Placeholder para valor dinâmico: `<Numero_Aditivo>` (ex: `Aditivo #<Numero_Aditivo>`).
- **Nunca escritas dentro do CA** — o CA só referencia `[MSG_0X]`.
- Cada MSG = um bullet: `- **MSG_01** (Erro) — "texto exato da mensagem."`

---

## 4. Referências Globais (seção 7) — dois momentos: reusar (cedo) e promover (depois)

Dado, estado, fluxo ou política **compartilhado por várias issues** vive no **documento de
Referências Globais** (`docs/context_docs/md/Referencias-Globais.md`, sincronizado do Drive —
**fonte da verdade, read-only pro harness**). GL tem duas etapas, em momentos diferentes:

### 4.1 Reusar — no início, só leitura

Antes de escrever, leia o catálogo com **um** objetivo: existe GL que dá pra reutilizar aqui?

- **Existe e cobre um conceito da issue** → referencie `[GL_0X]` nas seções 4/7. Não reescreva local.
- **Catálogo não existe no caminho** → global **vazio**; nada a reusar; **tudo nasce local**.
  **Proibido** usar exemplo de `{caminhos.entregaveis}` (ex.: `EXEMPLO_referencias-globais.md`) como catálogo —
  exemplo não é fonte de verdade.

### 4.2 Promover — depois do doc completo, com PROVA real

Só **depois** de escrever o documento com regras locais, releia as RNs e avalie promoção:

- **Promove** só com **2+ consumidores REAIS** (issues de fato documentadas usando o mesmo
  conceito) **ou** por ser enum/fluxo/status estrutural do sistema. **Exemplo fictício/demo NÃO
  é prova.**
- **1º consumidor real** (a issue atual é a primeira a usar o conceito) → **fica LOCAL** + nota
  "candidato a GL — promover quando o 2º consumidor real aparecer". **Não promova sozinho o
  primeiro.**
- **Promoveu (tem prova)** → o harness **NÃO escreve** o doc do Drive (o sync sobrescreve).
  Em vez disso: referencia `[GL_0X]` (número = última do doc + 1, sugerido), lista na seção 7, e
  traz o **conteúdo completo** do GL no apêndice **"Novas Referências Globais — copiar para o
  Drive"** (o `.docx` ignora esse apêndice; o usuário cola no Drive depois).

Numeração `GL_0X` é **global e contínua no doc do Drive** — o consolidator só lê a última e
sugere a próxima; nunca renumera nem escreve lá.

### Globais recorrentes — os suspeitos de sempre

Conceitos que costumam virar globais em contrato. Use a lista **nos dois momentos**: na etapa 4.1,
para ver se o catálogo já os tem (reúso); na 4.2, como candidatos — mas **ainda precisam do 2º
consumidor real** pra promover. Não são GL automático.

- **Numeração sequencial por contrato** (aditivo #1/#2…, medição #01/#02…).
- **Histórico de ações do contrato** (criação/edição/exclusão gera entrada imutável, com
  comparação anterior/atual na edição e cópia integral na exclusão).
- **Valor atual do contrato** (valor inicial + alterações vigentes de aditivos).
- **Situações/estados de entidade** (status e transições).
- **Papéis de usuário, catálogos fixos, enums estruturais.**

---

## 5. Numeração — resumo

- `RN_0X` e `MSG_0X` → **locais**, reiniciam por issue, texto completo mora no `.md`.
- `GL_0X` → **global**, contínuo no doc do Drive (read-only); a issue só referencia.
- CAs referenciam todos por esses códigos, cruzando as camadas.
