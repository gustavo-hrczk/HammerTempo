// --- NAVEGAÇÃO COM AS SETAS ---
var _cima = keyboard_check_pressed(vk_up);
var _baixo = keyboard_check_pressed(vk_down);
var _confirmar = keyboard_check_pressed(vk_enter);

var _total_opcoes = array_length(opcoes_menu);

// Move a seleção para baixo
if (_baixo) {
    opcao_selecionada = (opcao_selecionada + 1) % _total_opcoes;
}

// Move a seleção para cima
if (_cima) {
    // A matemática aqui garante que a seleção "dê a volta" corretamente de 0 para a última opção
    opcao_selecionada = (opcao_selecionada - 1 + _total_opcoes) % _total_opcoes;
}

// --- AÇÃO AO CONFIRMAR ---
if (_confirmar) {
    
    // Usa um 'switch' para decidir o que fazer baseado na opção selecionada
    switch (opcao_selecionada) {
        
        case 0: // Começar Jogo
            show_debug_message("Opção 'Começar Jogo' selecionada!");
            
            o_controlador_geral.fase_atual = 1;
            o_controlador_geral.estado_jogo = MINIGAME.RITMO;
            room_goto(rm_forja);
            break;
            
        case 1: // Opções
            show_debug_message("Opção 'Opções' selecionada! (Ainda não implementado)");
            break;
            
        case 2: // NOVA: Créditos
            show_debug_message("Opção 'Créditos' selecionada! (Ainda não implementado)");
            break;
            
        case 3: // CORRIGIDO: Sair do Jogo
            game_end();
            break;
    }
}