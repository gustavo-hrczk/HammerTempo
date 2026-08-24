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
// TABELA — grade de vãos iguais
//
// As colunas eram posicionadas a olho e "Pontos" terminava a 14 px de "Precisão".
// Agora a grade sai da MEDIDA de cada coluna, e a folga que sobra é dividida em
// partes iguais: 328 px úteis menos 232 de conteúdo dão 96 px, ou 32 px por vão.
//
// Cada coluna é medida pelo maior entre o cabeçalho e o dado. "Precisão" (86) é mais
// larga que "100%" (43), e "Pontos" (68) é mais larga que "999999" (60) — dimensionar
// pelo dado deixaria os cabeçalhos se tocando.
// =================================================================
var _col_pos      = _cx - 140;   // fim da posição       (24 px, à direita)
var _col_nome     = _cx - 108;   // início do nome       (54 px, à esquerda)
var _col_pontos   = _cx +  46;   // fim da pontuação     (68 px, à direita)
var _col_precisao = _cx + 164;   // fim da precisão      (86 px, à direita)

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

        // espaçamento fixo por letra, senão as três colunas do nome dançam de uma
        // linha para outra (ver placar_desenhar_nome)
        placar_desenhar_nome(_col_nome, _y, _e.nome);

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
