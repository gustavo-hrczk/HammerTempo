
// =================================================================
// 1. DESENHO DO PAINEL DO MENU E OPÇÕES
// =================================================================
// (Todo o resto do seu código de desenho do painel e das opções vem aqui)
// Vou colar o código da nossa última versão funcional para garantir.

var _menu_vertical_offset = 100;
var _cx = display_get_gui_width() / 2;
var _cy = (display_get_gui_height() / 2) + _menu_vertical_offset;

draw_set_font(f_padrao);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var _option_gap = 45;
var _padding_horizontal = 80;
var _padding_vertical = 40;

var _max_texto_largura = 0;
for (var i = 0; i < array_length(opcoes_menu); i++) {
    _max_texto_largura = max(_max_texto_largura, string_width(opcoes_menu[i]));
}

var _total_opcoes = array_length(opcoes_menu);
var _box_largura = _max_texto_largura + _padding_horizontal;
var _box_altura = (_total_opcoes * _option_gap) + _padding_vertical;
var _box_x = _cx - (_box_largura / 2);
var _box_y = _cy - (_box_altura / 2);

draw_sprite_stretched(s_menu_background_panel, 0, _box_x, _box_y, _box_largura, _box_altura);

var _texto_start_y = _cy - ((_total_opcoes - 1) * _option_gap) / 2;

for (var i = 0; i < _total_opcoes; i++) {
    var _pos_y = _texto_start_y + (i * _option_gap);
    var _cor = c_white;
    if (i == opcao_selecionada) {
        _cor = c_yellow;
        var _highlight_width_fixed = 180;
        var _highlight_height_fixed = 30;
        var _rect_x1 = _cx - (_highlight_width_fixed / 2);
        var _rect_y1 = _pos_y - (_highlight_height_fixed / 2);
        var _rect_x2 = _cx + (_highlight_width_fixed / 2);
        var _rect_y2 = _pos_y + (_highlight_height_fixed / 2);
        draw_set_color(c_black);
        draw_set_alpha(0.3);
        draw_rectangle(_rect_x1, _rect_y1, _rect_x2, _rect_y2, false);
        draw_set_alpha(1);
        var _texto_largura = string_width(opcoes_menu[i]);
        var _seletor_padding = 25;
        var _seletor_x = _cx - (_texto_largura / 2) - _seletor_padding;
        draw_sprite(s_menu_seletor, 0, _seletor_x, _pos_y);
    }
    draw_text_color(_cx, _pos_y, opcoes_menu[i], _cor, _cor, _cor, _cor, 1);
}

draw_set_halign(fa_left);