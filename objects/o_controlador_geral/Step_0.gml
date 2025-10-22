// Uma estrutura 'switch' para executar código diferente dependendo do estado do jogo
switch (estado_jogo) {

    case MINIGAME.NENHUM:
        // Código a ser executado quando nenhum minigame está ativo
        // Por exemplo, podemos checar se o jogador apertou "Enter" para começar
        if (keyboard_check_pressed(vk_enter)) {
            // Inicia o minigame de ritmo (vamos implementar isso na próxima etapa)
            estado_jogo = MINIGAME.RITMO;
            show_debug_message("Iniciando Minigame de Ritmo!");
        }
        break;

    case MINIGAME.RITMO:
        // Aqui vamos chamar a lógica do minigame de ritmo
        break;

    case MINIGAME.TEMPERA:
        // Aqui vamos chamar a lógica do minigame de têmpera
        break;

    // ... e assim por diante para os outros minigames
}

// (O resto do seu código do switch case fica abaixo disto)
