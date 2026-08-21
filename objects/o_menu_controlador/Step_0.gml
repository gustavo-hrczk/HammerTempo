// Se a transição universal estiver acontecendo, o menu não aceita input do jogador.
if (fluxo_ocupado()) {
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
            ir_para_sala(rm_forja);
            break;

        case 1: // Opções
            // sem fade: as duas telas compartilham logo e moldura, então o corte
            // seco lê como troca de conteúdo, e o fade leria como piscada
            ir_para_sala(rm_opcoes, 0, false);
            break;

        case 2: // Créditos
            ir_para_sala(rm_creditos);
            break;

        case 3: // Sair do Jogo
            game_end();
            break;
    }
}
