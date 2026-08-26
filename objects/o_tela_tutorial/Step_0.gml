// =================================================================
// TESTE DE TECLAS
// O jogador experimenta os quatro alvos aqui antes de valer ponto. A resposta é a
// mesma da partida — quadros enquanto a tecla está pressionada e afundamento no
// toque — para o reconhecimento ser imediato lá dentro. Sem som: aqui o ferreiro
// está atrás do escurecimento e a martelada tocaria sem martelo à vista.
// =================================================================
for (var i = 0; i < array_length(lane_acao); i++) {

    if (input_pressed(lane_acao[i])) {
        lane_afunda[i] = 5;
        lane_pop[i] = 1;
    }

    if (input_held(lane_acao[i])) {
        lane_frame[i] = min(lane_frame[i] + 1, sprite_get_number(lane_sprite[i]) - 1);
    } else {
        lane_frame[i] = 0;
    }

    lane_afunda[i] = max(0, lane_afunda[i] - 0.8);
    lane_pop[i]    = max(0, lane_pop[i] - 0.14);
}

// No Versus o tutorial tem duas etapas: primeiro o jogador 1 acha as teclas dele,
// depois o 2. Confirmar avanca de um para o outro antes de sair da tela.
if (versus_ativo() && lane_dono == 0 && input_pressed(ACAO.CONFIRMAR)) {
    o_audio_manager.play_sfx(snd_menu_confirm);
    trocar_de_jogador();
    exit;
}

if (input_pressed(ACAO.CONFIRMAR)) {
    o_audio_manager.play_sfx(snd_menu_confirm);

    // Avisa ao controlador geral que o tutorial foi visto.
    o_controlador_geral.tutorial_ja_foi_visto = true;

    // Muda o estado do jogo para a seleção de fases.
    o_controlador_geral.estado_jogo = MINIGAME.SELECAO_FASE;

    instance_destroy();
}
