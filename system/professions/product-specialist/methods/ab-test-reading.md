# Leitura de teste A/B

## Quando usar / quando não

- Use ao interpretar resultado de experimento com grupo de controle.
- Não use quando o teste não tem tamanho para detectar o efeito que importa — nesse caso a
  decisão é qualitativa, e dizer isso é mais honesto que exibir percentual.

## Barra de qualidade

- **Efeito mínimo relevante definido antes**; resultado "positivo" menor que ele é ruído
  útil para ninguém.
- Nada de olhar e parar quando ficou bom: espiar até dar significância fabrica vitória.
- Métrica de decisão única, definida antes. As outras são diagnóstico e não viram a
  conclusão.
- Contrapeso verificado: o que piorou enquanto a principal subiu.
- Resultado inconclusivo é resultado — a ação combinada vale, sem reinterpretação.
- Efeito relativo sempre acompanhado do absoluto: "+30%" sobre base ínfima é nada.

## Contrato de output

Métrica de decisão, efeito absoluto e relativo, intervalo · contrapesos · veredito
(adotar, descartar, inconclusivo) e a ação combinada · o que o teste não responde.
