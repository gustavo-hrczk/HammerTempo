musica_atual = -1;
is_fading_out = false;
fade_speed = 0;

// --- FUNÇÕES DE ÁUDIO ---
play_sfx = function(som_asset) {
    if (audio_is_playing(som_asset)) { audio_stop_sound(som_asset); }
    audio_play_sound(som_asset, 1, false);
}
play_music = function(musica_asset) {
    if (musica_atual != musica_asset) {
        if (musica_atual != -1) { audio_stop_sound(musica_atual); }
        audio_play_sound(musica_asset, 1, true);
        musica_atual = musica_asset;
        is_fading_out = false;
    }
}
stop_music = function() {
    if (musica_atual != -1) {
        audio_stop_sound(musica_atual);
        musica_atual = -1;
    }
}
fade_out_music = function(duracao_segundos) {
    if (musica_atual != -1 && !is_fading_out) {
        is_fading_out = true;
        var _current_gain = audio_sound_get_gain(musica_atual);
        fade_speed = _current_gain / (duracao_segundos * room_speed);
    }
}

// =================================================================
// --- LÓGICA DO SEQUENCIADOR DE MARTELADA ---
// =================================================================

// 1. O catálogo de sons, em ordem
sons_martelada = [
    snd_martelada_01,
    snd_martelada_02,
    snd_martelada_03,
    snd_martelada_04,
    snd_martelada_05
];

// 2. Variáveis de controle da sequência
martelada_index_atual = 0;
martelada_direcao = 1;

// 3. A função que toca o som em sequência
play_martelada_sequencial_sfx = function() {
    
    // >>> A CORREÇÃO ESTÁ AQUI <<<
    // Agora usa o nome correto do array: 'sons_martelada'
    var _som_para_tocar = sons_martelada[martelada_index_atual];
    
    // Toca o som
    play_sfx(_som_para_tocar);
    
    // --- ATUALIZA O ÍNDICE PARA A PRÓXIMA BATIDA ---
    if (martelada_direcao == 1) {
        if (martelada_index_atual >= array_length(sons_martelada) - 1) {
            martelada_direcao = -1;
        }
    }
    else {
        if (martelada_index_atual <= 0) {
            martelada_direcao = 1;
        }
    }
    
    martelada_index_atual += martelada_direcao;
}

sons_martelada = [snd_martelada_01, snd_martelada_02, snd_martelada_03, snd_martelada_04, snd_martelada_05];