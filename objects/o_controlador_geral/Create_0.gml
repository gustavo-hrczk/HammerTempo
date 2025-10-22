// Enum para controlar os estados do jogo de forma legível
enum MINIGAME {
    NENHUM,       // Nenhum minigame ativo (ex: transição)
    AQUECIMENTO,
    RITMO,
    TEMPERA,
    AFIACAO
}

// Variável que guarda o estado atual do jogo
estado_jogo = MINIGAME.NENHUM; // Mudei para RITMO para testarmos direto

// Variáveis de controle do jogo
fase_atual = 1;
pontuacao = 0; // Usaremos apenas 'pontuacao'. A 'pontuacao_total' era redundante.
