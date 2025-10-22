// Espera o jogador pressionar Enter para continuar
if (keyboard_check_pressed(vk_enter)) {
    o_controlador_geral.estado_jogo = MINIGAME.SELECAO_FASE;
    instance_destroy();
    room_goto(rm_forja); // << Garanta que esta linha existe!
	o_controlador_geral.resetar_estatisticas();
}