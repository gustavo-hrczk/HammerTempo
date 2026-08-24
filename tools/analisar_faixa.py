"""Andamento e fase de uma faixa, por pente de batidas sobre o envelope de onset.

Diferente da autocorrelacao, o pente testa uma grade de batidas de verdade e
devolve TAMBEM o deslocamento da primeira batida — que e o que alinha o mapa a
musica. Sem a fase, acertar o BPM ainda deixa tudo torto.
"""
import sys, numpy as np, soundfile as sf

HOP, JAN = 512, 1024

def envelope(caminho):
    x, sr = sf.read(caminho, dtype="float32", always_2d=True)
    x = x.mean(axis=1)
    jan_h = np.hanning(JAN)
    n = 1 + (len(x) - JAN) // HOP
    esp = np.empty((n, JAN // 2 + 1), dtype=np.float32)
    for i in range(n):
        esp[i] = np.abs(np.fft.rfft(x[i*HOP:i*HOP+JAN] * jan_h))
    fl = np.sum(np.maximum(np.diff(esp, axis=0), 0), axis=1)
    fl = np.maximum(fl - np.median(fl), 0)
    return fl / (fl.max() or 1), sr / HOP, len(x) / sr

def pente(env, taxa, bpm_lo=70, bpm_hi=130, passo=0.05):
    """Para cada BPM e cada fase, soma o envelope nas posicoes de batida.
    A combinacao que mais soma e a grade que a musica realmente usa."""
    melhor = (0, 0, -1)
    for bpm in np.arange(bpm_lo, bpm_hi, passo):
        per = 60.0 * taxa / bpm
        if per < 2: continue
        n = int((len(env) - 1) / per)
        if n < 8: continue
        base = (np.arange(n) * per)
        for fase in np.arange(0, per, max(1.0, per / 24)):
            idx = (base + fase).astype(int)
            idx = idx[idx < len(env)]
            s = env[idx].sum() / len(idx)
            if s > melhor[2]:
                melhor = (bpm, fase / taxa, s)
    return melhor

ANOTADO = {"snd_fase_01": 88, "snd_fase_02": 100, "snd_fase_03": 108}
for caminho in sys.argv[1:]:
    nome = caminho.replace("\\","/").split("/")[-1].rsplit(".",1)[0]
    env, taxa, dur = envelope(caminho)
    bpm, fase, forca = pente(env, taxa)
    ant = ANOTADO.get(nome)
    print(f"\n{nome}  ({dur:.1f} s)")
    print(f"   BPM medido   {bpm:7.2f}   | primeira batida em {fase*1000:6.1f} ms | forca {forca:.3f}")
    if ant:
        erro = (bpm - ant) / ant
        # de quanto o mapa do jogo se afasta da musica ao longo da fase
        jogada = 40 if nome != "snd_fase_03" else 60
        print(f"   BPM anotado  {ant:7.2f}   | erro {erro*100:+.2f}%")
        print(f"   -> em {jogada}s de fase, o mapa desliza {abs(erro)*jogada*1000:.0f} ms da musica"
              f"  ({abs(erro)*jogada/(60/bpm):.2f} batidas)")
