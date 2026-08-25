if (room != rm_modos || fluxo_ocupado()) {
    exit;
}

// --- RETORNO AO MENU ---
// ESC por fora do vínculo, pelo mesmo motivo da tela de controles: é a tecla que todo
// mundo tenta primeiro, e ela não pode depender de remapeamento. O item "Voltar" da
// lista faz a mesma coisa, para quem está no arcade e não tem ESC ao alcance.
if (keyboard_check_pressed(vk_escape) || input_pressed(ACAO.VOLTAR)) {
    o_audio_manager.play_sfx(snd_menu_return);
    ir_para_sala(rm_menu, 0, false);
    exit;
}

// --- NAVEGAÇÃO ---
var _move = input_eixo_v();

if (_move != 0) {
    var _total = array_length(opcoes_menu);
    opcao_selecionada = (opcao_selecionada + _move + _total) mod _total;

    var _som = o_controlador_geral.nav_sounds[o_controlador_geral.nav_sound_index];
    o_audio_manager.play_sfx(_som);
    o_controlador_geral.nav_sound_index = 1 - o_controlador_geral.nav_sound_index;
}

// --- SELEÇÃO ---
if (input_pressed(ACAO.CONFIRMAR)) {

    if (opcao_selecionada == 3) {
        o_audio_manager.play_sfx(snd_menu_return);
        ir_para_sala(rm_menu, 0, false);
        exit;
    }

    o_audio_manager.play_sfx(snd_menu_confirm);

    var _arcade = (opcao_selecionada == 0);

    switch (opcao_selecionada) {
        case 0:  o_controlador_geral.modo_jogo = MODO.ARCADE; break;
        case 2:  o_controlador_geral.modo_jogo = MODO.VERSUS; break;
        default: o_controlador_geral.modo_jogo = MODO.LIVRE;  break;
    }

    // No Arcade o tutorial volta a cada percurso. tutorial_ja_foi_visto guarda a
    // sessão inteira, o que serve para quem está jogando em casa e atrapalha na feira:
    // ali cada partida é um visitante novo, que além de não conhecer o jogo não
    // conhece os botões do gabinete.
    if (_arcade && ARCADE_SEMPRE_TUTORIAL) {
        o_controlador_geral.tutorial_ja_foi_visto = false;
    }

    // Os dois modos entram pelo MESMO estado. Quem decide se o seletor de armas
    // aparece ou se o percurso começa direto é o controlador, já dentro da forja —
    // iniciar a contagem daqui faria o cronômetro correr durante o fade, e a fase
    // poderia começar antes de a sala existir.
    if (o_controlador_geral.tutorial_ja_foi_visto == false) {
        o_controlador_geral.estado_jogo = MINIGAME.TUTORIAL;
    } else {
        o_controlador_geral.estado_jogo = MINIGAME.SELECAO_FASE;
    }

    ir_para_sala(rm_forja, 0, false);
}
