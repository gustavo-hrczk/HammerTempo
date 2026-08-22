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
// 4. O TEXTO DAS INSTRUÇÕES
// Definido antes de ser desenhado porque a coluna das teclas se alinha por ele: a
// altura sai de string_height_ext, não de uma contagem de linhas na mão, então o
// alinhamento se corrige sozinho se o texto ou a fonte mudarem.
// =================================================================
var _texto_x = _box_x + 300;
var _texto_topo = _box_y + 130;
var _texto_largura_max = (_box_x + _box_largura - 60) - _texto_x;

var _texto_instrucoes =
    "Cada nota corre até a zona de acerto. Martele no instante em que ela chega: " +
    "quanto mais perto do tempo certo, mais pontos ela vale.\n\n" +
    "Acertos consecutivos formam combo e valem cada vez mais. Errar muitas notas " +
    "em sequência esfria a forja e o trabalho se perde.";

draw_set_font(f_padrao);
var _texto_altura = string_height_ext(_texto_instrucoes, 35, _texto_largura_max);

// =================================================================
// 5. AS TECLAS — EMPILHADAS, COMO NA PARTIDA
// Numa feira ninguém lê instrução: os próprios alvos do jogo servem de ícone. Eles
// ficam na vertical e com o mesmo espaçamento de 50 px das faixas em rm_forja, para
// o jogador reconhecer na tela exatamente o que acabou de ver aqui.
//
// E aqui as teclas funcionam: o alvo responde ao toque igual à partida (ver o Step).
// =================================================================
var _coluna_x = _box_x + 150;   // centro da coluna
var _lane_gap = 50;             // idêntico ao espaçamento de rm_forja

// --- largura: o rótulo sai do vínculo em vigor ("W" hoje, "BOTÃO 1" num gabinete),
// então o bloco ícone + rótulo é medido e centrado na coluna como uma peça só.
draw_set_font(f_padrao_pequena);

var _rotulos = [];
var _larg_rotulo = 0;

for (var i = 0; i < array_length(lane_acao); i++) {
    _rotulos[i] = input_nome_da_acao(lane_acao[i]);
    _larg_rotulo = max(_larg_rotulo, string_width(_rotulos[i]));
}

var _icone_w = sprite_get_width(lane_sprite[0]);
var _icone_h = sprite_get_height(lane_sprite[0]);
var _vao = 14;

var _bloco_esq = _coluna_x - ((_icone_w + _vao + _larg_rotulo) / 2);
var _icone_cx = _bloco_esq + (_icone_w / 2);
var _rotulo_x = _bloco_esq + _icone_w + _vao;

// --- altura: a coluna inteira (rótulo + pilha) fica centrada no texto da direita
var _rotulo_h = string_height("TESTE AS TECLAS");
var _vao_rotulo = 24;
var _bloco_alt = _rotulo_h + _vao_rotulo + ((array_length(lane_sprite) - 1) * _lane_gap) + _icone_h;

var _bloco_topo = _texto_topo + (_texto_altura / 2) - (_bloco_alt / 2);
var _rotulo_y = _bloco_topo + (_rotulo_h / 2);
var _lane_topo = _bloco_topo + _rotulo_h + _vao_rotulo + (_icone_h / 2);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_black);
draw_text(_coluna_x, _rotulo_y, "TESTE AS TECLAS");

for (var i = 0; i < array_length(lane_sprite); i++) {

    var _ly = _lane_topo + (i * _lane_gap);
    var _spr = lane_sprite[i];

    // mesma resposta visual de o_buttons_forja: cresce um pouco e afunda no toque
    var _escala = 1 + (lane_pop[i] * 0.11);
    var _w = sprite_get_width(_spr);
    var _h = sprite_get_height(_spr);

    // a sprite do alvo tem origem no canto, então centraliza na mão
    var _dx = _icone_cx - (_w / 2) + (_w * (1 - _escala)) / 2;
    var _dy = _ly - (_h / 2) + lane_afunda[i] + (_h * (1 - _escala)) / 2;

    draw_sprite_ext(_spr, lane_frame[i], _dx, _dy, _escala, _escala, 0, c_white, 1);

    draw_set_halign(fa_left);
    draw_set_color(c_black);
    draw_text(_rotulo_x, _ly + lane_afunda[i], _rotulos[i]);
    draw_set_halign(fa_center);
}

// =================================================================
// 6. INSTRUÇÕES
// =================================================================
draw_set_font(f_padrao);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_black);
draw_text_ext(_texto_x, _texto_topo, _texto_instrucoes, 35, _texto_largura_max);

// =================================================================
// 7. PROMPT PARA COMEÇAR
// =================================================================
draw_set_valign(fa_middle);
ui_prompt(_cx, _box_y + _box_altura - 60, ui_texto_confirmar() + " para começar");

ui_reset();
