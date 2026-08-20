if (pausa) {
    exit; // Se estiver pausado, para a execução do resto do evento
}

// =================================================================
// TRANSIÇÕES DE ESTADO — o que acontece uma única vez, na virada
// =================================================================
if (estado_jogo != estado_anterior) {

    switch (estado_jogo) {

        case MINIGAME.CONTAGEM:
            // A música NÃO começa aqui. Enquanto o mapa rítmico não for derivado do
            // próprio áudio (Sprint 5), o alinhamento entre notas e música depende do
            // instante exato em que a faixa começa — que é a criação do spawner.
            // Adiantar a música para a contagem deslocava tudo em 3 segundos.
            hud_resetar();
            break;

        case MINIGAME.SELECAO_FASE:
            o_audio_manager.play_music_crossfade(snd_tema, 0.6);
            break;
    }

    estado_anterior = estado_jogo;
}

// =================================================================
// COMPORTAMENTO CONTÍNUO DE CADA ESTADO
// =================================================================
switch (estado_jogo) {

    case MINIGAME.TUTORIAL:
        // Só cria depois de a sala da forja estar carregada: com o fade de 250 ms o
        // estado muda antes da sala, e a camada "Gameplay" ainda não existe no menu.
        if (room == rm_forja && !instance_exists(o_tela_tutorial)) {
            instance_create_layer(0, 0, "Gameplay", o_tela_tutorial);
        }
        break;

    case MINIGAME.SELECAO_FASE:
        // Só cria o seletor se estivermos na sala da forja.
        if (room == rm_forja) {
            if (!instance_exists(o_seletor_fases)) {
                instance_create_layer(0, 0, "Gameplay", o_seletor_fases);
            }
        }
        break;

    case MINIGAME.CONTAGEM:
        if (contagem_timer > 0) {
            contagem_timer--;
        } else {
            estado_jogo = MINIGAME.RITMO;
        }
        break;

    case MINIGAME.RITMO:
        hud_update();

        // Garante que o spawner seja criado apenas uma vez.
        if (room == rm_forja && !instance_exists(o_spawner_ritmo)) {
            show_debug_message("Iniciando minigame de ritmo para a fase: " + fases_data[fase_atual].nome);
            var _spawn_x = room_width + 120;
            instance_create_layer(_spawn_x, 0, "Gameplay", o_spawner_ritmo);
        }

        // Lógica de Fim de Jogo por notas perdidas em sequência.
        // Toques inválidos não encerram mais a partida (auditoria GP-04): eles só
        // custam pontos, para não expulsar quem está experimentando o jogo.
        if (stats_sequencia_errada >= fases_data[fase_atual].stats_limite_sequencia_errada) {
            show_debug_message("Game Over por excesso de notas perdidas!");

            estado_jogo = MINIGAME.RESULTADO;
            estado_anterior = MINIGAME.RESULTADO;

            // Limpa a "bagunça" do minigame
            if (instance_exists(o_spawner_ritmo)) { instance_destroy(o_spawner_ritmo); }
            instance_destroy(o_nota_seta);

            // Cria o objeto da tela de resultado
            instance_create_layer(0, 0, "Gameplay", o_controlador_resultado);
        }
        break;

    case MINIGAME.RESULTADO:
        // O o_controlador_resultado agora gerencia o que acontece.
        // O controlador geral apenas espera.
        break;
}
