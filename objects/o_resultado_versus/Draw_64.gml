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

    // A COLUNA DE TEXTO PARA ANTES DO MEDALHAO. Ele fica encostado na margem direita,
    // centrado na altura do corredor, e tudo o mais — nome, total, barra e contagens —
    // recua para nao passar por baixo dele.
    var _med_lado = icone_tamanho(VERSUS_ESCALA_ICONE);
    var _med_x = _gw - 150 - (_med_lado / 2);
    var _dir = _med_x - (_med_lado / 2) - 26;

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
        var _yd = _by + _bh + 28;

        // A MESMA GRADE DA TELA DE RESULTADO DE UM JOGADOR: tinta escura sobre o
        // pergaminho, rotulo com dois-pontos, sem contorno e sem cor por tier.
        //
        // As cores de tier foram tentadas aqui e reprovadas na medicao — elas nasceram
        // para o fundo escuro da pista e dao entre 1,76 e 2,72 de contraste sobre o
        // pergaminho, longe do minimo de 4,5. Contorna-las resolvia o contraste e
        // criava uma segunda linguagem visual na mesma tela, competindo com a nota.
        //
        // O contorno fica reservado para UMA coisa so, que e o veredito.
        // f_padrao, o MESMO corpo da grade de estatisticas da tela de um jogador. Estava
        // em f_padrao_pequena para caber junto com o "Nota S" na ponta; sem ele a linha
        // sobra espaco, e nao ha motivo para os dois modos lerem em tamanhos
        // diferentes a mesma informacao.
        draw_set_font(f_padrao);

        var _tx = _esq;
        var _campos = ["Perfeitas: " + string(perfeitas[i]),
                       "Ótimas: "    + string(otimas[i]),
                       "Boas: "      + string(boas[i]),
                       "Erros: "     + string(erros[i])];

        for (var _k = 0; _k < array_length(_campos); _k++) {
            hud_texto_painel(_tx, _yd, _campos[_k], _tinta, f_padrao, fa_left);
            _tx += string_width(_campos[_k]) + 30;
        }
    }

    // --- A PECA FORJADA, com a nota estampada ---
    // Entra junto com o detalhe, no mesmo instante das contagens: a peca e a leitura de
    // "como foi", e ela nao pode chegar antes de os numeros que a explicam.
    if (tempo >= VERSUS_T_DETALHE) {
        icone_desenhar(arma, niveis[i], _med_x, _topo + (RITMO_CORREDOR_ALTURA / 2) - 6,
                       VERSUS_ESCALA_ICONE, 1, tiers[i]);
    }
}

// =================================================================
// TITULO E VENCEDOR — na faixa do meio, sobre a cena
// =================================================================
draw_set_halign(fa_center);

// A FAIXA DO MEIO E CENTRADA ENTRE OS DOIS CORREDORES.
//
// O corredor de cima acaba em 228 e o de baixo comeca em 492, entao o centro da cena
// e 360 — e nao um valor escolhido a olho. Os tres textos se distribuem em volta dele.
//
// Uma placa unica atras dos tres, mais densa que a do texto flutuante: aqui o fundo e
// a forja inteira, cheia de detalhe e contraste, e o degrade padrao nao dava conta.
var _cm = (RITMO_CORREDOR_P2 + 228 + 492) / 2;

hud_placa_suave(0, _cm - 92, _gw, _cm + 92, c_black, 0.78, 300, 40);

draw_set_font(f_padrao);
draw_set_color(c_white);
draw_text(_cx, _cm - 58, "FIM DA DISPUTA");

if (tempo >= VERSUS_T_VENCEDOR) {
    var _texto = (vencedor == -1)
        ? "EMPATE"
        : (versus_nome(vencedor) + " VENCEU!");

    draw_set_color((vencedor == -1) ? c_white : versus_cor(vencedor));
    draw_text_transformed(floor(_cx), floor(_cm), _texto, 2, 2, 0);
}

if (revelacao_pronta) {
    draw_set_font(f_padrao_pequena);
    draw_set_color(UI_COR_DESTAQUE);
    draw_text(_cx, _cm + 62, ui_texto_confirmar_dupla() + " para continuar");
}

ui_reset();
