# Verificação visual — conferir antes de entregar

Gerar com os valores certos não garante fidelidade; **conferir** garante. Nunca afirme
"ficou fiel" sem ter rodado a comparação. Honestidade > "ficou igual": reporte o que
restou divergente.

## Dois regimes, conforme a referência

**Referência com visual** (produção, desenho autoral, print): renderize a tela no mesmo
viewport da referência, screenshot, **diff numérico** contra a imagem de referência:

```python
import numpy as np
from PIL import Image
ref = Image.open(ref_path).convert('RGB')
got = Image.open(got_path).convert('RGB').resize(ref.size)
d = np.abs(np.asarray(ref, int) - np.asarray(got, int)).mean(axis=2)
print('diff medio:', d.mean())
rows = d.mean(axis=1)
for i in np.argsort(rows)[-5:]:
    print(f'y={i}  erro={rows[i]:.1f}')
```

Corrija as faixas de maior erro e repita. **Máximo 3 iterações** — diff parou de cair →
PARE e mostre o que restou.

**Wireframe** (sem visual a bater): o diff **não se aplica**. Verificação dupla:
estrutura contra o rabisco (toda seção existe? mesma ordem? todo botão lá?) e visual
contra a **tela irmã** (mesma cara de sistema, mesmos componentes, mesma densidade).

## Como ler o diff

- Diff alto em faixa de **texto** = fonte/antialiasing — não persiga.
- Diff alto em **borda/fundo** = layout — corrija.
- O diff mede **estrutura/layout, não pixel de cor**: pequena diferença por usar o token
  em vez do hex cru da referência é **correta**. Nunca troque token por hex cru só para
  baixar o número — isso reintroduz a inconsistência que a verificação existe para pegar.
