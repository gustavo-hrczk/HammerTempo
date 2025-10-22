// Este objeto só deve se desenhar se o jogo estiver no estado RITMO.
// Lembre-se: 2 é o valor de MINIGAME.RITMO no seu enum.
if (o_controlador_geral.estado_jogo == 2) {

    // draw_self() é o comando que diz "desenhe o meu próprio sprite".
    draw_self();
}