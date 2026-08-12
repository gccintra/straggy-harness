# Autoridade da referência — quem manda no visual

Nem toda referência vale a mesma coisa. Antes de transcrever, saiba **de onde ela veio** —
isso decide se o visual segue a referência ou o design system. Não está claro → pergunte.

| Referência | O que ela é | Quem manda no visual |
|---|---|---|
| **Print/node de produção** | retrato do sistema que já existe | o **design system do protótipo** — a produção dá só estrutura, campos, ordem, estados |
| **Desenho autoral** (usuário desenhou a tela nova) | intenção de design | **o desenho** — valor genuinamente novo entra no sistema (token/componente), não hardcode |
| **Wireframe/rabisco** | intenção e hierarquia, sem visual | o **design system, 100%** — do rabisco saem seções, ordem, agrupamento, ações; nunca cor, fonte ou medida |
| **Só texto** | descrição | design system + tela irmã |

## Barra de qualidade

- **Estrutura da referência, visual do sistema**: a referência define **o quê** (todo
  elemento aparece, mesma ordem, nada omitido — transcrever, não re-autorar de resumo);
  o design system define **como parece**.
- Erro clássico em ambas as direções: copiar hex cru de produção quando existe token
  (tela sai fora do sistema) e tratar wireframe como spec visual (tela sai com as caixas
  cinzas do rabisco).
- **Divergência desenho autoral × token existente** → pergunte: cor nova deliberada ou
  aproximação do token? Rabisco de cor quase sempre é aproximação.
- **Valor de design vs valor medido**: cor, radius, padding, gap, altura de **controle**
  são valores de design — copiam-se. Altura de seção e largura de container são valores
  **medidos** de um dia específico — viram layout fluido, nunca fixo.
- **Imagem se mede, não se estima** — cor e medida de print saem de medição por pixel.
  Exceção: wireframe **nunca** se mede (mediria a mão trêmula de quem desenhou).
- Imagem não carrega estados (hover, vazio, erro) nem nome de fonte → pergunte.
