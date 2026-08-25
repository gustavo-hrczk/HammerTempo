// Com a entrada de iniciais aberta, ela e quem responde ao input.
if (instance_exists(o_tela_nome)) {
    exit;
}

// =================================================================
// REVELACAO
// =================================================================
if (!revelacao_pronta) {
    tempo += 1 / room_speed;

    // A contagem parte devagar, ganha corpo no meio e assenta no fim.
    //
    // A curva anterior era desaceleracao cubica, que entrega 87% do numero na
    // primeira METADE do tempo — dai a sensacao de contagem apressada seguida de
    // arrasto. Esta e simetrica (smoothstep): 50% do numero em 50% do tempo, com
    // partida e chegada macias. Le como um placar girando, nao como carregamento.
    var _n_fileira = array_length(fileira);

    if (_n_fileira > 0) {
        // ARCADE: o contador segue a FILEIRA. Cada arma que se monta soma a propria
        // pontuacao ao numero, entao o jogador ve de onde veio cada pedaco do total.
        // Uma contagem continua correndo por cima da fileira seriam duas animacoes
        // dizendo a mesma coisa em ritmos diferentes.
        var _soma = 0;
        for (var i = 0; i < _n_fileira; i++) {
            if (tempo >= RESULTADO_T_CONTAGEM + (i * RESULTADO_GAP_FILEIRA)) {
                _soma += fileira[i].pontos;
            }
        }
        pontuacao_exibida = _soma;

    } else {
        if (tempo >= RESULTADO_T_CONTAGEM) {
            var _prog = min(1, (tempo - RESULTADO_T_CONTAGEM) / RESULTADO_DUR_CONTAGEM);
            var _suave = _prog * _prog * (3 - 2 * _prog);
            pontuacao_exibida = round(pontuacao_base * _suave);
        }

        // os bonus entram somados ao total, um de cada vez
        if (tempo >= RESULTADO_T_BONUS_1) pontuacao_exibida = pontuacao_base + bonus_sem_erro;
        if (tempo >= RESULTADO_T_BONUS_2) pontuacao_exibida = pontuacao_final;
    }

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
// O placar POR FASE nao serve para o Arcade: pontuacao_final ali e o total do
// percurso inteiro, e grava-lo no recorde da ultima arma corromperia a tabela do Modo
// Livre com um numero de outra natureza. O ranking do Arcade e uma frente propria
// (leaderboard.arcade, ja reservado no save) e entra em seguida.
if (!pediu_iniciais
    && o_controlador_geral.modo_jogo != MODO.ARCADE
    && !o_controlador_geral.fase_falhou
    && placar_posicao(o_controlador_geral.fase_atual, pontuacao_final) > 0) {

    pediu_iniciais = true;
    instance_create_depth(0, 0, -9000, o_tela_nome);
    exit;
}

// --- SAIDA ---
audio_stop_sound(snd_resultado_bom);
audio_stop_sound(snd_resultado_ruim);

// PENDENTE (frente 2): no Arcade daqui sai o encadeamento — somar a pontuacao em
// arcade_pontos, avancar arcade_indice e emendar a proxima fase sem passar por esta
// tela. Ate la o percurso termina aqui e volta ao menu, que e o comportamento SEGURO:
// mandar SELECAO_FASE no Arcade reiniciaria o percurso num laco.
if (o_controlador_geral.modo_jogo == MODO.ARCADE) {
    o_controlador_geral.modo_jogo = MODO.LIVRE;
    o_controlador_geral.estado_jogo = MINIGAME.NENHUM;
    o_controlador_geral.resetar_estatisticas();

    instance_destroy();
    ir_para_sala(rm_menu);
    exit;
}

o_controlador_geral.estado_jogo = MINIGAME.SELECAO_FASE;
o_controlador_geral.resetar_estatisticas();

instance_destroy();
ir_para_sala(rm_forja);
