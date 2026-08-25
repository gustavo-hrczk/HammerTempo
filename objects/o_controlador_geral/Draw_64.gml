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

        // O titulo abre JUNTO com a contagem, e nao depois dela: assim ele ja saiu
        // quando a fase comeca. Ver hud_titulo_fase.
        hud_titulo_fase();

        // No Versus, cada pista se apresenta durante a preparacao. Quem chega no
        // gabinete precisa saber qual das duas e a sua ANTES da primeira nota.
        if (versus_ativo()) versus_marcar_pistas(1);
        break;

    case MINIGAME.RITMO:
        hud_draw();
        hud_titulo_fase();

        // O rotulo da pista some junto com o titulo: depois disso ele viraria ruido
        // por cima da partida.
        if (versus_ativo()) {
            var _tp = hud_titulo_tempo() / room_speed;
            if (_tp < HUD_TITULO_DUR) {
                versus_marcar_pistas(1 - (_tp / HUD_TITULO_DUR));
            }
        }
        break;
}

// =================================================================
// MENU DE PAUSA — desenhado por cima de tudo, com o jogo congelado atrás
// =================================================================
if (pausa && retomada_timer > 0) {
    // Retomada: o campo fica à vista, só com a contagem por cima.
    //
    // NO VERSUS A CONTAGEM APARECE NAS DUAS PISTAS. Ela vivia so no corredor de baixo,
    // entao o jogador 2 nao tinha como saber quanto faltava para voltar — os dois
    // retomam ao mesmo tempo, e os dois precisam ver o mesmo numero.
    var _rn = string(ceil(retomada_timer / room_speed));
    var _rcx = display_get_gui_width() / 2;

    var _pistas = versus_ativo() ? [0, 1] : [solo_jogador()];

    for (var _i = 0; _i < array_length(_pistas); _i++) {
        var _rcy = ritmo_corredor_topo(_pistas[_i]) + 119;

        draw_set_font(f_padrao);
        draw_set_color(c_black);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(_rcx, _rcy - 58, "Retomando em...");

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        var _rw = string_width(_rn) * 3;
        var _rh = string_height(_rn) * 3;
        draw_text_transformed(floor(_rcx - (_rw / 2)), floor(_rcy + 26 - (_rh / 2)),
                              _rn, 3, 3, 0);
    }

    ui_reset();
}
else if (pausa) {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

    draw_set_alpha(0.65);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    // Mesma moldura e mesmos itens dos outros menus, só que centralizada na tela.
    var _cx = _gw / 2;
    var _cy = _gh / 2;

    // A lista muda com o modo: Arcade e Versus nao tem "Reiniciar" (ver
    // pausa_opcoes_agora). Desenhar a lista fixa mostraria uma opcao que o
    // confirmar nao executa.
    var _lista_pausa = pausa_opcoes_agora();
    var _total = array_length(_lista_pausa);
    var _altura_painel = ((_total + 1) * UI_ITEM_GAP) + UI_PAINEL_PADDING; // +1 pelo título

    draw_sprite_stretched(s_menu_background_panel, 0,
                          _cx - (UI_PAINEL_LARGURA / 2), _cy - (_altura_painel / 2),
                          UI_PAINEL_LARGURA, _altura_painel);

    draw_set_font(f_padrao);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(UI_COR_TEXTO);
    draw_text(_cx, _cy - (_altura_painel / 2) + 38, "PAUSA");

    var _primeiro = _cy - (((_total - 1) * UI_ITEM_GAP) / 2) + 20;

    for (var i = 0; i < _total; i++) {
        ui_item_menu(_cx, _primeiro + (i * UI_ITEM_GAP), _lista_pausa[i], i == pausa_opcao);
    }

    ui_reset();
}

debug_draw();
