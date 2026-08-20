// Se estamos no meio de um fade-out...
if (is_fading_out && musica_atual != -1) {

    var _current_gain = audio_sound_get_gain(musica_atual);
    var _new_gain = max(0, _current_gain - fade_speed);

    audio_sound_gain(musica_atual, _new_gain, 0);

    // Se o volume chegou a zero, para a música completamente
    if (_new_gain <= 0) {
        audio_stop_sound(musica_atual);
        // Devolve o ganho do asset ao normal: sem isso, tocar a mesma faixa de novo
        // resultava numa fase muda (auditoria CV-02).
        audio_sound_gain(musica_atual, 1, 0);
        musica_atual = -1;
        is_fading_out = false;
    }
}
