// =================================================================
// 1. FUNDO SEMI-TRANSPARENTE (PARA FOCO)
// =================================================================
draw_set_color(c_black);
draw_set_alpha(0.7);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// =================================================================
// 2. PAINEL
// =================================================================
var _box_largura = 955;
var _box_altura = 550;
var _margin_bottom = 60;

var _cx = display_get_gui_width() / 2;
var _box_y = display_get_gui_height() - _box_altura - _margin_bottom;
var _box_x = _cx - (_box_largura / 2);

draw_sprite_stretched(s_tutorial, 0, _box_x, _box_y, _box_largura, _box_altura);

// =================================================================
// 3. TÍTULO
// Antes o texto era posicionado em Y absoluto e só coincidia com o painel por acaso;
// agora tudo é relativo ao painel (auditoria UI-07).
// =================================================================
var _titulo_y = _box_y + 70;

draw_set_font(f_padrao);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_color(c_black);
draw_set_alpha(0.25);
draw_rectangle(_box_x + 40, _titulo_y - 25, _box_x + _box_largura - 40, _titulo_y + 25, false);
draw_set_alpha(1);

draw_set_color(c_yellow);
draw_text(_cx, _titulo_y, "COMO FORJAR");

// =================================================================
// 4. INSTRUÇÕES
// =================================================================
var _padding = 60;
var _texto_x = _box_x + _padding;
var _texto_y = _titulo_y + 60;
var _texto_largura_max = _box_largura - (_padding * 2);

var _comandos = (global.input_dispositivo == "gamepad")
    ? "Use o DIRECIONAL do controle"
    : "Use as  <SETAS>  ou  <W A S D>  do teclado";

var _texto_instrucoes = _comandos + " para acertar as notas no ritmo da forja.\n\n" +
    "Seu objetivo é forjar a melhor arma possível acertando as notas com precisão para aumentar sua pontuação.\n\n" +
    "Cuidado! Errar muitas notas seguidas pode arruinar seu trabalho.";

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_black);
draw_text_ext(_texto_x, _texto_y, _texto_instrucoes, 35, _texto_largura_max);

// =================================================================
// 5. PROMPT PARA COMEÇAR
// =================================================================
ui_prompt(_cx, _box_y + _box_altura - 60, ui_texto_confirmar() + " para começar");

ui_reset();
