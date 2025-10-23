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

// Função para iniciar a martelada NORMAL (VERSÃO CORRIGIDA)
iniciar_martelada_normal = function() {
    // A condição 'if (estado == FERRreiro_ESTADO.IDLE)' foi REMOVIDA.
    // Agora a martelada pode ser iniciada a qualquer momento.
    estado = FERRreiro_ESTADO.MARTELANDO;
    sprite_index = s_ferreiro_martelada;
    image_index = 0; // Força a animação a recomeçar do frame 0
    image_speed = 1;
}

// Função para iniciar a martelada PERFEITA (VERSÃO CORRIGIDA)
iniciar_martelada_perfeita = function() {
    // A condição 'if (estado == FERRreiro_ESTADO.IDLE)' foi REMOVIDA.
    estado = FERRreiro_ESTADO.MARTELANDO;
    sprite_index = s_ferreiro_martelada;
    image_index = 0; // Força a animação a recomeçar do frame 0
    image_speed = 0.8;

    if (instance_exists(o_bigorna)) {
        instance_create_layer(o_bigorna.x, o_bigorna.y, "Gameplay", o_faisca);
    }
}