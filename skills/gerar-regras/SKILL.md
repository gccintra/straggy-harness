---
name: gerar-regras
description: "Gera Regras de Negócio (RN), Regras de Apresentação (RA) e Mensagens do Sistema (MSG) no padrão oficial do projeto, aplicando rigor acadêmico de Engenharia de Software e separação de preocupações (Separation of Concerns). Use esta skill sempre que o utilizador pedir para documentar, criar ou gerar regras a partir de uma descrição de funcionalidade. O output segue estritamente o padrão do projeto, garantindo que regras de domínio NUNCA se misturem com regras de interface."
---

# Skill: Gerar Regras

Esta skill transforma descrições de funcionalidades em documentação formal de requisitos no padrão do projeto. Ela classifica rigorosamente o comportamento do sistema em RN, RA e MSG, com tolerância zero para a mistura de conceitos de Interface Gráfica (UI) dentro de Regras de Negócio (Domínio).

---

## 1. Antes de gerar — Entender o contexto

**Colete contexto das DUAS fontes antes de gerar:**
- **Repo:** regras existentes em `docs/context_docs/md/Regras/` (reúso, conflito e próximo número de RN/RA/MSG) + a seção relevante do ONEPAGE.md.
- **GitLab:** a issue da demanda e relacionadas — carregue a skill `glab-backlog` e use `glab issue view <NNN> -R ${GITLAB_REPO}` / `glab issue list --search "[termo]" -A`. Issues trazem decisões que ainda não chegaram aos docs do repo.

Se a descrição da funcionalidade estiver incompleta ou ambígua, faça perguntas pontuais antes de gerar.

Perguntas úteis para elicitação:
- Qual é o fluxo completo (quem executa a ação, quais as pré-condições e pós-condições)?
- Quais são os invariantes da base de dados? (O que não pode acontecer de jeito nenhum?)
- O que é política da instituição (Negócio) e o que é apenas para facilitar a vida do utilizador no ecrã (Usabilidade)?
- Quais são os próximos números de RN, RA e MSG disponíveis?

---

## 2. Diferenciação Acadêmica: RN, RA e MSG

Aplique os princípios de Clean Architecture. O domínio (RN) não sabe que a interface (RA) existe.

---

### RN — Regra de Negócio (Políticas de Domínio e API)

**Essência:** A RN encapsula o "Domínio do Problema". Ela dita as leis, cálculos e restrições da instituição que existiriam independentemente de um ecrã existir. Pense na RN como as validações que o Backend/API faria mesmo se o pedido viesse via linha de comandos (cURL ou Postman).

🚫 **VOCABULÁRIO PROIBIDO EM RN:**
NUNCA use as palavras: botão, clique, aba, separador, ecrã, sessão, navegador, modal, exibir, exibição, renderizar, ocultar, cor, campo, tempo real.

⚠️ **Cheiro de RA disfarçada de RN:** frases como "exibir/atualizar abaixo do campo", "atualizado em tempo real conforme o campo X muda", "ao informar o valor no campo Y" indicam que a regra descreve **reatividade de tela**, não política de domínio. Nesses casos, separe:
- A **fórmula/cálculo** (ex: "Data de Vigência = Data do Contrato + Prazo") fica na RN, falando de **entidades e atributos**, nunca de "campo" ou onde/quando aparece na tela.
- O **gatilho de exibição/atualização em tela** (o quê, quando e onde é mostrado, recálculo em tempo real ao digitar) vira RA.

**É RN quando:**
- Impede a corrupção de dados ou garante a integridade referencial.
- Define a máquina de estados de uma entidade (ex: "Uma turma só pode ser consolidada se o questionário estiver completo").
- Determina restrições de permissão de acesso aos dados.

**Exemplo padrão de escrita:**
`RN_XXXX: O sistema deve bloquear a efetivação de uma turma caso a mesma não possua os requisitos obrigatórios preenchidos.`

---

### RA — Regra de Apresentação (Requisitos de Interface, UX e Sessão)

**Essência:** A RA encapsula o comportamento do Front-end (React/Angular/Vue) e a Interação Humano-Computador. Ela existe para dar suporte ao utilizador.

✋ **Teste do print — crie a RA SÓ se não puder ser mostrada num print de tela do protótipo.**
Antes de escrever qualquer RA, pergunte: *"isso consegue ser comunicado por um print estático de
uma tela do protótipo?"* Se **SIM**, **não crie a RA** — o protótipo já comunica (layout, campos,
posição, estados visíveis de uma tela). Só crie RA quando o que precisa ser dito é **dinâmico/condicional/comportamental**
e um print parado não captura: *quando* algo aparece/some, sob qual condição desabilita, o que é
retido em sessão ao trocar de aba, para onde navega. Regra: print resolve → sem RA; só comportamento que o print não mostra → RA.

⚠️ **ATENÇÃO - Rascunhos e Botões são RA:**
Guardar dados "em sessão", "localmente" ou "em rascunho sem bater na API" é sempre RA. Esconder, desabilitar ou mostrar botões baseados numa condição é sempre RA.

**É RA quando:**
- Oculta, desabilita ou exibe botões, modais ou separadores (abas).
- Retém dados no estado local/sessão do navegador para evitar perda ao alternar separadores (ex: rascunhos de formulário).
- Redireciona o utilizador para outras páginas.

🚫 **NÃO descreva componentes visuais.** A RA define **comportamento/condição** de apresentação
(quando algo é ocultado, desabilitado, retido em sessão, ou para onde navega) — **nunca** a aparência,
layout, posição, cor, ícone, estilo ou a estrutura visual do componente. Isso já é mostrado no
**protótipo**, que é a fonte de verdade do visual. Referencie o elemento pela sua função (o gatilho/efeito),
não o desenhe em palavras.

- ✅ **É RA:** *o botão de guardar é ocultado quando a entidade já está consolidada* (condição → efeito).
- ❌ **Não é RA (vai pro protótipo):** *o botão "Guardar" é verde, fica no canto inferior direito, com ícone de disquete e largura de 120px* (descrição visual).

**Exemplo padrão de escrita:**
`RA_XXXX: O botão "Guardar" deve ser ocultado caso a entidade já se encontre consolidada na base de dados.`

---

### ⚖️ Teste de Mesa — Heurística de Decisão

Sempre que houver dúvida, aplique o Teste da API vs Ecrã:

- Se eu testar esta regra usando apenas o Postman (sem interface gráfica), ela continua a existir e a bloquear/permitir a ação? **Sim → É uma RN.**
- Esta regra serve apenas para não deixar o utilizador perder o que digitou, ou para ele não clicar no sítio errado? **Sim → É uma RA.**

---

### MSG — Mensagem do Sistema (Heurísticas de Feedback)

São as respostas literais devolvidas ao utilizador.

**Deve conter sempre:**
- Tipo da mensagem (GERAL - ERRO / GERAL - Aviso / GERAL - Sucesso / INDIVIDUAL / GERAL).
- O contexto ou gatilho de disparo.
- O texto literal ("string") que será renderizado.

---

## 3. Formato de Saída Obrigatório

### Bloco RN

```
RN_XXXX: <Título Conciso da Regra (Sem citar botões ou abas)>

<Descrição detalhada da política de negócio com foco na entidade e na base de dados.>
<Use marcadores (-) para detalhar pré-condições ou transições de estado.>
<Referencie outras regras quando necessário: RN_XXXX: Nome da Regra>
<Referencie mensagens de rejeição ou sucesso: MSG_XX: Nome da Mensagem>
```

### Bloco RA

```
RA_XXXX: <Título Conciso da Regra>

<Descrição do comportamento do estado da UI (sessão, botões, visibilidade).>
<Use marcadores (-) para detalhar os gatilhos visuais.>
<Referencie a MSG correspondente ou a RN que dita o bloqueio.>
```

### Bloco MSG

```
MSG_XX: <Título da Mensagem>

Tipo: Mensagem <GERAL - ERRO | GERAL - Aviso | GERAL - Sucesso | INDIVIDUAL>.

O texto para <ação específica ou falha de validação> é:
"<Texto exato da mensagem que o sistema exibe>"
```

---

## 4. Convenções de Estilo e Boas Práticas

- **Alta Coesão:** Uma RN não fala sobre ecrãs. Uma RA não fala sobre validações definitivas de base de dados.
- **Voz Passiva ou Imperativa:** Mantenha um tom impessoal ("O sistema deve", "É bloqueado").
- **Tipagem Dinâmica nas MSGs:** Utilize chaves angulares, ex: `"A turma <Nome_Turma> foi criada."`

---

## 5. Processo Lógico de Geração

1. **Analise a solicitação:** Leia o fluxo.
2. **Isole o Domínio (Backend/Negócio - RN):** Extraia as políticas, validações de API e integridade da entidade. Remova qualquer menção a botões, sessões ou cliques.
3. **Isole a Apresentação (Frontend/UX - RA):** Extraia o comportamento do ecrã, rascunhos em sessão, desabilitação de elementos e navegação.
4. **Isole o Feedback (Textos - MSG):** Identifique os alertas.
5. **Gere os blocos e vincule-os com referências cruzadas.**
6. **Resumo Executivo:** Finalize com um resumo quantitativo do que foi gerado.

---

## 6. Revisão Cautelosa Automática (Self-Correction)

Antes de gerar o output final, releia todas as RN_ geradas. Se encontrar palavras do "Vocabulário Proibido" (botão, aba, sessão, ecrã, clicar, campo, exibir, exibição, tempo real), reescreva a RN focando apenas no modelo de dados, ou mova a parte de exibição/reatividade para uma RA_.

Checklist específico por regra gerada:
- A RN cita "campo"? Reescreva usando o nome do atributo/entidade (ex: "Prazo de Vigência da entidade Contrato"), não "o campo X".
- A RN descreve "onde" ou "quando" algo aparece na tela, ou recálculo "em tempo real"? Isso é RA — mova.
- A RN sobrevive ao Teste de Mesa (Postman, sem tela)? Se a resposta exigir mencionar exibição/atualização visual, ela não sobrevive — quebre em RN (cálculo/regra) + RA (exibição/reatividade).