// Quando a animação da martelada terminar...
if (sprite_index == meus_sprites.martelada) {
    // ...volta para o estado de "parado", pronto para a próxima ação.
    estado = FERREIRO_ESTADO.IDLE;
    sprite_index = meus_sprites.idle;
    image_speed = 0.5; // << Define a velocidade da animação de idle
}

// Quando a animação de FALHA terminar...
else if (sprite_index == meus_sprites.falha) {
    // ...entra no estado de pose estática de falha.
    estado = FERREIRO_ESTADO.FALHOU_ESTATICO;
}