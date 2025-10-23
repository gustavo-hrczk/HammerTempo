if (o_controlador_geral.pausa){
	exit;
}
// Se a fase já estiver no período de tolerância, não faz mais nada aqui.
if (esta_finalizando) {
    exit;
}

// --- LÓGICA DO MODO INFINITO ---
if (is_endless_mode) {
    
    dificuldade_timer--;
    
    // A cada 15 segundos, aumenta a dificuldade
    if (dificuldade_timer <= 0) {
        dificuldade_level++;
        show_debug_message("Aumentando dificuldade para o Nível: " + string(dificuldade_level));
        
        // Aumenta a velocidade das notas (com um limite)
        velocidade_das_notas = min(12, velocidade_das_notas + 0.5);
        
        // Diminui o intervalo entre as notas (com um limite)
        intervalo_min = max(20, intervalo_min - 4);
        intervalo_max = max(40, intervalo_max - 4);
        
        // A partir do nível 2, ativa todas as 4 setas
        if (dificuldade_level >= 2) {
            tipos_permitidos = 4;
        }
        
        // Reseta o timer para o próximo aumento
        dificuldade_timer = 2 * room_speed;
    }
}
// --- LÓGICA DAS FASES NORMAIS ---
else {
    minha_duracao--;
    
    // Quando o tempo da fase normal acabar...
    if (minha_duracao <= 0) {
        show_debug_message("Tempo da fase acabou! Iniciando período de tolerância...");
        esta_finalizando = true;
        alarm[1] = room_speed * 4; // Tempo de garantia
    }
}