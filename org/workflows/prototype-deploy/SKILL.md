---
name: prototype-deploy
description: >
  Publica o app de protótipo (prototype/, React + Vite) numa VPS como site estático,
  atrás de basic auth e HTTPS. Descobre o "porteiro" HTTP da VPS (nginx no host,
  Traefik, Caddy, nginx-proxy) antes de assumir qualquer coisa, gera o prototype/deploy.sh
  e o bloco de configuração do servidor a partir dos valores em project-config.md, e
  produz o passo a passo a ser executado NA VPS. Use quando o usuário pedir para
  hospedar, publicar, subir, colocar no ar ou dar deploy do protótipo — ou pedir uma URL
  compartilhável dele. Não use para deploy do sistema de produção (backend/banco), que
  não é escopo deste harness.
---

# prototype-deploy

Coloca o `prototype/` no ar como **site estático** numa VPS, com **basic auth** e **HTTPS**.

O `prototype/` é um SPA React (Vite + `createBrowserRouter`) que buila para arquivos em disco. **Não tem backend, não precisa de processo rodando** — nem Node, nem pm2, nem container. Quem tratar isso como app com runtime vai adicionar peça que não faz nada.

Duas consequências práticas, e são as duas fontes de bug deste deploy:

1. **SPA fallback é obrigatório.** `createBrowserRouter` produz URLs reais (`/visitas/123`). O servidor precisa devolver o `index.html` para qualquer caminho que não seja arquivo — sem isso, F5 numa rota profunda dá 404.
2. **Protótipo carrega fluxo e dado do cliente.** Basic auth não é opcional, e não é "a gente põe depois". Entra antes do site atender a primeira requisição.

---

## 0. O ciclo — leia antes de executar qualquer coisa

A skill tem duas metades, e a maior parte dela **roda uma vez só na vida do projeto**.

**Setup (uma vez, §1 a §3 e §6):** descobrir o porteiro HTTP, criar o server block, basic auth, DNS, certificado. Mexe no servidor que hospeda outras coisas — é a metade com risco.

**Publicação (toda vez, §4):**
```bash
cd prototype && ./deploy.sh
```
Builda local, envia o `dist/` por rsync, recarrega o nginx. Não precisa de git, nem de Node na VPS, nem de tocar em config. Protótipo mudou → roda de novo.

O certificado renova sozinho (timer do certbot). O deploy não encosta nisso.

> **Antes de executar, descubra em qual metade você está.** Já existe `prototype/deploy.sh` e o domínio já responde? É **republicação**: vá direto pro §4. Refazer §2/§3 numa republicação é mexer em config de servidor à toa — e é lá que mora o risco de derrubar site alheio.

---

## 1. Configuração

Leia de `project-config.md`, seção `## Deploy do protótipo`:

```
Domínio:              ex. obrasim.gcsoftware.tech
Host SSH da VPS:      ex. root@gcsoftware.tech
Web root:             ex. /root/production/websis-obrasim-proto/dist
Usuário do basic auth: ex. obrasim
```

Campo faltando → **pergunte**, não invente. Domínio errado queima tentativa de certificado no rate limit do Let's Encrypt (5 por semana por domínio).

Se a seção não existir em `project-config.md`, é o primeiro deploy do projeto: colete os valores com o usuário e **proponha escrever a seção** (write-gate — não escreva sem aprovação).

---

## 2. Descubra o porteiro — não assuma

Só **um** processo ocupa as portas 80/443 da VPS. Ele decide qual domínio vai pra qual app, e é ele que você tem que configurar. Descobrir isso errado = pisar em site que já está no ar.

Peça ao usuário para rodar na VPS (ou, se você tem acesso SSH, rode você):

```bash
sudo ss -tlnp | grep -E ':80 |:443 '
docker ps
systemctl is-active nginx caddy
```

| Quem responde na 80/443 | Caminho |
|---|---|
| `nginx` no host | §3 — novo server block. **Caso mais comum.** |
| Traefik / nginx-proxy / caddy-docker (container) | §5 — novo serviço no compose com label/rede |
| Caddy no host | §5 — bloco novo no Caddyfile |
| Nada | VPS limpa: instale nginx e siga §3 |

Antes de escrever qualquer config, **leia um site estático que já funciona lá** e copie o padrão da casa (caminhos de cert, convenção de web root, nome de arquivo). O padrão local ganha do padrão desta skill.

---

## 3. nginx no host

### 3.1 Server block

Comece **HTTP-only**. O certbot injeta o bloco SSL depois — escrever caminho de certificado que ainda não existe faz `nginx -t` falhar e trava o passo seguinte.

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

Hash no nome do asset (`index-CXRaHnrN.js`) é o que torna o `immutable` seguro: build novo gera nome novo. Por isso o `index.html` — que aponta pros hashes — é o único que não pode cachear.

### 3.2 Ativar

```bash
sudo htpasswd -c /etc/nginx/.htpasswd-{PROJETO} {USUARIO}   # peça a senha ao usuário
sudo ln -s /etc/nginx/sites-available/{PROJETO} /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d {DOMINIO}                            # escolha o redirect HTTP→HTTPS
```

Depois do certbot: **releia o arquivo**. Ele reescreve o server block, e vale confirmar que `auth_basic` e `try_files` sobreviveram.

### 3.3 Permissão do web root

nginx roda como `www-data` e precisa de **read + execute em todo o caminho** até o `dist/`. Web root debaixo de `/root` (comum quando os outros serviços já moram lá) tende a dar 403, porque `/root` costuma ser `700`.

```bash
namei -l {WEB_ROOT}
```

Se outro site já serve estático do mesmo lugar, **replique a permissão dele**. Não afrouxe `/root` sem falar com o usuário — é diretório de sistema, e mexer nele afeta muito mais que o protótipo.

---

## 4. deploy.sh

Gere `prototype/deploy.sh` com os valores do `project-config.md`. Build local, envia o `dist/` — a VPS nunca faz `git pull`, nunca precisa de Node.

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

**`--delete` é intencional**: asset velho com hash antigo fica órfão no servidor pra sempre sem ele. Mas ele apaga tudo que estiver no destino e não estiver no `dist/` — confirme que o web root serve **só** o protótipo antes de rodar a primeira vez.

### Artefato de build não vai pro git

`prototype/dist/` versionado gera conflito a cada build (hash novo, hash velho deletado) e não serve pra nada — o deploy builda local. Garanta `prototype/.gitignore`:

```
node_modules/
dist/
tsconfig.tsbuildinfo
```

Se já estiverem trackeados: `git rm -r --cached prototype/dist prototype/tsconfig.tsbuildinfo`. Confira antes se `dist/` tem algo que **não** é derivado de `src/` ou `public/` — se tiver, é bug de outra coisa, não destrackeie por cima.

---

## 5. Outros porteiros

**Traefik / nginx-proxy / caddy-docker** — o protótipo vira um `nginx:alpine` com o `dist/` dentro, registrado no proxy pelo padrão que os outros serviços já usam (label, rede, variável de ambiente — leia o compose deles). O SPA fallback continua necessário, agora no `nginx.conf` de dentro do container.

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

---

## 6. DNS — antes do certificado

Registro **A** `{DOMINIO}` → IP da VPS, propagado, **antes** de rodar o certbot. Sem isso o desafio HTTP falha e a tentativa conta no rate limit.

```bash
dig +short {DOMINIO}
```

Não retornou o IP da VPS → **pare** e avise o usuário. Não siga "pra ver se passa".

---

## 7. Validação

```bash
curl -I https://{DOMINIO}                        # 401 — basic auth ativo
curl -I -u {USUARIO}:{SENHA} https://{DOMINIO}   # 200 (ou 404 se o dist ainda não subiu)
```

Rota profunda (a que quebra sem `try_files`):
```bash
curl -I -u {USUARIO}:{SENHA} https://{DOMINIO}/alguma/rota/interna   # 200, não 404
```

E os sites que já rodavam na VPS — todos ainda de pé. Você mexeu no servidor que serve todos eles.

---

## 8. Write-gate

Você vai tocar em servidor que hospeda coisa em produção. Vale o §2 do `ENGAGEMENT.md`, sem atalho:

- Config de servidor, symlink em `sites-enabled/`, certbot, `deploy.sh`, seção nova no `project-config.md` → **mostre o que vai fazer e espere aprovação.**
- Comando destrutivo (`rsync --delete`, `rm`, mudança de permissão em diretório de sistema) → **confirme antes**, mesmo que o passo anterior tenha sido aprovado.
- Rodar você o passo a passo na VPS vs. entregar o passo a passo pro usuário rodar: **pergunte** qual ele quer. Sem acesso SSH declarado, entregue o roteiro — em bloco copiável, com os valores já preenchidos.
