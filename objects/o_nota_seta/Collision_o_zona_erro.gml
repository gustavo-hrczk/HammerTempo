if (o_controlador_geral.pausa){
	exit;
}
// Só executa a lógica de erro se a nota já não estiver morrendo.
if (esta_morrendo == false) {
    
    // Incrementa o contador de erros.
    o_controlador_geral.stats_erros++;
    
    // >>> A NOVA LÓGICA ESTÁ AQUI <<<
    // Deduz 50 pontos da pontuação total.
    o_controlador_geral.pontuacao -= 50;
    
    // Inicia o fade-out (passando 'false' para não subir).
    iniciar_fade_final(c_red, false);
    
	o_controlador_geral.stats_sequencia_errada++;
	o_controlador_geral.stats_sequencia=0;
}