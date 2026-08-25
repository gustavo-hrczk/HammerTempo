if (room != rm_modos) {
    exit;
}

// Mesma logo, mesma moldura e mesmos itens do menu principal: a troca entre as duas
// telas não pode deslocar nem repintar nada.
var _cx = display_get_gui_width() / 2;
var _cy = (display_get_gui_height() / 2) + UI_PAINEL_Y;
var _total = array_length(opcoes_menu);

ui_logo();
var _altura_painel = ui_painel_menu(_total);
var _primeiro = _cy - (((_total - 1) * UI_ITEM_GAP) / 2);

for (var i = 0; i < _total; i++) {
    ui_item_menu(_cx, _primeiro + (i * UI_ITEM_GAP), opcoes_menu[i], i == opcao_selecionada);
}

// --- DESCRIÇÃO DO MODO EM FOCO ---
// Fora da moldura, em fonte pequena e tinta apagada: é apoio à decisão, não um item
// de menu. Posição inteira pela regra da fonte de pixel (D-33).
var _desc = descricoes[opcao_selecionada];

if (_desc != "") {
    draw_set_font(f_padrao_pequena);
    draw_set_color(UI_COR_APAGADA);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_cx, floor(_cy + (_altura_painel / 2) + 26), _desc);
}

ui_reset();
