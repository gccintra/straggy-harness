# Critérios de aceite

## Quando usar / quando não

- Use ao especificar um item e ao validar a entrega.
- Não use para descrever implementação nem para repetir regra que vale em vários itens —
  regra transversal é regra de negócio (`sbvr-rules.md`), referenciada e não copiada.

## Barra de qualidade

- **Verificável por quem não participou da conversa**, sem interpretação.
- Um comportamento por critério; critério com "e/ou" costuma esconder dois.
- Cobre fluxo alternativo, erro e limite — não só o caminho feliz.
- Linguagem de negócio; elemento de interface só quando o comportamento depende dele.
- `Dado / Quando / Então` quando a condição importa; lista simples quando a cerimônia não
  agrega.
- Critério sem como observar o resultado é desejo, não critério.

## Contrato de output

Lista numerada de critérios · o que está explicitamente fora · regras de negócio
referenciadas.
