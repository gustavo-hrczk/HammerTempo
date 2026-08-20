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
function hud_barra(_x, _y, _largura, _altura, _fracao, _cor_a, _cor_b) {
    _fracao = clamp(_fracao, 0, 1);

    draw_set_alpha(0.55);
    draw_set_color(c_black);
    draw_rectangle(_x, _y, _x + _largura, _y + _altura, false);
    draw_set_alpha(1);

    if (_fracao > 0) {
        draw_rectangle_colour(_x, _y, _x + (_largura * _fracao), _y + _altura,
                              _cor_a, _cor_b, _cor_b, _cor_a, false);
    }

    draw_set_color(c_black);
    draw_rectangle(_x, _y, _x + _largura, _y + _altura, true);
}

/// Prepara as variáveis de animação do HUD. Chamado pelo controlador geral.
function hud_init() {
    global.hud_pontos_exibidos = 0;
    global.hud_ganho_valor = 0;
    global.hud_ganho_timer = 0;
    global.hud_ganho_cor = c_white;
    global.hud_julg_texto = "";
    global.hud_julg_cor = c_white;
    global.hud_julg_timer = 0;
    global.hud_julg_sobe = true;
    global.hud_combo_anterior = 0;
    global.hud_combo_exibido = 0;
    global.hud_combo_quebra = 0;
    global.hud_fase_timer = 0;
    global.hud_aviso_pulso = 0;
}

/// Reinicia o HUD no começo de cada partida.
function hud_resetar() {
    global.hud_pontos_exibidos = 0;
    global.hud_ganho_valor = 0;
    global.hud_ganho_timer = 0;
    global.hud_julg_texto = "";
    global.hud_julg_timer = 0;
    global.hud_combo_anterior = 0;
    global.hud_combo_exibido = 0;
    global.hud_combo_quebra = 0;
    global.hud_fase_timer = 0;
}

/// Anima os valores do HUD. Chamado uma vez por frame durante a partida.
function hud_update() {
    var _ctrl = o_controlador_geral;

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
    global.hud_aviso_pulso += 0.12;
    global.hud_ganho_timer = max(0, global.hud_ganho_timer - 1);
    global.hud_julg_timer = max(0, global.hud_julg_timer - 1);
}

/// Registra um ganho de pontos, que sobe a partir do próprio número da pontuação.
/// Precisa ser desenhado pelo HUD (e não por um objeto): o painel está no Draw GUI,
/// então qualquer coisa em espaço de room apareceria atrás dele.
function hud_registrar_ganho(_valor, _cor = c_white) {
    global.hud_ganho_valor = _valor;
    global.hud_ganho_cor = _cor;
    global.hud_ganho_timer = room_speed * 0.7;
}

/// Julgamento do acerto, exibido na parte de baixo do bloco. Fica no HUD (e não num
/// objeto solto) porque o painel é desenhado no Draw GUI: em espaço de room, o texto
/// apareceria atrás dele. Um julgamento novo sempre substitui o anterior.
function hud_registrar_julgamento(_texto, _cor, _sobe = true) {
    global.hud_julg_texto = _texto;
    global.hud_julg_cor = _cor;
    global.hud_julg_sobe = _sobe;
    global.hud_julg_timer = room_speed * 0.55;
}

/// Cor do combo, esquentando conforme a sequência cresce: brasa escura, laranja,
/// ouro e por fim quase branco — a mesma leitura de temperatura do metal na forja.
function hud_cor_combo(_combo) {
    if (_combo >= 45) return make_colour_rgb(255, 240, 205);

    if (_combo >= 30) {
        return merge_colour(make_colour_rgb(255, 190, 60), make_colour_rgb(255, 240, 205), (_combo - 30) / 15);
    }
    if (_combo >= 15) {
        return merge_colour(make_colour_rgb(226, 120, 30), make_colour_rgb(255, 190, 60), (_combo - 15) / 15);
    }
    return merge_colour(make_colour_rgb(178, 58, 22), make_colour_rgb(226, 120, 30), (_combo - HUD_COMBO_MINIMO) / 10);
}

/// Desenha o HUD da partida (evento Draw GUI).
function hud_draw() {
    var _ctrl = o_controlador_geral;
    var _fase = _ctrl.fases_data[_ctrl.fase_atual];
    var _gw = display_get_gui_width();

    draw_set_font(f_padrao);

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

        draw_set_alpha(1 - (_prog * _prog));
        hud_texto_painel(_dir, HUD_BLOCO_Y + 14 - (_prog * 22),
                         "+" + string(global.hud_ganho_valor),
                         global.hud_ganho_cor, f_padrao, fa_right);
        draw_set_alpha(1);
    }

    var _acertos = _ctrl.stats_acertos_perfeitos + _ctrl.stats_acertos_otimos + _ctrl.stats_acertos_bons;
    var _julgadas = _acertos + _ctrl.stats_erros;
    var _precisao = (_julgadas > 0) ? (_acertos / _julgadas) * 100 : 100;
    hud_texto_painel(_esq, HUD_BLOCO_Y + 72, "Precisão", _tinta, f_padrao_pequena, fa_left);
    hud_texto_painel(_dir, HUD_BLOCO_Y + 72, string(round(_precisao)) + "%", _tinta, f_padrao, fa_right);

    // linha separando os dados fixos do combo
    draw_set_alpha(0.25);
    draw_set_color(_tinta);
    draw_line(_esq, HUD_BLOCO_Y + 86, _dir, HUD_BLOCO_Y + 86);
    draw_set_alpha(1);

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

        draw_set_alpha(1 - _qprog);
        hud_texto_painel(_combo_x + random_range(-_tremor, _tremor),
                         _combo_y + random_range(-_tremor, _tremor),
                         "Combo x" + string(global.hud_combo_exibido),
                         make_colour_rgb(120, 105, 95), f_padrao, fa_center);
        draw_set_alpha(1);
    }

    // ---------------------------------------------------------------
    // JULGAMENTO — logo abaixo do bloco, na faixa livre antes do corredor
    // ---------------------------------------------------------------
    if (global.hud_julg_timer > 0) {
        var _jdur = room_speed * 0.55;
        var _jprog = 1 - (global.hud_julg_timer / _jdur);

        // Sem escala fracionária: o impacto vem do deslocamento e da opacidade,
        // mais um clarão de cor nos primeiros frames.
        var _jdesloca = (global.hud_julg_sobe ? -1 : 1) * round(_jprog * 10);
        var _cor_julg = (_jprog < 0.15)
            ? merge_colour(global.hud_julg_cor, c_white, 0.6)
            : global.hud_julg_cor;

        draw_set_font(f_padrao);
        draw_set_alpha(1 - (_jprog * _jprog));

        hud_texto(HUD_BLOCO_X + (HUD_BLOCO_W / 2),
                  HUD_BLOCO_Y + HUD_BLOCO_H + 16 + _jdesloca,
                  global.hud_julg_texto, _cor_julg, 1);

        draw_set_alpha(1);
    }

    // ---------------------------------------------------------------
    // NOME DA FASE — abertura, some depois de 4 s
    // ---------------------------------------------------------------
    var _fade_inicio = room_speed * 4;
    if (global.hud_fase_timer < _fade_inicio + room_speed) {
        var _alpha = (global.hud_fase_timer < _fade_inicio)
            ? 1
            : 1 - ((global.hud_fase_timer - _fade_inicio) / room_speed);

        draw_set_alpha(_alpha);
        draw_set_font(f_padrao);
        hud_texto(_gw / 2, 40, string_upper(_fase.nome), c_white, 1);
        draw_set_font(f_padrao_pequena);
        hud_texto(_gw / 2, 74, _fase.dificuldade + "  -  " + string(_fase.beat_tempo_bpm) + " BPM", c_white, 1);
        draw_set_alpha(1);
    }

    // ---------------------------------------------------------------
    // PROGRESSO DA FASE — faixa de 13 px no rodapé
    // ---------------------------------------------------------------
    var _progresso = 1;
    if (instance_exists(o_spawner_ritmo) && o_spawner_ritmo.duracao_total > 0) {
        _progresso = 1 - (o_spawner_ritmo.minha_duracao / o_spawner_ritmo.duracao_total);
    }
    hud_barra(300, 708, 680, 10, _progresso, make_colour_rgb(255, 122, 69), c_yellow);

    // ---------------------------------------------------------------
    // AVISO DE FORJA ESFRIANDO — só quando falta 1 erro para falhar
    // ---------------------------------------------------------------
    var _limite = _fase.stats_limite_sequencia_errada;
    if (_ctrl.stats_sequencia_errada >= _limite - 1 && _ctrl.stats_sequencia_errada < _limite) {
        var _pulso = 0.22 + 0.22 * ((sin(global.hud_aviso_pulso) + 1) / 2);

        draw_set_alpha(_pulso);
        draw_set_color(make_colour_rgb(200, 30, 20));
        draw_rectangle(0, 0, _gw, 46, false);
        draw_rectangle(0, 0, 54, display_get_gui_height(), false);
        draw_rectangle(_gw - 54, 0, _gw, display_get_gui_height(), false);
        draw_set_alpha(1);

        draw_set_font(f_padrao);
        hud_texto(_gw / 2, 24, "A FORJA ESTÁ ESFRIANDO!", make_colour_rgb(255, 190, 170), 1);
    }

    ui_reset();
}
