if (room != rm_opcoes) {
    exit;
}

// =================================================================
// 1. LOGO
// =================================================================
var _cx = display_get_gui_width() / 2;
draw_sprite_ext(s_logo_jogo, 0, _cx, (display_get_gui_height() / 2) - 300, 1.2, 1.2, 0, c_white, 1);

// =================================================================
// 2. PAINEL
// =================================================================
var _option_gap = 44;
var _total_opcoes = array_length(opcoes_menu);
var _cy = (display_get_gui_height() / 2) + 150;

var _box_largura = 380;
var _box_altura = (_total_opcoes * _option_gap) + 44;
var _box_x = _cx - (_box_largura / 2);
var _box_y = _cy - (_box_altura / 2);

draw_sprite_stretched(s_option_menu, 0, _box_x, _box_y, _box_largura, _box_altura);

var _tinta = make_colour_rgb(40, 28, 18);
var _destaque = make_colour_rgb(178, 58, 22);

// =================================================================
// 3. OPÇÕES
// =================================================================
var _texto_start_y = _cy - ((_total_opcoes - 1) * _option_gap) / 2;

for (var i = 0; i < _total_opcoes; i++) {
    var _pos_y = _texto_start_y + (i * _option_gap);
    var _selecionado = (i == opcao_selecionada);

    if (_selecionado) {
        ui_caixa_pulsante(_cx, _pos_y, _box_largura - 44, 36);
    }

    var _cor = _selecionado ? _destaque : _tinta;
    var _valor = "";

    switch (i) {
        case 0: _valor = string(opcoes_musica); break;
        case 1: _valor = string(opcoes_sfx); break;
        case 2: _valor = string(JANELA_TAMANHOS[opcoes_janela][0]) + "x" + string(JANELA_TAMANHOS[opcoes_janela][1]); break;
        case 3: _valor = opcoes_tela_cheia ? "Sim" : "Não"; break;
    }

    draw_set_font(f_padrao);
    draw_set_valign(fa_middle);

    if (_valor == "") {
        // "Aplicar!" não tem valor: fica centralizado
        draw_set_halign(fa_center);
        draw_set_color(_cor);
        draw_text(_cx, _pos_y, opcoes_menu[i]);
    } else {
        draw_set_halign(fa_left);
        draw_set_color(_cor);
        draw_text(_box_x + 34, _pos_y, opcoes_menu[i]);

        draw_set_halign(fa_right);
        draw_text(_box_x + _box_largura - 34, _pos_y, _valor);
    }
}

// =================================================================
// 4. AJUDA
// =================================================================
draw_set_font(f_padrao_pequena);
draw_set_halign(fa_center);
draw_set_color(c_black);
draw_text(_cx, _box_y + _box_altura + 34, "ESQUERDA e DIREITA ajustam  -  APLICAR salva  -  VOLTAR descarta");

ui_reset();
