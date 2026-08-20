# HammerTempo — Documentação de Arquitetura (estado atual)

> Documento gerado na **Sprint 1 (Documentação)**. Descreve o projeto exatamente como ele está
> hoje no repositório (branch `main`, commit `c1e3dba`), sem propor mudanças.
> Achados e propostas estão em `02-AUDITORIA.md` e `03-ROADMAP-SPRINTS.md`.

---

## 1. Identidade do projeto

| Item | Valor |
|---|---|
| Nome do jogo | **HammerTempo** |
| Nome do arquivo de projeto | `Jorge's Smith 2.0.yyp` (divergente do nome do jogo) |
| Engine | GameMaker Studio 2 — IDE `2024.13.1.193` (runtime instalado na máquina: `2024.13.1.242`) |
| Gênero | Rhythm game ("guitar hero like") com tema de forja medieval |
| Equipe | Panela Games — Beatrice Fischer, Gabriele Maria Freiberger, Gustavo Hreczuck, Lucas de Carvalho Ziele, Raul Schmitz |
| Contexto | Game Jam de 5 dias (faculdade) — outubro/2025 |
| Licença | Ver `LICENSE` + bloco de créditos em `o_creditos/Create_0.gml` |
| Alvo de build | Windows (única plataforma com opções configuradas) |

### Configurações globais relevantes

- `option_game_speed`: **60 fps**
- `option_windows_allow_fullscreen_switching`: `false`
- `option_windows_resize_window`: `false`, `option_windows_scale`: `0` (mantém proporção)
- `option_windows_vsync`: `false`
- `option_windows_display_name`: `"Pixel Game"` (placeholder, não personalizado)
- `option_windows_interpolate_pixels`: `false` (correto para pixel art)

---

## 2. Inventário de recursos

| Tipo | Registrados no `.yyp` | Existem em disco | Órfãos (em disco, fora do projeto) |
|---|---|---|---|
| Objects | 25 | 27 | `o_controlador_titulo`, `o_menu_selecao_arma` |
| Rooms | 5 | 8 | `rm_titulo`, `rm_menu_principal`, `rm_resultado` (vazias, 1366x768) |
| Sounds | 18 | 25 | `martelada1-3`, `Martelada4`, `MusicaDificuldade{Facil,Media,Rapida,Extrema}`, `MusicaGameOver` |
| Sprites | 71 | 72 | `s_fundo_ceu` |
| Fonts | 2 | 3 | `f_padrao_1` |
| Scripts | **0** | 0 | — |

**Não existe nenhum script (`scripts/`)**: 100% da lógica vive em eventos de objetos, e as funções
reutilizáveis são declaradas como *métodos de instância* dentro de eventos `Create`
(`o_audio_manager`, `o_ferreiro`, `o_nota_seta`, `o_transicao`, `o_controlador_geral`).
São **62 arquivos `.gml`, ~2.200 linhas** no total.

### Fontes

Ambas derivadas de **Kobold 7** (pixel font): `f_padrao` (30 px) e `f_padrao_pequena` (23 px).

### Áudio

Todas as faixas estão marcadas como **não comprimidas / não transmitidas** (`compression: 0`).

| Asset | Duração | Uso |
|---|---|---|
| `snd_tema` | 16,0 s | Música de menu / seleção de fase |
| `snd_fase_01` | 57,3 s | Fase 1 — Adaga (*Istampitta Ghaetta*) |
| `snd_fase_02` | 83,8 s | Fase 2 — Lança (*Des Oge Mais Quer' Eu Trobar*) |
| `snd_fase_03` | 182,3 s | Fase 3 — Espada (*Des Oge Mais Quer' Eu Trobar*) |
| `snd_fase_04` | 198,2 s | **Não usado** (fase Machado está comentada) |
| `snd_martelada_01..05` | 0,5 s cada | SFX de acerto, tocados em sequência ping-pong |
| `snd_menu01` / `snd_menu02` | 0,5 s | SFX de navegação (alternados) |
| `snd_menu_confirm` / `snd_menu_return` | 0,5 / 0,44 s | Confirmar / voltar |
| `snd_resultado_bom` / `snd_resultado_ruim` | 16,0 / 8,6 s | Jingle da tela de resultado |

---

## 3. Rooms e fluxo de telas

| Room | Dimensão | Persistente | Instâncias |
|---|---|---|---|
| `rm_splash` | **1366x768** | não | `o_splash_controlador`, `o_transicao`, `o_audio_manager` |
| `rm_menu` | 1280x720 | não | `o_menu_controlador`, `o_controlador_geral`, `o_background_manajer_forja` |
| `rm_forja` | 1280x720 | **sim** | 4x `o_buttons_forja`, `o_hitbox_perfeito`, `o_hitbox_bom`, `o_zona_erro`, `o_seletor_fases`, `o_bigorna`, `o_forja`, `o_fundo_ui`, `o_ferreiro`, `o_fumaca`, `o_background_manajer_forja` |
| `rm_creditos` | 1280x720 | não | `o_creditos` |
| `rm_opcoes` | 1280x720 | não | `o_controlador_opcoes` |

**Nenhuma room habilita views/viewports** (`enableViews: false`) e **nenhum código chama
`display_set_gui_size()` / `display_set_gui_maximise()`**. Logo, o gameplay é desenhado em
coordenadas de room (1280x720) e toda a UI é desenhada no *Draw GUI* usando
`display_get_gui_width/height()` — dois espaços de coordenadas diferentes.

### Fluxo (máquina de estados + rooms)

```
rm_splash (2 s + fade via o_transicao)
   |
   +--> rm_menu -- "Comecar Jogo"
           |-- 1a vez --> estado TUTORIAL ----> rm_forja --> o_tela_tutorial --(Enter)--+
           +-- demais --> estado SELECAO_FASE --> rm_forja ------------------------------+
                                                                                        |
                                                                                        v
                                                            o_seletor_fases (grade horizontal)
                                                                        | Enter
                                                                        v
                                                            estado CONTAGEM (3 s)
                                                                        |
                                                                        v
                                                            estado RITMO (cria o_spawner_ritmo)
                                                    +-------------------+------------------+
                                            fim por tempo                        fim por erros
                                  (duracao + 4 s de tolerancia)        (sequencia errada / spam)
                                                    +-------------------+------------------+
                                                                        v
                                                            estado RESULTADO (o_controlador_resultado)
                                                                        | Enter
                                                                        v
                                                            estado SELECAO_FASE (volta ao seletor)

rm_menu -- "Opcoes"   --> rm_opcoes   --(Aplicar/ESC)--> rm_menu
rm_menu -- "Creditos" --> rm_creditos --(fim/Enter/ESC)--> rm_menu
rm_menu -- "Sair"     --> game_end()
```

---

## 4. Objetos — responsabilidades

### 4.1 Controle e estado

**`o_controlador_geral`** (persistente, criado em `rm_menu`) — cérebro do jogo.

- Define `enum MINIGAME { NENHUM, SELECAO_FASE, TUTORIAL, CONTAGEM, RITMO, TEMPERA, AFIACAO, RESULTADO }`.
  `TEMPERA` e `AFIACAO` **nunca são usados** (minigames planejados, não implementados).
- Guarda `estado_jogo`, `fase_atual`, `pontuacao`, `pausa`, `tutorial_ja_foi_visto`, `contagem_timer`.
- Guarda as estatísticas da partida: `stats_total_notas`, `stats_acertos_perfeitos`,
  `stats_acertos_bons`, `stats_erros`, `stats_sequencia` (combo), `stats_sequencia_errada`,
  `stats_spam_detect`, além da função `resetar_estatisticas()`.
- Guarda o **catálogo de fases** (`fases_data`, array de structs) — ver seção 5.
- No `Step`, roteia por estado: cria `o_tela_tutorial`, `o_seletor_fases` e `o_spawner_ritmo`
  sob demanda, mantém a música tocando e checa a condição de *game over*.
- No `Draw GUI`, desenha a contagem regressiva. **O HUD do estado RITMO está vazio**
  (as linhas de pontuação e estado estão comentadas).

**`o_transicao`** (persistente, criado em `rm_splash`) — fade preto universal
(`enum FADE {IN, OUT, IDLE}`), com `mudar_de_sala()` e `mudar_de_sala_imediato()`.
**Só é efetivamente usado no splash.**

**`o_audio_manager`** (persistente, criado em `rm_splash`) — `play_sfx()`, `play_music()`,
`stop_music()`, `fade_out_music()` e o sequenciador de marteladas
`play_martelada_sequencial_sfx()` (percorre `snd_martelada_01..05` em vai-e-vem).

### 4.2 Gameplay de ritmo

**`o_spawner_ritmo`** — criado ao entrar em RITMO, na posição `x = room_width + 120` (**1400**).

- Lê a fase atual e configura duração, velocidade e tipos de seta permitidos.
- Converte BPM em frames: `beat_interval_frames = (60 / bpm) * room_speed`.
- Sorteia **um** padrão de `ritmo_patterns` e o repete em loop até o fim da fase.
- `Alarm 0` = criar nota + reagendar (`alarm[0] = multiplicador * beat_interval_frames`).
- `Step` decrementa a duração; ao zerar, entra em "finalizando" e arma o `Alarm 1` (4 s), que
  espera todas as notas saírem da tela antes de abrir a tela de resultado.

**`o_nota_seta`** — move-se para a esquerda (`x -= velocidade`), `image_index = tipo_seta`.
Ao ser acertada ou perdida entra em `esta_morrendo` (fade de `image_alpha`; sobe 2 px/frame se
acertada). A colisão com `o_zona_erro` conta erro, tira 50 pontos, zera o combo e tinge o ferreiro
de vermelho.

**`o_buttons_forja`** — 4 instâncias em `x = 98`, uma por lane. O mapeamento vem do
*Instance Creation Code* de cada instância:

| Instância | y | Sprite | Teclas | `meu_tipo` |
|---|---|---|---|---|
| `inst_60744E91` | 515 | `s_alvo_cima` | `↑` / `W` | 1 |
| `inst_EF4E08E` | 565 | `s_alvo_esquerda` | `←` / `A` | 3 |
| `inst_67F047DB` | 615 | `s_alvo_direita` | `→` / `D` | 2 |
| `inst_59F06AAB` | 665 | `s_alvo_baixo` | `↓` / `S` | 0 |

O spawner converte `tipo → y` com o mapeamento inverso (`0→665, 1→515, 2→615, 3→565`).
Como o tipo é sorteado com `irandom(tipos_permitidos - 1)`, a progressão de dificuldade libera as
lanes nesta ordem: **baixo, cima, direita, esquerda**.

**`o_hitbox_perfeito` / `o_hitbox_bom` / `o_zona_erro`** — zonas de julgamento, definidas por
sprite + escala aplicada na room:

| Objeto | Sprite | Escala na room | Área efetiva (x, y) |
|---|---|---|---|
| `o_hitbox_perfeito` | `o_zona_perfeita` 2x64 | 2 x 3,75 | x ∈ [98, 102) · y ∈ [492, 732) |
| `o_hitbox_bom` | `o_zona_bom` 2x15 | 6 x 16 | x ∈ [114,5, 126,5) · y ∈ [495, 735) |
| `o_zona_erro` | `Zona_morta` 64x64 | 0,875 x 3,75 | x ∈ [0, 56) · y ∈ [492, 732) |

**`o_ferreiro`** — máquina de estados de animação
(`IDLE`, `MARTELANDO`, `COMEMORANDO`, `FALHA`, `FALHOU_ESTATICO`) com sprites de 240x240 e origem
no pé (120, 240). Expõe `iniciar_martelada_normal()`, `iniciar_martelada_perfeita()`
(que também cria `o_faisca` na bigorna), `aplicar_shade_erro()`, `iniciar_comemoracao()` e
`iniciar_animacao_falha()`.

**`o_background_manajer_forja`** (persistente) — parallax de 4 conjuntos de cenário
(manhã / dia / tarde / noite), cada um com velocidades próprias por camada, crossfade automático a
cada 20 s (transição de 10 s) e cor de fundo interpolada.

### 4.3 Interface

| Objeto | Papel |
|---|---|
| `o_menu_controlador` | Menu principal (logo + painel + 4 opções + seletor pulsante) |
| `o_seletor_fases` | Grade de fases (3 por linha, navegação horizontal com wrap) |
| `o_tela_tutorial` | Overlay de instruções antes da primeira partida |
| `o_controlador_resultado` | Tela de resultado: stats, frase, arma forjada + moldura |
| `o_controlador_opcoes` | Volume (0–10) e tela cheia |
| `o_creditos` | Rolagem de créditos/licenças |
| `o_splash_controlador` | Logos institucionais |
| `o_tela_settings` | **Não instanciado** — cópia quase idêntica de `o_tela_tutorial` |

Todos usam o mesmo vocabulário visual: painel (`s_menu_background_panel` / `s_option_menu` /
`s_tutorial`), texto amarelo no item selecionado, retângulo preto com alpha pulsante
(`sin(current_time * 0.004)`, alpha 0,15 → 0,5) e o cursor `s_menu_seletor`.

---

## 5. Modelo de dados das fases

`o_controlador_geral/Create_0.gml` define `fases_data` como array de structs:

```gml
fases_data[i] = {
    nome, dificuldade, musica_fase,
    sprites_resultado: [5 sprites, do pior ao melhor],
    duracao_segundos, velocidade_notas, tipos_seta_permitidos,
    stats_limite_sequencia_errada,
    beat_tempo_bpm, ritmo_patterns: [ [multiplicadores de batida], ... ]
};
```

| # | Nome | Dificuldade | Música | Duração | Vel. | Lanes | Limite de erros seguidos | BPM | Padrões |
|---|---|---|---|---|---|---|---|---|---|
| 0 | Forjar Adaga | Fácil | `snd_fase_01` | 40 s | 4 | 2 | 4 | 88 | 3 padrões |
| 1 | Forjar Lança | Médio | `snd_fase_02` | 40 s | 5 | 3 | 5 | 100 | 1 padrão |
| 2 | Forjar Espada | Difícil | `snd_fase_03` | 60 s | 5 | 4 | 6 | 108 | 1 padrão |
| — | Forjar Machado | Extremo | `snd_fase_04` | 60 s | 6 | 4 | 6 | 125 | **comentada** |
| — | Modo Infinito | Progressiva | — | ∞ | 4→12 | 2→4 | 6 | **comentada** |

Os `ritmo_patterns` são multiplicadores da duração da batida:
`1` = semínima, `0.5` = colcheia, `2`/`3` = pausas longas.

---

## 6. Regras de jogo (como está implementado)

### Pontuação

| Evento | Efeito |
|---|---|
| Acerto **PERFEITO** | `+100 + (10 × combo)`, combo++, zera a sequência de erros |
| Acerto **BOM** | `+50 + (5 × combo)`, combo++, zera a sequência de erros |
| Nota perdida (entra na zona de erro) | `−50`, `stats_erros++`, `stats_sequencia_errada++`, combo = 0 |
| Tecla pressionada sem nota correspondente | `stats_spam_detect++` |

### Fim de partida

1. **Por tempo** — `duracao_segundos` + 4 s de tolerância + espera todas as notas saírem.
2. **Por erros** — `stats_sequencia_errada >= limite_da_fase` **ou** `stats_spam_detect >= 10`.

### Avaliação final (`o_controlador_resultado`)

`% = (perfeitos + bons) / total_de_notas`

| Faixa | Índice | Arma | Moldura | Frase | Ferreiro |
|---|---|---|---|---|---|
| < 40% | 0 (Falha) | `sprites_resultado[0]` | `s_canva01` | frases_ruins | animação de falha |
| 40–69% | 1 (Aceitável) | `[1]` | `s_canva02` | frases_ruins | animação de falha |
| 70–94% | 2 (Bom) | `[2]` | `s_canva03` | frases_boas | comemoração |
| 95–99% | 3 (Excelente) | `[3]` | `s_canva04` | frases_boas | comemoração |
| 100% | 4 (Perfeito) | `[4]` | `s_canva05` | frases_otimas | comemoração |

> A pontuação **não** entra no cálculo da avaliação — só a taxa de acerto.

---

## 7. Geometria e temporização do minigame

Constantes medidas a partir do código e da room:

| Grandeza | Valor |
|---|---|
| Nascimento da nota | `x = 1400` |
| Linha de acerto (alvos) | `x = 98` |
| Distância percorrida até o alvo | ≈ **1300 px** |
| Máscara da nota / do alvo | 45 x 42 px (bbox cheia, origem no canto superior esquerdo) |
| Lanes (y) | 515 · 565 · 615 · 665 (espaçamento de 50 px) |

**Tempo de viagem da nota** (spawn → linha de acerto):

| Fase | Velocidade | Frames | Segundos | Duração da batida | Viagem em batidas |
|---|---|---|---|---|---|
| 1 — Adaga | 4 px/f | ~325 | **5,42 s** | 0,682 s (88 BPM) | 7,95 |
| 2 — Lança | 5 px/f | ~260 | **4,33 s** | 0,600 s (100 BPM) | 7,22 |
| 3 — Espada | 5 px/f | ~260 | **4,33 s** | 0,556 s (108 BPM) | 7,80 |

**Janelas de julgamento** (derivadas da sobreposição das máscaras — análise em `02-AUDITORIA.md`):

| Julgamento | Faixa de `x` da nota | Largura | Duração @ 5 px/f |
|---|---|---|---|
| Detecção (há nota sob o alvo) | 53 → 143 | 90 px | ~300 ms |
| **PERFEITO** | 97 → 102 | **5 px** | **~17 ms (1 frame)** |
| **BOM** | 69,5 → 126,5 (menos a faixa perfeita) | ~52 px | ~170 ms |
| Zona morta (acerta a tecla e nada acontece) | 126,5→143 e 53→69,5 | ~33 px | ~110 ms |
| Erro (nota atinge a zona morta) | `x < 56` | — | — |

---

## 8. Entrada (input)

- **Somente teclado.** Nenhuma chamada a `gamepad_*` existe no projeto.
- Gameplay: `↑↓←→` **ou** `WASD` (arrays `minha_tecla` no creation code das instâncias).
- Menus: `↑↓` / `WS` para navegar, `Enter` ou `Espaço` para confirmar, `ESC` para voltar
  (só no seletor de fases, nas opções e nos créditos).
- As checagens de teclado estão **espalhadas e duplicadas** em 8 objetos; não há camada de
  abstração de input, nem remapeamento, nem suporte a controle.

---

## 9. Persistência

**Não existe nenhuma persistência em disco.** Nenhuma chamada a `ini_*`, `file_*`, `json_*`,
`buffer_*` ou `game_save*` no projeto. Consequências:

- Volume e tela cheia voltam ao padrão a cada execução.
- Não há recordes, progresso ou desbloqueios.
- Não há base sobre a qual construir o leaderboard (Sprint 4) — precisará ser criada do zero.
