---
name: prototype-prints
description: >
  Captura as prints do protótipo (prototype/) que entram na seção Protótipo do documento
  de uma demanda — o .md consolidado da demanda e o .docx gerado a partir dele.
  Define o recorte a partir da documentação da demanda (não do git diff), organiza as prints
  por fluxo, e captura com Playwright em dimensões adequadas para página A4: telas longas em
  partes contínuas, componentes no próprio limite e todas as imagens com borda fina. Use
  quando o usuário pedir prints, screenshots ou imagens do protótipo para
  documentação — "tira as prints da #NNN", "preciso das telas pra colocar no docx",
  "salva as imagens do protótipo". Não use para export pro Figma (é html-to-figma) nem
  para criar/ajustar tela (é design-screen).
acao:
  id: capturar-prints
  rotulo: Capturar prints
  descricao: captura as prints do protótipo para a documentação
objetivo: Ilustrar uma demanda com as imagens que dizem algo sobre ela, em vez de um álbum do protótipo inteiro.
entrega:
  - PNGs numerados em `{caminhos.pasta_por_demanda}prototipo-prints/`, na ordem de leitura
  - seção Protótipo do `.md` com um heading por print lógica e o link da rota por fluxo
portoes:
  - sem documentação da demanda → PARA e pede; sem ela não há critério de recorte
  - propõe destino, lista numerada e o que fica de fora, e espera o aval antes de capturar
  - apagar print já entregue também pede confirmação
produz:
  id: prints-capturadas
  rotulo: Prints do protótipo
requer:
  - prototipo-validado
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo: Como fazer
    ajuda: Como sua empresa escolhe o recorte das prints e em que ordem elas aparecem.
    tipo: texto-longo
  secao-prototipo:
    caminho: references/secao-prototipo.md
    rotulo: Seção Protótipo do documento
    ajuda: Como a seção de prints é montada no documento — legenda, agrupamento por fluxo e tamanho das imagens.
    tipo: texto-longo
---

# prototype-prints

> **Camadas:** restrições em `system/CONSTITUTION.md` (write-gate: propor o recorte antes de
> capturar). Estrutura da seção de protótipo no `.md`: `references/secao-prototipo.md`.
> Mecânica e medidas da captura: `references/captura.md`.

Transforma o protótipo em um conjunto de imagens que ilustram **uma demanda específica** dentro do documento dela.

O erro que esta skill existe pra evitar não é técnico. É de recorte: capturar tudo que a tela mostra, ou tudo que o commit mudou, e entregar um álbum onde metade das imagens não diz nada sobre a demanda. Documento com print supérfluo declara de novo o que já estava entregue, e o leitor perde a referência do que mudou.


**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.

## 0. Pré-requisitos

- `prototype/` roda (`npm run dev`).
- Existe documentação da demanda em `{caminhos.pasta_por_demanda}*.md`. **Sem ela, pare e peça** — sem a doc não há critério de recorte, e o resultado vira álbum.
- Chrome instalado. Playwright usa o Chrome do sistema via `channel: 'chrome'`; **não** baixe browser.

Instale o Playwright fora do repositório, no diretório de scratchpad da sessão:

```bash
cd "$SCRATCHPAD" && npm init -y && npm i playwright
```

Nunca adicione Playwright ao `prototype/package.json` — a captura é ferramenta de sessão, não dependência do protótipo.

## 1. Propor antes de capturar

Write-gate. Antes de rodar qualquer coisa, apresente:

- pasta de destino
- lista numerada, agrupada por fluxo, uma linha por print
- quais telas longas serão divididas em partes contínuas para caber no DOCX
- o que ficou **de fora** e por quê — esta parte é a que o usuário revisa de verdade

Espere o "pode". Apagar print já entregue também pede confirmação.

## 2. Capturar

Destino:

- pasta com um único documento formal: `{caminhos.pasta_por_demanda}prototipo-prints/`;
- pasta com várias HUs/HTs: `{caminhos.pasta_por_demanda}prototipo-prints/{IDENTIFICACAO}/`
  (ex.: `prototipo-prints/HU08.02/`).

Em pastas com várias HUs/HTs, a numeração é local a cada documento (`01..NN`). Uma imagem
reutilizada por mais de uma HU deve existir na subpasta de cada uma, com o número correspondente
ao heading daquela HU. A ação `gerar-documento-final` escolhe a subpasta pela identificação nos metadados.

Se a demanda tem número de issue diferente do número no nome da pasta (issue guarda-chuva, tarefas filhas), **pergunte** onde salvar antes de criar diretório. Prints longe do documento se perdem.

Nomeie `NN_kebab-descricao.png`. O número é a ordem de leitura, não a ordem de captura.

**Mecânica em `references/captura.md`** — configuração do browser, divisão de tela longa em
partes para a página A4, borda obrigatória, recorte de modal/card/tabela, dropdown e estado
que o mock não alcança. As medidas de lá são contrato da imagem entregue, não sugestão.

## 3. Verificar

Abra as prints de estado condicional — bloqueio, contagem, status calculado. É onde a captura silenciosamente pega o estado errado: um seletor que casou com a linha errada da tabela, um modal que abriu na variante oposta.

Confira também que nenhum print de modal saiu com o fundo da página junto.

Para telas divididas, verifique ainda:

- largura idêntica em todas as partes;
- altura `largura × 1,10` nas partes completas;
- continuidade exata entre o último pixel de uma parte e o primeiro da seguinte;
- ausência de margem, sobreposição, reamostragem ou conteúdo perdido;
- borda preta interna de 1 pixel em cada arquivo;
- última parte sem preenchimento artificial.

## 4. Escrever os títulos na seção Protótipo do `.md`

A **estrutura concreta** dessa seção (numeração, onde os links entram, se são duplicados
noutra seção) é formato de documento — vive em `references/secao-prototipo.md`, que a
organização sobrescreve. **Leia esse arquivo antes de escrever.**

O que vale em qualquer formato:

- **Um heading por print lógica.** Partes `10a`, `10b` e `10c` da mesma tela ficam juntas
  sob esse único heading, na ordem, para parecerem uma captura contínua no documento final.
- **Só o título descritivo** no heading. Nada de nome de arquivo, caminho, "Figura NN" ou
  legenda — o título diz o que a tela mostra.
- **Deixe o espaço em branco** sob cada heading: é ali que o `doc-final-generator` insere a
  imagem, quando a implementação ativa do provider `docs-output/` tem a capacidade
  `image-embed`. Sem essa capacidade, os títulos e links continuam válidos e as imagens
  entram à mão — avise o usuário.
- **Link da rota por fluxo**, apontando para a tela do protótipo publicado. A base sai de
  `project-config.yaml`; a rota, do fluxo. Fluxos que acontecem na mesma tela repetem a
  mesma URL — não force rotas diferentes só para variar. Rota com parâmetro
  (`/<recurso>/<id>`, `/<rota>?<param>`) aponta para registro do mock: confira que o id
  existe e que os query params necessários para abrir o estado certo estão na URL.
- **Escreva só títulos e links.** Não insira imagem no `.md` e não gere o documento final —
  é passo separado, do `doc-final-generator`.

## 5. Entregar

Liste o resultado agrupado por fluxo, e declare:

- o que ficou de fora e por quê
- qualquer patch de mock que precisou existir (já revertido)
- limitação que restou na imagem — dropdown fechado, componente cortado, dado mockado que não representa produção

Encerre o servidor Vite que você subiu.

## Fronteira

- **Faz:** escolher o recorte a partir da documentação, capturar e nomear as imagens, entregá-las ao lado do `.md` da demanda, e escrever a seção de protótipo do `.md` (títulos das prints + link da rota por fluxo) conforme `references/secao-prototipo.md`.
- **Não faz:** inserir a imagem no `.md`; gerar o documento final (é `doc-final-generator`);
  ajustar tela do protótipo (é `design-screen`); exportar pro Figma (é `html-to-figma`).

Se durante a captura você notar que a tela está errada em relação à documentação, **reporte** — não corrija de passagem. Corrigir tela é `design-screen`, com plano próprio.
