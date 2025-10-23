// Máquina de estados da transição
switch (estado) {
    case FADE.IN:
        alpha = max(0, alpha - velocidade);
        if (alpha == 0) {
            estado = FADE.IDLE;
        }
        break;

    case FADE.OUT:
        alpha = min(1, alpha + velocidade);
        if (alpha == 1) {
            if (room != proxima_sala) {
                room_goto(proxima_sala);
            }
            estado = FADE.IN; // Começa o fade-in automaticamente na nova sala
        }
        break;
}