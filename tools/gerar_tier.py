"""Gera s_icone_tier, a quarta fatia do sanduiche do icone.

A arte e um selo de letra no canto inferior direito de um quadro de 26x26 — a mesma
medida da moldura, com a mesma origem no centro. Cai por cima do sanduiche existente
sem nenhum deslocamento.

A ORDEM DOS QUADROS E A ORDEM DO NIVEL DA ARMA. Os quadros 0 a 4 correspondem um a um
aos niveis que fundo, arma e moldura ja usam, e o quadro 5 e o degrau novo: S+, para
quem acerta tudo em perfeito. Sem isso a letra e a arte contariam historias diferentes
sobre a mesma forja.

tierD.png existe na pasta de origem e NAO e usado: a escala adotada tem seis degraus,
nao sete.
"""
import os, sys, shutil
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gerar_icones as G

FONTE = r"C:\Users\Gustavo\Desktop\Nova pasta (10)\Tier"
TMP = os.path.join(os.path.dirname(os.path.abspath(__file__)), "tier")
os.makedirs(TMP, exist_ok=True)

# indice -> arquivo. O indice E o nivel da arma; o 5 e o degrau novo.
ORDEM = ["tierF", "tierC", "tierB", "tierA", "tierS", "tierS+"]

destinos = []
for i, nome in enumerate(ORDEM):
    origem = os.path.join(FONTE, nome + ".png")
    if not os.path.isfile(origem):
        raise SystemExit(f"faltando: {origem}")
    d = os.path.join(TMP, f"tier_{i:02d}.png")
    shutil.copyfile(origem, d)
    destinos.append(d)
    print(f"  quadro {i} <- {nome}.png")

# origem no CENTRO (tipo 4), como as outras tres fatias, e sem animacao: o quadro e
# escolhido pelo desempenho, nao pelo tempo.
G.gerar_sprite("s_icone_tier", destinos, 26, 26, 0.0, origem_tipo=4)
G.registrar(["s_icone_tier"])
print("  s_icone_tier gerado e registrado")
