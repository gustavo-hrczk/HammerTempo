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

// Função ADICIONAL para mudar de sala SEM iniciar o FADE.OUT.
// Usar para retornar a telas de menu que já foram carregadas.
mudar_de_sala_imediato = function(sala_alvo) {
    // 1. Muda a sala imediatamente
    room_goto(sala_alvo); 
    
    // 2. Define o estado para IDLE (não vai fazer fade-in nem fade-out)
    // E garante que o alpha seja 0 (transparente)
    estado = FADE.IDLE;
    alpha = 0; 
}