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

---

## Sprint 3 — UI/UX

**D-13 · O HUD mora junto da margem de acerto.** A primeira proposta colocava pontuação e
precisão no canto superior direito. Errado: o olho do jogador fica preso no canto inferior
esquerdo, onde as notas são julgadas. Todo o bloco de informação passou para logo acima da
margem de acerto. Também ficou registrado que **a área bege à direita não é espaço livre** —
é o corredor por onde as notas atravessam a tela inteira.

**D-14 · Moldura do HUD reaproveita o painel dos menus.** `s_menu_background_panel` esticado,
o mesmo pergaminho do menu principal e das opções, para o HUD falar a mesma língua visual.
A placa de madeira testada antes foi descartada.

**D-15 · Textos do painel em tamanho nativo da fonte.** Nada de `draw_text_transformed` nos
valores de pontuação e precisão: fonte de pixel escalada perde o traçado. Rótulos em
`f_padrao_pequena`, valores em `f_padrao`, ambos em escala 1. O combo é a única exceção — ele
pulsa de propósito, por ser o elemento que reage a cada acerto.

**D-16 · Combo só a partir de 5 acertos seguidos**, rotulado "Combo xN" (só o `xN` era confuso).
O bônus de pontos continua somando desde o primeiro acerto; o que começa em 5 é o anúncio.

**D-17 · Julgamento sai da bigorna.** A ideia da cascata saindo da bigorna foi implementada e
depois movida para logo acima do bloco de HUD, para não dividir a atenção. O erro afunda em
vermelho enquanto os acertos sobem — a direção do movimento distingue sucesso de falha.

**D-18 · Acerto = absorção pelo alvo.** O antigo "sobe e desvanece" era lento e datado. Agora a
nota encolhe e desliza para dentro do alvo em ~6 frames, e o alvo dá um pop de escala. A reação
acontece onde o olho já está.

**D-19 · Trilhos por lane em degradê contínuo.** Alpha 0 do lado direito, onde a nota nasce,
subindo até 10% junto ao alvo. Duas versões anteriores foram descartadas: faixa cheia com alpha
constante (pesada) e faixa segmentada (degraus visíveis de alpha). O degradê é desenhado com
`draw_primitive` e alpha por vértice.

**D-20 · Efeitos de impacto removidos, aguardando referências.** Anel de choque e tremor da
bigorna, clarão do martelo e brilho da forja por combo foram implementados, testados e retirados
por não terem ficado bons. A faísca do acerto perfeito (que já existia desde a jam) e o
afundamento do alvo continuam.

**D-21 · Pitch da martelada revertido.** Variar o tom por julgamento e por combo descaracterizou
o som. `play_martelada_sequencial_sfx()` voltou ao comportamento original.

**D-22 · Tamanho de janela virou opção no menu** (640x360 / 1024x576 / 1280x720, mais tela
cheia), padrão 1024x576, salvo em disco. O **espaço de design continua 1280x720** em todos os
casos: só a janela encolhe e o jogo é escalado para caber nela.

**D-23 · Limite de caracteres da fonte.** A Kobold 7 está compilada com as faixas 32–127 e
192–255. Acentuadas funcionam; `·`, `…`, `º`, `ª` e afins viram um quadrado vazio. Ampliar as
faixas exigiria a fonte instalada em toda máquina que compila, então a regra é **não usar esses
caracteres**. Duas ocorrências foram corrigidas (uma delas vinha da jam, na tela de resultado).

**D-24 · Contagem regressiva volta para o corredor das notas.** Ela tinha sido movida para junto
do bloco de HUD e ficou deslocada; agora é desenhada centralizada na faixa por onde as notas vão
correr — é para lá que o olho precisa estar quando a fase começa. Ganhou pulso por segundo: o
número entra grande e assenta, com a opacidade acompanhando.

**D-25 · O ganho de pontos sobe a partir do próprio número da pontuação**, não solto sobre a
caixa. Tamanho aumentado (`f_padrao`) e cor por julgamento: dourado no perfeito, verde no bom.

**D-26 · Acerto = "bolha que estoura".** A absorção pelo alvo (D-18) foi testada e descartada por
ficar apagada. Agora a nota cresce enquanto some, no lugar onde foi acertada.

**D-27 · Redundância dupla no julgamento.** Perfeito e bom se distinguem por **texto** e por
**brilho colorido no botão** (dourado x verde), além da força do pop e da cor do estouro da nota.

**D-28 · O julgamento saiu do espaço de room e foi para o HUD.** O objeto `o_julgamento` foi
removido do projeto: como o painel é desenhado no Draw GUI, qualquer texto em espaço de room
aparecia atrás dele. Agora o HUD desenha tudo na mesma passada, e o texto fica na base do bloco.
Um julgamento novo substitui o anterior, em vez de empilhar cascata.

**D-29 · Combo com tamanho fixo e cor progressiva.** O pulso de escala saiu. Quem comunica o
crescimento é a cor, que segue a temperatura do metal: brasa escura aos 5, laranja aos 15, ouro
aos 30, quase branco a partir de 45. Ao quebrar, o último valor treme e some em 0,4 s.

**D-30 · Bloco, julgamento e teclas no mesmo eixo vertical.** O bloco foi estreitado de 330 para
230 px e reposicionado para que seu centro caia exatamente no centro da coluna de teclas (x = 120).

**D-31 · Nunca executar a janela do jogo sem permissão.** Compilar (sem abrir janela) pode a
qualquer momento; abrir o jogo exige aval explícito a cada vez, porque a automação de captura
clica na janela e rouba o foco do teclado da máquina.

**D-32 · Fonte de pixel só aceita escala inteira.** O contador da contagem estava em escala
fracionária contínua (3,0 a 4,7), o que faz um mesmo glifo ter pixels de tamanhos diferentes —
e, como a escala muda a cada frame, o padrão "ferve" na tela. A regra passou a valer para todo
texto do jogo:

- tamanho vem das duas fontes do projeto (`f_padrao` 30 px, `f_padrao_pequena` 23 px);
- ênfase só em **múltiplos inteiros** (2x, 3x, 4x);
- a **posição** também é arredondada, senão o texto cai fora da grade de pixels e borra igual;
- contorno em 4 direções com deslocamento inteiro, e não 8 cópias com deslocamento proporcional.

A contagem regressiva pulsa em degraus (5x → 4x → 3x), que é como pixel art anima de verdade.
Nome da fase, julgamento e aviso de forja fria foram convertidos para tamanho nativo. A alternativa
de criar uma fonte dedicada de ~90 px foi considerada e fica anotada como melhoria — a Kobold 7
está instalada na máquina de desenvolvimento, mas criar o asset exige a IDE.

**D-33 · O instante em que a música começa é o que ancora a sincronia — não mexer nele.**
A Sprint 3 adiantou a música da fase para a contagem regressiva (era o item CV-03, "tema cortado
em seco"). Isso deslocou a faixa em **3 segundos** em relação às notas, que continuam sendo
agendadas a partir da criação do spawner, e a dessincronia apareceu em playtest.

Enquanto o mapa não for derivado do próprio áudio (Sprint 5), **o alinhamento entre notas e
música é acidental e depende do instante exato em que a faixa começa**. Regra até lá: a música da
fase começa na criação do `o_spawner_ritmo`, na mesma linha em que a primeira nota é agendada.
O ganho de agradabilidade do CV-03 foi preservado de outra forma: em vez de adiantar a faixa,
ela entra com crossfade de 0,4 s a partir do tema — o volume suaviza a troca sem mover a posição
da faixa um único frame.

**D-34 · Contagem regressiva volta a ser estática.** O pulso em degraus (D-32) foi testado e
descartado. Do ajuste ficou só o **enquadramento**: centralizada na faixa por onde as notas vão
correr. O texto usa `f_padrao` com o mesmo tratamento do resto do jogo — sem contorno, sem
variação de opacidade — e o número em escala 3 com posição arredondada.

**D-35 · Paleta do combo medida, não estimada.** A rampa "temperatura do metal" (D-29) subia até
ouro e branco-quente — e o painel do HUD é um pergaminho claro (rgb 229,214,161). Medindo o
contraste: o ouro dava **1,14:1** e o branco-quente **1,29:1**, ou seja, texto praticamente
invisível. Em fundo claro, calor não pode ser expresso por luminosidade.

A rampa nova expressa calor por **matiz e saturação**, mantendo todas as paradas escuras:
terra (4,60:1) → cobre (4,68:1) → brasa (4,86:1) → carmim (5,57:1). Todas acima de 4,5:1, o
mínimo de contraste para texto. Sempre que um texto for sobre o pergaminho, medir antes.

**D-36 · Tela de resultado em grade 2x3.** Com a faixa "ótimas" a lista de duas colunas passou a
estourar o painel — a frase de feedback invadia a caixa do prompt em 7 px. Virou uma grade de duas
linhas por três colunas em `f_padrao_pequena`: julgamentos lado a lado em cima, erros/total/
precisão embaixo. Economiza uma linha inteira, agrupa as três faixas visualmente e ainda exibe a
precisão, que antes só existia durante a partida.
