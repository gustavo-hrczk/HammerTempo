var _cx = display_get_gui_width() / 2;
var _cy = (display_get_gui_height() / 2) + PAINEL_OFFSET;
var _total = array_length(acoes);

// O painel tem uma fatia a mais que a lista: a primeira é o título.
var _fatias = _total + 1;
var _altura_painel = ui_painel_menu(_fatias, PAINEL_LARGURA, PAINEL_OFFSET);
var _primeira = _cy - (((_fatias - 1) * UI_ITEM_GAP) / 2);

// --- TÍTULO ---
// Mesma faixa escura do "COMO FORJAR" do tutorial, que é a outra sobreposição.
draw_set_font(f_padrao);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_color(c_black);
draw_set_alpha(0.25);
draw_rectangle(_cx - (ITEM_LARGURA / 2), _primeira - 22,
               _cx + (ITEM_LARGURA / 2), _primeira + 22, false);
draw_set_alpha(1);

draw_set_color(UI_COR_DESTAQUE);
draw_text(_cx, _primeira, "CONTROLES");

// --- LISTA ---
for (var i = 0; i < _total; i++) {
    // O valor sai de input_nome_da_acao(), que lê o vínculo em vigor no dispositivo
    // em uso — a mesma função que o tutorial usa. Com um encoder de arcade ligado,
    // esta tela passa a mostrar os controles dele sem nenhuma troca de código.
    ui_item_menu(_cx, _primeira + ((i + 1) * UI_ITEM_GAP),
                 input_rotulo_acao(acoes[i]),
                 i == opcao_selecionada,
                 input_nome_da_acao(acoes[i]),
                 ITEM_LARGURA);
}

// --- AJUDA ---
draw_set_font(f_padrao_pequena);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_black);
draw_text(_cx, _cy + (_altura_painel / 2) + 30,
          "Lendo de: " + string_upper(global.input_dispositivo) + "  -  VOLTAR fecha");

ui_reset();
