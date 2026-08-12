# Provider: knowledge — implementação Google Drive + rclone

O Drive é a **fonte de verdade**; `docs/context_docs/` é cache derivado e descartável.
`_raw/` e `md/` nunca se editam à mão — qualquer edição perde no próximo sync.

**Ativa quando** o bloco `GDRIVE_*` do `.env` está preenchido.
**Capacidades:** leitura de corpus (`grep` sobre `md/`), sync incremental one-way.

## Uso

```bash
./sync-context.sh                 # sync completo (download + conversão)
SKIP_RCLONE=1 ./sync-context.sh   # só re-converte o _raw existente
```

Pipeline: `rclone` exporta do Drive para `docs/context_docs/_raw/` (incremental, compara
tamanho+hash) → conversão para `docs/context_docs/md/` espelhando subpastas — `.docx` via
`pandoc`, `.pdf` via `pdftotext`; `.xlsx`/`.pptx`/imagem são copiados como estão (converter
destruiria estrutura). Google Doc exporta como `.docx`, Slide como `.pptx`, Sheet como
`.xlsx`; PDF só como último recurso.

Origens declaradas no `.env`:

| Variável | Origem | Mecanismo | Nome final |
|---|---|---|---|
| `GDRIVE_HUS`, `GDRIVE_OUTROS` | pasta inteira (`root_folder_id`) | `rclone sync` recursivo | espelha subpastas e nomes |
| `GDRIVE_REGRAS_DOC_ID` | 1+ arquivos (IDs separados por espaço) | `rclone backend copyid` | título do doc no Drive |
| `GDRIVE_REFERENCIAS_GLOBAIS_DOC_ID` | arquivo único | `copyid` + conversão dedicada | sempre `Referencias-Globais.md` |

## Setup (uma vez por máquina)

```bash
apt-get install -y pandoc rclone poppler-utils      # ou brew equivalente
```

Autenticação **headless por service account** (token não expira, serve para cron):

1. Google Cloud Console → ative a **Google Drive API** → **IAM & Admin → Service Accounts**
   → criar → **Keys → Add key → JSON**. Guarde o `client_email` do JSON.
2. No Drive, compartilhe as pastas/arquivos com esse `client_email` como **Leitor**. Sem
   isso o robô não enxerga nada — o Drive próprio dele é vazio.
3. Na máquina:
   ```bash
   chmod 600 sa-key.json
   rclone config create gdrive drive scope drive.readonly \
     service_account_file "$PWD/sa-key.json"
   rclone lsd "gdrive,root_folder_id=<ID_DA_PASTA>:"   # teste de acesso
   ```

Agendamento opcional (rede de segurança; sync manual continua sendo o "agora"):

```cron
0 */2 * * * /CAMINHO/ABSOLUTO/sync-context.sh >> /CAMINHO/ABSOLUTO/sync.log 2>&1
```

Cron roda no `$HOME` — caminho relativo no crontab não funciona.

**Segurança:** `sa-key.json` é chave privada — `chmod 600`, nunca versionar, nunca colar em
chat/ticket; `.gitignore` com `sa-key.json` e `docs/context_docs/_raw/`. Escopo sempre
`drive.readonly`. Rotação: apague a chave no Console, crie outra, substitua o arquivo.

## Troubleshooting

| Sintoma | Causa provável | Ação |
|---|---|---|
| `rclone lsd` vem vazio | pasta não compartilhada com o robô | compartilhe com o `client_email` |
| `403 / insufficient permissions` | Drive API desativada ou email errado | ative a API; confira o email |
| Pede `config_token` | caiu no fluxo OAuth | cancele; use `config create ... service_account_file` |
| Cron não roda | caminho relativo no crontab | use caminho absoluto |
| `.md` com `<table>` HTML | tabela docx com células mescladas | normal do pandoc; segue legível e greppável |
| Documento mudou e não atualizou | cron ainda não rodou | rode `./sync-context.sh` |
