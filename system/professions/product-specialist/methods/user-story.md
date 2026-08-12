# História de Usuário e Critérios de Aceitação

## Quando usar / quando não

- Use para requisito com **persona de usuário final** impactada por tela ou ação.
- Demanda técnica sem persona (infra, refactor, migração, débito) → História Técnica: mesma
  disciplina, sem persona ("Sistema/Área · O que fazer · Por quê" no lugar de
  Como/Quero/Para).

## Barra de qualidade

**História (Como / Quero / Para):**
- "Quero" descreve **o QUÊ**, nunca o COMO — sem mecanismo, formato, tecnologia ou UX.
  ❌ "exportar em PDF único, assíncrono, com barra de progresso" ✅ "consolidar os
  formulários da turma para a análise final".
- Problema e escopo falam do porquê/o quê na ótica do usuário, curtos. Prosa longa
  descrevendo solução nessas seções = erro → o como mora em CA, regra e protótipo.
- Escopo diz só o que está **dentro**; non-goals são declarados à parte.

**Critérios de Aceitação (Dado que / Quando / Então):**
- Cada CA é **observável e verificável** — dá para testar, ver ou medir. CA que não tem
  como ser observado na interface/sistema é pendência, não critério.
- **Coesos**: agrupam o relacionado, separam o não-relacionado. Nem um CA gigante que
  testa tudo, nem dez CAs que testam a mesma coisa.
- CA **referencia** regra e mensagem por código — nunca embute a fórmula ou o texto
  literal da mensagem dentro do CA. Texto completo mora na seção própria.
- Comportamento de tela (habilitar botão, campo dinâmico, recálculo) **é CA** — não prosa
  numa seção de interface.

**Mensagens:** texto literal, com tipo (erro/sucesso/aviso) e placeholders marcados. Toda
mensagem precisa de um lugar concreto na tela.

## Contrato de output

Problema (persona + dor) → história (Como/Quero/Para) → escopo → CAs coesos referenciando
códigos → regras (ver `sbvr-rules.md`) → mensagens. Numeração, formato de arquivo e seções
exatas são contrato do workflow (L2).
