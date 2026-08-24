# Ritmo: diagnóstico do algoritmo atual e proposta de auto-track

Estudo pedido para responder duas queixas: o mapa de notas **não permite variação
rítmica** e tem **pontos de dessincronia**. Tudo abaixo foi medido nas faixas reais do
jogo, não estimado.

---

## 1. Como o mapa é gerado hoje

`o_spawner_ritmo` mantém um relógio próprio, em frames, que não consulta o áudio em
momento nenhum:

1. A música começa na criação do spawner.
2. A primeira nota é agendada com `alarm[0] = 60` — **um segundo fixo**, escolhido sem
   relação com a faixa.
3. Cada nota seguinte é agendada a partir da anterior:
   `alarm[0] = multiplicador × (60 / BPM_anotado) × 60`.
4. O `multiplicador` vem de um `ritmo_patterns` de 4 a 9 posições, que se repete em
   laço até a fase acabar.
5. A faixa da nota é `irandom(tipos_permitidos - 1)` — **sorteio uniforme**.

O BPM é anotado à mão em `fases_data`. Nada no jogo verifica se ele confere com a
música.

---

## 2. O que a medição encontrou

Envelope de fluxo espectral (FFT de 1024, salto de 512) e pente de batidas sobre uma
grade fina de andamento e fase. Ferramenta em `tools/analisar_faixa.py`.

| Fase | BPM anotado | BPM medido | Erro | 1ª batida da faixa |
|---|---|---|---|---|
| Adaga | 88 | **89,95** | +2,22% | 278 ms |
| Lança | 100 | **100,00** | 0,00% | 0 ms |
| Espada | 108 | **110,00** | +1,85% | 386 ms |

Dois dos três BPM anotados estão errados. Mas **não é daí que vem a dessincronia** — e
essa foi a surpresa do estudo.

### 2.1 A deriva quase não existe, por acidente

O alarme do GameMaker guarda inteiro, então a fração da batida é truncada a cada nota.
Cruzando as duas coisas:

| Fase | Batida anotada | Alarme real | Ciclo do jogo | Ciclo da música | Erro final |
|---|---|---|---|---|---|
| Adaga | 40,909 frames | `[40,40,40,40]` | 2666,7 ms | 2668,1 ms | **−0,06%** |
| Lança | 36,000 frames | `[18×8, 108]` | 4200,0 ms | 4200,0 ms | **0,00%** |
| Espada | 33,333 frames | `[33,33,16,16,33]` | 2183,3 ms | 2181,8 ms | **+0,07%** |

O truncamento encurta o intervalo quase exatamente na proporção em que o BPM anotado o
alonga. Na Adaga, um erro de +2,22% no BPM é cancelado por −2,22% de truncamento. **Dois
defeitos se anulando.** A deriva ao fim da fase fica em 22 ms na Adaga e 42 ms na
Espada — irrelevante.

Isso é sorte, não projeto. Trocar o BPM anotado pelo valor correto **pioraria** o jogo
hoje, porque removeria metade do par que se cancela.

### 2.2 O defeito real é um deslocamento constante

O que desalinha é onde a grade **começa**. A primeira nota nasce 1000 ms fixos após a
música, e chega à zona de acerto depois do tempo de viagem. Nenhum dos dois tem relação
com a batida da faixa.

| Fase | Viagem da nota | Deslocamento da grade | Batida | Fora por |
|---|---|---|---|---|
| Adaga | 5425 ms | **144 ms** | 667 ms | 22% |
| Lança | 4340 ms | **540 ms** | 600 ms | 90% (= 60 ms antes da batida seguinte) |
| Espada | 4340 ms | **45 ms** | 545 ms | 8% |

Contra as janelas de julgamento (perfeito ±33 ms, ótimo ±75 ms, bom ±133 ms):

- **Adaga: 144 ms fora da batida.** Está além até da janela de "bom". Quem toca no
  tempo da música erra a nota; quem acerta a nota está fora do tempo da música.
- **Lança: 60 ms adiantado.** Cabe em "ótimo", nunca em "perfeito" tocando pela música.
- **Espada: 45 ms.** Cabe em "ótimo".

Cada fase pegou um deslocamento diferente, e nenhum foi escolhido: é
`(1000 ms + viagem) mod batida`. Mudar a velocidade da nota muda o deslocamento, o que
explica ajustes de ritmo terem efeitos colaterais estranhos no passado.

### 2.3 A ausência de variação rítmica

O `ritmo_patterns` da Espada é `[1, 1, 0.5, 0.5, 1]`: quatro batidas que se repetem por
60 segundos, **27 vezes seguidas**. A faixa da nota é sorteio uniforme, sem relação com
nada. O mapa não conhece refrão, virada, silêncio nem acento — a música é só um pano de
fundo com um andamento aproximado.

---

## 3. Por que a arquitetura impede a correção

Três decisões estruturais, e cada uma bloqueia uma parte da solução:

**O relógio é o contador de frames, não o áudio.** Um `alarm` mede frames desde o
agendamento anterior. Se um frame atrasa — e atrasa, sob carga —, a nota atrasa junto e
o erro nunca é recuperado, porque não há referência absoluta contra a qual corrigir.

**O agendamento é relativo.** Cada nota parte da anterior. Erros somam por construção.
Um agendamento absoluto (nota `n` acontece no instante `t_n` da faixa) não acumula nada.

**O mapa é gerado em tempo de execução.** Como o padrão é sorteado na criação do
spawner, não existe "o mapa da fase" para inspecionar, medir ou corrigir. Só existe o
que aconteceu naquela partida.

---

## 4. Proposta

### 4.1 Relógio de áudio, e o mapa em dados

Duas mudanças que valem mesmo sem auto-track nenhum:

`audio_sound_get_track_position()` devolve a posição da faixa em segundos. Ela é a
única referência que não deriva, porque é o próprio áudio contando. O spawner passa a
perguntar "que horas são na música" e a comparar com uma lista de instantes.

O mapa vira **dado**: uma lista de `{t, faixa}` em milissegundos, carregada de um
arquivo. Uma nota nasce quando `posicao_audio >= t - tempo_de_viagem`. O deslocamento
constante desaparece porque `t` é medido a partir da faixa, e a deriva desaparece porque
cada nota tem seu instante absoluto.

Isso também torna o mapa **inspecionável**: dá para conferir densidade, distância mínima
entre notas e alinhamento antes de jogar.

### 4.2 O auto-track, sem intervenção humana

Viabilidade já comprovada: as três faixas foram decodificadas e analisadas nesta
sessão, e os andamentos batem com o que se ouve.

**Passo 1 — decodificar.** `soundfile` (libsndfile 1.2.2) lê MP3 direto. Sem ffmpeg,
sem conversão manual.

**Passo 2 — envelope de onset por banda.** Fluxo espectral, mas separado em três faixas
de frequência em vez de somado:

- grave (20–150 Hz) — bumbo
- médio (150–2000 Hz) — caixa, corpo
- agudo (2–10 kHz) — chimbal, ataque

É o que permite distinguir *tipos* de percussão. Somar tudo, como faz o protótipo atual,
joga fora justamente a informação que decide a faixa da nota.

**Passo 3 — andamento e fase.** Pente de batidas sobre grade fina, que é o que já está
em `tools/analisar_faixa.py`. Devolve BPM e o instante da primeira batida.

**Passo 4 — grade métrica.** Com BPM e fase, quantizar os onsets à subdivisão mais
próxima (semínima, colcheia, semicolcheia). Onsets que não caem perto de nenhuma
subdivisão são ruído e caem fora. Isso é o que impede o mapa de ficar "tremido".

**Passo 5 — atribuir faixas.** A banda dominante do onset escolhe a faixa: bumbo numa,
caixa noutra, chimbal noutra. O resultado tem relação audível com a música, ao contrário
do sorteio de hoje. Onsets simultâneos em bandas diferentes viram notas simultâneas — a
variação rítmica aparece sozinha, porque ela está na música.

**Passo 6 — podar por dificuldade.** Distância mínima entre notas conforme a fase (a
alavanca do gabinete impõe o seu próprio mínimo, ver `04-ARCADE.md`), teto de densidade,
e remoção das notas mais fracas quando o trecho fica denso demais. É aqui que Fácil,
Médio e Difícil deixam de ser BPM e passam a ser **seleção sobre o mesmo material**.

**Passo 7 — gravar** o mapa como dado do projeto, versionado junto com a faixa.

### 4.3 O que fica para depois

A calibração de latência (`offset_ms`, já no save) passa a ter função real: ela desloca
a leitura do relógio de áudio, corrigindo a latência do gabinete. Hoje o campo existe e
não é usado por nada.

---

## 5. Ordem sugerida

1. **Relógio de áudio + mapa em dados**, com os mapas atuais convertidos para lista de
   instantes. Corrige o deslocamento constante e a deriva, sem tocar em geração.
   Testável de imediato: a Adaga sai de 144 ms fora para zero.
2. **Auto-track até o passo 4** (onsets quantizados na grade), gerando um mapa para uma
   fase. Comparar lado a lado com o mapa atual.
3. **Passos 5 e 6** — faixas por banda e poda por dificuldade.
4. **Aposentar `ritmo_patterns`** quando os mapas gerados forem melhores que os
   sorteados.

O passo 1 é o que tem melhor relação entre risco e ganho: é uma correção de
sincronização, não uma mudança de projeto, e o jogo continua tocando os mesmos mapas.
