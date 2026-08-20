# HammerTempo — Roadmap de Micro Sprints

> Plano de trabalho derivado de `02-AUDITORIA.md`, organizado nas frentes definidas pela equipe,
> com a frente de **controle/arcade** acrescentada. Cada sprint termina com uma **validação
> explícita** antes da próxima começar.

## Princípio de ordenação

Duas frentes precisam vir **antes** do polimento, senão o trabalho é refeito:

1. **Espaço de coordenadas (UI-01)** — ajustar 1280x720 vs 1366x768 e a camada GUI *antes* de
   posicionar qualquer elemento novo de HUD.
2. **Camada de input (AR-02)** — criar a abstração de ações *antes* de espalhar mais
   `keyboard_check` por novas telas (leaderboard, pausa, modo arcade).

Por isso a ordem proposta é: **Refino técnico → UI/UX → Input arcade → Leaderboard → Ritmo →
Modo Arcade → Mais fases**, com a frente de input podendo ser puxada para dentro da Sprint 2 se o
hardware já estiver definido.

---

## Sprint 1 — Documentação ✅

**Entregue:** `01-ARQUITETURA.md`, `02-AUDITORIA.md`, `03-ROADMAP-SPRINTS.md`.

---

## Sprint 2 — Refino técnico (fundação) ✅ — validado em build real

**Objetivo:** deixar o jogo estável e o código pronto para receber as próximas frentes.
Nada de recurso novo visível — é a sprint que evita retrabalho.

### 2.1 Correções críticas
| Item | Ação |
|---|---|
| CV-01 | Mover **todos os singletons** (`o_controlador_geral`, `o_audio_manager`, `o_transicao`, `o_background_manajer_forja`, `o_controlador_opcoes`) para `rm_splash`, removendo-os das demais rooms. Guarda extra no `Create`: `if (instance_number(object_index) > 1) { instance_destroy(); exit; }` |
| CV-02 | Reescrever `play_music()`: parar explicitamente a faixa anterior, resetar o ganho para 1 ao iniciar, e usar `fade_out_music()` na tela de resultado em vez de mexer no ganho do asset |
| GP-04 | Trocar `spam_detect` acumulado por **sequência de toques inválidos consecutivos** (sugestão: só penaliza pontos, não encerra a partida) |
| GP-01/02 | Correção paliativa das janelas: alargar o "perfeito" para ~±3 frames e eliminar as zonas mortas (todo acerto dentro da faixa de detecção vira BOM). A solução definitiva vem na Sprint 5 |
| UI-01 | Padronizar `rm_splash` em 1280x720 e fixar `display_set_gui_size(1280, 720)` no bootstrap |
| CV-04 | Marcar as 5 músicas como *Compressed – Streamed* |
| GP-05 | Inicializar `intervalo_min`/`intervalo_max` no `Create` do spawner |

### 2.2 Fundação de código
- Criar `scripts/`:
  - `scr_input` — camada de ações (base da Sprint 3.5)
  - `scr_ui` — helpers de desenho (caixa pulsante, painel, texto com sombra, prompt)
  - `scr_save` — leitura/escrita de JSON (base da Sprint 4)
  - `scr_debug` — overlay de diagnóstico (FPS, estado, contadores) ligável por tecla
- Substituir todos os `estado_jogo == 2` por `MINIGAME.RITMO` (PJ-03)
- Extrair a caixa pulsante e o prompt "Enter/Espaço" para `scr_ui`

### 2.3 Higiene
- Remover órfãos: `o_controlador_titulo`, `o_menu_selecao_arma`, `o_tela_settings`, `o_linha_nota`,
  `rm_titulo`, `rm_menu_principal`, `rm_resultado`, sons antigos, `s_fundo_ceu`, `f_padrao_1`,
  `*.old.*`, `InstanceCreationCode_inst_78BF2821.gml`
- Tirar `HammerTempo.rar` e `HammerTempo-main.zip` do versionamento (decisão da equipe)
- README com instruções de abrir/rodar/build
- Renomear o projeto para `HammerTempo` e ajustar `option_windows_display_name`

**Validação:** rodar o jogo e percorrer o checklist — menu → fase → resultado → repetir a **mesma**
fase (música toca?) → ESC → menu → repetir 5 ciclos (FPS estável? estado correto?) → tela cheia.

---

## Sprint 3 — UI/UX ← PRÓXIMA

**Objetivo:** o jogador entender o que está acontecendo, o tempo todo.

### 3.1 HUD de partida (UI-02) — o item de maior impacto
- Pontuação com contagem animada (*tween*), canto superior direito
- **Combo** grande, com escala pulsante a cada acerto e queda visível ao errar
- **Julgamento** ("PERFEITO!" / "BOM!" / "ERROU") no centro-baixo, com pop + fade
- **Barra de integridade da forja**: representa `stats_sequencia_errada` contra o limite da fase —
  o jogador precisa ver que está perto do game over
- **Barra de progresso** da fase (quanto falta para a arma ficar pronta)
- Contador de notas restantes / porcentagem de acerto em tempo real

### 3.2 Feedback (UI-03/04)
- Flash e "afundamento" do alvo ao ser pressionado
- Partículas por lane no acerto (reaproveitar `o_faisca`), intensidade por julgamento
- Screen shake sutil no PERFEITO; tint vermelho já existente no erro
- Barra de acerto visível: desenhar as zonas BOM/PERFEITO de forma legível (`visible: true`)
- Brilho crescente na forja conforme o combo sobe (usa `s_forja` + blend)

### 3.3 Fluxo e navegação
- Pausa (ESC) com "Continuar / Reiniciar / Sair para o menu" (CV-07)
- Fade em **todas** as transições via `o_transicao` (CV-06)
- Música da fase começando junto com a contagem regressiva, com crossfade do tema (CV-03)
- Tela de resultado: mostrar também combo máximo, precisão e a nova pontuação máxima

### 3.4 Menus
- Opções: volume de **música** e **SFX** separados, tela cheia, **calibração de latência**,
  SFX de navegação, salvar em disco
- Tutorial refeito com ícones das teclas **e** dos botões do controle
- Seletor de fases com arte da arma, dificuldade, BPM e melhor pontuação local

**Validação:** sessão de teste com 3–5 pessoas de fora da equipe, cronometrando quanto tempo levam
para entender o objetivo sem explicação verbal.

---

## Sprint 3.5 — Input arcade (frente nova)

**Objetivo:** o jogo funcionar num gabinete com controle arcade, sem depender do teclado.

### 3.5.1 Camada de ação (`scr_input`)
```gml
// Ações do jogo, independentes do dispositivo
enum ACAO { LANE_CIMA, LANE_BAIXO, LANE_ESQ, LANE_DIR, CONFIRMAR, VOLTAR, PAUSAR, START }
input_pressed(ACAO.CONFIRMAR)   // teclado OU gamepad, consulta única
```
- Todos os objetos passam a consultar `input_*` — nenhum `keyboard_check` espalhado
- Suporte simultâneo a **teclado** e **gamepad** (`gamepad_button_check_pressed`,
  `gp_padu/gp_padd/gp_padl/gp_padr`, `gp_face1..4`, `gp_start`, além dos eixos com *deadzone*)
- Detecção automática do último dispositivo usado → os ícones da UI trocam sozinhos
- Suporte a *hot-plug* (`gamepad_is_connected`) — cabo solto na feira não pode travar o jogo

### 3.5.2 Remapeamento
Tela de configuração de controles com "pressione o botão para a nota de cima..." e persistência
em disco. É o que garante compatibilidade com **qualquer** painel arcade.

> **Nota sobre hardware:** muitos gabinetes usam encoders (iPac, Zero Delay) que **emulam teclado**.
> Nesse caso o jogo já funcionaria com setas/WASD/Enter, mas o remapeamento continua necessário
> porque o mapeamento de fábrica de cada encoder é diferente. Se o painel for XInput/DirectInput,
> a camada de gamepad é obrigatória.

**Validação:** jogar uma fase inteira usando **apenas** o controle, incluindo navegar menus,
pausar e digitar o nome no leaderboard.

---

## Sprint 4 — Leaderboard

**Objetivo:** placar arcade local, persistente entre execuções.

### 4.1 Persistência (`scr_save`)
Arquivo JSON na pasta de save do jogo (`game_save_id`), escrito com
`json_stringify` + `buffer_save`, com backup automático e leitura tolerante a arquivo corrompido
(se falhar, recria vazio em vez de travar).

```jsonc
{
  "versao": 1,
  "opcoes": { "vol_musica": 8, "vol_sfx": 10, "fullscreen": true, "offset_ms": 0 },
  "leaderboard": {
    "arcade": [
      { "nome": "GUS", "pontos": 12450, "precisao": 91.2, "fases": 3, "data": "2026-08-20" }
    ],
    "livre": {
      "fase_01": [ { "nome": "BEA", "pontos": 4300, "precisao": 96.0, "data": "2026-08-20" } ],
      "fase_02": [],
      "fase_03": []
    }
  }
}
```

- Chave por **id textual da fase** (`fase_01`), não por índice — assim inserir fases novas não
  embaralha os recordes existentes
- Top 10 por placar

### 4.2 Entrada de nome
Estilo arcade clássico: **3 letras**, seleção por direcionais + confirmar (funciona igual em
teclado e joystick, e é rápido para uma fila de visitantes).

### 4.3 Telas
- Ao final da partida: posição alcançada, destaque se entrou no Top 10, e só então a entrada de nome
- Tela de placar acessível pelo menu principal, com abas **Arcade** e **Livre (por fase)**
- Placar em rotação no *attract mode* (Sprint 6)

**Validação:** registrar 12 pontuações, fechar e reabrir o jogo, conferir ordenação, corte no Top 10
e separação entre os dois modos.

---

## Sprint 5 — Algoritmo de ritmo e auto-track

**Objetivo:** as notas caírem **na batida da música** e o mapeamento deixar de ser aleatório.

### 5.1 Conductor (relógio musical)
Substituir o agendamento por `alarm` por um relógio derivado do próprio áudio:
```gml
tempo_musica = audio_sound_get_track_position(musica) + offset_calibracao;
```
- Cada nota do mapa tem `hit_time` (segundos)
- A nota nasce quando `tempo_musica >= hit_time - tempo_de_viagem`
- Isso elimina de uma vez o drift (GP-03), o desalinhamento por tempo de viagem e a dependência
  de `room_speed`

### 5.2 Julgamento por tempo, não por pixel
```
|erro| <= 45 ms  -> PERFEITO
|erro| <= 90 ms  -> BOM
|erro| <= 140 ms -> OK (pontuação menor, sem quebrar o combo)
       > 140 ms  -> ERRO
```
Valores iniciais, a calibrar em playtest. Resolve GP-01, GP-02 e GP-06 de forma definitiva e torna
as janelas **iguais em todas as fases**, independentemente da velocidade visual das notas.

### 5.3 Formato de mapa (chart)
```jsonc
{
  "musica": "snd_fase_01", "bpm": 88, "offset": 0.412,
  "notas": [ { "t": 0.412, "lane": 1 }, { "t": 0.753, "lane": 0 } ]
}
```
Carregado de *Included File* — permite editar o mapa **sem recompilar o jogo**.

### 5.4 Auto-track — análise automática offline

**Decidido (D-03): só o caminho automático.** O editor de "tap" dentro do jogo foi
descartado.

Um script Python com `librosa` analisa cada faixa e gera o mapa:

1. detecta o BPM e o instante do primeiro downbeat (o `offset` do mapa);
2. detecta os *onsets* de percussão e filtra os que caem na grade de colcheias;
3. distribui as lanes por regra musical (altura da nota, repetição, densidade);
4. exporta o JSON para `datafiles/`, carregado pelo jogo como *Included File*.

Consequências assumidas: a toolchain (Python + librosa) precisa existir na máquina de
desenvolvimento, e o resultado é revisado à mão no arquivo de mapa — não há ferramenta de
edição dentro do jogo.

Em qualquer caminho, a **distribuição de lanes** deixa de ser `irandom()` e passa a seguir regras
musicais (repetir lane em notas repetidas da mesma altura, alternar em escadas, reservar as 4 lanes
para o refrão etc.).

### 5.5 Calibração de latência
Tela de calibração (o jogador bate no ritmo de um metrônomo, o jogo mede o offset médio) salva em
disco. Numa cabine com TV/HDMI, a latência de áudio/vídeo pode passar de 100 ms — sem isso, o mapa
perfeito ainda parece errado.

**Validação:** gravar um vídeo do gameplay e conferir quadro a quadro se as notas chegam na batida;
comparar o desvio médio entre os onsets detectados e os acertos do jogador.

---

## Sprint 6 — Modo Arcade e operação em feira

### 6.1 Seleção de modo
Nova tela após "Começar Jogo":
- **Arcade** — sequência fixa (Adaga → Lança → Espada → Machado), pontuação acumulada,
  placar único no final
- **Livre** — seletor de fases, placar por fase

### 6.2 Regras do Arcade (a validar com a equipe)
- Falhar uma fase **encerra a run** e leva ao placar com o total acumulado (padrão arcade clássico)
- Alternativa: seguir para a próxima fase com penalidade — mais amigável para feira
- Tela de transição entre fases exibindo a arma forjada e o total parcial
- Bônus por conclusão sem falhas

### 6.3 Operação desassistida (AR-01)
- **Attract mode**: após ~60 s de inatividade no menu, entra em demo/tela de placar em rotação
- Reset automático para o menu se a partida ficar parada
- Modo cabine: esconder "Sair do Jogo", iniciar em tela cheia, bloquear atalhos de fechamento
- Contador de partidas jogadas no dia (métrica interessante para a apresentação)

**Validação:** deixar o jogo rodando 30 minutos sem interação e conferir se ele volta sozinho para
um estado jogável, com FPS e memória estáveis.

---

## Sprint 7 — Mais fases

- Reativar **Machado** (Extremo) — `snd_fase_04` e os 5 sprites já existem
- Mapear todas as fases com o pipeline da Sprint 5
- Corrigir e reativar o **Modo Infinito** como fase bônus / desafio do placar
- Avaliar novas músicas de domínio público (a equipe já tem arranjos próprios do Maiko Thomé de
  Araujo, o que evita qualquer risco de licenciamento na apresentação)
- Revisar a curva de dificuldade completa com os mapas reais em mãos

---

## Riscos e dependências

| Risco | Mitigação |
|---|---|
| Hardware do gabinete só ser conhecido às vésperas | Suportar teclado **e** gamepad + tela de remapeamento (Sprint 3.5) |
| Refazer UI depois de mudar a resolução | Resolver UI-01 na Sprint 2, antes da Sprint 3 |
| Toolchain de análise de áudio não disponível | Caminho B (tap chart) não depende de nada externo |
| Bugs de duplicação só aparecerem em uso intenso | Teste de resistência (30 min) na validação da Sprint 6 |
| Escopo maior que o tempo | Sprints 2, 3 e 3.5 já entregam um jogo apresentável; 4–7 são incrementais |
