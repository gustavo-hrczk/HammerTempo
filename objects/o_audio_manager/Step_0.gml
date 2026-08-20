// --- FAIXA SAINDO DE CENA (crossfade) ---
if (musica_saindo != -1) {
    var _gain_saindo = max(0, audio_sound_get_gain(musica_saindo) - saindo_speed);
    audio_sound_gain(musica_saindo, _gain_saindo, 0);

    if (_gain_saindo <= 0) {
        audio_stop_sound(musica_saindo);
        // devolve o ganho do asset ao normal: sem isso, tocar a mesma faixa de novo
        // resultava numa fase muda (auditoria CV-02).
        audio_sound_gain(musica_saindo, 1, 0);
        musica_saindo = -1;
    }
}

// --- FAIXA ENTRANDO (crossfade) ---
if (entrando && musica_atual != -1) {
    var _gain_entrando = min(1, audio_sound_get_gain(musica_atual) + entrando_speed);
    audio_sound_gain(musica_atual, _gain_entrando, 0);

    if (_gain_entrando >= 1) {
        entrando = false;
    }
}

// --- FADE-OUT SIMPLES ---
if (is_fading_out && musica_atual != -1) {

    var _current_gain = audio_sound_get_gain(musica_atual);
    var _new_gain = max(0, _current_gain - fade_speed);

    audio_sound_gain(musica_atual, _new_gain, 0);

    if (_new_gain <= 0) {
        audio_stop_sound(musica_atual);
        audio_sound_gain(musica_atual, 1, 0);
        musica_atual = -1;
        is_fading_out = false;
    }
}
