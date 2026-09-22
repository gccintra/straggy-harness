# Código-fonte

Ambiente local do código do produto. O Git deste repositório versiona só este README. Tudo em `repos/` fica de fora: clones, credencial e o que for criado ali.

Os repositórios estão no `project-config.yaml`, no bloco `codigo_fonte`:

- `caminho` — pasta local dos clones. O padrão do instalador é `codigo-fonte/repos/`.
- `repositorios` — lista de `nome` e `url`. A `url` é um remoto Git, em qualquer host. Lista vazia: ninguém inventa remoto.

No modo aplicativo, o formulário do projeto grava esse mesmo bloco. Quem lê é o arquivo.

## Credencial

`repos/.git-credentials` guarda o acesso aos remotes da lista, nesta máquina. Cada clone em `repos/` usa um helper vazio — isso descarta o helper do sistema, no Mac o Keychain — e em seguida o `store` apontando para esse arquivo. `~/.gitconfig` não participa.

O arquivo não entra no Git. Segredo não entra no `project-config.yaml`. No modo aplicativo, o cofre é o lugar da credencial.
