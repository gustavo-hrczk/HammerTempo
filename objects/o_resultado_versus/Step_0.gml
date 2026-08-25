if (!revelacao_pronta) {
    tempo += 1 / room_speed;

    if (tempo >= VERSUS_T_PROMPT) {
        revelacao_pronta = true;
    }
}

if (!input_pressed(ACAO.CONFIRMAR)) {
    exit;
}

// Numa feira com fila, esperar animação é imposto: o primeiro toque termina a
// revelação e o segundo é que sai da tela.
if (!revelacao_pronta) {
    concluir_revelacao();
    o_audio_manager.play_sfx(snd_menu_confirm);
    exit;
}

o_audio_manager.play_sfx(snd_menu_confirm);

// O Versus volta ao MENU, e não ao seletor de armas: a partida acabou para os dois, e
// quem quiser outra escolhe o modo de novo — inclusive porque o segundo jogador pode
// ser outra pessoa.
o_controlador_geral.modo_jogo = MODO.LIVRE;
o_controlador_geral.estado_jogo = MINIGAME.NENHUM;
o_controlador_geral.resetar_estatisticas();

instance_destroy();
ir_para_sala(rm_menu);
