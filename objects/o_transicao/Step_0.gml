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
            if (espera_frames > 0) {
                estado = FADE.ESPERA;
                espera_timer = espera_frames;
            } else {
                if (room != proxima_sala) { room_goto(proxima_sala); }
                estado = FADE.IN;
            }
        }
        break;

    case FADE.ESPERA:
        // tela preta parada: o respiro entre uma tela e a seguinte
        espera_timer--;
        if (espera_timer <= 0) {
            if (room != proxima_sala) { room_goto(proxima_sala); }
            espera_frames = 0;
            estado = FADE.IN;
        }
        break;
}
