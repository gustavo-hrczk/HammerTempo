var _cx = display_get_gui_width() / 2;
var _cy = (display_get_gui_height() / 2) + PAINEL_OFFSET;

// O painel tem uma fatia a mais que a lista: a primeira é o título.
var _fatias = total_linhas + 1;
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

// --- LISTA DE AÇÕES ---
for (var i = 0; i < LINHA_RESTAURAR; i++) {

    var _selecionada = (i == opcao_selecionada);

    // O valor sai de input_nome_da_acao(), que lê o vínculo em vigor no dispositivo
    // em uso — a mesma função que o tutorial usa. Com um encoder de arcade ligado,
    // esta tela passa a mostrar os controles dele sem nenhuma troca de código.
    var _valor = (_selecionada && capturando)
        ? "APERTE..."
        : input_nome_da_acao(acoes[i]);

    ui_item_menu(_cx, _primeira + ((i + 1) * UI_ITEM_GAP),
                 input_rotulo_acao(acoes[i]),
                 _selecionada,
                 _valor,
                 ITEM_LARGURA);
}

// --- RESTAURAR PADRÃO ---
ui_item_menu(_cx, _primeira + ((LINHA_RESTAURAR + 1) * UI_ITEM_GAP),
             "Restaurar padrão",
             opcao_selecionada == LINHA_RESTAURAR,
             "",
             ITEM_LARGURA);

// --- AJUDA ---
var _base = _cy + (_altura_painel / 2);

var _ajuda = capturando
    ? "Aperte a tecla ou o botão desejado  -  ESC cancela"
    : "Lendo de: " + string_upper(global.input_dispositivo) + "  -  CONFIRMAR troca  -  ESC fecha";

draw_set_font(f_padrao_pequena);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_black);
draw_text(_cx, _base + 28, _ajuda);

// Dito na tela porque é a garantia que torna esta tela segura de usar: o que se
// muda aqui vale para a forja, e a navegação dos menus não depende disso.
draw_text(_cx, _base + 58, "As setas e WASD sempre navegam os menus");

ui_reset();
