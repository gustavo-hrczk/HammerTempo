// Evento Step do objeto de menu

switch (estado) {
    // =================================================================
    // CASO 1: O MENU ESTÁ AGUARDANDO A AÇÃO DO JOGADOR
    // =================================================================
    case MENU_STATE.IDLE:
        // --- CONTROLE DE NAVEGAÇÃO ---
        var _move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
        if (_move != 0) {
            opcao_selecionada += _move;
            var _total_opcoes = array_length(opcoes_menu);
            
            // Lógica para o cursor "dar a volta" (loop)
            if (opcao_selecionada < 0) {
                opcao_selecionada = _total_opcoes - 1;
            }
            if (opcao_selecionada >= _total_opcoes) {
                opcao_selecionada = 0;
            }
        }

        // --- CONTROLE DE SELEÇÃO ---
        if (keyboard_check_pressed(vk_enter)) {
            
            // VERIFICA SE A OPÇÃO É "COMEÇAR JOGO" (ÍNDICE 0)
            if (opcao_selecionada == 0) {
                // Se for, INICIA A TRANSIÇÃO DE FADE
                estado = MENU_STATE.FADING_OUT;
            } 
            else {
                // PARA AS OUTRAS OPÇÕES, A AÇÃO É IMEDIATA
                switch (opcao_selecionada) {
                    case 1: // Opções
                        show_debug_message("Opção 'Opções' selecionada! (Ação Imediata)");
                        // Exemplo: room_goto(rm_opcoes);
                        break;
                    
                    case 2: // Créditos
                        show_debug_message("Opção 'Créditos' selecionada! (Ação Imediata)");
                        // Exemplo: room_goto(rm_creditos);
                        break;
                        
                    case 3: // Sair do Jogo
                        game_end();
                        break;
                }
            }
        }
    break;

    // =================================================================
    // CASO 2: O MENU ESTÁ FAZENDO O "FADE OUT" (APENAS PARA "COMEÇAR JOGO")
    // =================================================================
case MENU_STATE.FADING_OUT:
        transicao_alpha = min(1, transicao_alpha + transicao_velocidade);
        
        if (transicao_alpha == 1) {
            // >>> ALTERAÇÃO IMPORTANTE AQUI <<<
            // Em vez de ir para RITMO, vamos para a SELEÇÃO DE FASE
            o_controlador_geral.estado_jogo = MINIGAME.SELECAO_FASE; 
            room_goto(rm_forja);
        }
    break;
}
