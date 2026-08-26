var _cx = display_get_gui_width() / 2;
var _gh = display_get_gui_height();

// Escurece o campo atrás, como o menu de pausa: a fase acabou e o que importa agora
// é a decisão.
draw_set_alpha(0.65);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), _gh, false);
draw_set_alpha(1);

// --- A FILEIRA DO QUE JÁ FOI FORJADO ---
// O mesmo desenho da tela final, em escala menor: o jogador decide olhando para o que
// já conquistou, e não para um número solto.
var _forjadas = fileira;
var _n = array_length(_forjadas);

if (_n > 0) {
    var _lado = icone_tamanho(2);
    var _passo = _lado + 14;
    var _inicio = _cx - (((_n - 1) * _passo) / 2);

    for (var i = 0; i < _n; i++) {
        icone_desenhar(_forjadas[i].icone, _forjadas[i].nivel,
                       _inicio + (i * _passo), 150, 2);
    }
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// --- TOTAL ATÉ AQUI ---
ui_texto_flutuante(_cx, 210,
                   "Arma " + string(feitas) + " de " + string(total_armas));

draw_set_font(f_padrao);
draw_set_color(UI_COR_DESTAQUE);
draw_text(floor(_cx), 258, "Percurso: " + string(total_ate_aqui));

// --- MENU ---
var _cy = (_gh / 2) + UI_PAINEL_Y;
var _total = array_length(opcoes_menu);

var _altura_painel = ui_painel_menu(_total, PAINEL_LARGURA);
var _primeiro = _cy - (((_total - 1) * UI_ITEM_GAP) / 2);

for (var i = 0; i < _total; i++) {
    ui_item_menu(_cx, _primeiro + (i * UI_ITEM_GAP), opcoes_menu[i],
                 i == opcao_selecionada, "", PAINEL_LARGURA - 17);
}

// A próxima arma fica embaixo do menu: é a informação que responde "vale a pena
// continuar?", que é exatamente a pergunta da tela.
ui_texto_flutuante(_cx, _cy + (_altura_painel / 2) + 34,
                   "A seguir: " + proxima_arma);

ui_reset();
