"""Confere cada motivo contra a propria faixa, com a amostragem robusta (+-40 ms).

O MINIMO sobre ~100 notas nao serve como criterio: uma unica nota que calhe num
compasso quieto zera a estatistica, e isso acontece ate nas fases ja validadas. O que
interessa e a DISTRIBUICAO — quantas notas caem em silencio ao longo da partida.
"""
import numpy as np, sys, math
sys.path.insert(0, "tools")
from perfil_compasso import fluxo, forca

FASES = [
    ("Adaga    Novato",      1, 89.99,  0.2902, [1,0.5,0.5,1,0.5,0.5], 4, 3, None, 40),
    ("Lanca    Aprendiz",    2, 100.0,  0.5921, [0.5]*8+[3],           5, 3, None, 40),
    ("Maca     Veterano",    4, 99.99,  0.3483, [0.5,0.5,1,0.5,0.5,1,1], 5, 3, 8.0, 45),
    ("Florete  Adepto",      3, 90.0,   1.7257,
        [0.6667,1,0.3333,0.6667,0.3333,1, 0.6667,0.3333,0.6667,0.3333,1,1], 5, 3, None, 50),
    ("Machado  Especialista",5, 130.01, 0.0,    [1,1,0.5,0.5,1,1,1],   5, 4, None, 60),
    ("Espada   Mestre",      6, 120.0,  0.3553,
        [0.5,0.5,1,0.5,0.5,1, 0.5,1.5,0.5,0.5,1], 6, 4, None, 60),
]

print(f"{'fase':22s} {'n/s':>5s} {'mudas':>7s} {'q25':>6s} {'mediana':>8s} "
      f"{'vao':>6s} {'indice':>7s}")
print("-" * 78)
for rot, n, bpm, fase, pat, vel, faixas, respiro, durac in FASES:
    p = f"sounds/snd_fase_0{n}/snd_fase_0{n}.mp3"
    e, taxa, dur = fluxo(p)
    beat = 60 / bpm
    piso = np.mean([forca(e, taxa, dur, fase + k * beat / 16, beat * 4) for k in range(16)])

    viagem = (1280 - 98) / vel / 60
    minimo = respiro if respiro else viagem + 1
    t = fase + math.ceil((minimo - fase) / beat) * beat

    vals, i = [], 0
    fim = min(dur - 0.2, t + durac)
    while t < fim:
        vals.append(forca(e, taxa, dur, t, dur * 2) / piso)
        t += pat[i] * beat
        i = (i + 1) % len(pat)

    v = np.array(vals)
    dens = len(v) / durac
    vao = min(pat) * beat * vel * 60 - 45
    idx = dens * faixas / viagem
    mudas = (v < 1.0).mean() * 100
    print(f"{rot:22s} {dens:5.2f} {mudas:6.1f}% {np.percentile(v,25):6.2f} "
          f"{np.median(v):8.2f} {vao:5.0f}px {idx:7.2f}")

print("\nAs tres fases ja validadas (Lanca, Maca, Machado) sao o controle:")
print("a taxa de notas mudas delas e o que se pode considerar aceitavel.")
