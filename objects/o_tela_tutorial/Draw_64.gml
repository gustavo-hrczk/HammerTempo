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
// =================================================================
var _titulo_y = _box_y + 60;

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
// 4. AS TECLAS, DESENHADAS
// Numa feira ninguém lê instrução: os próprios alvos do jogo servem de ícone, e o
// jogador reconhece na tela o que acabou de ver aqui.
// =================================================================
var _icones_y = _titulo_y + 78;
var _icone_gap = 84;
var _icones = [s_alvo_cima, s_alvo_esquerda, s_alvo_direita, s_alvo_baixo];
var _letras = ["W", "A", "D", "S"];

var _icones_x = _cx - (((array_length(_icones) - 1) * _icone_gap) / 2);

for (var i = 0; i < array_length(_icones); i++) {
    var _ix = _icones_x + (i * _icone_gap);

    // a sprite do alvo tem origem no canto, então centraliza na mão
    draw_sprite_ext(_icones[i], 0, _ix - 22, _icones_y - 21, 1, 1, 0, c_white, 1);

    draw_set_font(f_padrao_pequena);
    draw_set_color(c_black);
    draw_text(_ix, _icones_y + 40, _letras[i]);
}

// =================================================================
// 5. INSTRUÇÕES
// =================================================================
var _padding = 60;
var _texto_x = _box_x + _padding;
var _texto_y = _icones_y + 88;
var _texto_largura_max = _box_largura - (_padding * 2);

var _texto_instrucoes =
    "Acerte as notas no ritmo da forja: quanto mais preciso o golpe, melhor a arma.\n\n" +
    "Acertos seguidos formam combo e valem mais pontos. Errar muitas notas em\n" +
    "sequência arruína o trabalho.";

draw_set_font(f_padrao);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_black);
draw_text_ext(_texto_x, _texto_y, _texto_instrucoes, 35, _texto_largura_max);

// =================================================================
// 6. PROMPT PARA COMEÇAR
// =================================================================
ui_prompt(_cx, _box_y + _box_altura - 60, ui_texto_confirmar() + " para começar");

ui_reset();
