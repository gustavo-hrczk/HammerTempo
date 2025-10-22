switch (estado_jogo) {
  
  
  case MINIGAME.SELECAO_FASE:
        // Garante que o seletor de fases seja criado APENAS UMA VEZ.
        if (!instance_exists(o_seletor_fases)) {
            instance_create_layer(0, 0, "Gameplay", o_seletor_fases);
        }
        break;
  
  case MINIGAME.CONTAGEM:
        // Se o timer está ativo, faz a contagem regressiva
        if (contagem_timer > 0) {
            contagem_timer--;
        }
        // Quando o timer chegar a zero, muda para o estado de RITMO
        else {
            estado_jogo = MINIGAME.RITMO;
        }
        break;
  
case MINIGAME.RITMO:
        // Garante que o spawner seja criado apenas uma vez.
        if (!instance_exists(o_spawner_ritmo)) {
            show_debug_message("Iniciando minigame de ritmo para a fase: " + fases_data[fase_atual].nome);
            var _spawn_x = room_width + 100;
            instance_create_layer(_spawn_x, 0, "Gameplay", o_spawner_ritmo);
        }
        
        // --- NOVA LÓGICA DE VERIFICAÇÃO DE FIM DE JOGO ---
        if (pontuacao <= -300) {
            show_debug_message("Game Over por pontuação baixa!");
            
            // 1. Muda o estado do jogo para o resultado.
            estado_jogo = MINIGAME.RESULTADO;
            
            // 2. Limpa a "bagunça" do minigame para que ele pare imediatamente.
            if (instance_exists(o_spawner_ritmo)) {
                instance_destroy(o_spawner_ritmo);
            }
            // Destrói todas as notas que ainda estão na tela.
            instance_destroy(o_nota_seta); 
            
            // 3. Cria o objeto que vai mostrar a tela de resultado.
            instance_create_layer(0, 0, "Gameplay", o_controlador_resultado);
        }
        break;
}