# Exemplos de referência (padrão do pack)

Calibragem de tom e de nível de detalhe. A organização sobrescreve este arquivo em
`org/workflows/doc-final-generator/references/exemplos.md`, normalmente com trechos de
documentos que ela já entregou.

**Exemplo não é fonte de conteúdo.** Os trechos abaixo são neutros e servem para comparar
forma. Nada daqui entra num documento gerado.

## Critério de aceite

> **CA03:** **Dado que** o registro está em rascunho, **Quando** quem edita confirma o
> envio, **Então** o registro passa a aguardar aprovação e deixa de aceitar edição. [RN02]
> [MSG01]

Nível: um cenário, com gatilho e resultado observável. Sem "o sistema deve", sem nome de
componente de tela.

## Regra de negócio

> **RN02** — É necessário que registro aguardando aprovação não aceite alteração de
> conteúdo.

Nível: uma frase declarativa, sobre entidade do negócio. Sem passo a passo e sem operador de
código.

## Mensagem

> **MSG01** (sucesso) — "Registro enviado para aprovação em <data_envio>."

Nível: severidade mais o texto exato que aparece na tela, com marcador explícito no lugar do
valor variável.
