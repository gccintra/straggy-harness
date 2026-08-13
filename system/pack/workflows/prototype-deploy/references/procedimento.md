# Procedimento padrão — publicar protótipo (pack)

Passo a passo default da ação `publicar-prototipo`. A organização sobrescreve este arquivo
em `org/workflows/prototype-deploy/references/procedimento.md`.

O contrato do que tem que estar de pé no fim, os portões de configuração e a validação
final são da moldura e valem junto com o que estiver aqui.

## Em qual metade você está — descubra antes de executar

- **Setup** (uma vez na vida do projeto): descobrir o porteiro, criar a configuração,
  autenticação, DNS, certificado. É a metade com risco: mexe no servidor que hospeda
  outras coisas.
- **Publicação** (toda vez): roda o script de publicação e pronto. O certificado renova
  sozinho; o deploy não encosta nisso.

Já existe script de publicação e o domínio responde → é **republicação**: vá direto ao
passo de publicar. Refazer o setup numa republicação é mexer em config de servidor à toa.

## Descubra o porteiro — não assuma

Só **um** processo ocupa as portas 80/443. Ele decide qual domínio vai para qual app, e é
ele que você configura. Errar aqui = pisar em site que já está no ar. Como identificar e o
que fazer em cada caso: `references/vps-nginx.md`.

Antes de escrever qualquer configuração, **leia um site estático que já funciona lá** e
copie o padrão da casa (caminhos de certificado, convenção de web root, nome de arquivo).
**O padrão local ganha do padrão desta skill.**
