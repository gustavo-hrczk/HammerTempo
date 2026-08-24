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

**D-37 · Cascata de julgamentos em fila.** O slot único era substituído a cada acerto e, como o
jogador acerta em sequência — é a proposta do jogo —, o texto era trocado no meio da animação e
aos olhos virava tremulação. Cada acerto passou a empilhar um item próprio: nasce em `y = 502`,
sobe 33 px com desaceleração e some ao longo de 0,7 s, com teto de 3 simultâneos. Como cada um
nasce num instante diferente, ficam em alturas diferentes e a sobreposição vira leitura de
sequência. O erro afunda 16 px em vez de subir.

**D-38 · Ganho de efeito medido, não estimado.** As amostras de martelada estão em ~−11 dBFS RMS,
muito mais quentes que as faixas das fases. A primeira tentativa (ganho 0,55) equivalia a apenas
−5,2 dB e foi imperceptível. Volume aparente cai pela metade a cada ~−10 dB, então o valor ficou
em **0,32 (−9,9 dB)**. Duas assimetrias herdadas ficam anotadas: `snd_menu_confirm` é o mesmo
áudio de `snd_martelada_01`, e a navegação de menu está 13 dB abaixo da confirmação. As duas se
resolvem de vez quando existirem volumes separados de música e efeitos.

**D-39 · Respiro entre telas, por transição.** O `o_transicao` ganhou o estado `ESPERA`: a tela
pode ficar parada no preto entre uma sala e outra. Fica em zero na maioria das trocas — a decisão
de "fade rápido e uniforme" continua valendo para menu ↔ fase — e só a abertura usa 0,35 s, onde
a pausa é parte da apresentação.

**D-40 · Nada aparece de uma vez.** O tema do menu entra com crossfade de 1,2 s (a sala carrega
com a tela ainda preta, e o volume cheio no escuro soava abrupto), e HUD, trilhos e barra de
progresso entram em fade de 0,45 s quando a contagem termina.

**D-41 · A IDE do GameMaker desfaz edições externas.** Com o projeto aberto, a IDE reescreve
arquivos a partir do buffer dela e apaga alterações feitas por fora — aconteceu com
`o_controlador_geral/Draw_64.gml`, que voltou sozinho ao estado anterior e nem entrou no commit.
Enquanto houver edição de código por fora, ou o projeto fica fechado na IDE, ou é preciso
recarregar antes de testar. Toda alteração passou a ser verificada no disco depois de escrita.

**D-42 · Game over é game over, independente da precisão.** A tela de resultado escolhia jingle,
animação e arma só pela taxa de acerto. Um jogador avançado que perdesse a fase com 95% de
precisão recebia jingle de vitória, comemoração e a melhor arma — o oposto do que tinha acabado
de acontecer. Agora o controlador marca `fase_falhou` e o resultado força a faixa de falha.

**D-43 · Derrota também tem respiro.** O game over cortava a partida em seco. Passou a ter 1,6 s
entre a última nota perdida e a tela de resultado: o spawner é destruído, as notas que ainda
estavam na tela **saem de cena sem virar erro** (não são culpa do jogador), o ferreiro já reage
com a animação de falha e a música sai em fade de 1,4 s. Durante esse intervalo as teclas não
pontuam nem penalizam — a partida já acabou.

---

## Sprint 3 — fechamento

**D-44 · Pausa com menu, e o cuidado com os alarmes.** A variável `pausa` existia desde a jam,
era checada em seis lugares e nunca era ativada (CV-07). Agora ESC durante a partida abre
"Continuar / Reiniciar fase / Sair para o menu", com a música congelada por `audio_pause_sound`.

O detalhe que quase virou bug: **alarme do GameMaker continua contando mesmo com o Step
bloqueado**. O `Alarm_0` do spawner saía cedo quando pausado — mas sair sem reagendar mataria o
fluxo de notas para sempre ao despausar. Ele passou a **reagendar** (`alarm[0] = 5`) em vez de
apenas ignorar. Vale para qualquer alarme que venha a existir.

**D-45 · Volumes separados de música e efeitos.** Um master único nunca equilibraria os dois: as
amostras de efeito estão em ~−11 dBFS RMS contra faixas de fase bem mais baixas. Cada um ganhou
seu controle (0 a 10), aplicado como multiplicador em `global.ganho_musica` e `global.ganho_sfx`
em vez de audio groups — evita mexer no `.yy` de 16 sons. Padrões: música 8, efeitos 7.

Saves antigos migram sozinhos: o valor único de `volume` vira o ponto de partida dos dois. E o
ajuste é **audível enquanto se mexe** — a faixa em execução acompanha na hora, e mudar o volume
de efeitos dispara uma martelada de amostra, porque efeito sem referência sonora não dá para
ajustar de ouvido.

**D-46 · Recorde por fase, com id estável.** `save.recordes` guarda a melhor pontuação por fase,
indexada por **id textual** (`fase_01`) e não pelo índice do array: inserir uma fase no meio da
lista não pode embaralhar recordes já conquistados. O seletor mostra o recorde, e a tela de
resultado anuncia quando ele é superado. É também a base sobre a qual o leaderboard da Sprint 4
vai ser construído.

**D-47 · O tutorial mostra as teclas em vez de descrevê-las.** As sprites dos alvos já são
teclas desenhadas — o pacote de arte é uma folha de teclado. O texto "Use as `<SETAS>` ou
`<W A S D>`" virou os quatro alvos desenhados com a letra correspondente embaixo. Numa feira
ninguém lê instrução, e o jogador reconhece na tela o ícone que acabou de ver.

**D-48 · `instance_exists` não garante que o `Create` já rodou.** O boot quebrou porque
`save_aplicar_opcoes()` roda no `Create` do `o_controlador_geral`, que vem **antes** do
`o_audio_manager` na ordem de criação de `rm_splash`. A instância já existia, mas seus métodos
ainda não tinham sido definidos. Sempre que uma função de script chamar método de outro objeto
durante o boot, a checagem tem que ser pela **variável** (`variable_instance_exists`), não pela
instância.

**D-49 · Micro sprints mais curtos.** O fechamento da Sprint 3 entregou três blocos de uma vez
(pausa, volumes, seletor/tutorial) e o usuário só descobriu o erro de boot ao abrir o jogo. A
partir daqui: **uma mudança por vez, compilada e entregue para teste**, antes de começar a
seguinte. Compilar sem erro não é o mesmo que funcionar.

**D-50 · Pausa: notas ocultas e contagem de retomada.** Com o jogo congelado e o campo à vista,
dava para estudar as notas que vinham — por isso elas somem durante o **menu** de pausa e voltam
na **contagem de retomada**, quando o jogador precisa ver o que está chegando. Sair da pausa
passa por 3 s de contagem antes de a partida voltar a valer, padrão dos jogos de ritmo:
despausar direto é injusto se houver nota chegando.

**D-51 · Animação parada nunca termina.** O ferreiro travava no meio da martelada ao despausar,
e o escopo era maior que o relatado: acontecia em **qualquer** despausa. A pausa zera
`image_speed`, e o evento de fim de animação nunca dispara com a animação parada — então nada
devolvia o estado para IDLE. A velocidade passou a ser guardada e restaurada. Vale como regra:
zerar `image_speed` para congelar exige restaurar explicitamente.

**D-52 · Recordes de Arcade e Livre são placares separados.** A pergunta era se um recorde feito
na fase 3 dentro do modo Arcade deveria sobrepor o recorde isolado daquela fase. Não deve, e a
razão é técnica antes de ser de gosto: se o combo atravessar as fases no Arcade, a fase 3 começa
com combo herdado e o bônus por acerto produz pontuação que uma partida isolada nunca alcança
partindo do zero — o recorde do modo Livre viraria inalcançável por construção. Mesmo com o combo
zerando entre fases, o efeito de "mão quente" permanece.

Estrutura definida:

| Placar | Guarda | Onde aparece |
|---|---|---|
| **Livre** (por fase) | 3 letras + pontuação + precisão, Top 10 por fase | Recorde resumido no cartão do seletor e lista completa na tela de Recordes |
| **Arcade** (a run inteira) | 3 letras + total + até onde chegou + precisão média, Top 10 | Só na tela de Recordes |

O Arcade grava **o total do percurso**, não pontuações de fase — então não existe recorde de fase
no Arcade, e a sobreposição deixa de ser possível. Entrada de nome em 3 letras nos dois modos,
por direcional, que funciona igual em teclado e em alavanca de arcade.

A lista completa vai para uma tela própria no menu, mas o recorde continua no cartão do seletor:
é ali que ele funciona como alvo, no momento em que o jogador escolhe a fase.

**D-53 · Um só padrão visual de menu, num só lugar.** Menu principal, opções e pausa desenhavam
cada um do seu jeito: destaque amarelo num, laranja no outro; moldura de 248x215 numa tela e 380
de largura na outra; logo em alturas diferentes; e o cursor de espada só existia no menu
principal. Tudo passou para `scr_ui` — `ui_logo()`, `ui_painel_menu()` e `ui_item_menu()`, com
as medidas e cores em macros. As três telas viraram a mesma tela com conteúdo diferente.

**D-54 · Sem fade entre menu e opções.** Como as duas telas agora compartilham logo e moldura no
mesmo lugar, o fade não lê como transição — lê como piscada. `ir_para_sala` ganhou um parâmetro
para trocar de sala direto, usado só nesse par. As demais trocas seguem com os 250 ms.

**D-55 · O cartão do seletor passa a ser medido, não estimado.** A caixa pulsante da fase
selecionada era fixa em 300x180 centrada em y 619. O conteúdo do cartão ia de 523 (topo da
moldura da arma) a 684 (linha do recorde), então a caixa **cortava o topo do ícone** e ainda
sobrava um vão de 25 px abaixo do recorde — a origem dos "desalinhamentos" relatados. Agora
ela nasce do topo da moldura e termina logo abaixo do recorde, e a largura sai do maior
`string_width` entre nome, dificuldade e recorde, limitada à distância entre colunas.

O cursor de espada seguia a mesma lógica errada: ficava a 150 px fixos à esquerda, flutuando
longe de nomes curtos. Passou a se apoiar na largura do nome (`- string_width/2 - 25`), rente
à primeira linha do cartão, exatamente como em `ui_item_menu` — o cartão não tem moldura
própria, então é o texto que ancora o cursor. A tinta do texto também deixou de ser um marrom
particular e virou `UI_COR_TEXTO`.

**D-56 · Uma só largura de caixa de destaque, e a janela volta a mostrar a resolução.**
Menu e opções ainda destacavam de tamanhos diferentes: o menu usava `string_width + 75`,
que muda a cada item, e as opções usavam `painel - 36` (224 px), fixo. Ao trocar de tela a
caixa saltava de tamanho. Agora existe `UI_ITEM_LARGURA = 243`, medida no item mais largo
do menu principal ("Começar Jogo" = 168 px em f_padrao) mais a folga de 75 que o menu já
usava — e vale para menu, opções e pausa. O texto mais longo do jogo ("Sair para o menu",
218 px) continua cabendo dentro dela.

Os rótulos "Pequena/Média/Grande" saíram: quem escolhe tamanho de janela quer ver a
resolução. Voltaram "640x360", "1024x576" e "1280x720". O que forçou os apelidos foi a
margem das linhas com valor, que era tirada do painel (vão de 200 px, deixando 14 px entre
"Janela" e o número). As margens passaram a sair da própria caixa — maior à esquerda,
onde o cursor se encaixa — e o vão subiu para 205 px, com 18 px entre rótulo e valor.

**D-57 · O céu atravessa as salas.** Cada sala tem a sua instância do gerenciador de fundo,
e o `Create` dela zerava a rolagem do parallax e devolvia o ciclo de temas para o primeiro
item. Era o salto visível ao ir do menu para opções ou créditos: o céu recomeçava do zero
enquanto o resto da tela ficava parado. O estado (posição das camadas, tema atual, tema
seguinte e os temporizadores) agora é gravado em `global.bg_ceu_estado` a cada frame no
Draw e restaurado no Create. A fonte da verdade é o menu, por ser a primeira sala a criar
o fundo — as demais continuam de onde ele parou.

**D-58 · Corte seco entre o menu e o seletor de fases.** Mesmo motivo do D-54, agora que o
céu também atravessa a troca (D-57): as duas telas compartilham o fundo no mesmo ponto, então
o fade não lê como transição, lê como piscada. Vale nos dois sentidos — entrar e voltar são o
mesmo par de telas, e um corte na ida com fade na volta seria pior que os dois iguais.

**D-59 · O título do seletor subiu para o corpo do texto.** "Selecione a arma para forjar"
estava em f_padrao_pequena, o mesmo corpo da dificuldade e do recorde dos cartões — competia
com eles em vez de encabeçá-los. Passou para f_padrao (30 px), o corpo dos nomes das fases.
A linha ficou 7 px mais alta, então o cartão inteiro desceu 7 px: só assim a caixa de destaque
(que nasce no topo da moldura da arma) não invade o título, e o recorde ainda sobra 12 px do
fim do pergaminho.

**D-60 · A zona de perigo virou uma moldura só, em meia-esquadria.** O aviso de forja
esfriando eram três retângulos chapados desenhados um sobre o outro — topo (0,0)-(1280,46),
esquerda (0,0)-(54,720) e direita (1226,0)-(1280,720) — cada um com o mesmo alpha pulsante.
Nos dois cantos de cima os retângulos se cruzavam e o alpha somava: onde o resto da faixa
estava em 0,22-0,44, o canto ia a 0,44-0,69. Eram dois quadrados visivelmente mais escuros,
as "faixas sobrepostas" relatadas.

A moldura agora é desenhada como três trapézios que se encostam nas diagonais dos cantos,
sem nunca se cobrir — não há alpha somado em ponto nenhum. Cada trapézio tem alpha cheio na
borda da tela e zero na borda de dentro, o que troca o corte reto por um degradê de 64 px no
alto e 96 px nas laterais. Como um degradê deixa metade da tinta de uma faixa chapada de
mesma largura, o pulso subiu de 0,22-0,44 para 0,30-0,60 e o aviso manteve o peso.

As laterais também deixaram de descer até o pé da tela: morrem em `HUD_CORREDOR_TOPO`, para
não tingir as faixas por onde as notas correm.

**D-61 · O ócio do ferreiro sorteia distância, não posição.** Os "passinhos" estranhos na
seleção de fase tinham duas causas somadas. A primeira: o destino saía de
`random_range(passeio_min, passeio_max)`, uma POSIÇÃO dentro de uma faixa de 140 px. Como
ele já estava dentro dessa faixa, boa parte dos sorteios caía a dois ou três pixels dos pés
dele — a animação de andar começava e terminava sem que saísse do lugar. Agora sorteia
distância e lado, com mínimo de 55 px, e tenta o lado oposto quando esbarra no limite; sem
espaço para nenhum dos dois, fica parado mais um tempo em vez de dar o passo inútil.

A segunda: o contador de decisão corria também durante a caminhada. Ao zerar no meio dela,
trocava o destino ou cortava o passo pela metade. A decisão passou a acontecer só com ele
parado, o que torna cada caminhada indivisível.

Terceiro ajuste, de proporção: o ciclo de 6 quadros a `image_speed 0.6` fechava em 10
frames, e a 1,2 px/frame ele cobria 12 px por passada completa — os pés patinavam no chão.
Passou para 0,35 e 1,6 px/frame: 17 frames por ciclo, 27 px de avanço.

**D-62 · O tutorial mostra as faixas na vertical e deixa testar.** Os quatro alvos estavam
lado a lado, na horizontal, enquanto em `rm_forja` eles são uma coluna (y 515, 565, 615,
665). O tutorial ensinava uma leitura que o jogo não usa. Agora são a mesma coluna, com o
mesmo espaçamento de 50 px e na mesma ordem, e o texto passou para uma coluna à direita.

As teclas também respondem no tutorial, com a resposta idêntica à da partida — quadros
enquanto está pressionada, afundamento no toque e o som da martelada. É o mesmo código de
feedback de `o_buttons_forja`, sem julgamento nem pontuação. Numa feira, o visitante que
experimenta antes de começar não gasta a primeira fase descobrindo qual tecla é qual.

O texto foi reescrito junto, já que a coluna mudou de largura: "quanto mais preciso o
golpe, melhor a arma" não dizia o que fazer nem o que se ganha, e virou "martele no
instante em que ela chega: quanto mais perto do tempo certo, mais pontos ela vale".
"Acertos seguidos" virou "acertos consecutivos" e a quebra de linha manual saiu.

**D-63 · O tutorial lê o vínculo, não escreve a tecla na unha.** "W A D S" estava escrito
direto no desenho. Como o remapeamento vai existir — e no gabinete vai —, um rótulo fixo
passaria a mentir para o jogador na primeira remapeada. `scr_input` ganhou
`input_nome_da_acao()`, que devolve o nome do vínculo em vigor no dispositivo em uso.

Uma regra dentro dela: no teclado, prefere o vínculo que NÃO é seta direcional quando há
outro. As lanes estão ligadas a setas e a WASD ao mesmo tempo, e o ícone do alvo já é uma
seta — escrever "CIMA" ao lado de uma seta para cima não ensina nada, "W" ensina. Com
controle, mostra o botão ("BOTÃO 1", "CIMA" do direcional).

Como a largura do rótulo passou a variar, o bloco ícone + rótulo é medido antes de desenhar
e centrado na coluna como uma peça só. Antes o ícone é que era centrado e o rótulo ficava
pendurado à direita, o que puxava o conjunto para fora do eixo do título — o desalinhamento
visível na captura.

O som da martelada no teste de teclas foi removido: ali o ferreiro está atrás do
escurecimento de 0,7 e a martelada tocava sem martelo à vista.

**D-64 · Trava de preparação do ferreiro.** O passeio foi de -110/+30 (140 px) para
-160/+55 (215 px), para o ócio ter mais variedade. Alargar a faixa cria um risco: quanto
mais longe ele pode estar, maior a chance de a contagem de 3 s acabar com ele ainda a
caminho da bigorna — e aí o estado RITMO o teleportava para casa, porque força `x = home_x`.

Voltando para casa, a velocidade agora é a que for necessária para chegar antes da contagem
zerar, com folga de 0,4 s para assentar em IDLE: `abs(alvo - x) / (contagem_timer - 24)`,
nunca menor que o passo normal. A animação dos pés acompanha a mesma proporção, senão a
passada volta a patinar. Na faixa atual a trava nunca chega a agir (o pior caso são 160 px,
1,67 s de caminhada), mas ela é o que permite alargar o passeio de novo sem reabrir o
problema.

**D-65 · O alerta de perigo cresce em estágios.** Havia um estágio só, sempre a um erro de
perder. Como a vida varia por fase, o jogador da Espada errava cinco vezes sem sinal nenhum
e falhava na sexta — pouca responsividade justamente onde ela importa. Agora são até 4
estágios, `min(vida - 1, 4)`:

| Fase | Vida | Estágios | Alerta começa no erro |
|---|---|---|---|
| Adaga | 4 | 3 | 1 |
| Lança | 5 | 4 | 1 |
| Espada | 6 | 4 | 2 |

A intensidade (`estágio / total`) move duas coisas. O alpha da vinheta, por
`0,10 + 0,20 × intensidade` na base e na amplitude — que no estágio final dá 0,30-0,60,
exatamente o alerta anterior. E a velocidade do pulso, de um ciclo de 1,2 s no primeiro
estágio a 0,87 s no último. A urgência entra pela TAXA do acumulador, não multiplicando o
valor acumulado: multiplicar o acumulado daria um salto de fase a cada mudança de estágio.

O texto "A FORJA ESTÁ ESFRIANDO!" ficou só no estágio final, que nas três fases é exatamente
"um erro para perder". Aparecendo antes, deixaria de significar isso.

`hud_perigo_estagio()` está isolada de propósito: hoje lê a sequência de erros, e quando o
poço de vida entrar, só ela muda — o desenho do alerta continua igual.

**D-66 · Placa suave atrás do título da fase.** O nome da fase e a linha de dificuldade são
texto branco no alto da tela, sobre o céu. Medindo a faixa y 8-100 dos sprites de fundo, o
pior caso do ciclo é `s_bg_mid_clouds`, com luminância 0,697 — o branco fica em **1,41:1**,
ou seja, legível apenas pelo contorno. Era a "timidez" relatada.

Entrou uma placa preta de ponta a ponta com 0,72 de pico, que derruba o fundo para 0,195 e
leva o contraste a 4,3:1. Ela não é uma tarja: `hud_placa_suave()` desenha uma grade 3x3 de
quadriláteros com cor por vértice, com alpha cheio num miolo que cobre exatamente as duas
linhas (y 22 a 88) e queda a zero nas quatro bordas — 420 px de fade de cada lado. As nove
peças encostam sem se cobrir, então não há alpha somado nas emendas, como no D-60. A placa
acompanha o mesmo fade de entrada e saída do texto.

**D-67 · Recorde é de fase concluída.** `save_registrar_recorde()` era chamado no Create da
tela de resultado sem olhar para `fase_falhou`, e a checagem de derrota só vinha 45 linhas
depois — então perder a fase gravava a pontuação obtida até o game over como recorde. Além
de estar errado, premiava abandonar o trabalho: bastava somar pontos numa fase difícil e
falhar de propósito antes do trecho que não se acerta.

A pontuação da tentativa continua à vista na tela de resultado, que é onde ela faz sentido —
o que deixou de acontecer é ela virar recorde.

**D-68 · Pontuação e recorde ganham cor própria.** A pontuação era preta, do mesmo tamanho
e da mesma cor da grade de estatísticas logo acima — o número que o jogador mais quer ler
se perdia no meio dos outros seis. Passou para o cobre (150,66,24) da rampa do combo, o que
mantém a paleta da partida e a do resultado sendo a mesma. Mede 4,68:1 sobre o pergaminho
(229,214,161).

"NOVO RECORDE!" estava em (178,58,22), que dá 4,12:1 — abaixo do limiar e quase indistinto
do cobre ao lado. Foi para o carmim (158,22,40), 5,57:1, que também é o extremo da rampa do
combo. Ele deixou de ficar num deslocamento fixo de +190 px, que encostava no número com 6
dígitos, e passou a se ancorar na largura real da pontuação.

A onda percorre o texto letra a letra, amplitude de 4 px e ciclo de 1 s, com defasagem de
0,55 rad por caractere. O deslocamento é **arredondado**: Kobold 7 é fonte de pixel e
posição fracionária suja o traço — foi exatamente o que estragou o contador dinâmico da
contagem regressiva (D-33).

No seletor, o recorde também passou ao cobre quando existe. "Ainda não forjada" continua na
tinta comum, porque não é conquista nenhuma. Ressalva medida: no cartão selecionado a caixa
pulsante escurece o fundo e o cobre cai para ~3,2:1 na média do pulso — legível a 23 px, mas
é o ponto fraco da escolha, e existe porque um fundo que oscila de alpha não permite acertar
contraste para uma cor fixa.

**D-69 · O recorde do seletor cresce para poder clarear.** O cobre do D-68 ficou escuro
demais no cartão. Clarear, porém, piora o contraste nos DOIS fundos do seletor: o pergaminho
é claro (L 0,673) e a caixa pulsante só escurece o que está atrás dela — não existe tom claro
que resolva o cartão selecionado.

O que abriu espaço foi o tamanho. O recorde passou de f_padrao_pequena para f_padrao, e a
30 px o limiar aplicável cai de 4,5:1 para 3:1. Com isso o tom (176,92,32) passa a caber:
mede 3,29:1 sobre o pergaminho, contra 4,68:1 do cobre anterior. No pior instante do pulso
da caixa são 1,76:1, contra 2,50:1 do cobre — é o custo declarado da escolha, e a saída, se
incomodar, é escurecer o texto no cartão selecionado, não clarear.

A linha maior obrigou a redistribuir o cartão: título 507, ícone 574, nome 636, dificuldade
663, recorde 694, com a caixa de 526,5 a 710 e 10 px até o fim do pergaminho. "Ainda não
forjada" acompanha o tamanho, para as três linhas de baixo terem a mesma altura entre
cartões, mas continua na tinta comum — não é conquista.

**D-70 · A penalidade de pontuação por erro fica.** Estava marcada para sair por redundância
(errar já não pontua e já zera o combo). Mantida a pedido: ela é o que faz um recorde alto
exigir uma corrida limpa, e não só uma corrida longa.

**D-71 · Arma e moldura vêm sempre do mesmo índice.** As molduras `s_canva01..05` são níveis
de desempenho (0 falha ... 4 perfeito), e cada arma tem a sua correspondente. O seletor
desenhava a ÚLTIMA arma da lista — a melhor — dentro de `s_canva01`, que é a moldura de
falha. A lista de molduras vivia só no `o_controlador_resultado`, então o seletor tinha uma
cópia da ordem escrita à mão, e foi ela que saiu errada.

A lista subiu para `o_controlador_geral.molduras_resultado` e as duas telas leem de lá. O par
arma+moldura passa a sair sempre do mesmo índice, por construção.

Fase sem recorde não desenha nem arma nem moldura. Além de ser o que faz sentido — não há o
que exibir de uma fase nunca forjada —, mostrar a melhor arma antes de qualquer tentativa
entregava o prêmio antes da conquista.

**D-72 · SHIFT+F3 zera os recordes.** Voltar ao estado "ainda não forjada" exigia apagar
`hammertempo_save.json` inteiro, levando junto volume, tamanho de janela e tela cheia. O
overlay de debug ganhou a contagem de recordes gravados e o atalho que os apaga, preservando
as opções.

São dois passos deliberados — o overlay precisa estar aberto e a tecla é com Shift — porque
no gabinete um esbarrão em F3 não pode zerar o placar da feira.

**D-73 · Vínculos de controle passam a morar no save.** `input_init()` tinha os vínculos
escritos no código e nada era persistido — do jeito que estava, o dia do gabinete seria
gastar a única janela de acesso construindo a funcionalidade na frente do hardware, sem
margem se o encoder se comportar de forma inesperada. A tela em si não precisa do gabinete.

O save ganhou `controles`, que guarda **só o que foi remapeado**: o que não estiver lá
continua de fábrica, e assim mudar um padrão no futuro alcança quem nunca mexeu nos
controles. As chaves são identificadores estáveis (`lane_cima`, `confirmar`, …) e não o
índice do enum — inserir uma ação no meio da lista embaralharia todo mapeamento gravado,
mesmo cuidado de `save_id_fase()`.

`input_aplicar_save()` roda depois de `save_carregar()` no boot, porque `input_init()` vem
antes dele e deixa apenas os vínculos de fábrica no lugar. Estes saíram para
`input_vinculos_de_fabrica()`, que o "Restaurar padrão" vai reutilizar.

**D-74 · A tela de controles é uma tabela, não um menu.** Uma linha como "Confirmar /
BOTÃO 1" mede 242 px e não cabe no vão de 205 do padrão de menu. `ui_painel_menu()` e
`ui_item_menu()` ganharam largura e deslocamento vertical como parâmetros, com o padrão
atual como valor default — as outras telas não mudaram uma linha. Aqui o painel usa 360 px.

Sem logo, e por medida: a tinta dele desce até y=400 na tela, e o painel das opções só não
a corta porque começa em 367 e cobre o resto. As sete linhas mais o título formam 400 px de
painel, que embaixo do logo terminariam fora da tela. Esta é uma sobreposição, como
`o_tela_tutorial`, então o título vai dentro do painel, com a mesma faixa escura do
"COMO FORJAR".

O valor de cada linha vem de `input_nome_da_acao()`, a mesma função do tutorial: ela lê o
vínculo em vigor no dispositivo em uso, então com um encoder ligado a tela passa a mostrar
os controles dele sem troca de código.

**D-75 · Captura de vínculo, e o que ela protege.** Escolher uma linha e confirmar entra em
modo de captura: a tela passa a ler o teclado e o gamepad **crus**, sem passar por
`input_pressed()`. A pergunta ali é "qual botão foi apertado", não "qual ação foi acionada"
— e a ação que responde a esse botão é justamente a que está sendo trocada.

Três decisões de segurança, todas pensando no gabinete, onde não há teclado para socorrer:

O controle escolhido é **retirado de qualquer outra ação** (`input_liberar_controle`). Dois
comandos no mesmo botão deixam o jogo imprevisível, e é o tipo de erro que só aparece no
meio de uma partida, com fila esperando. Uma ação que fica sem vínculo passa a exibir
"NENHUM", em vez de um "?" que não diz nada.

**ESC cancela a captura** e por isso é a única tecla que não pode ser vinculada. Sem uma
saída reservada, entrar em captura sem um controle funcionando prenderia o jogador ali.

**"Restaurar padrão"** fecha a lista. Ele chama `input_vinculos_de_fabrica()` e **esvazia**
`save.controles`, o que devolve o save ao estado de seguir os padrões do jogo em vez de
congelar uma cópia deles no disco.

Ressalva do D-73 que muda aqui: a gravação passa a escrever a tabela inteira, não só a ação
alterada, porque remapear costuma mexer em mais de uma — o controle escolhido sai de quem o
usava. A partir da primeira alteração o mapeamento é do jogador; `controles` vazio continua
significando "seguir a fábrica".

Confirmar entra em captura e **sai do Step no mesmo frame**: a tecla que confirmou ainda
conta como pressionada, e seria capturada como o vínculo novo.

**D-76 · Direcional de menu separado do direcional da forja.** Falha estrutural encontrada
no teste do remapeamento: `input_eixo_h()` e `input_eixo_v()`, que navegam **todas** as
telas, liam as próprias `LANE_*`. Remapear uma faixa da forja levava junto a navegação do
menu, das opções, do seletor, da pausa e da própria tela de controles — seis telas. Bastava
um vínculo infeliz para não haver mais como sair de lugar nenhum, e era a tela de controles
que ficava inalcançável justamente quando mais precisava ser alcançada.

O enum ganhou `MENU_CIMA/BAIXO/ESQ/DIR`, ligados a setas, WASD e direcional do controle.
Eles **não** entram em `input_acoes_configuraveis()` e `input_id_acao()` devolve string vazia
para eles, o que faz `input_aplicar_save()` e `input_gravar_controles()` os ignorarem: ficam
sempre nos vínculos de fábrica, por construção, e não por alguém lembrar de não mexer.

Duas consequências desenhadas junto:

`ESC fecha a tela de controles SEMPRE`, por fora do vínculo, porque `VOLTAR` também é
remapeável. Sem essa saída fixa, um vínculo infeliz trancaria o jogador na única tela capaz
de desfazê-lo.

Os rótulos das faixas deixaram de ser "Cima/Esquerda/Direita/Baixo" e viraram
"Faixa 1" a "Faixa 4", na ordem de cima para baixo de `rm_forja`. Nomear a faixa pela
direção sugeria que ali se configurava a direção do jogo inteiro — que é exatamente o que
o bug fazia. A tela também passou a dizer, embaixo, que as setas e WASD sempre navegam os
menus.

Nota: `CONFIRMAR`, `VOLTAR` e `PAUSAR` continuam remapeáveis e continuam valendo nos menus.
Isso não é acoplamento, é a função delas — e o gabinete precisa poder apontá-las para os
botões físicos. A rede de segurança para elas é o ESC fixo e o "Restaurar padrão".

**D-77 · As setas acionam as faixas em caráter absoluto.** Remapear as faixas para 1-2-3-4
tirou do teclado a forma de jogar que a própria tela ensina: quatro faixas empilhadas, cada
uma com um ícone de seta. `global.input_teclas_fixas` é uma camada somada ao vínculo
configurável e imune ao remapeamento — quem configurar botões de arcade ganha os botões, e
as setas continuam ali.

Isso reserva as quatro setas: a captura passa a recusá-las, junto com ESC. Vinculá-las a
outra faixa faria uma tecla disparar duas ao mesmo tempo, sem nada na tela explicando por
quê. `input_nome_da_acao()` também passou a cair no vínculo fixo quando o configurável está
vazio — exibir "NENHUM" numa ação que ainda responde às setas seria mentira.

**D-78 · Rótulos da pausa encurtados, e o antigo mentia.** O cursor de espada precisa de
34,5 px de cada lado do texto, dentro de uma caixa de 243. Medindo: "Sair para o menu" (218)
punha a espada 22 px FORA da moldura, e "Reiniciar fase" (184) a punha 5 px fora — este
segundo caso não tinha sido notado. Viraram "Continuar" (21 px de folga), "Reiniciar" (26) e
"Sair" (59,5).

O rótulo antigo também era factualmente errado: `abandonar_partida()` leva ao SELETOR DE
FASES, não ao menu principal.

**D-79 · Layout vertical (estilo Guitar Hero) — possibilidade resguardada, não agendada.**
Registrado a pedido, para não se perder: testar as quatro faixas lado a lado na VERTICAL,
com as notas caindo, em vez de empilhadas com as notas correndo na horizontal.

A motivação é de portabilidade. Um gabinete tem uma fileira DEITADA de quatro botões, e o
jogo apresenta quatro faixas EMPILHADAS — o desencontro espacial entre o que a mão faz e o
que o olho lê é a origem do "feeling estranho" relatado ao mapear 1-2-3-4. Um campo vertical
com faixas lado a lado casa diretamente com a fileira de botões, que é como os jogos de
ritmo de arcade se apresentam.

O estudo completo — geometria proposta, a conta que decide o feel, o que se reaproveita e o
que muda — está em `05-LAYOUT-VERTICAL.md`.

**Não é para ser feito agora.** Mexeria no corredor de notas (`HUD_CORREDOR_TOPO/BASE`), no
movimento das notas, na zona de acerto (`RITMO_LINHA_X`), no enquadramento do ferreiro e da
bigorna, no bloco do HUD e na cascata de julgamentos — praticamente toda a decisão visual
tomada da D-20 em diante. Só entra depois que todos os pontos do plano original estiverem
fechados, e como experimento paralelo, nunca substituindo o que já funciona.

**D-80 · Placar Livre: armazenamento e entrada de iniciais.** Primeiro passo da Sprint 4.
`scr_placar` guarda um top 10 por fase em `leaderboard.livre`, com nome, pontuação e
precisão. A frente Arcade continua como estrutura vazia até o modo existir — gravar o total
de um percurso que ninguém pode jogar ainda não teria o que armazenar.

Decisões dentro do placar:

**Empate não ultrapassa.** Uma pontuação igual entra depois da que já estava. Numa feira a
fila inteira joga a mesma fase e empates acontecem; quem chegou primeiro fica na frente.

**A entrada de iniciais só aparece se a pontuação entrar no top 10.** Perguntar o nome de
quem não entrou é pedir digitação para nada, e cada segundo de fila conta. Fase perdida não
entra, pelo mesmo motivo do D-67: placar é de trabalho concluído.

**Espera de 25 segundos que GRAVA, não descarta.** Se o jogador saiu do gabinete no meio da
digitação, o placar grava o que estiver na tela e a máquina volta a ficar livre. Descartar
seria pior: a pontuação já foi conquistada, e perdê-la por distração é um resultado pior do
que gravar "AAA".

**Confirmar avança de letra e só grava na última**, que é o comportamento de gabinete e
evita gravar sem querer no primeiro toque.

Três letras por direcional foi escolha da D-52 por funcionar igual em teclado e em alavanca
— não por nostalgia. As letras são desenhadas em escala **inteira** 3 (30 px viram 90), pela
regra de fonte de pixel da D-33.

O SHIFT+F3 que zera recordes passou a limpar o placar junto: deixar o placar cheio com os
recordes zerados daria duas verdades diferentes na mesma tela.

**D-81 · Tela de Recordes.** Segundo passo da Sprint 4, e o que a D-52 já previa: a lista
completa vai para uma tela própria no menu, enquanto o resumo continua no cartão do seletor,
que é onde ele funciona como alvo — no momento em que o jogador escolhe a fase.

É sobreposição, como as telas de controles e de iniciais, e pelo mesmo motivo medido: a
tabela tem 480 px de altura e a tinta do logo desce até y=400. Título dentro do painel.

`ui_painel_livre()` entrou no `scr_ui` porque `ui_painel_menu()` calcula altura por
contagem de itens, e dez linhas de 32 px não são uma lista de itens de menu. Mesma moldura,
mesma família visual, altura declarada.

Colunas medidas: "10." ocupa 24 px, "999999" ocupa 60, "100%" ocupa 43. As posições deixam
80 px entre o nome e a pontuação — é a folga que impede um nome de três letras de encostar
num número de seis dígitos.

Duas escolhas de leitura: **só o primeiro lugar em cobre**, porque a tabela inteira colorida
não destacaria ninguém; e as **setas laterais só aparecem quando há para onde ir**, para não
prometerem navegação que não existe se um dia houver uma fase só.

**D-82 · Nome do placar com espaçamento fixo.** As maiúsculas de `f_padrao_pequena` variam
de 8 px ("I") a 15 px ("M"): um "WWW" mede 42 px e um "III" mede 24 — **18 px de diferença**.
Desenhado como string única, cada nome ficava com uma largura diferente e as três colunas de
letras dançavam de uma linha para outra. Placar é tabela, e tabela pede coluna.

`placar_desenhar_nome()` centra cada letra num slot de 18 px, com posição inteira pela regra
de fonte de pixel (D-33). O nome passa a ocupar sempre 54 px, quaisquer que sejam as letras.

**D-83 · Faixa de crossfade órfã.** Três estados inconsistentes no `o_audio_manager`, todos
com o mesmo efeito: uma faixa continuar tocando **em laço** sem ninguém para pará-la, por
baixo da próxima.

`play_music_crossfade()` sobrescrevia `musica_saindo` sem parar a faixa anterior. Duas trocas
de tela em sequência rápida — que é exatamente o que acontece ao sair de uma fase — deixavam
a primeira faixa tocando para sempre no ganho em que estivesse. Agora a anterior é parada
antes de a nova assumir o lugar.

`stop_music()` zerava `musica_atual` e ignorava `musica_saindo`, então uma faixa em crossfade
sobrevivia ao "pare tudo".

`pausar_musica()` / `retomar_musica()` só congelavam `musica_atual`. A faixa em crossfade
seguia correndo durante a pausa, e o jogador voltava de uma pausa longa com a transição já
terminada.

Como o gatilho exato não foi reproduzido em leitura de código, o overlay de debug ganhou a
linha `saindo:` com asset, estado e ganho da faixa em crossfade, mais os marcadores
`[entrando]` e `[saindo]` na linha da música. Se o defeito reaparecer, ele agora é visível
em vez de dedutível.

**D-84 · A tabela de recordes passou a ter grade.** As quatro colunas eram posicionadas a
olho, e "Pontos" terminava a 14 px de "Precisão". Agora a grade sai da **medida** de cada
coluna: 328 px úteis (painel de 380 menos 26 de margem de cada lado) menos 232 px de
conteúdo deixam 96 px de folga, divididos em três vãos iguais de 32 px.

Cada coluna é dimensionada pelo maior entre cabeçalho e dado, e é isso que resolve o
aperto: "Precisão" mede 86 px contra 43 de "100%", e "Pontos" mede 68 contra 60 de
"999999". Dimensionar pelo dado — que era o instinto — deixaria justamente os cabeçalhos se
tocando.

**D-85 · A tela de resultado não anuncia a colocação.** "AAA em 2o" ficava ao lado da
pontuação, numa tela que já mostra pontuação, precisão, três contagens de julgamento e a
frase de retorno. Era mais um número disputando o mesmo olhar, no momento em que o jogador
quer ler quanto fez. A colocação se lê na tela de Recordes, que existe para isso. O estado
que só servia a essa linha saiu junto, em vez de ficar como campo morto.
