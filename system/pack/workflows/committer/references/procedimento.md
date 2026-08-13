# Procedimento padrão — versionar mudanças (pack)

Passo a passo default da ação `versionar-mudancas`. A organização sobrescreve este arquivo em
`org/workflows/committer/references/procedimento.md`.

As regras duras, a lista de arquivos sensíveis, o portão do Plano de Commit e os checks
anteriores a cada commit são da moldura e valem junto com o que estiver aqui.

## 1. Levantar contexto e classificar arquivos

```bash
git status
git branch --show-current
git diff --stat
git diff --name-only
git diff --staged
```

Classifique cada arquivo mudado numa camada. A tabela abaixo é o default do harness — **confira o que o repositório realmente tem** (`git diff --name-only`) e ajuste as camadas ao projeto antes de montar o plano:

| Camada | Padrão | Exemplos |
|---|---|---|
| **Harness** | `.agents/**` | `.agents/system/**`, `.agents/org/**`, `.agents/runtime/**`, `.agents/docs/**` |
| **Docs/Contexto** | `docs/**`, `history/**`, `outputs/**`, `project-config.yaml` | documentos em `outputs/<feature>/*.md`, base de contexto, `history/discoveries/*.md` |
| **Protótipo** | `prototype/src/**`, `prototype/public/**` | `prototype/src/routes/**`, `prototype/src/components/**`, `prototype/src/mock/**` |
| **Config raiz/protótipo** | `prototype/package.json`, `prototype/*.config.*`, `prototype/tsconfig.json`, `AGENTS.md`, `CLAUDE.md`, `.env.example`, `install.sh` | mudança de dependência, tooling, override local |

Camadas que o projeto tiver e não estão aqui (código de aplicação, migrations, testes, infra) entram como camadas próprias — a ordem dos commits segue a mesma lógica: base primeiro, entregável depois.

Ordem default dos commits do plano: Harness → Docs/Contexto → Protótipo → Config.

## 2. Revisar mudanças

- Se Modo A: confira `### Tasks` (checkboxes `[x]`) e `## Evidence` no arquivo de tarefa.
- Releia o diff de cada arquivo sensível-adjacente (config, `.env.example`) antes de incluir no plano.

## 3. Craft da mensagem (Conventional Commits)

```
<type>(<scope>): <subject>
```

| Type | Uso |
|---|---|
| `feat` | Funcionalidade nova |
| `fix` | Correção de bug |
| `docs` | Só documentação (requisito, regra, contexto, history) |
| `refactor` | Mudança de código sem feature/fix nova |
| `style` | Formatação, sem mudança de comportamento |
| `chore` | Manutenção, dependências, tooling |
| `test` | Teste (quando existir suite) |

**Scope:** opcional — área afetada (`harness`, `docs`, `protótipo`, `design`…). **Siga o padrão do histórico do repositório** (`git log --oneline -20`): se o projeto omite scope, omitir também é correto. Prefira scope quando a camada não for óbvia pelo tipo.

**Subject:** modo imperativo ("adiciona" não "adicionado"), sem ponto final, conciso.

## 4. Executar commits (após aprovação)

Antes do primeiro commit: se estiver em `main`/`master`, **sugira** criar branch:

```bash
git checkout -b <type>/<slug>
```

Se o usuário recusar e pedir pra ir direto na main, siga sem branch — não é bloqueio, é sugestão.

Por commit do plano, em ordem:
```bash
git add <arquivo1> <arquivo2>     # NUNCA -A nem .
git commit -m "<type>(<scope>): <subject>"
git log -1 --oneline
git show HEAD --stat
```

## 5. Push

```bash
git push -u origin "$(git branch --show-current)"
```

Push em main/master permitido se foi essa a escolha do usuário — proteção de branch, se existir, é o GitHub quem barra.

- Rejeitado (non-fast-forward): `git pull --rebase origin "$BRANCH"`, depois push de novo.
- Force push: sempre avise e confirme antes — mais arriscado ainda em main/master (pode sobrescrever histórico de outros). Force só em branch pessoal que ninguém mais puxou: `git push --force-with-lease`.

## 6. Pull Request

```bash
gh pr create --title "<type>(<scope>): <description>" --body "$(cat <<'EOF'
## Summary
- <bullet 1>
- <bullet 2>

## Test plan
- [ ] <item>
EOF
)"
```

- Referencie issue original (`Closes #<num>`) se houver.
- Título curto (<70 char), corpo com o resumo do plano de commit.

## 7. Atualizar arquivo de tarefa (Modo A)

```markdown
## Status: READY_TO_COMMIT → DONE
```
