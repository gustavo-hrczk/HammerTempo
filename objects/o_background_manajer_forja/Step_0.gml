// Gerencia os estados de transição
if (o_controlador_geral.pausa){
	exit;
}
switch (state) {
    // ESTADO 0: Estável, aguardando o tempo para a próxima transição
    case 0:
        transition_timer--;
        if (transition_timer <= 0) {
            state = 1; // Inicia a transição
            transition_progress = 0;
            
            // Define o próximo cenário (dando a volta no final da lista)
            next_set_index = (current_set_index + 1) % total_sets;
        }
    break;
    
    // ESTADO 1: Em transição
    case 1:
        transition_progress++;
        if (transition_progress >= transition_duration) {
            state = 0; // Finaliza a transição
            
            // O próximo cenário se torna o atual
            current_set_index = next_set_index;
            
            // Sincroniza as posições X para evitar saltos visuais
            for (var i = 0; i < max_layers; i++) {
                layer_x_current[i] = layer_x_next[i];
            }
            
            // Reseta o temporizador
            transition_timer = time_between_changes;
        }
    break;
}