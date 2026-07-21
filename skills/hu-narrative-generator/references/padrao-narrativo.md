# Padrão editorial da descrição narrativa

## Objetivo

Produzir uma explicação contínua do comportamento esperado da HU. O texto deve permitir que uma
pessoa compreenda o fluxo, as decisões e os efeitos da funcionalidade sem interpretar uma lista de
critérios ou regras isoladas.

O padrão foi extraído de `outputs/731_Visitas-Multiplos-Tecnicos/HU731_Descricao_Narrativa.md`.

## Estrutura adaptativa

Usar somente os blocos que fizerem sentido para a HU, preferencialmente nesta ordem:

1. Mudança principal, contexto e objetivo.
2. Criação ou entrada no fluxo e estado inicial.
3. Ações que provocam transições de estado.
4. Atores autorizados e limites de permissão.
5. Vínculo, autoria, isolamento e visibilidade dos dados.
6. Regras temporais, sincronização e concorrência.
7. Validações, bloqueios, exceções e resultado dos estados finais.
8. Independência ou impacto sobre processos simultâneos.
9. Relatórios, histórico, congelamento de dados e filtros.
10. Comportamentos complementares de consulta.

Não forçar blocos ausentes na documentação.

## Forma

- Título único: `# HU{ID} — Descrição narrativa`.
- Corpo em parágrafos, sem subtítulos, bullets ou tabelas.
- Primeiro parágrafo: síntese da mudança e do valor esperado.
- Parágrafos seguintes: sequência operacional e dependências entre regras.
- Último parágrafo: comportamento complementar que encerra o fluxo, quando existir.
- Termos de interface com a mesma grafia da fonte, inclusive maiúsculas dos status e ações.
- Português do Brasil correto, direto e sem jargão desnecessário.

## Construção dos parágrafos

Cada parágrafo deve combinar, quando aplicável:

`contexto → ação ou condição → comportamento → consequência → exceção`

Exemplo abstrato:

> Quando [evento] ocorrer, o sistema [comportamento]. Caso [exceção], [tratamento], desde que
> [condição]. Essa ação [efeito ou registro posterior].

O exemplo serve como lógica de composição, não como frase fixa.

## Critérios de qualidade

- **Cobertura:** nenhuma condição, exceção ou consequência relevante desaparece na conversão.
- **Fidelidade:** o texto não amplia nem restringe regras da fonte.
- **Coesão:** uma regra prepara o entendimento da seguinte.
- **Precisão temporal:** termos como antes, durante, depois, imediatamente e retroativamente são
  mantidos quando alteram o resultado.
- **Identidade dos dados:** origem, vínculo, autoria, compartilhamento e persistência ficam claros.
- **Leitura autônoma:** siglas ou entidades específicas recebem contexto suficiente na primeira
  ocorrência, quando a fonte permitir.

## Evitar

- Copiar os critérios de aceitação em sequência e apenas remover sua numeração.
- Repetir a mesma regra em parágrafos diferentes sem necessidade de conexão.
- Criar títulos para cada critério, cenário ou regra.
- Usar frases vagas como “o sistema deverá funcionar corretamente”.
- Substituir status e rótulos oficiais por sinônimos.
- Acrescentar solução técnica, campos, mensagens ou permissões não documentados.
- Ocultar contradições para fazer o texto parecer coeso.
