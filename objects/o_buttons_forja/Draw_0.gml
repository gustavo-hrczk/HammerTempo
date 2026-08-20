if (!instance_exists(o_controlador_geral) || o_controlador_geral.estado_jogo != MINIGAME.RITMO) {
    exit;
}

// O alvo afunda quando pressionado e acende ao acertar: cor e intensidade do
// brilho distinguem perfeito de bom, em redundância com o texto do julgamento.
var _s = 1 + (pop * 0.11);
var _w = sprite_get_width(sprite_index);
var _h = sprite_get_height(sprite_index);

var _dx = x + (_w * (1 - _s)) / 2;
var _dy = y + afundamento + (_h * (1 - _s)) / 2;

draw_sprite_ext(sprite_index, image_index, _dx, _dy, _s, _s, 0, c_white, 1);

if (brilho > 0) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, _dx, _dy, _s, _s, 0, brilho_cor, brilho * 0.55);
    gpu_set_blendmode(bm_normal);
}
