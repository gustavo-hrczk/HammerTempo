"""Andamento, fase da primeira batida e confianca de uma faixa.

Duas licoes aprendidas medindo as faixas do jogo, ambas custaram uma conclusao errada:

1. O pico de andamento e AFIADO. Em snd_fase_04, 115,00 BPM pontua 0,235 e 115,60
   pontua 0,042 — porque ao longo de 379 batidas um erro de 0,6 BPM perde a fase por
   completo. Uma busca grosseira nao acha o pico: ela passa ao lado dele. Por isso a
   varredura e em duas etapas, grossa e depois fina.

2. Forca bruta NAO compara entre faixas, porque depende de quao denso e o envelope.
   O que compara e a razao contra a media do envelope: quanto a grade de batidas
   pontua acima do que uma grade aleatoria pontuaria naquela mesma faixa.
"""
import sys, numpy as np, soundfile as sf

HOP, JAN = 512, 1024

# Calibrado nas quatro faixas do projeto, que medem de 6,6x a 9,5x.
RAZAO_MINIMA = 4.0

def envelope(caminho):
    """Fluxo espectral: soma das subidas de energia por banda, quadro a quadro."""
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

def pontuar(env, taxa, bpm):
    """Melhor alinhamento de uma grade neste andamento: devolve forca e fase.
    A fase varre quadro a quadro, que e a resolucao do envelope (11,6 ms)."""
    per = 60.0 * taxa / bpm
    n = int((len(env) - 1) / per)
    if n < 8: return (-1, 0)

    base = np.arange(n) * per
    melhor = (-1, 0)
    for fase in np.arange(0, per, 1.0):
        idx = (base + fase).astype(int)
        idx = idx[idx < len(env)]
        s = env[idx].sum() / len(idx)
        if s > melhor[0]: melhor = (s, fase / taxa)
    return melhor

def procurar(env, taxa, lo=60, hi=200):
    """Duas etapas: acha a regiao com passo de 0,25 BPM e refina com 0,01."""
    grosso = max(((pontuar(env, taxa, b)[0], b) for b in np.arange(lo, hi, 0.25)))
    bpm0 = grosso[1]
    fino = max(((pontuar(env, taxa, b)[0], b)
                for b in np.arange(bpm0 - 0.5, bpm0 + 0.5, 0.01)))
    forca, fase = pontuar(env, taxa, fino[1])
    return fino[1], fase, forca

for caminho in sys.argv[1:]:
    nome = caminho.replace("\\", "/").split("/")[-1].rsplit(".", 1)[0]
    env, taxa, dur = envelope(caminho)
    bpm, fase, forca = procurar(env, taxa)
    razao = forca / env.mean()

    if   razao >= 6: veredito = "PERCUSSAO CLARA"
    elif razao >= RAZAO_MINIMA: veredito = "utilizavel"
    else: veredito = "SEM BATIDA CONFIAVEL - nao serve para mapa automatico"

    print(f"\n{nome}  ({dur:.1f} s)")
    print(f"   beat_tempo_bpm:     {bpm:.2f}")
    print(f"   primeira_batida_ms: {fase*1000:.1f}")
    print(f"   confianca: {razao:.1f}x acima do piso  ->  {veredito}")
