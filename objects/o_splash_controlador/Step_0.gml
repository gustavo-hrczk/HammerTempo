// Se o timer de espera já foi iniciado e terminou...
if (timer_iniciado && timer_hold <= 0) {
    // ...pede ao gerenciador para fazer a transição para o menu.
    // Esta verificação garante que a função só seja chamada uma vez.
    if (instance_exists(o_transicao) && o_transicao.estado == FADE.IDLE) {
        o_transicao.mudar_de_sala(rm_menu);
    }
}
// Se a transição inicial (fade-in) terminou, inicia o timer.
else if (instance_exists(o_transicao) && o_transicao.estado == FADE.IDLE && !timer_iniciado) {
    timer_iniciado = true;
}

// Se o timer foi iniciado, começa a contagem regressiva.
if (timer_iniciado) {
    timer_hold--;
}