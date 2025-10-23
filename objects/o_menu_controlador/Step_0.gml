// Se a transição universal estiver acontecendo, o menu não aceita input do jogador.
// A verificação 'instance_exists' garante que o jogo não quebre se o o_transicao ainda não foi criado.
if (instance_exists(o_transicao) && o_transicao.estado != FADE.IDLE) {
    exit;
}

// --- CONTROLE DE NAVEGAÇÃO ---
var _move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
if (_move == 0) { // Corrigido de '=' para '==' para comparação
    _move = keyboard_check_pressed(ord("S")) - keyboard_check_pressed(ord("W"));
}
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
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    
    switch (opcao_selecionada) {
        case 0: // Começar Jogo
            // Configura o estado do jogo para a próxima sala
            if (o_controlador_geral) {
                o_controlador_geral.estado_jogo = MINIGAME.SELECAO_FASE;
            } else {
                //o_controlador_geral.estado_jogo = MINIGAME.TUTORIAL;
            }
            
            // Pede ao gerenciador universal para iniciar a transição
            room_goto(rm_forja);
            break;
            
        case 1: // Opções
            show_debug_message("Opção 'Opções' selecionada! (Ainda não implementado)");
            // Exemplo de como usar: o_transicao.mudar_de_sala(rm_opcoes);
            break;
            
        case 2: // Créditos
            show_debug_message("Opção 'Créditos' selecionada! (Ainda não implementado)");
            // Exemplo de como usar: o_transicao.mudar_de_sala(rm_creditos);
            break;
            
        case 3: // Sair do Jogo
            game_end();
            break;
    }
}