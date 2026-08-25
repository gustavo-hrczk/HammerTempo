if (fluxo_ocupado()) {
    exit;
}

// ESC fecha sempre, por fora do vínculo, pelo mesmo motivo da tela de controles.
if (keyboard_check_pressed(vk_escape) || input_pressed(ACAO.VOLTAR)) {
    o_audio_manager.play_sfx(snd_menu_return);
    instance_destroy();
    exit;
}

// --- NAVEGAÇÃO ---
var _move = input_eixo_v();

if (_move != 0) {
    var _total = array_length(opcoes);
    opcao_selecionada = (opcao_selecionada + _move + _total) mod _total;

    var _som = o_controlador_geral.nav_sounds[o_controlador_geral.nav_sound_index];
    o_audio_manager.play_sfx(_som);
    o_controlador_geral.nav_sound_index = 1 - o_controlador_geral.nav_sound_index;
}

// --- SELEÇÃO ---
if (input_pressed(ACAO.CONFIRMAR)) {
    o_audio_manager.play_sfx(snd_menu_confirm);

    o_controlador_geral.modo_jogo = (opcao_selecionada == 0) ? MODO.ARCADE : MODO.LIVRE;

    // Os dois modos entram pelo MESMO estado. Quem decide se o seletor de armas
    // aparece ou se o percurso começa direto é o controlador, já dentro da forja —
    // iniciar a contagem daqui faria o cronômetro correr durante o fade, e a fase
    // poderia começar antes da sala existir.
    if (o_controlador_geral.tutorial_ja_foi_visto == false) {
        o_controlador_geral.estado_jogo = MINIGAME.TUTORIAL;
    } else {
        o_controlador_geral.estado_jogo = MINIGAME.SELECAO_FASE;
    }

    instance_destroy();
    ir_para_sala(rm_forja, 0, false);
}
