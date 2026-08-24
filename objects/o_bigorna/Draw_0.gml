// A bigorna treme no impacto, com amplitude vinda da qualidade do acerto.
//
// Deslocamento INTEIRO: a arte e pixel art, e meio pixel embaralha a leitura da
// silhueta — mesma regra das fontes (D-33).
//
// O eixo vertical so desce, e pela metade da amplitude: a bigorna e golpeada de
// cima, entao afundar le como impacto e subir leria como salto.
var _dx = 0;
var _dy = 0;

if (tremor > 0) {
    var _amp = ceil(tremor);
    _dx = irandom_range(-_amp, _amp);
    _dy = irandom_range(0, max(1, round(_amp * 0.5)));
}

draw_sprite_ext(sprite_index, image_index, x + _dx, y + _dy,
                image_xscale, image_yscale, image_angle, image_blend, image_alpha);
