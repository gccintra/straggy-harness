# Sincronização Google Drive → Markdown (guia reutilizável)

Como manter documentos do Google Drive (Google Docs nativos, `.docx` ou `.pdf`)
espelhados localmente em **Markdown**, prontos para um agente de IA (Claude Code,
OpenCode etc.) ler com `grep`. Atualiza sozinho via cron.

> Este guia é genérico — serve para qualquer projeto. Os IDs e caminhos usados
> como exemplo são do projeto `websis_itl`; troque pelos seus.

---

## 1. Visão geral

```
Google Drive (FONTE DE VERDADE — você edita aqui)
   │
   │  rclone  (exporta Google Doc → .docx, baixa só o que mudou)
   ▼
docs/context_docs/_raw/        cache binário (.docx/.pdf)  — descartável
   │
   │  pandoc (docx→md) / pdftotext (pdf→md)
   ▼
docs/context_docs/md/          Markdown — o agente lê AQUI
```

Princípios:
- **Drive é a única fonte de verdade.** `_raw/` e `md/` são cache derivado —
  pode apagar e re-sincronizar a qualquer momento.
- **Pull sob demanda.** `rclone` não vigia o Drive; ele compara e baixa quando
  chamado. O **cron** chama de tempos em tempos (a cada 2h aqui).
- **Markdown** porque LLM lê nativo, gasta ~5-10x menos token que parsear docx,
  e é `grep`/`diff`-ável.

---

## 2. Ferramentas (instalar uma vez por máquina)

```bash
apt-get install -y pandoc rclone poppler-utils
# pandoc        : docx → markdown
# rclone        : fala com o Google Drive
# poppler-utils : fornece o pdftotext (pdf → texto)
```

Verifica:
```bash
pandoc --version | head -1
rclone --version | head -1
pdftotext -v 2>&1 | head -1
```

---

## 3. Autenticação: Service Account (sem navegador)

A VPS só tem terminal. O OAuth normal do rclone exige navegador → não serve.
A solução headless é um **service account**: um "robô" Google com email próprio.
Você compartilha as pastas/arquivos do Drive com esse email, e a VPS usa um
arquivo JSON de chave. **Sem navegador, e o token nunca expira** (ideal pra cron).

### 3.1. Criar o service account (no seu PC, com navegador — uma vez)

1. Acesse <https://console.cloud.google.com>.
2. Crie ou selecione um projeto.
3. **APIs & Services → Library** → ative a **Google Drive API**.
4. **IAM & Admin → Service Accounts → Create service account**.
   - Nome: `rclone-drive` (qualquer um). Pode pular roles. → Done.
5. Clique no service account criado → aba **Keys → Add key → Create new key →
   JSON** → baixa o arquivo.
6. Abra o JSON e confirme que tem `"type": "service_account"` e
   `"private_key"`. Copie o valor de **`client_email`**
   (ex.: `rclone-drive@SEU-PROJETO.iam.gserviceaccount.com`).

> ⚠️ O JSON contém uma **chave privada**. Trate como senha: nunca cole em
> chat/ticket, nunca versione no git. Transfira por `scp` ou cole direto no
> arquivo na VPS.

### 3.2. Compartilhar os documentos com o robô

No Google Drive, compartilhe (papel **Leitor**) com o `client_email` do robô:
- a **pasta** que contém os documentos (compartilhar a pasta cascateia pra tudo
  dentro), e/ou
- um **arquivo único**, se for o caso.

Sem esse passo o robô não enxerga nada (o Drive próprio dele é vazio).

### 3.3. Configurar o rclone na VPS (não-interativo, 1 comando)

Salve o JSON na VPS (ex.: `sa-key.json` na raiz do projeto) e restrinja acesso:
```bash
chmod 600 sa-key.json
```

Crie o remote sem nenhum prompt:
```bash
rclone config create gdrive drive \
  scope drive.readonly \
  service_account_file /CAMINHO/ABSOLUTO/sa-key.json
```

Teste o acesso (use o **ID da pasta**, pego da URL
`https://drive.google.com/drive/folders/<ID>`):
```bash
rclone lsd "gdrive,root_folder_id=<ID_DA_PASTA>:"      # lista subpastas
rclone size "gdrive,root_folder_id=<ID_DA_PASTA>:"     # conta arquivos
```
Se listar o conteúdo, o compartilhamento pegou. Se vier vazio/erro de permissão,
revise o email no compartilhamento (passo 3.2) — costuma ser typo no email.

---

## 4. O script de sincronização (`sync-context.sh`)

Fica na raiz do projeto. Edite o bloco do topo com os IDs do seu Drive:

```bash
GDRIVE_HUS="gdrive,root_folder_id=<ID_DA_PASTA>:"   # pasta inteira (recursivo)
GDRIVE_REGRAS_DOC_ID="<ID_DO_ARQUIVO>"              # arquivo único (Google Doc)
```

Dois modos de origem, escolha conforme o caso:

| Origem | Como referenciar | Mecanismo |
|---|---|---|
| **Pasta inteira** (N arquivos) | `root_folder_id` da pasta | `rclone sync` (recursivo, incremental, apaga o que sumiu) |
| **Arquivo único** | ID do arquivo | `rclone backend copyid` (exporta só ele) |

O que o script faz, em ordem:
1. **Baixa** do Drive para `_raw/`, exportando Google Docs nativos → `.docx`
   (`--drive-export-formats docx`). `rclone sync` é incremental: compara
   tamanho+hash, baixa só o que mudou.
2. **Converte** `_raw/ → md/`, espelhando subpastas: `.docx` via `pandoc`,
   `.pdf` via `pdftotext`. Pula arquivos temporários do Word (`~$...`).
3. **Loga** cada conversão com timestamp.

Rodar manualmente:
```bash
./sync-context.sh                 # sync completo (download + conversão)
SKIP_RCLONE=1 ./sync-context.sh   # só re-converte _raw existente (sem baixar)
```

---

## 5. Automação por cron (a cada 2h)

```bash
crontab -e
```
Adicione (use **caminhos absolutos** — o cron roda no `$HOME`, não na pasta do
projeto):
```cron
0 */2 * * * /CAMINHO/ABSOLUTO/sync-context.sh >> /CAMINHO/ABSOLUTO/sync.log 2>&1
```

- `0 */2 * * *` = no minuto 0 de hora em hora par (00h, 02h, 04h…).
- Editou no Drive de manhã → em no máximo 2h o `md/` está fresco, sem você tocar.
- Quer fresco **agora** (antes de uma sessão importante)? Roda `./sync-context.sh`
  na mão. O cron é a rede de segurança; o manual é o "já".

Acompanhar:
```bash
crontab -l         # confere a entrada
tail -f sync.log   # log das rodadas
```

---

## 6. Adaptar para um novo projeto (checklist)

1. Instale as ferramentas (seção 2) — uma vez por máquina.
2. Reutilize **o mesmo service account** (ou crie outro) e compartilhe as novas
   pastas/arquivos com o `client_email` dele.
3. Copie `sync-context.sh` para o novo projeto e ajuste:
   - `BASE` (pasta de saída, se diferente),
   - `GDRIVE_HUS` / `GDRIVE_REGRAS_DOC_ID` com os novos IDs.
4. `rclone config create gdrive ...` aponta pro mesmo `sa-key.json` (vale pra
   todos os projetos da máquina — só precisa fazer uma vez).
5. Rode `./sync-context.sh` uma vez pra validar; depois agende no cron.

---

## 7. Segurança

- **Nunca versione** `sa-key.json` nem cole a `private_key` em chat/ticket. Se
  for repositório git, adicione ao `.gitignore`:
  ```
  sa-key.json
  docs/context_docs/_raw/
  ```
- **Permissão restrita**: `chmod 600 sa-key.json`.
- **Rotação de chave**: se a chave vazar (ou por higiene periódica), em
  Cloud Console → Service Account → **Keys** → delete a chave antiga → crie nova
  → substitua o arquivo na VPS. O setup não quebra; só troca o JSON.
- Use sempre `scope drive.readonly` — o robô só lê, nunca altera seu Drive.

---

## 8. Troubleshooting

| Sintoma | Causa provável | Ação |
|---|---|---|
| `rclone lsd` vem vazio | pasta não compartilhada com o robô | compartilhe com o `client_email` (3.2) |
| `403 / insufficient permissions` | Drive API desativada ou email errado | ative a API (3.1.3); confira o email |
| Pede `config_token` no `rclone config` | caiu no fluxo OAuth (esqueceu o SA) | cancele; use `rclone config create ... service_account_file` (3.3) |
| Cron não roda | caminho relativo no crontab | use caminhos absolutos (seção 5) |
| `.md` com `<table>` HTML | tabela docx com células mescladas | normal — pandoc faz isso; segue legível/greppável |
| PDF não converte | `pandoc` não lê PDF de entrada | PDF usa `pdftotext` (já tratado no script) |
| Mudei o doc e não atualizou | cron ainda não rodou | rode `./sync-context.sh` manual, ou espere o próximo ciclo |

---

## 9. Referência rápida

```bash
# instalar
apt-get install -y pandoc rclone poppler-utils

# configurar auth (1x)
chmod 600 sa-key.json
rclone config create gdrive drive scope drive.readonly \
  service_account_file "$PWD/sa-key.json"

# testar acesso
rclone lsd "gdrive,root_folder_id=<ID>:"

# sincronizar
./sync-context.sh                 # completo
SKIP_RCLONE=1 ./sync-context.sh   # só re-converte

# agendar (crontab -e)
0 */2 * * * /abs/sync-context.sh >> /abs/sync.log 2>&1
```
