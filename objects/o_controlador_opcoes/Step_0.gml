if (room != rm_opcoes) {
    exit;
}

// --- SAIR SEM APLICAR ---
// Desfaz o que estava sendo experimentado, voltando ao que está salvo.
if (input_pressed(ACAO.VOLTAR)) {
    save_aplicar_opcoes();
    o_audio_manager.play_sfx(snd_menu_return);
    room_goto(rm_menu);
    exit;
}

// --- NAVEGAÇÃO ---
var _move = input_eixo_v();
if (_move != 0) {
    opcao_selecionada += _move;

    var _som_a_tocar = o_controlador_geral.nav_sounds[o_controlador_geral.nav_sound_index];
    o_audio_manager.play_sfx(_som_a_tocar);
    o_controlador_geral.nav_sound_index = 1 - o_controlador_geral.nav_sound_index;

    var _total_opcoes = array_length(opcoes_menu);
    if (opcao_selecionada < 0) {
        opcao_selecionada = _total_opcoes - 1;
    }
    if (opcao_selecionada >= _total_opcoes) {
        opcao_selecionada = 0;
    }
}

// --- AJUSTE DO VALOR ---
var _ajuste = input_eixo_h();

switch (opcao_selecionada) {

    case 0: // Volume
        if (_ajuste != 0) {
            opcoes_volume = clamp(opcoes_volume + _ajuste, 0, 10);
            // Prévia imediata: o jogador escuta o volume enquanto ajusta.
            audio_master_gain(opcoes_volume / 10);
        }
        break;

    case 1: // Tela cheia
        if (_ajuste != 0) {
            opcoes_tela_cheia = !opcoes_tela_cheia;
        }
        break;

    case 2: // Aplicar
        if (input_pressed(ACAO.CONFIRMAR)) {
            save_set_opcao("volume", opcoes_volume);
            save_set_opcao("tela_cheia", opcoes_tela_cheia);
            save_gravar();
            save_aplicar_opcoes();

            o_audio_manager.play_sfx(snd_menu_confirm);
            room_goto(rm_menu);
        }
        break;
}
