# Formato do changelog (padrão do pack)

Formato default. A organização sobrescreve em
`org/workflows/changelog-generator/references/formato.md`.

```markdown
# Changelog — [PROJETO]

| Data | Demanda | Descrição da mudança | Impacto |
| :--- | :--- | :--- | :--- |
| DD/MM/AAAA | #NNN | **[TIPO] Título:** o que mudou para o usuário. | Telas/módulos afetados |
```

`[PROJETO]` vem de `identidade.projeto` (`project-config.yaml`); o título do documento,
quando a organização usa outro (ex.: "Histórico de Evolução"), é declarado em `org/ORG.md`.

### Regras

- Ordenado por data decrescente — entrada nova entra no topo.
- `TIPO` vem da taxonomia da organização (default do pack: Novo, Melhoria, Correção).
- Descrição em prosa curta, do ponto de vista de quem usa o produto.
- Campo sem dado confirmado fica com o marcador de vazio da organização (`org/ORG.md`);
  sem marcador declarado, use `[a definir]` — nunca preencha por suposição.
