// =================================================================
// PARTE 1: LÓGICA DE ANIMAÇÃO NORMAL
// =================================================================
if (keyboard_check(minha_tecla)) {
    if (image_index < image_number - 1) {
        image_index += 1;
    } else {
        image_index = image_number - 1;
    }
} else {
    image_index = 0;
}

// =================================================================
// PARTE 2: LÓGICA DE ACERTO (QUE AVISA A NOTA)
// =================================================================
if (keyboard_check_pressed(minha_tecla)) {

    var _nota_acertada = instance_place(x, y, o_nota_seta);

    if (_nota_acertada != noone && _nota_acertada.tipo_seta == meu_tipo) {

        // Verifica a precisão e avisa a nota para iniciar seu fade
        if (place_meeting(_nota_acertada.x, _nota_acertada.y, o_hitbox_perfeito)) {
            show_debug_message("PERFEITO!");
            o_controlador_geral.pontuacao += 100;
            // Avisa a nota para sumir com a cor BRANCA
            _nota_acertada.iniciar_fade_final(c_silver, true); 
        }
        else if (place_meeting(_nota_acertada.x, _nota_acertada.y, o_hitbox_bom)) {
            show_debug_message("BOM!");
            o_controlador_geral.pontuacao += 50;
            // Avisa a nota para sumir com a cor VERDE
            _nota_acertada.iniciar_fade_final(c_lime, true); 
        }
    }
}