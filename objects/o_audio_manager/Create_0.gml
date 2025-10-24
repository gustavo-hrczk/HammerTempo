// Guarda qual música está tocando atualmente para não reiniciá-la sem necessidade
musica_atual = -1;

// --- FUNÇÃO PARA TOCAR EFEITOS SONOROS (SFX) ---
play_sfx = function(som_asset) {
    if (audio_is_playing(som_asset)) {
        audio_stop_sound(som_asset); // Para e reinicia o som se ele já estiver tocando
    }
    audio_play_sound(som_asset, 1, false); // Toca o som uma vez
}

// --- FUNÇÃO PARA TOCAR MÚSICA DE FUNDO (BGM) ---
play_music = function(musica_asset) {
    // Só troca a música se a nova for diferente da atual
    if (musica_atual != musica_asset) {
        // Para qualquer música que estivesse tocando antes
        if (musica_atual != -1) {
            audio_stop_sound(musica_atual);
        }
        
        // Toca a nova música em loop
        audio_play_sound(musica_asset, 1, true);
        musica_atual = musica_asset;
    }
}

// --- FUNÇÃO PARA PARAR TODAS AS MÚSICAS ---
stop_music = function() {
    if (musica_atual != -1) {
        audio_stop_sound(musica_atual);
        musica_atual = -1;
    }
}