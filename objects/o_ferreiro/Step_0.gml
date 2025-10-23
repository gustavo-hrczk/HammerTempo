// --- LÓGICA DE PAUSA ---
if (instance_exists(o_controlador_geral) && o_controlador_geral.pausa) {
    image_speed = 0;
    exit;
}

// =================================================================
// LÓGICA DE DECISÃO DE ESTADO (VERSÃO FINAL)
// =================================================================
if (instance_exists(o_controlador_geral)) {
    
    // MASTER RESET: Se voltamos para a seleção de fase, o ferreiro volta ao normal.
    if (o_controlador_geral.estado_jogo == MINIGAME.SELECAO_FASE || o_controlador_geral.estado_jogo == MINIGAME.TUTORIAL) {
        estado = FERRreiro_ESTADO.IDLE;
    }
    // ESTADO DE RESULTADO: Decide se comemora, mas RESPEITA a falha.
    else if (o_controlador_geral.estado_jogo == MINIGAME.RESULTADO) {
        // >>> A CORREÇÃO ESTÁ AQUI <<<
        // Só muda para comemorar se ele não estiver JÁ no processo de falha.
        if (estado != FERRreiro_ESTADO.FALHA && estado != FERRreiro_ESTADO.FALHOU_ESTATICO) {
            estado = FERRreiro_ESTADO.COMEMORANDO;
        }
    }
    // ESTADO DE JOGO ATIVO: Volta para IDLE se não estiver ocupado.
    else if (estado != FERRreiro_ESTADO.MARTELANDO) {
        estado = FERRreiro_ESTADO.IDLE;
    }
}

// =================================================================
// LÓGICA DE EXECUÇÃO DE ANIMAÇÃO
// =================================================================
switch (estado) {
    case FERRreiro_ESTADO.IDLE:
        sprite_index = s_ferreiro_idle;
        image_speed = 0.5;
        break;
    case FERRreiro_ESTADO.MARTELANDO:
        // Ação em andamento
        break;
    case FERRreiro_ESTADO.COMEMORANDO:
        sprite_index = s_ferreiro_win;
        image_speed = 0.2;
        break;
    case FERRreiro_ESTADO.FALHA:
        // Animação de falha tocando
        break;
    case FERRreiro_ESTADO.FALHOU_ESTATICO:
        sprite_index = s_ferreiro_falha;
        image_index = sprite_get_number(s_ferreiro_falha) - 1; // Trava no último frame
        image_speed = 0;
        break;
}