// Se estivermos no menu principal OU na seleção de fase, não desenha o HUD.
// Se estivermos em qualquer estado que não seja o jogo ativo, não desenha o HUD.
if (estado_jogo != MINIGAME.RITMO) { // << CONDIÇÃO ATUALIZADA
    // Agora, desenha a contagem se estivermos no estado CONTAGEM
if (estado_jogo == MINIGAME.CONTAGEM && contagem_timer > 0) {

    var _display_number = ceil(contagem_timer / room_speed);

    draw_set_font(f_padrao);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_black);

    // --- MUDANÇA IMPORTANTE AQUI ---
    var _cx = display_get_gui_width() / 2;
    var _cy_rodape = 600; // Posição Y no rodapé (a mesma do seletor de fases)

    draw_text(_cx, _cy_rodape - 40, "Etapa da forja começa em...");
    draw_text_transformed(_cx, _cy_rodape + 40, string(_display_number), 3, 3, 0);

    draw_set_halign(fa_left); // Reseta
    }
    exit; // Sai para não desenhar o HUD
}

// Desenha o estado atual para debug
draw_text(10, 10, "Estado Atual: " + string(estado_jogo));

// Desenha a pontuação
draw_set_halign(fa_right);
draw_text(room_width - 20, 20, "Pontos: " + string(pontuacao));
draw_set_halign(fa_left); // Reseta