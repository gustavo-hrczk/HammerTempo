// =================================================================
// TESTE DE TECLAS
// O jogador experimenta os quatro alvos aqui antes de valer ponto. A resposta é a
// mesma da partida — quadros enquanto a tecla está pressionada, afundamento no
// toque e o som da martelada — para o reconhecimento ser imediato lá dentro.
// =================================================================
for (var i = 0; i < array_length(lane_acao); i++) {

    if (input_pressed(lane_acao[i])) {
        lane_afunda[i] = 5;
        lane_pop[i] = 1;
        o_audio_manager.play_martelada_sequencial_sfx();
    }

    if (input_held(lane_acao[i])) {
        lane_frame[i] = min(lane_frame[i] + 1, sprite_get_number(lane_sprite[i]) - 1);
    } else {
        lane_frame[i] = 0;
    }

    lane_afunda[i] = max(0, lane_afunda[i] - 0.8);
    lane_pop[i]    = max(0, lane_pop[i] - 0.14);
}

if (input_pressed(ACAO.CONFIRMAR)) {
    o_audio_manager.play_sfx(snd_menu_confirm);

    // Avisa ao controlador geral que o tutorial foi visto.
    o_controlador_geral.tutorial_ja_foi_visto = true;

    // Muda o estado do jogo para a seleção de fases.
    o_controlador_geral.estado_jogo = MINIGAME.SELECAO_FASE;

    instance_destroy();
}
