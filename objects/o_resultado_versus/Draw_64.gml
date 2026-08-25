var _gw = display_get_gui_width();
var _cx = _gw / 2;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// --- TÍTULO ---
draw_set_font(f_padrao);
ui_texto_flutuante(_cx, 96, "FIM DA DISPUTA", 1, f_padrao, c_white);

// =================================================================
// BARRAS COMPARATIVAS
//
// Crescem lado a lado até a proporção real entre os dois totais. Barra é melhor que
// número aqui porque a pergunta desta tela não é "quanto fiz", é "quem fez mais" — e
// a resposta a essa aparece no comprimento antes de qualquer leitura.
//
// A escala é o MAIOR dos dois, não um teto fixo: assim o vencedor sempre enche a
// barra dele, e a do outro conta a distância.
// =================================================================
var _prog = 0;
if (tempo >= VERSUS_T_BARRAS) {
    _prog = min(1, (tempo - VERSUS_T_BARRAS) / VERSUS_DUR_BARRAS);
    _prog = _prog * _prog * (3 - 2 * _prog);   // smoothstep, como o contador do Livre
}

var _teto = max(1, max(pontos[0], pontos[1]));

var _barra_x = 190;
var _barra_w = _gw - (_barra_x * 2);
var _barra_h = 46;

for (var i = 0; i < 2; i++) {
    var _y = 210 + (i * 92);
    var _cor = versus_cor(i);

    // trilho
    draw_set_alpha(0.22);
    draw_set_color(c_black);
    draw_rectangle(_barra_x, _y, _barra_x + _barra_w, _y + _barra_h, false);
    draw_set_alpha(1);

    var _w = _barra_w * (pontos[i] / _teto) * _prog;

    draw_set_color(_cor);
    draw_rectangle(_barra_x, _y, _barra_x + max(2, _w), _y + _barra_h, false);

    // nome à esquerda, pontuação acompanhando a ponta da barra
    draw_set_font(f_padrao_pequena);
    draw_set_halign(fa_left);
    draw_set_color(c_white);
    draw_text(_barra_x + 12, _y - 18, versus_nome(i));

    draw_set_font(f_padrao);
    draw_set_halign(fa_right);
    draw_text(_barra_x + _barra_w, _y - 18, string(round(pontos[i] * _prog)));

    // --- DETALHE ---
    // Nota, acertos e erros entram depois das barras: primeiro quem ganhou, depois
    // por quê.
    if (tempo >= VERSUS_T_DETALHE) {
        draw_set_font(f_padrao_pequena);
        draw_set_halign(fa_left);
        draw_set_color(c_white);
        draw_text(_barra_x + 12, _y + _barra_h + 18,
                  "Acertos " + string(acertos[i]) + "     Erros " + string(erros[i]));

        draw_set_halign(fa_right);
        draw_set_color(icone_rank_cor(notas[i]));
        draw_text(_barra_x + _barra_w, _y + _barra_h + 18, "Nota " + notas[i]);
    }
}

// =================================================================
// VENCEDOR
// =================================================================
if (tempo >= VERSUS_T_VENCEDOR) {
    var _texto = (vencedor == -1)
        ? "EMPATE"
        : (versus_nome(vencedor) + " VENCEU!");

    var _cor = (vencedor == -1) ? c_white : versus_cor(vencedor);

    draw_set_font(f_padrao);
    ui_texto_flutuante(_cx, 424, _texto, 1, f_padrao, _cor);
}

if (revelacao_pronta) {
    ui_prompt(_cx, 676, ui_texto_confirmar() + " para continuar", 65);
}

ui_reset();
