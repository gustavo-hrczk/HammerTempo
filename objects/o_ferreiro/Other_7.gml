// Quando a animação da martelada terminar...
if (sprite_index == s_ferreiro_martelada) {
    // ...volta para o estado de "parado", pronto para a próxima ação.
    estado = FERREIRO_ESTADO.IDLE;
    sprite_index = s_ferreiro_idle;
    image_speed = 0.5; // << Define a velocidade da animação de idle
}

// Quando a animação de FALHA terminar...
else if (sprite_index == s_ferreiro_falha) {
    // ...entra no estado de pose estática de falha.
    estado = FERREIRO_ESTADO.FALHOU_ESTATICO;
}