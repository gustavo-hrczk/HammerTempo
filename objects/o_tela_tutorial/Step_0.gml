if (input_pressed(ACAO.CONFIRMAR)) {
    o_audio_manager.play_sfx(snd_menu_confirm);

    // Avisa ao controlador geral que o tutorial foi visto.
    o_controlador_geral.tutorial_ja_foi_visto = true;

    // Muda o estado do jogo para a seleção de fases.
    o_controlador_geral.estado_jogo = MINIGAME.SELECAO_FASE;

    instance_destroy();
}
