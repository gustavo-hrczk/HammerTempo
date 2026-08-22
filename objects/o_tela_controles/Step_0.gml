if (fluxo_ocupado()) {
    exit;
}

// --- SAIR ---
if (input_pressed(ACAO.VOLTAR)) {
    o_audio_manager.play_sfx(snd_menu_return);
    instance_destroy();
    exit;
}

// --- NAVEGAÇÃO ---
var _move = input_eixo_v();
if (_move != 0) {
    opcao_selecionada += _move;

    var _som = o_controlador_geral.nav_sounds[o_controlador_geral.nav_sound_index];
    o_audio_manager.play_sfx(_som);
    o_controlador_geral.nav_sound_index = 1 - o_controlador_geral.nav_sound_index;

    var _total = array_length(acoes);
    if (opcao_selecionada < 0)       { opcao_selecionada = _total - 1; }
    if (opcao_selecionada >= _total) { opcao_selecionada = 0; }
}
