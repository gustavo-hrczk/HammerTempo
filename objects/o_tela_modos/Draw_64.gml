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
// Fora da moldura, então vai com placa de fundo: a tinta apagada sobre a nuvem clara
// media 1,9:1 e era quase invisível. ui_texto_flutuante garante 8,7:1 no pior fundo
// possível — é o padrão para qualquer texto sem painel atrás.
ui_texto_flutuante(_cx, _cy + (_altura_painel / 2) + 34, descricoes[opcao_selecionada]);

ui_reset();
