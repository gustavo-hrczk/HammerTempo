// =================================================================
// PAUSA — precisa vir antes de tudo, porque congela o resto do evento
// =================================================================
if (pausa) {

    // Contagem de retomada em andamento: nada de input, só esperar.
    if (retomada_timer > 0) {
        retomada_timer--;
        if (retomada_timer <= 0) { concluir_retomada(); }
        exit;
    }

    var _mv = input_eixo_v();
    if (_mv != 0) {
        var _total = array_length(pausa_opcoes_agora());
        pausa_opcao = (pausa_opcao + _mv + _total) mod _total;
        o_audio_manager.play_sfx(nav_sounds[nav_sound_index]);
        nav_sound_index = 1 - nav_sound_index;
    }

    // O mesmo botão que pausou também despausa. A ordem importa: esta checagem
    // vem antes da de entrar em pausa, então um toque só nunca faz as duas coisas.
    if (input_pressed(ACAO.PAUSAR)) {
        o_audio_manager.play_sfx(snd_menu_return);
        retomar_partida();
    }
    else if (input_pressed(ACAO.CONFIRMAR)) {
        o_audio_manager.play_sfx(snd_menu_confirm);
        pausa_executar(pausa_opcao);
    }

    exit; // pausado: nada mais roda
}

// Entrar em pausa só faz sentido com a partida em andamento e ainda não perdida.
//
// O intervalo do Arcade também bloqueia: o estado ainda é RITMO enquanto ele está
// aberto, e sem isto o jogador empilharia o menu de pausa por cima do de intervalo,
// com os dois respondendo ao mesmo direcional.
if (estado_jogo == MINIGAME.RITMO && !fase_falhou
    && !instance_exists(o_tela_intervalo)
    && input_pressed(ACAO.PAUSAR)) {
    o_audio_manager.play_sfx(snd_menu_confirm);
    pausar_partida();
    exit;
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

            // O tema do menu sai suave durante os 3 s de contagem, em vez de ser
            // cortado quando a fase começa.
            o_audio_manager.fade_out_music(2.2);
            break;

        case MINIGAME.SELECAO_FASE:
            o_audio_manager.play_music_crossfade(snd_tema, 0.6);
            break;

        case MINIGAME.RESULTADO:
            // Rede de segurança: nada de gameplay sobrevive à tela de resultado,
            // seja o fim normal da fase ou a derrota.
            if (instance_exists(o_spawner_ritmo)) { instance_destroy(o_spawner_ritmo); }
            instance_destroy(o_nota_seta);
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
            // O Versus reaproveita esta sala e reposiciona os dois lados. Feito aqui,
            // no estado que antecede a partida, para a cena ja estar montada quando a
            // contagem comecar.
            versus_montar_cena();
            versus_revelar_cena();

            // Fora do Versus, a cena inteira passa a pertencer a quem esta jogando —
            // o que so muda alguma coisa quando o jogador 2 comeca a partida sozinho.
            if (!versus_ativo()) solo_adotar_dono(solo_dono);

            // No Arcade o seletor de armas nao existe: o percurso e a lista inteira,
            // em ordem, e comeca na primeira. Os dois modos entram por este mesmo
            // estado justamente para a contagem so comecar com a sala ja montada.
            if (modo_jogo == MODO.ARCADE) {
                arcade_iniciar_percurso();
            } else if (!instance_exists(o_seletor_fases)) {
                instance_create_layer(0, 0, "Gameplay", o_seletor_fases);
            }
        }
        break;

    case MINIGAME.CONTAGEM:
        // o par do jogador 2 continua ganhando corpo durante a contagem
        versus_revelar_cena();

        if (contagem_timer > 0) {
            contagem_timer--;
        } else {
            estado_jogo = MINIGAME.RITMO;
        }
        break;

    case MINIGAME.RITMO:
        hud_update();

        // Garante que o spawner seja criado apenas uma vez.
        // A checagem de fase_falhou é essencial: no game over o estado continua
        // sendo RITMO durante o respiro, e sem ela o spawner destruído voltava no
        // frame seguinte, gerando notas por cima da tela de resultado.
        if (room == rm_forja && !fase_falhou && !instance_exists(o_spawner_ritmo)) {
            show_debug_message("Iniciando minigame de ritmo para a fase: " + fases_data[fase_atual].nome);
            var _spawn_x = room_width + 120;
            instance_create_layer(_spawn_x, 0, "Gameplay", o_spawner_ritmo);
        }

        // Lógica de Fim de Jogo por notas perdidas em sequência.
        // Toques inválidos não encerram mais a partida (auditoria GP-04): eles só
        // custam pontos, para não expulsar quem está experimentando o jogo.
        // A primeira fase do percurso Arcade nao expulsa ninguem: ela E a rampa de
        // aprendizado. A Adaga falha com 4 notas perdidas seguidas, o que a 2,25
        // notas/s sao 1,8 segundo sem acertar nada — quem nunca jogou seria ejetado
        // em vinte segundos, sem ter jogado.
        //
        // No VERSUS ninguem perde por falha: a partida e uma disputa entre os dois, e
        // encerra-la porque UM deles errou demais tiraria o outro do jogo junto. Quem
        // decide o Versus e a comparacao no fim, nao a sobrevivencia.
        if (!fase_falhou && !arcade_fase_imune() && !versus_ativo()
            && jogador().stats_sequencia_errada >= fases_data[fase_atual].stats_limite_sequencia_errada) {
            show_debug_message("Game Over por excesso de notas perdidas!");

            fase_falhou = true;
            falha_timer = room_speed * 1.6;

            // Para de gerar notas e manda as que estão na tela saírem de cena sem
            // virarem erro — elas não são culpa do jogador.
            if (instance_exists(o_spawner_ritmo)) { instance_destroy(o_spawner_ritmo); }
            with (o_nota_seta) { sumir(); }

            // A derrota já acontece aqui, durante o respiro: o ferreiro reage e a
            // música sai em fade, em vez de a fase ser cortada em seco.
            with (o_ferreiro) iniciar_animacao_falha();
            o_audio_manager.fade_out_music(1.4);
        }

        // Respiro entre a derrota e a tela de resultado.
        if (fase_falhou) {
            falha_timer--;
            if (falha_timer <= 0) {
                // estado_anterior NÃO é definido aqui de propósito: é a virada de
                // estado que dispara a limpeza do gameplay, no bloco de transições.
                estado_jogo = MINIGAME.RESULTADO;
                instance_create_layer(0, 0, "Gameplay", o_controlador_resultado);
            }
        }
        break;

    case MINIGAME.RESULTADO:
        // O o_controlador_resultado agora gerencia o que acontece.
        // O controlador geral apenas espera.
        break;
}
