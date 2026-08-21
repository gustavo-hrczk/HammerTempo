if (room != rm_opcoes || fluxo_ocupado()) {
    exit;
}

// --- SAIR SEM APLICAR ---
// Desfaz o que estava sendo experimentado, voltando ao que está salvo.
if (input_pressed(ACAO.VOLTAR)) {
    save_aplicar_opcoes();
    o_audio_manager.play_sfx(snd_menu_return);
    ir_para_sala(rm_menu, 0, false);
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

    case 0: // Volume da música
        if (_ajuste != 0) {
            opcoes_musica = clamp(opcoes_musica + _ajuste, 0, 10);
            previa_audio();
        }
        break;

    case 1: // Volume dos efeitos
        if (_ajuste != 0) {
            opcoes_sfx = clamp(opcoes_sfx + _ajuste, 0, 10);
            previa_audio();
            // toca uma martelada como amostra: efeito sem referência sonora não
            // dá para ajustar de ouvido
            o_audio_manager.play_martelada_sequencial_sfx();
        }
        break;

    case 2: // Tamanho da janela
        if (_ajuste != 0) {
            var _total = array_length(JANELA_TAMANHOS);
            opcoes_janela = (opcoes_janela + _ajuste + _total) mod _total;
        }
        break;

    case 3: // Tela cheia
        if (_ajuste != 0) {
            opcoes_tela_cheia = !opcoes_tela_cheia;
        }
        break;

    case 4: // Aplicar
        if (input_pressed(ACAO.CONFIRMAR)) {
            save_set_opcao("volume_musica", opcoes_musica);
            save_set_opcao("volume_sfx", opcoes_sfx);
            save_set_opcao("janela", opcoes_janela);
            save_set_opcao("tela_cheia", opcoes_tela_cheia);
            save_gravar();
            save_aplicar_opcoes();

            o_audio_manager.play_sfx(snd_menu_confirm);
            ir_para_sala(rm_menu, 0, false);
        }
        break;
}
