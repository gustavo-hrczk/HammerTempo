/// scr_hud — HUD de partida
///
/// Duas regras de ouro:
/// 1. Nada pode ser desenhado dentro do corredor das notas (y 515 a 707, largura inteira).
/// 2. O jogador olha para a margem de acerto, no canto inferior esquerdo. Toda a
///    informação de partida vive ali por perto, e não no canto oposto da tela.

#macro HUD_CORREDOR_TOPO 515
#macro HUD_CORREDOR_BASE 707

/// Bloco de informação, ancorado logo acima da margem de acerto.
/// A largura e o X são escolhidos para que o CENTRO do bloco caia exatamente no
/// centro da coluna de teclas (RITMO_LINHA_X + metade da largura do alvo = 120):
/// bloco, julgamento e teclas compartilham o mesmo eixo vertical.
#macro HUD_BLOCO_W 230
#macro HUD_BLOCO_X 5
#macro HUD_BLOCO_Y 344
#macro HUD_BLOCO_H 128

/// Combo só é anunciado a partir daqui.
#macro HUD_COMBO_MINIMO 5

/// Topo da rampa de cor do combo: daqui para cima a cor pulsa.
#macro HUD_COMBO_MAXIMO 45

/// Texto com contorno preto, legível sobre o céu e sobre o painel.
///
/// Regra rígida deste projeto: **fonte de pixel só aceita escala inteira**. Escala
/// fracionária faz um mesmo glifo ter pixels de tamanhos diferentes, e como a escala
/// muda a cada frame o padrão "ferve" na tela. A posição também é arredondada, senão
/// o texto cai fora da grade de pixels e borra do mesmo jeito.
function hud_texto(_x, _y, _texto, _cor, _escala = 1, _halign = fa_center) {
    _escala = max(1, round(_escala));

    var _largura = string_width(_texto) * _escala;
    var _altura = string_height(_texto) * _escala;

    var _px = _x;
    if (_halign == fa_center) _px = _x - (_largura / 2);
    else if (_halign == fa_right) _px = _x - _largura;

    _px = floor(_px);
    var _py = floor(_y - (_altura / 2));

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    // contorno de 4 direções, deslocamento inteiro proporcional à escala
    draw_set_color(c_black);
    var _off = _escala;
    draw_text_transformed(_px - _off, _py, _texto, _escala, _escala, 0);
    draw_text_transformed(_px + _off, _py, _texto, _escala, _escala, 0);
    draw_text_transformed(_px, _py - _off, _texto, _escala, _escala, 0);
    draw_text_transformed(_px, _py + _off, _texto, _escala, _escala, 0);

    draw_set_color(_cor);
    draw_text_transformed(_px, _py, _texto, _escala, _escala, 0);
}

/// Texto sólido do painel, desenhado no tamanho nativo da fonte — igual ao resto
/// do jogo. Fonte de pixel escalada perde o traçado, então aqui nada é transformado.
function hud_texto_painel(_x, _y, _texto, _cor, _fonte = -1, _halign = fa_left) {
    if (_fonte != -1) draw_set_font(_fonte);
    draw_set_halign(_halign);
    draw_set_valign(fa_middle);
    draw_set_color(_cor);
    draw_text(_x, _y, _texto);
}

/// Barra horizontal simples, com moldura escura.
function hud_barra(_x, _y, _largura, _altura, _fracao, _cor_a, _cor_b, _alpha = 1) {
    _fracao = clamp(_fracao, 0, 1);

    draw_set_alpha(0.55 * _alpha);
    draw_set_color(c_black);
    draw_rectangle(_x, _y, _x + _largura, _y + _altura, false);
    draw_set_alpha(1);

    draw_set_alpha(_alpha);
    if (_fracao > 0) {
        draw_rectangle_colour(_x, _y, _x + (_largura * _fracao), _y + _altura,
                              _cor_a, _cor_b, _cor_b, _cor_a, false);
    }

    draw_set_color(c_black);
    draw_rectangle(_x, _y, _x + _largura, _y + _altura, true);
    draw_set_alpha(1);
}

/// Prepara as variáveis de animação do HUD. Chamado pelo controlador geral.
function hud_init() {
    global.hud_pontos_exibidos = 0;
    // UM POR JOGADOR. No Versus os dois marcam ao mesmo tempo, e um valor unico
    // fazia o "+120" do jogador 2 substituir o do jogador 1 no meio da subida.
    global.hud_ganho_valor = [0, 0];
    global.hud_ganho_timer = [0, 0];
    global.hud_ganho_cor = [c_white, c_white];
    global.hud_julgamentos = [];
    global.hud_combo_anterior = 0;
    global.hud_combo_exibido = 0;
    global.hud_combo_quebra = 0;
    global.hud_fase_timer = 0;
    global.hud_aviso_pulso = 0;
    global.hud_aviso_ritmo = 1;   // multiplicador da velocidade do pulso de perigo
    global.hud_entrada = 0;
}

/// Reinicia o HUD no começo de cada partida.
function hud_resetar() {
    // No Arcade o contador NAO volta a zero entre as fases: ele retoma do total ja
    // acumulado. Zerar aqui faria o numero despencar e subir de novo a cada arma.
    global.hud_pontos_exibidos = hud_pontos_base();
    global.hud_ganho_valor = [0, 0];
    global.hud_ganho_timer = [0, 0];
    global.hud_julgamentos = [];
    global.hud_combo_anterior = 0;
    global.hud_combo_exibido = 0;
    global.hud_combo_quebra = 0;
    global.hud_fase_timer = 0;
    global.hud_entrada = 0;
}

/// Pontuacao ja acumulada ANTES da fase corrente. Zero fora do Arcade.
function hud_pontos_base() {
    var _c = o_controlador_geral;
    return (_c.modo_jogo == MODO.ARCADE) ? _c.arcade_pontos : 0;
}

/// Precisão a exibir, em porcentagem.
///
/// No Arcade ela é a do PERCURSO INTEIRO, e não a da arma corrente: o percurso é uma
/// partida só, e o placar e o combo já atravessam as fases. Ver a precisão despencar
/// para 77% numa arma e voltar a 100% na seguinte fazia os três números do painel
/// contarem histórias diferentes ao mesmo tempo.
function hud_precisao(_dono = undefined) {
    var _t = o_controlador_geral.arcade_stats_totais(_dono);
    var _a = _t.perfeitas + _t.otimas + _t.boas;
    var _n = _a + _t.erros;

    return (_n > 0) ? ((_a / _n) * 100) : 100;
}

/// Anima os valores do HUD. Chamado uma vez por frame durante a partida.
function hud_update() {
    var _ctrl = o_controlador_geral;

    // O HUD e os trilhos entram em fade quando a contagem termina, em vez de
    // aparecerem de uma vez junto com a primeira nota.
    global.hud_entrada = min(1, global.hud_entrada + (1 / (room_speed * 0.45)));

    // pontuação sobe suavemente até o valor real
    //
    // No Arcade o painel mostra o TOTAL DO PERCURSO, e nao o da fase: o jogador esta
    // perseguindo um numero so, e ver o contador voltar a zero a cada arma desfaria
    // exatamente a sensacao de percurso que o modo existe para criar.
    var _alvo = hud_pontos_base() + jogador().pontuacao;
    if (abs(global.hud_pontos_exibidos - _alvo) < 1) {
        global.hud_pontos_exibidos = _alvo;
    } else {
        global.hud_pontos_exibidos += (_alvo - global.hud_pontos_exibidos) * 0.25;
    }

    // o combo tem tamanho fixo: quem comunica o crescimento é a cor, que vai
    // esquentando. A quebra ganha um tremor curto com o último valor alcançado.
    var _combo = jogador().stats_sequencia;

    if (_combo < global.hud_combo_anterior && global.hud_combo_anterior >= HUD_COMBO_MINIMO) {
        global.hud_combo_exibido = global.hud_combo_anterior;
        global.hud_combo_quebra = room_speed * 0.4;
    }

    global.hud_combo_anterior = _combo;
    global.hud_combo_quebra = max(0, global.hud_combo_quebra - 1);

    global.hud_fase_timer++;
    // O pulso é um ACUMULADOR, então variar a taxa é contínuo — multiplicar o
    // valor acumulado, não. É por isso que a urgência entra pela taxa.
    global.hud_aviso_pulso += 0.12 * global.hud_aviso_ritmo;
    global.hud_ganho_timer[0] = max(0, global.hud_ganho_timer[0] - 1);
    global.hud_ganho_timer[1] = max(0, global.hud_ganho_timer[1] - 1);

    // envelhece a fila de julgamentos, do fim para o começo por causa da remoção
    for (var i = array_length(global.hud_julgamentos) - 1; i >= 0; i--) {
        var _j = global.hud_julgamentos[i];
        _j.timer++;
        if (_j.timer >= _j.dur) {
            array_delete(global.hud_julgamentos, i, 1);
        }
    }
}

/// Registra um ganho de pontos, que sobe a partir do próprio número da pontuação.
/// Precisa ser desenhado pelo HUD (e não por um objeto): o painel está no Draw GUI,
/// então qualquer coisa em espaço de room apareceria atrás dele.
function hud_registrar_ganho(_valor, _cor = c_white, _dono = 0) {
    global.hud_ganho_valor[_dono] = _valor;
    global.hud_ganho_cor[_dono] = _cor;
    global.hud_ganho_timer[_dono] = room_speed * 0.7;
}

/// Desenha o "+N" subindo a partir de um ponto, se houver ganho vivo deste jogador.
///
/// Extraido do painel do solo para o Versus poder usar o MESMO indicador. Era o que
/// faltava para a disputa: o placar do Versus mostrava o total mudando, mas nao dizia
/// quanto valeu a marretada — que e justamente a informacao que um jogador usa para
/// entender por que esta perdendo.
function hud_desenhar_ganho(_dono, _x, _y, _alpha = 1, _halign = fa_right) {
    if (global.hud_ganho_timer[_dono] <= 0) return;

    var _dur = room_speed * 0.7;
    var _prog = 1 - (global.hud_ganho_timer[_dono] / _dur);

    // sobe 22 px e some acelerando: o mesmo tempo e a mesma curva do painel do solo,
    // para os dois modos terem a mesma leitura
    draw_set_alpha((1 - (_prog * _prog)) * _alpha);
    hud_texto_painel(_x, _y - (_prog * 22),
                     "+" + string(global.hud_ganho_valor[_dono]),
                     global.hud_ganho_cor[_dono], f_padrao, _halign);
    draw_set_alpha(_alpha);
}

/// Julgamento do acerto. Fica no HUD (e não num objeto solto) porque o painel é
/// desenhado no Draw GUI: em espaço de room, o texto apareceria atrás dele.
///
/// Cada acerto empilha um item novo em vez de substituir o anterior. Como o jogador
/// acerta em sequência — é a proposta do jogo —, o slot único fazia o texto ser
/// trocado no meio da animação e aos olhos virava tremulação. Agora cada julgamento
/// sobe e some no seu próprio tempo, e os que ainda estão subindo ficam em alturas
/// diferentes: a sobreposição vira leitura de sequência.
function hud_registrar_julgamento(_texto, _cor, _sobe = true, _dono = 0) {
    array_push(global.hud_julgamentos, {
        dono: _dono,
        texto: _texto,
        cor: _cor,
        sobe: _sobe,
        timer: 0,
        dur: room_speed * 0.7,
        desvio_x: irandom_range(-9, 9)
    });

    // TETO DE 3 SIMULTANEOS POR JOGADOR, e nao no total. Sem o dono, o "ERRO" do
    // jogador 2 aparecia na pista do jogador 1 — quem estava com o combo intacto via
    // a falha do outro piscar na propria faixa e concluia ter quebrado a sequencia.
    // A pontuacao sempre esteve certa; era a bolha que mentia.
    var _n = 0;
    for (var i = array_length(global.hud_julgamentos) - 1; i >= 0; i--) {
        if (global.hud_julgamentos[i].dono != _dono) continue;

        _n++;
        if (_n > 3) array_delete(global.hud_julgamentos, i, 1);
    }
}

/// Onde os julgamentos deste jogador nascem.
///
/// O JOGADOR 1 FICA ONDE SEMPRE FICOU: 10 px para dentro da borda de cima do corredor,
/// que é logo acima do botão vermelho. É o enquadramento validado no solo, e o Versus
/// não muda nada para ele.
///
/// O jogador 2 é o espelho exato: 10 px para dentro da borda de BAIXO, logo abaixo do
/// botão amarelo. Os dois textos correm na direção do meio da tela, cada um saindo do
/// próprio corredor — quem olha para cima nunca vê um texto que não é seu.
function hud_julgamento_ancora(_dono) {
    var _topo = ritmo_corredor_topo(_dono);

    // O ESPELHO SO EXISTE NO VERSUS. Fora dele o jogador 2 joga no corredor de baixo,
    // o mesmo do jogador 1, e o texto tem de subir como sempre subiu — a condicao
    // olhava so para o dono e mandava o julgamento do jogador 2 para baixo tambem no
    // Arcade e no Livre.
    var _y = versus_espelhado(_dono)
        ? (_topo + RITMO_CORREDOR_ALTURA - 10)
        : (_topo + 10);

    return [ritmo_linha_x(_dono) + (RITMO_ALVO_LARGURA / 2), _y];
}

/// Os julgamentos de UM jogador, subindo (ou descendo) a partir da ancora dele.
function hud_desenhar_julgamentos(_dono, _entrada) {
    var _a = hud_julgamento_ancora(_dono);
    var _jx = _a[0];
    var _jy_base = _a[1];

    // O jogador 2 lê a pista de cima para baixo, então TUDO desce: o acerto e o erro.
    // Espelhar também a direção do erro — fazendo-o subir — deixava um único texto
    // andando contra todos os outros da mesma tela, e lia-se como defeito, não como
    // sinal. O que distingue erro de acerto continua sendo a cor e a distância curta.
    var _espelhado = versus_espelhado(_dono);

    draw_set_font(f_padrao);

    for (var i = 0; i < array_length(global.hud_julgamentos); i++) {
        var _j = global.hud_julgamentos[i];
        if (_j.dono != _dono) continue;

        var _prog = _j.timer / _j.dur;

        // sobe rápido e vai freando. A distância é curta de propósito: subindo
        // demais o texto atravessava o bloco inteiro e perdia a âncora visual.
        // O erro afunda pouco, só o suficiente para a direção marcar a falha.
        var _distancia = _j.sobe ? 33 : 16;
        var _desloca = _distancia * (1 - power(1 - _prog, 2));
        if (_j.sobe && !_espelhado) _desloca = -_desloca;

        // Opaco no impacto e totalmente apagado aos 65% do trajeto: o movimento
        // continua o mesmo, mas o texto já sumiu antes de subir sobre o combo.
        var _alpha = (_prog < 0.2) ? 1 : max(0, 1 - ((_prog - 0.2) / 0.45));

        // clarão de cor nos primeiros frames
        var _cor = (_prog < 0.12) ? merge_colour(_j.cor, c_white, 0.55) : _j.cor;

        draw_set_alpha(_alpha * _entrada);
        hud_texto(_jx + _j.desvio_x, round(_jy_base + _desloca), _j.texto, _cor, 1);
    }

    draw_set_alpha(1);
}

/// Cor do combo, medida contra o pergaminho do painel (rgb 229,214,161).
///
/// A rampa anterior ia até o ouro e o branco-quente e ficava ILEGÍVEL: o ouro
/// tinha 1,14:1 de contraste sobre o painel claro. Num fundo claro, calor não pode
/// ser expresso por luminosidade — aqui ele vem de matiz e saturação, com todas as
/// paradas escuras o bastante (contraste medido entre 4,6:1 e 5,6:1).
function hud_cor_combo(_combo) {
    var _terra   = make_colour_rgb(122, 84, 52);   // 4,60:1  - metal ainda frio
    var _cobre   = UI_COR_COBRE;   // 4,68:1
    var _brasa   = make_colour_rgb(168, 40, 16);   // 4,86:1
    var _carmim  = UI_COR_CARMIM;   // 5,57:1  - núcleo incandescente

    // No topo da rampa não há mais para onde esquentar, então a cor passa a
    // pulsar de leve — o jogador percebe que chegou ao máximo. O pico do pulso
    // foi medido em 5,03:1 de contraste, bem acima do mínimo de 4,5:1.
    if (_combo >= HUD_COMBO_MAXIMO) {
        var _pico = make_colour_rgb(169, 28, 35);
        var _pulso = (sin(current_time * 0.006) + 1) / 2;
        return merge_colour(_carmim, _pico, _pulso);
    }

    if (_combo >= 30) return merge_colour(_brasa, _carmim, (_combo - 30) / 15);
    if (_combo >= 15) return merge_colour(_cobre, _brasa, (_combo - 15) / 15);
    return merge_colour(_terra, _cobre, (_combo - HUD_COMBO_MINIMO) / 10);
}

/// Desenha o HUD da partida (evento Draw GUI).
/// Vinheta de perigo: moldura de brasa que fecha o alto da tela quando falta um
/// erro para a forja apagar.
///
/// A versão anterior eram três retângulos chapados (topo, esquerda e direita) com
/// alpha próprio. Onde eles se cruzavam o alpha somava, e os dois cantos de cima
/// viravam quadrados nitidamente mais escuros que o resto — as "faixas sobrepostas".
/// As laterais ainda desciam até o pé da tela, atravessando o corredor das notas.
///
/// Agora é uma moldura só, recortada em meia-esquadria: os três trapézios encostam
/// nas diagonais dos cantos sem nunca se cobrir, então não há alpha somado em lugar
/// nenhum. O alpha é cheio na borda da tela e zero na borda de dentro, o que troca o
/// corte reto por um degradê. As laterais morrem no topo do corredor, para não
/// tingir as faixas onde as notas correm.
function hud_vinheta_perigo(_alpha) {
    var _gw = display_get_gui_width();

    var _esp_topo = 64;                 // profundidade do degradê no alto
    var _esp_lado = 96;                 // profundidade do degradê nas laterais
    var _fim_lado = HUD_CORREDOR_TOPO;  // onde a lateral se desfaz, antes das notas

    var _cor = make_colour_rgb(200, 30, 20);

    // topo: as duas pontas de baixo são os pontos de esquadria dos cantos
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(0,   0, _cor, _alpha);
    draw_vertex_colour(_esp_lado,       _esp_topo, _cor, 0);
    draw_vertex_colour(_gw, 0, _cor, _alpha);
    draw_vertex_colour(_gw - _esp_lado, _esp_topo, _cor, 0);
    draw_primitive_end();

    // esquerda: parte do mesmo ponto de esquadria e se apaga descendo
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(0,         0,         _cor, _alpha);
    draw_vertex_colour(_esp_lado, _esp_topo, _cor, 0);
    draw_vertex_colour(0,         _fim_lado, _cor, 0);
    draw_vertex_colour(_esp_lado, _fim_lado, _cor, 0);
    draw_primitive_end();

    // direita: espelho da esquerda
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_gw,             0,         _cor, _alpha);
    draw_vertex_colour(_gw - _esp_lado, _esp_topo, _cor, 0);
    draw_vertex_colour(_gw,             _fim_lado, _cor, 0);
    draw_vertex_colour(_gw - _esp_lado, _fim_lado, _cor, 0);
    draw_primitive_end();

    draw_set_alpha(1);
    draw_set_color(c_white);
}

/// Quão perto de falhar o jogador está, em estágios de alerta.
///
/// ISOLADA DE PROPÓSITO. Hoje a falha vem da sequência de erros; quando o poço de
/// vida entrar, só esta função muda e todo o desenho do alerta continua igual.
///
/// São no máximo 4 estágios, e nunca mais do que a vida da fase permite:
///   vida 4 -> 3 estágios, alerta a partir do 1º erro
///   vida 5 -> 4 estágios, alerta a partir do 1º erro
///   vida 6 -> 4 estágios, alerta a partir do 2º erro
/// O último estágio é sempre, nas três, "um erro para perder".
function hud_perigo_estagio(_erros, _limite) {
    var _total = min(_limite - 1, 4);
    if (_total < 1) return { estagio: 0, total: 1 };

    var _inicio = _limite - _total;
    if (_erros < _inicio || _erros >= _limite) return { estagio: 0, total: _total };

    return { estagio: _erros - _inicio + 1, total: _total };
}

/// Quantas paradas cada borda da placa tem. Seis basta para a rampa parecer contínua;
/// abaixo de quatro a suavização volta a mostrar degrau.
#macro PLACA_PASSOS 6

/// As paradas de um eixo da placa: posição e peso do alpha, com a rampa SUAVIZADA.
///
/// Uma rampa linear vai de zero ao pico em linha reta, e a quebra de derivada nas duas
/// pontas — onde ela sai do zero e onde encosta no pico — aparece como um risco. É a
/// banda de Mach, e era o que fazia a placa dos créditos ter uma aresta visível de cada
/// lado apesar de tecnicamente não ter borda nenhuma.
///
/// smoothstep chega e sai com derivada zero, então não há onde o olho fisgar.
function hud_placa_eixo(_a, _b, _fade) {
    _fade = min(_fade, (_b - _a) / 2);

    if (_fade <= 0) {
        return { pos: [_a, _b], peso: [1, 1] };
    }

    var _n = PLACA_PASSOS;
    var _pos = [];
    var _peso = [];

    for (var i = 0; i <= _n; i++) {
        var _t = i / _n;
        array_push(_pos, _a + (_fade * _t));
        array_push(_peso, _t * _t * (3 - 2 * _t));
    }

    // o miolo, onde o alpha fica no pico. Some quando a borda ocupa a placa inteira.
    if ((_b - _fade) > (_a + _fade)) {
        array_push(_pos, _b - _fade);
        array_push(_peso, 1);
    }

    for (var i = 1; i <= _n; i++) {
        var _t = i / _n;
        var _s = 1 - _t;
        array_push(_pos, _b - _fade + (_fade * _t));
        array_push(_peso, _s * _s * (3 - 2 * _s));
    }

    return { pos: _pos, peso: _peso };
}

/// Placa escura de bordas suaves, para dar fundo a um texto sem virar uma tarja.
///
/// O alpha é cheio num miolo e cai a zero nas quatro bordas, então a placa não tem
/// aresta em lugar nenhum — desde que a queda seja suavizada, ver hud_placa_eixo.
///
/// Desenhada uma FAIXA POR VEZ, e não um quadrilátero por célula: a faixa inteira sai
/// num trianglestrip só, os vértices são compartilhados entre as colunas e não existe
/// emenda onde o alpha possa somar. Treze primitivas no lugar de cento e sessenta e
/// nove, que é o que a mesma grade custaria célula a célula.
function hud_placa_suave(_x1, _y1, _x2, _y2, _cor, _pico, _fade_x, _fade_y) {
    var _ex = hud_placa_eixo(_x1, _x2, _fade_x);
    var _ey = hud_placa_eixo(_y1, _y2, _fade_y);

    var _nc = array_length(_ex.pos);
    var _nl = array_length(_ey.pos);

    for (var j = 0; j < _nl - 1; j++) {
        var _a0 = _pico * _ey.peso[j];
        var _a1 = _pico * _ey.peso[j + 1];

        draw_primitive_begin(pr_trianglestrip);

        for (var i = 0; i < _nc; i++) {
            var _w = _ex.peso[i];
            draw_vertex_colour(_ex.pos[i], _ey.pos[j],     _cor, _a0 * _w);
            draw_vertex_colour(_ex.pos[i], _ey.pos[j + 1], _cor, _a1 * _w);
        }

        draw_primitive_end();
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}

function hud_draw() {

    // O VERSUS TEM O PROPRIO HUD. O painel de pergaminho, o combo e a vinheta de
    // perigo sao todos de um jogador so — desenha-los aqui mostraria os numeros do
    // jogador 1 como se fossem da partida inteira.
    if (versus_ativo()) {
        var _e = global.hud_entrada;

        // O MESMO painel dos dois lados, um por jogador — ver hud_bloco_y. O jogador 1
        // fica com o painel acima do corredor dele, o 2 com o painel abaixo do dele.
        hud_painel_jogador(0, _e);
        hud_painel_jogador(1, _e);

        // BOM / OTIMO / PERFEITO de cada um na propria pista. O jogador 1 sobe a partir
        // do botao vermelho, exatamente como no solo; o 2 desce a partir do amarelo.
        hud_desenhar_julgamentos(0, _e);
        hud_desenhar_julgamentos(1, _e);

        // barra de progresso da fase, no rodape, igual ao modo de um jogador
        var _prog = 1;
        if (instance_exists(o_spawner_ritmo) && o_spawner_ritmo.duracao_total > 0) {
            _prog = 1 - (o_spawner_ritmo.minha_duracao / o_spawner_ritmo.duracao_total);
        }
        hud_barra(300, 708, 680, 10, _prog, make_colour_rgb(255, 122, 69), c_yellow, _e);

        ui_reset();
        return;
    }
    var _ctrl = o_controlador_geral;
    var _fase = _ctrl.fases_data[_ctrl.fase_atual];
    var _gw = display_get_gui_width();

    var _entrada = global.hud_entrada;

    draw_set_font(f_padrao);
    draw_set_alpha(_entrada);

    // ---------------------------------------------------------------
    // BLOCO PRINCIPAL — mesmo painel usado nos menus, para o HUD falar
    // a mesma língua visual do resto do jogo.
    // ---------------------------------------------------------------
    var _bloco_y = hud_bloco_y(solo_jogador());

    draw_sprite_stretched(s_menu_background_panel, 0, HUD_BLOCO_X, _bloco_y, HUD_BLOCO_W, HUD_BLOCO_H);

    var _esq = HUD_BLOCO_X + 20;
    var _dir = HUD_BLOCO_X + HUD_BLOCO_W - 20;
    var _tinta = make_colour_rgb(40, 28, 18); // marrom bem escuro, casa com o pergaminho

    hud_texto_painel(_esq, _bloco_y + 32, "Pontos", _tinta, f_padrao_pequena, fa_left);
    hud_texto_painel(_dir, _bloco_y + 32, string(round(global.hud_pontos_exibidos)), _tinta, f_padrao, fa_right);

    // ganho de pontos subindo a partir do próprio número
    hud_desenhar_ganho(solo_jogador(), _dir, _bloco_y + 14, _entrada);

    var _precisao = hud_precisao();
    hud_texto_painel(_esq, _bloco_y + 72, "Precisão", _tinta, f_padrao_pequena, fa_left);
    hud_texto_painel(_dir, _bloco_y + 72, ui_pct(_precisao), _tinta, f_padrao, fa_right);

    // linha separando os dados fixos do combo
    draw_set_alpha(0.25 * _entrada);
    draw_set_color(_tinta);
    draw_line(_esq, _bloco_y + 86, _dir, _bloco_y + 86);
    draw_set_alpha(_entrada);

    // combo — só existe a partir de HUD_COMBO_MINIMO acertos seguidos
    var _combo_x = HUD_BLOCO_X + (HUD_BLOCO_W / 2);
    var _combo_y = _bloco_y + 106;

    var _seq = jogador().stats_sequencia;
    if (_seq >= HUD_COMBO_MINIMO) {
        hud_texto_painel(_combo_x, _combo_y, "Combo x" + string(_seq),
                         hud_cor_combo(_seq), f_padrao, fa_center);
    }
    else if (global.hud_combo_quebra > 0) {
        // sequência quebrada: o número treme e some depressa
        var _qdur = room_speed * 0.4;
        var _qprog = 1 - (global.hud_combo_quebra / _qdur);
        var _tremor = (1 - _qprog) * 5;

        draw_set_alpha((1 - _qprog) * _entrada);
        hud_texto_painel(_combo_x + random_range(-_tremor, _tremor),
                         _combo_y + random_range(-_tremor, _tremor),
                         "Combo x" + string(global.hud_combo_exibido),
                         UI_COR_APAGADA, f_padrao, fa_center);
        draw_set_alpha(_entrada);
    }

    hud_desenhar_julgamentos(solo_jogador(), _entrada);

    // ---------------------------------------------------------------
    // PROGRESSO DA FASE — faixa de 13 px no rodapé
    // ---------------------------------------------------------------
    var _progresso = 1;
    if (instance_exists(o_spawner_ritmo) && o_spawner_ritmo.duracao_total > 0) {
        _progresso = 1 - (o_spawner_ritmo.minha_duracao / o_spawner_ritmo.duracao_total);
    }
    hud_barra(300, 708, 680, 10, _progresso, make_colour_rgb(255, 122, 69), c_yellow, _entrada);

    // ---------------------------------------------------------------
    // AVISO DE FORJA ESFRIANDO — só quando falta 1 erro para falhar
    // ---------------------------------------------------------------
    // O alerta tinha um estágio só, sempre a um erro de perder: na Espada o jogador
    // errava cinco vezes sem sinal nenhum e falhava na sexta. Agora ele cresce em
    // até 4 estágios (ver hud_perigo_estagio), e cresce em duas dimensões — o alpha
    // da vinheta e a velocidade do pulso.
    // Na fase imune do Arcade a forja NAO esfria: sem game over possivel, a vinheta
    // vermelha e o aviso estariam mentindo sobre um risco que nao existe — e assustando
    // exatamente o jogador que a imunidade existe para proteger.
    var _perigo = _ctrl.arcade_fase_imune()
        ? { estagio: 0, total: 1 }
        : hud_perigo_estagio(jogador().stats_sequencia_errada,
                             _fase.stats_limite_sequencia_errada);

    if (_perigo.estagio <= 0) {
        global.hud_aviso_ritmo = 1;
    } else {
        var _intensidade = _perigo.estagio / _perigo.total;

        // ciclo de 1,2 s no primeiro estágio a 0,87 s no último
        global.hud_aviso_ritmo = 0.6 + (0.4 * _intensidade);

        // no estágio final dá 0,30-0,60, que é exatamente o alerta de antes
        var _base = 0.10 + (0.20 * _intensidade);
        var _pulso = _base + _base * ((sin(global.hud_aviso_pulso) + 1) / 2);

        hud_vinheta_perigo(_pulso * _entrada);

        // O texto é a última chance, então fica só no estágio final — que nas três
        // fases é exatamente "um erro para perder". Aparecendo antes, ele deixaria
        // de significar isso.
        if (_perigo.estagio == _perigo.total) {
            draw_set_font(f_padrao);
            hud_texto(_gw / 2, 24, "A FORJA ESTÁ ESFRIANDO!", make_colour_rgb(255, 190, 170), 1);
        }
    }

    ui_reset();
}

// =================================================================
// TITULO DA FASE
// =================================================================

/// Segundos da janela inteira do titulo, contados do inicio da CONTAGEM.
///
/// A contagem dura 3 s, entao 4,0 deixa o titulo sumir 1 s DEPOIS de ela acabar e
/// muito antes da primeira nota — a mais cedo do jogo chega aos 4,94 s de musica, que
/// sao ~7,9 s de relogio de parede. O titulo nunca divide a tela com nota.
#macro HUD_TITULO_DUR      4.0
#macro HUD_TITULO_FADE_IN  0.4
#macro HUD_TITULO_FADE_OUT 0.8

/// Centro vertical da placa. Vai no MEIO DA TELA, e nao no cabecalho.
///
/// Duas razoes. A leitura: no topo o texto competia com o ceu e com a barra de vida,
/// e ninguem olha para o canto superior quando esta esperando a contagem. E o Versus:
/// se o layout duplo existir, o cabecalho vira corredor de notas do jogador 2, e o
/// titulo teria de sair dali de qualquer jeito.
///
/// Nao colide com a contagem regressiva, que e desenhada dentro do corredor de notas
/// (HUD_CORREDOR_TOPO..BASE), bem abaixo daqui.
#macro HUD_TITULO_CY     300
#macro HUD_TITULO_ALTURA 210

/// Quanto tempo, em frames, desde o inicio da contagem desta fase.
///
/// Derivado, sem variavel nova: durante a CONTAGEM sai do proprio contagem_timer, que
/// anda para tras, e depois emenda no hud_fase_timer, que comeca do zero quando o
/// ritmo comeca.
function hud_titulo_tempo() {
    var _ctrl = o_controlador_geral;
    var _contagem = 3 * room_speed;

    if (_ctrl.estado_jogo == MINIGAME.CONTAGEM) {
        return _contagem - _ctrl.contagem_timer;
    }
    return _contagem + global.hud_fase_timer;
}

/// Placa de abertura com o nome da fase. Chamada na CONTAGEM e no RITMO.
///
/// Antes vivia dentro de hud_draw, que so roda no RITMO — ou seja, o titulo aparecia
/// DEPOIS da contagem e ficava 5 s por cima da partida ja em andamento. Agora ele abre
/// junto com a contagem e ja saiu quando a fase comeca de fato.
function hud_titulo_fase() {
    var _fase = o_controlador_geral.fases_data[o_controlador_geral.fase_atual];

    var _t = hud_titulo_tempo() / room_speed;
    if (_t < 0 || _t >= HUD_TITULO_DUR) {
        return;
    }

    // entra em degrade, segura, e sai em degrade
    var _alpha = 1;
    if (_t < HUD_TITULO_FADE_IN) {
        _alpha = _t / HUD_TITULO_FADE_IN;
    } else if (_t > HUD_TITULO_DUR - HUD_TITULO_FADE_OUT) {
        _alpha = (HUD_TITULO_DUR - _t) / HUD_TITULO_FADE_OUT;
    }

    var _gw = display_get_gui_width();
    var _meia = HUD_TITULO_ALTURA / 2;

    // No Versus a faixa se centra na CENA — o vao entre os dois corredores —, e nao no
    // valor fixo de um jogador. Com o corredor de cima ocupando o topo, 300 deixava a
    // placa 60 px acima do centro real.
    var _cy = versus_ativo()
        ? ((RITMO_CORREDOR_P2 + RITMO_CORREDOR_ALTURA + RITMO_CORREDOR_P1) / 2)
        : HUD_TITULO_CY;

    // Mesma opacidade do texto flutuante (UI_PLACA_ALPHA), para as duas faixas lerem
    // como a mesma coisa.
    //
    // O degrade lateral e longo DE PROPOSITO aqui, e so aqui: esta faixa vai de ponta
    // a ponta da tela, entao ela precisa dissolver nas bordas ou viraria uma tarja
    // atravessada. Na vertical vale a regra do texto flutuante — cauda curta, para a
    // faixa ter forma em vez de virar mancha.
    hud_placa_suave(0, _cy - _meia, _gw, _cy + _meia,
                    c_black, UI_PLACA_ALPHA * _alpha, 300, 22);

    draw_set_alpha(_alpha);

    // Corpo maior nas duas linhas, sempre em ESCALA INTEIRA (D-33): o nome sai em
    // f_padrao dobrada e a segunda linha troca a fonte pequena pela padrao. Escala
    // fracionaria suja o traco da fonte de pixel, entao 1,5 nao era opcao — o degrau
    // possivel e esse.
    draw_set_font(f_padrao);
    hud_texto(_gw / 2, _cy - 30, string_upper(_fase.nome), c_white, 2);

    // Branco tambem na segunda linha: a 0,62 de placa o creme cai para 4,3:1, abaixo
    // do minimo. A hierarquia entre as duas ja vem do corpo, nao da cor.
    hud_texto(_gw / 2, _cy + 42,
              _fase.dificuldade + "  -  " + string(round(_fase.beat_tempo_bpm)) + " BPM",
              c_white, 1);

    draw_set_alpha(1);
}

// =================================================================
// HUD DO VERSUS
//
// O painel de pergaminho e do modo de um jogador e fica onde sempre esteve. No Versus
// ele nao serve: sao dois placares, e um deles precisa ficar perto do corredor de
// cima. Entra no lugar um par de leituras compactas, uma junto de cada pista.
// =================================================================

/// Cor de cada jogador. Vem da paleta da forja, nao de vermelho-contra-azul: o
/// jogador 1 e o cobre que o jogo inteiro usa, e o jogador 2 e o verde-oliva do
/// ferreiro de paleta trocada.
function versus_cor(_dono) {
    return (_dono == 0) ? make_colour_rgb(198,  56,  48)    // jogador 1, vermelho
                        : make_colour_rgb( 62, 108, 190);   // jogador 2, azul
}

function versus_nome(_dono) {
    return (_dono == 0) ? "JOGADOR 1" : "JOGADOR 2";
}

/// Onde fica o painel de um jogador.
///
/// O MESMO painel de pergaminho dos dois lados, e nao uma leitura solta para o jogador
/// 2: ele e a lingua visual do jogo inteiro, e trocar de caixa so para o de cima faria
/// os dois placares parecerem coisas diferentes.
///
/// O jogador 1 tem o painel ACIMA do corredor dele, como sempre teve. O do jogador 2
/// fica ABAIXO do corredor dele — os dois ficam entre a pista e a cena, que e onde
/// sobra espaco em cada metade.
function hud_bloco_y(_dono) {
    if (!versus_ativo()) return HUD_BLOCO_Y;

    // O jogador 1 tem 20 px entre a caixa e o corredor dele (492 - 344 - 128). O
    // jogador 2 precisa dos MESMOS 20 px do outro lado: o corredor dele acaba em 228,
    // entao a caixa comeca em 248. Antes ela encostava na faixa.
    return (_dono == 0)
        ? HUD_BLOCO_Y
        : (RITMO_CORREDOR_P2 + RITMO_CORREDOR_ALTURA + 20);
}

/// Para que lado sobe o texto de julgamento deste jogador.
///
/// Sobe no jogador 1 e DESCE no jogador 2: em cada metade da tela o texto se afasta da
/// pista em vez de atravessa-la, e o gesto fica espelhado como o resto do layout.
function hud_sentido_julgamento(_dono) {
    if (!versus_ativo()) return -1;
    return (_dono == 0) ? -1 : 1;
}

/// O painel de pergaminho de um jogador, com pontos, precisao e combo.
///
/// E o MESMO painel do modo de um jogador, so que posicionado pelo dono. Reaproveita-lo
/// era o certo: uma caixa diferente para o jogador de cima faria os dois placares
/// parecerem coisas de naturezas diferentes, quando eles medem exatamente o mesmo.
function hud_painel_jogador(_dono, _alpha) {
    var _j = jogador(_dono);
    var _y = hud_bloco_y(_dono);

    // O JOGADOR 1 FICA ONDE SEMPRE FICOU — canto esquerdo, acima do corredor dele. E o
    // enquadramento validado, e mexer nele so porque existe um segundo jogador seria
    // mudar o que ja estava certo.
    //
    // O jogador 2 e o espelho: canto direito, abaixo do corredor dele. Centrar os dois
    // no meio da tela, como cheguei a fazer, empilhava as duas caixas em cima da forja
    // e escondia a cena inteira.
    var _x = (_dono == 0)
        ? HUD_BLOCO_X
        : (display_get_gui_width() - HUD_BLOCO_X - HUD_BLOCO_W);

    var _tinta = make_colour_rgb(40, 28, 18);
    var _meio = _x + (HUD_BLOCO_W / 2);

    draw_set_alpha(_alpha);
    draw_sprite_stretched(s_menu_background_panel, 0, _x, _y, HUD_BLOCO_W, HUD_BLOCO_H);

    var _esq = _x + 20;
    var _dir = _x + HUD_BLOCO_W - 20;

    hud_texto_painel(_meio, _y + 22, versus_nome(_dono), versus_cor(_dono),
                     f_padrao_pequena, fa_center);

    hud_texto_painel(_esq, _y + 60, "Pontos", _tinta, f_padrao_pequena, fa_left);
    hud_texto_painel(_dir, _y + 60, string(_j.pontuacao), _tinta, f_padrao, fa_right);

    // O MESMO "+N" do solo, subindo a partir do proprio numero. Num Versus a diferenca
    // de pontos e a unica coisa que os dois olham, e sem o incremento nao da para saber
    // se a marretada valeu 50 ou 300 — a leitura fica so no total, que muda rapido
    // demais para ser acompanhado.
    hud_desenhar_ganho(_dono, _dir, _y + 42, _alpha);

    var _seq = _j.stats_sequencia;
    if (_seq >= HUD_COMBO_MINIMO) {
        hud_texto_painel(_meio, _y + 100, "Combo x" + string(_seq),
                         hud_cor_combo(_seq), f_padrao, fa_center);
    }

    draw_set_alpha(1);
}

/// Placar compacto de um jogador, ancorado no corredor dele.
function versus_placar(_dono, _alpha) {
    var _gw = display_get_gui_width();
    var _j = jogador(_dono);

    // fica na ponta OPOSTA a linha de acerto, onde a pista esta vazia
    var _x = (_dono == 0) ? (_gw - 30) : 30;
    var _halign = (_dono == 0) ? fa_right : fa_left;

    var _y = ritmo_corredor_topo(_dono) + ((_dono == 0) ? -34 : 202);

    draw_set_alpha(_alpha);

    draw_set_font(f_padrao_pequena);
    hud_texto(_x, _y - 22, versus_nome(_dono), versus_cor(_dono), 1, _halign);

    draw_set_font(f_padrao);
    hud_texto(_x, _y + 8, string(_j.pontuacao), versus_cor(_dono), 1, _halign);

    if (_j.stats_sequencia >= HUD_COMBO_MINIMO) {
        draw_set_font(f_padrao_pequena);
        hud_texto(_x, _y + 36, "x" + string(_j.stats_sequencia),
                  hud_cor_combo(_j.stats_sequencia), 1, _halign);
    }

    draw_set_alpha(1);
}

/// Diz de quem e cada pista, durante a preparacao.
///
/// Mesmo tratamento do "Prepare-se para forjar em..." da contagem: texto preto direto
/// sobre o pergaminho do corredor, sem placa. A placa flutuante ficava pesada e
/// deslocada — ela existe para texto sobre fundo DESCONHECIDO, e aqui o fundo e o
/// corredor, cuja cor o jogo conhece.
///
/// Duas linhas: o nome do jogador por cima, em cor propria, e a instrucao embaixo.
function versus_marcar_pistas(_alpha) {
    if (_alpha <= 0) return;

    var _cx = display_get_gui_width() / 2;

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_alpha(_alpha);

    // NA BORDA EXTERNA de cada corredor, e nao no meio: o meio e onde a contagem
    // regressiva e desenhada, e os dois textos se sobrepunham durante a preparacao.
    //
    // O rotulo do jogador 2 sobe para o topo do corredor dele; o do jogador 1 desce
    // para a base do dele. Cada um se afasta do centro para o proprio lado.
    for (var _d = 0; _d < 2; _d++) {
        var _topo = ritmo_corredor_topo(_d);
        var _y = (_d == 0) ? (_topo + 200) : (_topo + 26);

        draw_set_font(f_padrao);
        draw_set_color(versus_cor(_d));
                // Hifen simples: o travessao nao existe na Kobold 7 e virava um quadrado
        // vazio na tela.
        draw_text(_cx, _y, versus_nome(_d) + " - esta é a sua pista");
    }

    draw_set_alpha(1);
    ui_reset();
}

