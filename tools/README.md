# Ferramentas de análise

Rodam **fora do jogo**, uma vez por faixa, e produzem dados que o jogo apenas lê.
Nada aqui é compilado no projeto.

## Ambiente

O `numpy` e o `soundfile` não existem no Python do sistema, e não devem ser instalados
lá. O ambiente fica isolado nesta pasta e é descartável:

```
python -m venv tools/.venv
tools/.venv/Scripts/python.exe -m pip install numpy soundfile
```

`soundfile` traz o libsndfile 1.2.2, que decodifica MP3 direto — por isso não é
preciso ffmpeg nem converter as faixas para WAV antes.

## Scripts

| Script | O que faz |
|---|---|
| `medir_bpm.py` | Candidatos de andamento por autocorrelação do envelope de onset |
| `analisar_faixa.py` | Andamento **e fase da primeira batida**, por pente de batidas |

```
tools/.venv/Scripts/python.exe tools/analisar_faixa.py sounds/snd_fase_01/snd_fase_01.mp3
```
