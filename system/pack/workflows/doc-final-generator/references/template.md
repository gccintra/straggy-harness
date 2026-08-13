# Modelo do entregável (padrão do pack)

Leiaute default do documento final. A organização sobrescreve este arquivo em
`org/workflows/doc-final-generator/references/template.md`.

## Estrutura mínima

| Bloco | Conteúdo |
|---|---|
| Identificação | quem recebe, projeto, demanda, responsável, data de emissão |
| Sumário | as seções do documento, na ordem em que aparecem |
| Corpo | as seções da fonte revisada, na mesma ordem e com os mesmos títulos |
| Anexos | o que a fonte declara como anexo, depois do corpo |

Campo de identificação sem valor declarado na configuração do projeto vai com o marcador de
vazio, visível — nunca em branco, nunca preenchido por dedução.

## Regras de leiaute

- **A ordem é a da fonte.** O modelo define aparência, não sequência de conteúdo.
- **Título de seção é o da fonte**, sem renumerar e sem renomear para "ficar melhor".
- Cabeçalho e rodapé repetem em toda página: identificação curta da demanda e número da
  página.
- Imagem entra com o rótulo que a fonte usa, na posição que ela indica; imagem que não cabe
  na página não é recortada — a limitação é relatada.
- Nada que só existe no modelo: rótulo, aviso ou texto padrão que a fonte não tem não entra
  no documento.
