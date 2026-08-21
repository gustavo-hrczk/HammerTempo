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
