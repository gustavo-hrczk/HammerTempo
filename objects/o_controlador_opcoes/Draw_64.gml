if(room != rm_opcoes){
	exit;
}

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
    _max_texto_largura = 200;
}

var _total_opcoes = array_length(opcoes_menu);
var _box_largura = 300;
var _box_altura = 150;
var _box_x = _cx - (_box_largura / 2);
var _box_y = _cy - (_box_altura / 2);

// =================================================================
// 3. DESENHO DO PAINEL DE FUNDO
// =================================================================
draw_sprite_stretched(s_option_menu, 0, _box_x, _box_y, _box_largura, _box_altura);

// =================================================================
// 4. DESENHO DAS OPÇÕES DO MENU
// =================================================================
var _texto_start_y = _cy - ((_total_opcoes - 1) * _option_gap) / 2;

for (var i = 0; i < array_length(opcoes_menu); i++) {
    var _pos_y = _texto_start_y + (i * _option_gap);
    var _cor = c_black;
    
	var texto = "";
    switch (i){
		case 0:
			texto = string_concat(opcoes_menu[i], ":      ", floor(opcoes_volume*100),"%");
			break;
		case 1:
			if(opcoes_tela_cheia){
				texto = opcoes_menu[i] + ":      Sim";
			} else {
				texto = opcoes_menu[i] + ":      Não";
			}
			break;
		case 2:
			texto = opcoes_menu[i];
			break;
	}
	
    if (i == opcao_selecionada) {
        _cor = c_yellow;
        
        var _highlight_width = _max_texto_largura + 63;
        var _highlight_height = 40;
        
        var _rect_x1 = _cx - (_highlight_width / 2);
        var _rect_y1 = _pos_y - (_highlight_height / 2);
        var _rect_x2 = _cx + (_highlight_width / 2);
        var _rect_y2 = _pos_y + (_highlight_height / 2);
        
        var _min_alpha = 0.15;
        var _max_alpha = 0.5;
        var _pulse_speed = 0.004;
        var _normalized_sine = (sin(current_time * _pulse_speed) + 1) / 2;
        var _current_pulse_alpha = _min_alpha + (_max_alpha - _min_alpha) * _normalized_sine;
        
        draw_set_color(c_black);
        draw_set_alpha(_current_pulse_alpha);
        draw_rectangle(_rect_x1, _rect_y1, _rect_x2, _rect_y2, false);
        draw_set_alpha(1);
        
        var _texto_largura_atual = string_width(texto);
    }
    draw_text_color(_cx, _pos_y, texto, _cor, _cor, _cor, _cor, 1);
}

draw_set_halign(fa_left); // Reseta o alinhamento