if (fluxo_ocupado()) {
    exit;
}

// ESC fecha sempre, por fora do vinculo, pelo mesmo motivo da tela de controles.
if (keyboard_check_pressed(vk_escape) || input_pressed(ACAO.VOLTAR)) {
    o_audio_manager.play_sfx(snd_menu_return);
    instance_destroy();
    exit;
}

// --- TROCA DE PAGINA ---
var _h = input_eixo_h();
if (_h != 0 && total_paginas > 1) {
    pagina = (pagina + _h + total_paginas) mod total_paginas;

    var _som = o_controlador_geral.nav_sounds[o_controlador_geral.nav_sound_index];
    o_audio_manager.play_sfx(_som);
    o_controlador_geral.nav_sound_index = 1 - o_controlador_geral.nav_sound_index;
}
