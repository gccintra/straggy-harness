# Seção de protótipo no `.md` consolidado (padrão do pack)

Estrutura default. A organização que numera ou distribui as seções de outro jeito
**sobrescreve este arquivo** em
`org/workflows/prototype-prints/references/secao-prototipo.md`.

A ordem das seções acompanha o `.md` do `doc-consolidator`
(`doc-consolidator/references/formato-md.md`) — mudou lá, muda aqui.

```markdown
## 9. Protótipo

### 9.1. <Nome do primeiro fluxo>

**Link:** https://<base>/<rota-do-fluxo>

#### 9.1.1. <O que a primeira print mostra>

#### 9.1.2. <O que a segunda print mostra>

### 9.2. <Nome do segundo fluxo>

**Link:** https://<base>/<outra-rota>

#### 9.2.1. <O que a print mostra>
```

### Regras

| Item | Regra |
|---|---|
| Subseção por fluxo | `###`, numeração acompanhando a seção |
| Heading por print lógica | `####`; partes `a/b/c` da mesma tela ficam sob um único heading |
| Link da rota | uma linha `**Link:** <url>` logo abaixo do `###`, antes dos headings de print |
| Espaço sob o heading | fica em branco — é onde o `doc-final-generator` insere a imagem |
| Conteúdo do heading | só o título descritivo; nada de nome de arquivo ou "Figura NN" |

### Duplicação dos links (quando o formato final não é o `.md`)

Se o documento entregue aos devs é o próprio `.md`, os links da seção de protótipo bastam
onde estão. Se o entregável é outro formato e as imagens só existem lá, o `.md` fica com
uma seção de imagens vazia — nesse caso **repita os links num bloco de complemento**, para
o `.md` continuar útil sozinho:

```markdown
## 10. Complemento de Documentação

**Link do Protótipo de Telas Impactadas:**

- **<Nome do primeiro fluxo>:** https://<base>/<rota-do-fluxo>
- **<Nome do segundo fluxo>:** https://<base>/<outra-rota>
```

Um bullet por fluxo, mesma ordem da seção de protótipo, **mesma URL literal**. Só links —
nada de títulos de print, imagem ou legenda.
