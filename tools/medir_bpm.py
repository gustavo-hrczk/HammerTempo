"""Estimativa de andamento a partir do audio, para conferir os BPM anotados a mao."""
import sys, numpy as np, soundfile as sf

def envelope_de_onset(x, sr, hop=512, jan=1024):
    """Fluxo espectral: soma das subidas de energia por banda, quadro a quadro.
    E o detector de onset classico e o que melhor responde a percussao."""
    jan_h = np.hanning(jan)
    n = 1 + (len(x) - jan) // hop
    espec = np.empty((n, jan // 2 + 1), dtype=np.float32)
    for i in range(n):
        seg = x[i * hop : i * hop + jan] * jan_h
        espec[i] = np.abs(np.fft.rfft(seg))
    dif = np.diff(espec, axis=0)
    fluxo = np.sum(np.maximum(dif, 0), axis=1)          # so o que SOBE
    fluxo -= np.median(fluxo)                            # tira o piso
    return np.maximum(fluxo, 0), sr / hop                # envelope e sua taxa

def estimar_bpm(env, taxa, bpm_min=60, bpm_max=200):
    """Autocorrelacao do envelope: o periodo que mais se repete e a batida."""
    env = env - env.mean()
    ac = np.correlate(env, env, mode="full")[len(env) - 1:]
    lag_min = int(taxa * 60 / bpm_max)
    lag_max = int(taxa * 60 / bpm_min)
    janela = ac[lag_min:lag_max]
    melhores = np.argsort(janela)[::-1][:6] + lag_min
    return [(60 * taxa / l, ac[l] / ac[0]) for l in melhores]

for caminho in sys.argv[1:]:
    x, sr = sf.read(caminho, dtype="float32", always_2d=True)
    x = x.mean(axis=1)
    env, taxa = envelope_de_onset(x, sr)
    print(f"\n{caminho}")
    print(f"   {len(x)/sr:.1f} s a {sr} Hz | envelope a {taxa:.1f} quadros/s")
    for bpm, forca in estimar_bpm(env, taxa):
        print(f"   candidato {bpm:6.1f} BPM   (forca {forca:.3f})")
