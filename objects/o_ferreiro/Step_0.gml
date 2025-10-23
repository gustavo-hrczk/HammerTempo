// Esta deve ser a PRIMEIRA coisa no evento.
if (instance_exists(o_controlador_geral) && o_controlador_geral.pausa) {
    exit;
}

// --- DECISÃO PRINCIPAL: QUAL O ESTADO GERAL DO JOGO? ---
if (instance_exists(o_controlador_geral) && o_controlador_geral.estado_jogo == MINIGAME.RESULTADO) {
    estado = FERRreiro_ESTADO.COMEMORANDO;
}
else if (estado == FERRreiro_ESTADO.MARTELANDO) {
    // Não faz nada aqui, o Animation End vai cuidar da transição.
}
else {
    estado = FERRreiro_ESTADO.IDLE;
}

// --- EXECUÇÃO: QUAL ANIMAÇÃO TOCAR BASEADO NO ESTADO ATUAL DO FERREIRO? ---
switch (estado) {
    
    case FERRreiro_ESTADO.IDLE:
        sprite_index = s_ferreiro_idle;
        image_speed = 0.5; // Velocidade da animação de "respiro"
        break;
        
    case FERRreiro_ESTADO.MARTELANDO:
        // A animação já foi iniciada pela função 'iniciar_martelada',
        // não precisamos fazer nada aqui.
        break;
        
    case FERRreiro_ESTADO.COMEMORANDO:
        sprite_index = s_ferreiro_win;
        image_speed = 0.2;
        break;
}