// Se a transição universal estiver acontecendo, o menu não aceita input do jogador.
if (instance_exists(o_transicao) && o_transicao.estado == FADE.OUT) {
    exit;
}

// --- CONTROLE DE NAVEGAÇÃO ---
var _move = input_eixo_v();

if (_move != 0) {
    opcao_selecionada += _move;
    var _total_opcoes = array_length(opcoes_menu);

    // Som de navegação alternado
    var _som_a_tocar = o_controlador_geral.nav_sounds[o_controlador_geral.nav_sound_index];
    o_audio_manager.play_sfx(_som_a_tocar);
    o_controlador_geral.nav_sound_index = 1 - o_controlador_geral.nav_sound_index;

    // Cursor "dá a volta"
    if (opcao_selecionada < 0) {
        opcao_selecionada = _total_opcoes - 1;
    }
    if (opcao_selecionada >= _total_opcoes) {
        opcao_selecionada = 0;
    }
}

// --- CONTROLE DE SELEÇÃO ---
if (input_pressed(ACAO.CONFIRMAR)) {
    o_audio_manager.play_sfx(snd_menu_confirm);

    switch (opcao_selecionada) {
        case 0: // Começar Jogo
            // Se o tutorial ainda não foi visto, ele vem antes da seleção de fase.
            if (o_controlador_geral.tutorial_ja_foi_visto == false) {
                o_controlador_geral.estado_jogo = MINIGAME.TUTORIAL;
            } else {
                o_controlador_geral.estado_jogo = MINIGAME.SELECAO_FASE;
            }
            room_goto(rm_forja);
            break;

        case 1: // Opções
            room_goto(rm_opcoes);
            break;

        case 2: // Créditos
            room_goto(rm_creditos);
            break;

        case 3: // Sair do Jogo
            game_end();
            break;
    }
}
