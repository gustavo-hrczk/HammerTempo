// Enum para os estados do ferreiro
enum FERRreiro_ESTADO {
    IDLE,
    MARTELANDO
}
estado = FERRreiro_ESTADO.IDLE;

// Função para iniciar a martelada NORMAL
iniciar_martelada_normal = function() {
    if (estado == FERRreiro_ESTADO.IDLE) { // Só martela se estiver parado
        estado = FERRreiro_ESTADO.MARTELANDO;
        sprite_index = s_ferreiro_martelada;
        image_index = 0; // Começa a animação do início
        image_speed = 1;
    }
}

// Função para iniciar a martelada PERFEITA
iniciar_martelada_perfeita = function() {
    if (estado == FERRreiro_ESTADO.IDLE) {
        estado = FERRreiro_ESTADO.MARTELANDO;
        sprite_index = s_ferreiro_martelada;
        image_index = 0;
        image_speed = 0.8; // Um pouco mais lento e pesado

        // Cria o efeito de faíscas na posição da bigorna
        if (instance_exists(o_bigorna)) {
            instance_create_layer(o_bigorna.x, o_bigorna.y - 30, "Gameplay", o_faisca);
        }
    }
}