"""Confere os motivos de todas as fases contra as respectivas faixas.

O criterio e a FRACAO DE NOTAS MUDAS ao longo da partida, e nao o minimo de forca: uma
unica nota que calhe num compasso quieto zera o minimo, e por esse criterio ate as fases
ja validadas pelo usuario reprovavam (D-131). Banda aceitavel medida nas fases
validadas: 14% a 21%.

A forca vem de perfil_compasso.forca, que amostra o maximo em +-40 ms — amostragem
pontual variava 100x conforme a janela de FFT (D-130).

Manter esta tabela em sincronia com fases_data em o_controlador_geral/Create_0.gml.
"""
import numpy as np, sys, math
sys.path.insert(0, "tools")
from perfil_compasso import fluxo, forca

SPAWNER_X, LINHA_X, FPS = 1280, 98, 60

#        rotulo                asset  bpm      1a batida  motivo                                    vel faixas respiro duracao
FASES = [
    ("Adaga    Novato",         1, 89.99,  0.2902,
        [1, 0.5, 0.5, 1, 0.5, 0.5],                                    4, 2, None, 40),
    ("Lanca    Aprendiz",       2, 100.0,  0.5921,
        [0.5] * 8 + [3],                                               5, 3, None, 40),
    ("Florete  Adepto",         3, 90.0,   1.7257,
        [0.6667, 0.3333, 0.6667, 0.3333, 1, 1, 0.6667, 0.3333, 1, 1, 1], 5, 3, None, 50),
    ("Maca     Veterano",       4, 99.99,  0.3483,
        [0.5, 0.5, 1, 0.5, 0.5, 1, 1],                                 5, 4, 8.0,  45),
    ("Machado  Especialista",   5, 130.01, 0.0,
        [1, 1, 0.5, 0.5, 1, 1, 1],                                     5, 4, None, 60),
    ("Espada   Mestre",         6, 110.0,  0.3831,
        [1, 1, 0.5, 0.5, 1],                                           5, 4, None, 60),
]

print(f"{'fase':22s} {'teclas':>7s} {'n/s':>5s} {'mudas':>7s} {'q25':>6s} "
      f"{'mediana':>8s} {'vao':>6s} {'indice':>7s}  soma")
print("-" * 92)
for rot, n, bpm, fase, pat, vel, faixas, respiro, durac in FASES:
    e, taxa, dur = fluxo(f"sounds/snd_fase_0{n}/snd_fase_0{n}.mp3")
    beat = 60 / bpm
    piso = np.mean([forca(e, taxa, dur, fase + k * beat / 16, beat * 4) for k in range(16)])

    viagem = (SPAWNER_X - LINHA_X) / vel / FPS
    t = fase + math.ceil(((respiro or viagem + 1) - fase) / beat) * beat

    vals, i = [], 0
    fim = min(dur - 0.2, t + durac)
    while t < fim:
        vals.append(forca(e, taxa, dur, t, dur * 2) / piso)
        t += pat[i] * beat
        i = (i + 1) % len(pat)

    v = np.array(vals)
    dens = len(v) / durac
    soma = sum(pat)
    aviso = "" if abs(soma - round(soma)) < 1e-3 else "  <-- SOMA NAO FECHA"
    print(f"{rot:22s} {faixas:7d} {dens:5.2f} {(v < 1.0).mean() * 100:6.1f}% "
          f"{np.percentile(v, 25):6.2f} {np.median(v):8.2f} "
          f"{min(pat) * beat * vel * FPS - 45:5.0f}px {dens * faixas / viagem:7.2f}  {soma:.4f}{aviso}")
