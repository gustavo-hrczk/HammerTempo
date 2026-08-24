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

## Mapas gerados a partir da música — tentado e descartado

Houve uma ferramenta que montava o mapa a partir dos ataques da faixa, com a **faixa
da nota vindo da banda de frequência** (grave embaixo, agudo em cima). Foi removida.

O erro não foi técnico — os mapas saíam alinhados e com a densidade certa. Foi de
premissa: o jogo tem **um único som de martelo**, então a faixa da nota não representa
instrumento nenhum, é só qual botão apertar. Separar por canais criou complexidade
sem função, e o arranjo ficou pior que os padrões escritos à mão.

O que precisa acompanhar a música é o **tempo**, não a distribuição das faixas — e
disso os `ritmo_patterns` já davam conta. Ver D-103.
