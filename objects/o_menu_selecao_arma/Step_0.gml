// Este menu só deve aceitar comandos se o jogo estiver no estado "NENHUM"
if (o_controlador_geral.estado_jogo != MINIGAME.NENHUM) {
    exit;
}

// Se o jogador apertar "1" para forjar a adaga
if (keyboard_check_pressed(ord("1"))) {
    o_controlador_geral.fase_atual = 1;
    o_controlador_geral.estado_jogo = MINIGAME.RITMO;
    // O menu vai parar de ser desenhado e o minigame pode começar
}