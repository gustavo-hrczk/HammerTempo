// --- TEMPO DE ESPERA ---
// Grava o que estiver na tela e libera o gabinete. Nunca descarta: a pontuação já
// foi conquistada, e perdê-la por distração seria pior do que gravar "AAA".
espera--;
if (espera <= 0) {
    confirmar();
    exit;
}

// --- TROCA DE LETRA ---
var _v = input_eixo_v();
if (_v != 0) {
    // cima sobe no alfabeto, e o eixo devolve +1 para baixo
    var _total = string_length(PLACAR_LETRAS);
    letras[cursor] = (letras[cursor] - _v + _total) mod _total;

    var _som = o_controlador_geral.nav_sounds[o_controlador_geral.nav_sound_index];
    o_audio_manager.play_sfx(_som);
    o_controlador_geral.nav_sound_index = 1 - o_controlador_geral.nav_sound_index;
}

// --- TROCA DE POSIÇÃO ---
var _h = input_eixo_h();
if (_h != 0) {
    cursor = clamp(cursor + _h, 0, PLACAR_NOME_TAMANHO - 1);

    var _som2 = o_controlador_geral.nav_sounds[o_controlador_geral.nav_sound_index];
    o_audio_manager.play_sfx(_som2);
    o_controlador_geral.nav_sound_index = 1 - o_controlador_geral.nav_sound_index;
}

// --- CONFIRMAR ---
// Confirmar avança até a última letra e só então grava. É o comportamento de
// gabinete, e evita gravar sem querer no primeiro toque.
if (input_pressed(ACAO.CONFIRMAR)) {
    o_audio_manager.play_sfx(snd_menu_confirm);

    if (cursor < PLACAR_NOME_TAMANHO - 1) {
        cursor++;
    } else {
        confirmar();
    }
}
