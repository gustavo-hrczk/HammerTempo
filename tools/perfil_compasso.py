"""Perfil de forca por posicao do compasso, robusto a janela de FFT.

Amostra o MAXIMO do fluxo espectral numa vizinhanca de +-40 ms de cada posicao, e
nao um unico quadro. Ver D-130: a amostragem pontual variava 100x conforme a janela,
porque um pico estreito cai entre dois quadros e some.
"""
import numpy as np, soundfile as sf
HOP, JAN, VIZ = 512, 2048, 0.040

def fluxo(p):
    x,sr=sf.read(p,dtype="float32",always_2d=True); m=x.mean(axis=1)
    jh=np.hanning(JAN); n=1+(len(m)-JAN)//HOP
    E=np.empty((n,JAN//2+1),dtype=np.float32)
    for i in range(n): E[i]=np.abs(np.fft.rfft(m[i*HOP:i*HOP+JAN]*jh))
    f=np.sum(np.maximum(np.diff(E,axis=0),0),axis=1)
    return np.maximum(f-np.median(f),0), sr/HOP, len(m)/sr

def forca(e,taxa,dur,t0,passo):
    "maximo do fluxo em +-40 ms, media sobre todas as repeticoes"
    r=int(VIZ*taxa); vals=[]; t=t0
    while t<dur-0.1:
        i=int(t*taxa)
        a,b=max(0,i-r),min(len(e),i+r+1)
        if b>a: vals.append(e[a:b].max())
        t+=passo
    return np.mean(vals) if vals else 0.0

def perfil(p,bpm,fase,rot,sub=2,compasso=4):
    e,taxa,dur=fluxo(p); beat=60/bpm
    piso=np.mean([forca(e,taxa,dur,fase+k*beat/16,beat*compasso) for k in range(16)])
    piso=max(piso,1e-9)
    print(f"\n=== {rot} ===  {bpm:.2f} BPM, 1a batida {fase*1000:.1f} ms")
    saida={}
    for b in range(compasso):
        linha=[]
        for s in range(sub):
            pos=b+s/sub
            r=forca(e,taxa,dur,fase+pos*beat,beat*compasso)/piso
            saida[round(pos,3)]=r
            tag="*" if r>=1.35 else ("." if r>=1.15 else "_")
            linha.append(f"{r:5.2f}{tag}")
        print(f"   tempo {b+1}: "+"  ".join(linha))
    fortes=[saida[float(b)] for b in range(compasso)]
    outros=[v for k,v in saida.items() if k!=int(k)]
    print(f"   tempo forte {np.mean(fortes):.2f}  |  entre-tempos {np.mean(outros):.2f}")
    return saida

if __name__=="__main__":
    SP="C:/Users/Gustavo/AppData/Local/Temp/claude/C--Users-Gustavo-Desktop-HammerTempo-HammerTempo/69d4ee7e-d40a-46e9-9a88-8bc4dea4246f/scratchpad/"
    perfil("sounds/snd_fase_01/snd_fase_01.mp3",89.99,0.2902,"ADAGA (snd_fase_01)")
    perfil(SP+"ductia90.mp3",90.0,0.3924,"DUCTIA 90 em dois")
    perfil(SP+"ductia90.mp3",90.0,0.3924,"DUCTIA 90 em tres",sub=3)
    perfil(SP+"taberna120.mp3",120.0,0.3553,"IN TABERNA 120 (nova Mestre)")
    perfil("sounds/snd_fase_03/snd_fase_03.mp3",110.0,0.3831,"ESPADA 110 (a referencia de personalidade)")
