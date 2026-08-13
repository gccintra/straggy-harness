# Procedimento padrão — capturar prints (pack)

Passo a passo default da ação `capturar-prints`. A organização sobrescreve este arquivo em
`org/workflows/prototype-prints/references/procedimento.md`.

## Definir o recorte — a documentação manda, não o `git diff`

Leia o `.md` consolidado da demanda. Ele é o contrato do que foi entregue.

**Por que não o diff:** o commit de uma demanda carrega junto refino de protótipo que ninguém pediu — um formulário reescrito, um componente trocado por lib, espaçamento arrumado. Isso mudou no código e **não** é escopo da demanda. Print desse refino entra no documento afirmando uma entrega que não existe.

**Por que o diff ainda serve:** como *rede*, no fim. Depois de montar a lista pela doc, olhe o diff e pergunte "mudou algo aqui que a doc declara e eu não capturei?". Nunca o contrário.

Critério, um por print:

> Esta imagem mostra algo que a demanda **declara**? Ou mostra a mesma interface que já existia antes dela?

O segundo caso sai. Sempre.

Três armadilhas recorrentes:

- **Formulário de cadastro.** Costuma ter mudado bastante no código e nada na demanda. Se a regra nova é sobre *vínculo, autoria ou visibilidade* do registro, ela não aparece no formulário — aparece no card, na listagem, no badge de origem. Capture onde a regra é visível.
- **Mesmo componente em dois contextos.** Um filtro que abre no painel A e no painel B gera duas imagens idênticas se o estado visível for o mesmo. Fique com uma, a do contexto que a documentação nomeia.
- **Modal de bloqueio já existente.** Mudar o texto de um aviso não é entrega. Mudar a *regra* que dispara o aviso é — e nesse caso o print vale, porque o número/mensagem na tela reflete o novo critério.

## Ordenar por fluxo

Monte a lista na ordem da seção **Escopo** da documentação — é a jornada que o leitor vai percorrer.

**Não organize por critério de aceitação.** Mapear CA → print produz duplicata (o mesmo modal atende três CAs), produz print fragmentado que ninguém entende solto (um card isolado, um modal que existe só para uma regra de cálculo), e ordena a leitura pela numeração dos CAs em vez da jornada.

Mas **use o mapa CA → print como checklist silencioso**, uma vez, antes de fechar a lista. Ele é bom exatamente no que a leitura por fluxo é fraca: achar buraco. CA sem nenhuma imagem correspondente é sinal de print faltando — ou de critério que não tem reflexo em tela, e aí vale mencionar ao usuário.

Agrupe em 4-7 fluxos, cada um com título curto. Prints numerados corridos, `01`..`NN`, atravessando os fluxos.

## Renumerar sem colidir

Cortar prints no meio da lista renumera o resto, e `mv 12 → 07` sobrescreve quando `07` ainda existe. Use diretório de staging:

```bash
mkdir -p .tmp
mv 12_<descricao>.png .tmp/07_<descricao>.png
# ...demais
mv .tmp/* . && rmdir .tmp
```

Não desloque os números das prints seguintes só porque uma tela longa foi dividida. Preserve o
número lógico e acrescente letras às partes (`10a`, `10b`, `10c`).
