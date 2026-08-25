var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _cx = _gw / 2;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// =================================================================
// O RESULTADO É PROJETADO NOS CORREDORES
//
// Cada jogador lê o próprio resultado na MESMA faixa onde jogou — é o que a tela de
// resultado do Modo Livre já faz, projetando os números sobre o pergaminho do
// corredor em vez de abrir uma janela nova.
//
// Isso resolve duas coisas de uma vez: a tela deixa de ter molduras flutuando sobre a
// cena, e cada metade da tela continua pertencendo ao mesmo jogador do começo ao fim
// da partida. Quem estava olhando para cima continua olhando para cima.
// =================================================================
var _teto = max(1, max(pontos[0], pontos[1]));

var _prog = 0;
if (tempo >= VERSUS_T_BARRAS) {
    _prog = min(1, (tempo - VERSUS_T_BARRAS) / VERSUS_DUR_BARRAS);
    _prog = _prog * _prog * (3 - 2 * _prog);   // smoothstep, como o contador do Livre
}

var _tinta = make_colour_rgb(40, 28, 18);

for (var i = 0; i < 2; i++) {
    // Miolo do corredor de cada jogador. O corredor tem 228 px; 40 de folga em cima
    // deixam o bloco centrado nele sem encostar nas bordas da faixa.
    var _topo = ritmo_corredor_topo(i);
    var _esq = 150;
    var _dir = _gw - 150;

    // --- nome e total ---
    draw_set_font(f_padrao);
    draw_set_halign(fa_left);
    draw_set_color(versus_cor(i));
    draw_text(_esq, _topo + 46, versus_nome(i));

    draw_set_halign(fa_right);
    draw_text(_dir, _topo + 46, string(round(pontos[i] * _prog)));

    // --- barra comparativa ---
    // A escala é o MAIOR dos dois totais: o vencedor sempre enche a barra dele, e a do
    // outro conta a distância. Barra responde "quem fez mais" antes de qualquer leitura.
    var _by = _topo + 88;
    var _bh = 30;
    var _bw = _dir - _esq;

    draw_set_alpha(0.20);
    draw_set_color(_tinta);
    draw_rectangle(_esq, _by, _esq + _bw, _by + _bh, false);
    draw_set_alpha(1);

    draw_set_color(versus_cor(i));
    draw_rectangle(_esq, _by, _esq + max(2, _bw * (pontos[i] / _teto) * _prog),
                   _by + _bh, false);

    // --- detalhe ---
    // Acertos, erros e nota entram depois das barras: primeiro quem ganhou, depois
    // por quê.
    if (tempo >= VERSUS_T_DETALHE) {
        draw_set_font(f_padrao_pequena);
        draw_set_halign(fa_left);
        draw_set_color(_tinta);
        draw_text(_esq, _by + _bh + 28,
                  "Acertos " + string(acertos[i]) + "     Erros " + string(erros[i]));

        draw_set_halign(fa_right);
        draw_set_color(icone_rank_cor(notas[i]));
        draw_text(_dir, _by + _bh + 28, "Nota " + notas[i]);
    }
}

// =================================================================
// TITULO E VENCEDOR — na faixa do meio, sobre a cena
// =================================================================
draw_set_halign(fa_center);

ui_texto_flutuante(_cx, 268, "FIM DA DISPUTA", 1, f_padrao, c_white);

if (tempo >= VERSUS_T_VENCEDOR) {
    var _texto = (vencedor == -1)
        ? "EMPATE"
        : (versus_nome(vencedor) + " VENCEU!");

    ui_texto_flutuante(_cx, 336, _texto, 1, f_padrao,
                       (vencedor == -1) ? c_white : versus_cor(vencedor));
}

if (revelacao_pronta) {
    ui_prompt(_cx, 420, ui_texto_confirmar() + " para continuar", 65);
}

ui_reset();
