switch (estado_jogo) {

    case MINIGAME.CONTAGEM:
        if (contagem_timer > 0) {
            var _display_number = ceil(contagem_timer / room_speed);

            // Volta para a faixa onde as notas vão correr, centralizada nela: é para
            // lá que o olho precisa estar quando a fase começar.
            var _cx = display_get_gui_width() / 2;
            var _cy = (HUD_CORREDOR_TOPO + HUD_CORREDOR_BASE) / 2;

            // Pulso por segundo em DEGRAUS: 5x, 4x e assenta em 3x. Escala inteira
            // preserva a grade de pixels da fonte — fracionária faz o glifo ferver.
            var _no_segundo = contagem_timer mod room_speed;
            var _escala = 3;
            if (_no_segundo > room_speed * 0.90)      _escala = 5;
            else if (_no_segundo > room_speed * 0.80) _escala = 4;

            var _frac = _no_segundo / room_speed;

            draw_set_font(f_padrao_pequena);
            hud_texto(_cx, _cy - 58, "Prepare-se para forjar em...", c_black, 1);

            draw_set_font(f_padrao);
            draw_set_alpha(0.6 + (0.4 * _frac));
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
