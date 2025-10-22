// Este objeto só deve se desenhar se o jogo estiver no estado RITMO.
// Agora ele verifica o estado pelo nome, não pelo número.
if (o_controlador_geral.estado_jogo == MINIGAME.RITMO) {

    // draw_self() é o comando que diz "desenhe o meu próprio sprite".
    draw_self();
}