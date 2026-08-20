switch (estado_jogo) {

    case MINIGAME.CONTAGEM:
        if (contagem_timer > 0) {
            var _display_number = ceil(contagem_timer / room_speed);

            draw_set_font(f_padrao);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(c_black);

            var _cx = display_get_gui_width() / 2;
            var _cy_rodape = 640;

            draw_text(_cx, _cy_rodape - 60, "Prepare-se para forjar em...");
            draw_text_transformed(_cx, _cy_rodape + 40, string(_display_number), 3, 3, 0);

            ui_reset();
        }
        break;

    case MINIGAME.RITMO:
        hud_draw();
        break;
}

debug_draw();
