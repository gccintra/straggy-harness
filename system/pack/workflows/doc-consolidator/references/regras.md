# Regras de classificação (padrão do pack)

Como o documento consolidado tipa e numera o que afirma. A organização sobrescreve este
arquivo em `org/workflows/doc-consolidator/references/regras.md`.

## Três tipos, três perguntas

| Tipo | Responde | Só existe se acrescenta |
|---|---|---|
| Critério de aceite | "está pronto? aceito?" | comportamento observável, com gatilho e resultado |
| Regra de negócio | "qual é a política, o cálculo, o limite?" | invariante que vale além do cenário do critério |
| Mensagem | "o que o sistema diz a quem usa?" | o texto literal |

Item que só repete o de cima não é escrito. Regra que reformula um critério é duplicata;
mensagem parafraseada dentro de um critério é mensagem no lugar errado.

## Numeração

- Código curto por tipo, sequencial e sem lacuna: `CA01`, `RN01`, `MSG01`.
- **Local ao documento**: a sequência reinicia a cada demanda documentada.
- Referência é sempre pelo código, nunca por cópia do texto — o critério cita `[RN01]`, e o
  texto da regra existe uma vez só, na seção dela.
- Código já publicado não é reaproveitado para outro conteúdo. Item removido deixa o código
  vago; renumerar quebra o que já foi citado fora do documento.

## Forma de cada tipo

- **Critério**: cenário verificável — contexto, ação, resultado observável. Um cenário
  coerente por critério; condições ligadas à mesma ação cabem juntas.
- **Regra**: frase declarativa do que é sempre verdade, não passo a passo de implementação.
  Fala de entidade e atributo do negócio, não de tela, campo ou botão.
- **Mensagem**: severidade (erro, aviso, sucesso) mais o texto exato, com marcador explícito
  onde entra valor variável.
