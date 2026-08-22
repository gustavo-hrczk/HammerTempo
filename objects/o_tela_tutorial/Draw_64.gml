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
// 4. AS TECLAS — EMPILHADAS, COMO NA PARTIDA
// Numa feira ninguém lê instrução: os próprios alvos do jogo servem de ícone. Eles
// ficam na vertical e com o mesmo espaçamento de 50 px das faixas em rm_forja, para
// o jogador reconhecer na tela exatamente o que acabou de ver aqui — antes estavam
// lado a lado, ensinando uma leitura que o jogo não usa.
//
// E aqui as teclas funcionam: o alvo responde ao toque igual à partida (ver o Step).
// =================================================================
var _coluna_x   = _box_x + 150;
var _lane_gap   = 50;                       // idêntico ao espaçamento de rm_forja
var _lane_topo  = _box_y + 170;

draw_set_font(f_padrao_pequena);
draw_set_color(c_black);
draw_text(_coluna_x, _box_y + 130, "TESTE AS TECLAS");

for (var i = 0; i < array_length(lane_sprite); i++) {

    var _ly = _lane_topo + (i * _lane_gap);
    var _spr = lane_sprite[i];

    // mesma resposta visual de o_buttons_forja: cresce um pouco e afunda no toque
    var _escala = 1 + (lane_pop[i] * 0.11);
    var _w = sprite_get_width(_spr);
    var _h = sprite_get_height(_spr);

    // a sprite do alvo tem origem no canto, então centraliza na mão
    var _dx = _coluna_x - (_w / 2) + (_w * (1 - _escala)) / 2;
    var _dy = _ly - (_h / 2) + lane_afunda[i] + (_h * (1 - _escala)) / 2;

    draw_sprite_ext(_spr, lane_frame[i], _dx, _dy, _escala, _escala, 0, c_white, 1);

    draw_set_font(f_padrao_pequena);
    draw_set_halign(fa_left);
    draw_set_color(c_black);
    draw_text(_coluna_x + 34, _ly + lane_afunda[i], lane_letra[i]);
    draw_set_halign(fa_center);
}

// =================================================================
// 5. INSTRUÇÕES
// Coluna à direita das teclas, já que elas passaram a ocupar altura em vez de
// largura. O texto fala do que o jogador faz e do que ganha com isso.
// =================================================================
var _texto_x = _box_x + 300;
var _texto_largura_max = (_box_x + _box_largura - 60) - _texto_x;

var _texto_instrucoes =
    "Cada nota corre até a zona de acerto. Martele no instante em que ela chega: " +
    "quanto mais perto do tempo certo, mais pontos ela vale.\n\n" +
    "Acertos consecutivos formam combo e valem cada vez mais. Errar muitas notas " +
    "em sequência esfria a forja e o trabalho se perde.";

draw_set_font(f_padrao);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_black);
draw_text_ext(_texto_x, _box_y + 130, _texto_instrucoes, 35, _texto_largura_max);

// =================================================================
// 6. PROMPT PARA COMEÇAR
// =================================================================
draw_set_valign(fa_middle);
ui_prompt(_cx, _box_y + _box_altura - 60, ui_texto_confirmar() + " para começar");

ui_reset();
