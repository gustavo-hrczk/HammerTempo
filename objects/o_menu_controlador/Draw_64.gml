
//=================================================================
// 1. DESENHO DA LOGO
// =================================================================
var _logo_pos_x = display_get_gui_width() / 2;
var _logo_pos_y = (display_get_gui_height() / 2) - 320;
var _logo_escala = 1.2;
draw_sprite_ext(s_logo_jogo, 0, _logo_pos_x, _logo_pos_y, _logo_escala, _logo_escala, 0, c_white, 1);

// =================================================================
// 2. SETUP E CÁLCULO DE DIMENSÕES PARA O MENU
// =================================================================
var _menu_vertical_offset = 140;
var _option_gap = 45;
var _padding_horizontal = 80;
var _padding_vertical = 40;

var _cx = display_get_gui_width() / 2;
var _cy = (display_get_gui_height() / 2) + _menu_vertical_offset;

draw_set_font(f_padrao);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var _max_texto_largura = 0;
for (var i = 0; i < array_length(opcoes_menu); i++) {
    _max_texto_largura = max(_max_texto_largura, string_width(opcoes_menu[i]));
}

var _total_opcoes = array_length(opcoes_menu);
var _box_largura = _max_texto_largura + _padding_horizontal;
var _box_altura = (_total_opcoes * _option_gap) + _padding_vertical;
var _box_x = _cx - (_box_largura / 2);
var _box_y = _cy - (_box_altura / 2);

// =================================================================
// 3. DESENHO DO PAINEL DE FUNDO
// =================================================================
draw_sprite_stretched(s_menu_background_panel, 0, _box_x, _box_y, 248, 215);

// =================================================================
// 4. DESENHO DAS OPÇÕES DO MENU
// =================================================================
var _texto_start_y = _cy - ((_total_opcoes - 1) * _option_gap) / 2;

for (var i = 0; i < array_length(opcoes_menu); i++) {
    var _pos_y = _texto_start_y + (i * _option_gap);
    var _cor = c_black;
    
    if (i == opcao_selecionada) {
        _cor = c_yellow;
        
        ui_caixa_pulsante(_cx, _pos_y, _max_texto_largura + 75, 40);

        var _texto_largura_atual = string_width(opcoes_menu[i]);
        var _seletor_padding = 25;
        var _seletor_x = _cx - (_texto_largura_atual / 2) - _seletor_padding;
        draw_sprite(s_menu_seletor, 0, _seletor_x, _pos_y);
    }
    
    draw_text_color(_cx, _pos_y, opcoes_menu[i], _cor, _cor, _cor, _cor, 1);
}

ui_reset();