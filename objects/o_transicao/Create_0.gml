// Guarda de instância única (auditoria CV-01)
if (instance_number(object_index) > 1) {
    instance_destroy();
    exit;
}

// O enum FADE agora vive em scr_estados.

estado = FADE.IN; // Sempre começa fazendo fade-in na primeira sala
alpha = 1;        // Começa totalmente preto
velocidade = 1 / FLUXO_FADE_FRAMES; // 250 ms, padrão de todas as telas
proxima_sala = -1;

// Respiro opcional: quantos frames a tela fica parada no preto entre uma sala e
// outra. Zero na maioria das trocas, para o ritmo continuar rápido; a abertura
// usa um valor maior, porque ali a pausa é parte da apresentação.
espera_frames = 0;
espera_timer = 0;

// Função para ser chamada por outros objetos para iniciar uma transição
mudar_de_sala = function(sala_alvo, _espera = 0) {
    if (estado == FADE.IDLE) {
        estado = FADE.OUT;
        proxima_sala = sala_alvo;
        espera_frames = _espera;
    }
}

// Função ADICIONAL para mudar de sala SEM iniciar o FADE.OUT.
// Usar para retornar a telas de menu que já foram carregadas.
mudar_de_sala_imediato = function(sala_alvo) {
    room_goto(sala_alvo);
    estado = FADE.IDLE;
    alpha = 0;
}
