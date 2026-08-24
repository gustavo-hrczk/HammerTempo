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

## Gerar mapas a partir da música

```
tools/.venv/Scripts/python.exe tools/gerar_mapa.py machado sounds/snd_fase_04/snd_fase_04.mp3 --dur 60 --faixas 4 --perfil mestre
tools/.venv/Scripts/python.exe tools/emitir_gml.py
```

O primeiro comando analisa e grava `tools/mapa_<fase>.json`; o segundo converte todos
os mapas em `scripts/scr_mapas/scr_mapas.gml`, que o jogo lê.

**Perfis de dificuldade** — a música é a mesma, muda quanto dela vira nota:

| perfil | distância mínima | teto por 4 s |
|---|---|---|
| `facil` | 350 ms | 7 |
| `medio` | 260 ms | 9 |
| `dificil` | 200 ms | 10 |
| `mestre` | 170 ms | 11 |

A ordem dos índices em `emitir_gml.py` (`FASES`) tem de bater com `fases_data`.
