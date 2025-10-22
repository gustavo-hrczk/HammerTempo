// Desenha o logo do jogo no centro
draw_sprite(s_logo_jogo, 0, room_width / 2, room_height / 2 - 100);

// Desenha as opções do menu
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
for (var i = 0; i < array_length(opcoes_menu); i++) {
    var _cor = c_white;
    if (i == opcao_selecionada) {
        _cor = c_yellow; // Destaca a opção selecionada
    }
    draw_text_color(room_width / 2, room_height / 2 + 50 + (i * 40), opcoes_menu[i], _cor, _cor, _cor, _cor, 1);
}
draw_set_halign(fa_left); // Reseta o alinhamento