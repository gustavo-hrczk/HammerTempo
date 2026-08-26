// Este objeto só funciona no estado de seleção de fase
// O ARCADE nao tem selecao de armas: o percurso e a lista inteira. O estado
// SELECAO_FASE ainda e atravessado por um quadro ate arcade_iniciar_percurso rodar, e
// nesse quadro o seletor piscava por cima do tutorial que acabava de sair.
if (o_controlador_geral.modo_jogo == MODO.ARCADE) {
    exit;
}

if (o_controlador_geral.estado_jogo != MINIGAME.SELECAO_FASE || fluxo_ocupado()) {
    exit;
}

// --- RETORNO AO MENU ---
if (input_pressed(ACAO.VOLTAR)) {
    o_audio_manager.play_sfx(snd_menu_return);
    ir_para_sala(rm_menu, 0, false);
    exit;
}

// --- NAVEGAÇÃO HORIZONTAL ---
var _move_h = input_eixo_h();

if (_move_h != 0) {
    var _som_a_tocar = o_controlador_geral.nav_sounds[o_controlador_geral.nav_sound_index];
    o_audio_manager.play_sfx(_som_a_tocar);
    o_controlador_geral.nav_sound_index = 1 - o_controlador_geral.nav_sound_index;

    var _novo_indice = opcao_selecionada + _move_h;

    // Cursor "dá a volta"
    if (_novo_indice < 0) {
        _novo_indice += total_opcoes;
    }
    if (_novo_indice >= total_opcoes) {
        _novo_indice -= total_opcoes;
    }

    opcao_selecionada = _novo_indice;
}

// --- SELEÇÃO ---
if (input_pressed(ACAO.CONFIRMAR)) {
    o_audio_manager.play_sfx(snd_menu_confirm);

    o_controlador_geral.resetar_estatisticas();
    o_controlador_geral.fase_atual = opcao_selecionada;

    o_controlador_geral.estado_jogo = MINIGAME.CONTAGEM;
    o_controlador_geral.contagem_timer = 3 * room_speed;

    instance_destroy();
}
