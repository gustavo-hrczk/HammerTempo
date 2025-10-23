// Enum para os estados da transição
enum FADE {
    IN,  // De preto para transparente (revelando a sala)
    OUT, // De transparente para preto (escondendo a sala)
    IDLE // Nenhuma transição ativa
}

estado = FADE.IN; // Sempre começa fazendo fade-in na primeira sala
alpha = 1; // Começa totalmente preto
velocidade = 0.02;
proxima_sala = -1;

// Função para ser chamada por outros objetos para iniciar uma transição
mudar_de_sala = function(sala_alvo) {
    if (estado == FADE.IDLE) {
        estado = FADE.OUT;
        proxima_sala = sala_alvo;
    }
}