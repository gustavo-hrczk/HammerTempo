// Se a transição universal estiver acontecendo, o menu não aceita input do jogador.
// A verificação 'instance_exists' garante que o jogo não quebre se o o_transicao ainda não foi criado.
if (instance_exists(o_transicao) && o_transicao.estado = FADE.OUT) {
    exit;
}

//// Dentro de if (_move != 0)
//if (_move != 0) {
//    o_audio_manager.play_sfx(snd_navegacao_menu);
//    // ... (resto do seu código de navegação)
//}

//// Dentro de if (keyboard_check_pressed(vk_enter)...)
//if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
//    o_audio_manager.play_sfx(snd_confirmacao_menu);
//    // ... (resto do seu código de seleção)
//}

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
            // --- LÓGICA DE DECISÃO INTELIGENTE ---
            // Se o tutorial ainda NÃO foi visto...
            if (o_controlador_geral.tutorial_ja_foi_visto == false) {
                // ...vai para o estado de TUTORIAL.
                o_controlador_geral.estado_jogo = MINIGAME.TUTORIAL;
            }
            // Se o tutorial JÁ foi visto...
            else {
                // ...pula direto para a SELEÇÃO DE FASE.
                o_controlador_geral.estado_jogo = MINIGAME.SELECAO_FASE;
            }
            
            // Em ambos os casos, pede ao gerenciador para mudar para a sala da forja.
            room_goto(rm_forja);
            break;
            
        case 1: // Opções
            show_debug_message("Opção 'Opções' selecionada!");
            room_goto(rm_opcoes);
            break;
            
        case 2: // Créditos
            show_debug_message("Opção 'Créditos' selecionada!");
            room_goto(rm_creditos);
            break;
            
        case 3: // Sair do Jogo
            game_end();
            break;
    }
}