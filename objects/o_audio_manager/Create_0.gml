// Guarda de instância única (auditoria CV-01)
if (instance_number(object_index) > 1) {
    instance_destroy();
    exit;
}

musica_atual = -1;
is_fading_out = false;
fade_speed = 0;

// --- CROSSFADE ---
musica_saindo = -1;
saindo_speed = 0;
entrando = false;
entrando_speed = 0;

// --- FUNÇÕES DE ÁUDIO ---

play_sfx = function(som_asset, _ganho = 1) {
    if (audio_is_playing(som_asset)) { audio_stop_sound(som_asset); }
    audio_sound_gain(som_asset, _ganho, 0);
    audio_play_sound(som_asset, 1, false);
}

/// Toca uma música em loop, com corte seco.
/// A versão anterior (auditoria CV-02) desistia quando a faixa já estava tocando com
/// ganho 0 — o que deixava a fase muda ao ser rejogada.
play_music = function(musica_asset) {
    if (musica_atual == musica_asset && audio_is_playing(musica_asset) && !is_fading_out) {
        audio_sound_gain(musica_asset, 1, 0);
        return;
    }

    if (musica_atual != -1) { audio_stop_sound(musica_atual); }
    if (audio_is_playing(musica_asset)) { audio_stop_sound(musica_asset); }

    audio_sound_gain(musica_asset, 1, 0);
    audio_play_sound(musica_asset, 1, true);

    musica_atual = musica_asset;
    is_fading_out = false;
    entrando = false;
}

/// Troca de música com crossfade: a atual sai enquanto a nova entra.
/// É o que evita o corte seco do tema quando a fase começa (auditoria CV-03).
play_music_crossfade = function(musica_asset, duracao_segundos = 0.5) {
    if (musica_atual == musica_asset && audio_is_playing(musica_asset) && !is_fading_out) {
        return;
    }

    var _frames = max(1, duracao_segundos * room_speed);

    // a faixa atual passa a sair de cena
    if (musica_atual != -1 && audio_is_playing(musica_atual) && musica_atual != musica_asset) {
        musica_saindo = musica_atual;
        saindo_speed = audio_sound_get_gain(musica_saindo) / _frames;
    }

    if (audio_is_playing(musica_asset)) { audio_stop_sound(musica_asset); }

    audio_sound_gain(musica_asset, 0, 0);
    audio_play_sound(musica_asset, 1, true);

    musica_atual = musica_asset;
    entrando = true;
    entrando_speed = 1 / _frames;
    is_fading_out = false;
}

stop_music = function() {
    if (musica_atual != -1) {
        audio_stop_sound(musica_atual);
        audio_sound_gain(musica_atual, 1, 0); // deixa o asset pronto para a próxima vez
        musica_atual = -1;
    }
    is_fading_out = false;
    entrando = false;
}

fade_out_music = function(duracao_segundos) {
    if (musica_atual != -1 && !is_fading_out) {
        is_fading_out = true;
        entrando = false;
        var _current_gain = audio_sound_get_gain(musica_atual);
        fade_speed = _current_gain / max(1, duracao_segundos * room_speed);
    }
}

// =================================================================
// --- SEQUENCIADOR DE MARTELADA ---
// =================================================================

sons_martelada = [
    snd_martelada_01,
    snd_martelada_02,
    snd_martelada_03,
    snd_martelada_04,
    snd_martelada_05
];

martelada_index_atual = 0;
martelada_direcao = 1;

// As amostras de martelada estão em ~-11 dBFS RMS, bem mais quentes que as faixas
// das fases, e encobriam a música. 0,32 equivale a -9,9 dB, que é o suficiente para
// derrubar o volume aparente pela metade — 0,55 (-5,2 dB) mal era perceptível.
// Ponto único de ajuste até existirem volumes separados de música e efeitos.
ganho_martelada = 0.32;

// Toca os sons de martelada em vai-e-vem, dando variação a cada acerto.
// Variação de pitch foi testada e descartada: descaracterizava o som da martelada.
play_martelada_sequencial_sfx = function() {
    play_sfx(sons_martelada[martelada_index_atual], ganho_martelada);

    if (martelada_direcao == 1) {
        if (martelada_index_atual >= array_length(sons_martelada) - 1) {
            martelada_direcao = -1;
        }
    } else {
        if (martelada_index_atual <= 0) {
            martelada_direcao = 1;
        }
    }

    martelada_index_atual += martelada_direcao;
}
