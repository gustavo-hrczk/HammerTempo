var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _cx = _gw / 2;

// Escurece a cena atrás, como o menu de pausa: a disputa acabou e o que importa agora
// é a comparação.
draw_set_alpha(0.72);
draw_set_color(c_black);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// =================================================================
// UM PAINEL DE PERGAMINHO POR JOGADOR
//
// A primeira versão desenhava barras coloridas soltas sobre a tela, e ficava fora da
// língua visual do jogo — todas as outras telas falam pelo mesmo pergaminho. Aqui cada
// jogador ganha o painel dele, e a comparação acontece DENTRO da moldura, na barra.
// =================================================================
var _pw = 620;
var _ph = 150;
var _px = _cx - (_pw / 2);

var _teto = max(1, max(pontos[0], pontos[1]));

var _prog = 0;
if (tempo >= VERSUS_T_BARRAS) {
    _prog = min(1, (tempo - VERSUS_T_BARRAS) / VERSUS_DUR_BARRAS);
    _prog = _prog * _prog * (3 - 2 * _prog);   // smoothstep, como o contador do Livre
}

var _tinta = make_colour_rgb(40, 28, 18);

for (var i = 0; i < 2; i++) {
    var _py = 168 + (i * (_ph + 24));

    draw_sprite_stretched(s_menu_background_panel, 0, _px, _py, _pw, _ph);

    var _esq = _px + 26;
    var _dir = _px + _pw - 26;

    // --- nome e total ---
    draw_set_font(f_padrao);
    draw_set_halign(fa_left);
    draw_set_color(versus_cor(i));
    draw_text(_esq, _py + 30, versus_nome(i));

    draw_set_halign(fa_right);
    draw_text(_dir, _py + 30, string(round(pontos[i] * _prog)));

    // --- barra comparativa ---
    // A escala é o MAIOR dos dois totais: o vencedor sempre enche a barra dele, e a do
    // outro conta a distância. Barra responde "quem fez mais" antes de qualquer leitura.
    var _bx = _esq;
    var _bw = _dir - _esq;
    var _by = _py + 62;
    var _bh = 26;

    draw_set_alpha(0.18);
    draw_set_color(_tinta);
    draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);
    draw_set_alpha(1);

    draw_set_color(versus_cor(i));
    draw_rectangle(_bx, _by, _bx + max(2, _bw * (pontos[i] / _teto) * _prog),
                   _by + _bh, false);

    // --- detalhe ---
    // Acertos, erros e nota entram depois das barras: primeiro quem ganhou, depois
    // por quê.
    if (tempo >= VERSUS_T_DETALHE) {
        draw_set_font(f_padrao_pequena);
        draw_set_halign(fa_left);
        draw_set_color(_tinta);
        draw_text(_esq, _by + _bh + 26,
                  "Acertos " + string(acertos[i]) + "     Erros " + string(erros[i]));

        draw_set_halign(fa_right);
        draw_set_color(icone_rank_cor(notas[i]));
        draw_text(_dir, _by + _bh + 26, "Nota " + notas[i]);
    }
}

// =================================================================
// TITULO E VENCEDOR
// =================================================================
draw_set_halign(fa_center);

ui_texto_flutuante(_cx, 96, "FIM DA DISPUTA", 1, f_padrao, c_white);

if (tempo >= VERSUS_T_VENCEDOR) {
    var _texto = (vencedor == -1)
        ? "EMPATE"
        : (versus_nome(vencedor) + " VENCEU!");

    ui_texto_flutuante(_cx, 540, _texto, 1, f_padrao,
                       (vencedor == -1) ? c_white : versus_cor(vencedor));
}

if (revelacao_pronta) {
    ui_prompt(_cx, 640, ui_texto_confirmar() + " para continuar", 65);
}

ui_reset();
