// Se estamos no meio de um fade-out...
if (is_fading_out && musica_atual != -1) {
    
    // Pega o volume atual
    var _current_gain = audio_sound_get_gain(musica_atual);
    
    // Calcula o novo volume, garantindo que não seja menor que 0
    var _new_gain = max(0, _current_gain - fade_speed);
    
    // Aplica o novo volume
    audio_sound_gain(musica_atual, _new_gain, 0);
    
    // Se o volume chegou a zero, para a música completamente
    if (_new_gain == 0) {
        audio_stop_sound(musica_atual);
        musica_atual = -1;
        is_fading_out = false;
    }
}