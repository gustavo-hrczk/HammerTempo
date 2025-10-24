// O Step verifica o teclado a cada frame, garantindo que o input seja detectado.
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
	audio_play_sound(snd_menu_confirm, 10, false);
	audio_sound_gain(snd_menu_confirm,o_controlador_opcoes.opcoes_volume,0);
    // Avisa ao controlador geral que o tutorial foi visto.
    o_controlador_geral.tutorial_ja_foi_visto = true;

    // Muda o estado do jogo para a seleção de fases.
    o_controlador_geral.estado_jogo = MINIGAME.SELECAO_FASE;

    // O trabalho deste objeto acabou.
    instance_destroy();
}