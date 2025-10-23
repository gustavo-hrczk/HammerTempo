// Substitua TODO o seu Evento Draw GUI por esta versão limpa:

switch (estado_jogo) {
    
    case MINIGAME.CONTAGEM:
        if (contagem_timer > 0) {
            var _display_number = ceil(contagem_timer / room_speed);
            
            draw_set_font(f_padrao);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(c_black);

            var _cx = display_get_gui_width() / 2;
            var _cy_rodape = 600;

            draw_text(_cx, _cy_rodape - 40, "Prepare-se para forjar em...");
            draw_text_transformed(_cx, _cy_rodape + 40, string(_display_number), 3, 3, 0);

            draw_set_halign(fa_left); // Reseta
        }
        break;
        
    case MINIGAME.RITMO:
        // --- DESENHO DO HUD DURANTE O JOGO ---
        draw_set_font(f_padrao);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_white);

//        draw_text(10, 10, "Estado Atual: " + string(estado_jogo));

        draw_set_halign(fa_right);
//        draw_text(room_width - 20, 20, "Pontos: " + string(pontuacao));
        draw_set_halign(fa_left); // Reseta
        break;
}