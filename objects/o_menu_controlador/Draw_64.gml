// A tabela de recordes ocupa o mesmo lugar do painel, com outra altura: desenhar as
// duas empilharia moldura sobre moldura.
if (instance_exists(o_tela_recordes)) {
    exit;
}

// Logo, moldura e itens vêm todos do padrão em scr_ui: o menu, as opções e a pausa
// precisam ser a mesma tela com conteúdo diferente, e não três telas parecidas.
var _cx = display_get_gui_width() / 2;
var _cy = (display_get_gui_height() / 2) + UI_PAINEL_Y;
var _total = array_length(opcoes_menu);

ui_logo();
ui_painel_menu(_total);
var _primeiro = _cy - (((_total - 1) * UI_ITEM_GAP) / 2);

for (var i = 0; i < _total; i++) {
    ui_item_menu(_cx, _primeiro + (i * UI_ITEM_GAP), opcoes_menu[i], i == opcao_selecionada);
}

ui_reset();
