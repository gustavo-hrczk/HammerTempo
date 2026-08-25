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
    global.hud_ganho_valor = 0;
    global.hud_ganho_timer = 0;
    global.hud_ganho_cor = c_white;
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
    global.hud_pontos_exibidos = 0;
    global.hud_ganho_valor = 0;
    global.hud_ganho_timer = 0;
    global.hud_julgamentos = [];
    global.hud_combo_anterior = 0;
    global.hud_combo_exibido = 0;
    global.hud_combo_quebra = 0;
    global.hud_fase_timer = 0;
    global.hud_entrada = 0;
}

/// Anima os valores do HUD. Chamado uma vez por frame durante a partida.
function hud_update() {
    var _ctrl = o_controlador_geral;

    // O HUD e os trilhos entram em fade quando a contagem termina, em vez de
    // aparecerem de uma vez junto com a primeira nota.
    global.hud_entrada = min(1, global.hud_entrada + (1 / (room_speed * 0.45)));

    // pontuação sobe suavemente até o valor real
    var _alvo = _ctrl.pontuacao;
    if (abs(global.hud_pontos_exibidos - _alvo) < 1) {
        global.hud_pontos_exibidos = _alvo;
    } else {
        global.hud_pontos_exibidos += (_alvo - global.hud_pontos_exibidos) * 0.25;
    }

    // o combo tem tamanho fixo: quem comunica o crescimento é a cor, que vai
    // esquentando. A quebra ganha um tremor curto com o último valor alcançado.
    var _combo = _ctrl.stats_sequencia;

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
    global.hud_ganho_timer = max(0, global.hud_ganho_timer - 1);

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
function hud_registrar_ganho(_valor, _cor = c_white) {
    global.hud_ganho_valor = _valor;
    global.hud_ganho_cor = _cor;
    global.hud_ganho_timer = room_speed * 0.7;
}

/// Julgamento do acerto. Fica no HUD (e não num objeto solto) porque o painel é
/// desenhado no Draw GUI: em espaço de room, o texto apareceria atrás dele.
///
/// Cada acerto empilha um item novo em vez de substituir o anterior. Como o jogador
/// acerta em sequência — é a proposta do jogo —, o slot único fazia o texto ser
/// trocado no meio da animação e aos olhos virava tremulação. Agora cada julgamento
/// sobe e some no seu próprio tempo, e os que ainda estão subindo ficam em alturas
/// diferentes: a sobreposição vira leitura de sequência.
function hud_registrar_julgamento(_texto, _cor, _sobe = true) {
    array_push(global.hud_julgamentos, {
        texto: _texto,
        cor: _cor,
        sobe: _sobe,
        timer: 0,
        dur: room_speed * 0.7,
        desvio_x: irandom_range(-9, 9)
    });

    // teto de 3 simultâneos: acima disso vira poluição
    while (array_length(global.hud_julgamentos) > 3) {
        array_delete(global.hud_julgamentos, 0, 1);
    }
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

/// Placa escura de bordas suaves, para dar fundo a um texto sem virar uma tarja.
///
/// O alpha é cheio num miolo e cai a zero nas quatro bordas, então a placa não tem
/// aresta em lugar nenhum. É uma grade 3x3 de quadriláteros com cor por vértice: as
/// nove peças encostam sem se cobrir, o que evita alpha somado nas emendas.
function hud_placa_suave(_x1, _y1, _x2, _y2, _cor, _pico, _fade_x, _fade_y) {
    var _xs = [_x1, _x1 + _fade_x, _x2 - _fade_x, _x2];
    var _ys = [_y1, _y1 + _fade_y, _y2 - _fade_y, _y2];
    var _f  = [0, 1, 1, 0];   // peso do alpha em cada linha da grade

    for (var i = 0; i < 3; i++) {
        for (var j = 0; j < 3; j++) {
            draw_primitive_begin(pr_trianglestrip);
            draw_vertex_colour(_xs[i],     _ys[j],     _cor, _pico * _f[i]     * _f[j]);
            draw_vertex_colour(_xs[i],     _ys[j + 1], _cor, _pico * _f[i]     * _f[j + 1]);
            draw_vertex_colour(_xs[i + 1], _ys[j],     _cor, _pico * _f[i + 1] * _f[j]);
            draw_vertex_colour(_xs[i + 1], _ys[j + 1], _cor, _pico * _f[i + 1] * _f[j + 1]);
            draw_primitive_end();
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}

function hud_draw() {
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
    draw_sprite_stretched(s_menu_background_panel, 0, HUD_BLOCO_X, HUD_BLOCO_Y, HUD_BLOCO_W, HUD_BLOCO_H);

    var _esq = HUD_BLOCO_X + 20;
    var _dir = HUD_BLOCO_X + HUD_BLOCO_W - 20;
    var _tinta = make_colour_rgb(40, 28, 18); // marrom bem escuro, casa com o pergaminho

    hud_texto_painel(_esq, HUD_BLOCO_Y + 32, "Pontos", _tinta, f_padrao_pequena, fa_left);
    hud_texto_painel(_dir, HUD_BLOCO_Y + 32, string(round(global.hud_pontos_exibidos)), _tinta, f_padrao, fa_right);

    // ganho de pontos subindo a partir do próprio número
    if (global.hud_ganho_timer > 0) {
        var _dur = room_speed * 0.7;
        var _prog = 1 - (global.hud_ganho_timer / _dur);

        draw_set_alpha((1 - (_prog * _prog)) * _entrada);
        hud_texto_painel(_dir, HUD_BLOCO_Y + 14 - (_prog * 22),
                         "+" + string(global.hud_ganho_valor),
                         global.hud_ganho_cor, f_padrao, fa_right);
        draw_set_alpha(_entrada);
    }

    var _acertos = _ctrl.stats_acertos_perfeitos + _ctrl.stats_acertos_otimos + _ctrl.stats_acertos_bons;
    var _julgadas = _acertos + _ctrl.stats_erros;
    var _precisao = (_julgadas > 0) ? (_acertos / _julgadas) * 100 : 100;
    hud_texto_painel(_esq, HUD_BLOCO_Y + 72, "Precisão", _tinta, f_padrao_pequena, fa_left);
    hud_texto_painel(_dir, HUD_BLOCO_Y + 72, string(round(_precisao)) + "%", _tinta, f_padrao, fa_right);

    // linha separando os dados fixos do combo
    draw_set_alpha(0.25 * _entrada);
    draw_set_color(_tinta);
    draw_line(_esq, HUD_BLOCO_Y + 86, _dir, HUD_BLOCO_Y + 86);
    draw_set_alpha(_entrada);

    // combo — só existe a partir de HUD_COMBO_MINIMO acertos seguidos
    var _combo_x = HUD_BLOCO_X + (HUD_BLOCO_W / 2);
    var _combo_y = HUD_BLOCO_Y + 106;

    if (_ctrl.stats_sequencia >= HUD_COMBO_MINIMO) {
        hud_texto_painel(_combo_x, _combo_y, "Combo x" + string(_ctrl.stats_sequencia),
                         hud_cor_combo(_ctrl.stats_sequencia), f_padrao, fa_center);
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

    // ---------------------------------------------------------------
    // JULGAMENTOS — sobem a partir da base do bloco e somem no caminho
    // ---------------------------------------------------------------
    var _jx = HUD_BLOCO_X + (HUD_BLOCO_W / 2);
    // 30 px abaixo da base do bloco. O corredor das notas começa em y = 515 e o
    // texto tem 30 px de altura, então a borda de baixo encosta nele por 2 px —
    // o limite prático de quanto a origem pode descer.
    var _jy_base = HUD_BLOCO_Y + HUD_BLOCO_H + 30;

    draw_set_font(f_padrao);

    for (var i = 0; i < array_length(global.hud_julgamentos); i++) {
        var _j = global.hud_julgamentos[i];
        var _prog = _j.timer / _j.dur;

        // sobe rápido e vai freando. A distância é curta de propósito: subindo
        // demais o texto atravessava o bloco inteiro e perdia a âncora visual.
        // O erro afunda pouco, só o suficiente para a direção marcar a falha.
        var _distancia = _j.sobe ? 33 : 16;
        var _desloca = _distancia * (1 - power(1 - _prog, 2));
        if (_j.sobe) _desloca = -_desloca;

        // Opaco no impacto e totalmente apagado aos 65% do trajeto: o movimento
        // continua o mesmo, mas o texto já sumiu antes de subir sobre o combo.
        var _alpha = (_prog < 0.2) ? 1 : max(0, 1 - ((_prog - 0.2) / 0.45));

        // clarão de cor nos primeiros frames
        var _cor = (_prog < 0.12) ? merge_colour(_j.cor, c_white, 0.55) : _j.cor;

        draw_set_alpha(_alpha * _entrada);
        hud_texto(_jx + _j.desvio_x, round(_jy_base + _desloca), _j.texto, _cor, 1);
    }

    draw_set_alpha(1);

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
        : hud_perigo_estagio(_ctrl.stats_sequencia_errada,
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

    // A placa vai de ponta a ponta e o alpha cai a zero em 420 px de cada lado, entao
    // ela nao lê como tarja. O miolo cobre as duas linhas com folga.
    hud_placa_suave(0, HUD_TITULO_CY - _meia, _gw, HUD_TITULO_CY + _meia,
                    c_black, UI_PLACA_ALPHA * _alpha, 420, 46);

    draw_set_alpha(_alpha);

    draw_set_font(f_padrao);
    hud_texto(_gw / 2, HUD_TITULO_CY - 22, string_upper(_fase.nome), c_white, 1);

    draw_set_font(f_padrao_pequena);
    hud_texto(_gw / 2, HUD_TITULO_CY + 26,
              _fase.dificuldade + "  -  " + string(round(_fase.beat_tempo_bpm)) + " BPM",
              UI_COR_PERGAMINHO, 1);

    draw_set_alpha(1);
}
