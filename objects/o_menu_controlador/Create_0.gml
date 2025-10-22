// enum para os estados do menu
enum MENU_STATE {
    IDLE,        // O menu está ativo, aguardando input
    FADING_OUT   // O menu está escurecendo a tela para uma transição
}

// Opções do menu
opcoes_menu = ["Começar Jogo", "Opções", "Créditos", "Sair do Jogo"];
opcao_selecionada = 0;

// Variáveis para a máquina de estados e transição
estado = MENU_STATE.IDLE;
transicao_alpha = 0;
transicao_velocidade = 0.03;
