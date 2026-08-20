# Registro de decisões

Decisões tomadas em conjunto durante o refino do projeto para a feira de profissões.
Cada entrada explica **o que foi decidido** e **por quê**, para que ninguém precise
reabrir a discussão depois.

---

## Sprint 1 — Documentação

**D-01 · Processo de trabalho.** Uma frente por vez, em micro sprints, com validação
explícita antes de começar a próxima. Toda decisão crítica (que altere arquitetura ou
sensação de jogo) é discutida antes de virar código.

**D-02 · Ordem das frentes.** Refino técnico → UI/UX → Input arcade → Leaderboard →
Algoritmo de ritmo → Modo Arcade → Mais fases. O motivo da ordem: resolução/GUI e camada
de input precisam existir antes do polimento visual, senão o trabalho é refeito.

**D-03 · Auto-track sem editor in-game.** O mapeamento das batidas será feito por
**análise automática offline** (caminho A do roadmap). O editor de "tap" dentro do jogo
foi descartado. Consequência: a Sprint 5 depende de uma toolchain de análise de áudio na
máquina de desenvolvimento, e o resultado é revisado à mão no arquivo de mapa.

---

## Sprint 2 — Refino técnico

**D-04 · Escopo.** Críticos + fundação (`scripts/`) + limpeza total dos órfãos.

**D-05 · Instâncias persistentes (CV-01).** Correção na causa, não no sintoma:
- guarda de instância única no `Create` de todo objeto persistente;
- `o_controlador_geral` sai de `rm_menu` e passa a nascer em `rm_splash`;
- `o_background_manajer_forja` e `o_controlador_opcoes` deixam de ser persistentes —
  eles pertencem à sua room e não precisavam sobreviver a ela.

**D-06 · Julgamento por tempo, já na Sprint 2 (GP-01, GP-02, GP-06).** Em vez do paliativo
espacial, o julgamento passou a medir o erro em frames/milissegundos usando a velocidade da
própria nota:

| Julgamento | Janela |
|---|---|
| PERFEITO | ±3 frames (±50 ms) |
| BOM | ±8 frames (±133 ms) |
| Perdida | além de −8 frames |

A exigência passa a ser idêntica em todas as fases, independentemente da velocidade visual
das notas, e as faixas mortas deixaram de existir. **Precisa de playtest**: é a mudança que
mais altera a sensação do jogo. Os valores estão em `scripts/scr_ritmo` e são um ponto único
de ajuste.

**D-07 · Anti-spam (GP-04).** Toque inválido não encerra mais a partida: custa 10 pontos e
zera o combo. A partida só termina por sequência de notas perdidas. Motivo: numa cabine de
feira, o visitante experimenta os botões antes de entender o jogo.

**D-08 · Repositório.** Trabalho em branch (`sprint-2-refino-tecnico`); projeto renomeado
para `HammerTempo.yyp`; `.rar`/`.zip` fora do versionamento (continuam no disco); recursos
órfãos apagados.

**D-09 · Zonas de acerto continuam invisíveis por enquanto.** Como as janelas agora são
temporais, a largura em pixels muda com a velocidade da fase — um sprite fixo mentiria para
o jogador. O desenho correto (calculado por fase) entra na Sprint 3, junto com o HUD.

**D-10 · Fase 4 (Machado) e Modo Infinito seguem desativados.** Os blocos comentados saíram
do `Create` do controlador; voltam na Sprint 7 já com mapa rítmico de verdade. Os assets
(`snd_fase_04`, `s_machado01..05`) continuam no projeto.

**D-11 · Regressões encontradas na validação e como foram tratadas.** Tirar a persistência do
gerenciador de fundo (D-05) revelou que **duas rooms nunca tiveram fundo próprio** e uma terceira
tinha a instância desativada — o parallax delas vinha "de carona" do objeto persistente. Em vez de
voltar atrás na decisão, cada room passou a ter sua própria instância de fundo, e todas as rooms
agora limpam a superfície a cada frame. É o desenho correto e elimina de quebra o rastro dos
créditos.

**D-12 · Penalidade por toque inválido fica em 10 pontos, sujeita a playtest.** Sob *mashing*
extremo (dezenas de toques por segundo, como no teste automatizado), a penalidade zera a pontuação
da partida. Para um jogador humano isso não acontece, e a regra é o que impede "ganhar martelando"
quando o leaderboard entrar (Sprint 4). Se no playtest parecer punitivo demais, o número está em
um único lugar (`o_buttons_forja/Step_0.gml`).
