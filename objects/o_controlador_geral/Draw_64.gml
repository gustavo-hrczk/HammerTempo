switch (estado_jogo) {

    case MINIGAME.CONTAGEM:
        if (contagem_timer > 0) {
            var _numero = string(ceil(contagem_timer / room_speed));

            // Mesma fonte e mesmo tratamento do resto do jogo: sem contorno, sem
            // pulso, sem variação de opacidade. Do ajuste anterior ficou só o
            // enquadramento — centralizado na faixa por onde as notas vão correr.
            var _cx = display_get_gui_width() / 2;
            var _cy = (HUD_CORREDOR_TOPO + HUD_CORREDOR_BASE) / 2;

            draw_set_font(f_padrao);
            draw_set_color(c_black);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);

            draw_text(_cx, _cy - 58, "Prepare-se para forjar em...");

            // escala 3 é inteira; a posição é arredondada para não sair da grade
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            var _largura = string_width(_numero) * 3;
            var _altura = string_height(_numero) * 3;
            draw_text_transformed(floor(_cx - (_largura / 2)),
                                  floor(_cy + 26 - (_altura / 2)),
                                  _numero, 3, 3, 0);

            ui_reset();
        }
        break;

    case MINIGAME.RITMO:
        hud_draw();
        break;
}

debug_draw();
