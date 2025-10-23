// --- DECISÃO PRINCIPAL: QUAL O ESTADO GERAL DO JOGO? ---

// Se o jogo está na tela de resultado...
if (instance_exists(o_controlador_geral) && o_controlador_geral.estado_jogo == MINIGAME.RESULTADO) {
    // ...força o ferreiro a entrar no estado de comemoração.
    estado = FERRreiro_ESTADO.COMEMORANDO;
}
// Se não estamos no resultado, mas o ferreiro está martelando, deixa ele terminar.
else if (estado == FERRreiro_ESTADO.MARTELANDO) {
    // Não faz nada aqui, o Animation End vai cuidar da transição.
}
// Para qualquer outro caso (Seleção de fase, Contagem, etc.)...
else {
    // ...o ferreiro deve ficar no estado de "parado".
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
        image_speed = 0.2; // 5 FPS (5 frames / 60 frames por segundo do jogo = ~0.08, mas 0.2 fica bom)
        break;
}