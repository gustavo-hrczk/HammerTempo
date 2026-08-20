# HammerTempo — Auditoria Técnica

> Sprint 1 (Documentação) · base: commit `c1e3dba` · complemento de `01-ARQUITETURA.md`.
> Toda a análise foi feita por **leitura de código e dos metadados das rooms/sprites**.
> Os itens marcados com 🔬 precisam de **confirmação em execução** antes de virarem tarefa.

## Legenda de severidade

| Nível | Significado |
|---|---|
| 🔴 **Crítico** | Quebra a experiência ou pode travar/inviabilizar a apresentação na feira |
| 🟠 **Alto** | Prejudica claramente o jogo, mas há contorno |
| 🟡 **Médio** | Incômodo, inconsistência ou dívida técnica relevante |
| 🔵 **Baixo** | Limpeza, cosmético, organização |

---

## 1. O que funciona bem hoje

Vale registrar: o projeto tem uma base sólida para 5 dias de jam.

- **Arquitetura de estado clara.** O `enum MINIGAME` + `switch` no `Step` do controlador é legível
  e fácil de estender — é justamente o gancho para o Modo Arcade.
- **Fases orientadas a dados.** `fases_data` como array de structs é a decisão de design mais
  acertada do projeto: adicionar uma fase é adicionar um struct. A Sprint 7 (mais fases) se apoia
  diretamente nisso.
- **Separação de camadas de áudio.** `o_audio_manager` persistente centraliza música e SFX.
- **Sequenciador de martelada** (`snd_martelada_01..05` em vai-e-vem) dá variação orgânica ao
  feedback sonoro sem custo de CPU — detalhe muito bom.
- **Parallax multi-cenário com crossfade** (`o_background_manajer_forja`) é robusto e bonito;
  o cálculo de escala por largura de sprite funciona em qualquer resolução.
- **Tela de resultado com identidade**: arma forjada + moldura por faixa de performance + frases
  aleatórias temáticas + animação do ferreiro. É o ponto alto de UX do jogo.
- **Créditos e licenciamento de assets documentados dentro do jogo** — raro em jam, e importante
  para uma apresentação institucional.
- **Linguagem visual consistente** nos menus (painel, amarelo no selecionado, caixa pulsante).

---

## 2. Achados — Gameplay e ritmo

### 🔴 GP-01 — A janela "PERFEITO" é de ~1 frame (praticamente inatingível)

`objects/o_buttons_forja/Step_0.gml:30`

O julgamento é **espacial**, por sobreposição de máscaras. Calculando as áreas reais:

- Máscara do alvo/nota: 45 x 42 px, origem no canto superior esquerdo.
- `o_hitbox_perfeito` ocupa `x ∈ [98, 102)` (sprite 2 px × escala 2).
- A condição extra `_nota_acertada.x >= 97` corta ainda mais a faixa.

Resultado: **PERFEITO só ocorre com a nota em `x ∈ [97, 102)`** — 5 px. A 5 px/frame, isso é
**1 frame (≈17 ms)**; a 4 px/frame, ~1,25 frame. Ou seja, o "perfeito" é sorte, não perícia.
Consequência em cascata: quase todos os acertos viram "BOM" (50 pts), o combo cresce devagar e a
faixa de 100% ("Perfeito") da tela de resultado é praticamente inalcançável.

### 🔴 GP-02 — Zonas mortas: o jogador acerta a tecla e nada acontece

`objects/o_buttons_forja/Step_0.gml:24-53`

A detecção de "há uma nota sob o alvo" (`instance_place`) cobre `x ∈ (53, 143)`, mas as faixas de
julgamento cobrem apenas `x ∈ (69,5, 126,5)`. Sobram duas faixas onde o jogador **pressiona a tecla
certa, no lane certo, e o jogo simplesmente ignora**:

| Faixa | Situação | Duração @5 px/f |
|---|---|---|
| `x ∈ [126,5, 143)` | adiantado demais | ~55 ms |
| `x ∈ (53, 69,5]` | atrasado demais | ~55 ms |

Pior: no caso "atrasado", a nota **continua andando até a zona de erro** e o jogador ainda leva
−50 pontos e um erro na sequência, mesmo tendo acertado a tecla. É a fonte número um de
"o jogo não registrou meu acerto".

### 🔴 GP-03 — As notas não estão sincronizadas com a música

`objects/o_spawner_ritmo/Create_0.gml` + `Alarm_0.gml`

Três problemas somados:

1. **Não há relógio musical.** As notas são agendadas por `alarm` a partir do instante em que o
   spawner é criado. A música é iniciada no mesmo instante, mas nada garante que o *downbeat* da
   gravação coincida com `t = 0` do arquivo (praticamente nunca coincide — há sempre alguns ms/
   compassos de introdução).
2. **O tempo de viagem desloca a fase.** A nota nasce em `x = 1400` e é julgada em `x ≈ 98`:
   são **1300 px**, ou 4,3–5,4 s. Como as notas *nascem* na grade rítmica, elas *chegam* na grade
   deslocada de `tempo_de_viagem mod duracao_da_batida` — um offset arbitrário em relação à música.
3. **Drift acumulado por arredondamento.** `beat_interval_frames = (60/BPM)*60` dá valores
   fracionários (fase 1: **40,909 frames**). O `alarm` trabalha em frames inteiros, então cada nota
   perde a fração. Se truncar para 40, o jogo toca a 90 BPM contra uma música de 88 BPM: **~2,3% de
   erro, ou quase 1 segundo de defasagem ao fim de 40 s**. 🔬 (a magnitude exata do truncamento
   precisa ser confirmada em execução, mas o erro existe em qualquer arredondamento).

Além disso o "mapeamento" não é um mapa: o **padrão é sorteado uma vez e repetido em loop**, e o
**lane de cada nota é `irandom()`** — não há relação alguma entre as notas e a melodia. É o item
central da Sprint 5.

### 🔴 GP-04 — `spam_detect >= 10` encerra a partida (fatal em feira)

`objects/o_controlador_geral/Step_0.gml:55` + `objects/o_buttons_forja/Step_0.gml:52`

Cada tecla pressionada sem nota correspondente incrementa `stats_spam_detect`, que **só é zerado ao
acertar uma nota** — ou seja, é um acumulador da partida inteira, não uma sequência. **10 toques
"vazios" ao longo de toda a fase = game over imediato**, sem explicação na tela.

Numa cabine de feira, onde o visitante bate nos botões antes de entender o jogo (e onde o próprio
formato arcade convida ao button mashing), isso vai encerrar partidas o tempo todo. Além disso, no
caso das zonas mortas (GP-02) o contador é *zerado* indevidamente.

### 🟠 GP-05 — Modo Infinito quebraria se fosse reativado

`objects/o_spawner_ritmo/Step_0.gml:23-24`

O ramo `is_endless_mode` usa `intervalo_min` / `intervalo_max`, que **não são inicializados no
Create** — a fase quebraria com "variable not set" no primeiro aumento de dificuldade. Também há
uma inconsistência: o comentário diz "a cada 15 segundos", o `Create` usa 15 s, e o reset usa
`2 * room_speed` (2 s).

### 🟠 GP-06 — Janelas de acerto em pixels, não em tempo

Como as janelas são espaciais e as fases têm velocidades diferentes (4 e 5 px/frame), a **exigência
de precisão muda de fase para fase sem ninguém ter decidido isso**: a fase Fácil, mais lenta, tem
janelas 25% mais generosas em milissegundos que as demais. Fases futuras com velocidade 6+ ficariam
proporcionalmente mais duras por acidente de implementação.

### 🟡 GP-07 — Uma nota só pode ser julgada por sobreposição, sem prioridade

`instance_place` retorna **uma** nota qualquer entre as sobrepostas. Com padrões densos (colcheias
a 0,5 do beat) duas notas do mesmo lane podem se sobrepor parcialmente e o julgamento escolhe
arbitrariamente qual. 🔬 Improvável nos padrões atuais, mas vira problema real com mapas mais densos.

### 🟡 GP-08 — Notas restantes contam como total no cálculo final

No game over por erros, as notas ainda em tela são destruídas mas já foram contadas em
`stats_total_notas`, o que puxa a porcentagem para baixo. Coerente, mas vale decidir
explicitamente.

---

## 3. Achados — Ciclo de vida, estado e áudio

### 🔴 CV-01 — Instâncias persistentes duplicam a cada retorno ao menu

`rooms/rm_menu/rm_menu.yy` + `objects/o_controlador_geral/o_controlador_geral.yy`

`o_controlador_geral` e `o_background_manajer_forja` são objetos **persistentes** e estão
**colocados na room `rm_menu`, que não é persistente**. Em GameMaker, ao reentrar numa room não
persistente, todas as instâncias dela são recriadas — enquanto as persistentes anteriores continuam
vivas. Portanto:

```
menu -> forja -> (ESC no seletor) -> menu   ==> 2x o_controlador_geral, 2x o_background_manajer_forja
        -> forja -> menu                    ==> 3x cada
```

Consequências: referências como `o_controlador_geral.pontuacao` passam a apontar para **uma
instância arbitrária**, o estado do jogo fica imprevisível, o tutorial reaparece, e cada background
extra desenha um parallax completo por frame (queda de performance progressiva).
O mesmo vale para `o_controlador_opcoes`, persistente e instanciado em `rm_opcoes`.
🔬 Reproduzir: entrar no jogo, apertar ESC no seletor, voltar ao jogo 3–4 vezes e observar FPS/estado.

**É o achado com maior risco para a feira**, porque só aparece depois de alguns ciclos — exatamente
o que acontece quando dezenas de pessoas jogam em sequência.

### 🔴 CV-02 — Repetir a mesma fase deixa a música muda

`objects/o_controlador_resultado/Create_0.gml:3-6` + `objects/o_audio_manager/Create_0.gml:11`

A tela de resultado faz `audio_sound_gain(musica_da_fase, 0, 1000)` — o *asset* fica com ganho 0,
mas **continua tocando em loop** (foi iniciado com `loop = true` e nunca recebe `audio_stop_sound`).
A linha seguinte (`if gain == 0 then audio_stop_all()`) lê o ganho **imediatamente**, antes do fade
de 1000 ms terminar, então praticamente nunca dispara.

Ao rejogar a mesma fase, `play_music()` avalia
`if (!audio_is_playing(asset) || audio_sound_get_gain(asset) > 0)`: o som *está* tocando e o ganho
*é* 0 → a condição é falsa → **não faz nada**. A fase roda em silêncio, com o ganho preso em 0.
🔬 Reproduzir: jogar a fase 1, chegar ao resultado, jogar a fase 1 de novo.

A mesma condição tem um segundo defeito: quando é verdadeira com a música já tocando, ela **para e
reinicia** a faixa do zero.

### 🟠 CV-03 — O tema corta bruscamente na contagem regressiva

Durante `CONTAGEM` (3 s) o `snd_tema` continua tocando; a música da fase só começa quando o spawner
é criado, já em `RITMO`, cortando o tema no meio. Falta um fade e/ou começar a música da fase junto
com a contagem (o que, aliás, é o gancho natural para sincronizar o mapa — Sprint 5).

### 🟠 CV-04 — Áudio todo em "Uncompressed / Not Streamed"

Todos os 25 sons estão com `compression: 0`. `snd_fase_03` (182 s) e `snd_fase_04` (198 s) são
descompactados inteiros na RAM na inicialização — na casa de **15–30 MB por faixa**, além de tempo
de carga. Músicas devem ser **Compressed – Streamed**; SFX curtos podem continuar uncompressed.

### 🟡 CV-05 — `randomize()` chamado a cada tela de resultado

`objects/o_controlador_resultado/Create_0.gml:2` — deveria ser chamado uma única vez na
inicialização do jogo.

### 🟡 CV-06 — `o_transicao` existe mas quase não é usado

Só o splash usa o fade. Todas as outras trocas de sala fazem `room_goto()` direto — corte seco.
`mudar_de_sala()` e `mudar_de_sala_imediato()` estão prontas e ociosas.

### 🟡 CV-07 — Não há pausa nem saída de partida

`pausa` existe, é checada em 6 lugares e **nunca é ativada** (o código que a alternava está
comentado — commit `87ea1fc "foda-se o pause"`). Durante a fase, ESC não faz nada: quem entrou por
engano precisa esperar 40–60 s ou errar de propósito. Em feira, isso trava a fila.

---

## 4. Achados — Apresentação, resolução e UI

### 🟠 UI-01 — Dois espaços de coordenadas conflitantes (720p vs 768p)

O jogo inicia em `rm_splash`, que é **1366x768**, enquanto todas as rooms de jogo são **1280x720**.
Nenhum código define o tamanho da camada GUI (`display_set_gui_size`) e nenhuma room usa views.
Assim, o gameplay é desenhado em coordenadas de room (1280x720) e a UI em coordenadas de GUI —
que **não são o mesmo espaço**. É a explicação mais provável para os números "mágicos" espalhados
pelo código (`_cy_rodape = 640`, `_prompt_y = 720`, `draw_text_ext(..., 220, ...)`).
🔬 Confirmar em execução medindo `display_get_gui_width()` dentro de `rm_forja`.

Impacto direto na feira: em tela cheia numa TV/monitor 1080p, o alinhamento entre HUD e lanes pode
sair do lugar. **Este item deve ser resolvido antes de qualquer trabalho fino de UI**, senão todo
ajuste será refeito.

### 🔴 UI-02 — Não existe HUD durante a partida

`objects/o_controlador_geral/Draw_64.gml:32-38`

No estado `RITMO`, **as duas únicas linhas de HUD estão comentadas**. Durante a fase inteira o
jogador não vê: pontuação, combo, julgamento (PERFEITO/BOM), quantas notas errou, quanto falta para
o game over, nem quanto falta para acabar. Os julgamentos existem apenas como
`show_debug_message("PERFEITO!")` — ou seja, só aparecem no console do IDE.

Para um jogo de ritmo, é a maior lacuna de UX do projeto: **não há loop de feedback**.

### 🟠 UI-03 — Feedback visual de acerto é mínimo

O acerto perfeito cria `o_faisca` na bigorna; o acerto bom não cria nada visual além da animação de
martelada. Não há: flash no alvo, pop/scale da nota, shake, partículas por lane, cor por julgamento,
nem indicação de combo. O erro tem um bom tint vermelho no ferreiro — é o único feedback claro.

### 🟠 UI-04 — A zona "BOM" é invisível

`objects/o_hitbox_bom/o_hitbox_bom.yy:37` tem `visible: false`, o que impede o evento `Draw` de
rodar — o `draw_self()` do objeto nunca executa. O jogador vê apenas a faixa fina do "perfeito",
sem noção da janela real de acerto.

### 🟡 UI-05 — Menu de opções incompleto e inconsistente

`objects/o_controlador_opcoes/`

- Sem SFX de navegação (todos os outros menus têm).
- Volume aplicado direto em `audio_master_gain()` sem passar pelo `o_audio_manager`.
- `if(room = rm_opcoes && ...)` usa atribuição como comparação (funciona em GML, mas é armadilha).
- Usa `keyboard_check(vk_escape)` em vez de `keyboard_check_pressed`.
- Loop `for` que atribui `_max_texto_largura = 200` a cada iteração (resquício de refatoração).
- Não há opção de música/SFX separados, nem calibração de latência (necessária para jogo de ritmo).
- **As opções não são salvas** (ver PS-01).

### 🟡 UI-06 — Textos e escalas fixos em pixels

Praticamente todo posicionamento é hardcoded (`955`, `550`, `640`, `720`, `_box_y = 200`...).
Qualquer mudança de resolução ou de fonte exige recalibrar tudo na mão. Não há helper de layout.

### 🟡 UI-07 — `o_tela_tutorial` desenha o texto em `y` fixo (220) fora do painel

Enquanto o painel é posicionado relativo à base da tela, o texto de instruções usa `220` absoluto —
os dois só coincidem por acaso na resolução atual. O mesmo bloco aparece duplicado em
`o_tela_settings` (objeto morto).

### 🟡 UI-08 — Créditos podem deixar rastro

`rooms/rm_creditos/rm_creditos.yy` tem `clearDisplayBuffer: false` e `clearViewBackground: false`,
e a room não tem fundo — nada limpa a tela entre frames. 🔬 Confirmar em execução: o texto rolando
provavelmente deixa "borrão".

### 🔵 UI-09 — Seletor de fases preparado para grade, usado como linha

`o_seletor_fases` calcula linhas/colunas (3 por linha), mas a navegação só é horizontal com wrap —
com 4+ fases (Sprint 7) as fases da segunda linha ficarão inacessíveis por navegação vertical.
**Precisa ser resolvido junto com o Modo Livre.**

### 🔵 UI-10 — Nome de janela e branding

`option_windows_display_name` está como `"Pixel Game"`. Ícone e splash do executável são os padrões
do GameMaker. Para apresentação institucional, vale ajustar.

---

## 5. Achados — Persistência, arcade e projeto

### 🔴 PS-01 — Zero persistência em disco

Não há nenhuma escrita de arquivo no projeto. Isso significa que **o leaderboard (Sprint 4) começa
do zero**, mas também que hoje volume e tela cheia são perdidos a cada execução — o que, numa
cabine, obriga alguém a reconfigurar toda vez que o jogo reiniciar.

### 🟠 AR-01 — Nada preparado para operação desassistida

Para o cenário de feira faltam: *attract mode* (demo/atrator quando ocioso), reset automático por
inatividade, bloqueio da opção "Sair do Jogo" (hoje qualquer visitante pode fechar o jogo com
`game_end()`), início em tela cheia por padrão e bloqueio de `Alt+F4`/`Alt+Tab`.

### 🟠 AR-02 — Sem suporte a controle / painel arcade

Nenhuma chamada `gamepad_*`. Se o gabinete usar um encoder que emula teclado (iPac, Zero Delay),
**boa parte funciona por acaso** — desde que os botões estejam mapeados em setas/WASD/Enter/ESC.
Se for um controle XInput/DirectInput, **nada funciona**. Como o input está espalhado e duplicado em
8 objetos, adicionar controle sem refatorar significa tocar em 8 arquivos e manter 3 caminhos de
código em paralelo.

### 🟡 PJ-01 — Recursos órfãos e arquivos mortos

| Item | Situação |
|---|---|
| `o_controlador_titulo` | Fora do `.yyp`; referencia `o_controlador_geral.iniciar_transicao_camera`, que não existe |
| `o_menu_selecao_arma` | Fora do `.yyp`; menu antigo de seleção de armas |
| `o_tela_settings` | No `.yyp`, mas nunca instanciado — cópia de `o_tela_tutorial` |
| `o_linha_nota` | No `.yyp`, sprite 1x1, nunca instanciado |
| `rm_titulo`, `rm_menu_principal`, `rm_resultado` | Rooms vazias fora do `.yyp` |
| 9 sons antigos (`martelada1-3`, `MusicaDificuldade*`, `MusicaGameOver`) | Fora do `.yyp` |
| `s_fundo_ceu`, `f_padrao_1` | Fora do `.yyp` |
| `rooms/rm_forja/InstanceCreationCode_inst_78BF2821.gml` | Creation code de instância inexistente — e contém `minha_tecla = vk_right` (escalar, não array), que quebraria `minha_tecla[0]` se a instância voltasse |
| 8 arquivos `*.old.*` em `fonts/` | Lixo do IDE |
| `HammerTempo.rar` (1,9 MB) + `HammerTempo-main.zip` (176 KB) | Backups versionados no git |

### 🟡 PJ-02 — Sem scripts, sem reuso

Zero arquivos em `scripts/`. Padrões repetidos que deveriam ser funções:

- Caixa pulsante (`sin(current_time * 0.004)`) — copiada em **5** lugares.
- `keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)` — em **6** objetos.
- Bloco de desenho de painel + opções — duplicado entre menu e opções.
- `o_tela_tutorial` / `o_tela_settings` — arquivos praticamente idênticos.

### 🟡 PJ-03 — Números mágicos comparados a enums

`o_hitbox_bom`, `o_hitbox_perfeito`, `o_zona_erro` e `o_seletor_fases` comparam
`estado_jogo == 2` / `!= 1` com comentários explicando o número, em vez de usar o `enum` — que já
existe. Se alguém inserir um estado novo no meio do enum (por exemplo `ARCADE_TRANSICAO`),
**esses objetos silenciosamente param de funcionar**. Risco direto para as Sprints 4 e 6.

### 🔵 PJ-04 — Nome do projeto e comentários

O `.yyp` ainda se chama `Jorge's Smith 2.0`. Há comentários desatualizados (o array de cores do
background diz "Dia Padrão" no índice errado — sem efeito prático, porque as duas primeiras cores
são idênticas), comentários de refatoração antiga (">>> A CORREÇÃO ESTÁ AQUI <<<") e blocos grandes
comentados dentro de arquivos ativos.

### 🔵 PJ-05 — Sem README nem instruções de build

Não há README, nem documentação de como abrir/rodar o projeto, nem changelog.

---

## 6. Resumo por prioridade

| # | Achado | Severidade | Sprint sugerida |
|---|---|---|---|
| CV-01 | Duplicação de instâncias persistentes | 🔴 | 2 — Refino técnico |
| CV-02 | Música muda ao repetir fase | 🔴 | 2 |
| GP-04 | `spam_detect` encerra a partida | 🔴 | 2 |
| UI-02 | Ausência total de HUD | 🔴 | 3 — UI/UX |
| GP-01 | Janela "perfeito" de 1 frame | 🔴 | 2 (paliativo) / 5 (definitivo) |
| GP-02 | Zonas mortas de julgamento | 🔴 | 2 / 5 |
| GP-03 | Notas dessincronizadas da música | 🔴 | 5 — Algoritmo de ritmo |
| PS-01 | Zero persistência | 🔴 | 4 — Leaderboard |
| UI-01 | Conflito 720p/768p GUI vs room | 🟠 | 2 (antes da Sprint 3) |
| AR-02 | Sem suporte a controle | 🟠 | 3.5 — Input arcade |
| AR-01 | Sem modo de operação desassistida | 🟠 | 6 — Modo Arcade |
| CV-04 | Áudio uncompressed | 🟠 | 2 |
| UI-03/04 | Feedback visual mínimo, zona BOM invisível | 🟠 | 3 |
| CV-03 | Corte brusco do tema | 🟠 | 3 |
| GP-05 | Modo infinito quebrado | 🟠 | 7 |
| CV-07 | Sem pausa/saída | 🟡 | 3 |
| UI-05..09 | Opções, layout, créditos, seletor | 🟡 | 3 |
| PJ-01..05 | Órfãos, reuso, enums, README | 🟡/🔵 | 2 |

---

## 7. Status após a Sprint 2 (Refino técnico)

Validado com build real (runtime 2024.13.1.242) e captura de tela a cada etapa.

| ID | Achado | Status |
|---|---|---|
| CV-01 | Duplicação de instâncias persistentes | ✅ **Fechado** — 5 ciclos forja↔menu mantêm `controladores: 1, audio: 1, fundo: 1` e 60 FPS |
| CV-02 | Música muda ao repetir fase | ✅ **Fechado** — rejogando a mesma fase: `snd_fase_01 tocando gain 1.00` |
| GP-04 | `spam_detect` encerrava a partida | ✅ **Fechado** — ~500 toques inválidos numa partida não encerram nada; custam 10 pontos cada |
| GP-01 | Janela "perfeito" de 1 frame | ✅ **Fechado** — julgamento por tempo, ±3 frames (±50 ms) |
| GP-02 | Zonas mortas de julgamento | ✅ **Fechado** — janela única de ±8 frames, sem faixas cegas; nota perdida usa o mesmo limite |
| GP-06 | Janelas em pixels, não em tempo | ✅ **Fechado** — exigência idêntica em todas as fases |
| GP-05 | Modo infinito quebrado | ✅ **Fechado** — `intervalo_min/max` inicializados |
| UI-01 | Conflito 720p/768p | ✅ **Fechado** — `rm_splash` em 1280x720 + `display_set_gui_size(1280,720)` |
| UI-07 | Texto do tutorial em Y absoluto | ✅ **Fechado** — tudo relativo ao painel |
| UI-08 | Créditos com rastro | ✅ **Fechado** — `clearViewBackground` ligado em todas as rooms |
| CV-04 | Áudio uncompressed | ✅ **Fechado** — músicas em *Compressed – Streamed* (convertidas para Ogg no build) |
| CV-05 | `randomize()` a cada resultado | ✅ **Fechado** — uma vez, no boot |
| PS-01 | Zero persistência | ✅ **Fechado** — `hammertempo_save.json` grava opções e já tem a estrutura do leaderboard |
| PJ-01 | Recursos órfãos | ✅ **Fechado** — 2 objetos, 3 rooms, 9 sons, 1 sprite, 1 fonte, 8 `.old` e o creation code fantasma removidos |
| PJ-02 | Sem scripts / código repetido | ✅ **Fechado** — `scr_estados`, `scr_input`, `scr_ui`, `scr_save`, `scr_ritmo`, `scr_debug` |
| PJ-03 | Números mágicos no lugar de enums | ✅ **Fechado** |
| PJ-04/05 | Nome do projeto, README | ✅ **Fechado** — `HammerTempo.yyp`, janela "HammerTempo", README na raiz |
| AR-02 | Sem suporte a controle | 🟡 **Parcial** — camada de ações pronta e já lendo gamepad; falta remapeamento e ícones (Sprint 3.5) |
| UI-02 | Sem HUD | ⬜ Sprint 3 |
| UI-03/04 | Feedback visual, zonas invisíveis | ⬜ Sprint 3 (ver D-09) |
| CV-03 | Corte brusco do tema | ⬜ Sprint 3 |
| CV-06 | Transições sem fade | ⬜ Sprint 3 |
| CV-07 | Sem pausa | ⬜ Sprint 3 |
| UI-05/06/09 | Opções, layout, seletor em grade | 🟡 Parcial — opções já salvam e têm linha de ajuda; o resto na Sprint 3 |
| GP-03 | Notas dessincronizadas da música | ⬜ Sprint 5 |
| GP-07/08 | Prioridade de nota, notas restantes no total | ⬜ Sprint 5 |
| AR-01 | Operação desassistida | ⬜ Sprint 6 |

### Achados novos, descobertos durante a validação da Sprint 2

| ID | Achado | Severidade | Status |
|---|---|---|---|
| PJ-06 | A instância do gerenciador de fundo em `rm_forja` estava **desativada** (`ignore: true`): o parallax da forja vinha da instância persistente do menu | 🟠 | ✅ Corrigido — instância habilitada |
| UI-12 | `rm_opcoes` e `rm_creditos` nunca tiveram fundo próprio e não limpavam a superfície: sem o objeto persistente, exibiam o **último frame congelado** da room anterior | 🟠 | ✅ Corrigido — cada room tem seu fundo e limpa a superfície |
| UI-11 | Os créditos começavam 3020 px abaixo do topo — **~25 s de tela vazia** antes do primeiro texto aparecer | 🟡 | ✅ Corrigido — a rolagem começa logo abaixo da tela |
| UI-13 | Na tela de resultado, a frase de feedback colidia com o prompt depois da mudança de GUI | 🟡 | ✅ Corrigido — linhas reposicionadas |
| GP-09 | Sob *mashing* extremo, a penalidade de 10 pontos por toque inválido zera a pontuação da partida | 🔵 | Aberto — decisão de balanceamento, precisa de playtest |
