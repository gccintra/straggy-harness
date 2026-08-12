# Leitura do modelo de dados

## Quando usar / quando não

- Use quando a demanda cria, altera ou depende de estrutura de dado existente.
- Não use para responder pergunta de comportamento que a documentação já cobre.

## Barra de qualidade

- Estrutura lida na fonte: tabela, chave, cardinalidade, obrigatoriedade, índice existente.
- Estado real conferido com consulta (contagem, nulos, duplicidade, valores fora do
  domínio) — o modelo permite coisas que a prática já quebrou.
- Divergência entre o que a regra diz e o que o dado mostra é reportada, nunca conciliada em
  silêncio.
- Efeito em histórico avaliado: migração, retrocompatibilidade, relatório que já existe.
- Nome e semântica dos campos ditos em linguagem de negócio, para o PM poder decidir.

## Contrato de output

Estruturas envolvidas com cardinalidade · estado real com as consultas usadas ·
divergências encontradas · impacto da mudança proposta · alerta de migração.
