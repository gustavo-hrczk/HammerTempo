var _cx = display_get_gui_width() / 2;
var _qtd = array_length(opcoes);

// A descrição fica FORA do painel, embaixo: dentro dela empurraria os itens para
// larguras diferentes, e o painel deixaria de bater com o do menu principal.
var _altura = ui_painel_menu(_qtd, PAINEL_LARGURA);
var _topo = (display_get_gui_height() / 2) + UI_PAINEL_Y - (_altura / 2);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// --- ITENS ---
var _y = _topo + (UI_PAINEL_PADDING / 2) + (UI_ITEM_GAP / 2);

for (var i = 0; i < _qtd; i++) {
    ui_item_menu(_cx, _y, opcoes[i], i == opcao_selecionada, "", PAINEL_LARGURA - 17);
    _y += UI_ITEM_GAP;
}

// --- DESCRIÇÃO DO MODO EM FOCO ---
// Em fonte pequena e tinta apagada: é apoio à decisão, não um item de menu. Posição
// inteira pela regra da fonte de pixel (D-33).
draw_set_font(f_padrao_pequena);
draw_set_color(UI_COR_APAGADA);
draw_set_halign(fa_center);
draw_text(_cx, floor(_topo + _altura + 26), descricoes[opcao_selecionada]);

ui_reset();
