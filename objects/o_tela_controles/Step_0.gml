if (fluxo_ocupado()) {
    exit;
}

// =================================================================
// CAPTURA
// Enquanto espera o controle novo, esta tela lê o teclado e o gamepad CRUS, sem
// passar por input_pressed(): a pergunta aqui é "qual botão foi apertado", não
// "qual ação foi acionada" — e a ação que responde a ele é justamente o que está
// sendo trocado.
// =================================================================
if (capturando) {

    // ESC cancela, e por isso não pode ser vinculado. É a única tecla reservada.
    if (keyboard_check_pressed(vk_escape)) {
        capturando = false;
        o_audio_manager.play_sfx(snd_menu_return);
        exit;
    }

    if (keyboard_check_pressed(vk_anykey)) {

        // Setas e ESC são recusadas: as setas já acionam as faixas em caráter fixo,
        // e vinculá-las a outra ação faria uma tecla disparar duas faixas ao mesmo
        // tempo. Recusa e continua esperando, em vez de cancelar.
        if (input_tecla_reservada(keyboard_lastkey)) {
            o_audio_manager.play_sfx(snd_menu_return);
            exit;
        }

        input_definir_tecla(acoes[opcao_selecionada], keyboard_lastkey);
        capturando = false;
        o_audio_manager.play_sfx(snd_menu_confirm);
        exit;
    }

    var _botao = input_botao_pressionado();
    if (_botao >= 0) {
        input_definir_botao(acoes[opcao_selecionada], _botao);
        capturando = false;
        o_audio_manager.play_sfx(snd_menu_confirm);
    }

    exit;
}

// --- SAIR ---
// ESC fecha SEMPRE, por fora do vínculo. VOLTAR também é remapeável, e sem esta
// saída fixa um vínculo infeliz trancaria o jogador justamente na tela que
// conserta vínculos infelizes.
if (keyboard_check_pressed(vk_escape) || input_pressed(ACAO.VOLTAR)) {
    o_audio_manager.play_sfx(snd_menu_return);
    instance_destroy();
    exit;
}

// --- NAVEGAÇÃO ---
// LADOS trocam de pagina, como na tela de recordes. Fora da captura: durante ela o
// teclado inteiro esta sendo lido para o vinculo novo.
var _h = input_eixo_h();
if (_h != 0) {
    o_audio_manager.play_sfx(o_controlador_geral.nav_sounds[o_controlador_geral.nav_sound_index]);
    o_controlador_geral.nav_sound_index = 1 - o_controlador_geral.nav_sound_index;
    ir_para_pagina(pagina + _h);
    exit;
}

var _move = input_eixo_v();
if (_move != 0) {
    opcao_selecionada += _move;

    var _som = o_controlador_geral.nav_sounds[o_controlador_geral.nav_sound_index];
    o_audio_manager.play_sfx(_som);
    o_controlador_geral.nav_sound_index = 1 - o_controlador_geral.nav_sound_index;

    if (opcao_selecionada < 0)             { opcao_selecionada = total_linhas - 1; }
    if (opcao_selecionada >= total_linhas) { opcao_selecionada = 0; }
}

// --- CONFIRMAR ---
if (input_pressed(ACAO.CONFIRMAR)) {

    if (opcao_selecionada == LINHA_RESTAURAR) {
        input_restaurar_padrao();
        o_audio_manager.play_sfx(snd_menu_confirm);
    } else {
        // Sai já: a tecla que confirmou ainda conta como pressionada neste frame e
        // seria capturada como o vínculo novo.
        capturando = true;
        o_audio_manager.play_sfx(snd_menu_confirm);
        exit;
    }
}
