switch (estado_jogo) {

    case MINIGAME.CONTAGEM:
        if (contagem_timer > 0) {
            var _display_number = ceil(contagem_timer / room_speed);

            // Volta para a faixa onde as notas vão correr, centralizada nela: é para
            // lá que o olho precisa estar quando a fase começar.
            var _cx = display_get_gui_width() / 2;
            var _cy = (HUD_CORREDOR_TOPO + HUD_CORREDOR_BASE) / 2;

            // Pulso por segundo: o número entra grande e assenta, e a opacidade
            // acompanha, dando ritmo à contagem.
            var _frac = (contagem_timer mod room_speed) / room_speed;
            var _pop = power(_frac, 5);
            var _escala = 3 + (_pop * 1.7);

            draw_set_font(f_padrao_pequena);
            hud_texto(_cx, _cy - 58, "Prepare-se para forjar em...", c_black, 1);

            draw_set_font(f_padrao);
            draw_set_alpha(0.55 + (0.45 * _frac));
            hud_texto(_cx, _cy + 26, string(_display_number), make_colour_rgb(200, 70, 30), _escala);
            draw_set_alpha(1);

            ui_reset();
        }
        break;

    case MINIGAME.RITMO:
        hud_draw();
        break;
}

debug_draw();
