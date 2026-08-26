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

// VOLTA PARA A SELECAO DE ARMAS DO VERSUS, e nao para o menu.
//
// A dupla que acabou de jogar quase sempre quer outra partida, e mandar os dois de
// volta ao menu principal os obrigava a atravessar duas telas para isso. O modo
// continua sendo VERSUS: sair dali e escolha de quem quiser, pelo ESC.
// ZERA O AUDIO ANTES DE DEVOLVER O SELETOR.
//
// O tema voltava dobrado, tocando duas vezes sobreposto por alguns instantes. A tela
// de resultado chama fade_out_music, que pode ou nao ter terminado quando o jogador
// confirma — e o seletor de fases entra logo depois pedindo um crossfade para o tema.
// Um crossfade partindo de um estado indeterminado nao tem como garantir que a faixa
// anterior morreu.
//
// stop_music para TUDO: a faixa atual, a que estava em crossfade e os dois fades. O
// tema entra num silencio limpo, e nao por cima do que sobrou.
o_audio_manager.stop_music();

o_controlador_geral.estado_jogo = MINIGAME.SELECAO_FASE;
o_controlador_geral.resetar_estatisticas();

instance_destroy();
ir_para_sala(rm_forja);
