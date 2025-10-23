// Se o jogador pressionar Enter, o tutorial termina.
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    
    // Avisa ao controlador geral que o tutorial foi visto.
    o_controlador_geral.tutorial_ja_foi_visto = true;
    
    // Muda o estado do jogo para a seleção de fases.
    o_controlador_geral.estado_jogo = MINIGAME.SELECAO_FASE;
    
    // O trabalho deste objeto acabou.
    instance_destroy();
}