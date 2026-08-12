# Regras de negócio em SBVR

## Quando usar / quando não

- Use para o que carrega **fórmula, política ou invariante** que um CA não expressa:
  cálculo, condição de validade, restrição estrutural.
- Não use para comportamento de tela (isso é CA) nem para texto de feedback (isso é
  mensagem). Regra que só repete um CA em outras palavras não é regra — corte.

## Forma

Frase SBVR em linguagem de negócio:

- *É necessário que…* / *É proibido que…* / *É obrigatório que…*
- *… é calculado como …*

## Barra de qualidade

- **Vocabulário de negócio**: entidade + atributo. Nunca "campo", "botão", "tela",
  "exibir", "em tempo real" — regra descreve o domínio, não a interface.
- **Autocontida**: a frase carrega a regra inteira (fórmula completa, condição completa).
  Título que repete a frase é redundância — a frase basta.
- **Uma invariante por regra.** Duas condições independentes = duas regras.
- **Local por padrão**: regra nasce no escopo da demanda. Promover a global exige prova de
  reúso real (2+ consumidores documentados) ou natureza estrutural (enum/status/fluxo do
  sistema) — nunca por suposição de que "outros vão usar".

## Contrato de output

Lista de frases SBVR numeradas, referenciáveis por código a partir dos CAs. Esquema de
numeração e onde o texto vive são contrato do workflow (L2).
