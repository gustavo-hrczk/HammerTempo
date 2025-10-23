// Garante que o fundo seja sempre preto
draw_clear_alpha(c_black, 1);

// --- Posições e Ajustes (seu código original, que está perfeito) ---
var _cx = display_get_gui_width() / 2;
var _cy = display_get_gui_height() / 2;
var _logo_width = 290;
var _logo_height = 290;
var _gap_horizontal_entre_logos = 100;
var _gap_vertical_entre_blocos = 10;
var _cy_top_row = _cy - (_logo_height / 2) - (_gap_vertical_entre_blocos / 2);
var _cx_instituicao = _cx - (_logo_width / 2) - (_gap_horizontal_entre_logos / 2);
var _cx_gamejam = _cx + (_logo_width / 2) + (_gap_horizontal_entre_logos / 2);
var _cy_dev_logo = _cy + (_logo_height / 2) + (_gap_vertical_entre_blocos / 2);

// --- Desenha as logos com alpha = 1 (totalmente opaco) ---
// O o_transicao cuidará do fade por cima delas.
draw_sprite_ext(logo_catolica, 0, _cx_instituicao, _cy_top_row, 1, 1, 0, c_white, 1);
draw_sprite_ext(logo_gamejam, 0, _cx_gamejam, _cy_top_row, 1, 1, 0, c_white, 1);
draw_sprite_ext(logo_panela, 0, _cx, _cy_dev_logo, 1, 1, 0, c_white, 1);