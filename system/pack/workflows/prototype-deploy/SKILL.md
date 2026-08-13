---
name: prototype-deploy
description: >
  Publica o app de protótipo (prototype/) num servidor como site estático, atrás de
  autenticação e HTTPS. Descobre o "porteiro" HTTP do servidor (nginx no host, Traefik,
  Caddy, nginx-proxy) antes de assumir qualquer coisa, gera o script de publicação e o
  bloco de configuração a partir dos valores em project-config.yaml, e produz o passo a
  passo a ser executado no servidor. Use quando o usuário pedir para hospedar, publicar,
  subir, colocar no ar ou dar deploy do protótipo — ou pedir uma URL compartilhável dele.
  Não use para deploy do sistema de produção (backend/banco), que não é escopo deste
  harness.
acao:
  id: publicar-prototipo
  rotulo: Publicar protótipo
  descricao: publica o protótipo num servidor, com HTTPS e autenticação
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo: Como fazer
    ajuda: Como sua empresa publica um protótipo — quem aprova, que ambiente usa e o que precisa estar protegido.
    tipo: texto-longo
  receita-servidor:
    caminho: references/vps-nginx.md
    rotulo: Receita do servidor
    ajuda: Os comandos e a configuração do servidor da sua empresa. Vazio → receita padrão de VPS com nginx.
    tipo: texto-longo
---

# prototype-deploy — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` §2 — você mexe em servidor que hospeda coisa de terceiros: **cada** passo de config, comando destrutivo e escrita no `project-config.yaml` é um portão separado |
| Configuração | `project-config.yaml`, bloco `prototipo_deploy` |
| Receita | `references/vps-nginx.md` — server block, script de publicação, certificado, permissão, outros porteiros (a organização sobrescreve para outro alvo de hospedagem) |

O protótipo é um SPA que buila para arquivos em disco. **Não tem backend, não precisa de
processo rodando** — nem Node, nem pm2, nem container. Quem tratar isso como app com
runtime adiciona peça que não faz nada.


**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.

## Contrato do que tem que estar de pé no fim

1. **SPA fallback.** O roteador produz URLs reais (`/modulo/123`); o servidor devolve o
   `index.html` para qualquer caminho que não seja arquivo. Sem isso, F5 numa rota profunda
   dá 404 — é a falha nº 1 deste deploy.
2. **Autenticação antes da primeira requisição.** O protótipo carrega fluxo e dado de
   cliente. Não é "a gente põe depois". Desligar exige decisão explícita do responsável,
   registrada no `project-config.yaml`.
3. **HTTPS** com renovação automática.
4. **Cache correto**: assets com hash no nome são imutáveis; o arquivo de entrada
   (`index.html`) **nunca** cacheia — senão deploy novo não aparece no browser.
5. **Publicação repetível num comando**, buildando local e enviando só o resultado. O
   servidor nunca faz `git pull` nem precisa de Node.
6. **Artefato de build fora do Git** (`dist/`, cache de type-check).

## Configuração

Leia o bloco `prototipo_deploy` do `project-config.yaml` (domínio, host SSH, web root,
porteiro, usuário da autenticação). Campo faltando → **pergunte, não invente**: domínio
errado queima tentativa de certificado no rate limit da autoridade certificadora. Bloco
vazio → é o primeiro deploy: colete os valores e **proponha escrever o bloco** (write-gate).
Senha nunca entra no arquivo nem no Git.

## Validar antes de entregar

Sem credencial → resposta de não autorizado. Com credencial → a raiz responde, **e uma rota
profunda também** (é o que quebra sem SPA fallback). E os sites que já rodavam no servidor
continuam de pé — você mexeu no servidor que serve todos eles.

Entregue a URL, o usuário da autenticação e o comando de republicação.
