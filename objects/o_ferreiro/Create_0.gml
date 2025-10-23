// Enum para os estados do ferreiro
enum FERRreiro_ESTADO {
    IDLE,
    MARTELANDO,
    COMEMORANDO
}
estado = FERRreiro_ESTADO.IDLE;

// --- FUNÇÃO PARA O "SHADE" DE ERRO (VERSÃO APRIMORADA) ---
aplicar_shade_erro = function() {
    if (estado == FERRreiro_ESTADO.IDLE) {
        
        // --- A MUDANÇA MÁGICA ESTÁ AQUI ---
        // Cria uma nova cor misturando branco e vermelho
        // O último valor (0.5) é a intensidade do vermelho. 0.3 = sutil, 0.7 = forte.
        var _cor_tint = merge_color(c_white, c_red, 0.5); // <<< AJUSTE AQUI a intensidade
        
        // Pinta o sprite atual com a nossa nova cor translúcida
        image_blend = _cor_tint;
        
        // Aciona o Alarme 0 para voltar à cor normal
        alarm[0] = room_speed * 0.2;
    }
}

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