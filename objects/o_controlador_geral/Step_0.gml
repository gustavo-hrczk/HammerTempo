// Substitua TODO o seu Evento Step por esta versão completa e robusta:

// Lógica de Pausa (se existir, deve ficar no topo)
//if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("P"))) {
//    if (estado_jogo == MINIGAME.RITMO || estado_jogo == MINIGAME.CONTAGEM) {
//        pausa = !pausa; // Alterna o estado de pausa
//    }
//}
if (pausa) {
    exit; // Se estiver pausado, para a execução do resto do evento
}


switch (estado_jogo) {
    
case MINIGAME.TUTORIAL:
        // Garante que a tela de tutorial seja criada apenas uma vez.
        if (!instance_exists(o_tela_tutorial)) {
            instance_create_layer(0, 0, "Gameplay", o_tela_tutorial);
        }
        break;
        
case MINIGAME.SELECAO_FASE:
		if(!audio_is_playing(snd_tema) || audio_sound_get_gain(snd_tema) <= 0){
			o_audio_manager.play_music(snd_tema);
		}
        // Só cria o seletor se estivermos na sala da forja.
        if (room == rm_forja) {
            if (!instance_exists(o_seletor_fases)) {
                instance_create_layer(0, 0, "Gameplay", o_seletor_fases);
            }
        }
        break;
    
case MINIGAME.CONTAGEM:
        if (contagem_timer > 0) {
            contagem_timer--;
        } else {
            estado_jogo = MINIGAME.RITMO;
        }
        break;
    
    case MINIGAME.RITMO:
        // Garante que o spawner seja criado apenas uma vez.
        if (!instance_exists(o_spawner_ritmo)) {
            show_debug_message("Iniciando minigame de ritmo para a fase: " + fases_data[fase_atual].nome);
            var _spawn_x = room_width + 120;
            instance_create_layer(_spawn_x, 0, "Gameplay", o_spawner_ritmo);
        }
		if(!audio_is_playing(fases_data[fase_atual].musica_fase) || audio_sound_get_gain(fases_data[fase_atual].musica_fase) <= 0){
			o_audio_manager.play_music(fases_data[fase_atual].musica_fase);
		}
        
        // Lógica de Fim de Jogo por erros
        if (stats_sequencia_errada >= fases_data[fase_atual].stats_limite_sequencia_errada ||stats_spam_detect >= 10) {
            show_debug_message("Game Over por excesso de erros!");
            
            estado_jogo = MINIGAME.RESULTADO;
            
            // Limpa a "bagunça" do minigame
            if (instance_exists(o_spawner_ritmo)) { instance_destroy(o_spawner_ritmo); }
            instance_destroy(o_nota_seta);
            
            // Cria o objeto da tela de resultado
            instance_create_layer(0, 0, "Gameplay", o_controlador_resultado);
        }
        break;
        
    case MINIGAME.RESULTADO:
        // O o_controlador_resultado agora gerencia o que acontece.
        // O controlador geral apenas espera.
        break;
}