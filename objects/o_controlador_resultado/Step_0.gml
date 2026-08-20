// Espera o jogador confirmar para voltar à seleção de fases
if (input_pressed(ACAO.CONFIRMAR)) {
    o_audio_manager.play_sfx(snd_menu_confirm);

    audio_stop_sound(snd_resultado_bom);
    audio_stop_sound(snd_resultado_ruim);

    o_controlador_geral.estado_jogo = MINIGAME.SELECAO_FASE;
    o_controlador_geral.resetar_estatisticas();

    instance_destroy();
    ir_para_sala(rm_forja);
}
