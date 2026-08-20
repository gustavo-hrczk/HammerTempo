/// scr_hud — HUD de partida
///
/// Duas regras de ouro:
/// 1. Nada pode ser desenhado dentro do corredor das notas (y 515 a 707, largura inteira).
/// 2. O jogador olha para a margem de acerto, no canto inferior esquerdo. Toda a
///    informação de partida vive ali por perto, e não no canto oposto da tela.

#macro HUD_CORREDOR_TOPO 515
#macro HUD_CORREDOR_BASE 707

/// Bloco de informação, ancorado logo acima da margem de acerto.
#macro HUD_BLOCO_X 14
#macro HUD_BLOCO_Y 344
#macro HUD_BLOCO_W 330
#macro HUD_BLOCO_H 128

/// Onde o julgamento nasce: logo acima do bloco.
#macro HUD_JULGAMENTO_X 179
#macro HUD_JULGAMENTO_Y 314

/// Combo só é anunciado a partir daqui.
#macro HUD_COMBO_MINIMO 5

/// Texto com contorno preto, legível sobre o céu e sobre o painel.
function hud_texto(_x, _y, _texto, _cor, _escala = 1, _halign = fa_center) {
    draw_set_halign(_halign);
    draw_set_valign(fa_middle);

    draw_set_color(c_black);
    var _off = max(1, round(2 * _escala));
    for (var _dx = -1; _dx <= 1; _dx++) {
        for (var _dy = -1; _dy <= 1; _dy++) {
            if (_dx == 0 && _dy == 0) continue;
            draw_text_transformed(_x + (_dx * _off), _y + (_dy * _off), _texto, _escala, _escala, 0);
        }
    }

    draw_set_color(_cor);
    draw_text_transformed(_x, _y, _texto, _escala, _escala, 0);
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
    global.hud_combo_escala = 1;
    global.hud_combo_anterior = 0;
    global.hud_fase_timer = 0;
    global.hud_aviso_pulso = 0;
}

/// Reinicia o HUD no começo de cada partida.
function hud_resetar() {
    global.hud_pontos_exibidos = 0;
    global.hud_combo_escala = 1;
    global.hud_combo_anterior = 0;
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

    // combo dá um "pop" toda vez que cresce
    if (_ctrl.stats_sequencia > global.hud_combo_anterior) {
        global.hud_combo_escala = 1.5;
    }
    global.hud_combo_anterior = _ctrl.stats_sequencia;
    global.hud_combo_escala += (1 - global.hud_combo_escala) * 0.2;

    global.hud_fase_timer++;
    global.hud_aviso_pulso += 0.12;
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

    var _esq = HUD_BLOCO_X + 24;
    var _dir = HUD_BLOCO_X + HUD_BLOCO_W - 24;
    var _tinta = make_colour_rgb(40, 28, 18); // marrom bem escuro, casa com o pergaminho

    hud_texto_painel(_esq, HUD_BLOCO_Y + 32, "Pontos", _tinta, f_padrao_pequena, fa_left);
    hud_texto_painel(_dir, HUD_BLOCO_Y + 32, string(round(global.hud_pontos_exibidos)), _tinta, f_padrao, fa_right);

    var _acertos = _ctrl.stats_acertos_perfeitos + _ctrl.stats_acertos_bons;
    var _julgadas = _acertos + _ctrl.stats_erros;
    var _precisao = (_julgadas > 0) ? (_acertos / _julgadas) * 100 : 100;
    hud_texto_painel(_esq, HUD_BLOCO_Y + 72, "Precisão", _tinta, f_padrao_pequena, fa_left);
    hud_texto_painel(_dir, HUD_BLOCO_Y + 72, string(round(_precisao)) + "%", _tinta, f_padrao, fa_right);

    // linha separando os dados fixos do combo
    draw_set_alpha(0.25);
    draw_set_color(_tinta);
    draw_line(_esq, HUD_BLOCO_Y + 86, _dir, HUD_BLOCO_Y + 86);
    draw_set_alpha(1);

    // combo — só existe a partir de HUD_COMBO_MINIMO acertos seguidos.
    // Aqui a escala varia de propósito: é o único elemento que reage a cada acerto.
    if (_ctrl.stats_sequencia >= HUD_COMBO_MINIMO) {
        draw_set_font(f_padrao);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(make_colour_rgb(178, 58, 22));
        var _e = min(global.hud_combo_escala, 1.25);
        draw_text_transformed(HUD_BLOCO_X + (HUD_BLOCO_W / 2), HUD_BLOCO_Y + 106,
                              "Combo x" + string(_ctrl.stats_sequencia), _e, _e, 0);
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
        hud_texto(_gw / 2, 40, string_upper(_fase.nome), c_white, 0.85);
        hud_texto(_gw / 2, 72, _fase.dificuldade + "  -  " + string(_fase.beat_tempo_bpm) + " BPM", c_white, 0.55);
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

        hud_texto(_gw / 2, 24, "A FORJA ESTÁ ESFRIANDO!", make_colour_rgb(255, 190, 170), 0.8);
    }

    ui_reset();
}

/// Cria um julgamento logo acima do bloco de HUD, no campo de visão de quem está
/// olhando para a margem de acerto. Os anteriores encolhem e aceleram, formando a
/// cascata; no máximo 3 ficam na tela ao mesmo tempo.
function julgamento_criar(_texto, _cor, _sobe = true, _pontos = 0) {
    with (o_julgamento) {
        escala_alvo *= 0.7;
        vel_y *= 1.35;
        if (vida < 10) vida = 10;
    }

    if (instance_number(o_julgamento) >= 3) {
        var _mais_velho = noone;
        var _maior_vida = -1;
        with (o_julgamento) {
            if (vida > _maior_vida) {
                _maior_vida = vida;
                _mais_velho = id;
            }
        }
        if (_mais_velho != noone) instance_destroy(_mais_velho);
    }

    var _j = instance_create_layer(HUD_JULGAMENTO_X, HUD_JULGAMENTO_Y, "Gameplay", o_julgamento);
    _j.texto = _texto;
    _j.cor = _cor;
    _j.escala = 0.4;
    _j.escala_alvo = _sobe ? 1.15 : 0.9;
    _j.vel_y = _sobe ? -2.2 : 2.2;
    _j.vel_x = random_range(-0.5, 0.5);

    // pontos ganhos acompanham o julgamento, menores e mais discretos
    if (_pontos != 0) {
        var _p = instance_create_layer(HUD_JULGAMENTO_X + 96, HUD_JULGAMENTO_Y + 20, "Gameplay", o_julgamento);
        _p.texto = "+" + string(_pontos);
        _p.cor = c_white;
        _p.escala = 0.3;
        _p.escala_alvo = 0.6;
        _p.vel_y = -1.6;
        _p.vel_x = 0.4;
        _p.vida = 6;
    }

    return _j;
}
