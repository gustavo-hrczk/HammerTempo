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

// =================================================================
// MENU DE PAUSA — desenhado por cima de tudo, com o jogo congelado atrás
// =================================================================
if (pausa) {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

    draw_set_alpha(0.65);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    var _cx = _gw / 2;
    var _cy = _gh / 2;
    var _bw = 360;
    var _bh = 240;

    draw_sprite_stretched(s_menu_background_panel, 0, _cx - (_bw / 2), _cy - (_bh / 2), _bw, _bh);

    var _tinta = make_colour_rgb(40, 28, 18);

    draw_set_font(f_padrao);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_set_color(_tinta);
    draw_text(_cx, _cy - 78, "PAUSA");

    var _gap = 46;
    var _primeiro = _cy - 18;

    for (var i = 0; i < array_length(pausa_opcoes); i++) {
        var _oy = _primeiro + (i * _gap);

        if (i == pausa_opcao) {
            ui_caixa_pulsante(_cx, _oy, _bw - 60, 38);
            draw_set_color(make_colour_rgb(178, 58, 22));
        } else {
            draw_set_color(_tinta);
        }

        draw_set_font(f_padrao);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(_cx, _oy, pausa_opcoes[i]);
    }

    ui_reset();
}

debug_draw();
