if (o_controlador_geral.pausa) {
    alarm[1] = 10;
    exit;
}

// Ainda há notas na tela: continua esperando.
if (instance_exists(o_nota_seta)) {
    alarm[1] = 10;
    exit;
}

// Última nota resolvida. Antes de mostrar o resultado, dá um respiro de ~1,8 s:
// o corte imediato ficava seco demais.
if (!esperando_respiro) {
    esperando_respiro = true;
    alarm[1] = room_speed * 1.8;
    o_audio_manager.fade_out_music(1.8);
    exit;
}

// No Arcade, entre uma arma e a proxima vem o INTERVALO: o total ate aqui e a escolha
// de seguir ou encerrar. O percurso completo leva quase seis minutos, e quem nao esta
// gostando nao deve precisar perder a partida de proposito para sair.
//
// Quem escolhe seguir cai em arcade_avancar, que emenda a proxima fase pela contagem —
// sem passar pela tela de resultado, que custaria ~5,5 s por fase.
if (o_controlador_geral.arcade_tem_proxima()) {
    show_debug_message("Percurso Arcade: intervalo entre fases.");
    instance_create_depth(0, 0, -9000, o_tela_intervalo);
    instance_destroy();
    exit;
}

// O Versus tem tela propria: a do modo de um jogador conta UMA historia — quanto voce
// forjou — e e construida em volta de uma arma so, um bonus so e um recorde.
if (versus_ativo()) {
    show_debug_message("Versus concluido.");
    o_controlador_geral.estado_jogo = MINIGAME.RESULTADO;
    instance_create_depth(0, 0, -9000, o_resultado_versus);
    instance_destroy();
    exit;
}

show_debug_message("Fase Concluída! Mostrando resultados...");

o_controlador_geral.estado_jogo = MINIGAME.RESULTADO;
instance_create_layer(0, 0, "Gameplay", o_controlador_resultado);

instance_destroy();
