# Análise de impacto — o que quebra se eu mudar isto

Varredura antes de editar. Também é a resposta à pergunta "qual o raio disso?" quando o
usuário só quer saber, sem mexer.

O modo de falha que esta análise existe para evitar não é o erro de sintaxe — o build pega
esse. É a mudança que **passa no build e apodrece outra coisa**: o método que duas skills
liam e agora diz outra coisa para uma delas, a ação renomeada que deixou a contraprova da
vizinha apontando para o vazio, o arquivo de encaixe que mudou de caminho e abandonou o
conteúdo que a organização escreveu nele.

Rode os cinco raios. Cada um responde uma pergunta diferente; nenhum substitui outro.

---

## Raio 1 — quem cita o alvo

Referência textual. É o mais barato e o que mais acha.

```bash
grep -rn "<alvo>" --include='*.md' --include='*.yaml' --include='*.sh' --include='*.py' \
  system/ org/ docs/ runtime/adapters/ README.md | grep -v '^runtime/skills/'
```

`runtime/skills/` fica de fora sempre: é gerado, e acerto ali é apagado no próximo build.

Leia cada acerto e classifique: **referência** (aponta para o alvo — segue valendo, ou vira
link morto), **cópia** (repete o que o alvo diz — já era defeito antes da sua mudança; a
camada de cima referencia, nunca copia) ou **coincidência**.

## Raio 2 — quem depende do artefato na esteira

Só quando o alvo tem `produz`. Renomear ou aposentar um artefato deixa quem o exige sem
produtor, e o build reprova — mas depois de você já ter mexido em tudo.

```bash
python3 -c "
import json
m = json.load(open('runtime/manifest.json'))
alvo = '<artefato>'
print([a['id'] for a in m['acoes']
       if alvo in a['requer'] or any(c['artefato'] == alvo for c in a['requer_condicional'])])
"
```

Dependente condicional (`requer_condicional`) é o que mais escapa: ele só exige o artefato
em algumas demandas, então some das conversas até o dia em que trava uma.

## Raio 3 — que eval cita a ação

Renomear uma ação quebra a suíte de duas maneiras, e a segunda ninguém lembra: os `atende`
dela **e** os `confunde_com` das vizinhas, que são a contraprova de que o pedido delas não
cai nela.

```bash
grep -rn "<acao>" --include='caso.yaml' system/ org/
```

Ação aposentada libera as vizinhas que a citavam — a linha `confunde_com` some junto, senão
o build reprova por citar ação inexistente.

## Raio 4 — o que a organização escreveu ali

O raio mais caro de errar, porque o prejuízo é conteúdo humano, não código.

```bash
./build.sh --list                 # quantos encaixes de cada workflow estão preenchidos
ls -R org/workflows/<nome>/               # o que ela escreveu de fato
```

Mudou o `caminho` de um encaixe? O arquivo que a organização preencheu continua no caminho
antigo, agora sem dono: o build passa a avisar "não corresponde a nenhum encaixe declarado" e
a ação volta a rodar no padrão do pack **em silêncio para quem usa**. Encaixe que já tem
conteúdo preenchido não muda de caminho sem migrar o arquivo no mesmo passo.

Encaixe **removido** é conteúdo da organização jogado fora. Encaixe **novo** é aditivo e não
quebra ninguém.

## Raio 5 — a camada está certa?

Não é sobre o que quebra hoje; é sobre o que apodrece em seis meses.

- O conteúdo serve a mais de uma skill? Então desce para método (L1) ou provider — nunca se
  copia para a segunda.
- Está subindo regra de comportamento para dentro de um workflow? Ela é L0.
- Está descendo vocabulário desta empresa para o pack? Reprova no teste do pack: *"outra
  empresa usaria isto sem editar?"*
- A edição afrouxa algum portão? Nenhuma camada de cima pode — no máximo adiciona portões.

Tabela por camada: `docs/MANUTENCAO.md` §1.

---

## O que o build já pega sozinho

Não gaste varredura com o que `./build.sh --strict` denuncia de graça: ação com dois
donos, esteira sem produtor ou com ciclo, eval citando ação inexistente, cobertura de gatilho
sem contraprova, encaixe apontando provider sem a capacidade, arquivo da organização fora de
encaixe declarado, workflow sem `objetivo`/`entrega`/`portoes`, bloco derivado divergindo do
frontmatter.

O que **só a varredura** pega: referência textual que vira link morto, cópia que passou a
divergir, conteúdo da organização abandonado por mudança de caminho, e camada errada.

## Como reportar

Uma tabela, antes de propor a edição. Raio sem nenhum acerto se declara vazio — omitir não é
o mesmo que verificar.

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | `arquivo:linha` … | atualizar / é cópia, resolver na camada / ignorar |
| Esteira | ação dependente … | — |
| Evals | caso … | — |
| Organização | encaixe preenchido … | migrar / preservar |
| Camada | — | mantém / desce para L1 / sobe para L0 |

**Nada quebra** é um resultado legítimo e comum. O que não é legítimo é não ter olhado.
