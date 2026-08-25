if (!instance_exists(o_controlador_geral) || o_controlador_geral.estado_jogo != MINIGAME.RITMO) {
    exit;
}

// O alvo afunda quando pressionado e acende ao acertar.
//
// A amplitude do pop dobrou (0,11 -> 0,22) porque a diferença entre os três acertos
// era invisível: Bom ficava em 1,06 de escala e Perfeito em 1,11, cinco por cento que
// ninguém enxerga no meio da partida. Agora vai de 1,06 a 1,22.
var _s = 1 + (pop * 0.22);
var _w = sprite_get_width(sprite_index);
var _h = sprite_get_height(sprite_index);

var _dx = x + (_w * (1 - _s)) / 2;
var _dy = y + afundamento + (_h * (1 - _s)) / 2;

// --- ECO ---
// Anel que se expande e some, desenhado ANTES do alvo para passar por baixo dele.
// Só Perfeito e Ótimo têm eco; o Bom não tem nenhum, e é essa ausência que separa os
// dois de baixo — presença ou ausência lê mais rápido que intensidade.
if (eco > 0) {
    var _ee = 1 + ((1 - eco) * 1.15);   // cresce de 1 até ~2,15
    var _ex = x + (_w * (1 - _ee)) / 2;
    var _ey = y + afundamento + (_h * (1 - _ee)) / 2;

    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, _ex, _ey, _ee, _ee, 0, eco_cor, eco * 0.40 * image_alpha);
    gpu_set_blendmode(bm_normal);
}

// image_alpha e respeitado porque os alvos do jogador 2 nascem transparentes e ganham
// corpo em degrade — ver versus_revelar_cena.
draw_sprite_ext(sprite_index, image_index, _dx, _dy, _s, _s, 0, c_white, image_alpha);

if (brilho > 0) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, _dx, _dy, _s, _s, 0, brilho_cor, brilho * 0.55 * image_alpha);
    gpu_set_blendmode(bm_normal);
}
