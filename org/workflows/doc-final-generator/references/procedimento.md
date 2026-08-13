# Procedimento desta organização — gerar documento final

Encaixe `procedimento` da ação `gerar-documento-final`. Substitui o passo a passo padrão do
pack. A moldura — `.md` revisado como pré-requisito absoluto, transcrição mecânica, portão
antes de gerar, correção sempre no `.md` — continua sendo do sistema.

Output é **sempre** um `.docx`. Nunca apenas Markdown.

## Os dois tipos de documento

| Tipo | Quando | Seções |
|---|---|---|
| **HU** — História de Usuário | há persona de usuário final impactada; existe tela ou ação do usuário | 9 |
| **HT** — História Técnica | benefício para sistema/plataforma/time (migração, ambiente, performance, dependências, pipeline, logs), sem usuário final direto | 6: Por que precisamos disso · O que deve ser feito · Escopo · Critérios de Aceite · Dependências e restrições · O que será afetado |

Em dúvida entre os dois: `system/professions/tech-lead/reasoning.md`.

Conteúdo e tom das seções: `references/template.md` e `references/exemplos.md`.

## Fluxo

1. **Localizar o `.md`**: `ls {caminhos.pasta_por_demanda}{HU|HT}*${ID}*`. **Não existe → PARE** e aponte
   a ação `documentar-requisito`. Existe → é a **única fonte de conteúdo**; não releia
   discovery, não reescreva nada.
2. **Divisão**: se a demanda puder virar mais de um documento, pergunte — nunca decida
   sozinho.
3. **Gerar**:
   `python3 generate_doc.py <md> {caminhos.pasta_por_demanda}{HU|HT}{ID}_{TOKEN}_{NomeCurto}.docx`
   O rótulo do header sai do frontmatter (`tipo: HU|HT`); `--label` sobrescreve. Uso
   completo e validação: `system/providers/docs-output/pandoc-docx.md`.
4. **Prints (Seção 8, só HU)**: seção com headings de prints → o script insere as imagens de
   `prototipo-prints/{IDENTIFICACAO}/` ao lado do `.md` (fallback `prototipo-prints/` para
   pastas legadas), agrupadas pelo prefixo numérico (`04a`/`04b` = uma print lógica).
   Divergência entre heading e arquivo **interrompe** a geração.

Cada seção do `.md` vira a seção correspondente do `.docx`; apêndices são cortados.

## Tom

Português formal acessível, voz ativa, termo técnico explicado entre parênteses. Nunca peça
detalhe técnico ao PO (tabela, endpoint) — infira ou deixe aberto para o time.

## Layout

`.docx` errado → conserte o `.md` e regere. Nunca edite o `.docx`, e nunca descreva layout
em prosa: mudou o template, edita-se o `generate_doc.py`.

`assets/header_logo.png` — logo do header (730×61 px). Ausente → header sem logo.

## L3

`project-config.yaml`: `identidade.token_arquivo`, `identidade.responsavel_padrao` (vazio →
placeholder).
