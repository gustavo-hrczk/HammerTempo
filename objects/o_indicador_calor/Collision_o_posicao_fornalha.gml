if(instance_place(o_indicador_calor.x+16, o_indicador_calor.y+16, o_posicao_fornalha)){
	if(keyboard_check_released(vk_space)){
		iniciar_fade_final(c_white, true)
		show_debug_message("ACERTO!");
        o_controlador_geral.pontuacao += 50;
	}
}