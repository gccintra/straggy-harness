# Configuração do Projeto — Pipeline de Documentação (HU / HT / Regras)

Arquivo **único** (na raiz do projeto) que guarda tudo que é específico do projeto. Criado pelo
`.agents/install.sh` a partir deste template — **preencha antes de usar as skills**.

Lido por: `doc-consolidator`, `hu-generator`, `ht-generator`, `changelog-generator`,
`prototype-deploy` e `committer`. Fica na raiz para funcionar com qualquer CLI/agente.

**Como usar:** preencha os valores após cada `:`. **Campo em branco → a skill usa o placeholder
indicado** (`[ASSIM]`) no documento gerado, para completar depois.

---

## Identidade

- **Cliente:**
  <!-- vazio → placeholder [CLIENTE] -->
- **Projeto:**
  <!-- nome + descrição curta | vazio → placeholder [PROJETO] -->
- **Token de arquivo:**
  <!-- usado no nome do arquivo: {HU|HT}{ID}_{TOKEN}_{NomeCurto}.docx | vazio → PROJ -->
- **Responsável padrão:**
  <!-- vazio → placeholder [RESPONSÁVEL] -->
- **Ordem de Serviço padrão:**
  <!-- normalmente vem da issue; vazio → perguntar ou placeholder [OS] -->

## Recursos

- **URL base das issues:**
  <!-- ex: https://gitlab.exemplo.com/grupo/projeto/-/issues/ | vira o campo `issue_url` do frontmatter; vazio → placeholder [ISSUE_URL_BASE] -->
- **Service account do sync (compartilhar pastas/doc do Drive — papel Leitor):**
  `rclone-drive@gen-lang-client-0520101386.iam.gserviceaccount.com`
  <!-- mesmo robô p/ todos os projetos; ver .agents/SYNC_SETUP.md -->

> **Logo do header:** NÃO fica aqui — fica dentro de cada skill geradora, em
> `.agents/skills/{hu-generator,ht-generator}/assets/header_logo.png` (PNG ~730×61 px).
> Substitua pelo logo do projeto. Ausente → header sai só com o texto, sem logo.

## Caminhos (saídas e fontes)

- **Pasta por issue (regras + .md + .docx juntos):** outputs/{ID}_{NomeCurto}/
  <!-- ex: outputs/855_Multi-Selecao-Conselho/ contendo o {HU|HT}{ID}_{TOKEN}_{Nome}.md e o .docx -->
- **Versionamento de outputs:** somente arquivos `.md`; `.docx` e demais artefatos são regeneráveis e não entram no Git.
- **Regras (fonte da verdade / numeração):** docs/context_docs/regras/

## Deploy do protótipo

Lido pela skill `prototype-deploy` para gerar o `prototype/deploy.sh` e a config do servidor.
Preencha quando for publicar o protótipo; até lá, a skill pergunta.

- **Domínio:**
  <!-- ex: projeto.suaempresa.tech — precisa de registro A apontando pra VPS antes do certbot -->
- **Host SSH da VPS:**
  <!-- ex: root@suaempresa.tech -->
- **Web root:**
  <!-- ex: /root/production/<projeto>-proto/dist — siga a convenção que os outros sites da VPS já usam -->
- **Usuário do basic auth:**
  <!-- protótipo tem fluxo e dado de cliente: basic auth é obrigatório, senha fora do Git -->
- **Porteiro HTTP da VPS:**
  <!-- quem ocupa as portas 80/443: nginx no host / Traefik / Caddy. A skill descobre se estiver vazio. -->

## Padrão de documentação

- **Marca/Padrão (texto livre):**
  <!-- aparece em títulos internos das skills; vazio → "Padrão do Projeto" -->
- **Label header HU:** HISTÓRIA DE USUÁRIO
- **Label header HT:** HISTÓRIA TÉCNICA
  <!-- inferidos por `tipo:` no .md; só altere se o padrão do projeto usar outro rótulo -->
