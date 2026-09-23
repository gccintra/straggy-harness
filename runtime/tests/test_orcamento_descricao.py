"""Orçamento das descriptions (HRN-010 parte B). Sem modelo e sem rede.

O build avisa — e o --strict reprova — descrição acima de 350 caracteres ou soma
do harness em 6.000 ou mais. A frase que o eval usa para acionar a ação tem que
continuar na description; a do vizinho, não.
"""
from __future__ import annotations

import pathlib
import sys
import unittest

RAIZ = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(RAIZ / "runtime" / "adapters"))

import harness  # noqa: E402

# Trechos da frase de roteamento que a description enxuta precisa conservar.
ANCORAS = {
    "backlog-analysis": ["métricas do backlog", "burndown", "backlog-prioritization", "backlog-health"],
    "backlog-health": ["duplicatas", "bagunça", "backlog-analysis"],
    "backlog-issue-creator": ["cria uma issue", "refina a #NNN", "backlog-query"],
    "backlog-prioritization": ["lista ranqueada", "prioriza", "backlog-analysis"],
    "backlog-query": ["vê a #NNN", "fecha a #NNN", "backlog-issue-creator"],
    "changelog-generator": ["registra essa entrega", "changelog", "wiki-publish"],
    "committer": ["@committer", "$committer"],
    "db-query": ["quantos X estão com status Y", "backlog-query"],
    "design-brief": ["o que reusa e o que falta", "design-screen"],
    "design-screen": ["cria a tela", "design-brief"],
    "design-setup": ["prints do sistema atual", "design-screen"],
    "discovery": ["explorar alternativas", "problema de verdade", "doc-consolidator"],
    "doc-consolidator": ["documenta a #NNN", "documento base", "doc-final-generator"],
    "doc-final-generator": ["gera o docx", "doc-consolidator"],
    "prototype-deploy": ["publica o protótipo"],
    "prototype-prints": ["prints da #NNN", "prototype-deploy"],
    "sprint-goal-generator": ["meta da sprint", "sprint-ops"],
    "sprint-ops": ["fecha a sprint", "move pra próxima", "sprint-goal-generator"],
    "stop-slop": ["humaniza", "cheiro de IA"],
    "wiki-publish": ["publica na wiki", "changelog-generator"],
}

# Skills cuja description antiga terminava no aviso de INTERFACE.md.
COM_PROVIDER = {
    "backlog-analysis", "backlog-health", "backlog-issue-creator",
    "backlog-prioritization", "design-brief", "design-screen", "discovery",
    "doc-consolidator", "doc-final-generator", "sprint-ops", "wiki-publish",
}


def _wf(nome, descricao, origem="sistema"):
    return {
        "nome": nome,
        "origem": origem,
        "skill_existe": True,
        "campos": {"description": descricao},
        "acao": None,
        "encaixes": [],
        "provider": None,
        "produz": None,
        "requer": [],
        "requer_condicional": [],
        "objetivo": "problema que o workflow resolve",
        "entrega": [],
        "portoes": [],
        "persona": False,
        "evals": [],
        "resolvido": "/tmp/harness-teste-inexistente",
        "org": "",
        "pack": "",
    }


def _avisos(workflows):
    return [m for sev, m in harness.validar(workflows, "/tmp") if sev == harness.AVISO]


def _fontes():
    achados = {}
    for base in (RAIZ / "system" / "pack" / "workflows", RAIZ / "system" / "workflows"):
        for skill in base.glob("*/SKILL.md"):
            achados[skill.parent.name] = skill
    return achados


def _descricao(skill):
    campos = harness.frontmatter(skill)[0]
    return " ".join(str(campos.get("description", "")).split())


class OrcamentoSintetico(unittest.TestCase):
    def test_acima_do_teto_avisa_com_o_nome(self):
        msgs = _avisos([_wf("longa", "a" * 351)])
        self.assertTrue(any("longa" in m and "351" in m for m in msgs))

    def test_no_teto_nao_avisa(self):
        msgs = _avisos([_wf("justa", "a" * 350)])
        self.assertFalse(any("description com" in m or "descrições do harness" in m for m in msgs))

    def test_soma_no_orcamento_avisa_uma_vez(self):
        # 20 × 300 = 6.000, que já não cabe (o critério é abaixo de 6.000).
        workflows = [_wf(f"s{i}", "b" * 300) for i in range(20)]
        msgs = [m for m in _avisos(workflows) if "descrições do harness somam" in m]
        self.assertEqual(msgs, [
            "descrições do harness somam 6000 caracteres "
            "(orçamento 6000) — acima disso o runtime corta a lista e o gatilho some."
        ])

    def test_soma_abaixo_nao_avisa(self):
        workflows = [_wf(f"s{i}", "b" * 300) for i in range(19)]
        msgs = _avisos(workflows)
        self.assertFalse(any("descrições do harness" in m for m in msgs))

    def test_descricao_da_organizacao_nao_entra_no_orcamento(self):
        # 467 da org + uma do harness de 100 não estouram teto nem soma do harness.
        workflows = [
            _wf("da-org", "c" * 500, origem="org"),
            _wf("do-pack", "d" * 100, origem="pack"),
        ]
        msgs = _avisos(workflows)
        self.assertFalse(any("description com" in m or "descrições do harness" in m for m in msgs))

    def test_teto_e_soma_sao_avisos_distintos(self):
        workflows = [_wf("estoura", "e" * 351), _wf("curta", "ok")]
        msgs = _avisos(workflows)
        self.assertTrue(any("estoura" in m and "351" in m for m in msgs))
        self.assertFalse(any("descrições do harness" in m for m in msgs))


class FontesReais(unittest.TestCase):
    def test_cada_descricao_cabe_e_a_soma_tambem(self):
        fontes = _fontes()
        self.assertGreaterEqual(len(fontes), 27)
        soma = 0
        for nome, skill in sorted(fontes.items()):
            desc = _descricao(skill)
            self.assertLessEqual(len(desc), harness.TETO_DESCRICAO, nome)
            self.assertNotIn("IMPORTANTE: leia", desc)
            soma += len(desc)
        self.assertLess(soma, harness.ORCAMENTO_DESCRICOES)
        self.assertEqual(soma, 5560)

    def test_ancora_da_frase_de_eval_permanece(self):
        fontes = _fontes()
        for nome, ancoras in ANCORAS.items():
            desc = _descricao(fontes[nome])
            for ancora in ancoras:
                self.assertIn(ancora, desc, f"{nome} perdeu {ancora!r}")

    def test_committer_nao_oferece_commita_isso(self):
        desc = _descricao(_fontes()["committer"])
        self.assertNotIn("commita isso", desc)
        self.assertIn("explícito", desc)

    def test_aviso_de_interface_foi_para_a_linha_provider(self):
        fontes = _fontes()
        for nome in COM_PROVIDER:
            corpo = fontes[nome].read_text(encoding="utf-8").split("---", 2)[2]
            self.assertIn("INTERFACE.md", corpo, nome)
            self.assertIn("antes de qualquer operação", corpo, nome)
            self.assertNotIn("IMPORTANTE: leia", _descricao(fontes[nome]))

    def test_vizinha_nao_herda_a_frase_exclusiva(self):
        fontes = _fontes()
        analise = _descricao(fontes["backlog-analysis"])
        saude = _descricao(fontes["backlog-health"])
        self.assertNotIn("bagunça", analise)
        self.assertNotIn("burndown", saude)
        self.assertNotIn("gera o docx", _descricao(fontes["doc-consolidator"]))
        self.assertNotIn("documento base", _descricao(fontes["doc-final-generator"]))


if __name__ == "__main__":
    unittest.main()
