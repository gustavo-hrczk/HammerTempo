if (room != rm_opcoes) {
    exit;
}

// A tela de controles ocupa o mesmo lugar do painel, com outra largura: desenhar as
// duas empilharia moldura sobre moldura.
if (instance_exists(o_tela_controles)) {
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
    var _pos_y = _primeiro + (i * UI_ITEM_GAP);
    var _valor = "";

    switch (i) {
        case 0: _valor = string(opcoes_musica); break;
        case 1: _valor = string(opcoes_sfx); break;
        // save_texto_janela() em vez do acesso direto: ela traz o clamp, e o
        // indice vem do save, que pode ficar fora da faixa se a lista de tamanhos
        // encolher um dia
        case 2: _valor = save_texto_janela(opcoes_janela); break;
        case 3: _valor = opcoes_tela_cheia ? "Sim" : "Não"; break;
        case 4: _valor = ""; break;   // Controles abre uma tela própria
    }

    ui_item_menu(_cx, _pos_y, opcoes_menu[i], i == opcao_selecionada, _valor);
}

// --- AJUDA ---
var _painel_base = (display_get_gui_height() / 2) + UI_PAINEL_Y + (_altura_painel / 2);

draw_set_font(f_padrao_pequena);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_black);
draw_text(_cx, _painel_base + 30, "ESQUERDA e DIREITA ajustam  -  APLICAR salva  -  VOLTAR descarta");

ui_reset();
