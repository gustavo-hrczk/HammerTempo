var _cx = display_get_gui_width() / 2;
var _cy = display_get_gui_height() / 2;

// escurece a tela de resultado atrás, como o tutorial faz
draw_set_color(c_black);
draw_set_alpha(0.65);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

var _altura = ui_painel_menu(5, PAINEL_LARGURA, 0);
var _topo = _cy - (_altura / 2);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// --- TÍTULO ---
draw_set_font(f_padrao);
draw_set_color(c_black);
draw_text(_cx, _topo + 42, (posicao_prevista > 0)
    ? (string(posicao_prevista) + "o LUGAR!")
    : "SUAS INICIAIS");

// --- AS TRÊS LETRAS ---
// Escala INTEIRA e posição inteira: Kobold 7 é fonte de pixel, e escala fracionária
// suja o traço (D-33). Em escala 3 os 30 px viram 90.
var _escala = 3;
var _vao = 78;
var _letra_y = _cy + 4;
var _esq = _cx - (((PLACAR_NOME_TAMANHO - 1) * _vao) / 2);

for (var i = 0; i < PLACAR_NOME_TAMANHO; i++) {

    var _lx = floor(_esq + (i * _vao));
    var _ativa = (i == cursor);

    if (_ativa) {
        // o traço embaixo marca onde o direcional age
        draw_set_color(make_colour_rgb(150, 66, 24));
        draw_rectangle(_lx - 26, _letra_y + 50, _lx + 26, _letra_y + 55, false);
    }

    draw_set_color(_ativa ? make_colour_rgb(150, 66, 24) : c_black);
    draw_text_transformed(_lx, floor(_letra_y), placar_letra(letras[i]),
                          _escala, _escala, 0);
}

// --- AJUDA ---
draw_set_font(f_padrao_pequena);
draw_set_color(c_black);
draw_text(_cx, _topo + _altura - 34, "CIMA e BAIXO trocam  -  LADOS movem");

// A contagem só aparece quando falta pouco: mostrá-la desde o início apressaria o
// jogador sem necessidade.
var _seg = ceil(espera / room_speed);
if (_seg <= 10) {
    draw_text(_cx, _topo + _altura + 30, "Gravando em " + string(_seg) + "...");
}

ui_reset();
