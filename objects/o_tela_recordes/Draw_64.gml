var _cx = display_get_gui_width() / 2;

var _topo = ui_painel_livre(PAINEL_LARGURA, PAINEL_ALTURA);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// --- TÍTULO ---
draw_set_font(f_padrao);
draw_set_color(c_black);
draw_text(_cx, _topo + 40, "RECORDES");

// --- PÁGINA EXIBIDA ---
// As setas laterais só aparecem quando há para onde ir.
var _arcade = (pagina == 0);
var _nome_pagina = _arcade
    ? "MODO ARCADE"
    : o_controlador_geral.fases_data[pagina - 1].nome;

var _rotulo = (total_paginas > 1) ? ("<  " + _nome_pagina + "  >") : _nome_pagina;

draw_set_color(UI_COR_DESTAQUE);
draw_text(_cx, _topo + 82, _rotulo);

// =================================================================
// TABELA
//
// O TOP 3 vem em f_padrao e o resto em f_padrao_pequena. O destaque tinha de sair de
// FONTE e não de escala: Kobold 7 é fonte de pixel, e 1,5x destruiria o traço (D-33).
// Como só existem dois corpos no projeto, o degrau entre eles É o destaque possível —
// e ele calha de cair exatamente no pódio.
//
// A última coluna muda com a frente e mede coisas diferentes em cada uma:
//   Livre  — NOTA, de F a S. Porcentagem é um número que o jogador precisa
//            interpretar; a letra ele compara de relance com a do vizinho na fila.
//   Arcade — ARMAS, quantas ele chegou a forjar. Num percurso, o quanto se andou é o
//            que desempata totais parecidos.
// =================================================================
var _col_pos    = _cx - 150;   // fim da posição, à direita
var _col_nome   = _cx - 138;   // início do nome, em slots fixos
var _col_pontos = _cx +  74;   // fim da pontuação, à direita
var _col_nota   = _cx + 150;   // fim da nota, à direita

var _y_cabecalho = _topo + 124;
var _y_primeira  = _topo + 164;

// vãos por corpo de fonte: o pódio respira mais porque a letra é maior
var _gap_topo = 40;
var _gap_resto = 31;

// --- CABEÇALHO ---
draw_set_font(f_padrao_pequena);
draw_set_color(c_black);

draw_set_alpha(0.55);
draw_set_halign(fa_left);
draw_text(_col_nome, _y_cabecalho, "Nome");
draw_set_halign(fa_right);
draw_text(_col_pontos, _y_cabecalho, "Pontos");
draw_text(_col_nota, _y_cabecalho, _arcade ? "Armas" : "Nota");
draw_set_alpha(1);

draw_set_alpha(0.25);
draw_line(_col_pos - 26, _y_cabecalho + 20, _col_nota, _y_cabecalho + 20);
draw_set_alpha(1);

var _lista = _arcade ? placar_arcade() : placar_livre(pagina - 1);

if (array_length(_lista) == 0) {
    draw_set_halign(fa_center);
    draw_set_font(f_padrao);
    draw_set_color(UI_COR_APAGADA);
    draw_text(_cx, _y_primeira + 110, "Nenhum recorde ainda");

} else {
    var _y = _y_primeira;

    for (var i = 0; i < array_length(_lista); i++) {

        var _e = _lista[i];
        var _podio = (i < 3);

        draw_set_font(_podio ? f_padrao : f_padrao_pequena);

        // O primeiro em cobre, o resto do pódio em cobre claro, os demais na tinta
        // comum: a tabela inteira colorida não destacaria ninguém.
        var _tinta = (i == 0) ? UI_COR_COBRE
                   : (_podio ? UI_COR_COBRE_CLARO : c_black);
        draw_set_color(_tinta);

        draw_set_halign(fa_right);
        draw_text(_col_pos, _y, string(i + 1) + ".");

        // espaçamento fixo por letra, senão as três colunas do nome dançam de uma
        // linha para outra (ver placar_desenhar_nome)
        placar_desenhar_nome(_col_nome, _y, _e.nome, _podio ? 23 : 18);

        draw_set_halign(fa_right);
        draw_text(_col_pontos, _y, string(_e.pontos));

        if (_arcade) {
            // Um asterisco marca quem fechou o percurso inteiro. Entre dois totais
            // parecidos, quem completou fez a corrida mais longa.
            var _armas = variable_struct_exists(_e, "armas") ? _e.armas : 0;
            var _fim = (variable_struct_exists(_e, "completou") && _e.completou) ? "*" : "";
            draw_text(_col_nota, _y, string(_armas) + _fim);

        } else {
            // O SELO, e nao uma letra colorida. Medido sobre o pergaminho, o ouro do S
            // dava 1,09:1 de contraste e o cobre do A dava 2,70:1 — os dois muito abaixo
            // do minimo de 4,5:1. Escurecer as cores mataria a leitura, que vem do
            // calor, e contorno vira ruido em dez linhas seguidas.
            //
            // O selo traz a propria chapa escura atras da letra, entao le pelo desenho e
            // nao pela cor. E e a MESMA marca que as telas de resultado estampam na
            // peca: o jogador ve a nota la e a procura aqui.
            var _tier = variable_struct_exists(_e, "tier")
                ? _e.tier
                : (variable_struct_exists(_e, "nivel")
                    ? _e.nivel
                    : icone_nivel_por_precisao(_e.precisao));

            icone_tier_desenhar(_tier, _col_nota - 6, _y, 3);
        }

        _y += _podio ? _gap_topo : _gap_resto;
    }
}

// --- AJUDA ---
draw_set_font(f_padrao_pequena);
draw_set_halign(fa_center);
draw_set_color(c_black);
draw_text(_cx, _topo + PAINEL_ALTURA + 30,
          (total_paginas > 1) ? "LADOS trocam de tabela  -  ESC fecha" : "ESC fecha");

ui_reset();
