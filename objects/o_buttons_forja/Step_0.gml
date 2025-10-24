if (!instance_exists(o_controlador_geral) || o_controlador_geral.estado_jogo != MINIGAME.RITMO) {
    exit; // Para a execução de todo o código abaixo se não for a hora certa.
}

// =================================================================
// PARTE 1: LÓGICA DE ANIMAÇÃO NORMAL
// =================================================================
if (keyboard_check(minha_tecla[0])||keyboard_check(minha_tecla[1])) {
    if (image_index < image_number - 1) {
        image_index += 1;
    } else {
        image_index = image_number - 1;
    }
} else {
    image_index = 0;
}

// =================================================================
// PARTE 2: LÓGICA DE ACERTO (QUE AVISA A NOTA)
// =================================================================
if (keyboard_check_pressed(minha_tecla[0])||keyboard_check_pressed(minha_tecla[1])) {

    var _nota_acertada = instance_place(x, y, o_nota_seta);
	

    if (_nota_acertada != noone && _nota_acertada.tipo_seta == meu_tipo) {
		o_controlador_geral.stats_spam_detect = 0;

        // Verifica a precisão e avisa a nota para iniciar seu fade
		if (_nota_acertada.x >= 97 && place_meeting(_nota_acertada.x, _nota_acertada.y, o_hitbox_perfeito)) {
			 show_debug_message("PERFEITO!");
			 o_controlador_geral.stats_sequencia_errada = 0;
			 o_controlador_geral.pontuacao += 100 + (10*o_controlador_geral.stats_sequencia);
			 o_controlador_geral.stats_sequencia++;
			 o_controlador_geral.stats_acertos_perfeitos++; // <<< ADICIONE AQUI
			 _nota_acertada.iniciar_fade_final(c_silver, true);
			 o_ferreiro.iniciar_martelada_perfeita();
			            o_audio_manager.play_martelada_sequencial_sfx();
		}else if (place_meeting(_nota_acertada.x, _nota_acertada.y, o_hitbox_bom)) {
			 show_debug_message("BOM!");
			 o_controlador_geral.stats_sequencia_errada = 0;
			 o_controlador_geral.pontuacao += 50 + (5*o_controlador_geral.stats_sequencia);
			 o_controlador_geral.stats_sequencia++;
			 o_controlador_geral.stats_acertos_bons++; // <<< ADICIONE AQUI
			 _nota_acertada.iniciar_fade_final(c_silver, true);
			 o_ferreiro.iniciar_martelada_normal();
			             o_audio_manager.play_martelada_sequencial_sfx();
			 
		}
		
	} else {
		o_controlador_geral.stats_spam_detect++;
	}
}