// Quando a animação da martelada terminar...
if (sprite_index == s_ferreiro_martelada) {
    // ...volta para o estado de "parado", pronto para a próxima ação.
    estado = FERRreiro_ESTADO.IDLE;
    sprite_index = s_ferreiro_idle;
    image_speed = 0.5; // << Define a velocidade da animação de idle
}