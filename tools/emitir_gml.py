"""Converte os mapas gerados em um script GML que o jogo le.

O mapa vira CODIGO em vez de arquivo de dados de proposito: fica versionado, aparece
em diff, e nao depende de leitura de arquivo em tempo de execucao — uma coisa a menos
para dar errado no gabinete.

    tools/.venv/Scripts/python.exe tools/emitir_gml.py
"""
import json, os

# indice da fase em fases_data -> nome do mapa
FASES = [(0, "adaga"), (1, "lanca"), (2, "espada"), (3, "machado")]

linhas = [
    "/// scr_mapas — mapas de notas gerados a partir da percussao das faixas",
    "///",
    "/// NAO EDITE A MAO. Gerado por tools/gerar_mapa.py + tools/emitir_gml.py.",
    "///",
    "/// Cada nota e [instante_em_segundos_da_faixa, tipo_de_seta]. O instante e",
    "/// absoluto e medido a partir do inicio da faixa, entao ele nao depende de",
    "/// velocidade de nota, de frame rate nem de quando o spawner nasceu.",
    "///",
    "/// A faixa da nota vem da BANDA de frequencia do ataque, com grave embaixo e",
    "/// agudo em cima — a pista espelha a musica em vez de sortear.",
    "",
]

meta = []
for indice, nome in FASES:
    caminho = f"tools/mapa_{nome}.json"
    if not os.path.exists(caminho):
        continue
    with open(caminho, encoding="utf-8") as f:
        m = json.load(f)

    notas = m["notas"]
    meta.append((indice, nome, m, len(notas)))

    linhas.append(f"/// {nome}: {len(notas)} notas | {m['bpm']} BPM | "
                  f"1a batida {m['primeira_batida_ms']} ms | confianca {m['confianca']}x")
    linhas.append(f"function mapa_fase_{nome}() {{")
    linhas.append("    return [")

    for i in range(0, len(notas), 6):
        pedaco = notas[i:i + 6]
        corpo = ", ".join(f"[{n['t']:.4f},{n['faixa']}]" for n in pedaco)
        linhas.append(f"        {corpo},")

    linhas.append("    ];")
    linhas.append("}")
    linhas.append("")

linhas += [
    "/// Mapa da fase, ou array vazio se ela ainda nao tem um.",
    "/// Fase sem mapa cai no gerador por padrao ritmico, que continua funcionando.",
    "function mapa_da_fase(_indice) {",
    "    switch (_indice) {",
]
for indice, nome, _, _ in meta:
    linhas.append(f"        case {indice}: return mapa_fase_{nome}();")
linhas += [
    "    }",
    "    return [];",
    "}",
    "",
]

destino = "scripts/scr_mapas/scr_mapas.gml"
os.makedirs(os.path.dirname(destino), exist_ok=True)
with open(destino, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(linhas))

yy = """{
  "$GMScript":"v1",
  "%Name":"scr_mapas",
  "isCompatibility":false,
  "isDnD":false,
  "name":"scr_mapas",
  "parent":{
    "name":"Scripts",
    "path":"folders/Scripts.yy",
  },
  "resourceType":"GMScript",
  "resourceVersion":"2.0",
}
"""
with open("scripts/scr_mapas/scr_mapas.yy", "w", encoding="utf-8", newline="\n") as f:
    f.write(yy)

print(f"{destino}: {sum(n for _,_,_,n in meta)} notas em {len(meta)} fases")
for indice, nome, m, n in meta:
    print(f"   fase {indice} {nome:9s} {n:4d} notas  {m['bpm']:6.2f} BPM  {m['confianca']}x")
