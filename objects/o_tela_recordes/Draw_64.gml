var _cx = display_get_gui_width() / 2;

var _topo = ui_painel_livre(PAINEL_LARGURA, PAINEL_ALTURA);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// --- TÍTULO ---
draw_set_font(f_padrao);
draw_set_color(c_black);
draw_text(_cx, _topo + 40, "RECORDES");

// --- FASE EXIBIDA ---
// As setas laterais só aparecem quando há para onde ir.
var _nome_fase = o_controlador_geral.fases_data[fase_exibida].nome;
var _rotulo = (total_fases > 1) ? ("<  " + _nome_fase + "  >") : _nome_fase;

draw_set_color(UI_COR_DESTAQUE);
draw_text(_cx, _topo + 82, _rotulo);

// =================================================================
// TABELA
// Colunas medidas: "10." cabe em 24 px, "999999" em 60, "100%" em 43. As posições
// abaixo deixam 80 px entre o nome e a pontuação, que é a folga que impede um nome
// de três letras de encostar num número de seis dígitos.
// =================================================================
var _col_pos      = _cx - 130;   // fim da posição (à direita)
var _col_nome     = _cx - 110;   // início do nome (à esquerda)
var _col_pontos   = _cx +  60;   // fim da pontuação (à direita)
var _col_precisao = _cx + 160;   // fim da precisão (à direita)

var _y_cabecalho = _topo + 120;
var _y_primeira  = _topo + 152;
var _linha_gap   = 32;

draw_set_font(f_padrao_pequena);
draw_set_color(c_black);

draw_set_alpha(0.55);
draw_set_halign(fa_left);
draw_text(_col_nome, _y_cabecalho, "Nome");
draw_set_halign(fa_right);
draw_text(_col_pontos, _y_cabecalho, "Pontos");
draw_text(_col_precisao, _y_cabecalho, "Precisão");
draw_set_alpha(1);

// linha separando o cabeçalho das entradas
draw_set_alpha(0.25);
draw_line(_col_pos - 24, _y_cabecalho + 18, _col_precisao, _y_cabecalho + 18);
draw_set_alpha(1);

var _lista = placar_livre(fase_exibida);

if (array_length(_lista) == 0) {
    draw_set_halign(fa_center);
    draw_set_color(make_colour_rgb(120, 105, 95));
    draw_text(_cx, _y_primeira + 100, "Nenhum recorde ainda");
} else {
    for (var i = 0; i < array_length(_lista); i++) {

        var _e = _lista[i];
        var _y = _y_primeira + (i * _linha_gap);

        // O primeiro lugar em cobre, o resto na tinta comum: a tabela inteira
        // colorida não destacaria ninguém.
        draw_set_color((i == 0) ? make_colour_rgb(150, 66, 24) : c_black);

        draw_set_halign(fa_right);
        draw_text(_col_pos, _y, string(i + 1) + ".");

        draw_set_halign(fa_left);
        draw_text(_col_nome, _y, _e.nome);

        draw_set_halign(fa_right);
        draw_text(_col_pontos, _y, string(_e.pontos));
        draw_text(_col_precisao, _y, string(_e.precisao) + "%");
    }
}

// --- AJUDA ---
draw_set_font(f_padrao_pequena);
draw_set_halign(fa_center);
draw_set_color(c_black);
draw_text(_cx, _topo + PAINEL_ALTURA + 30,
          (total_fases > 1) ? "LADOS trocam de fase  -  ESC fecha" : "ESC fecha");

ui_reset();
