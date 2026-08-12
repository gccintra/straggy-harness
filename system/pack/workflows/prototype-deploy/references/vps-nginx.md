# Receita de hospedagem — VPS com nginx (padrão do pack)

Implementação default do contrato do `SKILL.md`. Outro alvo de hospedagem (PaaS estático,
bucket + CDN, cluster interno) → a organização sobrescreve este arquivo em
`org/workflows/prototype-deploy/references/vps-nginx.md`.

Valores entre `{}` saem do bloco `prototipo_deploy` do `project-config.yaml`.

## 1. Identificar o porteiro HTTP

```bash
sudo ss -tlnp | grep -E ':80 |:443 '
docker ps
systemctl is-active nginx caddy
```

| Quem responde na 80/443 | Caminho |
|---|---|
| `nginx` no host | §2 — novo server block. **Caso mais comum.** |
| Traefik / nginx-proxy / caddy-docker (container) | §6 — novo serviço no compose com label/rede |
| Caddy no host | §6 — bloco novo no Caddyfile |
| Nada | servidor limpo: instale nginx e siga §2 |

## 2. Server block (nginx no host)

Comece **HTTP-only**. O certbot injeta o bloco SSL depois — escrever caminho de certificado
que ainda não existe faz `nginx -t` falhar e trava o passo seguinte.

```nginx
server {
    listen 80;
    server_name {DOMINIO};

    root {WEB_ROOT};
    index index.html;

    auth_basic           "Restrito";
    auth_basic_user_file /etc/nginx/.htpasswd-{PROJETO};

    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # index.html nunca cacheia — senão deploy novo não aparece no browser
    location = /index.html {
        add_header Cache-Control "no-cache";
    }

    # SPA fallback: rota profunda cai no index.html
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

Hash no nome do asset (`index-CXRaHnrN.js`) é o que torna o `immutable` seguro: build novo
gera nome novo. Por isso o `index.html` — que aponta para os hashes — é o único que não
pode cachear.

### Ativar

```bash
sudo htpasswd -c /etc/nginx/.htpasswd-{PROJETO} {USUARIO}   # peça a senha ao usuário
sudo ln -s /etc/nginx/sites-available/{PROJETO} /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d {DOMINIO}                            # escolha o redirect HTTP→HTTPS
```

Depois do certbot: **releia o arquivo**. Ele reescreve o server block, e vale confirmar que
`auth_basic` e `try_files` sobreviveram.

### Permissão do web root

nginx roda como `www-data` e precisa de **read + execute em todo o caminho** até o `dist/`.
Web root debaixo de `/root` tende a dar 403, porque `/root` costuma ser `700`.

```bash
namei -l {WEB_ROOT}
```

Outro site já serve estático do mesmo lugar → **replique a permissão dele**. Não afrouxe
`/root` sem falar com o usuário: é diretório de sistema, e afeta muito mais que o protótipo.

## 3. DNS — antes do certificado

Registro **A** `{DOMINIO}` → IP do servidor, **propagado antes** do certbot. Sem isso o
desafio HTTP falha e a tentativa conta no rate limit (5 por semana por domínio).

```bash
dig +short {DOMINIO}
```

Não retornou o IP → **pare** e avise. Não siga "pra ver se passa".

## 4. Script de publicação

Gere `prototype/deploy.sh` com os valores do `project-config.yaml`:

```bash
#!/usr/bin/env bash
set -euo pipefail

VPS_HOST="${VPS_HOST:-{HOST_SSH}}"
VPS_PATH="${VPS_PATH:-{WEB_ROOT}}"

cd "$(dirname "$0")"

echo "==> Build"
npm ci
npm run build

echo "==> Enviando para ${VPS_HOST}:${VPS_PATH}"
ssh "$VPS_HOST" "mkdir -p '$VPS_PATH'"
rsync -avz --delete dist/ "${VPS_HOST}:${VPS_PATH}/"

echo "==> Recarregando nginx"
ssh "$VPS_HOST" "nginx -t && systemctl reload nginx"

echo "==> Pronto: https://{DOMINIO}"
```

`chmod +x prototype/deploy.sh`.

**`--delete` é intencional**: sem ele, asset velho com hash antigo fica órfão no servidor
para sempre. Mas ele apaga tudo que estiver no destino e não estiver no `dist/` — confirme
que o web root serve **só** o protótipo antes da primeira execução.

### Artefato de build fora do Git

```
node_modules/
dist/
tsconfig.tsbuildinfo
```

Já trackeados: `git rm -r --cached prototype/dist prototype/tsconfig.tsbuildinfo`. Confira
antes se `dist/` tem algo que **não** é derivado de `src/`/`public/` — se tiver, é bug de
outra coisa, não destrackeie por cima.

## 5. Validação

```bash
curl -I https://{DOMINIO}                        # 401 — autenticação ativa
curl -I -u {USUARIO}:{SENHA} https://{DOMINIO}   # 200 (ou 404 se o dist ainda não subiu)
curl -I -u {USUARIO}:{SENHA} https://{DOMINIO}/alguma/rota/interna   # 200, não 404
```

## 6. Outros porteiros

**Traefik / nginx-proxy / caddy-docker** — o protótipo vira um `nginx:alpine` com o `dist/`
dentro, registrado no proxy pelo padrão que os outros serviços já usam (label, rede,
variável de ambiente — leia o compose deles). O SPA fallback continua necessário, agora no
`nginx.conf` de dentro do container.

```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
```

**Caddy no host** — bloco novo no Caddyfile; TLS é automático:

```
{DOMINIO} {
    root * {WEB_ROOT}
    basicauth { {USUARIO} {HASH_BCRYPT} }   # caddy hash-password
    try_files {path} /index.html
    file_server
}
```
