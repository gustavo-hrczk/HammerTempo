// Este menu só desenha no estado de seleção de fase
if (o_controlador_geral.estado_jogo != MINIGAME.SELECAO_FASE) {
    exit;
}

// =================================================================
// CARTÕES DE FASE
// Cada fase mostra a arma que se pretende forjar, a dificuldade, o andamento e o
// recorde local — informação que antes só existia depois de jogar.
// =================================================================
var _cx = display_get_gui_width() / 2;
var _gap_coluna = 360;

var _y_icone   = 566;
var _y_nome    = 622;
var _y_detalhe = 648;
var _y_recorde = 672;

var _tinta = make_colour_rgb(40, 28, 18);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// --- título ---
draw_set_font(f_padrao_pequena);
draw_set_color(_tinta);
draw_text(_cx, 510, "Selecione a arma para forjar");

// --- cartões ---
var _inicio_x = _cx - (((min(3, total_opcoes) - 1) * _gap_coluna) / 2);

for (var i = 0; i < total_opcoes; i++) {

    var _pos_x = _inicio_x + (i * _gap_coluna);
    var _fase = opcoes_fase[i];
    var _selecionada = (i == opcao_selecionada);

    if (_selecionada) {
        ui_caixa_pulsante(_pos_x, (_y_icone + _y_recorde) / 2, 300, 180);
    }

    // arma dentro da moldura, do mesmo jeito que aparece na tela de resultado
    var _arma = _fase.sprites_resultado[array_length(_fase.sprites_resultado) - 1];
    draw_sprite_ext(_arma, 0, _pos_x, _y_icone, 0.26, 0.26, 0, c_white, 1);
    draw_sprite_ext(s_canva01, 0, _pos_x, _y_icone, 0.34, 0.34, 0, c_white, 1);

    // nome
    draw_set_font(f_padrao);
    draw_set_color(_selecionada ? c_yellow : _tinta);
    draw_text(_pos_x, _y_nome, _fase.nome);

    // dificuldade e andamento
    draw_set_font(f_padrao_pequena);
    draw_set_color(_tinta);
    draw_text(_pos_x, _y_detalhe, _fase.dificuldade + "  -  " + string(_fase.beat_tempo_bpm) + " BPM");

    // recorde local
    var _recorde = save_recorde(i);
    draw_text(_pos_x, _y_recorde, (_recorde > 0) ? ("Recorde: " + string(_recorde)) : "Ainda não forjada");

    // cursor da opção escolhida
    if (_selecionada) {
        draw_sprite(s_menu_seletor, 0, _pos_x - 150, _y_nome);
    }
}

ui_reset();
