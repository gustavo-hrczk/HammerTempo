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

show_debug_message("Fase Concluída! Mostrando resultados...");

o_controlador_geral.estado_jogo = MINIGAME.RESULTADO;
instance_create_layer(0, 0, "Gameplay", o_controlador_resultado);

instance_destroy();
