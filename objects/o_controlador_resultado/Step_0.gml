// Com a entrada de iniciais aberta, ela e quem responde ao input.
if (instance_exists(o_tela_nome)) {
    exit;
}

// =================================================================
// REVELACAO
// =================================================================
if (!revelacao_pronta) {
    tempo += 1 / room_speed;

    // A contagem sobe com desaceleracao: rapida no comeco, assentando no fim. Uma
    // contagem linear parece uma barra de carregamento; esta parece um placar.
    if (tempo >= RESULTADO_T_CONTAGEM) {
        var _prog = min(1, (tempo - RESULTADO_T_CONTAGEM) / RESULTADO_DUR_CONTAGEM);
        var _suave = 1 - power(1 - _prog, 3);
        pontuacao_exibida = round(pontuacao_base * _suave);
    }

    // os bonus entram somados ao total, um de cada vez
    if (tempo >= RESULTADO_T_BONUS_1) pontuacao_exibida = pontuacao_base + bonus_sem_erro;
    if (tempo >= RESULTADO_T_BONUS_2) pontuacao_exibida = pontuacao_final;

    if (tempo >= RESULTADO_T_PROMPT) {
        revelacao_pronta = true;
    }
}

if (!input_pressed(ACAO.CONFIRMAR)) {
    exit;
}

// --- CONFIRMAR CORTA A ANIMACAO ---
// Numa feira com fila, esperar animacao e imposto. O primeiro toque termina a
// revelacao; o segundo e que sai da tela.
if (!revelacao_pronta) {
    concluir_revelacao();
    o_audio_manager.play_sfx(snd_menu_confirm);
    exit;
}

o_audio_manager.play_sfx(snd_menu_confirm);

// =================================================================
// INICIAIS, SO AGORA
// A tela de iniciais nascia no Create e cobria o resultado antes de o jogador ver a
// propria pontuacao. Agora ela vem depois da revelacao, e so se a pontuacao — JA com
// os bonus somados — entrar no top 10.
//
// Fase perdida nao entra, pelo mesmo motivo do recorde (D-67).
// =================================================================
if (!pediu_iniciais
    && !o_controlador_geral.fase_falhou
    && placar_posicao(o_controlador_geral.fase_atual, pontuacao_final) > 0) {

    pediu_iniciais = true;
    instance_create_depth(0, 0, -9000, o_tela_nome);
    exit;
}

// --- SAIDA ---
audio_stop_sound(snd_resultado_bom);
audio_stop_sound(snd_resultado_ruim);

o_controlador_geral.estado_jogo = MINIGAME.SELECAO_FASE;
o_controlador_geral.resetar_estatisticas();

instance_destroy();
ir_para_sala(rm_forja);
