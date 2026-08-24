"""Gera o mapa de notas de uma faixa a partir da percussao dela.

A queixa que originou esta ferramenta: "parece que estamos tocando algo e ouvindo
outra coisa desconexa". A causa e que a faixa da nota vinha de irandom() e o ritmo de
um padrao curto em laco — nada nos dois olhava para a musica. A martelada tem de ser
percussao DA faixa, e para isso as notas precisam sair dos ataques dela.

Como funciona
-------------
1. Envelope de onset por BANDA de frequencia, nao somado. Somar joga fora justamente
   a informacao que decide a faixa da nota:
       grave  20-150 Hz  -> bumbo
       medio  150-2k     -> caixa, corpo
       agudo  2k-10k     -> chimbal, ataque
2. Andamento e fase pelo pente de batidas (mesma rotina de analisar_faixa.py).
3. Cada pico e QUANTIZADO para a semicolcheia mais proxima. Onset que cai longe de
   qualquer subdivisao e ruido e sai fora — e isso que impede o mapa de ficar tremido.
4. A faixa vem da banda dominante do pico. Onsets em bandas diferentes no mesmo
   instante viram notas simultaneas; a variacao ritmica aparece sozinha, porque ela
   esta na musica.
5. Poda por dificuldade: distancia minima entre notas e teto de densidade, tirando
   sempre os picos mais fracos primeiro.

Uso
---
    tools/.venv/Scripts/python.exe tools/gerar_mapa.py <fase> <mp3> [--dur N]
"""
import sys, json
import numpy as np
import soundfile as sf

HOP, JAN = 512, 1024

# Quatro bandas, uma por faixa. Tres bandas para quatro faixas deixava uma vazia e
# empilhava 54% das notas numa so.
BANDAS = [
    ("agudo",       2500, 10000),   # chimbal, ataque
    ("medio_agudo",  500,  2500),   # corpo, ataque de caixa
    ("medio_grave",  120,   500),   # caixa, tom
    ("grave",         20,   120),   # bumbo
]

# GRAVE EMBAIXO, AGUDO EM CIMA. A faixa de cima esta em y=515 e a de baixo em y=665,
# entao mapear altura de frequencia para altura de tela faz a pista espelhar a musica:
# o bumbo desce, o chimbal sobe. Nao e so distribuicao, e leitura.
#
# tipos de seta como rm_forja os define: 0 baixo, 1 cima, 2 direita, 3 esquerda
# linhas na tela, de cima para baixo:      cima(1), esquerda(3), direita(2), baixo(0)
FAIXA_DA_BANDA = {
    "agudo":       1,   # linha 0, no topo
    "medio_agudo": 3,   # linha 1
    "medio_grave": 2,   # linha 2
    "grave":       0,   # linha 3, no pe
}


def envelopes(caminho):
    """Um envelope de fluxo espectral por banda, mais o somado."""
    x, sr = sf.read(caminho, dtype="float32", always_2d=True)
    x = x.mean(axis=1)

    jan_h = np.hanning(JAN)
    n = 1 + (len(x) - JAN) // HOP
    esp = np.empty((n, JAN // 2 + 1), dtype=np.float32)
    for i in range(n):
        esp[i] = np.abs(np.fft.rfft(x[i * HOP:i * HOP + JAN] * jan_h))

    freqs = np.fft.rfftfreq(JAN, 1 / sr)
    subida = np.maximum(np.diff(esp, axis=0), 0)

    saida = {}
    for nome, lo, hi in BANDAS:
        sel = (freqs >= lo) & (freqs < hi)
        e = subida[:, sel].sum(axis=1)
        e = np.maximum(e - np.median(e), 0)
        saida[nome] = e / (e.max() or 1)

    total = subida.sum(axis=1)
    total = np.maximum(total - np.median(total), 0)
    saida["_total"] = total / (total.max() or 1)

    return saida, sr / HOP, len(x) / sr


def pontuar(env, taxa, bpm):
    per = 60.0 * taxa / bpm
    n = int((len(env) - 1) / per)
    if n < 8:
        return (-1, 0)
    base = np.arange(n) * per
    melhor = (-1, 0)
    for fase in np.arange(0, per, 1.0):
        idx = (base + fase).astype(int)
        idx = idx[idx < len(env)]
        s = env[idx].sum() / len(idx)
        if s > melhor[0]:
            melhor = (s, fase / taxa)
    return melhor


def andamento(env, taxa, lo=60, hi=200):
    """Busca em duas etapas: o pico de andamento e afiado demais para uma so."""
    _, bpm0 = max((pontuar(env, taxa, b)[0], b) for b in np.arange(lo, hi, 0.25))
    _, bpm = max((pontuar(env, taxa, b)[0], b)
                 for b in np.arange(bpm0 - 0.5, bpm0 + 0.5, 0.01))
    forca, fase = pontuar(env, taxa, bpm)
    return bpm, fase, forca / env.mean()


def picos(env, limiar=0.18, vizinhanca=2):
    """Maximos locais acima do limiar. Devolve (quadro, intensidade)."""
    saida = []
    for i in range(vizinhanca, len(env) - vizinhanca):
        v = env[i]
        if v < limiar:
            continue
        if v >= env[i - vizinhanca:i + vizinhanca + 1].max():
            saida.append((i, float(v)))
    return saida


def gerar(caminho, dur, faixas, dist_min_ms, densidade_max):
    envs, taxa, total_seg = envelopes(caminho)
    bpm, fase, confianca = andamento(envs["_total"], taxa)

    sub = (60.0 / bpm) / 4            # semicolcheia, em segundos
    tol = sub * 0.35                  # o quanto o pico pode estar fora da grade

    # --- candidatos, com banda e forca ---
    cand = {}
    for nome, _, _ in BANDAS:
        if FAIXA_DA_BANDA[nome] >= faixas and faixas < 4:
            continue
        for quadro, forca in picos(envs[nome]):
            t = quadro / taxa
            if t > dur:
                continue
            k = round((t - fase) / sub)
            t_grade = fase + k * sub
            if abs(t - t_grade) > tol or t_grade < 0:
                continue
            chave = (k, nome)
            if forca > cand.get(chave, (0,))[0]:
                cand[chave] = (forca, t_grade, FAIXA_DA_BANDA[nome])

    notas = sorted(({"t": round(v[1], 4), "faixa": v[2] % faixas, "f": v[0]}
                    for v in cand.values()), key=lambda n: n["t"])

    # --- poda: distancia minima, tirando sempre o pico mais fraco ---
    dist_min = dist_min_ms / 1000
    podadas = []
    for n in notas:
        if podadas and (n["t"] - podadas[-1]["t"]) < dist_min:
            if n["f"] > podadas[-1]["f"]:
                podadas[-1] = n
            continue
        podadas.append(n)

    # --- teto de densidade por janela de 4 segundos ---
    final = []
    for n in podadas:
        recentes = [m for m in final if n["t"] - m["t"] < 4.0]
        if len(recentes) >= densidade_max:
            mais_fraco = min(recentes, key=lambda m: m["f"])
            if n["f"] <= mais_fraco["f"]:
                continue
            final.remove(mais_fraco)
        final.append(n)

    return {
        "bpm": round(float(bpm), 2),
        "primeira_batida_ms": round(float(fase) * 1000, 1),
        "confianca": round(float(confianca), 1),
        "duracao": float(total_seg),
        "notas": [{"t": float(n["t"]), "faixa": int(n["faixa"])} for n in final],
    }


# Dificuldade e SELECAO sobre o mesmo material, nao ritmo diferente: a musica e a
# mesma, muda quanto dela vira nota. Os alvos vem da densidade dos mapas atuais, que
# ja foram jogados e aprovados — 1,5 a 2,5 notas por segundo.
#
# dist_min: quanto tempo minimo entre duas notas quaisquer
# densidade: teto de notas numa janela de 4 segundos
PERFIS = {
    "facil":   (350, 7),
    "medio":   (260, 9),
    "dificil": (200, 10),
    "mestre":  (170, 11),
}

if __name__ == "__main__":
    fase_nome = sys.argv[1]
    caminho = sys.argv[2]
    dur = 60
    faixas = 4
    perfil = "dificil"
    for i, a in enumerate(sys.argv):
        if a == "--dur":    dur = float(sys.argv[i + 1])
        if a == "--faixas": faixas = int(sys.argv[i + 1])
        if a == "--perfil": perfil = sys.argv[i + 1]

    dist_min, densidade = PERFIS[perfil]
    m = gerar(caminho, dur, faixas, dist_min_ms=dist_min, densidade_max=densidade)

    print(f"{fase_nome}: {m['bpm']} BPM, 1a batida {m['primeira_batida_ms']} ms, "
          f"confianca {m['confianca']}x")
    print(f"   {len(m['notas'])} notas em {dur:.0f} s "
          f"({len(m['notas'])/dur:.2f} por segundo)")

    conta = {}
    for n in m["notas"]:
        conta[n["faixa"]] = conta.get(n["faixa"], 0) + 1
    print(f"   por faixa: {dict(sorted(conta.items()))}")

    saltos = [abs(m["notas"][i]["faixa"] - m["notas"][i-1]["faixa"])
              for i in range(1, len(m["notas"]))]
    if saltos:
        rep = sum(1 for s in saltos if s == 0) * 100 // len(saltos)
        print(f"   repeticao de faixa: {rep}%")

    with open(f"tools/mapa_{fase_nome}.json", "w", encoding="utf-8") as f:
        json.dump(m, f, ensure_ascii=False)
    print(f"   -> tools/mapa_{fase_nome}.json")
