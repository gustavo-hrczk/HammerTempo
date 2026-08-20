if (room != rm_opcoes) {
    exit;
}

// =================================================================
// 1. LOGO
// =================================================================
var _cx = display_get_gui_width() / 2;
var _logo_pos_y = (display_get_gui_height() / 2) - 300;
draw_sprite_ext(s_logo_jogo, 0, _cx, _logo_pos_y, 1.2, 1.2, 0, c_white, 1);

// =================================================================
// 2. PAINEL
// =================================================================
var _option_gap = 45;
var _cy = (display_get_gui_height() / 2) + 140;

var _box_largura = 300;
var _box_altura = 195;
var _box_x = _cx - (_box_largura / 2);
var _box_y = _cy - (_box_altura / 2);

draw_set_font(f_padrao);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_sprite_stretched(s_option_menu, 0, _box_x, _box_y, _box_largura, _box_altura);

// =================================================================
// 3. OPÇÕES
// =================================================================
var _total_opcoes = array_length(opcoes_menu);
var _texto_start_y = _cy - ((_total_opcoes - 1) * _option_gap) / 2;

for (var i = 0; i < _total_opcoes; i++) {
    var _pos_y = _texto_start_y + (i * _option_gap);
    var _cor = c_black;
    var _texto = opcoes_menu[i];

    switch (i) {
        case 0: _texto += ":  " + string(floor(opcoes_volume)); break;
        case 1: _texto += ":  " + string(JANELA_TAMANHOS[opcoes_janela][0]) + "x" + string(JANELA_TAMANHOS[opcoes_janela][1]); break;
        case 2: _texto += opcoes_tela_cheia ? ":  Sim" : ":  Não"; break;
    }

    if (i == opcao_selecionada) {
        _cor = c_yellow;
        ui_caixa_pulsante(_cx, _pos_y, 295, 40);
    }

    draw_text_color(_cx, _pos_y, _texto, _cor, _cor, _cor, _cor, 1);
}

// =================================================================
// 4. AJUDA
// =================================================================
draw_set_font(f_padrao_pequena);
draw_set_color(c_black);
draw_text(_cx, _box_y + _box_altura + 40, "ESQUERDA e DIREITA ajustam  -  APLICAR salva  -  VOLTAR descarta");

ui_reset();
